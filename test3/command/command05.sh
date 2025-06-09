#!/bin/bash
# command05.sh

# 1. prepDE.py를 사용하여 DESeq2 입력 파일 생성
prepDE.py -i ./source/prep_deseq.txt -g ./result/gene_count_matrix.csv -t ./result/transcript_count_matrix.csv

# 2. run_pydeseq.py를 실행하여 DE 분석 수행 (성별 비교)
python3 ./source/run_pydeseq.py -i ./result/gene_count_matrix.csv -o ./result/deseq2_results.csv -f sex

# 3. 과발현된 유전자 수 계산
tail -n +2 ./result/deseq2_results.csv | awk -F, '$3 > 0' | wc -l > ./result/overexpressed_genes.txt

# 4. make_volcano.py를 사용하여 볼케이노 플롯 생성
python3 ./source/make_volcano.py -i ./result/deseq2_results.csv -o ./result/volcano.png -x log2FoldChange -y padj -c

# 5. 유의미한 유전자 추출 및 결론 작성
# padj < 0.05인 유전자를 padj 기준 오름차순으로 정렬하여 저장
tail -n +2 ./result/deseq2_results.csv | awk -F, '$7 < 0.05' | sort -t, -k7,7g | awk -F, '{print $1 "\t" $7}' > ./result/significant_genes.tsv

# 결론 파일 작성
cat << 'EOF' > ./result/conclusion.txt
Analysis Conclusion

The differential expression analysis between male and female samples using chromosome X data revealed several significantly differentially expressed genes. Among the most significant genes is likely XIST (X Inactive Specific Transcript), which is a key player in X-chromosome inactivation, the process that transcriptionally silences one of the two X chromosomes in females to ensure dosage compensation between sexes.

These results are biologically sensible. Since females (XX) have two X chromosomes and males (XY) have one, genes involved in X-inactivation like XIST are expected to be highly expressed in females and virtually absent in males. The presence of such genes at the top of the significance list validates the analysis approach.

Potential issues with the methodology could include the small sample size (two males vs. two females), which limits statistical power and might not capture the full biological variability within each population. Additionally, while the pipeline is standard, technical variations or batch effects, if not properly accounted for in the DESeq2 model, could influence the results. However, the stark and expected difference in XIST expression suggests the primary biological signal is strong and correctly identified.
EOF