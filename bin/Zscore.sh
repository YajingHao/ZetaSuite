echo "input parameters are negative.list and processed.matrix"
while getopts a:b:i:o:n: OPT; do
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
    \?)
        printf "[Usage] `date '+%F %T'`-a <Input_dir> -b <output_dir> -i <Input_File> -o <Output_Name> -n <Negative_Control>\n" >&2
        exit 1
  esac
done
# check parameter
if [ -z "${in_dir}" -o -z "${out_dir}" -o -z "${in_file}" -o -z "${out_name}" -o -z "${negative_control}" ]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-a=${in_dir}\n-b=${out_dir}\n-i=${in_file}\n-o=${out_name}\n-n=${negative_control}\n"
    exit 1
fi
awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="Negative"}NR>FNR{if(FNR==1){print $0}else if(A[$1]!=""){print $0}}' ${in_dir}/${negative_control}  ${in_dir}/${in_file} > ${out_dir}/${out_name}_Negative.matrix
echo "start calculating Zscore"
Rscript $(dirname $(readlink -f $0))/calculateZscore.R ${out_dir}/${out_name}_Negative.matrix  ${in_dir}/${in_file} ${out_dir}/${out_name}_Zscore.matrix
echo "Zscore calculating finshed"
