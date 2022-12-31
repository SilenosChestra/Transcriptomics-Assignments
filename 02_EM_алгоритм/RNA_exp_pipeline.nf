params.results_dir = "results/"
params.index_file = "${PWD}/human_transcriptome.idx"
SRA_list = params.SRA.split(",")


log.info ""
log.info "  Q U A L I T Y   C O N T R O L  "
log.info "================================="
log.info "SRA number         : ${SRA_list}"
log.info "Index file         : ${params.index_file}"
log.info "Results location   : ${params.results_dir}"


process DownloadFastQ {

  input:
    val sra

  output:
    path "${sra}"

  script:
    """
    fasterq-dump ${sra} -o ${sra} -O ${sra}
    """
}

process Quant {
  publishDir "${params.results_dir}"
 
  input:
    path x

  output:
    path "${x}_expressions/*"

  script:
    """
    kallisto quant -i ${params.index_file} -o ${x}_expressions/ ${x}/*.fastq
    """
}


workflow {
  data = Channel.of( SRA_list )
  DownloadFastQ(data)
  Quant( DownloadFastQ.out.collect() )
}

