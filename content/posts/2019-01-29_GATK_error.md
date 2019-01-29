+++
title = "Error report: two errors I encountered while running GATK VariantRecalibrator"
author = "Zhen Li"
date = 2019-01-29
+++

I was running GATK's VariantRecalibrator today with the following command and run into a couple of errors:

```bash
java -Xmx4g -jar ~/zhen/bin/GenomeAnalysisTK-3_8/GenomeAnalysisTK.jar \
 -T VariantRecalibrator \
 -R ${genomeRef}/hg38.fa \
 -input GSE81475_chr${PBS_ARRAYID}_output.sorted.vcf \
 -recalFile ${project}/GSE81475_chr${PBS_ARRAYID}_SNP_output.recal \
 -tranchesFile ${project}/GSE81475_chr${PBS_ARRAYID}_SNP_output.tranches \
 -nt 7 \
 -resource:hapmap,known=false,training=true,truth=true,prior=15.0 ${genomeRef}/hapmap_3.3.hg38.vcf \
 -resource:omni,known=false,training=true,truth=true,prior=12.0 ${genomeRef}/1000G_omni2.5.hg38.vcf \
 -resource:1000G,known=false,training=true,truth=false,prior=10.0 ${genomeRef}/1000G_phase1.snps.high_confidence.hg38.vcf \
 -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${genomeRef}/dbsnp_138.hg38.vcf \
 -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR -an DP -an InbreedingCoeff \
 -mode SNP \
```

The first error is this:

```
Exception in thread "main" java.lang.IllegalArgumentException: java.lang.AssertionError: SAM dictionaries are not the same: SAMSequenceRecord(name=chr2,length=242193529,dict_index=1,assembly=20) was found when SAMSequenceRecord(name=chr10,length=133797422,dict_index=1,assembly=null) was expected. at picard.vcf.SortVcf.collectFileReadersAndHeaders(SortVcf.java:127) at picard.vcf.SortVcf.doWork(SortVcf.java:96) at picard.cmdline.CommandLineProgram.instanceMain(CommandLineProgram.java:268) at picard.cmdline.PicardCommandLine.instanceMain(PicardCommandLine.java:98) at picard.cmdline.PicardCommandLine.main(PicardCommandLine.java:108) Caused by: java.lang.AssertionError: SAM dictionaries are not the same: SAMSequenceRecord(name=chr2,length=242193529,dict_index=1,assembly=20) was found when SAMSequenceRecord(name=chr10,length=133797422,dict_index=1,assembly=null) was expected. at htsjdk.samtools.SAMSequenceDictionary.assertSameDictionary(SAMSequenceDictionary.java:169) at picard.vcf.SortVcf.collectFileReadersAndHeaders(SortVcf.java:125) ... 4 more
```

Basically, it indicates that my version of the genome reference (hg38) which I downloaded from UCSC a couple months ago does not work with the .vcf files I downloaded from GATK. Specifically, the contigs in the files are not matching.

After some research, I solved the problem by running the following command on the vcf files:

```bash
java -jar ~/zhen/bin/GenomeAnalysisTK-3_8/picard.jar UpdateVcfSequenceDictionary \
    I=${genomeRef}/${filename}.vcf \
    O=${genomeRef}/${filename}.updated.vcf \
    SEQUENCE_DICTIONARY=${genomeRef}/hg38.dict \

java -jar ~/zhen/bin/GenomeAnalysisTK-3_8/picard.jar SortVcf \
    I=${genomeRef}/${filename}.updated.vcf \
    O=${genomeRef}/${filename}.sorted.vcf \
    SEQUENCE_DICTIONARY=${genomeRef}/hg38.dict
```

So, first, the vcf sequence dictionary has to be updated with the UpdateVcfSequencdDictionary function. Then, the contigs need to be sorted in the .vcf files by SortVcf command.

After sorting the vcf files, the original command proceeded but encountered a second error:

```
##### ERROR MESSAGE: Bad input: Found annotations with zero variance. They must be excluded before proceeding.
```

Upon inspecing the error report, I noticed two of the annotations (arguments used to run VariantRecalibrator), -MQ and -MQRankSum had ```standard deviation - 0.00``` as follows:

```
INFO  14:06:50,480 VariantDataManager - MQ:      mean = 60.00    standard deviation = 0.00
```
And they were caused by constant mapping quality (MQ) score (possibly an error in earlier process which I will try to figure out later). So I removed those annotations and the program completed successfully!

Here is the final command I used:

```bash
java -Xmx4g -jar ~/zhen/bin/GenomeAnalysisTK-3_8/GenomeAnalysisTK.jar \
 -T VariantRecalibrator \
 -R ${genomeRef}/hg38.fa \
 -input GSE81475_chr${PBS_ARRAYID}_output.sorted.vcf \
 -recalFile ${project}/GSE81475_chr${PBS_ARRAYID}_SNP_output.recal \
 -tranchesFile ${project}/GSE81475_chr${PBS_ARRAYID}_SNP_output.tranches \
 -nt 7 \
 -resource:hapmap,known=false,training=true,truth=true,prior=15.0 ${genomeRef}/hapmap_3.3.hg38.sorted.vcf \
 -resource:omni,known=false,training=true,truth=true,prior=12.0 ${genomeRef}/1000G_omni2.5.hg38.sorted.vcf \
 -resource:1000G,known=false,training=true,truth=false,prior=10.0 ${genomeRef}/1000G_phase1.snps.high_confidence.hg38.sorted.vcf \
 -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${genomeRef}/dbsnp_138.hg38.sorted.vcf \
 -an QD -an ReadPosRankSum -an FS -an SOR -an DP -an InbreedingCoeff \
 -mode SNP \
```
