configfile: "config.json"

SAMPLES, = glob_wildcards(config['haplotype_folder']+"/{id}.fa")

rule all:
    input:
         config['output_dir']+"/rooted_tree.txt"

#Concatenate haplotypes and oldest sample consensus
rule concatenate:
    input:
        haplotypes = expand("{prefix}/{samples}.fa", prefix=config['haplotype_folder'], samples=SAMPLES)
    output:
        config['output_dir']+"/concatenated.fa"
    shell: 
        "cat {config[oldest_consensus]} > {output} ;"
        "cat {input.haplotypes} | sed '$ s/.$//' >> {output}"

#Dealign sequences
rule dealign:
    input:
        config['output_dir']+"/concatenated.fa"
    output:
        config['output_dir']+"/dealigned.fa"
    shell:
        "seqkit seq -g {input} > {output}" 

#Align sequences
rule align:
    input:
        config['output_dir']+"/dealigned.fa"
    output:
        config['output_dir']+"/aligned.fa"
    shell:
        """
        mafft --globalpair --maxiterate 500 {input} > {output}
        """

#Create phylip file
rule phylip:
    input:
         config['output_dir']+"/aligned.fa"
    output:
        config['output_dir']+"/aligned.fa.phylip"
    shell:
        "python fasta2phylip.py -i {input} -r"

#Create phylogenetic tree with PhyML
rule phyml:
    input:
        config['output_dir']+"/aligned.fa.phylip"
    output:
        config['output_dir']+"/aligned.fa.phylip_phyml_tree.txt"
    shell:
        "phyml -i {input} -b 100 --n_rand_starts 5 --quiet --no_memory_check --leave_duplicates"

#Root the tree
rule root:
    input:
        config['output_dir']+"/aligned.fa.phylip_phyml_tree.txt",
    output:
        config['output_dir']+"/rooted_tree.txt"
    script:
        "RootTree.R"
