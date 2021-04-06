# ZetaSuit
Zeta score method to analysis multiple targets multiple hits screening

# If the input is the rawcount matrix, please run the Preprocess.sh first.
Preprocess.sh including the following steps: 
  1) Filter low quailty samples and low quality readouts.
  2) Using KNN to add the NA values.
  3) Loess Normalization to avoid the change bias along with sequencing depth.

# If the input is the already precessed matrix, you can directly run ZetaSuit.sh.
ZetaSuit.sh including the following steps:
  1) QC evaluation of the input datasets. We just evaluate the QC but will not do any filterations.
  2) Calculate the Zscore to make the readouts are comparable.(option command)
  3) Calculate the Event Coverage for each genes.
  4) Using the SVM curve to filter the genes which is more similar with the negative control.
  5) Based the SVM curve and Event Coverage to calculate the Zeta value.
  6) Draw screen strength curve based on the internal negative control.

# following steps were decided by the users.
  1) Based on the screen strength curve, users can choose the different cut-off.
  2) Based on the cut-off to selected the hits.
  3) Remove Off-targeting hits based on the regulation similarity and siRNA targeting.
  4) Do fuctional analysis.
  5) Draw Network for the hits.
