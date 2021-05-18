#input parameters are Negative.list Negative.list Achilles-98k_batch1_input.txt
while getopts a:b:i:o:n:p: OPT; do
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
    \?)
       	printf "[Usage] `date '+%F %T'`-a <Input_dir> -b <output_dir> -i <Input_File> -o <Output_Name> -n <Negative_Control> -p <Positive_Control>\n" >&2
	exit 1
  esac
done
# check parameter
if [ -z "${in_dir}" -o -z "${out_dir}" -o -z "${in_file}" -o -z "${out_name}" -o -z "${negative_control}"  -o -z "${positive_control}" ]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-a=${in_dir}\n-b=${out_dir}\n-i=${in_file}\n-o=${out_name}\n-n=${negative_control}\n-p=${positive_control}\n"
    exit 1
fi
# data processing
awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="Negative"}NR>FNR{if(FNR==1){print $0,"Type"}else if(A[$1]!=""){print $0,A[$1]}}' ${in_dir}/${negative_control}  ${in_dir}/${in_file} > ${out_dir}/${out_name}_QC_Negative
awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="Positive"}NR>FNR{if(FNR==1){print $0,"Type"}else if(A[$1]!=""){print $0,A[$1]}}' ${in_dir}/${positive_control}  ${in_dir}/${in_file} > ${out_dir}/${out_name}_QC_Positive
sed '1,1d' ${out_dir}/${out_name}_QC_Positive |cat ${out_dir}/${out_name}_QC_Negative - |cut -f 2-|sed 's/NA/0/g' > ${out_dir}/${out_name}_QC_input.txt
rm ${out_dir}/${out_name}_QC_Positive
rm ${out_dir}/${out_name}_QC_Negative
Rscript $(dirname $(readlink -f $0))/QC_input.R ${out_dir}/${out_name}_QC_input.txt ${out_dir}/${out_name}_score_QC.png ${out_dir}/${out_name}_tSNE_QC.pdf ${out_dir}/${out_name}_QC_boxplot.pdf ${out_dir}/${out_name}_QC_SSMD.pdf
