#!/usr/bin/env Rscript

library('ggplot2')
library('plyr')
library('tidyr')

df <- read.table(file='./viruses.txt', sep = '\t', fill = TRUE, header=TRUE)
df$Release_Date <- as.Date(df$Release_Date)
df$Release_Date <- format(df$Release_Date, "%Y")
df1 <- as.data.frame(table(df$Release_Date, useNA = 'no', dnn = 'date'))
df1$date <- as.Date(df1$date, "%Y")

prokaryotes <- read.table(file='./prokaryotes.txt', sep = '\t', fill = TRUE, header=TRUE)
prokaryotes$Release_Date <- as.Date(prokaryotes$Release_Date)
prokaryotes$Release_Date <- format(prokaryotes$Release_Date, "%Y")
prokaryotes1 <- as.data.frame(table(prokaryotes$Release_Date, useNA = 'no', dnn = 'date'))
prokaryotes1$date <- as.Date(prokaryotes1$date, "%Y")
head(prokaryotes1)

eukaryotes <- read.table(file='./eukaryotes.txt', sep = '\t', fill = TRUE, header=TRUE)
eukaryotes$Release_Date <- as.Date(eukaryotes$Release_Date)
eukaryotes$Release_Date <- format(eukaryotes$Release_Date, "%Y")
eukaryotes1 <- as.data.frame(table(eukaryotes$Release_Date, useNA = 'no', dnn = 'date'))
eukaryotes1$date <- as.Date(eukaryotes1$date, "%Y")
head(eukaryotes1)

cairo_pdf(file='sequenced_genomes.pdf', width = 12, height = 7)
ggplot(df1, aes(x = date, y = log(Freq, 10))) +
	geom_point(aes(colour = "wirusy")) +
	geom_point(data = prokaryotes1, aes(colour = "prokarionty")) +
	geom_point(data = eukaryotes1, aes(colour = "eukarionty")) +
	geom_smooth(aes(colour = "wirusy"), se = FALSE) +
	geom_smooth(data = prokaryotes1,aes(colour = "prokarionty"), se = FALSE) +
	geom_smooth(data = eukaryotes1,aes(colour = "eukarionty"), se = FALSE) +
	labs(x = "Rok", y = "logarytm dziesiętny z liczby zsekwencjonowanych genomów", colour = "Grupa organizmów") +
	scale_colour_hue() +
	theme_bw()
dev.off()
