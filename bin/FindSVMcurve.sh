while getopts d:i:o:z: OPT; do
  case ${OPT} in
    d) in_file_SVMline_D=${OPTARG}
       ;;
    i) in_file_SVMline_I=${OPTARG}
       ;;
    o) output_name=${OPTARG}
       ;;
    z) zrange=${OPTARG}
      ;;
    \?)
       printf "[Usage] `date '+%F %T'` -d <in_file_SVMline_D> -i <in_file_SVMline_I> -o <output_name> -z <Zscore_range>\n" >&2
       exit 1
  esac
done
# check parameter
if [ -z "${in_file_SVMline_D}" -o -z "${in_file_SVMline_I}" -o -z "${output_name}" -o -z "${zrange}" ]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-d=${in_file_SVMline_D}\n-i=${in_file_SVMline_I}\n-o=${output_name}\n-z=${zrange}\n"
    exit 1
fi

:>${output_name}_SVM_lineCutOff_I
length=$(awk 'BEGIN{FS=OFS="\t"}{sum=sum+1}END{print sum}' ${zrange})
for numberseq in $(seq 2 1 ${length});do
	echo ${numberseq}
	number=$(sed -n "${numberseq},${numberseq}p" ${zrange}|cut -f 2)
	sed 's/"//g' ${in_file_SVMline_I}|awk -v num=${number} 'BEGIN{FS=OFS="\t"}{if(($2-num)<=0.00000001 && ($2-num)>=(-0.00000001)){print}}' |sort -k 3 -n -r |awk 'BEGIN{FS=OFS="\t"}{if($4=="Negative"){print $2,$3}}' |head -1 >>${output_name}_SVM_lineCutOff_I
done
:>${output_name}_SVM_lineCutOff_D
for numberseq in $(seq 2 1 ${length});do
	number=$(sed -n "${numberseq},${numberseq}p" ${zrange}|cut -f 1)
        sed 's/"//g' ${in_file_SVMline_D}|awk -v num=${number} 'BEGIN{FS=OFS="\t"}{if(($2-num)<=0.00000001 && ($2-num)>=(-0.00000001)){print}}' |sort -k 3 -n -r |awk 'BEGIN{FS=OFS="\t"}{if($4=="Negative"){print $2,$3}}' |head -1 >>${output_name}_SVM_lineCutOff_D
done 

