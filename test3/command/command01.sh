#!/bin/bash
# command01.sh

# 1. 데이터 다운로드 및 압축 해제
wget https://hulk.mmseqs.com/introbioinfo/chrX_data.tar.gz -O ./data/chrX_data.tar.gz
tar -xzvf ./data/chrX_data.tar.gz -C ./data

# 2. HISAT2를 사용하여 리드 매핑
# HISAT2 인덱스 경로 변수 설정
HISAT2_INDEX=./data/chrX_data/indexes/chrX_tran

# 샘플 목록
SAMPLES=("ERR188044" "ERR188257" "ERR188273" "ERR188428")

# 각 샘플에 대해 HISAT2 실행
for SAMPLE in ${SAMPLES[@]}; do
    hisat2 -x ${HISAT2_INDEX} \
           -1 ./data/chrX_data/samples/${SAMPLE}_chrX_1.fastq.gz \
           -2 ./data/chrX_data/samples/${SAMPLE}_chrX_2.fastq.gz \
           -S ./data/${SAMPLE}_chrX.sam
done