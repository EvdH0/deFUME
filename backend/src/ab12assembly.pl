#!/usr/bin/perl

=head1 NAME

ab12assembly.pl - Assembly of Sanger sequencing reads with Phred and Phrap

=head1 SYNOPSIS

ab12assembly.pl -h -i <path> -o <filename> -l <filename> -v -s <filename> -m <score> -a <score> 

=head1 DESCRIPTION

Base calling from ABI-type chromatograms (.ab1-files) and assembly of reads.
Optional vector masking before assembly is possible.

=head1 OPTIONS
  
  -h  : Print help information
  
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
#use Data::Dumper;
use FindBin qw($RealBin);
use lib "$RealBin/../lib/";
use FASTA;
use Cwd;
use Cwd 'abs_path';

$ENV{PHRED_PARAMETER_FILE} = "$RealBin/../phredpar.dat";

########################################################################################
#
# INITIAL CHECKS AND SETUP
#
########################################################################################

my $platform = `uname -s`;
chomp($platform);
$platform = lc($platform);

my $architecture = `uname -m`; 
chomp $architecture;
$architecture = lc($architecture);


########################################################################################
#
# PROCESS COMMAND LINE
#
########################################################################################

getopts('hi:o:l:s:q:m:a:t:n:vf:r:w') or Usage();

#
# Usage
#
if (defined($Getopt::Std::opt_h) or defined($Getopt::Std::opt_h)){
  # Print help message
  Usage();
}

sub Usage {
    print ("Usage: $0 [-h] [-i name]\n");
    print ("Description:\n");
    print ("$0 - Base call from chromatograms and adapt filenames and description for phrap\n");
    print ("\n");
    print ("Options:\n");
    print ("  -h  : Display this message\n");
    print ("  -i  : Directory of ab1 files [current dir]\n");
    print ("  -o  : Filename of assembly summary [assembly_report.txt]\n");
    print ("  -s  : Filename of sequence of vector to be masked out before assembly [NONE]\n");
    print ("  -q  : PHRED ONLY: Error rate for base calling [0.01]\n");
    print ("  -m  : PHRAP ONLY: Minimum overlap of reads (10 => low stringency, 15 => medium, 20 => high) [20]\n");
    print ("  -a  : PHRAP ONLY: Minimum alignment score (10 => low stringency, 20 => medium, 30 => high) [20]\n");
    print ("  -t  : Minimum length (in nucleotides) of non assembled reads [150]\n");
    print ("  -n  : Minimum length (in nucleotides) of non vector match in contigs and singlets [100]\n");
    print ("  -f  : Forward primer pattern (separate multiple entries by comma e.g. \'_OGEN41_,_GEBO31_\')\n");
    print ("  -r  : Reverse primer pattern (separate multiple entries by comma e.g. \'_OGEN44_,_GEBO29_\')\n");
    print ("  -l  : Filename of logfile [STDERR]\n");
    print ("  -v  : Verbose\n");
    print ("  -w  : Www-version [ON/[OFF]]\n");
    print ("  -h  : Print this message\n");
    print ("\n");
 exit;
} # Usage

my $verbose = 0;
$verbose = 1 if ($Getopt::Std::opt_v);

if (defined($Getopt::Std::opt_l)) {
    open(LOG,">$Getopt::Std::opt_l");
} else {
    *LOG = *STDERR;
}

# make sure that relative paths are converted to absolute before changing dir
my $vector_file = abs_path($Getopt::Std::opt_s) if (defined($Getopt::Std::opt_s));
print LOG "$vector_file\n" if (defined($Getopt::Std::opt_s) and $verbose);

my $input_dir = getcwd;
if (defined($Getopt::Std::opt_i)) {
    $input_dir = $Getopt::Std::opt_i;
    $input_dir =~ s/\/$//;
    #print STDOUT "$input_dir\n";
    chdir("$input_dir");
}

my $output = 'assembly_report.txt';
$output = $Getopt::Std::opt_o if (defined($Getopt::Std::opt_o));
open(OUT,">$output") or die "Cannot open output file $output: $!\n";


my $base_call = 1;
if ($Getopt::Std::opt_p) {
    # not possible in current version
    $base_call = 0 if (defined($Getopt::Std::opt_p));
    print LOG "# User phd.1-files are used. No base calling done.\n" if ($Getopt::Std::opt_v);
    
}


