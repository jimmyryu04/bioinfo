#!/bin/bash
# command02.sh

# 샘플 목록
SAMPLES=("ERR188044" "ERR188257" "ERR188273" "ERR188428")

# 각 샘플에 대해 samtools sort 실행
for SAMPLE in ${SAMPLES[@]}; do
    samtools sort -@ 8 -o ./data/${SAMPLE}_chrX.bam ./data/${SAMPLE}_chrX.sam
done