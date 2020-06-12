
dataset="PRJNA63455"

metaData<-read.csv("SraRunTable-PRJNA63455.txt",header=T,stringsAsFactors=F)
names(metaData)
#1538 x 41

#remove drosophila data
metaData<-metaData[metaData$Organism=="Caenorhabditis elegans",]
#1008

#####################################
### manually look at data in columns
#####################################
head(metaData[,31:41])
table(metaData$Assay.Type)
# all ChIP-Seq

table(metaData$AvgSpotLen)
#28-75bp

table(metaData$Center.Name)
# all GEO

table(metaData$Consent)
# all public

table(metaData$DATASTORE.filetype)
#fastq,sra       sra
#111       897

table(metaData$DATASTORE.provider)
# all gs,ncbi,s3

table(metaData$DATASTORE.region)
# alll gs.US,ncbi.public,s3.us-east-1

table(metaData$Instrument)
#    Illumina Genome Analyzer Illumina Genome Analyzer II         Illumina HiSeq 2000
#983                          17                           8

table(metaData$LibraryLayout)
#all SINGLE

table(metaData$LibrarySelection)
#   ChIP RANDOM
# 1006      2

table(metaData$LibrarySource)
# all GENOMIC

table(metaData$Platform)
# all ILLUMINA

table(metaData$ReleaseDate)

#### SRA.Study contains paired input and chip data

table(metaData$BioProject)
#""  PRJNA63455 PRJNA63461
#74        930          4

table(metaData$Developmental_stage)
##### useful

table(metaData$sex)
# partial

table(metaData$Development_stage)
### empty

table(metaData$Library.Name)
# partial info - only for snyder data

metaData[grep("Snyder",metaData$Library.Name),]
# same data is in source_name so cn be deleted

metaData$source_name

table(metaData$tissue)
# whole body or whole embryo... can be deleted

table(metaData$Cell_Line)
# empty

table(metaData$stage)
# very limited info

metaData$Developmental_stage[metaData$stage=="L3"]
metaData$Developmental_stage[metaData$stage=="mixed stages"]
metaData$Developmental_stage[metaData$stage=="MXemb"]
metaData$Developmental_stage[metaData$stage=="early embryos"]
# should be placed in Developmental_stage

table(metaData$chip_antibody)
#partial

table(metaData$transgene)
#partial

table(metaData$chip_antibody_supplier)
#partial

table(metaData$genotype.variation)
# meaningless: 4 wildtype the rest nothing

table(metaData$strain.background)
# meaningless: 4 N2, the rest nothing

table(metaData$antibody_manufacturer)
# meaningless. 2 wako, the rest nothing

table(metaData$input_experiment.sample)
metaData[grep("seq",metaData$input_experiment.sample),]
# the input experiments are these (early emb)
metaData[grep("RANDOM",metaData$LibrarySelection),]

#SRA.Study SRP003622  H3K4me3_N2_MXemb

metaData[grep("H3K4me3",metaData$source_name),]
# another dataset in EEmb, but that is in mixed Male and Hermaphrodites SRP007859


#####################################
### copy data from "stage" to Developmental_stage
#####################################

idx<-metaData$stage!=""
metaData$Developmental_stage[idx]
metaData$Developmental_stage[idx]<-metaData$stage[idx]
table(metaData$Developmental_stage)


#####################################
### subset L3 data
#####################################

idx<-grep("L3",metaData$Developmental_stage)
l3data<-metaData[idx,]

tmp<-l3data$LibraryLayout
# remove all columns that have all the same info
cols2remove<-c()
for (i in 1:ncol(l3data)){
  if(length(unique(l3data[,i]))==1){
    cols2remove<-c(cols2remove,names(l3data)[i])
  }
}
cols2remove
head(l3data)
cols2remove<-c(cols2remove,"DATASTORE.filetype","Library.Name","tissue","stage","chip_antibody_supplier","genotype.variation","strain.background")

l3data[,cols2remove]<-NULL

l3data$libType<-tmp

