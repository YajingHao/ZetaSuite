#while getopts a:b:i:o:n:p: OPT; do
#  case ${OPT} in
#    a) in_dir=${OPTARG}
#       ;;
#    b) out_dir=${OPTARG}
#       ;;
#    i) in_file=${OPTARG}
#       ;;
#    o) out_name=${OPTARG}
#       ;;
#    \?)
#       printf "[Usage] `date '+%F %T'` -a <Input_dir> -b <output_dir> -i <Input_File> -o <Output_Name>\n" >&2
#       exit 1
#  esac
#done
# check parameter
#if [ -z "${in_dir}" -o -z "${out_dir}" -o -z "${in_file}" -o -z "${out_name}" ]; then
#    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-a=${in_dir}\n-b=${out_dir}\n-i=${in_file}\n-o=${out_name}\n"
#    exit 1
#fi
#a#:>${out_dir}/${out_name}_Edges_filter.csv
#awk 'BEGIN{FS=OFS="\t"}{if(A[$1$2]=="" && A[$2$1]=="" && $1!=$2){print;A[$1$2]="yes";A[$2$1]="yes"}}' ${in_dir}/${in_name}_edge.txt
:>temp.txt
for  number in $(seq 0.5 0.01 1);do
	edgeNum=$(awk -v num=${number} 'BEGIN{FS=OFS="\t"}{if(A[$1$2]=="" && A[$2$1]=="" && $1!=$2 && $3>num){print;A[$1$2]="yes";A[$2$1]="yes"}}' _edge.txt|wc -l)
	echo "$number\t${edgeNum}" >> temp.txt
done
