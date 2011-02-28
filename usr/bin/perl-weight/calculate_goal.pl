#!/usr/bin/env perl
use warnings;
use strict;

my $start_weight = 248.80;
my $end_weight = 247;
my $start_time = 1298657280;
my $calories_per_day = 668;

my $end_time = &calc_end_time( $start_weight, $end_weight, $start_time, $calories_per_day );
my $end_time_string = localtime($end_time);

print "$end_time_string\n";


sub calc_end_time {
    my ( $start_weight, $end_weight, $start_time, $calories_per_day ) = @_;
    my $lbs_per_second = $calories_per_day / 3500.0 / 86400.0;
    my $lbs_diff = ( $start_weight - $end_weight ) ;

    my $seconds = $lbs_diff / $lbs_per_second;
    return int($seconds + $start_time);
}