dim(l3data)
#down to 205 rows and 20 columns

summary(l3data$Bases/1e8)
#  fold coverage (theoretically) ranges between 0.32 to 30x (median 3.7)
hist(l3data$Bases/1e8,breaks=50, main="Genome fold coverage")


#################
### process metadata by release date
#################

names(l3data)
table(l3data$ReleaseDate)
l3data[grep("2014-",l3data$ReleaseDate),]
# each release date has one input
# 2014 data is all mixed male and herm

l3tidy<-l3data[,c("Run","AvgSpotLen", "Bases", "BioSample",
                  "Experiment", "GEO_Accession..exp.",
                  "Instrument", "libType", "ReleaseDate",
                  "Sample.Name","SRA.Study","BioProject")]
# sex
l3tidy$sex<-"herm"
idx<-(grepl("male",l3data$sex,ignore.case=T) | grepl("male",l3data$sex_type,ignore.case=T))
l3tidy$sex[idx]<-paste0(l3tidy$sex[idx],"-male")

# dev stage
l3tidy$stage<-"L3"

# strain
l3tidy$strain<-"N2"
idx<-grepl("OP",l3data$strain,ignore.case=T)
l3tidy$strain[idx]<-gsub("\\(.*$","",l3data$strain[idx])

# genotype
l3tidy$genotype<-"wild-type"
idx<-grepl("unc",l3data$Genotype)
l3tidy$genotype[idx]<-l3data$Genotype[idx]


# target/input/chip/control etc
l3tidy$target<-NA
l3tidy$antibody<-NA
l3tidy$replicate<-NA
l3tidy$Input_or_IP<-NA
l3tidy$matchedInputs<-NA
l3tidy$mergeInputs<-F
l3tidy$matchedIPs<-NA
l3tidy$mergeIPs<-F

# process early data by release date
head(l3data)
table(l3data$ReleaseDate)

##
idx<-grepl("2011-05-03T00:00:00Z",l3data$ReleaseDate)
inputs<-idx & grepl("Control",l3data[,"source_name"])
ips<-idx & ! grepl("Control",l3data[,"source_name"])

l3tidy$target[ips]<-gsub("^[[:alnum:]]* ","",l3data$chip_antibody[ips])
l3tidy$target[inputs]<-"Input"
l3tidy$antibody[ips]<-l3data$chip_antibody[ips]
l3tidy$replicate[inputs]<-paste0("rep",1:sum(inputs))
for (target in unique(l3tidy$target[ips])) {
  replicates<-idx & grepl(target,l3tidy$target)
  l3tidy$replicate[replicates]<-paste0("rep",1:sum(replicates))
}
l3tidy$replicate[ips]
l3tidy$Input_or_IP[inputs]<-"Input"
l3tidy$Input_or_IP[ips]<-"ChIP"
l3tidy$matchedInputs[ips]<-paste0(l3data$Run[inputs],collapse=";")
l3tidy$mergeInputs[ips]<-T
l3tidy$matchedIPs[inputs]<-paste0(l3data$Run[ips],collapse=";")
l3tidy$mergeIPs[inputs]<-F


##
idx<-grepl("2011-08-30T00:00:00Z",l3data$ReleaseDate)
inputs<-idx & grepl("Control",l3data[,"source_name"])
ips<-idx & ! grepl("Control",l3data[,"source_name"])
l3data[idx,]

l3tidy$target[ips]<-gsub("^[[:alnum:]]* ","",l3data$chip_antibody[ips])
l3tidy$target[inputs]<-"Input"
l3tidy$antibody[ips]<-l3data$chip_antibody[ips]
l3tidy$replicate[inputs]<-paste0("rep",1:sum(inputs))
for (target in unique(l3tidy$target[ips])) {
  replicates<-idx & grepl(target,l3tidy$target)
  l3tidy$replicate[replicates]<-paste0("rep",1:sum(replicates))
}
l3tidy$replicate[ips]
l3tidy$Input_or_IP[inputs]<-"Input"
l3tidy$Input_or_IP[ips]<-"ChIP"
l3tidy$matchedInputs[ips]<-paste0(l3data$Run[inputs],collapse=";")
l3tidy$matchedIPs[inputs]<-paste0(l3data$Run[ips],collapse=";")
l3tidy[idx,]


