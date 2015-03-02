#!/usr/bin/perl

# #!/tools/bin/perl cannot be used here because the DBI module in this installation is not working with the used module syntax

use strict;
use warnings;
#use Data::Dumper;
use FindBin qw($RealBin);
use Cwd 'abs_path';
use DBI;
use JSON;



########################################################################################
#
# PARSE JSON
#
########################################################################################

my $json_inp = do { local $/; <STDIN> };
my $inp_data = decode_json $json_inp;



########################################################################################
#
# Add GO terms to contig->ORF structure
#
########################################################################################

my $db      = 'go_termdb';
my $user    = 'www';
my $passwd  = '';
my $dbc = db_connect () or die ("Connection to database failed.\n");

foreach my $obj (@$inp_data{Contig}) {
    
    foreach my $contig (@$obj) {
        my $total_orfs = $contig->{ORFs_found};
        
        if ($total_orfs > 0) {
            my $contig_name = $contig->{contig};
            
            foreach my $ORF (@{$contig->{ORF}}) {
                my $orf_name = $ORF->{name};
                my $full_name  = $contig_name .'_ORF_' ."${orf_name}";
                
                my $file = "interpro/$full_name.tsv";
                if (-e $file) {
                    my %ORF_goterms;
                    
                    open(IP, "<$file") or die "Cannot open $file: $!\n";
                    while (defined(my $line = <IP>)) {
                        chomp($line);
                        if ($line =~ m/(GO:\d+)/) {
                            my @go_terms = ($line =~ m/(GO:\d+)/g);
                            
                            foreach my $term (@go_terms) {
                                $ORF_goterms{$term}++;
                            }
                        }
                    }
                    close(IP);
                    
                    if (scalar(keys %ORF_goterms) > 0) {
                        my @go_collect;
                        foreach my $term (sort {$ORF_goterms{$b} <=> $ORF_goterms{$a}} keys(%ORF_goterms)) {
                            
                            my $go_term = &GO_lookup($term);
                            $$go_term{top_parent} = &find_parent($term);
                            push(@go_collect, $go_term);
                            #if (exists $go{$term} and defined $go{$term}{name} and defined $go{$term}{namespace}) {
                            #    $mouse_over .= "$term\t$go{$term}{name}\t$go{$term}{namespace}\n";
                                
                            #} else {
                                #print STDERR Dumper($go{$term});
                                #die;
                            #}
                        }
                        
                        $$ORF{GO} = \@go_collect;
                        
                    } else {
                        
                    }
                }
            }
        }
    }
}



my $json_encoded = encode_json \%$inp_data;
print STDOUT "$json_encoded\n";

exit;



########################################################################################
#
# SUBFUNCTIONS
#
########################################################################################

sub GO_lookup {
    my ($GO_term) = @_;
    
    my $cmd = "SELECT * FROM term WHERE acc='$GO_term';";
    my $fetch = $dbc->prepare ("$cmd");
    $fetch->execute ();
    
    my %lookup;
    while (my $select = $fetch->fetchrow_hashref ()) {
        %lookup = (GOterm => $$select{acc}, name => $$select{name});
    }
    
    return \%lookup;
}

sub find_parent {
    my ($GO_term) = @_;
    
    my $cmd = "SELECT DISTINCT descendant.acc, descendant.name, descendant.term_type FROM term as termTWO INNER JOIN graph_path as graph_pathTWO ON (termTWO.id=graph_pathTWO.term1_id) INNER JOIN term AS descendant ON (descendant.id=graph_pathTWO.term2_id) WHERE (termTWO.acc='GO:0003674' OR termTWO.acc='GO:0005575' OR termTWO.acc='GO:0008150')  AND distance = 1 AND descendant.id = ANY (SELECT DISTINCT graph_path.term1_id FROM term INNER JOIN graph_path ON (term.id=graph_path.term2_id) WHERE term.acc='$GO_term');";
    my $fetch = $dbc->prepare ("$cmd");
    $fetch->execute ();
    
    my @parents;
    while (my $select = $fetch->fetchrow_hashref ()) {
        my %mysql_go = (GOterm => $$select{acc}, name => $$select{name}, type => $$select{term_type});
        push(@parents, \%mysql_go);
    }
    
    return \@parents;
}

sub db_connect {
    my $dbc = DBI->connect ("DBI:mysql:database=$db;host=mysql;user=$user;password=$passwd;", RaiseError => 1) or die ("Could not connect to database: " . DBI->errstr);
    $dbc->{RaiseError} = 1;

    return ($dbc);
}
