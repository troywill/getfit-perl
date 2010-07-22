package Getfit::Statistics;

use strict;
use warnings;

BEGIN {
    use Exporter   ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    # set the version for version checking
    $VERSION     = 1.00;
    # if using RCS/CVS, this may be preferred
    $VERSION = sprintf "%d.%03d", q$Revision: 1.1 $ =~ /(\d+)/g;

    @ISA         = qw(Exporter);
    @EXPORT      = qw(&elapsed_time &func2 &func4 &graph_scale);
    %EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

    # your exported package globals go here,
    # as well as any optionally exported functions
    @EXPORT_OK   = qw($Current_goal $max_weight $min_weight $min_time $max_time $%Hashit &func3);
}
our @EXPORT_OK;

# exported package globals go here
our ($Current_goal, $max_weight, $min_weight, $min_time, $max_time);
our %Hashit;

# non-exported package globals go here
our @more;
our $stuff;

# initialize package globals, first exported ones
$Current_goal   = '';
%Hashit = ();

# then the others (which are still accessible as $Some::Module::stuff)
$stuff  = '';
@more   = ();

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

sub plot_file {
    my ( $input_file, $left, $bottom, $width, $height, $gfx ) = @_;

    my ( $max_weight, $min_weight, $min_time, $max_time ) = &calculate_weight_range ( $input_file );
    my ( $xscale, $yscale ) = &graph_scale ( $width, $height, $min_weight, $max_weight, $min_time, $max_time );

    my $top = $bottom + $height;
    my $right = $left + $width;
    
    $gfx->move($left,$bottom);
    $gfx->line($left,$top);
    $gfx->line($right,$top);
    $gfx->line($right,$bottom);
    $gfx->line($left,$bottom);
    $gfx->stroke;
    
    open( my $IN, '<', $input_file ) or die "Unable to open data file: $!";
    $_ = <$IN>;
    my ( $time, $weight ) = split();
    print "plot_file ==> ( $time, $weight )\n";
    my ( $x, $y ) = &calculate_plot_point ( $weight, $time, $min_weight, $min_time, $left, $bottom, $xscale, $yscale );
    $gfx->circle($x,$y,1);
    while (<$IN>) {
	my ( $time, $weight ) = split;
     	( $x, $y ) = &calculate_plot_point ( $weight, $time, $min_weight, $min_time, $left, $bottom, $xscale, $yscale );
     	$gfx->line($x,$y);
     	$gfx->circle($x,$y,1);
     	$gfx->move($x,$y);
     }
    $gfx->circle($x,$y,2);
    $gfx->stroke;
    close $IN;
}

sub plot_file_with_params {
    my ( $input_file, $top, $bottom, $left, $right, $gfx ) = @_;

    # my ( $input_file, $start_time, $end_time, $min_weight, $max_weight ) = @_;
    my ( $max_weight, $min_weight, $min_time, $max_time ) = &calculate_weight_range ( $input_file );
    my ( $xscale, $yscale ) = &graph_scale ( $top, $bottom, $left, $right, $min_weight, $max_weight, $min_time, $max_time );

    # Rect
    $gfx->move($left,$top);
    $gfx->line($right,$top);
    $gfx->line($right,$bottom);
    $gfx->line($left,$bottom);
    $gfx->line($left,$top);
    $gfx->stroke;
    
    open( my $IN, '<', $input_file ) or die "Unable to open data file: $!";
    $_ = <$IN>;
    my ( $time, $weight ) = split();
    print "plot_file ==> ( $time, $weight )\n";
    my ( $x, $y ) = &calculate_plot_point ( $weight, $time, $min_weight, $min_time, $left, $bottom, $xscale, $yscale );
    $gfx->circle($x,$y,1);
    while (<$IN>) {
	my ( $time, $weight ) = split;
     	( $x, $y ) = &calculate_plot_point ( $weight, $time, $min_weight, $min_time, $left, $bottom, $xscale, $yscale );
     	$gfx->line($x,$y);
     	$gfx->circle($x,$y,1);
     	$gfx->move($x,$y);
     }
    $gfx->circle($x,$y,2);
    $gfx->stroke;
    close $IN;
}

sub calculate_plot_point {
    my ( $weight, $time, $weight_min, $time_min, $left, $bottom, $xscale, $yscale ) = @_;
    my $x = $left + $xscale * ( $time - $time_min );
    my $y = $bottom + $yscale * ( $weight - $weight_min );
    return ( $x, $y );
}

sub plot_segment_weights {
}

sub graph_scale {
    my ( $view_width, $view_height, $weight_min, $weight_max, $time_min, $time_max ) = @_;
    my $points_per_second = ( $view_width ) / ( $time_max - $time_min );
    my $points_per_pound =  ( $view_height ) / ( $weight_max - $weight_min );
    return ( $points_per_second, $points_per_pound );
}

sub get_current_goal {
    my ( $initial_time, $initial_weight, $loss_rate )  = @_;
    my $time_diff = time - $initial_time;
    my $current_goal = $initial_weight - ($time_diff/86400) * ($loss_rate/3500);
    return $current_goal;
}

sub elapsed_time {
    my $initial_time = shift;
    my $elapsed_time = time - $initial_time;
}

sub calculate_weight_range {
    my $SCALE_DATA_FILE = shift;
    open( my $in, '<', $SCALE_DATA_FILE ) or warn "Not able to open $SCALE_DATA_FILE: $!";
    my $max_weight = 0;
    my $min_weight = 1000;
    my $max_time = 0;
    my $min_time = 10000000000;
    while (<$in>) {
	my ( $time, $weight ) = split;
	$max_weight = $weight if ( $weight > $max_weight );
	$min_weight = $weight if ( $weight < $min_weight );
	$min_time = $time if ( $time < $min_time );
	$max_time = $time if ( $time > $max_time );
    }
    return ( $max_weight, $min_weight, $min_time, $max_time );
}

sub time_since_last_reading {
    
}

sub func2()    {}    # proto'd void
sub func3($$)  {}    # proto'd to 2 scalars

# this one isn't exported, but could be called!
sub func4(\%)  {}    # proto'd to 1 hash ref

END { }       # module clean-up code here (global destructor)

1;  # don't forget to return a true value from the file
