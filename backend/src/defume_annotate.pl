#!/tools/bin/perl

=head1 NAME

metaparser_annotate.pl - Make JSON file containing sequence annotations from Blastx (local) and InterPro (via SOAP) 

=head1 SYNOPSIS

metaparser_annotate.pl -h

=head1 DESCRIPTION

See command line options using -h

=head1 OPTIONS

    -o : JSON formatted output filename [STDOUT]

    -a : Blastx hit E-value cutoff [0.001]

    -p : Blastx HSP minimum percent sequence id [30]

    -b : Blastx maximum hits to report (pr. ORF) [100]

    -u : User email for InterPro SOAP services [none]

    -T : Use specific temporary directory [from metaparser_wrap.pl]

    -l : Logfile if -v is defined [STDERR]

    -v : Verbose [OFF]

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

use strict;
#use warnings;
use Getopt::Std;
use Data::Dumper;
use FindBin qw($RealBin);
use Bio::SearchIO;
use JSON;


########################################################################################
#
# PROCESS COMMAND LINE
#
########################################################################################

my $command_line_input = join(' ', @ARGV);

getopts('hi:o:T:a:p:b:u:l:vk')||Usage();
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
    print "  Usage: $0 -h -i <filename> -o <filename> -u <email> -l <filename> -p -v -k\n";
    print "  Options:\n";
    print "  -i : JSON formatted input file containing contigs [STDIN]\n";
    print "  -o : JSON formatted output file [STDOUT]\n";
    print "  -a : Blastp hit E-value cutoff [0.001]\n";
    print "  -p : Blastp HSP minimum percent sequence id [30]\n";
    print "  -b : Blastp maximum hits to report (pr. ORF) [25]\n";
    print "  -u : User email for InterPro SOAP services (no InterPro annotation if not provided) [none]\n";
    print "  -T : Use specific temporary directory [from deFUME.pl]\n";
    print "  -l : Logfile if -v is defined [STDERR]\n";
    print "  -v : Verbose [OFF]\n";
    print "  -h : Print this help information\n";
    print "\n\n";
    exit;                              
}

#
# JSON input
#
if (defined($Getopt::Std::opt_i)) {
    open(INP, "<$Getopt::Std::opt_i") or die "Cannot open file $Getopt::Std::opt_i: $!, $?\n";
} else {
    *INP = *STDIN;
}

my $json_inp = do { local $/; <INP> };
my $inp_data = decode_json $json_inp;
close(INP);



#
# Logfile
#
unless (defined($Getopt::Std::opt_l)) {
    *LOG=*STDERR;
} else {
    open(LOG, ">>$Getopt::Std::opt_l") or die "Cannot open $Getopt::Std::opt_l: $!\n";
    # print warn and die to same log file
    #open(STDERR, ">>$Getopt::Std::opt_l");
    unless (defined($Getopt::Std::opt_v)) {
        warn "$Getopt::Std::opt_l defined but verbose mode not turned ON!\n";
    }
}
# Verbose mode (no logs written unless defined)
my $verbose = 0;
$verbose = 1 if (defined($Getopt::Std::opt_v));

#print LOG "# Commandline: $0 $command_line_input\n" if ($verbose);


#
# InterPro SOAP service setup
#
my $user_email = '';
if (defined($Getopt::Std::opt_u)) {
    if ($Getopt::Std::opt_u =~ m/\@/) {
        $user_email = $Getopt::Std::opt_u;
    } else {
        #die "Unvalid email address provided. Check your opt -u\n";
    }
} else {
    print LOG "No user email provided for SOAP services. Use opt -u or no InterPro annotations will be included\n";
}


#
# Blastp parse parameters
#
my $user_significance = 0.001;
$user_significance = $Getopt::Std::opt_a if (defined($Getopt::Std::opt_a));

my $user_id = 30;
$user_id = $Getopt::Std::opt_p if (defined($Getopt::Std::opt_p));

my $user_hit_max = 25;
$user_hit_max = $Getopt::Std::opt_b if (defined($Getopt::Std::opt_b));


# tempdir
my $tempdir;
if (defined($Getopt::Std::opt_T)) {
    $tempdir = $Getopt::Std::opt_T;
    chdir("$tempdir");
    die "Could not change dir to $tempdir\n" unless ($? == 0);
    
} else {
    #die "Please specifiy the temporary directory of the metaparse_wrap.pl run\n";
}



########################################################################################
#
# PARSE BLASTP RESULTS
#
########################################################################################


my @seq_files = `ls -1 sequences_*`;
die "Could not list sequence files in $tempdir\n" unless ($? == 0);

