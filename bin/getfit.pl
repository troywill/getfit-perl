#!/usr/bin/env perl

use warnings;
use strict;
use LWP::Simple;
use Getopt::Long;
use FindBin qw($Bin);
use File::Basename;
use lib "$Bin/../lib";
### BEGIN CONFIGURATION SECTION
my $config_file = $ENV{HOME} . '/.getfit.conf';
my $BASE_DIR = "/var/getfit";

my %User_Preferences;
open(CONFIG, "<", $config_file) or die "Unable to read config file $config_file: $!";
while (<CONFIG>) {
    chomp;                  # no newline
    s/#.*//;                # no comments
    s/^\s+//;               # no leading white
    s/\s+$//;               # no trailing white
    next unless length;     # anything left?
    my ($var, $value) = split(/\s*=\s*/, $_, 2);
    $User_Preferences{$var} = $value;
}
### END CONFIGURATION SECTION
### BEGIN GET OPTIONS SECTION
my $interval = 1;
my $duration = 86400;
my $camera_name = 'CAM2';
my $hostname = '192.168.1.20';
GetOptions( "interval=i" => \$interval,
            "duration=i" => \$duration,
            "camera=s" => \$camera_name,
            "hostname=s" => \$hostname);
my $PIDFILE = "$BASE_DIR/run/pid.asf.$camera_name";
my $UPLOADFILE = "$BASE_DIR/log/videofiles";
my $RSYNCFILE = "$BASE_DIR/log/rsyncfile";
### END GET OPTIONS SECTION

my $initial_time = 1358716005;
my $calories_per_day = 120;
my $seconds_per_day = 86400;
my $calories_per_pound = 3500;
my $weight_loss_rate = $calories_per_day / $seconds_per_day / $calories_per_pound;
my $delta_time = time - $initial_time;
my $goal = 178.2 - $weight_loss_rate * $delta_time;
print "Goal: $goal\n";
