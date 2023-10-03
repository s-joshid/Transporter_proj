awk 'BEGIN{
    for (i = 0; i < 100000; i++)
        NR = expr 1 + $RANDOM % 149000000
        print NR
}' input.txt >> output.txt



awk 'BEGIN {RS = ">"}
{
    for(i = 0; i < 100; i++){
       ran_num = int(1.0 + rand() * 1999)
       NR = ran_num
        }
}' ./Transporter_proj/data/testSubsetReformatted.fasta >> ./RandomReformattedSubSet
--> could make this a multipart piped command 


cat ./Transporter_proj/data/testSubsetReformatted.fasta | \
awk '/^>/ { if(i>0) printf("\n"); i++; printf("%s\t",$0); next;} {printf("%s",$0);} END { printf("\n");}' |\
shuf |\
head -n 100 |\
awk 'BEGIN{FS="\t"}{printf("%s\n%s\n",$1,$2)}' >> Reformatted.fasta