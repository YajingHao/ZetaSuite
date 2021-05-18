while getopts a:i:o:b:l:s:z: OPT; do
  case ${OPT} in
    a) input_dir=${OPTARG}
       ;;
    i) in_file=${OPTARG}
       ;;
    o) out_name=${OPTARG}
       ;;
    b) out_dir=${OPTARG}
       ;;
    l) SVM_line_D=${OPTARG}
       ;;
    s) SVM_line_I=${OPTARG}
       ;;
    z) zrange=${OPTARG}
      ;;
    \?)
       printf "[Usage] `date '+%F %T'`-a <Input_dir> -i <Input_File> -o <Output_Name> -b <Output_dir> -l <SVM_line_D> -s <SVM_line_I> -z <Zscore_range>\n" >&2
       exit 1
  esac
done
# check parameter
if [ -z "${input_dir}" -o -z "${in_file}" -o -z "${out_name}" -o -z "${out_dir}" -o -z "${SVM_line_D}" -o -z "${SVM_line_I}" -o -z "${zrange}" ]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-a=${input_dir}\n-i=${in_file}\n-o=${out_name}\n-b=${out_dir}\n-l=${SVM_line_D}\n-s=${SVM_line_I}\n-z=${zrange}\n"
    exit 1
fi
echo "preprocessing"
echo "obtain zeta for D"
cp ${zrange} Zseq_list.txt
cp ${input_dir}/${SVM_line_D} svm_line_D.txt
Rscript $(dirname $(readlink -f $0))/obtainZeta_D_SVM.R ${in_file} ${out_dir}/${out_name}_Zeta_D.txt
echo "obtain zeta for I"
cp ${input_dir}/${SVM_line_I} svm_line_I.txt
Rscript $(dirname $(readlink -f $0))/obtainZeta_I_SVM.R ${in_file} ${out_dir}/${out_name}_Zeta_I.txt
paste ${out_dir}/${out_name}_Zeta_D.txt ${out_dir}/${out_name}_Zeta_I.txt |awk 'BEGIN{FS=OFS="\t"}{if(NR==1){print "Gene",$0}else{print $1,$2,$4}}' >${out_dir}/${out_name}_Zeta.txt
rm ${out_dir}/${out_name}_Zeta_D.txt
rm ${out_dir}/${out_name}_Zeta_I.txt
rm Zseq_list.txt
rm svm_line_D.txt
rm svm_line_I.txt
