#!/bin/csh -f
#===============================================================================
#   Process NAHosMIP u03-hos outputs and generate regridded 1 deg x 1 deg files.
#
# Main outputs:
#   1. Annual-mean atmospheric variables.
#   2. Annual-mean ocean variables.
#   3. Additional monthly-mean output for tos.
#
# Experiment:
#   u03-hos
#
# Workflow: 
#   monthly files -> mergetime -> yearmean -> selgridname -> remapbil -> sellonlatbox
#   monthly files -> mergetime -> selgridname -> remapbil -> sellonlatbox

#===============================================================================

#===============================================================================
# 1. User-defined global settings
#===============================================================================

# Select which processing blocks to run.
# To run only one block, keep only that block in this list.
set process_groups = ( Amon_annual_variables Omon_annual_variables Omon_tos_monthly )

# NAHosMIP experiment name.
set experiment = u03-hos

# Input and output roots.
set input_root  = /Volumes/CMIP_Ocean/NAHosMIP
set output_root = /Users/chenxiaodan/Documents/MOC/PostProcData_NAHos

# Target 1 deg x 1 deg grid file.
set grid_file = /Users/chenxiaodan/Documents/MOC/CDOscript/grid_1.0x1.0

# Native-grid selector used by CDO.
# For most files this is 1. Check with:
#   cdo sinfov input_file.nc
set grid_name = 1

