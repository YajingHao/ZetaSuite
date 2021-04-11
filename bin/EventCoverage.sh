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
echo ${out_name}_EC_jitter_D.pdf
#Rscript obtain_ZRange.R ${in_file} Zseq_list.txt
echo "calculating EC for D"
Rscript obtain_EventCoverage_D.R ${in_file} Zseq_list.txt ${out_name}_EC_D.txt
echo "calculating EC for I"
Rscript obtain_EventCoverage_I.R ${in_file} Zseq_list.txt ${out_name}_EC_I.txt
echo "divid data to Positive and Negative"
awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="Positive"}NR>FNR{if(FNR==1){print "GeneSymbol",$0}else if(A[$1]!=""){print}}' ${positive_control} ${out_name}_EC_D.txt > ${out_name}_Matrix_EC_Positive_D 
awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="Positive"}NR>FNR{if(FNR==1){print "GeneSymbol",$0}else if(A[$1]!=""){print}}' ${positive_control} ${out_name}_EC_I.txt > ${out_name}_Matrix_EC_Positive_I
awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="Negative"}NR>FNR{if(FNR==1){print "GeneSymbol",$0}else if(A[$1]!=""){print}}' ${negative_control} ${out_name}_EC_D.txt > ${out_name}_Matrix_EC_Negative_D
awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="Negative"}NR>FNR{if(FNR==1){print "GeneSymbol",$0}else if(A[$1]!=""){print}}' ${negative_control} ${out_name}_EC_I.txt > ${out_name}_Matrix_EC_Negative_I
echo "draw EC jitter figures"
Rscript draw_EC.R ${out_name}_EC_jitter_D.pdf ${out_name}_EC_jitter_I.pdf ${out_name}_Matrix_EC_Positive_D ${out_name}_Matrix_EC_Negative_D ${out_name}_Matrix_EC_Positive_I ${out_name}_Matrix_EC_Negative_I

