# simscaleR
Large scale similarity calculations with support for:
* Thresholding & a sparse representation of the similarity matrix (based on the `Matrix` package)
* Parallelisation of calculations, locally or using a standard R cluster object (from `parallel` package). We also include helper functions to decide how to split the calculations efficiently  

## Installation
`devtools::install_github(repo = 'ytoren/simscaleR')`