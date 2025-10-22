#!/usr/bin/env perl -w
# (Copyright) Jiaqi Wu
use diagnostics;
use 5.010;
use strict;
use Cwd;
use Getopt::Std;
use File::Copy;
use List::Util qw(shuffle); 
use File::Copy;

my %opts;
getopts('i:j:t:s:k:o:', \%opts);
my $input_vcf_file = $opts{'i'} or die "use: $0 -i input_vcf_file -j input_indv_to_pop_file -t input_sample_number_info -s sample_number -k admixture_k -o output_folder\n";
my $input_indv_to_pop_file = $opts{'j'} or die "use: $0 use: $0 -i input_vcf_file -j input_indv_to_pop_file -t input_sample_number_info -s sample_number -k admixture_k -o output_folder\n";
my $input_sample_number_info = $opts{'t'} or die "use: $0 use: $0 -i input_vcf_file -j input_indv_to_pop_file -t input_sample_number_info -s sample_number -k admixture_k -o output_folder\n";
my $sample_number = $opts{'s'} or die "use: $0 use: $0 -i input_vcf_file -j input_indv_to_pop_file -t input_sample_number_info -s sample_number -k admixture_k -o output_folder\n";
my $admixture_k = $opts{'k'} or die "use: $0 use: $0 -i input_vcf_file -j input_indv_to_pop_file -t input_sample_number_info -s sample_number -k admixture_k\n -o output_folder";
my $output_folder = $opts{'o'} or die "use: $0 use: $0 -i input_vcf_file -j input_indv_to_pop_file -t input_sample_number_info -s sample_number -k admixture_k -o output_folder\n";


#my %ind2pop;
my %pop2ind;
##ind2pop file, first line, individual name; second line, population name.
open IND, $input_indv_to_pop_file or die $!;
while (<IND>){
	chomp;
	my @line = split (/\t/, $_);
	#$ind2pop{$line[0]} = $line[1];
	if (exists $pop2ind{$line[1]}){
		$pop2ind{$line[1]} .= "\n$line[0]";
	} else {
		$pop2ind{$line[1]} = $line[0];
	}
}
close IND;

my %pop_sample_info;
open SAM, $input_sample_number_info or die $!;
while (<SAM>){
	chomp;
	my @line = split (/\t/, $_);
	$pop_sample_info{$line[0]} = $line[1];
}
close SAM;

if (!(-e "./${output_folder}_samples_$admixture_k")){
	mkdir "./${output_folder}_samples_$admixture_k" or die $!;
} else {
	system "rm ./${output_folder}_samples_$admixture_k/*.txt";
}

if (!(-e "./${output_folder}_${admixture_k}")){
	mkdir "./${output_folder}_${admixture_k}" or die $!;
} else {
	system "rm ${output_folder}_${admixture_k}/*.P";
	system "rm ${output_folder}_${admixture_k}/*.Q";
	system "rm ${output_folder}_${admixture_k}/*.out";
}

my $options;
open OPT, ">$output_folder.options.txt" or die $!;
foreach my $i (1..$sample_number){
	my %new_sample;
	foreach my $pop (sort keys %pop2ind){
		if (exists $pop_sample_info{$pop}){
			my @inds = split (/\n/, $pop2ind{$pop});
			my @new_inds = shuffle(@inds);
			if ($pop_sample_info{$pop} <= (scalar (@new_inds))){
				foreach my $j (0..($pop_sample_info{$pop}-1)){
					$new_sample{$new_inds[$j]} = "";
				}
			} else {
				foreach my $j (0..$#inds){
					$new_sample{$inds[$j]} = "";
				}
			}
			
		} else{
			my @inds = split (/\n/, $pop2ind{$pop});
			foreach my $j (0..$#inds){
					$new_sample{$inds[$j]} = "";
			}
		}
	}

	open OUT, ">${output_folder}_samples_$admixture_k/sample.$i.txt";
	foreach my $j (sort keys %new_sample){
		print OUT "$j\n";
	}
	close OUT;

	$options = "vcftools --gzvcf $input_vcf_file --keep ${output_folder}_samples_$admixture_k/sample.$i.txt --plink --out temp";
	print "$options\n";
	print OPT "$options\n";
	system $options;

	$options = "plink1.9 --file temp --make-bed --out temp --chr-set 28";
	print "$options\n";
	print OPT "$options\n";
	system $options;

	$options = "./admixture --cv temp.bed $admixture_k | tee log$admixture_k.out";
	print "$options\n";
	print OPT "$options\n";
	system $options;

	$options = "mv log$admixture_k.out ${output_folder}_${admixture_k}/sample_$i.log$admixture_k.out";
	print "$options\n";
	print OPT "$options\n";
	system $options;

	$options = "mv temp.$admixture_k.P ${output_folder}_${admixture_k}/sample_$i.$admixture_k.P";
	print "$options\n";
	print OPT "$options\n";
	system $options;

	$options = "mv temp.$admixture_k.Q ${output_folder}_${admixture_k}/sample_$i.$admixture_k.Q";
	print "$options\n";
	print OPT "$options\n";
	system $options;

	$options = "rm temp.*";
	print "$options\n";
	print OPT "$options\n";
	system $options;

	print "\n";
	print OPT "\n";
}
close OPT;
#@array = shuffle(@array);
