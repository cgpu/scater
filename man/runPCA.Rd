% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotting.R
\name{runPCA}
\alias{runPCA}
\title{Run PCA for a SingleCellExperiment object}
\usage{
runPCA(object, ntop = 500, ncomponents = 2, exprs_values = "logcounts",
  feature_set = NULL, scale_features = TRUE, pca_data_input = "logcounts",
  selected_variables = NULL, detect_outliers = FALSE)
}
\arguments{
\item{object}{a \code{\link{SingleCellExperiment}} object}

\item{ntop}{numeric scalar indicating the number of most variable features to
use for the PCA. Default is \code{500}, but any \code{ntop} argument is
overrided if the \code{feature_set} argument is non-NULL.}

\item{ncomponents}{numeric scalar indicating the number of principal
components to obtain from \code{\link{prcomp}}.}

\item{exprs_values}{character string indicating which values should be used
as the expression values for this plot. Valid arguments are \code{"tpm"}
(transcripts per million), \code{"norm_tpm"} (normalised TPM
values), \code{"fpkm"} (FPKM values), \code{"norm_fpkm"} (normalised FPKM
values), \code{"counts"} (counts for each feature), \code{"norm_counts"},
\code{"cpm"} (counts-per-million), \code{"norm_cpm"} (normalised
counts-per-million), \code{"logcounts"} (log-transformed count data; default),
\code{"norm_exprs"} (normalised
expression values) or \code{"stand_exprs"} (standardised expression values)
or any other named element of the \code{assays} slot of the \code{SingleCellExperiment}
object that can be accessed with the \code{assay} function.}

\item{feature_set}{character, numeric or logical vector indicating a set of
features to use for the PCA. If character, entries must all be in
\code{featureNames(object)}. If numeric, values are taken to be indices for
features. If logical, vector is used to index features and should have length
equal to \code{nrow(object)}.}

\item{scale_features}{logical, should the expression values be standardised
so that each feature has unit variance? Default is \code{TRUE}.}

\item{pca_data_input}{character argument defining which data should be used
as input for the PCA. Possible options are \code{"logcounts"} (default), which
uses log-count data to produce a PCA at the cell level; \code{"coldata"} or
\code{"pdata"} (for backwards compatibility) which uses numeric variables
from \code{colData(object)} to do PCA at the cell level; and
\code{"rowdata"} which uses numeric variables from \code{rowData(object)} to
do PCA at the feature level.}

\item{selected_variables}{character vector indicating which variables in
\code{colData(object)} to use for the phenotype-data based PCA. Ignored if
the argument \code{pca_data_input} is anything other than \code{"pdata"}
or \code{"coldata"}.}

\item{detect_outliers}{logical, should outliers be detected based on PCA
coordinates generated from column-level metadata? Only an option when 
\code{pca_data_input} argument is \code{"pdata"} or \code{"coldata"}. 
Default is \code{FALSE}.}
}
\value{
A \code{SingleCellExperiment} object containing the first 
\code{ncomponent} principal coordinates for each cell in the \code{"PCA"}
entry of the \code{reducedDims} slot.
}
\description{
Perform a principal components analysis (PCA) based on the data stored in 
a \code{\link{SingleCellExperiment}} object.
}
\details{
The function \code{\link{prcomp}} is used internally to do the PCA.
The function checks whether the \code{object} has standardised
expression values (by looking at \code{stand_exprs(object)}). If yes, the
existing standardised expression values are used for the PCA. If not, then
standardised expression values are computed using \code{\link{scale}} (with
feature-wise unit variances or not according to the \code{scale_features}
argument), added to the object and PCA is done using these new standardised
expression values.

If the arguments \code{detect_outliers} and \code{return_SCE} are both
\code{TRUE}, then the element \code{$outlier} is added to the pData
(phenotype data) slot of the \code{SingleCellExperiment} object. This element contains
indicator values about whether or not each cell has been designated as an
outlier based on the PCA. These values can be accessed for filtering
low quality cells with, for example, \code{example_sce$outlier}.

When \code{pca_data_input="pdata"} or \code{"coldata"}, the selected variables 
default to a vector containing:
\itemize{
\item \code{"pct_counts_top_100_features"}
\item \code{"total_features"}
\item \code{"pct_counts_feature_control"}
\item \code{"total_features_feature_control"}
\item \code{"log10_total_counts_endogenous"}
\item \code{"log10_total_counts_feature_control"}
}
These metrics were chosen due to their utility in distinguishing low-quality
libraries. However, they can be overriden by setting \code{selected_variables}
manually. In particular, \code{"log10_total_counts"} is more useful than 
the \code{_endogenous} and \code{_control} metrics when spike-ins are not
available.
}
\examples{
## Set up an example SingleCellExperiment
data("sc_example_counts")
data("sc_example_cell_info")
example_sce <- SingleCellExperiment(
assays = list(counts = sc_example_counts), colData = sc_example_cell_info)
example_sce <- normalize(example_sce)

example_sce <- runPCA(example_sce)
reducedDimNames(example_sce)
head(reducedDim(example_sce))
}
\seealso{
\code{\link[scater]{plotPCA}}
}