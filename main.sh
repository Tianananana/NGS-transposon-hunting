set -e
SCRIPT_DIR=$(dirname $(realpath $0))
BASE_DIR=$(dirname $SCRIPT_DIR)
cd $BASE_DIR

########################
# 1. Quality Control ###
########################
fastqc data/*.fq -o fastqc
for file in fastqc/*.zip;
    do
    unzip $file -d fastqc
    done
cat fastqc/*/summary.txt > fastqc/main_summary.txt
grep "FAIL" fastqc/main_summary.txt 
# check that theres no FAILS in fastqc.
# adaptor content passed. Trimming not needed.



###################################
# 2a. Initial Alignment: Ty5_6p ###
###################################
SRR=dnaseq
fq1=DNAseq/${SRR}_1.fq
fq2=DNAseq/${SRR}_2.fq
ty5_6p=genome/ty5_6p_genome/ty5_6p.fa

export BOWTIE2_INDEXES=${BASE_DIR}/genome/ty5_6p_genome/ty5_6p.fa
bowtie2-build $ty5_6p genome/ty5_6p_genome/ty5_6p

sam1=results/align1/align1.sam
bam1=results/align1/align1.bam
sorted_bam1=results/align1/align1-sorted.bam

bowtie2 -x ty5_6p --very-fast -p 4 -1 ${fq1} -2 ${fq2} -S ${sam1}
samtools view -S -b ${sam1} > ${bam1}
samtools sort -o ${sorted_bam1} ${bam1}
samtools index ${sorted_bam1}

##########################################
# 2b. Filter Reads with Unmapped Mates ###
##########################################
filterbyname=bbmap/filterbyname.sh # BBMap (v38.90)
filtered_sam=results/filtered/filtered_sam.sam
filtered_names=results/filtered/filtered_names.txt
filtered_1=results/filtered/filtered_1.fq
filtered_2=results/filtered/filtered_2.fq

## extracting QNAME from FLAG tags with mate unmapped
awk '$2==73 || $2==89 || $2==137 || $2==153' ${sam1} > ${filtered_sam}

#extract QNAMEs into seperate text file
awk '{print $1}' ${filtered_sam} > ${filtered_names}
## filter raw reads based on the QNAME extracted in ${filtered_names} 
${filterbyname} in=${fq1} in2=${fq2} out=${filtered_1} out2=${filtered_2} names=${filtered_names} include=t prefix=t ow=t


###################################
# 2c. Final Alignment: SacCer3 ###
###################################
sacCer3=genome/sacCer3_genome/sacCer3.fa

export BOWTIE2_INDEXES=${BASE_DIR}/genome/sacCer3_genome/sacCer3.fa
bowtie2-build $sacCer3 genome/sacCer3_genome/sacCer3

sam2=results/align2/align2.sam
bam2=results/align2/align2.bam
sorted_bam2=results/align2/align2-sorted.bam

bowtie2 -x sacCer3 --very-fast -p 4 -1 ${filtered_1} -2 ${filtered_2} -S ${sam2}
samtools view -S -b ${sam2} > ${bam2}
samtools sort -o ${sorted_bam2} ${bam2}
samtools index ${sorted_bam2}

########################
### 3. Visualisation ###
########################
## Visualisation on Ty5_6p transposon:

## Extract subset of reads with unmapped mates
unmapped_bam=results/align1/unmapped.bam
unmapped_bam-sorted=results/align1/unmapped-sorted.bam

samtools view -f 9 -b ${sam1} > ${unmapped_bam}
samtools sort ${unmapped_bam} > ${unmapped_bam-sorted}
samtools index ${unmapped_bam-sorted}

#---------------------------------------------------------------------------------------------------------

## Plot histogram for potential insertion sites:

## count frequencies from each chromosome; identify those with high number of reads.
 for chr in 'chrIII' 'chrIV' 'chrIX' 'chrV' 'chrVII' 'chrXI';
     do
     grep -c "^${chr}" ${filtered_names}
     done

## POS column of filtered reads extracted from Chr III, IV, VII, and IX. Used to plot histogram in R.
for chr in 'chrIII' 'chrIV' 'chrVII' 'chrIX';
    do
    awk '$3==$chr' ${filtered_sam} | awk '{print $4}' > results/filter/${chr}.txt
    done

#----------------------------------------------------------------------------------------------------------

## Visualisation on SacCer3 Genome:

## filtering out the genes from annotations of SacCer
grep gene saccharomyces_cerevisiae.gff > saccharomyces_cerevisiae_gene.gff