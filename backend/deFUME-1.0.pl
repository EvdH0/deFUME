#!/tools/bin/perl

=head1 NAME

defume.pl

=head1 SYNOPSIS

deFUME.pl -h

=head1 DESCRIPTION

Main program for the deFUME sequence analysis suite

=head1 OPTIONS

  -i  : Input filename [STDIN]
  
  -l  : Logfile if -v is defined [STDERR]
  
  -v  : Verbose [OFF]
  
  -k  : Keep results directory [ON]
  
  -h  : Print this help information
  
=head1 NOTES

This tools is currently being tested. Please consult one of the authors for advice or questions on usage.

=head1 AUTHORS

Henrik Marcus Geertz-Hansen <hmgh@cbs.dtu.dk>
Eric van der Helm <evand@biosustain.dtu.dk>
Hans Genee <hjg@biosustain.dtu.dk>

=head1 LICENSE

Copyright (C) 2015, CBS @ DTU, Denmark

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

use strict;
#use warnings;
use Getopt::Std;
use FindBin qw($RealBin);
use File::Temp qw(tempdir tempfile);
use Cwd;
use File::Spec;
use lib "$RealBin/lib";
use Portal::Page;


########################################################################################
#
# PROCESS COMMAND LINE
#
########################################################################################

my $command_line_input = join(' ', @ARGV);

getopts('hTs:g:m:i:o:d:t:a:p:b:u:f:r:Q:l:vkwj:')||Usage();
#
# Usage
#
if (defined($Getopt::Std::opt_h)||defined($Getopt::Std::opt_h)){
  # Print help message
  Usage();
}

# print help information
sub Usage {
    print "\n  Description: deFUME program suite\n\n";
    print "  Usage: $0 -h -i <filename> -o <filename> -u <email> -l <filename> -p -v -k\n";
    print "  Options:\n";
    print "  -s : Directory containing .ab1 files [current dir]\n";
    print "  -g : Gzipped file of .ab1 files\n";
    print "  -m : Fasta file containing vector sequences to be masked out (only for assembly) [none]\n";
    print "  -i : Directory containing only nucleotide FASTA files (use only when not assemblying) [current dir]\n";
    print "  -o : JSON formatted output filename [results.json]\n";
    print "  -f : Forward primer pattern (separate multiple entries by comma e.g. \'_OGEN41_,_F_\')\n";
    print "  -r : Reverse primer pattern (separate multiple entries by comma e.g. \'_OGEN44_,_R_\')\n";
    print "  -Q : Phred error probability for base calling [0.01]\n";
    print "  -d : Blastp database [[nr]/sp/up]\n";
    print "  -t : Threads for Blastp (use up to 16 on protein-s0 or up to 4 on cge-s2) [4]\n";
    print "  -a : Blastp hit E-value cutoff [0.001]\n";
    print "  -p : Blastp HSP minimum percent sequence id [30]\n";
    print "  -b : Blastp maximum hits to report (pr. ORF) [25]\n";
    print "  -u : User email for InterPro SOAP services [none]\n";
    #print "  -c : Filename of list of custom colony data to be added to JSON file [none]\n";
    print "  -l : Logfile if -v is defined [STDERR]\n";
    print "  -v : Verbose [OFF]\n";
    print "  -k : Keep temporary directory [ON/[OFF]]\n";
    print "  -w : Www-mode (also specify -j)\n";
    print "  -j : Use www-accessible output directory (must be used with -w)\n";
    print "  -T : Flag for test data (paper submission requirement)\n";
    print "  -h : Print this help information\n";
    print "\n\n";
    exit;                              
}

my $threads = 4;
$threads = $Getopt::Std::opt_t if (defined($Getopt::Std::opt_t));
$threads = 2 if (defined($Getopt::Std::opt_w));

unless ($node eq 'service0') {
    die "Not enough threads available on your current node: $node. Please adjust opt -p" unless ($threads <= 4);
}



########################################################################################
#
# LOGFILE
#
########################################################################################

