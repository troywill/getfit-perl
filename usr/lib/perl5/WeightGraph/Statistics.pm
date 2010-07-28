package WeightGraph::Statistics;

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
    @EXPORT = qw(&get_current_goal &get_current_goal_from_config &elapsed_time &graph_scale);
    %EXPORT_TAGS = ();    # eg: TAG => [ qw!name1 name2! ],

    # your exported package globals go here,
    # as well as any optionally exported functions
    @EXPORT_OK =
      qw(&get_current_goal &get_current_goal_from_config $Current_goal $max_weight $min_weight $min_time $max_time);
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

sub goal_weight {
    my ( $t, $t0, $w0, $rate ) = @_;
    $rate = $rate / 3500 / 86400;
    my $goal_weight = $w0 - $rate * ( $t - $t0 );
    return ($goal_weight);
}

sub get_current_goal {
    my ( $initial_time, $initial_weight, $loss_rate ) = @_;
    my $time_diff = time - $initial_time;
    my $current_goal =
      $initial_weight - ( $time_diff / 86400 ) * ( $loss_rate / 3500 );
    return $current_goal;
}

sub get_current_goal_from_config {
    my $config_file = shift or die "Please supply a configuration file";
    my $config = ConfigReader::Simple->new($config_file);
    
    my $initial_time = $config->get('START_TIME');
    my $initial_weight = $config->get('START_WEIGHT');
    my $loss_rate = $config->get('INITIAL_LOSS_RATE');

    my $time_diff = time - $initial_time;

    my $current_goal =
      $initial_weight - ( $time_diff / 86400 ) * ( $loss_rate / 3500 );

    print "[DEBUG] [$loss_rate] [$initial_weight]\n";
    
    return $current_goal;
}

sub elapsed_time {
    my $initial_time = shift;
    my $elapsed_time = time - $initial_time;
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

END { }              # module clean-up code here (global destructor)

1;                   # don't forget to return a true value from the file
