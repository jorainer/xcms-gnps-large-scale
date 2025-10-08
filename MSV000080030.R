## Data set: https://massive.ucsd.edu/ProteoSAFe/dataset.jsp?task=5e7034cc98c54a47b803b144bff6a296
## Simple R-script to perform peak detection.
cat(paste0("Start processing: ", date(), "\n"), file = "timings.txt")

library(xcms)

## Get the number of cpus allocated from the environment variable
## 'SLURM_JOB_CPUS_PER_NODE' or fall back to 3
ncores <- as.integer(Sys.getenv("SLURM_JOB_CPUS_PER_NODE", 3))
## Define and set-up the parallel processing.
register(bpstart(MulticoreParam(ncores)), default = TRUE)

## Get all mzXML files in the current folder or sub-folders
fls <- dir("Forensic_study_80_volunteers", pattern = "mzXML$",
           full.names = TRUE, recursive = TRUE)

## Skip the blanks
fls <- fls[-grep(fls, pattern = "/Blank", fixed = TRUE)]

## Define the sample annotation table. Might be better to define the *real*
## sample grouping here as well.
pd <- data.frame(sample_group = rep("A", length(fls)))
dta <- readMSData(fls, mode = "onDisk", pdata = new("NAnnotatedDataFrame", pd))
cat("> data import done: ", date(), "\n", file = "timings.txt", append = TRUE)

## Define peak detection
cwp <- CentWaveParam(snthresh = 3, noise = 800, peakwidth = c(2, 30),
                     ppm = 20)
xdta <- findChromPeaks(dta, param = cwp)
cat("> peak detection done", date(), "\n", file = "timings.txt", append = TRUE)

## Alignment with peak groups
## Ideally, find an m/z slice with a high density of peaks and select that.
pdp <- PeakDensityParam(sampleGroups = rep(1, length(fileNames(xdta))),
                        bw = 2, binSize = 0.1, minFraction = 0.5)
xdta <- groupChromPeaks(xdta, param = pdp)
cat("> initial peak grouping done", date(), "\n", file = "timings.txt", append = TRUE)

## Perform the alignment
pgp <- PeakGroupsParam(minFraction = 0.7, extraPeaks = 100, span = 0.3)
xdta <- adjustRtime(xdta, param = pgp)
cat("> alignment done", date(), "\n", file = "timings.txt", append = TRUE)

## Correspondence analysis
pdp <- PeakDensityParam(sampleGroups = rep(1, length(fileNames(xdta))),
                        bw = 2, binSize = 0.015, minFraction = 0.03)
xdta <- groupChromPeaks(xdta, param = pdp)
cat("> correspondence done", date(), "\n", file = "timings.txt", append = TRUE)

## Fill missing peak data
medWidth <- median(chromPeaks(xdta)[, "rtmax"] -
                   chromPeaks(xdta)[, "rtmin"])
xdta <- fillChromPeaks(
    xdta, param = FillChromPeaksParam(fixedRt = medWidth))
cat("> filling in done", date(), "\n", file = "timings.txt", append = TRUE)

## Extract all MS2 spectra for each feature and clean them
ms2_spectra <- clean(featureSpectra(xdta, return.type = "Spectra"), all = TRUE)
cat("> extracting and cleaning MS2 peaks done", date(), "\n", file = "timings.txt", append = TRUE)

## Format them for GNPS and export all MS2 spectra
source("customFunctions.R")
ms2_spectra <- formatSpectraForGNPS(ms2_spectra)
save(ms2_spectra, file = "ms2_spectra.RData")
save(xdta, file = "xdta.RData")

## Export all feature data
## get data
fdef <- featureDefinitions(xdta)
fints <- featureValues(xdta, value = "into")
cat("> extract feature values done", date(), "\n", file = "timings.txt", append = TRUE)

## generate data table
dataTable <- merge(fdef, fints, by = 0, all = TRUE)
dataTable <- dataTable[, !(colnames(dataTable) %in% c("peakidx"))]
write.table(dataTable, "xcms_all_features.txt", sep = "\t",
            quote = FALSE, row.names = FALSE)

## Select for each feature the MS2 spectrum with the largetst TIC
ms2_spectra_maxTIC <- combineSpectra(ms2_spectra, fcol = "feature_id",
                                     fun = maxTic)
writeMgfData(ms2_spectra_maxTIC, "ms2_spectra_maxTIC.mgf")
cat("> maxTIC definition and export done", date(), "\n", file = "timings.txt", append = TRUE)

## Create a representative MS2 spectrum for each feature
ms2_spectra_consensus <- combineSpectra(ms2_spectra, fcol = "feature_id",
                                        fun = consensusSpectrum,
                                        mzd = 0, minProp = 0.8, ppm = 10)
writeMgfData(ms2_spectra_consensus, "ms2_spectra_consensus.mgf")
cat("> consensus MS2 and export done", date(), "\n", file = "timings.txt", append = TRUE)

## Export only features that have an MS2 spectrum
filteredDataTable <- dataTable[which(
    dataTable$Row.names %in% ms2_spectra@elementMetadata$feature_id),]
write.table(filteredDataTable, "xcms_onlyMS2_features.txt", sep = "\t",
            quote = FALSE, row.names = FALSE)
cat("> FINE", date(), "\n", file = "timings.txt", append = TRUE)
