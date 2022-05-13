#Daphne van Ginneken 12-05-2022
#This script roots a tree on the outgroup

#load library
library(ape)
library(stringr)

#set variables
tree_file = snakemake@input[[1]]
consensus_file = snakemake@config[["oldest_consensus"]]

#read consensus name
firstline = readLines(consensus_file, n=1)
consensus_name = str_sub(firstline, 2, nchar(firstline))

#read tree
tree = ape::read.tree(tree_file)

#root tree based on outgroup
rooted_tree = ape::root(tree, outgroup = consensus_name, resolve.root=TRUE)

#remove outgroup
rooted_tree_removed = ape::drop.tip(rooted_tree, consensus_name)

#write new tree
write.tree(rooted_tree_removed, file=snakemake@output[[1]], digits = 6)
