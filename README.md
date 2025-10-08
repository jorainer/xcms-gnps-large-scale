# Large-scale LC-MS/MS data preprocessing with *xcms*

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17293665.svg)](https://doi.org/10.5281/zenodo.17293665)

Here we present example workflows to perform a large scale untargeted
metabolomics LC-MS/MS data preprocessing for molecular networking analysis using
[GNPS](http://gnps.ucsd.edu). The data set is described in [Nothias, L.F. et al
Nat Methods 2020 Sep;17(9):905-908](https://doi.org/10.1038/s41592-020-0933-6).

The analysis in this repository is based on the *xcms* Bioconductor package
version >= 4.7
[10.26434/chemrxiv-2025-2n2kh](https://doi.org/10.26434/chemrxiv-2025-2n2kh)
that reuses the
[RforMassSpectrometry](https://rformassspectrometry.org)/[Spectra](https://github.com/rformassspectrometry/Spectra)
MS data infrastructure
[10.31219/osf.io/cwt2v_v2](https://doi.org/10.31219/osf.io/cwt2v_v2). See also
the [*large-scale data preprocessing with
xcms*](https://rformassspectrometry.github.io/Metabonaut/articles/large-scale-analysis.html)
tutorial within [Metabonaut](https://doi.org/10.5281/zenodo.15062929) for a
large-scale data analysis workflow of another data set.

The analysis performed here includes the preprocessing of the raw LC-MS/MS data
files from the *MSV000080030* data set, which includes chromatographic peak
detection, peak refinement, retention time alignment, correspondence analysis
and gap-filling. Subsequently, MS2 spectra for all features are extracted and,
along with the feature abundances exported for use in *GNPS*.

The original analysis of the same data set was described in the supplementary
information from [Nothias, L.F. et al Nat Methods 2020
Sep;17(9):905-908](https://doi.org/10.1038/s41592-020-0933-6). That used an
older version of *xcms* and was performed on a high performance cluster (8 CPUs
with 32GB main memory for each node). The full analysis with that setup took 8
hours to complete.

The present workflow is completely reproducible: the raw data files can be
downloaded from MassIVE:
[MSV000080030](https://gnps.ucsd.edu/ProteoSAFe/result.jsp?task=5e7034cc98c54a47b803b144bff6a296&view=advanced_view)
and quarto files defining the analysis are provided in this repository.
Processing timing and memory usage were tracked along the analysis and are
reported in the rendered pdf files. The present analysis was performed using the
[Bioconductor docker
image](https://hub.docker.com/r/bioconductor/bioconductor_docker/) for the
developmental version 3.22. The analysis for the rendered pdf files was run on 4
CPUs of a [Framework](https://frame.work) 13' notebook with a 13th Gen Intel(R)
Core(TM) i7-1370P CPU (20 cores) and 64 GB of main memory.

## Analysis files

- [xcms-preprocessing.qmd](xcms-preprocessing.qmd): workflow using the
  [MsExperiment](https://bioconductor.org/packages/MsExperiment) +
  [Spectra](https://bioconductor.org/packages/Spectra)-based infrastructure and
  the new *xcms* result object (`XcmsExperiment`). At least 64GB of main memory
  are suggested to perform this analysis.

- [xcms-preprocessing-hdf5.qmd](xcms-preprocessing-hdf5.qmd): workflow that uses
  the low memory *xcms* result object `XcmsExperimentHdf5`. All preprocessing
  results are stored off-memory in a dedicated HDF5 file, optimized for fast
  access and processing. This enables processing of the data also on computers
  with lower amount of available main memory.

- [xcms-preprocessing-msnbase.Rmd](xcms-preprocessing-msnbase.Rmd): version of
  the analysis with the results reported in [Nothias, L.F. et al Nat Methods
  2020 Sep;17(9):905-908](https://doi.org/10.1038/s41592-020-0933-6). It uses
  the *xcms* version from Bioconductor release 3.10. This version of *xcms*
  (a.k.a. *xcms 3*) used the infrastructure and data objects from the
  [*MSnbase*](https://bioconductor.org/packages/MSnbase) Bioconductor package
  for handling of the MS data.

- [xcms-preprocessing-old.Rmd](xcms-preprocessing-old.Rmd): version of the
  analysis that used most of the original result objects from the *xcms*
  package. This version of *xcms* did not support LC-MS/MS data, peak refinement
  or the new and improved gap-filling, hence only a minimal preprocessing of the
  data is performed in this file. To run the analysis, the
  [bioconductor/release_metabolomics2:R3.3.2_Bioc3.4](https://hub.docker.com/layers/bioconductor/release_metabolomics2/R3.3.2_Bioc3.4/images/sha256-eecdb80fc886e0ac4e5e32989a87db0a10ad48c8d737fc5695c2226f21e4aca6)
  docker image was used which features *xcms* version 1.50.1.

- [MSV000080030.R](MSV000080030.R): R script used to perform the original
  analysis described in the Supplement from Nothias et al.

## Software requirements

The docker image for the Bioconductor 3.22 developmental version can be
retrieved using `docker pull bioconductor/bioconductor_docker:devel`.

All required R packages can be installed using:

```{r}
BiocManager::install(c("xcms", "MsExperiment", "peakRAM",
    "pander", "MsBackendMgf", "rhdf5"))
```

To docker image for the Bioconductor release 3.10 used for
*xcms-preprocessing-msnbase.Rmd* can be retrieved using `docker pull
bioconductor/bioconductor_docker:RELEASE_3_10`.
