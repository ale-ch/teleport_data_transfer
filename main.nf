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
    tuple(
        val(line),  // Each line from the parsed text file
        val(dst)    // Destination parameter
    )
    

    script:
    """
    echo Transferring file: "${line}" to destination: "${dst}"    
    """
    // # Using singularity to transfer data
    // # singularity exec -B /hpcnfs/ /hpcnfs/techunits/bioinformatics/singularity/teleport-distroless_14.0.3.sif \
    // # tsh scp -r --proxy teleport.ieo.it "${line}" dimaimaging.garr.cloud.ct:"${params.dst}"
    
    // # Check if the file exists at the destination
    // singularity exec -B /hpcnfs/ /hpcnfs/techunits/bioinformatics/singularity/teleport-distroless_14.0.3.sif \
    // tsh ssh --proxy teleport.ieo.it "$DST_HOST" "[[ -f '$DST_FILE' ]]"
    // 
    // # Capture the exit status of the previous command
    // if [ $? -eq 0 ]; then
    //     echo "File already exists at destination: $DST_FILE"
    // else
    //     echo "File does not exist at destination. Proceeding with transfer."
    //     # Transfer the file using scp
    //     singularity exec -B /hpcnfs/ /hpcnfs/techunits/bioinformatics/singularity/teleport-distroless_14.0.3.sif \
    //     tsh scp -r --proxy teleport.ieo.it "$SRC_FILE" "$DST_HOST:$DST_PATH"
    // fi
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