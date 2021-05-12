## ZetaSuit : A computation workframe to analysis multiple targets multiple hits screening
![Figure1-01](https://user-images.githubusercontent.com/65927843/118019732-2b29b600-b30e-11eb-9ca0-5911dd82b608.jpg)
If you have any questions, please contact Yajing Hao <yahao@health.ucsd.edu> in [Fu Lab](http://fugenome.ucsd.edu/).

## Table of contents
- Installation
- The overall workflow of ZetaSuit
- Parameters
- Testing ZetaSuite using one example
- Citations
## Installation
Since ZetaSuit is written in `Shell`, `R` and `Perl`, `R` and `Perl` are needed. 

Other R packages dependencies are:
    
    
     library(foreach)
     library(ggplot2)
     library(parallel)
     library(RColorBrewer)
     library(reshape2)
     library(DMwR)
     library(scater)
     library(e1071)
     library(Rtsne)
     library(clusterProfiler)
     library(org.Hs.eg.db)
     library(enrichplot)
     library(DOSE)
     library(bubbles)
     library(colorRamps)
     library(webshot)
     library(htmlwidgets)
     library(SC3)
     library(SingleCellExperiment)
     library(NbClust)
     
You can just run the code below to install all the dependent R packages at once:

`install.packages(c("foreach", "ggplot2","parallel","RColorBrewer", "reshape2","DMwR","e1071", "Rtsne","clusterProfiler","org.Hs.eg.db","enrichplot","DOSE","bubbles","colorRamps","webshot","htmlwidgets","SC3","SingleCellExperiment","NbClust"))`

Other softwares dependencies are:

- `Bedtools`(https://bioweb.pasteur.fr/docs/modules/bedtools/2.17.0/index.html)
- `blast`(https://blast.ncbi.nlm.nih.gov/Blast.cgi)

      
The installation procedure is extremely easy. 
1. clone the source code from git-hub.
   
   `github clone https://github.com/YajingHao/ZetaSuit.git`
2. go into the directory in the command line. 
   
   `cd bin`
3. test the example data.
   
   `sh ZetaSuite.sh -a ...`

And it is done :v:!

## The overall workflow of ZetaSuit.
![workflow-01](https://user-images.githubusercontent.com/65927843/118020609-1ef22880-b30f-11eb-8e59-843c3eb4fe31.jpg)


### The input of ZetaSuite can be three types:
      
      - Raw read count matrix, in the example data: row is the genes with targeting siRNAs, and columns are the AS events as readouts.
      - Preprocess matrix, which means the low-quality rows and columns were already filtered by users.
      - Normalized matrix, which means the value in the matrix can directly compare and do the accumulation.
        

* #### If the input is the raw read count matrix without any processing, please run the `Preprocess.sh` first.

    `sh Preprocess.sh -a <Input_dir> -b <output_dir> -i <Input_File> -o <Output_Name>`
    
    `Preprocess.sh` including the following steps: 
        1. Filter low quailty samples and low quality readouts.
        2. Using KNN to estimate the value of the missing data points in the input matrix.

* #### If the input is the already precessed matrix, you can directly run `ZetaSuit.sh`.

    `sh ZetaSuit.sh -a <Input_dir> -b <output_dir> -i <Input_File> -o <Output_Name> -n <Negative_Control> -p <Positive_Control>`

    `ZetaSuit.sh` including the following steps:
   
    1. QC evaluation of the input datasets. We just evaluate the QC but will not do any filterations.
    2. Calculate the Z-score to make the readouts are comparable.(option command -norm or -withoutNorm,default: -norm)
    3. Calculate the Event Coverage for each genes. 
    4. Using the SVM curve to filter the genes which is more similar with the negative control.(option command -svm or -withousvm, default:-svm)
    5. Whether the user need to directly compare the Zeta score in two directions? (option command -com or -withoutCom, default: -com)
    6. Event Coverage to calculate the Zeta value.
    7. Draw screen strength curve based on the internal negative control.
 
  
* #### If the input is already normalized matrix, you can directly run `ZetaSuit.sh` with parameter `-`. 

### Following steps were decided by the users, see example for detail.
  1. Based on the screen strength curve, users can choose the different cut-off.
  2. Based on the cut-off to selected the hits.
  3. Remove Off-targeting hits based on the regulation similarity and siRNA targeting.
  4. Draw Network for the hits.
 
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------
 ## Parameters 
 ## Testing ZetaSuite using one example
 # Citations
