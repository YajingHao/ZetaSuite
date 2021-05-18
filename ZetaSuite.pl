#!/usr/bin/perl
#Copyright Yajing Hao <yahao\@ucsd.edu>
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use File::Basename qw(basename dirname);
use FindBin  qw($Bin $Script);
my $BEGIN_TIME =time();
my $author ="Yajing Hao";


#-------------------------------------------------------
#   Getoptions
#-------------------------------------------------------
my ($fIn,$fOut,$input,$output,$Negative_Control,$Positive_Control,$zscore,$combine,$svm,$non_expressed_genes);
GetOptions(
	     "help|?" =>\&USAGE,
		 "id:s"=>\$fIn,
		 "od:s"=>\$fOut,
		 "in:s"=>\$input,
		 "op:s"=>\$output,
		 "n:s"=>\$Negative_Control,
		 "p:s"=>\$Positive_Control,
		 "ne:s"=>\$non_expressed_genes,
		 "z:s"=>\$zscore,
		 "c:s"=>\$combine,
		 "svm:s"=>\$svm,
    ) or &USAGE;
&USAGE unless ($fIn and $fOut and $input and $output and $Negative_Control and $Positive_Control and $non_expressed_genes);

#######################################################################################
# ------------------------------------------------------------------
# main 
# ------------------------------------------------------------------
#default
$zscore||="yes";
$combine||="no";
$svm||="yes";

#input directory
$fIn=AbsolutePath("dir",$fIn);

#output directory setting
mkdir $fOut if (! -d $fOut);
$fOut=AbsolutePath("dir",$fOut);

#quality control output
my $QC="$fOut/QC";
mkdir $QC if(! -d $QC);
$QC=AbsolutePath("dir",$QC);

# zscore output
my $zscore_result;
if($zscore eq "yes"){
	$zscore_result="$fOut/Zscore";
	mkdir $zscore_result if (! -d $zscore_result);
	$zscore_result=AbsolutePath("dir",$zscore_result);
}

#EventCoverage output
my $EventCoverage="$fOut/EventCoverage";
mkdir $EventCoverage if(! -d $EventCoverage);
$EventCoverage=AbsolutePath("dir",$EventCoverage);

#Zeta output
my $Zeta="$fOut/Zeta";
mkdir $Zeta if(! -d $Zeta);
$Zeta=AbsolutePath("dir",$Zeta);

#FDR cutoff output
my $FDR_cutoff="$fOut/FDR_cutoff";
mkdir $FDR_cutoff if(! -d $FDR_cutoff);
$FDR_cutoff=AbsolutePath("dir",$FDR_cutoff);

