#cd ./bin
while getopts i:o:n:p: OPT; do
  case ${OPT} in
    i) in_file=${OPTARG}
       ;;
    o) out_name=${OPTARG}
       ;;
    n) negative_control=${OPTARG}
       ;;
    p) positive_control=${OPTARG}
       ;;
    \?)
       printf "[Usage] `date '+%F %T'` -i <Input_File> -o <Output_Name> -n <Negative_Control> -p <Positive_Control>\n" >&2
       exit 1
  esac
done
# check parameter
if [ -z "${in_file}" -o -z "${out_name}" -o -z "${negative_control}"  -o -z "${positive_control}" ]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-i=${in_file}\n-o=${out_name}\n-n=${negative_control}\n-p=${positive_control}\n"
    exit 1
fi
sh QC.sh -i ${in_file} -o ${out_name} -n ${negative_control} -p ${positive_control}
echo "do event coverage calculation"
sh EventCoverage.sh -i ${in_file} -o ${out_name} -n ${negative_control} -p ${positive_control}
echo "calculating zeta"
echo "check wether calculating the SVM curve"
sh SVM.sh -a ${out_name}_Matrix_EC_Positive_D  -b ${out_name}_Matrix_EC_Negative_D -c ${out_name}_Matrix_EC_Positive_I -d ${out_name}_Matrix_EC_Negative_I -e ${out_name}
#echo "calculate zeta score other zeta or no"
#sh Zeta.sh -i ${in_file} -o ${out_name} 
#echo "calculate zeta score consider svm curve"
#sh Zeta_SVM.sh -i ${in_file} -o ${out_name}
#echo "do FDR analysis"
#sh FDR_cutoff.sh -i ${out_name}_Zeta.txt -o ${out_name} -n ${negative_control} -p ${positive_control}
#echo "based on screen strength to select cut-off"
#Cutoff_D=0.07117596
#Cutoff_I=0.021272834
#awk -v cutoff=${Cutoff_D} '{FS=OFS="\t"}{if(NR==1 || $2>cutoff){print}}' D2_DRIVE_Zeta_anno.txt > D2_DRIVE_D_hits
#awk -v cutoff=${Cutoff_I} '{FS=OFS="\t"}{if(NR==1 || $3>cutoff){print}}' D2_DRIVE_Zeta_anno.txt > D2_DRIVE_I_hits
##do off-targeting remove
#based on siRNAs correlation and gene-correlation
#do clustering on total Hits
#do deapthAndBreadthAnalysi

