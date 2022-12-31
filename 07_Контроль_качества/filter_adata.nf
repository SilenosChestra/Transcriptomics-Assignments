params.results_dir = "results/"
params.output_dir = "kb_data/"

log.info "${baseDir}"

process kb_count {
	
	output:
	  path "kb_data/"
		 
	script:
	
	  """
	  mkdir kb_data
	  kb count --h5ad -i "$baseDir/index.idx" -g "$baseDir/t2g.txt" -x 10xv2 -t2 -o kb_data/ "$baseDir/SRR8599150_S1_L001_R1_001.fastq.gz" "$baseDir/SRR8599150_S1_L001_R2_001.fastq.gz"
	  """
}

process python_script {
	publishDir "${params.results_dir}"
	
	input:
		path x
	output: 
		path "filtered_adata.h5ad"
		
	script:
		"""
		#!/usr/bin/env python
		import scanpy as sc
		import pandas as pd
		import anndata2ri
		import rpy2.robjects as ro
		import scipy.stats as stats
		anndata2ri.activate()

		adata = sc.read_h5ad("$x/" + "counts_unfiltered/adata.h5ad")

		ro.r("library(DropletUtils)")
		ro.globalenv["adata_raw"] = adata
		df = ro.r('e.out <- emptyDrops(assay(adata_raw))')

		cell_barcodes = df.loc[df.FDR < 0.05]
		adata_emptydrops = adata[cell_barcodes.index]
		adata_emptydrops.write_h5ad("filtered_adata.h5ad")
		"""
		}
workflow {
	kb_count()
	python_script(kb_count.out)
	}

