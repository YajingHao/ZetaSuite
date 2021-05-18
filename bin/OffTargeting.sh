while getopts b:i:o:m:t:l:g:c: OPT; do
  case ${OPT} in
    b) out_dir=${OPTARG}
       ;;
    i) in_file=${OPTARG}
       ;;
    o) out_name=${OPTARG}
       ;;
    m) Normalized_matrix=${OPTARG}
       ;;
    t) targetingRNA_seq=${OPTARG}
       ;;
    l) GeneLocation_bed=${OPTARG}
       ;;
    g) GodenSets=${OPTARG}
       ;;
    c) GeneTrans=${OPTARG}
       ;;
    \?)
       printf "[Usage] `date '+%F %T'` -b <output_dir> -i <Input_File> -o <Output_Name> -m <Normalized_matrix> -t <targetingRNA_seq> -l <GeneLocation_bed> -g <GodenSets> -c <GeneID_transfer_files>\n" >&2
       exit 1
  esac
done
# check parameter
if [ -z "${out_dir}" -o -z "${in_file}" -o -z "${out_name}" -o -z "${Normalized_matrix}"  -o -z "${targetingRNA_seq}" -o -z "${GeneLocation_bed}" -o -z "${GodenSets}" -o -z "${GeneTrans}" ]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-b=${out_dir}\n-i=${in_file}\n-o=${out_name}\n-m=${Normalized_matrix}\n-t=${targetingRNA_seq}\n-l=${GeneLocation_bed}\n-g=${GodenSets}\n-c=${GeneTrans}\n"
    exit 1
fi
:>${out_dir}/${out_name}_blast
echo "obtain highly correlated genes"
Rscript $(dirname $(readlink -f $0))/offTagrt_cor.R ${Normalized_matrix} ${out_dir}/${out_name}_cor
echo  "do blast analysis"
cut -f 1 ${in_file} |cat -|while read line;do
	 hit=$(echo $line)
        grep -n "${hit}" ${targetingRNA_seq} |sed 's/:/\t/g'|awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="yes";A[$1+1]="yes"}NR>FNR{if(A[FNR]!=""){print}}' - ${targetingRNA_seq} > ${out_dir}/${out_name}_siRNA.fa
        echo "obtain correlated genes"
	number=$(grep -w "${hit}" ${out_dir}/${out_name}_cor|wc -l)
        if [ $number -ne 0 ];then
        	awk -v name=${hit} 'BEGIN{FS=OFS="\t"}{if($1==name){print}}' ${out_dir}/${out_name}_cor |cut -f 2 - |sort|uniq|awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[toupper($1)]=$2}NR>FNR{if(A[toupper($1)]!=""){print $0,A[toupper($1)]}}' $(dirname $(readlink -f $0))/dataSets/GeneID.transfer -|awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$2]="yes"}NR>FNR{split($1,a,".");if(A[a[1]]!=""){print $2}}' - ${GeneTrans} |awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="yes"}NR>FNR{if(A[$4]){print}}' - ${GeneLocation_bed}|sort -k 4 |awk 'BEGIN{FS=OFS="\t"}{if(A[$4]){split($4,a,"%%");$4=a[1]"%%"(a[2]+1)}else{$4=$4"%%"1};print $0}'|fastaFromBed -fi $(dirname $(readlink -f $0))/dataSets/hg38_chr.fa -bed - -fo ${out_dir}/${out_name}_gene.fa -name -split -s
        	formatdb -i ${out_dir}/${out_name}_gene.fa -p F -a  F -o T
        	blastn -task blastn-short -db ${out_dir}/${out_name}_gene.fa -query ${out_dir}/${out_name}_siRNA.fa -strand plus  -ungapped  -outfmt 10 -evalue 10 >>${out_dir}/${out_name}_blast
      fi
done
rm ${out_dir}/${out_name}_gene.fa
rm ${out_dir}/${out_name}_gene.fa.nin
rm ${out_dir}/${out_name}_gene.fa.nsd
rm ${out_dir}/${out_name}_gene.fa.nsi
rm ${out_dir}/${out_name}_siRNA.fa
rm ${out_dir}/${out_name}_cor
sed 's/,/\t/g' ${out_dir}/${out_name}_blast |awk 'BEGIN{FS=OFS="\t"}{if($4>10 && $3==100){print}}'|awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$2]=$1}NR>FNR{split($2,a,"%%");if(A[a[1]]!=""){print $0,A[a[1]]}}' ${GeneTrans} - |awk 'BEGIN{FS=OFS="\t"}NR==FNR{if(A[$2]){A[$2]=A[$2]";"$1}else{A[$2]=$1}}NR>FNR{split($13,a,".");if(A[a[1]]!=""){print $0,A[a[1]]}}' $(dirname $(readlink -f $0))/dataSets/GeneID.transfer -|awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]="yes"}NR>FNR{split($1,a,"%%");split($14,b,";");str="no";for(i in b){if(A[b[i]]!=""){str="yes"}};if(str=="yes"){print}}' ${GodenSets} - > ${out_dir}/${out_name}_output.txt
