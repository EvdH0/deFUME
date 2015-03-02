#!/tools/bin/perl

=head1 NAME

metaparser_makeJSON.pl - Create JSON file containing contigs from assembly  

=head1 SYNOPSIS

metaparser_makeJSON.pl -h

=head1 DESCRIPTION

Create JSON file based on the contigs and singlets provided by the assembly

=head1 OPTIONS
    
    -i : Directory containing nucleotide FASTA files (cannot contain other files) [current dir]\n";
    
    -h : Print this help information\n";
  
=head1 NOTES

This tools is currently being tested. Please consult one of the authors for advice or questions on usage.

=head1 AUTHORS

Henrik Marcus Geertz-Hansen <hmgh@cbs.dtu.dk>
Eric van der Helm <evand@biosustain.dtu.dk>
Hans Genee <hjg@biosustain.dtu.dk>

=head1 LICENSE

Copyright (C) 2014, CBS @ DTU, Denmark

=cut



########################################################################################
#
# INITIATE AND IMPORT REQUIRED LIBRARIES
#
########################################################################################

use strict;
#use warnings;
use Getopt::Std;
use Data::Dumper;
use FindBin qw($RealBin);
use JSON;
use lib "$RealBin/../lib/";
use FASTA;



########################################################################################
#
# INITIAL CHECKS AND SETUP
#
########################################################################################

my $architecture = `uname -m`; 
chomp $architecture;
$architecture = lc($architecture);



########################################################################################
#
# PROCESS COMMAND LINE
#
########################################################################################

my $command_line_input = join(' ', @ARGV);

getopts('hi:l:v')||Usage();
#
# Usage
#
if (defined($Getopt::Std::opt_h)||defined($Getopt::Std::opt_h)){
  # Print help message
  Usage();
}

# print help information
sub Usage {
    print "\n  Description: Create JSON file based on the contigs and singlets provided by the assembly\n\n";
    print "  Usage: $0 -h -i <filename> -l <filename> -v -k\n";
    print "  Options:\n";
    print "  -i : Directory containing nucleotide FASTA files (cannot contain other files) [current dir]\n";
    print "  -l : Logfile if -v is defined [STDERR]\n";
    print "  -v : Verbose [OFF]\n";
    print "  -h : Print this help information\n";
    print "\n\n";
    exit;                              
}


#
# Open input
#
my $input_dir;
if (defined($Getopt::Std::opt_i)) {
    $input_dir = $Getopt::Std::opt_i;
} else {
    die "Input directory containing fasta file(s) is not defined\n";
}


# Logfile
my $log_handle;
unless (defined($Getopt::Std::opt_l)) {
    *LOG=*STDERR;
} else {
    open($log_handle, ">$Getopt::Std::opt_l") or die "Cannot open $Getopt::Std::opt_l: $!\n";
    #print LOG "Log: $Getopt::Std::opt_l is open\n";
    unless (defined($Getopt::Std::opt_v)) {
        warn "$Getopt::Std::opt_l defined but verbose mode not turned ON!\n";
    }
}
# Verbose mode (no logs written unless defined)
my $verbose = 0;
$verbose = 1 if (defined($Getopt::Std::opt_v));



########################################################################################
#
# MAIN
#
########################################################################################


#
# Check input sequences and split into manageable file sizes 
#

my @input_files = `ls -1 $input_dir/*`;
#print Dumper(@input_files);
&logdie("No fasta files were found in inputdir: $input_dir\n", $log_handle) unless (scalar(@input_files) > 0);

print $log_handle "# Starting gene prediction\n" if ($verbose);
my @output;
foreach my $fasta_input (@input_files) {
    open(FASTA, "<$fasta_input") or die "Cannot open file: $fasta_input, $!, $?\n";
    while (! eof (FASTA)) {
        my %fasta = readFASTA(\*FASTA);
        #print STDOUT Dumper(keys %fasta);
        my %contig = ('contig' => $fasta{name}, 'length' => $fasta{len}*1);
        push(@output, \%contig);
    }
    close(FASTA);
}

my %json;
$json{Contig} = \@output;

my $json_encoded = encode_json \%json;
print STDOUT "$json_encoded\n";

exit;



########################################################################################
#
# SUBFUNCTIONS
#
########################################################################################

sub logdie {
    
    my ($log_base, $log_handle) = @_;
    
    print $log_handle "$log_base";
    die;
    
}