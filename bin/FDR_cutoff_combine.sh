while getopts a:b:i:o:n:p:s: OPT; do
  case ${OPT} in
    a) in_dir=${OPTARG}
       ;;
    b) out_dir=${OPTARG}
       ;;
    i) in_file=${OPTARG}
       ;;
    o) out_name=${OPTARG}
       ;;
    n) negative_control=${OPTARG}
       ;;
    p) positive_control=${OPTARG}
       ;;
    s) NS_mix=${OPTARG}
       ;;
    \?)
       printf "[Usage] `date '+%F %T'` -a <Input_dir> -b <output_dir> -i <Input_File> -o <Output_Name> -n <Negative_Control> -p <Positive_Control> -s <NS_mix>\n" >&2
       exit 1
  esac
done
# check parameter
if [ -z "${in_dir}" -o -z "${out_dir}" -o -z "${in_file}" -o -z "${out_name}" -o -z "${negative_control}"  -o -z "${positive_control}" -o -z "${NS_mix}" ]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-a=${in_dir}\n-b=${out_dir}\n-i=${in_file}\n-o=${out_name}\n-n=${negative_control}\n-p=${positive_control}\n-s=${NS_mix}\n"
    exit 1
fi
:>${out_dir}/${out_name}_FDR_cutOff_output.txt
#two parameters here, one is non-expression genes Negative_control_use.txt and Zeta scores Zeta.txt
awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="non-exp"}NR>FNR{if(FNR==1){print $0,"type"}else if(A[$1]!=""){print $0,A[$1]}else{print $0,"Gene"}}' ${negative_control} ${in_dir}/${in_file}| awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="Positive"}NR>FNR{if(FNR==1 || A[$1]==""){print $0}else if(A[$1]!=""){print $1,$2,$3,A[$1]}}' ${positive_control} - |awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="NS_mix"}NR>FNR{if(FNR==1 || A[$1]=="" || $4=="non-exp" || $4=="Positive"){print $0}else if(A[$1]!=""){print $1,$2,$3,A[$1]}}' ${NS_mix} - > ${out_dir}/${out_name}_Zeta_anno.txt
maxD=$(awk 'BEGIN{FS=OFS="\t"}{if(NR>1 && ($4=="non-exp" || $4=="Gene")){print $2+$3}}' ${out_dir}/${out_name}_Zeta_anno.txt|sort -g -r |sed -n '20,20p')
minD=$(awk 'BEGIN{FS=OFS="\t"}{if(NR>1 && ($4=="non-exp" || $4=="Gene")){print $2+$3}}' ${out_dir}/${out_name}_Zeta_anno.txt|sort -g |head -1)
stepD=$(head -1 ${out_dir}/${out_name}_Zeta_anno.txt|awk -v max=${maxD} -v min=${minD} '{print (max-min)/100}')
iFDR=$(awk 'BEGIN{FS=OFS="\t"}{if($4=="non-exp" || $4=="Gene"){sum1=sum1+1};if($4=="non-exp"){sum2=sum2+1}}END{print sum2/(sum1-1)}' ${out_dir}/${out_name}_Zeta_anno.txt)
echo "Decrease cut-off"
for  number in $(seq ${minD} ${stepD} ${maxD});do
	totalnum=$(awk -v num=${number} -v sum=0 'BEGIN{FS=OFS="\t"}{if(NR>1 && ($2+$3)>=num && ($4=="non-exp" || $4=="Gene")){sum=sum+1}}END{print sum}' ${out_dir}/${out_name}_Zeta_anno.txt)
	numNexp=$(awk -v num=${number} -v sum=0 'BEGIN{FS=OFS="\t"}{if(NR>1 && ($2+$3)>=num && $4=="non-exp"){sum=sum+1}}END{print sum}' ${out_dir}/${out_name}_Zeta_anno.txt)
	FDR_Nexp=$(echo "yes" |awk -v num1=${totalnum} -v num2=${numNexp} '{print num2/num1}' )
	screen_Stress=$(echo "yes" |awk -v num1=${FDR_Nexp} -v num2=${iFDR} '{print (num2-num1)/num2}' )
	echo "$number&&${FDR_Nexp}&&${screen_Stress}&&${totalnum}&&${numNexp}&&Combine" >> ${out_dir}/${out_name}_FDR_cutOff_output.txt
done
sed '1i Cut-Off\taFDR\tSS\tTotalHits\tNum_nonExp\tType' ${out_dir}/${out_name}_FDR_cutOff_output.txt|sed 's/&&/\t/g' > ${out_dir}/${out_name}_FDR_cutOff_output_temp.txt
mv ${out_dir}/${out_name}_FDR_cutOff_output_temp.txt ${out_dir}/${out_name}_FDR_cutOff_output.txt
echo "draw zeta jitter figues"
Rscript $(dirname $(readlink -f $0))/drawZeta_jitter_combine.R ${out_dir}/${out_name}_Zeta_anno.txt ${out_dir}/${out_name}_Zeta_type.pdf ${out_dir}/${out_name}_FDR_cutOff_output.txt ${out_dir}/${out_name}_SS_cutOff.pdf