my $min_match = 20;
$min_match = $Getopt::Std::opt_m if (defined($Getopt::Std::opt_m));

my $min_score = 20;
$min_score = $Getopt::Std::opt_a if (defined($Getopt::Std::opt_a));

my $min_singlet = 150;
$min_singlet = $Getopt::Std::opt_t if (defined($Getopt::Std::opt_t));

my $min_nonvector = 100;
$min_nonvector = $Getopt::Std::opt_n if (defined($Getopt::Std::opt_n));

my $min_quality = 0.01;
$min_quality = $Getopt::Std::opt_q if (defined($Getopt::Std::opt_q));


#*STDERR = *STDOUT;


########################################################################################
#
# PRIMER SPECIFICATIONS
#
########################################################################################

my %primers = ('_oGEN43_' => 'fwd',
               '_oGEN44_' => 'rev',
               '_OGEN43_' => 'fwd',
               '_OGEN44_' => 'rev',
               '_43_' => 'fwd',
               '_44_' => 'rev',
               '_F_' => 'fwd',
               '_R_' => 'rev',
               '_F$' => 'fwd',
               '_R$' => 'rev',
               '_GEBO29_' => 'fwd',
               '_GEBO31_' => 'rev');

if (defined($Getopt::Std::opt_f) or defined($Getopt::Std::opt_r)) {
    if (defined($Getopt::Std::opt_f) or defined($Getopt::Std::opt_r)) {
        
        my $primer_fwd = $Getopt::Std::opt_f;
        $primer_fwd =~ s/ //; # remove potential spaces between entries
        $primer_fwd =~ s/\,/\|/;
        
        my $primer_rev = $Getopt::Std::opt_r;
        $primer_rev =~ s/ //; # remove potential spaces between entries
        $primer_rev =~ s/\,/\|/;
        
        $primers{$primer_fwd} = 'fwd';
        $primers{$primer_rev} = 'rev';
        
        print LOG "# User defined primer patterns used:\n# Fwd: $primer_fwd\n# Rev: $primer_rev\n" if ($verbose);
    } else {
        die "Please specify both a forward and a reverse primer pattern using -f and -r\n";
    }
    
}

my ($primer_fwd, $primer_rev);
foreach my $primer (keys %primers) {
    $primer_fwd .= "$primer|" if ($primers{$primer} eq 'fwd');
    $primer_rev .= "$primer|" if ($primers{$primer} eq 'rev');
}
chop($primer_fwd, $primer_rev);
print LOG "fwd: $primer_fwd\nrev: $primer_rev\n" if ($verbose);



###########################################################################################################
#
# MAIN
#
###########################################################################################################

#=pod

my @ab1_files;
unless (-d "org_files") {
    system("mkdir org_files");
    system("mv *.ab1 org_files"); 
}

@ab1_files = `ls -1 org_files/*.ab1`;
die "No ab1-files found in directory 'org_files'.\n" if (scalar(@ab1_files) == 0);
system("mkdir ab1_files") unless (-d "ab1_files");
system("mkdir phd_files") unless (-d "phd_files");



###########################################################################################################
#
# .ab1-FILE RENAMING
#
###########################################################################################################


foreach my $file (@ab1_files) {
    chomp($file);
    $file =~ s/org_files\///;
    my @name = split(/\./, $file);
    #print "$name[0]\n";
    #die;
    if ($name[0] =~ m/$primer_fwd/) {
        system("ln -f -s ../org_files/$file ab1_files/$name[0].b.ab1");
        
    } elsif ($name[0] =~ m/$primer_rev/) {
        system("ln -f -s ../org_files/$file ab1_files/$name[0].g.ab1");
        
    } else {
        system("ln -f -s ../org_files/$file ab1_files/$name[0].b.ab1"); # considering unknown primers as uni-directional
        print LOG "Unknown naming scheme for read: $name[0]\nPlease consult one of the authors of the program to improve usability\n" if ($verbose);
    }
}



###########################################################################################################
#
# BASE CALLING WITH PHRED
#
###########################################################################################################


