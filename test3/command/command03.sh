#!/bin/bash
# command03.sh

# 가이드 GTF 파일 경로
GUIDE_GTF=./data/chrX_data/genes/chrX.gtf

# 샘플 목록
SAMPLES=("ERR188044" "ERR188257" "ERR188273" "ERR188428")

# 각 BAM 파일에 대해 StringTie 실행
for SAMPLE in ${SAMPLES[@]}; do
    stringtie ./data/${SAMPLE}_chrX.bam \
              -G ${GUIDE_GTF} \
              -o ./result/${SAMPLE}_chrX.gtf
done