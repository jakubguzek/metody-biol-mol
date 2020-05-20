#!/usr/bin/env zsh

### script can be found on http://sulab.org/2013/06/sequenced-genomes-per-year/

### analyze GOLD

# download data file
set d = `date +%F`
mkdir data/GOLD
wget "http://www.genomesonline.org/documents/Export/gold.xls" -O data/GOLD/gold-$d.txt

# screenscrape completion data -- credit @ppgardne ...
# takes a long time -- do on byobu window
cat data/GOLD/gold-$d.txt | awk '{print "curl -s http://genomesonline.org/cgi-bin/GOLD/bin/GOLDCards.cgi?goldstamp="$1}' | sh | grep "COMPLETION DATE" | perl -lane 'if(/left>(\S+)<\/td>/){print $1}' >! results/_t1
paste data/GOLD/gold-2013-06-06.txt results/_t1 > results/gold-$d-plusdate.txt

# sort by date
sed 's/-.*//' results/_t1 | sort | uniq -c | sort -k2n > results/GOLD_by_year.txt

# kingdom analysis
gawk '{print $7}' data/GOLD/gold-2013-06-06.txt | sort | uniq -c | sort -k1nr

# kingdom analysis by year -- must have a COMPLETED DATE (col 24)
gawk '$7=="Bacteria"{print $24}' results/gold-2013-06-06-plusdate.txt | sed 's/-.*//' | sort | uniq -c | sort -k2n > results/gold-2013-06-06-plusdate_byyear_bacteria.txt
gawk '$7=="Bacteria"&&$24~/^[0-9-]+$/{print $6,$24,$13}' results/gold-2013-06-06-plusdate.txt | sort > results/_gold-2013-06-06-plusdate_bacteria
join -t"$TAB" -a1 results/_gold-2013-06-06-plusdate_bacteria results/_tax_to_category | sort -k4 -k2r -t"$TAB" | gawk '{print $4,$2,$3}' > results/_gold-2013-06-06-plusdate_bacteria_speciesID
gawk '{idx[$1]=$0}END{for (i in idx) {print idx[i]}}' results/_gold-2013-06-06-plusdate_bacteria_speciesID > results/_gold-2013-06-06-plusdate_bacteria_speciesID_early
gawk '{print $2}' results/_gold-2013-06-06-plusdate_bacteria_speciesID_early | sed 's/-.*//' | sort | uniq -c | sort -k2n > results/gold-2013-06-06-plusdate_bacteria_byyear_species.txt


gawk '$7=="Eukaryota"{print $24}' results/gold-2013-06-06-plusdate.txt | sed 's/-.*//' | sort | uniq -c | sort -k2n > results/gold-2013-06-06-plusdate_byyear_eukaryotes.txt
gawk '$7=="Eukaryota"&&$24~/^[0-9-]+$/{print $6,$24,$13}' results/gold-2013-06-06-plusdate.txt | sort > results/_gold-2013-06-06-plusdate_eukaryotes
join -t"$TAB" -a1 results/_gold-2013-06-06-plusdate_eukaryotes results/_tax_to_category | sort -k4 -k2r -t"$TAB" | gawk '{print $4,$2,$3}' > results/_gold-2013-06-06-plusdate_eukaryotes_speciesID
gawk '{idx[$1]=$0}END{for (i in idx) {print idx[i]}}' results/_gold-2013-06-06-plusdate_eukaryote_speciesID > results/_gold-2013-06-06-plusdate_eukaryotes_speciesID_early
gawk '{print $2}' results/_gold-2013-06-06-plusdate_eukaryotes_speciesID_early | sed 's/-.*//' | sort | uniq -c | sort -k2n > results/gold-2013-06-06-plusdate_eukaryotes_byyear_species.txt


gawk '$7=="Archaea"{print $24}' results/gold-2013-06-06-plusdate.txt | sed 's/-.*//' | sort | uniq -c | sort -k2n > results/gold-2013-06-06-plusdate_byyear_archaea.txt
gawk '$7=="Archaea"&&$24~/^[0-9-]+$/{print $6,$24,$13}' results/gold-2013-06-06-plusdate.txt | sort > results/_gold-2013-06-06-plusdate_archaea
join -t"$TAB" -a1 results/_gold-2013-06-06-plusdate_archaea results/_tax_to_category | sort -k4 -k2r -t"$TAB" | gawk '{print $4,$2,$3}' > results/_gold-2013-06-06-plusdate_archaea_speciesID
gawk '{idx[$1]=$0}END{for (i in idx) {print idx[i]}}' results/_gold-2013-06-06-plusdate_archaea_speciesID > results/_gold-2013-06-06-plusdate_archaea_speciesID_early
gawk '{print $2}' results/_gold-2013-06-06-plusdate_archaea_speciesID_early | sed 's/-.*//' | sort | uniq -c | sort -k2n > results/gold-2013-06-06-plusdate_archaea_byyear_species.txt



### analyze NCBI genomes

# download files
wget -r -l1 -nd --no-parent -P data/NCBI_genome_reports ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/

