#!/bin/bash
# command04.sh

# 1. StringTie를 사용하여 GTF 파일 병합
GUIDE_GTF=./data/chrX_data/genes/chrX.gtf
MERGELIST=./data/chrX_data/mergelist.txt
stringtie --merge -G ${GUIDE_GTF} -o ./result/stringtie_merged.gtf ${MERGELIST}

# 2. StringTie를 사용하여 발현량 재정량화
SAMPLES=("ERR188044" "ERR188257" "ERR188273" "ERR188428")
MERGED_GTF=./result/stringtie_merged.gtf

for SAMPLE in ${SAMPLES[@]}; do
    # 출력 디렉토리 생성
    mkdir -p ./data/ballgown/${SAMPLE}
    
    stringtie ./data/${SAMPLE}_chrX.bam \
              -G ${MERGED_GTF} \
              -e -B \
              -o ./data/ballgown/${SAMPLE}/${SAMPLE}_chrX.gtf
done

# 3. 상위 5개 발현 전사체 추출
for SAMPLE in ${SAMPLES[@]}; do
    INPUT_GTF=./data/ballgown/${SAMPLE}/${SAMPLE}_chrX.gtf
    OUTPUT_TSV=./result/${SAMPLE}_chrX.top5.tsv

    # GTF 파일을 처리하여 gene_id, gene_name, TPM 추출, TPM 기준으로 정렬 후 상위 5개 선택
    awk -F'\t' '$3 == "transcript" && /gene_name/ {
        gene_id="NA"; gene_name="NA"; tpm="NA";
        n=split($9, attrs, "; ");
        for(i=1; i<=n; i++){
            if(attrs[i] ~ /^gene_id/) { split(attrs[i], gid, " "); gsub(/"/,"",gid[2]); gene_id=gid[2]; }
            if(attrs[i] ~ /^gene_name/) { split(attrs[i], gn, " "); gsub(/"/,"",gn[2]); gene_name=gn[2]; }
            if(attrs[i] ~ /^TPM/) { split(attrs[i], t, " "); gsub(/"/,"",t[2]); tpm=t[2]; }
        }
        print gene_id "\t" gene_name "\t" tpm;
    }' ${INPUT_GTF} | sort -k3,3nr | head -n 5 > ${OUTPUT_TSV}
done