#curl ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/current/fasta/dmel-all-chromosome-r6.13.fasta.gz -o dmel-all-chromosome-r6.13.fasta.gz
#curl ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/current/gtf/dmel-all-r6.13.gtf.gz -o dmel-all-r6.13.gtf.gzl 



#module load jje/jjeutils
#module load jje/kent
#createProject ee282_final
#module load brew/git for the updated version of github on the cluster
#git status
#git remote add origin http://github.com/ramink100/ee282_Final.git
#git push -u origin master

faSize dmel-all-chromosome-r6.13.fasta > ~/repos/ee282_final/data/processed/summary

infile=~/repos/ee282_final/data/raw/dmel-all-chromosome-r6.13.fasta
outname=~/repos/ee282_final/data/processed/dmelrel6_filtered.fa
faFilter -maxSize=100000 $infile /dev/stdout \
| tee $outname.fa \
| faSize -detailed /dev/stdin \
| sort -rnk 2,2 \
> $outname.sizes

outname=~/repos/ee282_final/data/processed/dmelrel6_min1000000
faFilter -minSize=100000 $infile /dev/stdout \
| tee $outname.fa \
| faSize -detailed /dev/stdin \
| sort -rnk 2,2 \
> $outname.sizes

faSize dmelrel6_min100000.fa > ~/repos/ee282_final/data/processed/summarymin100000

faSize dmelrel6_filtered.fa > ~/repos/ee282_final/data/processed/summarymax100000

bioawk -c fastx '{print ">"$name, gc($seq)}' raw/dmel-all-chromosome-r6.13.fasta > processed/dmelrel6_gc

infile=~/repos/ee282_final/data/raw/dmel-all-chromosome-r6.13.fasta
outname=~/repos/ee282_final/data/processed/dmelrel6_size
faSize -detailed $infile |sort -rnk 2,2 > $outname

bioawk -c gff '{print $seqname }' dmel-all-r6.13.gtf.gz | sort | uniq -c | sort -rnk 1,1 > ~/repos/ee282_final/data/processed/dmelallr6_features

bioawk -c gff ' $feature =="gene" { print $seqname }' ~/repos/ee282_final/data/raw/dmel-all-r6.13.gtf.gz | sort | uniq -c | sort -rnk 1,1 > ~/repos/ee282_final/data/processed/dmelallr6_genes_chrom

bioawk -c gff ' $feature =="mRNA" { print $group }' ~/repos/ee282_final/data/raw/dmel-all-r6.13.gtf.gz | perl -F"\t" -lane ' $F[0] =~ /gene_id "(FBgn\d{7})"/; print $1; ' | sort | uniq -c | less | awk ' { print $1 } ' | bioawk -c gff ' $feature =="mRNA" { print $group }' ~/repos/ee282_final/data/raw/dmel-all-r6.13.gtf.gz | perl -F"\t" -lane ' $F[0] =~ /gene_id "(FBgn\d{7})"/; print $1; ' | sort | uniq -c | awk ' { print $1 } ' | sort | uniq -c | sort -nk 2,2 > processed/dmelallr6_transcripts

#Graphing in R:
#I downloaded the files from the cluster to my computer using WinSCP.
#library(ggplot2)
#small<-read.table("dmelrel6_filtered.sizes")
#big<-read.table("dmelrel6_min100000.sizes")
#pdf("smalldistribution.pdf")
#ggsmall <-ggplot(data =small)
#ggsmall +geom_histogram(mapping = aes(x=V2), bins =100)
#dev.off()
#pdf("bigdistribution.pdf")
#ggbig <-ggplot(data=big)
#ggbig +geom_histogram(mapping = aes(x=V2), bins =100)
#dev.off()

#gc<-read.table("dmelrel6_gc")
#pdf("gcdistribution.pdf")
#gggc <-ggplot(data =gc)
#gggc +geom_histogram(mapping = aes(x=V2), bins =100)
#dev.off()

#size<-read.table("dmelrel6_size")
#pdf("genomesize.pdf")
#ggplot(size, aes(x=1:1870, y=cumsum(V2))) + geom_line()
#dev.off()

#transcripts<-read.table("dmelallr6_transcripts")
#pdf("transcripts.pdf")
#ggplot(data = transcripts, aes(x = V2, y = V1)) + geom_bar(stat="identity")
#dev.off()

#gene<-read.table("dmelallr6_genelength")
#pdf("genelengths.pdf")
#ggplot(gene, aes(x=V1)) + 
#    geom_histogram(binwidth=1000) + ylim(0,250)
#dev.off()

#exon<-read.table("dmelallr6_exonlength")
#pdf("exonlengths.pdf")
#ggplot(exon, aes(x=V1)) + 
#    geom_histogram(binwidth=10) + ylim(0,300)
#dev.off()
