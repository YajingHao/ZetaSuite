while getopts a:b:i:o:n:f: OPT; do
  case ${OPT} in
    a) in_dir=${OPTARG}
       ;;
    b) out_dir=${OPTARG}
       ;;
    i) in_file=${OPTARG}
       ;;
    o) out_name=${OPTARG}
       ;;
    n) binNum=${OPTARG}
       ;;
    f) filter=${OPTARG}
       ;; 
   \?)
       printf "[Usage] `date '+%F %T'`-a <Input_dir> -b <output_dir> -i <Input_File> -o <Output_Name> -n <Bin_Number> -f <filter>\n" >&2
       exit 1
  esac
done
# check parameter
if [ -z "${in_dir}" -o -z "${out_dir}" -o -z "${in_file}" -o -z "${out_name}" -o -z "${binNum}" -o -z "${filter}" ]; then
    printf "[ERROR] `date '+%F %T'` following parameters is empty:\n-a=${in_dir}\n-b=${out_dir}\n-i=${in_file}\n-o=${out_name}\n-n=${binNum}\n-f=${filter}\n"
    exit 1
fi
# make sure rows are individual cells and columns are individual genes
# remove cell counts < 100 read counts
mkdir ${out_dir}
awk 'BEGIN{FS=OFS="\t"}{if(NR>1){sum=0;for(i=2;i<=NF;i++){sum=sum+$i};print $1,sum}}' ${in_dir}/${in_file} > ${out_dir}/${out_name}_nCount
awk 'BEGIN{FS=OFS="\t"}NR==FNR{if($2>100){A[$1]="yes"}}NR>FNR{if(FNR==1 || A[$1]!=""){print}}' ${out_dir}/${out_name}_nCount ${in_dir}/${in_file} > ${out_dir}/${out_name}_matrix
if [ ${filter} = "no" ]
then
	cp ${in_dir}/${in_file} ${out_dir}/${out_name}_matrix
fi
#obtain Zrange
Rscript $(dirname $(readlink -f $0))/obtain_ZRange_SC.R ${out_dir}/${out_name}_matrix ${binNum} ${out_dir}/${out_name}_ZRange
#obtain ZetaScore
cut -f 1 ${out_dir}/${out_name}_matrix > ${out_dir}/${out_name}_nFeatureDiffCutOff
for value in $(awk 'BEGIN{FS=OFS="\t"}{if(NR>1){print $i}}' ${out_dir}/${out_name}_ZRange);do
       awk -v value=${value} 'BEGIN{FS=OFS="\t"}{if(NR>1){num=0;for(i=2;i<=NF;i++){if($i>value){num=num+1}}}else{num=value};print num}' ${out_dir}/${out_name}_matrix |paste ${out_dir}/${out_name}_nFeatureDiffCutOff - > ${out_dir}/${out_name}_temp
       mv ${out_dir}/${out_name}_temp ${out_dir}/${out_name}_nFeatureDiffCutOff
       echo ${value}
done
if [ ${binNum} -eq 10 ]
then
	binNum=9
fi
awk -v num=${binNum} 'BEGIN{FS=OFS="\t"}{if(NR==1){print $1,"Zeta"}else{sum=($2+$3)/2;for(i=3;i<=(num+1);i++){sum=sum+($i+$(i+1))/2;};printf $1"\t";printf ("%.2f\n",sum)}}' ${out_dir}/${out_name}_nFeatureDiffCutOff > ${out_dir}/${out_name}_Zeta
#check the cut-off for OutPut ZetaScore
Rscript $(dirname $(readlink -f $0))/FindCutOff_SC.R ${out_dir}/${out_name}_Zeta ${out_dir}/${out_name}_cutoff.pdf
rm ${out_dir}/${out_name}_nFeatureDiffCutOff
rm ${out_dir}/${out_name}_ZRange
rm ${out_dir}/${out_name}_matrix
rm ${out_dir}/${out_name}_nCount
