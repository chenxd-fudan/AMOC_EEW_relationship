#!/bin/csh -f
#===============================================================================
#   Process CMIP6 monthly atmospheric and oceanic variables and generate
#   regridded 1 deg x 1 deg climatological fields for selected periods.
#
# Supported data groups in this script:
#   1. Amon_surface_variables       : period-mean atmospheric surface variables
#   2. Omon_ocean                   : period-mean ocean variables
#   3. Omon_tos_monthly_climatology : monthly climatology of tos
#
# Workflow:  monthly files -> mergetime -> yearmean -> selyear -> timmean -> selgridname -> remapbil
#            monthly files -> mergetime -> selyear -> ymonmean -> selgridname -> remapbil
#
#   - Period-mean groups output one climatological mean field for the selected
#     period for HIST(1980-1999), FUT (2080-2099), or piControl (all simulation years).
#===============================================================================

#===============================================================================
# 1. User-defined global settings
#===============================================================================

# Select which data groups to process.
# Keep only that group in this list.
set process_groups = ( Amon_surface_variables Omon_ocean Omon_tos_monthly_climatology )

# Realization numbers to process. 
set runs = ( 1 )

# Native-grid selector used by CDO. For most models this is 1. Some models, such as IPSL or MIROC in some variables, may require 2 or 4.
# Check with: cdo sinfov input_file.nc
set grid_name = 1