*STDERR = *STDOUT;
my $fh_log;
if (defined($Getopt::Std::opt_l)) {
    open($fh_log, '>', "$Getopt::Std::opt_l") or die "Cannot open $Getopt::Std::opt_l: $!\n";
    warn "$Getopt::Std::opt_l defined but verbose mode not turned ON!\n" unless (defined($Getopt::Std::opt_v));
} else {
    $fh_log = *STDERR;
}
# Verbose mode (no logs written unless defined)
my $verbose = 0;
$verbose = 1 if (defined($Getopt::Std::opt_v));



########################################################################################
#
# INTERPRO SOAP SERVICE
#
########################################################################################

my $user_email;
if (defined($Getopt::Std::opt_u)) {
    if ($Getopt::Std::opt_u =~ m/\@/) {
        $user_email = $Getopt::Std::opt_u;
    } else {
        #$user_email = '';
        #&logdie("Unvalid email address provided. Check your opt -u\n", $fh_log);
    }
} else {
    $user_email = 'dummy_email';
}



########################################################################################
#
# TEMPORARY DIRECTORY
#
########################################################################################

my $tempdir;
my $output_dir;
if (defined($Getopt::Std::opt_w)) {
    # script is running in www-version
    print $fh_log "# $0 is running in www-mode\n" if ($verbose);
    
    if (defined($Getopt::Std::opt_j)) {
        $tempdir = tempdir("$Getopt::Std::opt_j-XXXX",  DIR => "$ENV{TMPDIR}" ,  CLEANUP => ($Getopt::Std::opt_k ? undef : 1) );
        #$ENV{TMPDIR} is under /usr/opt/www/webface/tmp/server/deFUME/
        
        system("chmod -R 755 $tempdir");
        
        print $fh_log "Making www output directory\n" if ($verbose);
        $output_dir = "/usr/opt/www/pub/CBS/services/deFUME/tmp/$Getopt::Std::opt_j/"; # for linked files for output
        
        system("mkdir $output_dir");
        &logdie("Could not make directory $output_dir: $?, $!\n", $fh_log) unless ($? == 0);
        
        system("chmod 777 $output_dir");
        &logdie("Could not change permissions on $output_dir to 777: $?, $!\n", $fh_log) unless ($? == 0);
        
    } else {
        $tempdir = tempdir("defume-XXXXX",  DIR => "./" ,  CLEANUP => ($Getopt::Std::opt_k ? undef : 1) );
        system("chmod -R 755 $tempdir");
        $output_dir = './';
    }
    #print STDOUT "outdir $output_dir\n";
} else {
    
    $tempdir = tempdir("defume-XXXXX",  DIR => "./" ,  CLEANUP => ($Getopt::Std::opt_k ? undef : 1) );
    $output_dir = './';
}
print $fh_log "# Using temporary dir: $tempdir and output dir: $output_dir\n" if ($verbose);

$output_dir = File::Spec->rel2abs($output_dir);



########################################################################################
#
# INPUT
#
########################################################################################

my $input_dir;

