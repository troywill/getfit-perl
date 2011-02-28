#!/usr/bin/env perl
use warnings;
use strict;

my $start_weight = 248.80;
my $end_weight = 239.99;
my $start_time = 1298657280;
my $calories_per_day = 668;

my $end_time = &calc_end_time( $start_weight, $end_weight, $start_time, $calories_per_day );
my $end_time_string = localtime($end_time);
print "$end_time_string\n";

$end_time = 1301641200;
my $rate = &calc_rate( 248.3, 239.99, 1298918340, $end_time );
print "Rate: $rate\n";

sub calc_rate {
    my ( $start_weight, $end_weight, $start_time, $end_time ) = @_;
    my $seconds_diff = $end_time - $start_time;
    my $lbs_diff = ( $start_weight - $end_weight ) ;
    my $lbs_per_second = $lbs_diff / $seconds_diff;
    my $cals_per_second = $lbs_per_second * 3500.0;
    my $cals_per_day = $cals_per_second * 86400.0;
    return int($cals_per_day);
}

sub calc_end_time {
    my ( $start_weight, $end_weight, $start_time, $calories_per_day ) = @_;
    my $lbs_per_second = $calories_per_day / 3500.0 / 86400.0;
    my $lbs_diff = ( $start_weight - $end_weight ) ;

    my $seconds = $lbs_diff / $lbs_per_second;
    return int($seconds + $start_time);
}
