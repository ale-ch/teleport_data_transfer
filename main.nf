#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PIPELINE WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Parse rows from txt file
def parse_txt(src_list_path) {
    return Channel
        .fromPath(src_list_path)
        .splitText()  // Split into lines
}

// Process for transferring data
process transfer_data {
    memory "1G"
    cpus 1
    tag "transfer_data"

    input:
    val(line),  // Each line from the parsed text file
    val(dst)    // Destination parameter

    script:
    """
    echo "Transferring file: ${line} to destination: ${dst}"

    # Using singularity to transfer data
    singularity exec -B /hpcnfs/ /hpcnfs/techunits/bioinformatics/singularity/teleport-distroless_14.0.3.sif \
    tsh scp -r --proxy teleport.ieo.it "${line}" "dimaimaging.garr.cloud.ct:${dst}"
    """
}

// Workflow definition
workflow {    
    // Parse text file lines
    parsed_lines = parse_txt(params.src_list_path)

    // Transfer data by pairing each line with the destination
    params_transfer = parsed_lines.map { line -> tuple(line, params.dst) }

    // Run transfer_data process
    transfer_data(params_transfer)
}