print LOG "Running Phred\n" if ($verbose);
my $cmd = "$RealBin/$architecture/phred -id ab1_files -trim_alt '' -trim_cutoff $min_quality -trim_out -exit_nomatch -pd phd_files";
system("$cmd");
die "Command '$cmd' did not execute succesfully\n" unless ($? == 0);




###########################################################################################################
#
# PHD FILE TO FASTA FILE CONVERSION
#
###########################################################################################################

print LOG "Running phd2fasta\n" if ($verbose);

$cmd = "$RealBin/$architecture/phd2fasta -id phd_files -os seqs_fasta -oq seqs_fasta.qual -of phd2fasta.log";
system("$cmd");
system("cp seqs_fasta.qual seqs_fasta.screen.qual");
die "Command '$cmd' did not execute succesfully\n" unless ($? == 0);



###########################################################################################################
#
# VECTOR MASKING
#
###########################################################################################################


if (defined($Getopt::Std::opt_s)) {
    print LOG "Running cross_match to mask vector sequences\n" if ($verbose);
    $cmd = "$RealBin/$architecture/cross_match seqs_fasta $vector_file -minmatch 12 -minscore 20 -screen > screen.out";
    system("$cmd");
    die "Command '$cmd' not executed succesfully\n" unless ($? == 0);
} else {
    system("mv seqs_fasta seqs_fasta.screen");
}



###########################################################################################################
#
# ASSEMBLY WITH PHRAP
#
###########################################################################################################

print LOG "Running phrap to assemble reads into contigs\n" if ($verbose);

$cmd = "$RealBin/$architecture/phrap seqs_fasta.screen -preassemble -minmatch $min_match -minscore $min_score -trim_score 20 -new_ace > phrap.out";
system("$cmd");
die "Command '$cmd' not executed succesfully\n" unless ($? == 0);



###########################################################################################################
#
# POST PROCESSING OF ASSEMBLY
#
###########################################################################################################
#=cut

print LOG "Post processing the assembly\n" if ($verbose);

open(PHRAP, "<phrap.out") or die "Cannot open phrap.out: $!\n";

