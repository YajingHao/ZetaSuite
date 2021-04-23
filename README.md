# ZetaSuit
Zeta score method to analysis multiple targets multiple hits screening

# Installation
Since ZetaSuit is written in Shell, R and Perl, R and Perl are needed. 
Other dependencies are:
      1 library(e1071)
      2 library(foreach)
      3 library(ggplot2)
      4 library(parallel)
      5 library(RColorBrewer)
      6 library(reshape2)
      7 library(Rtsne)
      8 library(scater)
      
The installation procedure is extremely easy. First, download the source code, unzip it, and go into the directory in the command line to test the example data.
(code)

And it is done!

# The overall workflow of ZetaSuit.
<img width="634" alt="image" src="https://user-images.githubusercontent.com/65927843/114289438-d18f4c80-9a2c-11eb-846d-4a54339fdb02.png">


# If the input is the raw read count matrix, please run the Preprocess.sh first.

sh Preprocess.sh -n Negative.list -o outputName

Preprocess.sh including the following steps: 
  1) Filter low quailty samples and low quality readouts.
  2) Using KNN to add the NA values.

# If the input is the already precessed matrix, you can directly run ZetaSuit.sh.
(sh ZetaSuit.sh code)

ZetaSuit.sh including the following steps:
  1) QC evaluation of the input datasets. We just evaluate the QC but will not do any filterations.
  2) Calculate the Zscore to make the readouts are comparable.(option command,default: yes)
  3) Calculate the Event Coverage for each genes.
  4) Using the SVM curve to filter the genes which is more similar with the negative control.(option command, default:yes)
  5) Event Coverage to calculate the Zeta value.
  6) Draw screen strength curve based on the internal negative control.
  
# If the input is already normalized matrix. The normalization means the values are comparable between different events. The users can directly using ZetaSuite to calculate the acumulation strength. Run ZetaSuit_norm.sh. 
  ZetaSuit_norm.sh'steps are similar with ZetaSuit_norm.sh, except step2.

# following steps were decided by the users.
  1) Based on the screen strength curve, users can choose the different cut-off.
  2) Based on the cut-off to selected the hits.
  3) Remove Off-targeting hits based on the regulation similarity and siRNA targeting.
  4) Draw Network for the hits.
