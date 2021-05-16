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

    `perl ZetaSuite.pl -id <input_dir> -od <output_dir> -in <input_matrix> -op <output_prefix> -p <positive.list> -n <negative.list> -ne <internatal_negative.list>`

    `ZetaSuite.pl` including the following steps:
   
    1). QC evaluation of the input matrix `<input_matrix>`. We just evaluate the QC but will not do any filterations.
  
    2). Calculate the Z-score to make the readouts are comparable.(option command `-z` yes or no,default: yes)
    
    3). Calculate the Event Coverage for each genes. 
    
    4). Using the SVM curve to filter the genes which is more similar with the negative control.(option command `-svm` yes or no , default: yes)
    
    5). Whether the user need to directly compare the Zeta score in two directions and use the combined Zeta score to do hits' selection? (option command `-c` yes or no, default: no)
    
    6). Calculate the Zeta score.
    
    7). Draw screen strength curve based on the internal negative control `<internatal_negative.list>`.
 
  
* #### If the input is already normalized matrix, you can directly run `ZetaSuite.pl` with parameter `-z no`. 

### Following steps were decided by the users, see example for detail.
  1. Based on the screen strength curve, users can define their optimal threshold by considering both SS and inflection points..
  2. Based on the threshold to selected the hits.
  3. Remove Off-targeting hits based on the regulation similarity and siRNA targeting.
  4. Function interpretation of selected hits based on [ClusterProfiler](https://github.com/YuLab-SMU/clusterProfiler) and [CORUM complexes database](https://github.com/YuLab-SMU/clusterProfiler).The top 15 GO terms with lowest adjust p-values were presented and the top 15 complexes with highest hits’ number were gave.If the complexes number were lower than 15, the complexes with hits’ number larger than 3 would be outputted.
  5. Constructed Network files for user selected hits. Then can directly input [Gephi](https://gephi.org/) for visulization.
 
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------
 ## Testing ZetaSuite using one example
We provided example data (our in-house HTS2 screening dataset) for using ZetaSuite to explore the hits and do futher functional interpretation. To save the testing time, we provide a subsampled dataset. While this test data may not yield reasonable results, it can be used to see how the workflow is configured and executed.

#### step 1. we started with the preprecessed data set which was already removed the low qulity rows and columns.
Users can find the example data set in the [example](https://github.com/YajingHao/ZetaSuit/tree/master/data) directory.
The example input files including:
   
   1. input matrix file, [Example_matrix.txt](https://github.com/YajingHao/ZetaSuit/tree/master/data), Each row represents gene with specific knocking-down siRNA pool, each column is an AS event. The values in the matrix are the processed readcounts foldchange values between included exons and skipping exons. 
   
      (we random pick-up 2000 genes and 200 AS events as example matrix)
   
      <img width="390" alt="image" src="https://user-images.githubusercontent.com/65927843/118161936-06e4dc80-b3d5-11eb-880b-259f46b00543.png">

   2. input negative file, the wells treated with non-specific siRNAs, [Example_negative_wells.list](https://github.com/YajingHao/ZetaSuit/tree/master/data). If users didn't have the build-in negative controls, the non-expressed genes should be provided here.
   3. input positive file, the wells treated with siRNAs targeting to PTB, [Example_positive_wells.list](https://github.com/YajingHao/ZetaSuit/tree/master/data). If users didn't have the build-in negative controls, choose the parameters `-withoutsvm` and the filename can use any name such as 'NA'.
   4. input internal negative control (non-expressed genes), genes which annotated as non-expressed (RPKM<1) in HeLa cells, [Example_NonExp_wells.list](https://github.com/YajingHao/ZetaSuit/tree/master/data).
  
#### step 2. run [ZetaSuite](https://github.com/YajingHao/ZetaSuit) main pipeline
   
  ```
  perl ZetaSuite.pl -id ./example -od ./output_example -in Example_matrix.txt -op Example -p Example_postive_wells.list -n Example_negative_wells.list -ne Example_NonExp_wells.list -z yes -c yes -svm yes
  ```
     
After finished processing, we will obtain the following files and figures in the corresponding directory:

The most time cosuming step is SVM in our pipeline. If you just want to test the pipeline, you can choose `-svm no`.
  
  `cd /output_example`
  
   1. QC figure :
   2. Normalized matrix:
   3. SVM figure:
   4. ZetaScore file:
   5. ZetaScore figure:
   6. ScreenStrength curve and files:
  
#### step 3. selected the thresholds
     
   Users can check the Screenstrength curves and find the optimal threshold based on balance points and Screen strength.
   As for example data set, we set the threshold as,
   
   Then obtain hits passed the threshold with the following command:
   
     ```
      Cutoff_D=0.07117596
      Cutoff_I=0.021272834
      awk -v cutoff=${Cutoff_D} '{FS=OFS="\t"}{if(NR==1 || $2>cutoff){print}}' D2_DRIVE_Zeta_anno.txt > Example_D_hits
      awk -v cutoff=${Cutoff_I} '{FS=OFS="\t"}{if(NR==1 || $3>cutoff){print}}' D2_DRIVE_Zeta_anno.txt > Example_I_hits
      
     ```
#### step 4. removing off-targeting genes
   
   The input files for off-targeting remove are:
   1) Targeting RNA sequences
     
   2) Gloden gene sets
   
   3) Hits
   
   4) Gene location files: [bed format](https://genome.ucsc.edu/FAQ/FAQformat.html#format1). The genome version should be human release 38(hg38).
     The default file is human gene locations downloaded from [Genecode database](https://www.gencodegenes.org/human/)(V28).
   
   5) Normalized matrix from **step2**
   
   `cd bin
     `
#### step 5. functional interpretation of hits
   The input file is hits file from **step3**
     `cd bin
     sh Function.sh -a -b -i Example_D_hits -o Example_D
     sh Function.sh -a -b -i Example_I_hits -o Example_I` 
   The output files are below:
    
#### step 6. constructing network files
   The input files for Network construction are:
    1)Normalized matrix from **step2**
    2)Hits from **step3**
    3)consensus_score_cutoff, the threshold to choose edges in the network.
    `cd bin
     cat Example_D_hits Example_I_hits |cut -f 1|sort|uniq > TotalHits.txt
     sh Network.sh -a <Input_dir> -b <output_dir> -h TotalHits.txt -i <Input_File> -o Example_Hits -c 0.5`
     
   The output files are below:
 
 # Citations

**software** : *Yajing Hao, Changwei Shao, Guofeng Zhao, Xiang-Dong Fu (2021). ZetaSuite, A Computational Method for Analyzing Multi-dimensional High-throughput Data, Reveals Genes with Opposite Roles in Cancer Dependency. Forthcoming*

**in-house dataset** : *Changwei Shao, Yajing Hao, Jinsong Qiu, Bing Zhou, Hairi Li, Yu Zhou, Fan Meng, Li Jiang, Lan-Tao Gou, Jun Xu, Yuanjun Li,Hui Wang, Gene W. Yeo, Dong Wang, Xiong Ji, Christopher K. Glass, Pedro Aza-Blanc, Xiang-Dong Fu (2021). HTS2 Screen for Global Splicing Regulators Reveals a Key Role of the Pol II Subunit RPB9 in Coupling between Transcription and Pre-mRNA Splicing. Cell.  Forthcoming.* 
