## Test functions related to calculation of the variance explained.
## library(scater); library(testthat); source("setup-sce.R"); source("test-expl-var.R")

#############################################################
# getVarianceExplained() tests:

varexp <- getVarianceExplained(normed) 
  
test_that("getVarianceExplained matches with a reference function", {
    expect_identical(colnames(varexp), colnames(colData(normed)))
    for (v in colnames(varexp)) {
        X <- colData(normed)[[v]]
        Y <- logcounts(normed, withDimnames=FALSE)

        # Using lm() per gene, which is a bit slow but ensures we get a reference R2.
        output <- numeric(nrow(normed))
        for (g in seq_len(nrow(normed))) { 
            y <- Y[g,]
            fit <- lm(y ~ X)
            output[g] <- suppressWarnings(summary(fit)$r.squared)
        }

        expect_equal(output, unname(varexp[,v]))
    }
})

test_that("getVarianceExplained responds to the options", {
    # Responds to differences in the assay name.
    blah <- normed
    assayNames(blah) <- c("yay", "whee")
    expect_error(getVarianceExplained(blah), "logcounts")
    expect_identical(varexp, getVarianceExplained(blah, exprs_values="whee"))
    
    # Responds to choice of variable.
    expect_identical(varexp[,1,drop=FALSE], getVarianceExplained(normed, variables=colnames(varexp)[1]))
    expect_identical(varexp[,c(3,2),drop=FALSE], getVarianceExplained(normed, variables=colnames(varexp)[c(3,2)]))
    expect_identical(varexp, getVarianceExplained(normed, variables=colnames(varexp)))

    # Unaffected by chunk size.
    expect_identical(varexp, getVarianceExplained(normed, chunk=10))
    expect_identical(varexp, getVarianceExplained(normed, chunk=1))
    expect_identical(varexp, getVarianceExplained(normed, chunk=100000))
})

test_that("getVarianceExplained handles sparse inputs", {
    normed_sparse <- normed
    library(Matrix)
    counts(normed_sparse) <- as(counts(normed), "dgCMatrix")
    logcounts(normed_sparse) <- as(logcounts(normed), "dgCMatrix")

    varexp_sparse <- getVarianceExplained(normed_sparse)
    expect_equal(varexp, varexp_sparse)
})

test_that("getVarianceExplained handles NA values in the metadata", {
    whee <- runif(ncol(normed))
    whee[sample(ncol(normed), ncol(normed)/3)] <- NA
    normed$whee <- whee

    out <- getVarianceExplained(normed, variables="whee")
    ref <- getVarianceExplained(normed[,!is.na(whee)], variables="whee")
    expect_identical(out, ref)
})

test_that("getVarianceExplained handles silly inputs correctly", {
    # Misspecified variables.
    expect_error(getVarianceExplained(normed, variables="yay"), "invalid names")

    # Empty inputs.
    out <- getVarianceExplained(normed[0,])
    expect_identical(colnames(out), colnames(varexp))
    expect_identical(nrow(out), 0L)

    expect_warning(out <- getVarianceExplained(normed[,0]), "2 unique levels")
    expect_identical(dimnames(out), dimnames(varexp))
    expect_true(all(is.na(out)))
    
    # Inputs with only one unique level.
    normed$whee <- 1
    expect_warning(out2 <- getVarianceExplained(normed, variables="whee"), "2 unique levels")
    expect_identical(rownames(out2), rownames(varexp))
    expect_identical(colnames(out2), "whee")
    expect_true(all(is.na(out)))
})

#############################################################
# plotExplanatoryVariables() tests:

