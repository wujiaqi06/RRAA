# RRAA
Reduced-Representation Admixture Analysis (RRAA) is a tool for evaluating how inbreeding within specific populations influences the stability of population structure inferred by Admixture, through random subsampling of individuals from the target population.
This software depends on vcftools and admixture software.
Please install vcftools by:
```
sudo apt-get install vcftools
```
And put admixture software in the same folder.

It can be run by:
Example code:
```
perl RRAA_pipeline.pl -i ChSNP474Asiax21656-ARS1-65K.vcf.gz -j ind2pop.txt -t pop.sample.info.txt -s 300 -k 4 -o Goat
```
This do random sampling of each sample (defined by pop.sample.info.txt) for 300 times, with admixture option k = 4.


