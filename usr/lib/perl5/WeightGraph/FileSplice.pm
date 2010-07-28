package WeightGraph::FileSplice;

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
    @EXPORT      = qw(&func1 &func2 &func4);
    %EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

    # your exported package globals go here,
    # as well as any optionally exported functions
    @EXPORT_OK   = qw($Var1 %Hashit &func3);
}
our @EXPORT_OK;

# exported package globals go here
our $Var1;
our %Hashit;

# non-exported package globals go here
our @more;
our $stuff;

# initialize package globals, first exported ones
$Var1   = '';
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
sub func1      {}    # no prototype
sub func2()    {}    # proto'd void
sub func3($$)  {}    # proto'd to 2 scalars

# this one isn't exported, but could be called!
sub func4(\%)  {}    # proto'd to 1 hash ref

END { }       # module clean-up code here (global destructor)

## YOUR CODE GOES HERE


#===== SUBROUTINE ===========================================================
# Name      : file_splice()
# Purpose   : parse command line options and update the %Option hash
# Parameters: start_time => Unix time of start of period of interest
#           : INPUT_FILE => Filename of unix timestamped weight readings
#           : OUTPUT_FILE => Filename of unix timestamped to be written
# Returns   : n/a
# Outputs   : Writes a file of unix timestamped weight readings after start_time
#============================================================================

sub file_splice {
    my ( $start_time,  $INPUT_FILE, $OUTPUT_FILE ) = @_;
    open ( my $input_file, '<', $INPUT_FILE ) or die "Unable to open $INPUT_FILE for reading: $!";
    open ( my $output_file, '>', $OUTPUT_FILE ) or die "Unable to open $OUTPUT_FILE  for writing: $!";
    while (<$input_file>) {
	my ( $time, $weight ) = split ( / /, $_ );
	if ( $time > $start_time ) {
	    print  $output_file $_;
	}
    }
}

sub generate_segment_data_file {
    my ( $start_time,  $INPUT_FILE, $OUTPUT_FILE ) = @_;
    open ( my $input_file, '<', $INPUT_FILE ) or die "Unable to open $INPUT_FILE for reading: $!";
    open ( my $output_file, '>', $OUTPUT_FILE ) or die "Unable to open $OUTPUT_FILE  for writing: $!";
    my $transition = 'no';
    my ( $previous_time, $previous_weight ) = ( 0, 0 );
    while (<$input_file>) {
	my ( $time, $weight ) = split;
	if ( $time < $start_time ) {
	} else {
	    if ( $transition eq 'no' ) {
		my ( $t, $w ) = &calculate_transition ( $previous_time, $previous_weight, $time, $weight, $start_time );
		print $output_file "$t $w\n";
		$transition = 'yes';
	    }
	    print $output_file "$time $weight\n";
	}
	( $previous_time, $previous_weight ) = ( $time, $weight );
    }
}

sub calculate_transition {
    my ( $t0, $w0, $t2, $w2, $t1 ) = @_;
    print "=> ( $t0, $w0, $t2, $w2, $t1 )\n";
    my $w1 = $w0 + ( $w2 - $w0 ) * ( $t1 - $t0 ) / ( $t2 - $t0 );
    return ( $t1, $w1 );
}

1;  # don't forget to return a true value from the file