if (defined($Getopt::Std::opt_T)) {
    # run webserver test case
    my $cmd = "tar -zxf $RealBin/test/test.tar.gz -C $tempdir";
    system("$cmd");
    &logdie("Decompression of test data: $RealBin/test/test.tar.gz to $tempdir failed, $!, $?\n", $fh_log) unless ($? == 0);
    
    $Getopt::Std::opt_m = "$RealBin/test/vector.fa";
    $Getopt::Std::opt_f = 'FORWARD_';
    $Getopt::Std::opt_r = 'REVERSE_';
    
    $input_dir = File::Spec->rel2abs($tempdir);
    $input_dir =~ s/\/$//;
    
} elsif (defined($Getopt::Std::opt_i)){
    my $input_file = File::Spec->rel2abs($Getopt::Std::opt_i); # convert possible relative path to absolute
    mkdir("$tempdir/fasta");
    system("cp $Getopt::Std::opt_i $tempdir/fasta/input.fasta");
    $input_dir = File::Spec->rel2abs("$tempdir/fasta");

} elsif (defined($Getopt::Std::opt_s)) {
    $input_dir = File::Spec->rel2abs($Getopt::Std::opt_s); # convert possible relative path to absolute
    $input_dir =~ s/\/$//;

} elsif (defined($Getopt::Std::opt_g)) {
    print $fh_log "# Decompressing gzipped file $Getopt::Std::opt_g\n" if ($verbose);
    
    my $cmd = "tar -zxf $Getopt::Std::opt_g -C $tempdir >& /dev/null";
    system("$cmd");
    unless ($? == 0) {
        my $zip_cmd = "unzip -qq -j $Getopt::Std::opt_g -d $tempdir";
        #&logdie("Command $cmd did not execute succesfully, trying $zip_cmd\n", $fh_log);
        system("$zip_cmd");
    }
    unless ($? == 0) {
        print STDOUT ("Could not decompress your input. Exiting.\n", $fh_log);
        &logdie("Could not decompress your input. Exiting.\n", $fh_log);
    }
    
    $input_dir = File::Spec->rel2abs($tempdir);
    $input_dir =~ s/\/$//;
}



########################################################################################
#
# ASSEMBLY
#
########################################################################################

my $vector_path;
if (defined($Getopt::Std::opt_m)) {
    $vector_path = File::Spec->rel2abs($Getopt::Std::opt_m);
    print $fh_log "# Vector sequence: $vector_path\n" if ($verbose);
} else {
    print $fh_log "# No vector sequence defined\n" if ($verbose);
}

chdir("$tempdir"); # changing to tempdir for calculations
print $fh_log "\n# Starting read assembly\n" if ($verbose);

unless (defined($Getopt::Std::opt_i)) {
    unless (defined($Getopt::Std::opt_T) or defined($Getopt::Std::opt_g)) {
        # chromatograms are being unzipped directly to tempdir
        system("cp ../*.ab1 .");
        &logdie("Could not move ab1 files from $input_dir to $tempdir\n", $fh_log) unless ($? == 0);
    }
    
    my $primer_flag = 0;
    if ((defined($Getopt::Std::opt_f) and not defined($Getopt::Std::opt_r)) or (defined($Getopt::Std::opt_r) and not defined($Getopt::Std::opt_f))) {
        die "Both forward and reverse primer patterns must be specified\n";
        
    } elsif (defined($Getopt::Std::opt_f)) {
        $primer_flag = 1;
        print $fh_log "User input primer patterns:\nForward: $Getopt::Std::opt_f\nReverse: $Getopt::Std::opt_r\n" if ($verbose);
    }
    
    my $cmd;
    my $error_rate = 0.01;
    $error_rate = $Getopt::Std::opt_Q if (defined($Getopt::Std::opt_Q));
    if ($primer_flag) {
        $cmd = "$RealBin/src/ab12assembly.pl -i $tempdir -a 25 -q $error_rate -f $Getopt::Std::opt_f -r $Getopt::Std::opt_r -v -l assembly.log >& /dev/null";
        $cmd = "$RealBin/src/ab12assembly.pl -i $tempdir -s $vector_path -a 25 -q $error_rate -f $Getopt::Std::opt_f -r $Getopt::Std::opt_r -v -l assembly.log >& /dev/null" if (defined($Getopt::Std::opt_m));
        
    } else {    
        $cmd = "$RealBin/src/ab12assembly.pl -i $tempdir -a 25 -q $error_rate -v -l assembly.log >& /dev/null";
        $cmd = "$RealBin/src/ab12assembly.pl -i $tempdir -s $vector_path -a 25 -q $error_rate -v -l assembly.log >& /dev/null" if (defined($Getopt::Std::opt_m));
        
    }
    
    system("$cmd");
    &logdie("$cmd executed unsuccesfully. $0 terminated\n", $fh_log) unless ($? == 0);
    #&logdie("$cmd executed unsuccesfully. Assembly report empty, \n", $fh_log) unless (-z 'assembly_report.txt');
    
    mkdir('fasta');
    chdir('fasta');
    system('ln -fs ../seqs_fasta.screen.contigs .');
    system('ln -fs ../seqs_fasta.screen.singlets .');
    chdir('..');
    $input_dir = File::Spec->rel2abs('fasta');
    #print $fh_log "# $input_dir\n";
}

