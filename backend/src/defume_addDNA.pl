#!/tools/bin/perl

use strict;
#use warnings;
#use Data::Dumper;
use JSON;


########################################################################################
#
# PROCESS COMMAND LINE AND INITIATE JSON
#
########################################################################################

my $input_file = shift(@ARGV);
die "Cannot find input file" unless (-e $input_file);

my $json_inp = do { local $/; <STDIN> };
my $data = decode_json $json_inp;

#print Dumper(%$data);
#die;


########################################################################################
#
# Read preassembled DNA input 
#
########################################################################################

my %seqs;

my $line = '';
open(SEQ, "<$input_file") or die "Cannot open $input_file: $!\n";
$line = <SEQ> while (defined $line and $line !~ m/^>/);
#print "$line\n";
while (defined $line) {
    chomp $line;
    (my $name = $line) =~ s/>//;
    #print "$name\n";
    my $dna = '';
    while (defined ($line = <SEQ>) and $line !~ m/^>/) {
        #print "$line";
        chomp($line);
        $line =~ s/\s//g; # remove possible whitespaces
        $dna .= uc($line);
    }
    $seqs{$name} = $dna;
}
close(SEQ);

=pod
#print Dumper(%seqs);
#die;

########################################################################################
#
# Add read information to contig structure
#
########################################################################################

my %reads;

if (-e $assembly_report) {

    open(REPORT, "<$assembly_report") or die "Cannot open file $assembly_report: $!\n";
    while (defined(my $line = <REPORT>)) {
        chomp($line);
        if ($line =~ m/^Contig (\d+)/) {
            my $contig = "Contig$1";
            
            my $get_read = 1;
            
            while ($get_read == 1) {
                $line = <REPORT>;
                unless ($line =~ m/^This contig is composed of:/ or $line =~ m/^\s*$/) {
                    
                    my @read = split(/\s+/, $line);
                    (my $read_name = $read[0]) =~ s/://; 
                    my $dir;
                    if ($read[-1] =~ m/\>/) {
                        $dir = 1;
                    } else {
                        $dir = -1; 
                    }
                    #print STDERR "$line\n";
                    $line =~ m/:\s+(-?\d+)\s+\(\s*(-?\d+)\)\s+(-?\d+)\s+\(\s*(-?\d+)\)\s+/;
                    #print STDERR "1: $1\t2: $2\t3: $3\t4: $4\n";
                    die "Something is not right for $line\n1: $1\t2: $2\t3: $3\t4: $4\n" unless (defined($1) and defined($2) and defined($3) and defined($4));
                    
                    my $start = $1*1;
                    my $btrim = $2*1;
                    my $end = $3*1;
                    my $etrim = $4*1;
                    
                    #my $start = substr($line, 27, 5)*1;
                    #my $btrim = substr($line, 34, 4)*1;
                    #my $end = substr($line, 40, 5)*1;
                    #my $etrim = substr($line, 48, 4)*1;
                    
                    my %tmp_read = ('name' => $read_name, 'start' => $start, 'end' => $end, 'Btrim' => $btrim, 'Etrim' => $etrim, 'direction' => $dir);
                    push(@{$reads{$contig}}, \%tmp_read);
                }
                $get_read = 0 if ($line =~ m/^\s*$/); # i.e. empty line
            }
            
        }
        
    }
    close(REPORT);
} else {
    print LOG "# WARNING: Phrap report file: $assembly_report was not found. No read information was added to the contigs\nRead to contig associations will not appear in JSON output\n";
    die;
}
=cut


foreach my $obj (@$data{Contig}) {
    foreach my $contig (@$obj) {
        my $contig_name = $contig->{contig};
        #$$contig{reads} = \@{$reads{$contig_name}} if (exists $reads{$contig_name});
        $$contig{dna_seq} = $seqs{$contig_name};
    }
}

my $json_encoded = encode_json \%$data;
print STDOUT "$json_encoded\n";

exit;
