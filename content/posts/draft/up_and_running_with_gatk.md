+++
title = "Up and running with GATK"
author = "Zhen Li"
date = 2018-12-12
+++

What do we need?
1) Reference genome: hg38.fa
2) gatk
3) samtools

```
gatk --java-options "-Xmx8G" CreateSequenceDictionary -R hg38.fa -O hg38.dict
```

```
samtools faidx hg38.fa
```

Download GATK from <a href=""> this link <a>

```
gatk --java-options "-Xmx8G" AddOrReplaceReadGroups -I Aligned.out.sam -O rg_added_sorted.bam -SO coordinate -ID test -LB library -PL Illumina -PU 2000 -SM BrainSpan
```

```
gatk --java-options "-Xmx8G" MarkDuplicates -I rg_added_sorted.bam -O dedupped.bam  --CREATE_INDEX true --VALIDATION_STRINGENCY SILENT -M output.metrics
```

```
gatk --java-options "-Xmx8G" SplitNCigarReads -R ~/zhen/Reference_genome/hg38/hg38.fa -I dedupped.bam -O split.bam
```

```
gatk --java-options "-Xmx8G" HaplotypeCaller -R ~/zhen/Reference_genome/hg38/hg38.fa -I split.bam --dont-use-soft-clipped-bases -stand-call-conf 20.0 -O split_output.vcf
```

```
input=dedupped
gatk --java-options "-Xmx8G" HaplotypeCaller -R ~/zhen/Reference_genome/hg38/hg38.fa -I dedupped.bam --dont-use-soft-clipped-bases -stand-call-conf 20.0 -O dedupped_output.vcf
```
