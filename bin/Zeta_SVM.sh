while getopts i:o:n:p: OPT; do
  case ${OPT} in
    i) in_file=${OPTARG}
       ;;
    o) out_name=${OPTARG}
       ;;
    \?)
       printf "[Usage] `date '+%F %T'` -i <Input_File> -o <Output_Name>\n" >&2
       exit 1
  esac
done
# check parameter
if [ -z "${in_file}" -o -z "${out_name}" ]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-i=${in_file}\n-o=${out_name}\n"
    exit 1
fi
echo "obtain zeta for D"
Rscript obtainZeta_D_SVM.R ${in_file} Zseq_list.txt ${out_name}_Zeta_D.txt
echo "obtain zeta for I"
Rscript obtainZeta_I_SVM.R ${in_file} Zseq_list.txt ${out_name}_Zeta_I.txt
paste ${out_name}_Zeta_D.txt ${out_name}_Zeta_I.txt |awk 'BEGIN{FS=OFS="\t"}{if(NR==1){print "Gene",$0}else{print $1,$2,$4}}' >${out_name}_Zeta.txt
rm ${out_name}_Zeta_D.txt
rm ${out_name}_Zeta_I.txt
