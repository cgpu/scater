\name{NEWS}
\title{News for Package \pkg{scater}}

\section{Changes in version 1.14.0, Bioconductor 3.10 Release (September 2019)}{
  \itemize{ 
    \item Removed deprecated dplyr verbs.
    \item Removed deprecated method= option in runPCA().
    Increased ncomponents= default to 50.
    Deprecated use_coldata= and related options in favour of runColDataPCA().
    \item Added runColDataPCA() function for running PCA on colData().
    \item Pass all ... options to biomaRt::useMart() in getBMFeatureAnnos().
  }
}

\section{Changes in version 1.12.0, Bioconductor 3.9 Release (April 2019)}{
  \itemize{
    \item Removed all functions deprecated in the last release.
    \item Added option in runTSNE() to perform an external nearest neighbors check with BiocNeighbors.
    Removed the deprecated rand.seed= argument.
    \item Added text_by= and related options to plotReducedDim(), to overlay annotation labels onto the plot.
    \item Switched to BSPARAM= from BiocSingular for controlling SVD parameters.
    Deprecated the approximate= argument for runPCA().
    \item Switched runUMAP() to use uwot::umap.
    Added support for supplying a pre-defined set of nearest neighbors.
    \item Deprecated the various dplyr verbs, i.e., filter(), arrange(), mutate(), rename().
  }
}

\section{Changes in version 1.10.0, Bioconductor 3.8 Release (October 2018)}{
  \itemize{
    \item Fixes to all violin plots to ensure scatter matches up with violin outlines.
    \item Rectangle categorical/categorical plots collapse to mirrored bar plots when either factor contains only one level.
    \item Removed scater_gui(), downsampleCounts(), read10xResults(), normalizeExprs().
    \item Simplified plotRLE() to avoid the need for internal faceting.
    \item Added option for row subsetting in librarySizeFactors().
    \item Ensured calcAverage() with subset_row= behaves as if the matrix was subsetted prior to the function call.
    Added support for parallelization.
    \item Ensured calculateCPM() with subset_row= behaves as if the matrix was subsetted prior to the function call.
    \item Added support for parallelization in nexprs().
    \item Added readSparseCounts() for creating a sparse matrix from a dense array on file.
    \item Added normalizeCounts() for easy division of matrix columns by the size factors.
    Modified to throw error upon encountering negative, NA or zero size factors.
    \item Added preserve_zeroes= option to normalizeSCE() for preserving sparsity with non-unity pseudo-counts.
    \item Added runUMAP() and plotUMAP() to use the UMAP dimensionality reduction method.
    \item Added plotExplanatoryPCs() and getExplanatoryPCs() to correlate PCs with known factors.
    Deprecated findImportantPCs().
    \item Added getVarianceExplained() to get the variance in gene expression explained by known factors.
    \item Removed runKallisto() and runSalmon().
    \item Switched readTxResults() to use tximport.
    Switched readSalmonResults() and readKallistoResults() to use readTxResults().
    \item Removed obsolete fields in calculateQCMetrics().
    Moved processing into C++ for a single-pass algorithm.
    Supported parallelization across cells for QC computations.
    \item Added sumCountsAcrossFeatures() to sum counts across multiple redundant features.
    Deprecated summariseExprsAcrossFeatures().
    \item All plotting functions can now access internal fields by using a character vector with NA as the first element.
    \item Returned threshold values in the attributes of the output from isOutlier().
    \item Deprecated the ticks in plotReducedDim().
  }
}

\section{Changes in version 1.8.0, Bioconductor 3.7 Release (April 2018)}{
  \itemize{
    \item Refactored calculateQCMetrics() to ignore potential non-linearity, rank genes by highest expression, 
        rename automatically generated union sets, allow for output of a compact format. 
     \item Refactored all plotting functions to allow access to nested fields in the colData() or rowData(), by supplying a character vector.
     \item Refactored plotTSNE(), plotPCA(), etc. to dispatch to the calculation functions (e.g., runTSNE(), runPCA()), with argument checks.
     \item Refactored plotColData() and plotRowData() to use the same argument types as other functions rather than aes= input.
     \item Removed all plotting functions that do not operate on SingleCellExperiment objects.
     \item Deprecated read10xResults(), downsampleCounts() in favour of methods from the DropletUtils package.
     \item Deprecated scater_gui() in favour of methods from the iSEE package.
     \item Deprecated normalizeExprs() as this function made very little sense.
     \item Added plotHeatmap() function, for easy plotting of heatmaps. 
     \item Added librarySizeFactors() function, to compute size factors from library sizes.
     \item Added by_exprs_values= argument to many plotting functions, to distinguish direct plotting of expression values from their use in aesthetics.
     \item Renamed arguments in plotHighestExprs(), plotExprsVsTxLength(), plotExprsFreqVsMean() for greater clarity. 
     \item Added centreSizeFactors() function for centralized size factor centering.
     \item Added size_factor_grouping= argument to normalizeSCE(), calcAverage() and calculateCPM().
     \item Added subset_row= argument to calculateCPM().
     \item Consolidated size_factors= argument into use_size_factors= for calcAverage(), calculateCPM().
     \item Modified normalizeSCE() so that centre_size_factors=FALSE does not use centred size factors at all during normalization.
  }
}

\section{Changes in version 1.6.0, Bioconductor 3.6 Release (September 2017)}{
  \itemize{
    \item Complete refactoring of the package to use the SingleCellExperiment class.
  }
}

\section{Changes in version 1.4.0, Bioconductor 3.5 Release (April 2017)}{
  \itemize{
    \item plotRLE() function to make relative log expression plots to assess and compare normalizations.
    \item Refactored newSCESet() with defined hierarchy of data types
    \item read10XResults() to read in results from 10x Chromium CellRanger output.
    \item Refined QC metrics.
    \item Bug fixes, efficiency improvements and more tests.
  }
}

\section{Changes in version 1.2.0, Bioconductor 3.4 Release (October 2016)}{
  \itemize{
    \item Key code ported to C++ for greater computational and memory efficiency
    \item Added support/integration for SC3 package for single-cell clustering
    \item writeSCESet() function added to write SCESets to HDF5 format on disk
    \item mergeSCESet() function to merge two SCESet objects that share features
    \item plotPlatePosition() function to visualise gene expression and cell metadata for cells in their position on a plate
    \item Adding plotExprsVsTxLength() to plot expression against transcript length
    \item Added fitted line and some tweaks to plotExprsFreqVsMean().
    \item Adding support for scaled TPM counts when summarising expression at feature level. 
    \item Adding NULL method for set_exprs(). Adding tests.
    \item Adding import of effective feature lengths with readKallistoResults()
    \item runSalmon() function for running Salmon from within R, following suggestions from Rob Patro.
    \item Added cellNames<- assignment function
    \item Added extra QC metrics
    \item Numerous other bug fixes and minor improvements
  }
}

\section{Changes in version 1.0.0, Bioconductor 3.3 Release (April 2016)}{
  \itemize{
    \item Package added to Bioconductor
    \item Bioc-submission branch merged with master
  }
}
