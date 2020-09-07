# simscaleR

Large scale similarity calculations with support for:
* Thresholds & sparse representations of the similarity matrix (based on the `Matrix` package)
* Parallel calculations, locally or using a standard R cluster object (from `parallel` package). We also include helper functions to decide how to split the calculations efficiently  
* "Injection" of domain knowledge, in the form of external information on groups of nodes that belong to the same higher-level entity. See details & examples below.

## Background

A smart dev-ops engineer once told me: 
> Before I give you a cluster, show me you can fully utilize a single machine

With that in mind I created this package to share my experiences working on large scale similarity projects. The main problems I've encountered were

1. Scaling up similarity calculations and representation: Specifically how to better distribute calculations (focus on utilizing a single, multi-core machine as efficiently as possible) and efficiently store the result, especially when low values are not very interesting (making the similarity matrix sparse)
2. Injecting domain knowledge: In many cases similarity is calculated at different levels - for example similarity between messages to find similar users or similarity between images to find similar products. These cases require a way to aggregate similarities between sets of arbitrary lower level entities (messages / images) to represent similarity between higher level entities. For example the similarity between products can be the sum of all similarities between their respective sets of images. 

This package contains tools for handling both of the above problems. 

### Assumptions

* Data is numeric (binary, integers or real numbers). For categorical data please convert first (embedding, 1-hot encoding or other methods)

* The `NxM` matrix of features (`N` rows, `M` features) can be contained in memory, or at least expose a `Matrix` API. 


## Installation
`devtools::install_github(repo = 'ytoren/simscaleR')`

## Usage

### Similarity calculations 

The package contains functions that automatically estimate resources of the local machine. See [vignette](vignettes/estimating-local-resources.Rmd). You can also control the calculation manually using lower level functions. See `?sim_blocksR`

### Similarity matrix manipulation \ domain knowledge injection

The package contains 2 functions that allow for such aggregations in 2 stages: 

* Step 1: Shuffle matrix rows, so that all rows that belong to the same entity are next to one another (in case they are not already sorted this way). See `?sim_matrix_shuffle`
* Step 2: combine the rows of the similarity matrix using an aggregation function (default is a simple sum). See `?merge_by_partition`

The end result is a similarity smaller similarity matrix that represents similarity between higher level entities. 




