#!/bin/csh -f
#===============================================================================
#   Process CMIP6 piControl monthly data and generate regridded 1 deg x 1 deg
#   climatological fields using all available years.
#
# Supported data groups in this script:
#   1. Amon_surface_variables       : period-mean atmospheric surface variables
#   2. Omon_ocean                   : period-mean ocean variables
#   3. Omon_tos_monthly_climatology : monthly climatology of tos
#
# Experiment:
#   piControl
#
# Workflow:  monthly files -> mergetime -> yearmean -> timmean -> selgridname -> remapbil
#            monthly files -> mergetime -> ymonmean -> selgridname -> remapbil
#
#===============================================================================

#===============================================================================
# 1. User-defined global settings
#===============================================================================

# Select which data groups to process.
# To process only one group, keep only that group in this list.
set process_groups = ( Amon_surface_variables Omon_ocean Omon_tos_monthly_climatology )

# CMIP6 experiment name.
# CMIP6 standard spelling is piControl.
# If your local directories and filenames use lower-case picontrol, set this to picontrol.
set experiment = piControl

# Realization numbers to process.
# For example, run = 1 matches files beginning with r1i1*.
set runs = ( 1 )

# Native-grid selector used by CDO. For most models this is 1.
# Check with: cdo sinfov input_file.nc
# Some models, such as IPSL or MIROC in some variables, may require 2 or 4.
set grid_name = 1

# Common output root and target grid file.
set output_root = /Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6
set grid_file   = /Users/chenxiaodan/Documents/MOC/CDOscript/grid_1.0x1.0

# Output period label. Since piControl uses all available years, no year range is given.
set period_label = all_years

#===============================================================================
# 2. Basic checks
#===============================================================================

if ( ! -e "$grid_file" ) then
    echo "ERROR: Target grid file not found: $grid_file"
    exit 1
endif

which cdo >& /dev/null
if ( $status != 0 ) then
    echo "ERROR: CDO was not found. Please load or install CDO before running this script."
    exit 1
endif

#===============================================================================
# 3. Main processing loop
#===============================================================================

