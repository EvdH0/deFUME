#!/tools/bin/perl

=head1 NAME

metaparser_blastp.pl - Make JSON file containing sequence annotations from Blastx (local) and InterPro (via SOAP) 

=head1 SYNOPSIS

metaparser_blastp.pl -h

=head1 DESCRIPTION

To be addded...

=head1 OPTIONS

    -i : Directory containing nucleotide FASTA files (cannot contain other files) [current dir]

    -d : Blastp database [[nr]/sp/up]

    -t : Threads for Blastp (use up to 16 on protein-s0 or up to 4 on cge-s2) [16]

    -T : Use specific temporary directory [none]

    -l : Logfile if -v is defined [STDERR]

    -v : Verbose [OFF]

    -k : Keep temporary directory (required for parsing of search results) [ON]

    -h : Print this help information
  
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

my $cmd = 'uname -n';
my $node = `$cmd`;
chomp($node);

my $blastp = '/tools/usr/bin/blastp';
$blastp = '/tools/bin/blastp' if ($node eq 'interaction' or $node eq 'sbiology');

$cmd = "$blastp -version";
my $blastp_version = `$cmd`;
chomp($blastp_version);
die "$0 requires BLAST+. Please check your path or select a different host\n" unless ($blastp_version =~ m/\+/s);

$ENV{BLASTDB} = '/home/databases/blastdb';
$ENV{BLASTMAT} = '/usr/cbs/bio/lib/ncbi/blast/matrix';
$ENV{BLASTFILTER} = '/usr/local/bin';

use strict;
#use warnings;
use Getopt::Std;
use Cwd;
use FindBin qw($RealBin);
use File::Temp qw(tempdir tempfile);
use File::Spec;
use lib "$RealBin/../lib/";
use FASTA;


########################################################################################
#
# PROCESS COMMAND LINE
#
########################################################################################

my $command_line_input = join(' ', @ARGV);

getopts('hi:d:t:T:l:vwk') || Usage();
#
# Usage
#
if (defined($Getopt::Std::opt_h)||defined($Getopt::Std::opt_h)){
  # Print help message
  Usage();
}

# print help information
sub Usage {
    print "\n  Description: Blastp sequences using xmsub\n\n";
    print "  Usage: $0 -h -i <filename> -l <filename> -v -k\n";
    print "  Options:\n";
    print "  -i : Input FASTA file of protein sequences [none]\n";
    print "  -d : Blastp database [[nr]/sp/up]\n";
    print "  -t : Threads for Blastp (use up to 16 on protein-s0 or up to 4 on cge-s2) [4]\n";
    print "  -T : Use specific temporary directory [none]\n";
    print "  -l : Logfile if -v is defined [STDERR]\n";
    print "  -v : Verbose [OFF]\n";
    print "  -w : Www-mode (no queueing system used)\n";
    print "  -k : Keep temporary directory (required for parsing of search results) [ON/[OFF]]\n";
    print "  -h : Print this help information\n";
    print "\n\n";
    exit;                              
}

# Logfile
unless (defined($Getopt::Std::opt_l)) {
    *LOG=*STDERR;
} else {
    open(LOG, ">$Getopt::Std::opt_l") or &logdie("Cannot open $Getopt::Std::opt_l: $!\n");
    print LOG "LOG $Getopt::Std::opt_l is now open\n";
    warn "$Getopt::Std::opt_l defined but verbose mode not turned ON!\n" unless (defined($Getopt::Std::opt_v));
}
# Verbose mode (no logs written unless defined)
my $verbose = 0;
$verbose = 1 if (defined($Getopt::Std::opt_v));

#print LOG "# Commandline: $0 $command_line_input\n" if ($verbose);

my $threads = 4;
$threads = $Getopt::Std::opt_t if (defined($Getopt::Std::opt_t));
$threads = 4 if (defined($Getopt::Std::opt_w)); # www-mode overrules any other thread assignment !!

unless ($node eq 'service0') {
    &logdie("Not enough threads available on your current node: $node. Please adjust opt -t") unless ($threads <= 4);
}


#
# Open input
#
my $input_file;
if (defined($Getopt::Std::opt_i)) {
    $input_file = File::Spec->rel2abs($Getopt::Std::opt_i);
} else {
    die "Input file in FASTA format for Blastp search is not defined\n";
}



########################################################################################
#
# TEMPDIR
#
########################################################################################


my $tempdir = $Getopt::Std::opt_T;

unless (defined($Getopt::Std::opt_T)) {
    $tempdir = tempdir( "anno-XXXXX" , DIR => './' , CLEANUP => ($Getopt::Std::opt_k ? undef : 1) );
    chdir("$tempdir");
}
print LOG "# Using tempdir '$tempdir' for Blastp search\n" if ($verbose);



########################################################################################
#
# MAIN
#
########################################################################################

#
# Check input sequences and split into manageable file sizes 
#

my %inp_names;
my $entries = 0;
open(FASOUT, ">input_seqs") or die "Cannot open file 'input_seqs' for output: $!, $?\n";
open(FASIN, "<$input_file") or die "Cannot open input file: $input_file: $!, $?\n";

while (! eof (FASIN)) {
    my %fasta = readFASTA(\*FASIN);
    $entries++;
    my $id = $fasta{name};
    die "More than one sequence is named $id. Please use unique identifiers or run $RealBin/src/rename_fastas.pl\n" if (exists($inp_names{$id}));
    
    $inp_names{$id}++;
    writeFASTA(\%fasta, \*FASOUT);
}
close(FASOUT);
close(FASIN);
die "No sequences in input\n" if ($entries == 0);

my $query_max = 25;
my $seq_files = roundup($entries/$query_max);