print $fh_log "# Done\n" if ($verbose);



########################################################################################
#
# CREATE JSON FROM ASSEMBLY FILES
#
########################################################################################

print $fh_log "\n# Creating JSON file\n" if ($verbose);

$cmd = "$RealBin/src/defume_makeJSON.pl -i $input_dir > metaP1.json";
system("$cmd");
&logdie("$cmd executed unsuccesfully. $0 terminated\n", $fh_log) unless ($? == 0);

print $fh_log "# Done\n" if ($verbose);



########################################################################################
#
# PREDICT GENES AND ADD TO JSON
#
########################################################################################

print $fh_log "\n# Predicting ORFs and adding to JSON\n" if ($verbose);

$cmd = "$RealBin/src/defume_predictgenes.pl -i $input_dir -o $input_dir/translated_genes.fasta < metaP1.json > metaP2.json";
system("$cmd");
&logdie("$cmd executed unsuccesfully. $0 terminated\n", $fh_log) unless ($? == 0);

print $fh_log "# Done\n" if ($verbose);



########################################################################################
#
# BLASTp on translated predicted genes
#
########################################################################################

print $fh_log "\n# Starting BLASTp\n" if ($verbose);

my $db = 'nr'; # define search database 
if (defined($Getopt::Std::opt_d)) {
    if ($Getopt::Std::opt_d =~ m/nr|sp|up/i) {
        $db = $Getopt::Std::opt_d;
        #system("echo $db > searchdb.txt\n");
    } else {
        &logdie("Blastp database specification not valid. Only 'nr/sp/up' is currently allowed. Please check your opt -d\n", $fh_log);
    }
}

$cmd = "$RealBin/src/defume_blastp.pl -T $tempdir -t $threads -d $db -i $input_dir/translated_genes.fasta -v -l blastp.log";
# www-mode
$cmd = "$RealBin/src/defume_blastp.pl -T $tempdir -t $threads -d $db -i $input_dir/translated_genes.fasta -v -l blastp.log -w" if (defined($Getopt::Std::opt_w));

system("$cmd");
&logdie("$cmd executed unsuccesfully. $0 terminated\n", $fh_log) unless ($? == 0);

print $fh_log "# Done\n" if ($verbose);



########################################################################################
#
# PARSE BLASTp RESULTS AND RUN INTERPRO
#
########################################################################################

print $fh_log "\n# Parsing BLASTp results\n" if ($verbose);

# default parse parameters
my $user_significance = 0.001;
$user_significance = $Getopt::Std::opt_a if (defined($Getopt::Std::opt_a));

my $user_id = 30;
$user_id = $Getopt::Std::opt_p if (defined($Getopt::Std::opt_p));

my $user_hit_max = 25;
$user_hit_max = $Getopt::Std::opt_b if (defined($Getopt::Std::opt_b));

$cmd = "$RealBin/src/defume_annotate.pl -T $tempdir -u $user_email -a $user_significance -b $user_hit_max -p $user_id -i metaP2.json -o metaP3.json -v -l interpro.log";
system("$cmd");
&logdie("$cmd executed unsuccesfully. $0 terminated\n", $fh_log) unless ($? == 0);

print $fh_log "# Done\n" if ($verbose);



########################################################################################
#
# ADD GO ANNOTATIONS FROM INTERPRO TO JSON
#
########################################################################################

print $fh_log "\n# Adding GO annotations\n" if ($verbose);

$cmd = "perl $RealBin/src/defume_addGO.pl < metaP3.json > metaP4.json";
system("$cmd");
&logdie("$cmd executed unsuccesfully. $0 terminated\n", $fh_log) unless ($? == 0);

