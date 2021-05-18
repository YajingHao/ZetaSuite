#input is the hits.list with the zetavalues
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
    \?)
        printf "[Usage] `date '+%F %T'`-a <Input_dir> -b <output_dir> -i <Input_File> -o <Output_Name>\n" >&2
        exit 1
  esac
done
# check parameter
if [ -z "${in_dir}" -o -z "${out_dir}" -o -z "${in_file}" -o -z "${out_name}" ]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-a=${in_dir}\n-b=${out_dir}\n-i=${in_file}\n-o=${out_name}\n"
    exit 1
fi
Rscript $(dirname $(readlink -f $0))/ClusterProfiler.R ${in_dir}/${in_file} ${out_dir}/${out_name}_GO_top15.pdf
awk 'BEGIN{FS=OFS="\t"}NR==FNR{split($13,a,";");for(i in a){if(A[a[i]]){A[a[i]]=A[a[i]]";"$1}else{A[a[i]]=$1}};gsub(" ",";",$19);gsub(",",";",$19);split($19,b,";");for(i in b){if(b[i]!=""){if(A[b[i]]){A[b[i]]=A[b[i]]";"$1}else{A[b[i]]=$1}}}}NR>FNR{if(A[$1]){print $0,A[$1]}else if(FNR==1){print $0,"complex"}}' $(dirname $(readlink -f $0))/dataSets/allComplexes_human.txt ${in_dir}/${in_file} > ${out_dir}/${out_name}_complex
awk 'BEGIN{FS=OFS="\t"}{if(NR>1){print $NF}}' ${out_dir}/${out_name}_complex |awk 'BEGIN{FS=OFS="\t"}{split($1,a,";");for(i in a){print a[i]}}'|sort|uniq -c|sed 's/^[ \t]*//g'|sed 's/ /\t/g'|awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]=$2}NR>FNR{print $0,A[$2]}' $(dirname $(readlink -f $0))/dataSets/allComplexes_human.txt -|sort -k 1 -n -r|head -15|sed '1i Count\tLableID\tName' > ${out_dir}/${out_name}_Top15_Complex_frequency
Rscript $(dirname $(readlink -f $0))/Complex.R ${out_dir}/${out_name}_Top15_Complex_frequency ${out_dir}/${out_name}_Top15_Complex.png