#Log file 
my $LOG;
open (Log,">$fOut/LOG.txt") or die;
print Log "perl $0 -id $fIn -od $fOut -in $input  -op $output  -ne $non_expressed_genes  -n $Negative_Control  -p $Negative_Control  -z $zscore -c $combine -svm $svm\n";
print Log "first step:QC......\n";
my $first_step="$Bin/bin/QC.sh -a $fIn -b $QC  -i $input  -o $output  -n $Negative_Control  -p $Positive_Control";
print Log "$first_step\n";
system($first_step);
if($zscore eq "yes"){
	my $second_step="$Bin/bin/Zscore.sh -a $fIn -b $zscore_result  -i $input  -o $output  -n $Negative_Control";
	print Log "second step:Zscore normalization......\n$second_step\n";
	system($second_step);
	if($combine eq "yes"){
		my $third_step="$Bin/bin/EventCoverage_combine.sh -a $zscore_result -b $EventCoverage  -i $output\_Zscore.matrix  -o $output  -n $fIn/$Negative_Control -p $fIn/$Positive_Control";
		system($third_step);
		print Log "third step:EventCoverage_combine......\n$third_step\n";
		if($svm eq "yes"){
			my $fourth_step1="$Bin/bin/SVM.sh -i $EventCoverage  -a $output\_Matrix_EC_Positive_D  -b $output\_Matrix_EC_Negative_D -c $output\_Matrix_EC_Positive_I -d $output\_Matrix_EC_Negative_I -z Zseq_list.txt  -o $output -t $Zeta";
			print Log "fourth step1:SVM calculation......\n$fourth_step1\n";
			system($fourth_step1);
			my $fourth_step2="$Bin/bin/Zeta_SVM.sh -a $Zeta  -i $zscore_result/$output\_Zscore.matrix  -b $Zeta -l $output\_SVM_lineCutOff_D -s $output\_SVM_lineCutOff_I   -o $output -z $EventCoverage/Zseq_list.txt";
			print Log "fourth step2:Zeta calculation......\n$fourth_step2\n";
			system($fourth_step2);
		}else{
			my $fourth_step="$Bin/bin/Zeta.sh -a $zscore_result  -b $Zeta  -i $output\_Zscore.matrix  -o $output -z $EventCoverage/Zseq_list.txt";
			print Log "fourth step:Zeta calculation......\n$fourth_step\n";
			system($fourth_step);
		}
		my $fifth_step="$Bin/bin/FDR_cutoff_combine.sh -a $Zeta -b $FDR_cutoff -i $output\_Zeta.txt -o $output -n $fIn/$non_expressed_genes -p $fIn/$Positive_Control -s $fIn/$Negative_Control";
		print Log "fifth step:FDR cutoff calculation......\n$fifth_step\n";
		system($fifth_step);
	}else{
		my $third_step="$Bin/bin/EventCoverage.sh -a $zscore_result -b $EventCoverage  -i $output\_Zscore.matrix  -o $output  -n $fIn/$Negative_Control -p $fIn/$Positive_Control";
		print Log "third step:EventCoverage.....\n$third_step\n";
		system($third_step);
		if($svm eq "yes"){
			my $fourth_step1="$Bin/bin/SVM.sh -i $EventCoverage  -a $output\_Matrix_EC_Positive_D  -b $output\_Matrix_EC_Negative_D -c $output\_Matrix_EC_Positive_I -d $output\_Matrix_EC_Negative_I -z Zseq_list.txt  -o $output -t $Zeta";
			print Log "fourth step1:SVM calculation......\n$fourth_step1\n";
			system($fourth_step1);
			my $fourth_step2="$Bin/bin/Zeta_SVM.sh -a $Zeta  -i $zscore_result/$output\_Zscore.matrix  -b $Zeta -l $output\_SVM_lineCutOff_D -s $output\_SVM_lineCutOff_I  -o $output -z $EventCoverage/Zseq_list.txt";
			print Log "fourth step2:Zeta calculation......\n$fourth_step2\n";
			system($fourth_step2);
                }else{
			my $fourth_step="$Bin/bin/Zeta.sh -a $zscore_result  -b $Zeta  -i $output\_Zscore.matrix  -o $output -z $EventCoverage/Zseq_list.txt";
			print Log "fourth step:Zeta calculation......\n$fourth_step\n";
			system($fourth_step);
                }
		my $fifth_step="$Bin/bin/FDR_cutoff.sh -a $Zeta -b $FDR_cutoff -i $output\_Zeta.txt -o $output -n $fIn/$non_expressed_genes -p $fIn/$Positive_Control -s $fIn/$Negative_Control";
		system($fifth_step);
		print Log "fifth step:FDR cutoff calculation......\n$fifth_step\n";
	}
						
}else{
	if($combine eq "yes"){
		my $second_step="$Bin/bin/EventCoverage_combine.sh -a $fIn  -b $EventCoverage  -i $input  -o $output  -n $fIn/$Negative_Control -p $fIn/$Positive_Control";
		print Log "second step:Zscore normalization......\n$second_step\n";
		system($second_step);
		if($svm eq "yes"){
			my $third_step1="$Bin/bin/SVM.sh -i $EventCoverage  -a $output\_Matrix_EC_Positive_D  -b $output\_Matrix_EC_Negative_D -c $output\_Matrix_EC_Positive_I -d $output\_Matrix_EC_Negative_I -z  Zseq_list.txt -o $output -t $Zeta";
			print Log "third step1:SVM calculation......\n$third_step1\n";
			system($third_step1);
                        my $third_step2="$Bin/bin/Zeta_SVM.sh -a $Zeta  -i $fIn/$input  -b $Zeta -l $output\_SVM_lineCutOff_D -s $output\_SVM_lineCutOff_I   -o $output -z $EventCoverage/Zseq_list.txt ";
			print Log "third step2:Zeta calculation......\n$third_step2\n";
			system($third_step2);
		}else{
			my $third_step="$Bin/bin/Zeta.sh -a $fIn  -b $Zeta  -i $input -o $output -z $EventCoverage/Zseq_list.txt";
			print Log "third step:Zeta calculation......\n$third_step\n";
			system($third_step);
		}
		my $fourth_step="$Bin/bin/FDR_cutoff_combine.sh -a $Zeta -b $FDR_cutoff -i $output\_Zeta.txt -o $output -n $fIn/$non_expressed_genes -p $fIn/$Positive_Control -s $fIn/$Negative_Control";
		print Log "fourth step:FDR cutoff calculation......\n$fourth_step\n";
		system($fourth_step);
		
	}else{          
		my $second_step="$Bin/bin/EventCoverage.sh -a $fIn  -b $EventCoverage  -i $input  -o $output  -n $fIn/$Negative_Control -p $fIn/$Positive_Control";
		print Log "second step:EventCoverage.....\n$second_step\n";
		system($second_step);                
		if($svm eq "yes"){
			my $third_step1="$Bin/bin/SVM.sh -i $EventCoverage  -a $output\_Matrix_EC_Positive_D  -b $output\_Matrix_EC_Negative_D -c $output\_Matrix_EC_Positive_I -d $output\_Matrix_EC_Negative_I -z Zseq_list.txt -o $output -t $Zeta";
			print Log "third step1:SVM calculation......\n$third_step1\n";
			system($third_step1);
                        my $third_step2="$Bin/bin/Zeta_SVM.sh -a $Zeta  -i $fIn/$input  -b $Zeta -l $output\_SVM_lineCutOff_D -s $output\_SVM_lineCutOff_I  -o $output -z $EventCoverage/Zseq_list.txt";
			print Log "third step2:Zeta calculation......\n$third_step2\n";
			system("$third_step2");
		}else{
			my $third_step="$Bin/bin/Zeta.sh -a $fIn  -b $Zeta  -i $input  -o $output -z $EventCoverage/Zseq_list.txt";
			print Log "third step:Zeta calculation......\n$third_step\n";
			system("$third_step");
		}
		my $fourth_step="$Bin/bin/FDR_cutoff.sh -a $Zeta -b $FDR_cutoff -i $output\_Zeta.txt -o $output -n $fIn/$non_expressed_genes -p $fIn/$Positive_Control -s $fIn/$Negative_Control";
			print Log "fourth step:FDR cutoff calculation......\n$fourth_step\n";
			system($fourth_step);
	}
	
}
close Log;
##########################################################################
sub AbsolutePath{
        my ($type,$input) = @_;

        my $return;

        if ($type eq 'dir')
        {
                my $pwd = `pwd`;
                chomp $pwd;
                chdir($input);
                $return = `pwd`;
                chomp $return;
                chdir($pwd);
        }
        elsif($type eq 'file')
        {
                my $pwd = `pwd`;
                chomp $pwd;

                my $dir=dirname($input);
                my $file=basename($input);
                chdir($dir);
                $return = `pwd`;
                chop $return;
                $return .="/".$file;
                chdir($pwd);
        }
        return $return;
}
#####################################################################3
sub USAGE {
 	my $usage=<<"USAGE";

#-------------------------------------------------
Program: $Script

Author: $author

Contact: <yahao\@ucsd.edu>

Date of development: 2021-4-10

Fuction: the script was used to calculate Zeta score for multiple targets multiple hits screening analysis.

Usage:    
    -id  <STR>   input directory [require]
    -od  <STR>	 output directory [require]
    -in  <STR>   input file name [require]
    -op  <STR>	 output file prefix [require]
    -p   <STR>	 positive control file [require]
    -n   <STR>   negative control file [require]
    -ne  <STR>   internal negative control file (non-expressed genes) [require]
    -z   <STR>   zscore normalization(yes or no) [default yes]
    -c   <STR>   combine two direction zeta together(yes or no) [default no] 
    -svm <STR>	 svm calculation (yes or no) [dafault yes]
    -h   <STR>   documents help,

Example:
    perl $Script -id ./example -od ./output_example -in Example_matrix.txt -op Example -p Example_postive_wells.list -n Example_negative_wells.list -ne Example_NonExp_wells.list -z yes -c yes -svm yes 
#-------------------------------------------------
USAGE
    print $usage;
    exit;
}