print $fh_log "# Done\n" if ($verbose);



########################################################################################
#
# ADD SEQUENCING READ INFORMATION TO JSON
#
########################################################################################

unless (defined($Getopt::Std::opt_i)) {
    print $fh_log "\n# Adding read information\n" if ($verbose);
    
    my $phrap_report = './assembly_report.txt';
    $phrap_report = File::Spec->rel2abs($phrap_report); # convert possible relative path to absolute path
    print $fh_log "# Using $phrap_report to associate reads with contigs\n" if ($verbose);
    
    
    $cmd = "$RealBin/src/defume_addReads.pl $phrap_report < metaP4.json > metaP5.json";
    system("$cmd"); 
    &logdie("$cmd executed unsuccesfully. $0 terminated\n", $fh_log) unless ($? == 0);
    
    print $fh_log "# Done\n" if ($verbose);
} else {
    $cmd = "$RealBin/src/defume_addDNA.pl ./fasta/input.fasta < metaP4.json > metaP5.json";
    system("$cmd");
    &logdie("$cmd executed unsuccesfully. $0 terminated\n", $fh_log) unless ($? == 0);
    #system("cp metaP4.json metaP5.json");
    print $fh_log "# Reads not added to output json as input was already assembled\n" if ($verbose);
}



########################################################################################
#
# COPY FINAL JSON AND INTERPRO GRAPHICS TO USER SPECIFIED DESTINATION
#
########################################################################################

print $fh_log "\n# Copying output to final destination\n" if ($verbose);

my $output = "results.json";
$output = $Getopt::Std::opt_o if (defined($Getopt::Std::opt_o));
system("cp metaP5.json $output_dir/$output");
&logdie("Copying of results file $output to destination: $output_dir failed: $?, $!\n", $fh_log) unless ($? == 0);

$cmd = "ls -1 interpro/*.tar.gz";
my @graphics = `$cmd`;
#&logdie("Could not list files in dir 'interpro': $!, $?\n", $fh_log) unless ($? == 0);

if (scalar(@graphics) > 0) {
    
    #unless (-d "$output_dir/interpro") {
        mkdir("$output_dir/interpro");
        &logdie("Could not create new directory $output_dir/interpro: $!, $?\n", $fh_log) unless ($? == 0);
    #}
    
    for (my $i = 0; $i < scalar(@graphics); $i++) {
        chomp($graphics[$i]);
        my $cmd = "tar -xzf $graphics[$i] -C $output_dir/interpro/";
        system("$cmd");
        warn "Command failed: $cmd: $?, $!\n" unless ($? == 0);
        #&logdie("Command failed: $cmd: $?, $!\n", $fh_log) unless ($? == 0);            
    }
    
    my $cmd = "cp -Rf /usr/opt/www/pub/CBS/services/deFUME/interpro/resources $output_dir/interpro/";
    $cmd = "cp -Rf /home/projects2/hmgh/projects/deFUME/interpro/resources interpro/" unless (defined($Getopt::Std::opt_w));
    system("$cmd");
    &logdie("Could not execute $cmd: $!, $?\n", $fh_log) unless ($? == 0);

    
} else {
    &logdie("No interpro output to untar\n", $fh_log);
    # Nothing is copied to the output folder as no InterPro results exist 
}

chdir('..');



########################################################################################
#
# Copy files required for visualization (www only)
#
########################################################################################

if (defined($Getopt::Std::opt_w)) {
    my $output_template = '/usr/opt/www/pub/CBS/services/deFUME/visual/output.html';
    system("cp $output_template $output_dir/output.html");
    print STDERR "Copying of output template $output_template to destination: $output_dir failed: $?, $!\n" unless ($? == 0);

    my $mypath = "$output_dir/$output";
    new Portal::Page()->stream(\*STDOUT)->load("output.html")->render({ results_path => $mypath });
}

exit 0;



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

# human readable json:
# cat results.json | python -mjson.tool | m
