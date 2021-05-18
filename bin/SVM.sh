#input positive and negative matrix_EC_D and matrix_EC_I
while getopts i:a:b:c:d:o:z:t: OPT; do
  case ${OPT} in
    i) input_dir=${OPTARG}
       ;;
    a) in_file_D_positive=${OPTARG}
       ;;
    b) in_file_D_negative=${OPTARG}
       ;;
    c) in_file_I_positive=${OPTARG}
       ;;
    d) in_file_I_negative=${OPTARG}
       ;;
    o) output_name=${OPTARG}
      ;;
    z) zrange=${OPTARG}
      ;;
    t) output_dir=${OPTARG}
      ;;
    \?)
       printf "[Usage] `date '+%F %T'` -i <input_dir> -a <Input_File_D_Positive> -b <in_file_D_negative> -c <in_file_I_positive> -d <in_file_I_negative> -o <output_name> -z <Zscore_range> -t <Output_dir>\n" >&2
       exit 1
  esac
done
# check parameter
if [ -z "${input_dir}" -o -z "${in_file_D_positive}" -o -z "${in_file_D_negative}" -o -z "${in_file_I_positive}"  -o -z "${in_file_I_negative}" -o -z "${output_name}" -o -z "${zrange}" -o -z "${output_dir}" ]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-i=${input_dir}\n-a=${in_file_D_positive}\n-b=${in_file_D_negative}\n-c=${in_file_I_positive}\n-d=${in_file_I_negative}\n-o=${output_name}\n-z=${zrange}\n-t=${output_dir}\n"
    exit 1
fi

Rscript $(dirname $(readlink -f $0))/meltdata.R ${input_dir}/${in_file_D_negative} ${input_dir}/${in_file_D_positive} ${input_dir}/${in_file_I_negative} ${input_dir}/${in_file_I_positive} ${output_dir}/${output_name}
Rscript $(dirname $(readlink -f $0))/svmClassifier.R ${output_dir}/${output_name}_SVMInput_D ${output_dir}/${output_name}_SVMInput_I ${output_dir}/${output_name}
sh $(dirname $(readlink -f $0))/FindSVMcurve.sh -d ${output_dir}/${output_name}_svm_line_D.txt -i ${output_dir}/${output_name}_svm_line_I.txt -z ${input_dir}/${zrange} -o ${output_dir}/${output_name}