test_that("plotExplanatoryVariables works as expected", {
    out <- plotExplanatoryVariables(normed)
    ref <- plotExplanatoryVariables(varexp)
    expect_s3_class(out, "ggplot")
    expect_identical(out$data, ref$data)

    medians <- apply(varexp, 2, median, na.rm=TRUE)

    # Responds to choice of number of variables
    out <- plotExplanatoryVariables(normed, nvars_to_plot=2)
    ref <- plotExplanatoryVariables(varexp[,order(medians, decreasing=TRUE)[1:2]])
    expect_s3_class(out, "ggplot")
    expect_identical(out$data, ref$data)

    out <- plotExplanatoryVariables(normed, nvars_to_plot=Inf)
    ref <- plotExplanatoryVariables(varexp)
    expect_s3_class(out, "ggplot")
    expect_identical(out$data, ref$data)

    out <- plotExplanatoryVariables(normed, nvars_to_plot=0)
    ref <- plotExplanatoryVariables(varexp[,0,drop=FALSE])
    expect_s3_class(out, "ggplot")
    expect_identical(out$data, ref$data)

    # Responds to choice of minimum marginal R2.
    out <- plotExplanatoryVariables(normed, min_marginal_r2=0.5)
    ref <- plotExplanatoryVariables(varexp[,medians >= 0.5,drop=FALSE])
    expect_s3_class(out, "ggplot")
    expect_identical(out$data, ref$data)

    out <- plotExplanatoryVariables(normed, min_marginal_r2=0.05)
    ref <- plotExplanatoryVariables(varexp[,medians >= 0.05,drop=FALSE])
    expect_s3_class(out, "ggplot")
    expect_identical(out$data, ref$data)

    # Handles silly inputs.
    expect_s3_class(plotExplanatoryVariables(varexp[0,,drop=FALSE]), "ggplot")
    expect_s3_class(plotExplanatoryVariables(varexp[,0,drop=FALSE]), "ggplot")
})

#############################################################
# getExplanatoryPCs() tests:

exppcs <- getExplanatoryPCs(normed, ncomponents=10)

test_that("getExplanatoryPCs matches with a reference function", {
    expect_identical(nrow(exppcs), 10L)
    expect_identical(colnames(exppcs), colnames(colData(normed)))
    normed <- runPCA(normed, ncomponents=nrow(exppcs))

    for (v in colnames(varexp)) {
        X <- colData(normed)[[v]]
        Y <- reducedDim(normed, "PCA")

        # Using lm() per PC, which is a bit slow but ensures we get a reference R2.
        output <- numeric(ncol(Y))
        for (g in seq_along(output)) {
            y <- Y[,g]
            fit <- lm(y ~ X)
            output[g] <- suppressWarnings(summary(fit)$r.squared)
        }

        expect_equal(output, unname(exppcs[,v]))
    }
})

test_that("getExplanatoryPCs responds to PC-specific options", {
    # Responds to differences in the reduced dimension slot.
    blah <- normed
    normed2 <- runPCA(normed, ncomponents=10)
    reducedDim(blah, "WHEE") <- reducedDim(normed2, "PCA")
    expect_identical(res <- getExplanatoryPCs(normed2), getExplanatoryPCs(blah, use_dimred="WHEE"))
    expect_identical(nrow(res), 10L)

    reducedDim(blah, "WHEE") <- reducedDim(normed2, "PCA")[,1:2]
    expect_identical(getExplanatoryPCs(normed2)[1:2,], getExplanatoryPCs(blah, use_dimred="WHEE"))
    
    # Correctly re-runs in the absence of PCs.
    expect_identical(res <- getExplanatoryPCs(normed, ncomponents=2), getExplanatoryPCs(blah, use_dimred="WHEE"))
    expect_identical(nrow(res), 2L)

    expect_identical(res <- getExplanatoryPCs(normed, ncomponents=10), getExplanatoryPCs(normed2))
    expect_identical(nrow(res), 10L)
    
    res <- getExplanatoryPCs(normed, ncomponents=Inf)
    expect_identical(nrow(res), min(dim(normed))) 

    # Correctly truncates existing PCs.
    expect_identical(res <- getExplanatoryPCs(normed2, ncomponents=2), getExplanatoryPCs(blah, use_dimred="WHEE"))
    expect_identical(nrow(res), 2L)

    expect_identical(getExplanatoryPCs(normed2, ncomponents=Inf), getExplanatoryPCs(normed)) # ignores Inf, as it's maxed out.

    # Forcibly re-runs when necessary.    
    expect_false(identical(getExplanatoryPCs(normed2), getExplanatoryPCs(blah, use_dimred="WHEE", ncomponents=10)))
    expect_identical(getExplanatoryPCs(normed2), getExplanatoryPCs(blah, use_dimred="WHEE", rerun=TRUE, ncomponents=10))
})