##
idx<-grepl("2014-04-14T00:00:00Z",l3data$ReleaseDate)
inputs<-idx & grepl("input",l3data[,"source_name"])
ips<-idx & ! grepl("input",l3data[,"source_name"])
l3data[idx,]
l3data[inputs,]
l3data[ips,]

l3tidy$target[ips]<-gsub("^anti-","",l3data$chip_antibody[ips])
l3tidy$target[inputs]<-"Input"
l3tidy$antibody[ips]<-l3data$chip_antibody[ips]
l3tidy$replicate[inputs]<-paste0("rep",1:sum(inputs))
l3tidy$replicate[idx]<-"rep1"

l3tidy$replicate[ips]
l3tidy$Input_or_IP[inputs]<-"Input"
l3tidy$Input_or_IP[ips]<-"ChIP"
l3tidy$matchedInputs[ips]<-paste0(l3data$Run[inputs],collapse=";")
l3tidy$mergeInputs[ips]<-T
l3tidy$matchedIPs[inputs]<-paste0(l3data$Run[ips],collapse=";")
l3tidy$mergeIPs[inputs]<-T
l3tidy[idx,]
l3data[idx,]



#### process newer data by naming convention:

##
idx<-grepl("^seq-",l3data$source_name)
inputs<-idx & grepl("Input",l3data[,"source_name"])
ips<-idx & grepl("ChIP",l3data[,"source_name"])
l3data[idx,]
dim(l3data[inputs,])
dim(l3data[ips,])

# split source_name field for metadata
#antibody
l3tidy$antibody[idx]<-sapply(do.call(strsplit,list(l3data$source_name[idx],"[-_:]")), "[[",2)
# target
l3tidy$target[idx]<-sapply(do.call(strsplit,list(l3data$source_name[idx],"[-_:]")), "[[",3)
# replicate
l3tidy$replicate[idx]<-sapply(do.call(strsplit,list(l3data$source_name[idx],"[-_:]")), tail,2)[2,]
# input or ip
l3tidy$Input_or_IP[idx]<-sapply(do.call(strsplit,list(l3data$source_name[idx],"[-_:]")), tail,2)[1,]

#get unique target-replicate-antibody combination for matching
ips_target_rep<-paste(l3tidy$target[ips],l3tidy$replicate[ips],l3tidy$antibody[ips],sep="_")
inputs_target_rep<-paste(l3tidy$target[inputs],l3tidy$replicate[inputs],l3tidy$antibody[inputs],sep="_")

#match chips with their inputs
matchedReps<-match(ips_target_rep,inputs_target_rep)
l3tidy$matchedInputs[ips]<-l3data$Run[inputs][matchedReps]
#match inputs with their chips
matchedReps<-match(inputs_target_rep,ips_target_rep)
l3tidy$matchedIPs[inputs]<-l3data$Run[ips][matchedReps]



##
idx<-is.na(l3tidy$target)
l3data[idx,]
l3tidy[idx,]

l3tidy$antibody[idx & grepl("GFP",l3data$Genotype)]<-"GFP"
l3data$source_name[idx]<-gsub("Snyder_","",l3data$source_name[idx])

# target
l3tidy$target[idx]<-sapply(do.call(strsplit,list(l3data$source_name[idx],"[_ ]")), "[[",1)
### Note discrepancy between Chip annotation of ceh-28 when the
### strain is supposed to be ceh-38!?
# replicate
r<-regexec("rep\\d",l3data$source_name[idx],ignore.case=T, perl=T)
l3tidy$replicate[idx]<-unlist(do.call(regmatches,list(l3data$source_name[idx],r)))
l3tidy$replicate<-gsub("Rep","rep",l3tidy$replicate)

