## ZetaSuit : A Computational Method for Analyzing Multi-dimensional High-throughput Data

![Figure1-01](https://user-images.githubusercontent.com/65927843/118019732-2b29b600-b30e-11eb-9ca0-5911dd82b608.jpg)
If you have any questions, please contact Yajing Hao <yahao@health.ucsd.edu> in [Fu Lab](http://fugenome.ucsd.edu/).

## Table of contents
- Installation
- The overall workflow of ZetaSuit
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
   
    1). QC evaluation of the input datasets. We just evaluate the QC but will not do any filterations.
  
    2). Calculate the Z-score to make the readouts are comparable.(option command -norm or -withoutNorm,default: -norm)
    
    3). Calculate the Event Coverage for each genes. 
    
    4). Using the SVM curve to filter the genes which is more similar with the negative control.(option command -svm or -withousvm, default:-svm)
    
    5). Whether the user need to directly compare the Zeta score in two directions? (option command -com or -withoutCom, default: -com)
    
    6). Calculate the Zeta score.
    
    7). Draw screen strength curve based on the internal negative control.
 
  
* #### If the input is already normalized matrix, you can directly run `ZetaSuit.sh` with parameter `-withoutNorm`. 

### Following steps were decided by the users, see example for detail.
  1. Based on the screen strength curve, users can define their optimal threshold by considering both SS and inflection points..
  2. Based on the threshold to selected the hits.
  3. Remove Off-targeting hits based on the regulation similarity and siRNA targeting.
  4. Function interpretation of selected hits based on [ClusterProfiler](https://github.com/YuLab-SMU/clusterProfiler) and [CORUM complexes database](https://github.com/YuLab-SMU/clusterProfiler).The top 15 GO terms with lowest adjust p-values were presented and the top 15 complexes with highest hits’ number were gave.If the complexes number were lower than 15, the complexes with hits’ number larger than 3 would be outputted.
  5. Constructed Network files for user selected hits. Then can directly input [Gephi](https://gephi.org/) for visulization.
 
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------
 ## Testing ZetaSuite using one example
We provided example data for using ZetaSuite to explore the hits and do futher functional interpretation based on our in-house HTS2 screening dataset. To save the testing time, we provide a subsampled dataset. While this test data may not yield reasonable results, it can be used to see how the workflow is configured and executed.

#### step 1. we started with the preprecessed data set which was already removed the low qulity rows and columns.
Users can find the example data set in the [example](https://github.com/YajingHao/ZetaSuit/tree/master/data) directory.
The example input files including:
   
   1. input matrix file, [Example_matrix.txt](https://github.com/YajingHao/ZetaSuit/tree/master/data), Each row represents gene with specific knocking-down siRNA pool, each column is an AS event. The values in the matrix are the processed readcounts foldchange values between included exons and skipping exons. 
   
   (we random pick-up 2000 genes and 200 AS events as example matrix)
   
   <img width="390" alt="image" src="https://user-images.githubusercontent.com/65927843/118161936-06e4dc80-b3d5-11eb-880b-259f46b00543.png">

   2. input negative file, the wells treated with non-specific siRNAs, [Example_negative_wells.list](https://github.com/YajingHao/ZetaSuit/tree/master/data). If users didn't have the build-in negative controls, the non-expressed genes should be provided here.
   3. input positive file, the wells treasted with siRNAs targeting to PTB, [Example_positive_wells.list](https://github.com/YajingHao/ZetaSuit/tree/master/data). If users didn't have the build-in negative controls, choose the parameters `-withoutsvm` and the filename can use any name such as 'NA'.
   4. input internal negative control (non-expressed genes), genes which annotated as non-expressed (RPKM<1) in HeLa cells, [Example_NonExp_wells.list](https://github.com/YajingHao/ZetaSuit/tree/master/data).
  
#### step 2. run [ZetaSuite](https://github.com/YajingHao/ZetaSuit) main pipeline
    `cd bin`
    `sh ZetaSuit.sh -a ../example -b ../output_example -i Example_matrix.txt -o Example -n Example_negative_wells.list -p Example_postive_wells.list -c Example_NonExp_wells.list`
     
  After finished processing, we will obtain the following files and figures:
  
   1. QC figure:
   2. SVM figure:
   3. ZetaScore file:
   4. ScreenStrength curve and files.
  
#### step 3. selected the thresholds
     
   Users can check the Screenstrength curves and the provided inflection points candidate to choose the threshold.
     As for example data set, we set the threshold as,
     Then obtain hits passed the threshold with the following command:
     `cd bin`
     
#### step 4. removing off-targeting genes
     `cd bin`
#### step 5. functional interpretation
     `cd bin` 
#### step 6. constructing network files
     `cd bin`
 
 # Citations