# Common output root and target grid file.
set output_root = /Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6
set grid_file   = /Users/chenxiaodan/Documents/MOC/CDOscript/grid_1.0x1.0

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
    # Group-specific settings
    #---------------------------------------------------------------------------
    switch ( $group )

        case Amon_surface_variables:
            # This group is designed for surface atmospheric variables and top-of-atmosphere flux variables.
            # Modify the variable list as needed.  Keeping only selected variables here
            set variables        = ( tauu tauv hfls hfss rlds rlus rsds rsus rlut rsut pr)
            set mip_table        = Amon
            set averaging_method = period_mean
            set experiment       = ssp245 # historical ssp126 ssp245 ssp370 ssp585
            #   historical -> 1980-1999
            #   SSPs       -> 2080-2099
            set input_root       = /Volumes/CMIP_Ocean
            set models = ( \
                ACCESS-CM2 ACCESS-ESM1-5 CanESM5 CanESM5-1 CAS-ESM2-0 \
                CESM2 CESM2-WACCM CIESM CMCC-ESM2 CMCC-CM2-SR5 \
                CNRM-CM6-1 CNRM-ESM2-1 EC-Earth3-CC FGOALS-f3-L FGOALS-g3 \
                GFDL-ESM4 GISS-E2-1-G GISS-E2-2-G HadGEM3-GC31-LL \
                INM-CM4-8 INM-CM5-0 IPSL-CM6A-LR MIROC-ES2L MIROC6 \
                MPI-ESM1-2-HR MPI-ESM1-2-LR MRI-ESM2-0 NorESM2-LM \
                NorESM2-MM UKESM1-0-LL \
            )
            breaksw

        case Omon_ocean:
            # Ocean monthly variables for period-mean fields. Keeping only selected variables here
            set variables        = ( tos thetao wo uo vo )
            set mip_table        = Omon
            set averaging_method = period_mean
            set experiment       = ssp245 # historical ssp126 ssp245 ssp370 ssp585
            #   historical -> 1980-1999
            #   SSPs       -> 2080-2099
            set input_root       = /Volumes/CMIP_Ocean2
            set models = ( \
                ACCESS-CM2 ACCESS-ESM1-5 CanESM5 CanESM5-1 CAS-ESM2-0 \
                CESM2 CESM2-WACCM CIESM CMCC-ESM2 CMCC-CM2-SR5 \
                CNRM-CM6-1 CNRM-ESM2-1 EC-Earth3-CC FGOALS-f3-L FGOALS-g3 \
                GFDL-ESM4 GISS-E2-1-G GISS-E2-2-G HadGEM3-GC31-LL \
                INM-CM4-8 INM-CM5-0 IPSL-CM6A-LR MIROC-ES2L MIROC6 \
                MPI-ESM1-2-HR MPI-ESM1-2-LR MRI-ESM2-0 NorESM2-LM \
                NorESM2-MM UKESM1-0-LL \
            )            
            breaksw

        case Omon_tos_monthly_climatology:
            # Ocean surface temperature monthly climatology. 
            # Output contains 12 fields: Jan, Feb, ..., Dec climatological means.
            set variables        = ( tos )
            set mip_table        = Omon
            set averaging_method = monthly_climatology
            set experiment       = ssp245 # historical ssp126 ssp245 ssp370 ssp585
            #   historical -> 1980-1999
            #   SSPs       -> 2080-2099
            set input_root       = /Volumes/CMIP_Ocean2
            set models = ( \
                ACCESS-CM2 ACCESS-ESM1-5 CanESM5 CanESM5-1 CAS-ESM2-0 \
                CESM2 CESM2-WACCM CIESM CMCC-ESM2 CMCC-CM2-SR5 \
                CNRM-CM6-1 CNRM-ESM2-1 EC-Earth3-CC FGOALS-f3-L FGOALS-g3 \
                GFDL-ESM4 GISS-E2-1-G GISS-E2-2-G HadGEM3-GC31-LL \
                INM-CM4-8 INM-CM5-0 IPSL-CM6A-LR MIROC-ES2L MIROC6 \
                MPI-ESM1-2-HR MPI-ESM1-2-LR MRI-ESM2-0 NorESM2-LM \
                NorESM2-MM UKESM1-0-LL \
            )
            breaksw

        default:
            echo "ERROR: Unknown data group: $group"
            echo "       Supported groups: Amon_surface_variables Omon_ocean Omon_tos_monthly_climatology"
            exit 1
    endsw

    switch ( $experiment )
        case historical:
            set year_start = 1980
            set year_end   = 1999
            breaksw
        case ssp126:
        case ssp245:
        case ssp370:
        case ssp585:
            set year_start = 2080
            set year_end   = 2099
            breaksw
        default:
            echo "ERROR: Unsupported experiment: $experiment"
            echo "       Experiments are: historical ssp126 ssp245 ssp370 ssp585"
            exit 1
    endsw


    echo "======================================================================"
    echo "Data group       : $group"
    echo "MIP table        : $mip_table"
    echo "Experiment       : $experiment"
    echo "Years            : ${year_start}-${year_end}"
    echo "Averaging method : $averaging_method"
    echo "Variables        : $variables"
    echo "Input root       : $input_root"
    echo "======================================================================"

    foreach model ( $models )
    foreach var ( $variables )
    foreach run ( $runs )

        echo "----------------------------------------------------------------------"
        echo "Processing model=${model}, variable=${var}, experiment=${experiment}, run=r${run}"
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
            set output_file = ${output_dir}/${var}_${mip_table}_${model}_${experiment}_r${run}i1_${year_start}-${year_end}_timmean_1x1.nc
        else if ( "$averaging_method" == "monthly_climatology" ) then
            set output_file = ${output_dir}/${var}_${mip_table}_${model}_${experiment}_r${run}i1_${year_start}-${year_end}_ymonmean_1x1.nc
        else
            echo "ERROR: Unknown averaging method: $averaging_method"
            continue
        endif

        if ( -f "$output_file" ) then
            echo "Output file already exists. Skip: $output_file"
            continue
        endif

        # Match all available monthly files for this model-variable-realization.
        set input_files = ( `ls ${input_dir}/${var}_${mip_table}_${model}_${experiment}_r${run}i1*.nc 2>/dev/null` )

        if ( $#input_files == 0 ) then
            echo "WARNING: No input files found for pattern:"
            echo "         ${input_dir}/${var}_${mip_table}_${model}_${experiment}_r${run}i1*.nc"
            continue
        endif

        # Use a model-variable-run-specific temporary directory to avoid conflicts.
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

        #-------------------------------------------------------------------
        # Step 1: Merge monthly files along time.
        #-------------------------------------------------------------------
        cdo -O -mergetime $input_files "$merged_file"
        if ( $status != 0 ) then
            echo "ERROR: cdo mergetime failed for ${model} ${var} r${run}."
            rm -rf "$tmp_dir"
            continue
        endif

        #-------------------------------------------------------------------
        # Step 2: Calculate the requested climatological field.
        #-------------------------------------------------------------------
        if ( "$averaging_method" == "period_mean" ) then

            # Annual means followed by averaging over selected years.
            set annual_file          = ${tmp_dir}/annual_mean.nc
            set annual_selected_file = ${tmp_dir}/annual_mean_${year_start}-${year_end}.nc
            set climatology_file     = ${tmp_dir}/period_mean_${year_start}-${year_end}.nc

            cdo -O -yearmean "$merged_file" "$annual_file"
            if ( $status != 0 ) then
                echo "ERROR: cdo yearmean failed for ${model} ${var} r${run}."
                rm -rf "$tmp_dir"
                continue
            endif

            cdo -O -selyear,${year_start}/${year_end} "$annual_file" "$annual_selected_file"
            if ( $status != 0 ) then
                echo "ERROR: cdo selyear failed for ${model} ${var} r${run}."
                rm -rf "$tmp_dir"
                continue
            endif

            cdo -O -timmean "$annual_selected_file" "$climatology_file"
            if ( $status != 0 ) then
                echo "ERROR: cdo timmean failed for ${model} ${var} r${run}."
                rm -rf "$tmp_dir"
                continue
            endif

        else if ( "$averaging_method" == "monthly_climatology" ) then

            # Select target years from monthly data, then calculate the
            # multi-year mean for each calendar month.
            set monthly_selected_file = ${tmp_dir}/monthly_${year_start}-${year_end}.nc
            set climatology_file      = ${tmp_dir}/monthly_climatology_${year_start}-${year_end}.nc

            cdo -O -selyear,${year_start}/${year_end} "$merged_file" "$monthly_selected_file"
            if ( $status != 0 ) then
                echo "ERROR: cdo selyear failed for ${model} ${var} r${run}."
                rm -rf "$tmp_dir"
                continue
            endif

            cdo -O -ymonmean "$monthly_selected_file" "$climatology_file"
            if ( $status != 0 ) then
                echo "ERROR: cdo ymonmean failed for ${model} ${var} r${run}."
                rm -rf "$tmp_dir"
                continue
            endif

        endif

        #-------------------------------------------------------------------
        # Step 3: Select the desired native grid.
        # Modify grid_name if CDO reports that grid 1 is not appropriate.
        #-------------------------------------------------------------------
        cdo -O -selgridname,${grid_name} "$climatology_file" "$selected_grid_file"
        if ( $status != 0 ) then
            echo "ERROR: cdo selgridname failed for ${model} ${var} r${run}."
            echo "       Please inspect the file with: cdo sinfov input_file.nc"
            rm -rf "$tmp_dir"
            continue
        endif

        #-------------------------------------------------------------------
        # Step 4: Remap to a regular 1 deg x 1 deg grid.
        #-------------------------------------------------------------------
        cdo -O -remapbil,"$grid_file" "$selected_grid_file" "$output_file"
        if ( $status != 0 ) then
            echo "ERROR: cdo remapbil failed for ${model} ${var} r${run}."
            rm -rf "$tmp_dir"
            continue
        endif

        # Remove temporary files after successful processing.
        rm -rf "$tmp_dir"

        echo "DONE: $output_file"

    end
    end
    end

end

exit 0