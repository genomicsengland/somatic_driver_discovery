process CLEAN_SCRATCH {
    /*
        per chunk: select variants per chunk (creating mini-aggregates) to use in oncodrivefml and dndscv.

    */
    input:
    path(sl_tmpdirs)


    script:
    """
    set -eoux pipefail

    [[ -d ${sl_tmpdirs} ]] && rm -r ${sl_tmpdirs}

    """
}