foreach group ( $process_groups )

    switch ( $group )

        case Amon_surface_variables:
            # This group is designed for surface atmospheric variables and top-of-atmosphere flux variables.
            # Modify the variable list as needed.  Keeping only selected variables here
            set variables        = ( tauu tauv hfls hfss rlds rlus rsds rsus rlut rsut pr)
            set mip_table        = Amon
            set averaging_method = period_mean
            set averaging_method = period_mean
            set input_root       = /Volumes/CMIP_Ocean
            set models = ( CanESM5 CESM2 EC-Earth3 HadGEM3-GC31-LL HadGEM3-GC31-MM IPSL-CM6A-LR MPI-ESM1-2-HR MPI-ESM1-2-LR )
            breaksw

        case Omon_ocean:
            # Ocean monthly variables for period-mean fields. Keeping only selected variables here
            set variables        = ( tos thetao wo uo vo )
            set mip_table        = Omon
            set averaging_method = period_mean
            set averaging_method = period_mean
            set input_root       = /Volumes/CMIP_Ocean2
            set models = ( CanESM5 CESM2 EC-Earth3 HadGEM3-GC31-LL HadGEM3-GC31-MM IPSL-CM6A-LR MPI-ESM1-2-HR MPI-ESM1-2-LR )
            breaksw

        case Omon_tos_monthly_climatology:
            # Ocean surface temperature monthly climatology. 
            # Output contains 12 fields: Jan, Feb, ..., Dec climatological means.
            set variables        = ( tos )
            set mip_table        = Omon
            set averaging_method = monthly_climatology
            set input_root       = /Volumes/CMIP_Ocean2
            set models = ( CanESM5 CESM2 EC-Earth3 HadGEM3-GC31-LL HadGEM3-GC31-MM IPSL-CM6A-LR MPI-ESM1-2-HR MPI-ESM1-2-LR )
            breaksw

        default:
            echo "ERROR: Unknown data group: $group"
            echo "       Supported groups: Amon_surface_variables Omon_ocean Omon_tos_monthly_climatology"
            exit 1
    endsw

    echo "======================================================================"
    echo "Data group       : $group"
    echo "MIP table        : $mip_table"
    echo "Experiment       : $experiment"
    echo "Analysis period  : $period_label"
    echo "Averaging method : $averaging_method"
    echo "Variables        : $variables"
    echo "Input root       : $input_root"
    echo "======================================================================"

    foreach model ( $models )
    foreach var ( $variables )
    foreach run ( $runs )

        echo "----------------------------------------------------------------------"
        echo "Processing model=${model}, variable=${var}, experiment=${experiment}, run=r${run}i1*"
        echo "----------------------------------------------------------------------"

        set input_dir  = ${input_root}/cmip6_${experiment}/${var}/${model}
        set output_dir = ${output_root}/${var}/${experiment}_r${run}

        if ( ! -d "$input_dir" ) then
            echo "WARNING: Input directory does not exist. Skip: $input_dir"
            continue
        endif

        if ( ! -d "$output_dir" ) then
            mkdir -p "$output_dir"
            if ( $status != 0 ) then
                echo "ERROR: Failed to create output directory: $output_dir"
                continue
            endif
        endif

        if ( "$averaging_method" == "period_mean" ) then
            set output_file = ${output_dir}/${var}_${mip_table}_${model}_${experiment}_r${run}i1_${period_label}_timmean_1x1.nc
        else if ( "$averaging_method" == "monthly_climatology" ) then
            set output_file = ${output_dir}/${var}_${mip_table}_${model}_${experiment}_r${run}i1_${period_label}_ymonmean_1x1.nc
        else
            echo "ERROR: Unknown averaging method: $averaging_method"
            continue
        endif

        if ( -f "$output_file" ) then
            echo "Output file already exists. Skip: $output_file"
            continue
        endif

        set input_files = ( `ls ${input_dir}/${var}_${mip_table}_${model}_${experiment}_r${run}i1*.nc 2>/dev/null` )

        if ( $#input_files == 0 ) then
            echo "WARNING: No input files found for pattern:"
            echo "         ${input_dir}/${var}_${mip_table}_${model}_${experiment}_r${run}i1*.nc"
            continue
        endif

        set tmp_dir = ${output_dir}/tmp_${group}_${var}_${model}_${experiment}_r${run}_$$
        mkdir -p "$tmp_dir"
        if ( $status != 0 ) then
            echo "ERROR: Failed to create temporary directory: $tmp_dir"
            continue
        endif

        set merged_file        = ${tmp_dir}/merged_monthly.nc
        set selected_grid_file = ${tmp_dir}/selected_grid${grid_name}.nc

        echo "Input directory : $input_dir"
        echo "Output file     : $output_file"
        echo "Temporary dir   : $tmp_dir"

        cdo -O -mergetime $input_files "$merged_file"
        if ( $status != 0 ) then
            echo "ERROR: cdo mergetime failed for ${model} ${var} r${run}."
            rm -rf "$tmp_dir"
            continue
        endif

        if ( "$averaging_method" == "period_mean" ) then

            set annual_file      = ${tmp_dir}/annual_mean.nc
            set climatology_file = ${tmp_dir}/period_mean_${period_label}.nc

            cdo -O -yearmean "$merged_file" "$annual_file"
            if ( $status != 0 ) then
                echo "ERROR: cdo yearmean failed for ${model} ${var} r${run}."
                rm -rf "$tmp_dir"
                continue
            endif

            cdo -O -timmean "$annual_file" "$climatology_file"
            if ( $status != 0 ) then
                echo "ERROR: cdo timmean failed for ${model} ${var} r${run}."
                rm -rf "$tmp_dir"
                continue
            endif

        else if ( "$averaging_method" == "monthly_climatology" ) then

            set climatology_file = ${tmp_dir}/monthly_climatology_${period_label}.nc

            cdo -O -ymonmean "$merged_file" "$climatology_file"
            if ( $status != 0 ) then
                echo "ERROR: cdo ymonmean failed for ${model} ${var} r${run}."
                rm -rf "$tmp_dir"
                continue
            endif

        endif

        cdo -O -selgridname,${grid_name} "$climatology_file" "$selected_grid_file"
        if ( $status != 0 ) then
            echo "ERROR: cdo selgridname failed for ${model} ${var} r${run}."
            echo "       Please inspect the file with: cdo sinfov input_file.nc"
            rm -rf "$tmp_dir"
            continue
        endif

        cdo -O -remapbil,"$grid_file" "$selected_grid_file" "$output_file"
        if ( $status != 0 ) then
            echo "ERROR: cdo remapbil failed for ${model} ${var} r${run}."
            rm -rf "$tmp_dir"
            continue
        endif

        rm -rf "$tmp_dir"

        echo "DONE: $output_file"

    end
    end
    end

end

exit 0