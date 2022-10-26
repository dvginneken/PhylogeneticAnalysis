# Phylogenetic Analysis
A pipeline for phylogenetic analysis of haplotypes from each of the methods using PhyML[1].

### How to run this pipeline
Create and activate the conda environment:  
`conda env create -f environment.yaml`  
`conda activate phylo-analysis`  

Run the script for each patient and method separately:  
`snakemake -c8 --config haplotype_folder=[directory with haplotype fasta files] oldest_consensus=[fasta file outgroup sequence] output_dir=[output] --`

[1]: Guindon S, Dufayard JF, Lefort V, et al. “New Algorithms and Methods to Estimate
Maximum-Likelihood Phylogenies: Assessing the Performance of PhyML 3.0”. In: Systematic
Biology 59.3 (2010). doi:10.1093/nar/gki352, pp. 307–21.