my $contig_flag = 0;
my $contig_resolution = 50; # in bp
while (defined(my $line = <PHRAP>)) {
    chomp($line);
    $contig_flag = 1 if ($line =~ m/Contig (\d+)\.\s+(\d+)\s+\w+\;\s+(\d+)\s+bp\s+\(untrimmed\)\,\s+(\d+)\s+\(trimmed\)/); # $1 is contig number, $2 is total numer of reads and $3 is read length (untrimmed) $4 is length but trimmed
    if ($contig_flag == 1) {
        my $contig_no = $1;
        my $total_reads = $2;
        my $contig_length = $3; # $3 is untrimmed $4 is trimmed
        print OUT "Contig $contig_no | length: $contig_length bp | reads: $total_reads\n";
        
        my $contig_print = 0;
        my $offset;
        while ($contig_flag == 1 and defined($line = <PHRAP>)) {
            unless ($line =~ m/^\s*$/) {
                
                # avoid issue with the following line observed when no vector masking is carried out
                unless ($line =~ m/\s+\*\*\*\*\s+PROBABLE\s+DELETION\s+READ/) { 
                    chomp($line);
                    my $reverse = 0;
                    $reverse = 1 if ($line =~ m/^C/);
                    $line =~ s/^C/ /; # remove control character from beginning of line to make format as forward read
                    
                    $line =~ m/\s+(-?\d+)\s+(\d+)\s+(.+\.ab1)\s+\d+\s+\(\s*\d+\)\s+\d+\.\d+\s+\d+\.\d+\s+\d+\.\d+\s+(\d+)\s+\(\s*\d+\)\s+(\d+)/; # $1 is start in bp, $2 is end in bp, $3 is read name $4 is trimmed at beginning of read and $5 is trimmed at end of read
                    #my $start = $1 + $4; # start of read relative to contig plus trimmed bases at the beginning
                    my $start = $1;
                    my $end = $2;# - $5; # end of read relative to contig minus trimmed bases at the end
                    
                    
                    if ($contig_print == 0) {
                        $offset = " " x sprintf("%.0f", abs($start)/$contig_resolution); # the x operator means repeat " " int(..) times
                        my $contig_total_length = sprintf("%.0f", $contig_length/$contig_resolution);
                        my $read = 'X';
                        for (my $i = 2; $i < $contig_total_length; $i++) {
                            $read .= 'x';
                        }
                        $read .= 'X';
                        
                        printf OUT ("%-55s%s%s\n", 'This contig is composed of: ', $offset, $read); # read starts at char. pos. 35 on line and extends $total_length
                        $contig_print = 1;
                    }
                    
                    
                    my $total_length = sprintf("%.0f", $end/$contig_resolution) - sprintf("%.0f", $start/$contig_resolution);
                    #print STDOUT "Debug: $start, $end, $total_length\n";
                    my $read = '+';
                    for (my $i = 2; $i < $total_length; $i++) {
                        $read .= '-';
                    }
                    if ($reverse) {
                        $read .= '<';
                        $read = reverse($read);
                    } else {
                        $read .= '>';
                    }
                    
                    if ($start > $contig_resolution) {
                        my $displacement = sprintf("%.0f",$start/$contig_resolution);
                        $read = "$offset$read";
                        for (my $i = 0; $i < $displacement; $i++) {
                            $read = ' '. $read;
                        }
                    }
                    
                    my $readname = $3;
                    my $usr_name;
                    if (-l "ab1_files/$readname") {
                        my $link = readlink("ab1_files/$readname");
                        #print STDERR "link: $link, readname: $readname\n";
                        
                        my @path = split(/\//, $link);
                        ($usr_name = $path[-1]) =~ s/\.ab1//; #remove .ab1 suffix from read name
                        #print STDERR "name: $usr_name\n";
                        
                    } else {
                        print LOG "# Symbolic link ab1_files/$readname does not exist\n" if ($verbose);
                    }
                    
                    printf OUT ("%-27s%5s (%4d) %5d (%4s) | %s\n", "$usr_name:", $start, $4, $end, $5, $read);
                }
                
            } else {            
                $contig_flag = 0;
                print OUT "\n";
                
            }
        }
    }
}
close(PHRAP);


# Rename contigs
system("cp seqs_fasta.screen.contigs seqs_fasta.screen.contigs_OLD");
open(OLD, '<', 'seqs_fasta.screen.contigs_OLD') or die "Cannot open file seqs_fasta.screen.contigs_OLD: $!\n";
open(NEW, '>', 'seqs_fasta.screen.contigs') or die "Cannot open file seqs_fasta.screen.contigs: $!\n";

while (defined(my $line = <OLD>)) {
    chomp($line);
    if ($line =~ m/^>/) {
        my @tmp_name = split(/\./, $line);
        print NEW ">$tmp_name[-1]\n";
    } else {
        print NEW "$line\n";
    }
}
close(OLD);
close(NEW);


# rename and quality control singlets
system("cp seqs_fasta.screen.singlets seqs_fasta.screen.singlets_OLD");
open(OLD, '<', 'seqs_fasta.screen.singlets_OLD') or die "Cannot open file seqs_fasta.screen.singlets_OLD: $!\n";
open(NEW, '>', 'seqs_fasta.screen.singlets') or die "Cannot open file seqs_fasta.screen.singlets: $!\n";

while (! eof (OLD)) {
    my %fasta = readFASTA(\*OLD);
    my @tmp_name = split(/\s+/, $fasta{name});
    my $usr_name;
    if (-l "ab1_files/$tmp_name[0]") {
        my $link = readlink("ab1_files/$tmp_name[0]");
        #print "link: $link\n";
        
        my @path = split(/\//, $link);
        ($usr_name = $path[-1]) =~ s/\.ab1//; #remove .ab1 suffix from read name
        
    } else {
        warn "No user read name identified for $tmp_name[0]\n";
    }
    
    $fasta{name} = $usr_name;
    $fasta{desc} = '';
    my $vector_flag = 0;
    for (my $i = 1; $i < scalar(@{$fasta{seq}}); $i++) {
        $vector_flag++ if ($fasta{seq}->[$i] ne 'X');
    }
    
    writeFASTA(\%fasta, \*NEW) if (scalar(@{$fasta{seq}}) > $min_singlet and $vector_flag > 120); # singlets below 150 nucleotides and reads only consisting of >80% vector are filtered
}
close(OLD);
close(NEW);

print LOG "Done\n" if ($verbose);

chdir("..") if (defined($Getopt::Std::opt_i));

exit;