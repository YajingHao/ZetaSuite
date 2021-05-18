while getopts b:h:i:o:c: OPT; do
  case ${OPT} in
    b) out_dir=${OPTARG}
       ;;
    i) in_file=${OPTARG}
       ;;
    h) hits_file=${OPTARG}
       ;;
    o) out_name=${OPTARG}
       ;;
    c) consensus_score_cutoff=${OPTARG}
       ;;
    \?)
       printf "[Usage] `date '+%F %T'`-b <output_dir> -h <hits_file> -i <Input_File> -o <Output_Name> -c <consensus_score_cutoff>\n" >&2
       exit 1
  esac
done
# check parameter
if [ -z "${out_dir}" -o -z "${in_file}" -o -z "${hits_file}" -o -z "${out_name}" -o -z "${consensus_score_cutoff}" ]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-b=${out_dir}\n-i=${in_file}\n-h=${hits_file}\n-o=${out_name}\n-c=${consensus_score_cutoff}\n"
    exit 1
fi
awk 'BEGIN{FS=OFS="\t"}NR==FNR{if(NR>1){A[$1]="yes"}}NR>FNR{if(FNR==1 || A[$1]!=""){print}}' ${hits_file} ${in_file} |sort|uniq > ${out_dir}/${out_name}_inputMatrix
Rscript $(dirname $(readlink -f $0))/SC3_cluster_combine.R  ${out_dir}/${out_name}_inputMatrix ${out_dir}/${out_name}_consensus_matrix.txt ${out_dir}/${out_name}_cluster.pdf ${out_dir}/${out_name}_cluster.txt
echo "args 1: consensus.matrix 2: cut-off value 3: edge.txt 4:Zscore.matrix 5:correlation.txt"
Rscript $(dirname $(readlink -f $0))/constructNetwork.R ${out_dir}/${out_name}_consensus_matrix.txt ${consensus_score_cutoff} ${out_dir}/${out_name}_edge.txt ${out_dir}/${out_name}_inputMatrix ${out_dir}/${out_name}_cor.txt
awk 'BEGIN{FS=OFS="\t"}{if(A[$1$2]=="" && A[$2$1]=="" && $1!=$2){print;A[$1$2]="yes";A[$2$1]="yes"}}' ${out_dir}/${out_name}_edge.txt|awk 'BEGIN{FS=OFS="\t"}NR==FNR{if($3<0){A[$1$2]="negative";A[$2$1]="negative"}else{A[$1$2]="positive";A[$2$1]="positive"}}NR>FNR{print $0,A[$1$2]}' ${out_dir}/${out_name}_cor.txt - |sed '1i source\ttarget\tweight\tcorType'| sed 's/\t/,/g' >${out_dir}/${out_name}_Edges_filter.csv
awk 'BEGIN{FS=OFS="\t"}NR==FNR{A[$1]=$4}NR>FNR{if(FNR==1){print $1,$0,"Cluster"}else{print $1,$0,A[$1]}}' ${out_dir}/${out_name}_cluster.txt ${hits_file} |sed 's/\t/,/g' > ${out_dir}/${out_name}_Network_node.csv
