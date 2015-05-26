# READ in the file

library(foreign)
baseline = read.spss("H:\\data_fes\\20150113_baseline_sorted.sav", to.data.frame=TRUE,
  use.value.labels=FALSE)

# logical statements  
# family
moth <- (baseline$BL_a2 >=1)  
fath <- (baseline$BL_a3 >=1)
mothfath <- (baseline$BL_a2 >=1 | baseline$BL_a3 >=1)
child <- (baseline$BL_a1 >=1)
maxfam <-  pmax(baseline$BL_a1, baseline$BL_a2, baseline$BL_a3,
 baseline$BL_a4, baseline$BL_a5, baseline$BL_a6, baseline$BL_a7,
 baseline$BL_a8, baseline$BL_a9, baseline$BL_a10, baseline$BL_a11,
 baseline$BL_a12, baseline$BL_a13, baseline$BL_a14, na.rm = FALSE)
allfam <- (maxfam >=1)

 
# professionals and supports
maxprof <-  pmax(baseline$BL_a15, baseline$BL_a16, baseline$BL_a17,
 baseline$BL_a18, baseline$BL_a19, baseline$BL_a20, baseline$BL_a21,
 baseline$BL_a22, baseline$BL_a23, baseline$BL_a24, baseline$BL_a25,
 baseline$BL_a26, baseline$BL_a27, baseline$BL_a28, na.rm = FALSE)
allprof <- (maxprof >=1)

 
 
# SUMMARY statistics
summary(moth)
summary(fath)
summary(mothfath)
summary(maxfam)
summary(allfam)
summary(maxprof)
summary(allprof)

# bind the columns
cmothfath<- cbind(moth, fath)
cmfchil<- cbind(mothfath, child)
cmfsepchil<- cbind(moth, fath, child)
cfamprof<- cbind(allfam, allprof)

# use the Venn Counts
zvenn<- vennCounts(cmothfath)
yvenn<- vennCounts(cmfchil)
wvenn<- vennCounts(cmfsepchil)
xvenn<- vennCounts(cfamprof)

# draw Venn diagrams
vennDiagram(zvenn, names = c("Mother", "Father"), 
  cex = 1, counts.col = "red")

vennDiagram(yvenn, names = c("M or F", "Child"), 
  cex = 1, counts.col = "green")

vennDiagram(wvenn, names = c("Mother", "Father", "Child"), 
  cex = 1, counts.col = "purple")

vennDiagram(xvenn, names = c("Family", "Prof. or Supp."), 
  cex = 1, counts.col = "blue")

subset(baseline, allfam==0 & allprof==0)
  