# NAHosMIP models
  set models = ( CanESM5 CESM2 EC-Earth3 HadGEM3-GC31-LL HadGEM3-GC31-MM IPSL-CM6A-LR MPI-ESM1-2-HR MPI-ESM1-2-LR )


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

    #---------------------------------------------------------------------------
    # 3.1 Group-specific settings
    #---------------------------------------------------------------------------
    switch ( $group )

        case Amon_annual_variables:
            # Atmospheric variables to be saved as annual means.
            # Modify this list according to the variables used in your analysis.
            set variables = ( pr tas rlut rsut hfls hfss rlds rlus rsds rsus psl tauu tauv )
            set temporal_method = annual_mean
            # Amon output is global.
            set lon_min = 0
            set lon_max = 360
            set lat_min = -90
            set lat_max = 90
            set region_label = global
            breaksw

        case Omon_annual_variables:
            # Ocean variables to be saved as annual means.
            # Modify this list according to the variables used in your analysis.
            set variables = ( tos wo thetao uo vo mlotst hfds tauuo tauvo )
            set temporal_method = annual_mean
            # Omon output is restricted to 70S-70N
            set lon_min = 0
            set lon_max = 360
            set lat_min = -70
            set lat_max = 70
            set region_label = 70S70N
            breaksw

        case Omon_tos_monthly:
            # Additional monthly-mean output for tos.
            set variables = ( tos )
            set temporal_method = monthly_mean
            set lon_min = 0
            set lon_max = 360
            set lat_min = -90
            set lat_max = 90
            set region_label = global
            breaksw

        default:
            echo "ERROR: Unknown processing group: $group"
            echo "       Supported groups:"
            echo "       Amon_annual_variables"
            echo "       Omon_annual_variables"
            echo "       Omon_tos_monthly"
            exit 1
    endsw

    set lonlat_box = "${lon_min},${lon_max},${lat_min},${lat_max}"

    echo "======================================================================"
    echo "Processing group : $group"
    echo "Experiment       : $experiment"
    echo "Temporal method  : $temporal_method"
    echo "Variables        : $variables"
    echo "Models           : $models"
    echo "Longitude range  : ${lon_min}-${lon_max}E"
    echo "Latitude range   : ${lat_min}-${lat_max}N"
    echo "Input root       : $input_root"
    echo "Output root      : $output_root"
    echo "======================================================================"

    foreach model ( $models )
    foreach var ( $variables )

        echo "----------------------------------------------------------------------"
        echo "Processing model=${model}, variable=${var}, experiment=${experiment}"
        echo "----------------------------------------------------------------------"

        set input_dir  = ${input_root}/${var}/${model}/${experiment}
        set output_dir = ${output_root}/${var}

        if ( ! -d "$input_dir" ) then
            echo "WARNING: Input directory does not exist. Skip:"
            echo "         $input_dir"
            continue
        endif

        if ( ! -d "$output_dir" ) then
            mkdir -p "$output_dir"
            if ( $status != 0 ) then
                echo "ERROR: Failed to create output directory:"
                echo "       $output_dir"
                continue
            endif
        endif

        if ( "$temporal_method" == "annual_mean" ) then
            if ( "$region_label" == "global" ) then
                set output_file = ${output_dir}/${var}_${model}_${experiment}_annualmean_1x1.nc
            else
                set output_file = ${output_dir}/${var}_${model}_${experiment}_annualmean_1x1_${region_label}.nc
            endif
        else if ( "$temporal_method" == "monthly_mean" ) then
            if ( "$region_label" == "global" ) then
                set output_file = ${output_dir}/${var}_${model}_${experiment}_monthlymean_1x1.nc
            else
                set output_file = ${output_dir}/${var}_${model}_${experiment}_monthlymean_1x1_${region_label}.nc
            endif
        else
            echo "ERROR: Unknown temporal method: $temporal_method"
            continue
        endif

        if ( -f "$output_file" ) then
            echo "Output file already exists. Skip:"
            echo "    $output_file"
            continue
        endif

        # Match all available NetCDF files for this model-variable-experiment.
        set input_files = ( `ls ${input_dir}/*.nc 2>/dev/null` )

        if ( $#input_files == 0 ) then
            echo "WARNING: No input files found in:"
            echo "         $input_dir"
            continue
        endif

        # Use a model-variable-specific temporary directory to avoid conflicts.
        set tmp_dir = ${output_dir}/tmp_${group}_${var}_${model}_${experiment}_$$
        mkdir -p "$tmp_dir"
        if ( $status != 0 ) then
            echo "ERROR: Failed to create temporary directory:"
            echo "       $tmp_dir"
            continue
        endif

        set merged_file        = ${tmp_dir}/merged_monthly.nc
        set annual_file        = ${tmp_dir}/annual_mean.nc
        set selected_grid_file = ${tmp_dir}/${temporal_method}_grid${grid_name}.nc
        set remapped_file      = ${tmp_dir}/${temporal_method}_1x1.nc

        echo "Input directory : $input_dir"
        echo "Output file     : $output_file"
        echo "Temporary dir   : $tmp_dir"

        #-------------------------------------------------------------------
        # Step 1: Merge all available files along the time dimension.
        #-------------------------------------------------------------------
        cdo -O -mergetime $input_files "$merged_file"
        if ( $status != 0 ) then
            echo "ERROR: cdo mergetime failed for ${model} ${var}."
            rm -rf "$tmp_dir"
            continue
        endif

        #-------------------------------------------------------------------
        # Step 2: Temporal processing.
        #
        # For annual_mean:
        #   Convert monthly means to annual means.
        #   The output keeps one annual-mean field for each year.
        #
        # For monthly_mean:
        #   Keep the monthly-mean time series after mergetime.
        #   This is used for the additional tos monthly output.
        #-------------------------------------------------------------------
        if ( "$temporal_method" == "annual_mean" ) then

            cdo -O -yearmean "$merged_file" "$annual_file"
            if ( $status != 0 ) then
                echo "ERROR: cdo yearmean failed for ${model} ${var}."
                rm -rf "$tmp_dir"
                continue
            endif

            set temporal_file = "$annual_file"

        else if ( "$temporal_method" == "monthly_mean" ) then

            set temporal_file = "$merged_file"

        endif

        #-------------------------------------------------------------------
        # Step 3: Select the desired native grid.
        #
        # If this step fails, inspect the input file with:
        #   cdo sinfov input_file.nc
        # and adjust grid_name above.
        #-------------------------------------------------------------------
        cdo -O -selgridname,${grid_name} "$temporal_file" "$selected_grid_file"
        if ( $status != 0 ) then
            echo "ERROR: cdo selgridname failed for ${model} ${var}."
            rm -rf "$tmp_dir"
            continue
        endif

        #-------------------------------------------------------------------
        # Step 4: Remap to a regular 1 deg x 1 deg grid.
        #-------------------------------------------------------------------
        cdo -O -remapbil,"$grid_file" "$selected_grid_file" "$remapped_file"
        if ( $status != 0 ) then
            echo "ERROR: cdo remapbil failed for ${model} ${var}."
            rm -rf "$tmp_dir"
            continue
        endif

        #-------------------------------------------------------------------
        # Step 5: Select the target longitude-latitude box.
        #-------------------------------------------------------------------
        cdo -O -sellonlatbox,${lonlat_box} "$remapped_file" "$output_file"
        if ( $status != 0 ) then
            echo "ERROR: cdo sellonlatbox failed for ${model} ${var}."
            rm -rf "$tmp_dir"
            continue
        endif

        # Remove temporary files after successful processing.
        rm -rf "$tmp_dir"

        echo "DONE: $output_file"

    end
    end

end

exit 0