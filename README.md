# simscaleR

Large scale similarity calculations with support for:
* Thresholding & a sparse representation of the similarity matrix (based on the `Matrix` package)
* Parallelisation of calculations, locally or using a standard R cluster object (from `parallel` package). We also include helper functions to decide how to split the calculations efficiently  
* "Injection" of domain knowledge, in the form of external information on groups of nodes that are similar. See details below.

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

### Similarity matrix manipulation \ domain knowledge injection

Similarity between entities can sometimes be calculated on multiple levels, for example similarity between products based on features, text and multiple images or similarity between users based on multiple messages. Specifically for cases where the similarity is calculated on a "lower level" first (for example images or messages) we need a way to aggregate similarity in a meaningful way to the higher level (products or users correspondingly).  

The package contains 2 functions that allow for such aggregations in 2 stages: 

* Step 1: Shuffle matrix rows, so that all rows that belong to the same entity are next to one another (in case thay are not already pre-sorted this way). See `?sim_matrix_shuffle`
* Step 2: combine the rows of the similarity matrix using an aggregation function (default is a simple sum). See `?merge_by_partition`

The end result is a similarity smaller similarity matrix that represents similarity between higher level entities. 




