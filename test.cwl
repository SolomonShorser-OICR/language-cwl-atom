#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
id: "VariantBam"
label: "VariantBam"

doc: |
    This is the VariantBam tool used in the PCAWG project.
    VariantBam was created by Jeremiah Wala (jwala@broadinstitute.org).
    This CWL wrapper was created by Solomon Shorser.
    For more information about VariantBam, see https://github.com/jwalabroad/VariantBam

dct:creator:
    foaf:name: "Solomon Shorser"
    foaf:mbox: "solomon.shorser@oicr.on.ca"

dct:contributor:
  foaf:name: "Jeremiah Wala"
  foaf:mbox: "jwala@broadinstitute.org"

requirements:
    - class: DockerRequirement
      dockerPull: test_variantbam
    - class: InlineJavascriptRequirement

stdout: stdout.txt
stderr: stderr.txt

inputs:
    - id: "#input-bam"
      type: File?
      inputBinding:
        position: 1
        # prefix: "-i"
    - id: "#outfile"
      type: Any[]?
      inputBinding:
        position: 2
        # prefix: "-o"
    - id: "#input-snv"
      type: File
      inputBinding:
        position: 3
        # prefix: "-l"
    - id: "#input-sv"
      type: File
      inputBinding:
        position: 4
        # prefix: "-l"
    - id: "#input-indel"
      type: File
      inputBinding:
        position: 5
        # prefix: "-l"
    - id: "#snv-padding"
      type: string
    - id: "#sv-padding"
      type: string
    - id: "#indel-padding"
      type: string
    null_filter:
      type: null_thing


arguments:
    valueFrom: |
        ${
            var vcfsToUse = []
            var flattened_oxogs = flatten_nested_arrays(inputs.oxogVCFs)
            var associated_snvs = inputs.tumours_list.associatedVcfs.filter( function(item)
                {
                    return item.indexOf("snv") !== -1
                }
            )
            for (var i in associated_snvs)
            {
                for (var j in flattened_oxogs)
                {
                    //if ( flattened_oxogs[j].basename.indexOf(associated_snvs[i].replace(".vcf.gz","")) !== -1 )
                    {
                        vcfsToUse.push(flattened_oxogs[j])
                    }
                }
            }
            return vcfsToUse
        }
    #   prefix: "-r"
      position: 6
    valueFrom: $( inputs.indel-padding.replace("123","456") )
      position: 7
    valueFrom: |
        $( { svs_for_merge: filterFor("embl-delly",".sv.",inputs.in_vcf) } )
      position: 8

outputs:
    - id: "#minibam"
      type: File
      outputBinding:
        glob: $(inputs.outfile)
      secondaryFiles:
          - "*.bai"

    # - id: "#bai"
    #   type: File
    #   outputBinding:
    #     glob: "*.bai"

baseCommand: [ /opt/variantbam_workspace/run_variant_bam.sh ]