test_that("getExplanatoryPCs responds to getVarianceExplained options", {
    # Responds to choice of variable.
    expect_identical(exppcs[,1,drop=FALSE], getExplanatoryPCs(normed, variables=colnames(varexp)[1]))
    expect_identical(exppcs[,c(3,2),drop=FALSE], getExplanatoryPCs(normed, variables=colnames(varexp)[c(3,2)]))
    expect_identical(exppcs[,,drop=FALSE], getExplanatoryPCs(normed, variables=colnames(varexp)))

    # Unaffected by chunk size.
    expect_identical(exppcs, getExplanatoryPCs(normed, ncomponents=nrow(exppcs), chunk=10))
    expect_identical(exppcs, getExplanatoryPCs(normed, ncomponents=nrow(exppcs), chunk=1))
    expect_identical(exppcs, getExplanatoryPCs(normed, ncomponents=nrow(exppcs), chunk=100000))
})

#############################################################
# plotExplanatoryPCs() tests:

test_that("plotExplanatoryPCs works with PC choice options", {
    out <- plotExplanatoryPCs(normed, npcs=nrow(exppcs))
    ref <- plotExplanatoryPCs(exppcs)
    expect_s3_class(out, "ggplot")
    expect_identical(out$data, ref$data)

    # Handles situations where different numbers of PCs are requested.
    out <- plotExplanatoryPCs(normed, npcs=5)
    allpcs <- runPCA(normed, ncomponents=5)
    ref <- plotExplanatoryPCs(allpcs)
    expect_s3_class(out, "ggplot")
    expect_identical(out$data, ref$data)

    out <- plotExplanatoryPCs(normed, npcs=Inf)
    allpcs <- runPCA(normed, ncomponents=Inf)
    ref <- plotExplanatoryPCs(allpcs)
    expect_s3_class(out, "ggplot")
    expect_identical(out$data, ref$data)
})

test_that("plotExplanatoryPCs responds to choice of number of variables", {
    maxes <- apply(exppcs, 2, max, na.rm=TRUE)

    out <- plotExplanatoryPCs(normed, nvars_to_plot=2, npcs=nrow(exppcs))
    ref <- plotExplanatoryPCs(exppcs[,order(maxes, decreasing=TRUE)[1:2]])
    expect_s3_class(out, "ggplot")
    expect_identical(out$data, ref$data)

    out <- plotExplanatoryPCs(normed, nvars_to_plot=Inf, npcs=nrow(exppcs))
    ref <- plotExplanatoryPCs(exppcs)
    expect_s3_class(out, "ggplot")
    expect_identical(out$data, ref$data)

    out <- plotExplanatoryPCs(normed, nvars_to_plot=0, npcs=nrow(exppcs))
    ref <- plotExplanatoryPCs(exppcs[,0,drop=FALSE])
    expect_s3_class(out, "ggplot")
    expect_identical(out$data, ref$data)
})

test_that("plotExplanatoryPCs handles silly inputs.", {
    expect_s3_class(suppressWarnings(plotExplanatoryPCs(exppcs[0,,drop=FALSE])), "ggplot")
    expect_s3_class(plotExplanatoryPCs(exppcs[,0,drop=FALSE]), "ggplot")
})
