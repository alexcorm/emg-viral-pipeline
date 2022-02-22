process hmmscan {
      publishDir "${params.output}/${name}/${params.hmmerdir}/${params.db}", mode: 'copy', pattern: "${set_name}_${params.db}_hmmscan.tbl"
      label 'hmmscan'

    input:
      tuple val(name), val(set_name), file(faa) 
      file(db)
    
    output:
      tuple val(name), val(set_name), file("${set_name}_${params.db}_hmmscan.tbl"), file(faa)
    
    script:
    """
    # Load hmmer-mpi from datarmor
    . /appli/bioinfo/hmmer-mpi/3.3/env.sh

    if [[ ${params.db} == "viphogs" ]]; then
      if [[ ${params.version} == "v1" ]]; then
        mpiexec_mpt -n ${task.mpiprocs} hmmscan --mpi --noali -E "0.001" --domtblout ${set_name}_${params.db}_hmmscan.tbl ${db}/${db}.hmm ${faa} >& hmmscan.log 2>&1
      else
        mpiexec_mpt -n ${task.mpiprocs} hmmscan --mpi --noali --cut_ga --domtblout ${set_name}_${params.db}_hmmscan_cutga.tbl ${db}/${db}.hmm ${faa} >& hmmscan.log 2>&1
        #filter evalue for models that dont have any GA cutoff
        awk '{if(\$1 ~ /^#/){print \$0}else{if(\$7<0.001){print \$0}}}' ${set_name}_${params.db}_hmmscan_cutga.tbl > ${set_name}_${params.db}_hmmscan.tbl
      fi
    else
      mpiexec_mpt -n ${task.mpiprocs} hmmscan --mpi --noali -E "0.001" --domtblout ${set_name}_${params.db}_hmmscan.tbl ${db}/${db}.hmm ${faa} >& hmmscan.log 2>&1
    fi
    """
}
