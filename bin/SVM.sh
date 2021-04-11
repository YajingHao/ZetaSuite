#input positive and negative matrix_EC_D and matrix_EC_I
while getopts a:b:c:d:o: OPT; do
  case ${OPT} in
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
    \?)
       printf "[Usage] `date '+%F %T'` -a <Input_File_D_Positive> -b <in_file_D_negative> -c <in_file_I_positive> -d <in_file_I_negative> -o <output_name>\n" >&2
       exit 1
  esac
done
# check parameter
if [ -z "${in_file_D_positive}" -o -z "${in_file_D_negative}" -o -z "${in_file_I_positive}"  -o -z "${in_file_I_negative}" -o -z "${output_name}"]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-a=${in_file_D_positive}\n-b=${in_file_D_negative}\n-c=${in_file_I_positive}\n-d=${in_file_I_negative}\n-o=${output_name}\n"
    exit 1
fi
Rscript meltdata.R ${in_file_D_negative} ${in_file_D_positive} ${in_file_I_negative} ${in_file_I_positive}
Rscript svmClassifier.R SVMInput_D SVMInput_I ${output_name}
sh FindSVMcurve.sh