my %data;
for (my $i = 0; $i < scalar(@seq_files); $i++) {
    print LOG "# Parsing Blastp xml-file ", $i+1, " of ", scalar(@seq_files), "\n" if ($verbose);
    if (-f "blast/blast_$i.xml") {
	my $in = Bio::SearchIO-> new(-format => 'blastxml', -file => "blast/blast_$i.xml") or die "Cannot open file blast/blast_$i.xml: $!\n";
        
        while( my $result = $in->next_result ) {            
            
            (my $query = $result->query_description) =~ s/\s+.+$//; # get ORF from name of query
            my $user_hit = 0;
            
            while (my $hit = $result->next_hit) {
                
                if ($hit->significance < $user_significance) {
                    my $hsp = $hit->next_hsp;
                    
                    if ($hsp->percent_identity >= $user_id) {
                        
                        if ($user_hit < $user_hit_max) {
                            
                            my @tmp_desc = split(/ \>/, $hit->description);
                            (my $tmp_seq = $hsp->query_string) =~ s/-//g;
                            #my $tmp_frame = ($hsp->query->frame + 1) * $hsp->query->strand; # frame (0, 1, 2) does not contain information about strand (1 or -1)
                            my %hsp_tmp = ('h_id' => $hit->name, 'eval' => $hit->significance*1, 'bit' => $hit->bits*1, 'h_acc' => $hit->accession,
                                           'h_desc' => $tmp_desc[0], 'h_length' => $hit->length*1, 'perc' => sprintf("%.1f", $hsp->percent_identity)*1,
                                           'q_start' => $hsp->start('query')*1, 'q_end' => $hsp->end('query')*1, 'q_seq' => $tmp_seq); 
                                            
                            
                            push(@{$data{$query}}, \%hsp_tmp);
                            $user_hit++;
                            
                        } else {
                            last;
                        }
                    }
                    
                }
                
            }
            
	}
    } else {
	print LOG "# BLAST output $tempdir/blast/blast_$i.xml does not exist\n" if ($verbose);
        #die;
    }
    #last; # for debugging
}
print LOG "# Blast parsing completed\n" if ($verbose);
print LOG "# Writing sequences of query ORFs with Blastx hit for InterPro search\n" if ($verbose);

my @query_seq_ids;
foreach my $obj (@$inp_data{Contig}) {
    
    foreach my $contig (@$obj) {
        my $total_orfs = $contig->{ORFs_found};
        
        if ($total_orfs > 0) {
            my $contig_name = $contig->{contig};
            
            foreach my $ORF (@{$contig->{ORF}}) {
                my $orf_name = $ORF->{name};
                my $full_name  = $contig_name .'_ORF_' ."${orf_name}";
                push(@query_seq_ids, $full_name); # make array of all ORF names
                
                if (exists $data{$full_name}) {
                    $$ORF{BLAST} = \@{$data{$full_name}};
                    $$ORF{hasBLAST} = 'True';
                }
            }
        }
    }
}



########################################################################################
#
# INTERPRO
#
########################################################################################

### Consider using RunIprScan instead http://michaelrthon.com/runiprscan/
### This handles gene ontologies as well as resubmission to EBI if job fails