# input or ip
l3data$source_name[idx]<-gsub("GFP(_\\w{4})$","ChIP\\1",l3data$source_name[idx])
r<-regexec("(?:ChIP|Input)",l3data$source_name[idx])
l3tidy$Input_or_IP[idx]<-unlist(do.call(regmatches,list(l3data$source_name[idx],r)))


inputs<-idx & (l3tidy$Input_or_IP=="Input")
ips<-idx & (l3tidy$Input_or_IP=="ChIP")
#get unique target-replicate-antibody combination for matching
ips_target_rep<-paste(l3tidy$target[ips],l3tidy$replicate[ips],sep="_")
inputs_target_rep<-paste(l3tidy$target[inputs],l3tidy$replicate[inputs],sep="_")

#match chips with their inputs
matchedReps<-match(ips_target_rep,inputs_target_rep)
l3tidy$matchedInputs[ips]<-l3data$Run[inputs][matchedReps]
#match inputs with their chips
matchedReps<-match(inputs_target_rep,ips_target_rep)
l3tidy$matchedIPs[inputs]<-l3data$Run[ips][matchedReps]
dups<-ips_target_rep[duplicated(ips_target_rep)]
for (d in dups){
  l3tidy$matchedIPs[inputs][inputs_target_rep==d] <-
    paste0(l3data$Run[ips][ips_target_rep==d],collapse=";")
  l3tidy$mergeIPs[inputs][inputs_target_rep==d] <- T
}

# tidy gene names up
l3tidy$target<-gsub("^([[:alpha:]]{3,4})([[:digit:]]{1,3})$","\\1-\\2",l3tidy$target)
l3tidy$target<-gsub("^([[:alpha:]]{3,4}-[[:digit:]]{1,3})$","\\U\\1",l3tidy$target, perl=T)

l3tidy$basename<-with(l3tidy,paste(Run,stage,sex,target,Input_or_IP,replicate,sep="_"))


# save tidy table
write.csv(l3tidy,file=paste0(dataset,"_L3tidy.csv"),row.names=F)

#rework table to run pipeline


dflist<-list()

inputIdx<-which(l3tidy$Input_or_IP=="Input")
l3tidy[inputIdx,]
i=1
i=3
for (i in inputIdx) {
  #print(l3tidy[i,])
  ipSRRs<-unlist(strsplit(l3tidy$matchedIPs[i],";"))
  ipIdx<-match(ipSRRs,l3tidy$Run)
  #print(l3tidy[ipIdx,])
  # get inputs
  if(sum(l3tidy$mergeInputs[ipIdx])>0){
    inputs=unlist(strsplit(unique(l3tidy$matchedInputs[ipIdx]),";"))
  } else {
    inputs=unlist(strsplit(l3tidy$Run[i],";"))
  }
  targets<-l3tidy$target[ipIdx]
  replicates<-l3tidy$replicate[ipIdx]
  # get ips
  if(l3tidy$mergeIPs[i]==T) {
    ips2merge<-unlist(strsplit(l3tidy$matchedIPs[i],";"))
    ips<-NA
    targets<-unique(targets)
    replicates<-unique(replicates)
  } else {
    ips2merge<-NA
    ips<-unlist(strsplit(l3tidy$matchedIPs[i],";"))
  }
  # get basename
  basename<-paste(targets, replicates, l3tidy$stage[i], l3tidy$sex[i],
                  paste0("_", paste(inputs,collapse="-"), "v",
                         ifelse(is.na(ips), paste(ips2merge,collapse="-"),
                         ips)), sep="_")
  dflist[[l3tidy$Run[i]]]<-data.frame(inputs=paste(inputs,collapse=";"),
                                    ips2merge=paste(ips2merge,collapse=";"),
                                    ips=paste(ips,collapse=";"),
                                    basename=paste(basename,collapse=";"),
                                    stringsAsFactors=F)
}



df<-do.call(rbind,dflist)
row.names(df)<-NULL
df<-df[!duplicated(df$basename),]
write.csv(df, file=paste0(dataset,"_L3_forPipeline.csv"),row.names=F)
