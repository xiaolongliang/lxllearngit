#!/bin/bash
"""
E-mail: xlliang0409@gmail.com
sample information download from NCBI, we want get the RUN and BREED column, normally in col 1 and 10;
like in this web:https://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP066883&o=acc_s%3Aa;  download Metadata as sample infor
FASTQ are download from ENA database, enter into by BioProject and select fastq_ftp as Fq download list;
"""
#set parameters
FqList=$1  #filereport_read_run_PRJNA624020_tsv
SampleInforList=$2  #SraRunTable
workdir="/opt/synData/xlliang/Sheep_data/resequence/2020NC_248indiv_WGS_sheep"
sed -i '1d' $FqList

echo "================How to run?================="
echo "sh download.sh filereport_read_run_PRJNA624020_tsv SraRunTable"

echo "==========create FASTQ directory============"
if [ ! -d "${workdir}/FASTQ" ];then
        mkdir ${workdir}/FASTQ
else
        break
fi

echo "==========generate the download list file============"
cat $FqList | awk '{print $2}' - | tr -s ';' '\n' | while read line
do
        fq=${line##*/}
        echo "wget -c -t 0 -O ${workdir}/FASTQ/${fq} ${line}" >> download.run.sh
done

echo "==========Parallel computing by ParaFly=============="
source ~/miniconda3/bin/activate
echo "ParaFly -c download.run.sh -CPU 20" > ParaFly.run.sh
nohup sh ParaFly.run.sh > ParaFly.log 2>&1 & 

echo "========== Create folder and Generalize files into specific folders ============"
awk -F "," '{print $1"\t"$10}' $2 | sed -r 's/(.*).*\(.*/\1/g' | sed '1d' | while read srr specie
do
        specie=${specie/ /_}
        if [ ! -d "${workdir}/FASTQ/${specie}" ];then
                mkdir ${workdir}/FASTQ/$specie
        fi
        mv ${workdir}/FASTQ/${srr}* ${workdir}/FASTQ/$specie
done