if ($user_email =~ m/\@/) {
    print LOG "# Initiating InterPro search\n" if ($verbose);
    
    mkdir('interpro');
    chdir('interpro');
    #=pod
    # use SOAP services
    my $file_count = scalar(@seq_files);
    my %jobctl;
    for (my $i = 0; $i < scalar(@seq_files); $i++) {
        my $cmd = "perl $RealBin/iprscan5_soaplite.pl --async --email $user_email --goterms --pathways --multifasta ../sequences_$i 2>> /dev/null";
        
        my @SOAP_reply = `$cmd`;
        my @jobid;
        foreach my $n (0 .. $#SOAP_reply) {
            my $reply = $SOAP_reply[$n];
            chomp($reply);
            my $seqid = shift(@query_seq_ids);
            
            if ($reply =~ m/^iprscan5-/) {
                push(@jobid, $reply);
                $jobctl{$reply} = $seqid;
            }
        }
        
        print LOG "# Waiting 30 seconds for InterPro. Sequence file ", $i+1, " of ", $file_count + 1, "\n" if ($verbose);
        # locate all jobids and make copy of array
        my $jobid_copy = \@jobid;
        
        #print STDOUT Dumper(@jobid);
        my $wait;
        while (scalar(@$jobid_copy) > 0) {
            sleep 30;
            for (my $job = scalar(@$jobid_copy) - 1; $job >= 0; $job--) {
                my $cmd = "perl $RealBin/iprscan5_soaplite.pl --status --jobid $$jobid_copy[$job] 2>> /dev/null";
                my $status = `$cmd`;
                chomp($status);
                if ($status eq 'FINISHED') {
                    my $cmd = "perl $RealBin/iprscan5_soaplite.pl --resultTypes --jobid $$jobid_copy[$job] 2>> /dev/null";
                    my @possible_outs = `$cmd`;
                    
                    #my $outformat = 'xml';
                    #my $ipr_name = "$$jobid_copy[$job].xml.xml";
                    foreach my $output (@possible_outs) {
                        if ($output =~ m/^tsv|^htmltarball/i) {
                            my ($outformat, $base_name, $full_name, $short_name) = ('tsv', "$jobctl{$$jobid_copy[$job]}", "$jobctl{$$jobid_copy[$job]}.tsv.txt", "$jobctl{$$jobid_copy[$job]}.tsv");
                            ($outformat, $base_name, $full_name, $short_name) = ('htmltarball', "$jobctl{$$jobid_copy[$job]}", "$jobctl{$$jobid_copy[$job]}.htmltarball.html.tar.gz", "$jobctl{$$jobid_copy[$job]}.html.tar.gz") if ($output =~ m/^htmltarball/);
                            $cmd = "perl $RealBin/iprscan5_soaplite.pl --polljob --outformat $outformat --outfile $base_name --jobid $$jobid_copy[$job] 2>> /dev/null";
                            `$cmd`;
                            
                            system("mv $full_name $short_name");
                            
                            print LOG "# Error executing \"$cmd\". Output: $short_name does not exist\n" unless (-e $short_name);
                            die "check log\n" unless (-e $short_name);
                            
                        }
                    }
                    
                    # remove completed job
                    splice(@$jobid_copy, $job, 1);
                    
                } elsif ($status eq 'FAILURE') {
                    # remove failed job
                    
                    # NOTE: consider adding resubmission instead of removal 
                    
                    splice(@$jobid_copy, $job, 1);
                    print LOG "InterPro job $job failed for unknown reasons. Moving on\n" if ($verbose);
                } else {
                    # wait
                }
            }
            print LOG '# ', scalar(@$jobid_copy), " job(s) remaining for sequence file ", $i+1, " of ", $file_count + 1, ", refreshing in 30 seconds\n" if ($verbose);
            
            $wait++;
            if ($wait > 10) {
                if ($verbose) {
                    print LOG "# Have been waiting for 10 min and one or more jobs are still not done or failed. Use:\n\n";
                    
                    foreach my $job (@$jobid_copy) {
                        print LOG "perl $RealBin/iprscan5_soaplite.pl --status --jobid $job\n";
                    }
                    
                    print LOG "\nto check their status. Not sure what to do about it. Moving on to next sequence file\n";
                }
                
                @$jobid_copy = ();
                # add function to resubmit individual jobs if the first submission fails
            }
        
        }
        print LOG "# InterPro annotation for ", $i+1, " of ", $file_count + 1, " sequence files completed\n" if ($verbose);
    }
    #=cut
    
    
    
    print LOG "# Parsing InterPro results\n" if ($verbose);
    foreach my $obj (@$inp_data{Contig}) {
        
        foreach my $contig (@$obj) {
            my $total_orfs = $contig->{ORFs_found};
            
            if ($total_orfs > 0) {
                my $contig_name = $contig->{contig};
                
                foreach my $ORF (@{$contig->{ORF}}) {
                    my $orf_name = $ORF->{name};
                    my $full_name  = $contig_name .'_ORF_' ."${orf_name}";
                    
                    if (-e "$full_name.tsv") {
                        #print STDERR "FOUND $full_name.tsv\n";
                        my @interpro;
                        open(IP, "<$full_name.tsv") or die "Cannot open file $full_name.tsv: $!\n";
                        while (defined(my $line = <IP>)) {
                            chomp($line);
                            my @data = split(/\t/, $line);
                            
                            my %tmp = ('db' => $data[3], 'desc' => $data[4], 'start' => $data[6]*1, 'end' => $data[7]*1); 
                            push(@interpro, \%tmp);
                        }
                        close(IP);
                        
                        if (scalar(@interpro) > 0) {
                            $$ORF{InterPro} = \@interpro;
                            $$ORF{hasInterPro} = 'True';
                            
                        }
                        
                    } else {
                        $$ORF{hasInterPro} = 'NA'; # indicates that Interpro search failed
                    }
                    
                }
            }
        }
    }

    chdir('..') if (defined($Getopt::Std::opt_T)); # back in temp dir

} else {
    print LOG "Skipping InterPro annotation as not email address was provided\n";
}


########################################################################################
#
# Print results as JSON and exit
#
########################################################################################

my $json_encoded = encode_json \%$inp_data;

if (defined($Getopt::Std::opt_o)) {
    open(OUT,">$Getopt::Std::opt_o");
} else {
    *OUT = *STDOUT;
}
print OUT "$json_encoded\n";
close(OUT);

# human readable:
# cat metaP1.json | python -mjson.tool | m

close (LOG) if (defined($Getopt::Std::opt_l));

exit;