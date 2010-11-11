package WeightGraph::ParameterPlot;

use strict;
use warnings;

BEGIN {
    use Exporter ();
    our ( $VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS );

    # set the version for version checking
    $VERSION = 1.00;

    # if using RCS/CVS, this may be preferred
    $VERSION = sprintf "%d.%03d", q$Revision: 1.1 $ =~ /(\d+)/g;

    @ISA    = qw(Exporter);
    @EXPORT = qw(&plot_file_with_range &graph_scale);
    %EXPORT_TAGS = ();    # eg: TAG => [ qw!name1 name2! ],

    # your exported package globals go here,
    # as well as any optionally exported functions
    @EXPORT_OK =
      qw( &plot_file_with_range $Current_goal $max_weight $min_weight $min_time $max_time $%Hashit &func3);
}
our @EXPORT_OK;

# exported package globals go here
our ( $Current_goal, $max_weight, $min_weight, $min_time, $max_time );
our %Hashit;

# non-exported package globals go here
our @more;
our $stuff;

# initialize package globals, first exported ones
$Current_goal = '';
%Hashit       = ();

# then the others (which are still accessible as $Some::Module::stuff)
$stuff = '';
@more  = ();

# all file-scoped lexicals must be created before
# the functions below that use them.

# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();

# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {

    # stuff goes here.
};

# make all your functions, whether exported or not;
# remember to put something interesting in the {} stubs

## YOUR CODE GOES HERE

sub plot_file_with_range {
    my ( $input_file, $left, $bottom, $width, $height, $gfx, $weight_min,
        $weight_max, $min_time, $max_time )
      = @_;

#    my ( $max_weight_placeholder, $min_weight_placeholder, $min_time,
#         $max_time ) = &calculate_weight_range($input_file);

    my ( $xscale, $yscale ) =
      &graph_scale( $width, $height, $weight_min, $weight_max, $min_time,
        $max_time );

    my $top   = $bottom + $height;
    my $right = $left + $width;

    $gfx->move( $left, $bottom );
    $gfx->line( $left,  $top );
    $gfx->line( $right, $top );
    $gfx->line( $right, $bottom );
    $gfx->line( $left,  $bottom );
    $gfx->stroke;

    open( my $IN, '<', $input_file ) or die "Unable to open data file: $!";
    $_ = <$IN>;
    my ( $time, $weight ) = split();
    print "plot_file ==> ( $time, $weight )\n";
    my ( $x, $y ) =
      &calculate_plot_point( $weight, $time, $weight_min, $min_time, $left,
        $bottom, $xscale, $yscale );
    $gfx->circle( $x, $y, 1 );
    while (<$IN>) {
        ( $time, $weight ) = split;
        ( $x, $y ) =
          &calculate_plot_point( $weight, $time, $weight_min, $min_time, $left,
            $bottom, $xscale, $yscale );
        $gfx->line( $x, $y );
        $gfx->circle( $x, $y, 1 );
        $gfx->move( $x, $y );
    }
    $gfx->circle( $x, $y, 2 );
    $gfx->stroke;
    close $IN;
    return ( $x, $y, $weight );
}

sub plot_goal_line {
    my (
        $input_file,    $left,       $bottom,
        $width,         $height,     $gfx,
        $weight_min,    $weight_max, $TOP_GOAL_CALORIES,
        $TOP_GOAL_TIME, $TOP_GOAL_WEIGHT, $min_time, $max_time
    ) = @_;

    my ( $xscale, $yscale ) =
      &graph_scale( $width, $height, $weight_min, $weight_max, $min_time,
        $max_time );

    my $top   = $bottom + $height;
    my $right = $left + $width;

    my $w1 = &goal_weight( $min_time, $TOP_GOAL_TIME, $TOP_GOAL_WEIGHT, $TOP_GOAL_CALORIES );
    my $w2 = &goal_weight( $max_time, $TOP_GOAL_TIME, $TOP_GOAL_WEIGHT, $TOP_GOAL_CALORIES );

    my ( $x, $y ) = &calculate_plot_point( $w1, $min_time, $weight_min, $min_time, $left, $bottom, $xscale, $yscale );
    $gfx->move( $x,$y );
    ( $x, $y ) = &calculate_plot_point( $w2, $max_time, $weight_min, $min_time, $left, $bottom, $xscale, $yscale );
    $gfx->line( $x, $y );
    $gfx->stroke;

    return $w2; # This is goal weight at end of 
}

sub goal_weight {
    my ( $t, $t0, $w0, $rate ) = @_;
    $rate = $rate / 3500 / 86400;
    my $goal_weight = $w0 - $rate * ( $t - $t0 );
    return ($goal_weight);
}

sub calculate_plot_point {
    my ( $weight, $time, $weight_min, $time_min, $left, $bottom, $xscale,
        $yscale )
      = @_;
    my $x = $left + $xscale *   ( $time - $time_min );
    my $y = $bottom + $yscale * ( $weight - $weight_min );
    return ( $x, $y );
}

sub graph_scale {
    my (
        $view_width, $view_height, $weight_min,
        $weight_max, $time_min,    $time_max
    ) = @_;

    print "TDWL156: $time_max, $time_min\n";
    
    my $points_per_second = ($view_width) /  ( $time_max - $time_min );
    my $points_per_pound  = ($view_height) / ( $weight_max - $weight_min );
    return ( $points_per_second, $points_per_pound );
}

sub calculate_weight_range {
    my $SCALE_DATA_FILE = shift;
    open( my $in, '<', $SCALE_DATA_FILE )
      or warn "Not able to open $SCALE_DATA_FILE: $!";
    my $max_weight = 0;
    my $min_weight = 1000;
    my $max_time   = 0;
    my $min_time   = 10000000000;
    while (<$in>) {
        my ( $time, $weight ) = split;
        $max_weight = $weight if ( $weight > $max_weight );
        $min_weight = $weight if ( $weight < $min_weight );
        $min_time   = $time   if ( $time < $min_time );
        $max_time   = $time   if ( $time > $max_time );
    }
    return ( $max_weight, $min_weight, $min_time, $max_time );
}

END { }    # module clean-up code here (global destructor)

1;         # don't forget to return a true value from the file
