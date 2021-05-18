while getopts a:b:i:o:z: OPT; do
  case ${OPT} in
    a) in_dir=${OPTARG}
       ;;
    b) out_dir=${OPTARG}
       ;;
    i) in_file=${OPTARG}
       ;;
    o) out_name=${OPTARG}
       ;;
    z) zrange=${OPTARG}
      ;;
    \?)
       printf "[Usage] `date '+%F %T'` -a <Input_dir> -b <output_dir> -i <Input_File> -o <Output_Name> -z <Zscore_range>\n" >&2
       exit 1
  esac
done
# check parameter
if [ -z "${in_dir}" -o -z "${out_dir}" -o -z "${in_file}" -o -z "${out_name}" -o -z "${zrange}" ]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-a=${in_dir}\n-b=${out_dir}\n-i=${in_file}\n-o=${out_name}\n-z=${zrange}\n"
    exit 1
fi
echo "obtain zeta for D"
cp ${zrange} Zseq_list.txt
Rscript $(dirname $(readlink -f $0))/obtainZeta_D.R ${in_dir}/${in_file}  ${out_dir}/${out_name}_Zeta_D.txt
echo "obtain zeta for I"
Rscript $(dirname $(readlink -f $0))/obtainZeta_I.R ${in_dir}/${in_file}  ${out_dir}/${out_name}_Zeta_I.txt
paste ${out_dir}/${out_name}_Zeta_D.txt ${out_dir}/${out_name}_Zeta_I.txt |awk 'BEGIN{FS=OFS="\t"}{if(NR==1){print "Gene",$0}else{print $1,$2,$4}}' >${out_dir}/${out_name}_Zeta.txt
rm ${out_dir}/${out_name}_Zeta_D.txt
rm ${out_dir}/${out_name}_Zeta_I.txt
rm Zseq_list.txt
