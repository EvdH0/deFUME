#!/usr/bin/perl

use strict;
#use warnings;
#use Data::Dumper;
use JSON;

########################################################################################
#
# PROCESS COMMAND LINE AND INITIATE JSON
#
########################################################################################

my $assembly_report = shift(@ARGV);
die "Cannot find assemly report" unless (-e $assembly_report);

my $custom_data = shift(@ARGV);
die "Cannot find file with user data" unless (-e $custom_data);

my $json_inp = do { local $/; <STDIN> };
my $data = decode_json $json_inp;

########################################################################################
#
# Add custom user data to data structure
#
########################################################################################

my %user_data;
my $data_type;
open(USER, "<$custom_data") or die "Cannot open file $custom_data: $!\n";
while (defined(my $line = <USER>)) {
    chomp($line);
    my @data = split(/\s+/, $line);
    if ($data[1] !~ m/^[0-9]+/) {
        my $data_type = $data[1];
        $line = <USER>;
        @data = split(/\s+/, $line);
        #colony data is always first column
    }
    warn "Multiple data entries found for colony $data[0]\n" if (exists $user_data{$data[0]});
    
    $user_data{$data[0]} = $data[1];
}


my %reads;
my %custom_data;
if (-e $assembly_report) {

    open(REPORT, "<$assembly_report") or die "Cannot open file $assembly_report: $!\n";
    while (defined(my $line = <REPORT>)) {
        chomp($line);
        if ($line =~ m/^Contig (\d+)/) {
            my $contig = "seqs_fasta.screen.Contig$1";
            #print $
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
                    
                    my $colony = &colony($read_name);
                    
                    $data_type = 'user_data' unless (defined($data_type));
                    push(@{$custom_data{$contig}{$data_type}}, $user_data{$colony}) if (exists $user_data{$colony});
                    
                    
                    my %tmp_read = ('name' => $read_name, 'start' => $read[1], 'end' => $read[2], 'direction' => $dir);
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


foreach my $obj (@$data{Contig}) {
    foreach my $contig (@$obj) {
        my $contig_name = $contig->{contig};
        $$contig{reads} = \@{$reads{$contig_name}} if (exists $reads{$contig_name});
        if (exists $custom_data{$contig_name}) {
            foreach my $data_type (keys %{$custom_data{$contig_name}}){ 
                $$contig{userdata}{$data_type} = \@{$custom_data{$contig_name}{$data_type}};
            }
        }
    }
}

my $json_encoded = encode_json \%$data;
print STDOUT "$json_encoded\n";

exit;


sub colony {
    (my $inp_read) = @_;

    my $colony;
    
    if ($inp_read =~ m/_(.+)_F_|_(.+)_R_/) {
        $colony = $1;
        
    } elsif ($inp_read =~ m/_EvdH_oGEN4[34]_(.+)_/) {
        $colony = $1;
        
    } elsif ($inp_read =~ m/_GEBO[1-9]{2}_(.+)/) {
        $colony = $1;
        
    } else {
        die "Unknown scheme for colony naming. Please consult one of the authors of the program to improve usability\n";
    }
    
    return $colony;
}