# simscaleR

Large scale similarity calculations with support for:
* Thresholding & a sparse representation of the similarity matrix (based on the `Matrix` package)
* Parallelisation of calculations, locally or using a standard R cluster object (from `parallel` package). We also include helper functions to decide how to split the calculations efficiently  

## Background

A smart dev ops engineer once told me: 
> Before I give you a cluster, show me you can fully utilize a single machine

With that in mind I created this package to implement some of my learnings on large scale similarity calculations. The main idea is to utilize a single, multi-core machine as efficiently as possible.

### Assumptions

* Data is numeric (binary, integers or reals). For categorical data please convert first (embedding, 1-hot encoding or other methods)

* The $N\times M$ matrix of features ($N$ rows, $M$ features) can be contained in memory, or at least expose a `Matrix` API. 


## Installation
`devtools::install_github(repo = 'ytoren/simscaleR')`

## Usage

### Similarity calculations 

The package contains functions that automatically estimate resources of the local machine. See [vignette]('/vignettes/estimating-local-resources.Rmd'). You can also control the calculation manually using lower level functions. See `?sim_blocksR`

