# NGS-transposon-hunting
Identification of transposon sites on yeast genome (S. cerevisiae) using DNAseq data.

Given paired-end sequencing data of a Ty5_6p inserted S. cerevisiae (Strain: S288C) clone SacCer3, we aim to identify mapped positions, orientation, and consequences of transposon insertion with next-generation sequencing tools. We first verified the quality of sequencing data. Next, we obtained read pairs which lie at the region of transposon insertion through alignment on Ty5_6p and filtering reads of interest with appropriate FLAG tags. The final insert positions were identified with a second alignment of filtered reads on SacCer3. Finally, the orientation, as well as potential biological effects of these insertions were investigated by visualisation on a genome browser.

![analysis workflow](https://user-images.githubusercontent.com/65380831/135720873-db80f6a7-6e2a-4f45-8281-2d580c2a8f72.png)

This is an individual project as part of NUS LSM3241: Genomic Data Analysis.
