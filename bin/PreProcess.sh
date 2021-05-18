#cd ./bin
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
echo "Remove the dropout rows and columns"
awk 'BEGIN{FS=OFS="\t"}{if(NR>1){sum=0;for(i=2;i<=NF;i++){if($i=="NA" || $i=="" || $i==0){sum=sum+1}};print $1,sum}}' ${in_dir}/${in_file} |sed '1i Gene\tNumber' > ${out_dir}/${out_name}_DropoutNumber_row
awk 'BEGIN{FS=OFS="\t"}{if(NR==1){for(i=2;i<=NF;i++){A[i]=0}}else{for(i=2;i<=NF;i++){if($i=="NA" || $i=="" || $i==0){A[i]=A[i]+1}}}}END{for(i in A){print i,A[i]}}' ${in_dir}/${in_file} |sed '1i colID\tNumber' > ${out_dir}/${out_name}_DropoutNumber_col
Rscript RemoveDropOut.R ${out_dir}/${out_name}_DropoutNumber_row ${out_dir}/${out_name}_DropoutNumber_col ${out_dir}/${out_name}_passed_genelist ${out_dir}/${out_name}_passed_col
awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="yes"}NR>FNR{if(FNR==1 || A[$1]!=""){print}}' ${out_dir}/${out_name}_passed_genelist ${in_dir}/${in_file} |awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="yes"}NR>FNR{str=$1;for(i=2;i<=NF;i++){str=str"\t"$i};print str}' ${out_dir}/${out_name}_passed_col - > ${out_dir}/${out_name}_matrix_filter
echo "KNN analysis"
Rscript KNN.R ${out_dir}/${out_name}_matrix_filter ${out_dir}/${out_name}_matrix_KNN
echo "done the file with ${out_name}_matrix_input is ready"
head -1 ${out_dir}/${out_name}_matrix_filter|cat - ${out_dir}/${out_name}_matrix_KNN > ${out_dir}/${out_name}_matrix_input 