my $file = 0;
open(INPSEQ, "<input_seqs") or die "Cannot open file input_seqs: $!, $?\n";
while ($file < $seq_files) {
    open(OUTSEQ, ">sequences_$file") or die "Cannot open file: sequences_$file: $!, $?\n";
    $entries = 0;
    while (! eof (INPSEQ)) {      
        my %fasta = readFASTA(\*INPSEQ);
        writeFASTA(\%fasta, \*OUTSEQ);
        $entries++;
        last if ($entries == $query_max);
    }
    close(OUTSEQ);
    $file++;
}
close(INPSEQ);



########################################################################################
#
# Blastp
#
########################################################################################

mkdir('blast');
my @jobname = split(/\//, $tempdir);

unless (defined($Getopt::Std::opt_w)) {
    # redefine KILL, INT (CTRL+C) and TERM (DIE) signals to remove jobs submitted to the cluster before program exit
    $SIG{KILL} = \&diefunction;
    $SIG{INT} = \&diefunction;
    $SIG{TERM} = \&diefunction;
}

my $db = 'nr';
$db = $Getopt::Std::opt_d if (defined($Getopt::Std::opt_d));
my $run_dir = cwd();

if ($verbose) {
    unless (defined($Getopt::Std::opt_w)) {
        print LOG "# Submitting Blastp jobs to queing system:\n";
    } else {
        print LOG "# Running Blastp jobs on current node\n";
    }
}

for (my $i = 0; $i < $seq_files; $i++) {
    unless (defined($Getopt::Std::opt_w)) {
        open(PROCS, ">blast/blast_$i.sh") or die "Cannot open file blast/blast_$i.sh: $!\n";
        print PROCS "#!/usr/bin/tcsh\n";
        print PROCS "$blastp -query sequences_$i -task blastp -db $db -outfmt 5 -max_target_seqs 25 -evalue 0.001 -num_threads $threads -out blast/blast_$i.xml\n\n";
        close(PROCS);
        system("chmod 755 blast/blast_$i.sh");
        
        $cmd = "xmsub -l mem=4gb,walltime=14400,nodes=1:ppn=$threads -d $run_dir -de -q cbs -N ${jobname[-1]}_b$i -r y blast/blast_$i.sh";
        
    } else {
        # don't use queueing system in www-mode 
        $cmd = "$blastp -query sequences_$i -task blastp -db $db -outfmt 5 -max_target_seqs 25 -evalue 0.001 -num_threads $threads -out blast/blast_$i.xml";
    }
    print LOG "# $cmd\n"; 
    
    system("$cmd");
    
    &logdie("Queue is not responding, job for blast_$i may not have been submitted $?\n") unless ($? == 0);
    
    print LOG "# ", $i+1, " of $seq_files submitted\n" if ($verbose);
    sleep 2;
}


#
# Wait for jobs to complete
#
unless (defined($Getopt::Std::opt_w)) {
    print LOG "# Waiting for blastp job(s) to finish\n" if ($verbose);
    &wait_for_jobs($jobname[-1]);   
    print LOG "# Returning from wait\n# Returning to main script\n" if ($verbose);

} else {
    print LOG "# Returning to main script\n" if ($verbose);
}

chdir('..') unless (defined($Getopt::Std::opt_T));

exit;



########################################################################################
#
# END OF PROGRAM 
#
########################################################################################

########################################################################################
#
# Subfunctions
#
########################################################################################

sub roundup {
    my $n = shift;
    return(($n == int($n)) ? $n : int($n + 1))
}

sub wait_for_jobs {
    my ($basename) = @_;
    
    my ($flag, $wait, $wait_no, $max_wait) = (0, 60, 0, 120); # 120 = 2 hours wait from submission to completion
    
    while ($flag == 0 and $wait_no <= $max_wait) {
        sleep $wait;
        my @jobid;
        open(JOBS, "showq --xml |") or die "Cannot execute \'showq --xml\'\n";
        while (defined(my $line = <JOBS>)) {
            # foreach xml line
            push(@jobid, $line =~ m/JobName=\"(${basename}_[A-Za-z0-9]+)\"/g);
        }
        close(JOBS);
        
        $flag = 1 if (scalar(@jobid) == 0);
        $wait_no++;
        print LOG '# ', scalar(@jobid), " job(s) remaining, refreshing in $wait seconds\n" if ($verbose);
    }
    
    #
    # Remove remaining job(s) if wait time was exceeded
    #
    if ($wait_no > $max_wait) {
        print LOG "Max wait exceeded, presumably there is something wrong. Removing remaining jobs.\n" if ($verbose);
        
        open(JOBS, "showq --xml |") or die "Cannot execute \'showq --xml\'\n";
        while (defined(my $line = <JOBS>)) {
            my @match = ( $line =~ m/JobName=\"(${basename}_[A-Za-z0-9]+)\"/g );
            
            foreach my $job (@match) {
                my $cmd = "canceljob $job";
                `$cmd`;
                print LOG "# Cancelled job: $job\n" if ($verbose);
                
            }
        }
        close(JOBS);
    }
    
    return;
}

sub diefunction {
    
    my $basename = $jobname[-1];
    
    open(JOBS, "showq --xml |") or die "Cannot execute \'showq --xml\'\n";
    while (defined(my $line = <JOBS>)) {
        my @match = ( $line =~ m/JobName=\"(${basename}_[A-Za-z0-9]+)\"/g );
        
        foreach my $job (@match) {
            my $cmd = "canceljob $job";
            `$cmd`;
        }
    }
    die "$0 was interrupted from the command line. Jobs on the cluster were deleted before exit.\n";
    
    return;
}


sub logdie {
    
    my ($log_base) = shift;
    
    print LOG "$log_base";
    die;
    
}
