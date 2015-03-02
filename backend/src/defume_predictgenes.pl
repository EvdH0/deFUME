#!/tools/bin/perl

=head1 NAME

metaparser_predictgenes.pl - Predict genes from assembled DNA and add information to JSON  

=head1 SYNOPSIS

metaparser_predictgenes.pl -h

=head1 DESCRIPTION

Predict genes using MetaGeneMark and add the coordinates and direction to JSON (via STDIN)

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
use warnings;
use Getopt::Std;
use Data::Dumper;
use FindBin qw($RealBin);
use JSON;


########################################################################################
#
# INITIAL CHECKS AND SETUP
#
########################################################################################


my $architecture = `uname -m`; 
chomp $architecture;
$architecture = lc($architecture);

die "Currently the MetaGeneMark installation does not work under $architecture\n" unless ($architecture eq 'x86_64');

########################################################################################
#
# PROCESS COMMAND LINE
#
########################################################################################

my $command_line_input = join(' ', @ARGV);

getopts('hi:o:l:v')||Usage();
#
# Usage
#
if (defined($Getopt::Std::opt_h)||defined($Getopt::Std::opt_h)){
  # Print help message
  Usage();
}

# print help information
sub Usage {
    print "\n  Description: Provide overview of sequence annotations from multiple databases\n\n";
    print "  Usage: $0 -h -i <filename> -o <filename> -l <filename> -v -k\n";
    print "  Options:\n";
    print "  -i : Directory containing nucleotide FASTA files (cannot contain other files) [current dir]\n";
    print "  -o : Fasta file output containing sequences of translated predicted genes [filename]\n";
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
    die "Input directory containing fasta files for Blastx search is not defined\n";
}


# Logfile
unless (defined($Getopt::Std::opt_l)) {
    *LOG=*STDERR;
} else {
    open(LOG, ">$Getopt::Std::opt_l") or die "Cannot open $Getopt::Std::opt_l: $!\n";
    #print LOG "Log: $Getopt::Std::opt_l is open\n";
    unless (defined($Getopt::Std::opt_v)) {
        warn "$Getopt::Std::opt_l defined but verbose mode not turned ON!\n";
    }
}
# Verbose mode (no logs written unless defined)
my $verbose = 0;
$verbose = 1 if (defined($Getopt::Std::opt_v));


my $json_inp = do { local $/; <STDIN> };
my $data = decode_json $json_inp;


########################################################################################
#
# MAIN
#
########################################################################################


#
# Check input sequences and split into manageable file sizes 
#

my @input_files = `ls -1 $input_dir`;
#print Dumper(@input_files);
&logdie("No fasta files were found in inputdir: $input_dir\n") unless (scalar(@input_files) > 0);

print LOG "# Starting gene prediction\n" if ($verbose);
my %predicted_genes;
my %translated_seq;
my @contigs;
foreach my $fasta_input (@input_files) {
    next if ($fasta_input =~ m/\.gmm/);
    chomp($fasta_input);
    $ENV{HOME} = '/usr/opt/www' unless defined($ENV{HOME}); # required for gmhmmp license as www-user 
    my $cmd = "$RealBin/$architecture/gmhmmp -a -f G -m $RealBin/$architecture/MetaGeneMark_v1.mod $input_dir/$fasta_input -o $input_dir/$fasta_input.gmm";
    system("$cmd");
    
    &logdie("$cmd did not execute correctly: $?, $!\n") unless ($? == 0);
    my $contig;
    if (-e "$input_dir/$fasta_input.gmm") {
        open(GENE, "<$input_dir/$fasta_input.gmm") or &logdie("Cannot open file $input_dir/$fasta_input.gmm: $!\n");
        while (defined(my $line = <GENE>)) {
            if ($line !~ m/^#|^\s+$/) { # skip lines starting with # and empty lines
                chomp($line);
                my @data = split(/\s+/, $line);
                $contig = $data[0];
                push(@contigs, $contig) unless (exists $predicted_genes{$contig});
                
                my $dir = 1;
                $dir = -1 if ($data[6] eq '-');
                
                unless (defined($contig)) {
                    print STDOUT "$line\n";
                    die;
                }
                my $name = 1;
                $name = scalar(@{$predicted_genes{$contig}}) +1 if (defined($predicted_genes{$contig}));
                my %tmp_gene = ('start' => $data[3]*1, 'end' => $data[4]*1, 'dir' => $dir*1, 'name' => $name, 'hasBLAST' => 'False', 'hasInterPro' => 'False');
                
                push(@{$predicted_genes{$contig}}, \%tmp_gene);
                
            } elsif (defined($Getopt::Std::opt_o) and $line =~ m/^##Protein \d+$/) {
                my ($prot, $seq);
                
                while ($line =~ m/^##/) {
                    if ($line =~ m/^##Protein (\d+)/) {
                        $prot = $1;
                        
                    } elsif ($line =~ m/^##end-Protein/) {
                        ($seq = $seq) =~ s/##//g;
                        chomp($seq);
                        push(@{$translated_seq{$contig}}, $seq);
                        $seq = '';
                        
                    } else {
                        $seq .= $line;
                        
                    }
                    
                    $line = <GENE>;
                }
                
            }
            
        }
        
    } else {
        &logdie("$cmd did not execute succesfully. Program exited correctly but output cannot be found\n");
    }
    
}
#print STDOUT "THis is almost working\n";
#print STDOUT Dumper(%predicted_genes);


# add to data structure producing JSON file

foreach my $obj (@$data{Contig}) {
    
    foreach my $contig (@$obj) {
        my $contig_name = $contig->{contig};
        
        if (exists $predicted_genes{$contig_name}) {
            $$contig{ORF} = \@{$predicted_genes{$contig_name}};
            $$contig{ORFs_found} = scalar(@{$predicted_genes{$contig_name}})*1;
        } else {
            $$contig{ORF} = [];
            $$contig{ORFs_found} = 0;
        }
    }
}


my $json_encoded = encode_json \%$data;
print STDOUT "$json_encoded\n";

## print predicted genes as fasta
if (defined($Getopt::Std::opt_o)) {
    open(FASTA, ">$Getopt::Std::opt_o") or die "Cannot write to file $Getopt::Std::opt_o: $!, $?\n";
    foreach my $contig (@contigs) {
        my $total = scalar(@{$translated_seq{$contig}});
        for (my $i = 0; $i < $total; $i++) {
            my $current = $i + 1;
            print FASTA ">${contig}_ORF_${current} start: $predicted_genes{$contig}[$i]{start} end: $predicted_genes{$contig}[$i]{end} dir: $predicted_genes{$contig}[$i]{dir}\n";
            print FASTA "$translated_seq{$contig}[$i]\n";
        }
    }
    close(FASTA);
}

exit;

sub logdie {
    
    my ($log_base) = shift;
    
    print LOG "$log_base";
    die;
    
}