# analyze eukaryotes
# "Status" in col 19, "Release Date" in col 17
cat data/NCBI_genome_reports/eukaryotes.txt | gawk '$19=="Chromosomes"||$19=="Scaffolds or contigs"{print $17}' >! results/_NCBI_eukaryotes_years
cat data/NCBI_genome_reports/eukaryotes.txt | gawk '($19=="Chromosomes"||$19=="Scaffolds or contigs")&&$17!="-"{print $17,$2}' | sort -k2  >! results/_NCBI_eukaryotes_taxid
join -12 -21 -a1 -t"$TAB" results/_NCBI_eukaryotes_taxid results/_tax_to_category | sort -k3 -k2r >! results/_NCBI_eukaryotes_speciesID
gawk '{idx[$3]=$0}END{for (i in idx) {print idx[i]}}' results/_NCBI_eukaryotes_speciesID >! results/_NCBI_eukaryotes_speciesID_early
gawk '{print $2}' results/_NCBI_eukaryotes_speciesID_early | sed 's/\/.*//' | sort | uniq -c | sort -k2n >! results/NCBI_eukaryotes_by_year_species.txt

cat data/NCBI_genome_reports/eukaryotes.txt | gawk '$19=="Chromosomes"&&$17!="-"{print $17,$2}' | sort -k2  >! results/_NCBI_eukaryotes_taxid_chronly
join -12 -21 -a1 -t"$TAB" results/_NCBI_eukaryotes_taxid_chronly results/_tax_to_category | sort -k3 -k2r >! results/_NCBI_eukaryotes_speciesID_chronly
gawk '{idx[$3]=$0}END{for (i in idx) {print idx[i]}}' results/_NCBI_eukaryotes_speciesID_chronly >! results/_NCBI_eukaryotes_speciesID_early_chronly
gawk '{print $2}' results/_NCBI_eukaryotes_speciesID_early_chronly | sed 's/\/.*//' | sort | uniq -c | sort -k2n >! results/NCBI_eukaryotes_by_year_species_chronly.txt


# analyze prokaryotes
# "Status" in col 19, "Release Date" in col 17
cat data/NCBI_genome_reports/prokaryotes.txt | gawk '$19=="Complete"||$19=="Scaffolds or contigs"{print $17}' > results/_NCBI_prokaryotes_years
cat data/NCBI_genome_reports/prokaryotes.txt | gawk '($19=="Complete"||$19=="Scaffolds or contigs")&&$17!="-"{print $17,$2}' | sort -k2  >! results/_NCBI_prokaryotes_taxid
join -12 -21 -a1 -t"$TAB" results/_NCBI_prokaryotes_taxid results/_tax_to_category | sort -k3 -k2r > results/_NCBI_prokaryotes_speciesID
gawk '{idx[$3]=$0}END{for (i in idx) {print idx[i]}}' results/_NCBI_prokaryotes_speciesID > results/_NCBI_prokaryotes_speciesID_early
gawk '{print $2}' results/_NCBI_prokaryotes_speciesID_early | sed 's/\/.*//' | sort | uniq -c | sort -k2n > results/NCBI_prokaryotes_by_year_species.txt


# analyze viruses
# "Status" in col **15**, "Release Date" in col **13**
cat data/NCBI_genome_reports/viruses.txt | gawk '$15=="Complete"||$15=="Scaffolds or contigs"{print $13}' > results/_NCBI_viruses_years
cat data/NCBI_genome_reports/viruses.txt | gawk '($15=="Complete"||$15=="Scaffolds or contigs")&&$13!="-"{print $13,$2}' | sort -k2  >! results/_NCBI_viruses_taxid
join -12 -21 -a1 -t"$TAB" results/_NCBI_viruses_taxid results/_tax_to_category | sort -k3 -k2r > results/_NCBI_viruses_speciesID
gawk '{idx[$3]=$0}END{for (i in idx) {print idx[i]}}' results/_NCBI_viruses_speciesID > results/_NCBI_viruses_speciesID_early
gawk '{print $2}' results/_NCBI_viruses_speciesID_early | sed 's/\/.*//' | sort | uniq -c | sort -k2n > results/NCBI_viruses_by_year_species.txt


# analyze aggregate results
cat results/_NCBI_eukaryotes_years | sed 's/\/.*//' | sort | uniq -c | sort -k2n > results/NCBI_eukaryotes_by_year.txt
cat results/_NCBI_prokaryotes_years | sed 's/\/.*//' | sort | uniq -c | sort -k2n > results/NCBI_prokaryotes_by_year.txt
cat results/_NCBI_viruses_years | sed 's/\/.*//' | sort | uniq -c | sort -k2n > results/NCBI_viruses_by_year.txt
cat results/_NCBI_{eukaryotes,prokaryotes,viruses}_years | sed 's/\/.*//' | sort | uniq -c | sort -k2n > results/NCBI_by_year.txt

# kingdom analysis (method #1)
gawk '{print $2}' data/NCBI_genome_reports/overview.txt | sort | uniq -c | sort -k1nr

# kingdom analysis (method #2)
wc -l data/NCBI_genome_reports/{eukaryotes,viruses}.txt | sed 's/data.*\///;s/\.txt//'
gawk '$5~/archae/' data/NCBI_genome_reports/prokaryotes.txt | wc
gawk '$5!~/archae/' data/NCBI_genome_reports/prokaryotes.txt | wc
