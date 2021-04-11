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
:>${out_name}_FDR_cutOff_output.txt
#two parameters here, one is non-expression genes Negative_control_use.txt and Zeta scores Zeta.txt
awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="non-exp"}NR>FNR{if(FNR==1){print $0,"type"}else if(A[$1]!=""){print $0,A[$1]}else{print $0,"Gene"}}' ${negative_control} ${in_file}| awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="Positive"}NR>FNR{if(FNR==1 || A[$1]==""){print $0}else if(A[$1]!=""){print $1,$2,$3,A[$1]}}' ${positive_control} - > ${out_name}_Zeta_anno.txt
maxD=$(sed '1,1d' ${out_name}_Zeta_anno.txt|cut -f 2|sort -g -r |sed -n '50,50p')
maxI=$(sed '1,1d' ${out_name}_Zeta_anno.txt|cut -f 3|sort -g -r |sed -n '50,50p')
minD=$(sed '1,1d' ${out_name}_Zeta_anno.txt|cut -f 2|sort -g |head -1)
minI=$(sed '1,1d' ${out_name}_Zeta_anno.txt|cut -f 3|sort -g |head -1)
stepD=$(head -1 ${out_name}_Zeta_anno.txt|awk -v max=${maxD} -v min=${minD} '{print (max-min)/100}')
stepI=$(head -1 ${out_name}_Zeta_anno.txt|awk -v max=${maxI} -v min=${minI} '{print (max-min)/100}')
iFDR=$(awk 'BEGIN{FS=OFS="\t"}{sum1=sum1+1;if($4=="non-exp"){sum2=sum2+1}}END{print sum2/(sum1-1)}' ${out_name}_Zeta_anno.txt)
echo "Decrease cut-off"
for  number in $(seq ${minD} ${stepD} ${maxD});do
	totalnum=$(awk -v num=${number} -v sum=0 'BEGIN{FS=OFS="\t"}{if(NR>1 && $2>=num){sum=sum+1}}END{print sum}' ${out_name}_Zeta_anno.txt)
	numNexp=$(awk -v num=${number} -v sum=0 'BEGIN{FS=OFS="\t"}{if(NR>1 && $2>=num && $4=="non-exp"){sum=sum+1}}END{print sum}' ${out_name}_Zeta_anno.txt)
	FDR_Nexp=$(echo "yes" |awk -v num1=${totalnum} -v num2=${numNexp} '{print num2/num1}' )
	screen_Stress=$(echo "yes" |awk -v num1=${FDR_Nexp} -v num2=${iFDR} '{print (num2-num1)/num2}' )
	echo "$number\t${FDR_Nexp}\t${screen_Stress}\t${totalnum}\t${numNexp}\tDecrease" >> ${out_name}_FDR_cutOff_output.txt
done
echo "Increase cut-off"
for  number in $(seq ${minI} ${stepI} ${maxI});do
        totalnum=$(awk -v num=${number} -v sum=0 'BEGIN{FS=OFS="\t"}{if(NR>1 && $3>=num){sum=sum+1}}END{print sum}' ${out_name}_Zeta_anno.txt)
        numNexp=$(awk -v num=${number} -v sum=0 'BEGIN{FS=OFS="\t"}{if(NR>1 && $3>=num && $4=="non-exp"){sum=sum+1}}END{print sum}' ${out_name}_Zeta_anno.txt)
        FDR_Nexp=$(echo "yes" |awk -v num1=${totalnum} -v num2=${numNexp} '{print num2/num1}' )
        screen_Stress=$(echo "yes" |awk -v num1=${FDR_Nexp} -v num2=${iFDR} '{print (num2-num1)/num2}' )
        echo "$number\t${FDR_Nexp}\t${screen_Stress}\t${totalnum}\t${numNexp}\tIncrease" >> ${out_name}_FDR_cutOff_output.txt
done
sed '1i Cut-Off\taFDR\tSS\tTotalHits\tNum_nonExp\tType' ${out_name}_FDR_cutOff_output.txt > ${out_name}_FDR_cutOff_output_temp.txt
mv ${out_name}_FDR_cutOff_output_temp.txt ${out_name}_FDR_cutOff_output.txt
echo "draw zeta jitter figues"
Rscript drawZeta_jitter.R ${out_name}_Zeta_anno.txt ${out_name}_Zeta_type.pdf ${out_name}_FDR_cutOff_output.txt ${out_name}_SS_cutOff.pdf
