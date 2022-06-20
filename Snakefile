configfile: "config.json"

SAMPLES, = glob_wildcards(config['haplotype_folder']+"/{id}.fa")

rule all:
    input:
         config['output_dir']+"/rooted_tree.txt"

rule concatenate:
    input:
        haplotypes = expand("{prefix}/{samples}.fa", prefix=config['haplotype_folder'], samples=SAMPLES)
    output:
        config['output_dir']+"/concatenated.fa"
    shell: 
        "cat {config[oldest_consensus]} > {output} ;"
        "cat {input.haplotypes} | sed '$ s/.$//' >> {output}"

rule dealign:
    input:
        config['output_dir']+"/concatenated.fa"
    output:
        config['output_dir']+"/dealigned.fa"
    shell:
        "seqkit seq -g {input} > {output}" 

rule align:
    input:
        config['output_dir']+"/concatenated.fa"
    output:
        config['output_dir']+"/aligned.fa"
    shell:
        """
        clustalo -i {input} --profile1 /hpc/dla_lti/dvanginneken/HaploHIV_Daphne/haplohiv4/reference_sequences/CONSENSUS_B.fa \
         --full --full-iter -o {config[output_dir]}/aligned_incl.fa --output-order=input-order --iter=50;
        seqkit grep -n -v -p "CONSENSUS_B" {config[output_dir]}/aligned_incl.fa -o {output}
        """

rule phylip:
    input:
         config['output_dir']+"/aligned.fa"
    output:
        config['output_dir']+"/aligned.fa.phylip"
    shell:
        "python fasta2phylip.py -i {input} -r"

rule phyml:
    input:
        config['output_dir']+"/aligned.fa.phylip"
    output:
        config['output_dir']+"/aligned.fa.phylip_phyml_tree.txt"
    shell:
        "phyml -i {input} -b 100 --n_rand_starts 5 --quiet --no_memory_check --leave_duplicates"

rule root:
    input:
        config['output_dir']+"/aligned.fa.phylip_phyml_tree.txt",
    output:
        config['output_dir']+"/rooted_tree.txt"
    script:
        "RootTree.R"
