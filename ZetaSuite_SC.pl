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

#-a <Input_dir> -b <output_dir> -i <Input_File> -o <Output_Name> -n <Bin_Number>

#-------------------------------------------------------
#   Getoptions
#-------------------------------------------------------
my ($fIn,$fOut,$input,$output,$bin_number,$filter);
GetOptions(
	     "help|?" =>\&USAGE,
		 "id:s"=>\$fIn,
		 "od:s"=>\$fOut,
		 "in:s"=>\$input,
		 "op:s"=>\$output,
		 "n:s"=>\$bin_number,
		 "f:s"=>\$filter,
    ) or &USAGE;
&USAGE unless ($fIn and $fOut and $input and $output);

#######################################################################################
# ------------------------------------------------------------------
# main 
# ------------------------------------------------------------------
#default
$bin_number||=10;
$filter||="yes";

#input directory
$fIn=AbsolutePath("dir",$fIn);

#output directory setting
mkdir $fOut if (! -d $fOut);
$fOut=AbsolutePath("dir",$fOut);

#Log file 
my $LOG;
open (Log,">$fOut/LOG.txt") or die;
my $tmp="$Bin/bin/ZetaSuite_SC.sh -a $fIn -b $fOut  -i $input  -o $output  -n $bin_number -f $filter";
system($tmp);
print Log "$tmp\n";
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

Fuction: the script was used to calculate Zeta score for Single Cell data.

Usage:    
    -id  <STR>   input directory [require]
    -od  <STR>	 output directory [require]
    -in  <STR>   input file name [require]
    -op  <STR>	 output file prefix [require]
    -n   <STR>   bin number [default 10]
    -f   <STR>   need filter nCount<100 before calculation [default yes]
    -h   <STR>   documents help,

Example:
    perl $Script -id ./example -od ./output_example -in Example_matrix.txt -op Example -n 10 
#-------------------------------------------------
USAGE
    print $usage;
    exit;
}
