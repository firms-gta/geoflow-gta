function(action, entity, config) {

	opts <- action$options
	con <- config$software$output$dbi
	options(encoding = "UTF-8")
	
	#scripts
	url_scripts_create_own_tuna_atlas <- "https://raw.githubusercontent.com/firms-gta/geoflow-tunaatlas/master/tunaatlas_scripts/generation"
	source(file.path(url_scripts_create_own_tuna_atlas, "function_overlapped.R")) # adding this function as overlapping is now a recurent procedures for several overlapping 
	source(file.path(url_scripts_create_own_tuna_atlas, "dimension_filtering_function.R"))
	
	#data
	georef_dataset = entity$data$features
	
	
	### filtering on minimum time_start (TRUE  by default) 
    # extract the maximum year of declaration for each source_authority
    max_years <- georef_dataset %>%
      dplyr::group_by(source_authority) %>%
      dplyr::summarise(max_time_start = max(time_start))
    
    # check if not all the source_authority columns have the same maximum year of declaration
    if (length(unique(max_years$max_time_start)) > 1) {
      config$logger.info("Careful, not all the source_authority has the same maximum year of declaration")
      
      # get the minimum time_start of all the maximum time_start of each source_authority
      min_time_start <- min(max_years$max_time_start)
      
      # filter the georef_dataset based on the minimum time_start of all the maximum time_start of each source_authority
      georef_dataset <- georef_dataset %>%
        dplyr::filter(time_start <= min_time_start)
    }
	
	##for now we keep only retained catches
	georef_dataset <- georef_dataset %>%
		dplyr::filter(measurement_type == "RC")
	
	
	#--------Overlapping zones---------------------------------------------------------------------------------------------------------------------
	function_overlapped = function(dataset, con, rfmo_to_keep, rfmo_not_to_keep, 
                              strata =c("geographic_identifier","species", "year" ,"fishing_fleet")
                              , opts = list(), removing_unk = "TRUE"){
	  variable <- opts$fact
	  columns_to_keep <- NULL
	  if (variable == "catch"){
		columns_to_keep<-c("source_authority","species","gear_type","fishing_fleet","fishing_mode","time_start","time_end","geographic_identifier", "measurement_type","measurement_unit","measurement_value")
	  } else if (variable=="effort"){
		columns_to_keep<-c("source_authority","gear_type","fishing_fleet","fishing_mode","time_start","time_end","geographic_identifier", "measurement_type", "measurement_unit","measurement_value")
	  }
	  rfmo_restant <- dataset %>% 
		dplyr::filter(source_authority != rfmo_not_to_keep & source_authority!= rfmo_to_keep)
	  
	  if("year"%in%strata){
		dataset <- dataset %>% dplyr::mutate(year = as.character(lubridate::year(time_start)))
		columns_to_keep <- append(setdiff(columns_to_keep, c("time_start", "time_end")), "year")
	  }
	  strata <- intersect(strata, columns_to_keep)
	  rfmo_to_keep_DT <- dataset %>% dplyr::filter(source_authority == rfmo_to_keep)
	  rfmo_not_to_keep_DT <- dataset %>% dplyr::filter(source_authority == rfmo_not_to_keep)
	  
	  rfmo_not_to_keep_without_equivalent <- dplyr::anti_join(rfmo_not_to_keep_DT, rfmo_to_keep_DT, 
															  by = strata)
	  overlapping_kept <- rbind(rfmo_not_to_keep_without_equivalent, rfmo_to_keep_DT)
	  
	  if(removing_unk){# if we keep data from both rfmos we can remove data labelled as "UNK" as they are not precise enough and they can be duplicated
		overlapping_kept_unk_removed <- overlapping_kept %>% 
		  dplyr::group_by(across(append(strata, "source_authority"))) %>% dplyr::rowwise()%>% dplyr::mutate(overlap = dplyr::n_distinct(source_authority))
		
		overlapping_kept <- overlapping_kept_unk_removed %>% 
		  dplyr::rowwise() %>% 
		  dplyr::filter(!(overlap == 2 && any(dplyr::c_across(strata) %in% c("UNK", "NEI", "99.9","MZZ"))))
		overlapping_kept <- overlapping_kept %>% dplyr::select(-overlap)
	  }
	  if("year" %in% colnames(overlapping_kept)){
		overlapping_kept <- overlapping_kept %>% dplyr::select(-year)
	  }
	  
	  georef_dataset <- rbind(rfmo_restant, overlapping_kept)
	  rm(rfmo_to_keep_DT, rfmo_not_to_keep_DT, rfmo_restant, rfmo_not_to_keep_without_equivalent)
	  gc()


	  out = georef_dataset %>% dplyr::ungroup()
	  return(out)
	}
	# This function handles the processing of overlapping zones.
  handle_overlap <- function(zone_key, rfmo_main, default_strata) {
    # Construct the names of options based on the zone key
    opts_key <- paste0("overlapping_zone_", zone_key, "_data_to_keep")
    strata_key <- paste0("strata_overlap_", zone_key)
    
    # Check if options for the zone are provided
    if (is.null(opts[[opts_key]])) {
      if(rfmo_main[[1]]=="CCSBT"){
        opts[[opts_key]] <- "CCSBT"
      } else {
        config$logger.info(paste0("Please provide a source authority to keep for overlapping zone ", opts_key))
        return()
      }
    }
    
    # Determine which strata options to use, default or provided
    if (!exists(paste0("opts$", strata_key))) {
      options_strata <- default_strata
    } else {
      options_strata <- unlist(strsplit(opts[[strata_key]], split = ","))
    }
    
    # Determine which RFMO data not to keep
    rfmo_not_to_keep <- ifelse(opts[[opts_key]] == rfmo_main[[1]], names(rfmo_main)[[1]], rfmo_main[[1]])
    # Call the overlapping function to process the dataset
    georef_dataset <<- function_overlapped(
      dataset = georef_dataset,
      con = con,
      rfmo_to_keep = opts[[opts_key]],
      rfmo_not_to_keep = rfmo_not_to_keep,
      strata = options_strata,
      opts = opts
    )
  }
  
  
  # Configuration for each overlapping zone checking the one having an impact later and be able to easily remove unusefull steps by commenting
  
  zones_config <- list(
    iattc_wcpfc = list(main = c(WCPFC = "IATTC"), default_strata = c("geographic_identifier", "species", "year")),
    iotc_wcpfc = list(main = c(WCPFC = "IOTC"), default_strata = c("geographic_identifier", "species", "year"))
  )
  
  # Loop over each zone and handle overlap using the defined configuration
  for (zone_key in names(zones_config)) {
    config$logger.info(paste0("Processing zone: ", zone_key))  # Log before processing
    
    # It's a good practice to use tryCatch to understand if errors in handle_overlap are stopping the loop
    tryCatch({
      handle_overlap(zone_key, zones_config[[zone_key]]$main, zones_config[[zone_key]]$default_strata)
    }, error = function(e) {
      message(paste0("Error encountered: ", e))  # Print errors to the console
    })
    
    config$logger.info(paste0("Finished processing zone: ", zone_key))  # Log after processing
  }
  
    #------Spatial aggregation of data------------------------------------------------------------------------------------------------------------------------
  #Spatial Aggregation of data (5deg resolution datasets only: Aggregate data on 5° resolution quadrants)
  #-----------------------------------------------------------------------------------------------------------------------------------------------------------
  if (!is.null(opts$aggregate_on_5deg_data_with_resolution_inferior_to_5deg)) if (opts$aggregate_on_5deg_data_with_resolution_inferior_to_5deg) {
    config$logger.info("Aggregating data that are defined on quadrants or areas inferior to 5° quadrant resolution to corresponding 5° quadrant...")
    source("https://raw.githubusercontent.com/firms-gta/geoflow-tunaatlas/master/sardara_functions/transform_cwp_code_from_1deg_to_5deg.R")
    
    one_degree <- georef_dataset %>% dplyr::filter(substr(geographic_identifier, 1, 1) == "5")
    five_degree <- georef_dataset %>% dplyr::filter(substr(geographic_identifier, 1, 1) == "6")
    one_degree_aggregated <- one_degree %>% dplyr::rowwise() %>% 
      dplyr::mutate(geographic_identifier = transform_cwp_code_from_1deg_to_5deg(geographic_identifier))
    # df_input_not_aggregated <- georef_dataset %>% dplyr::filter(is.null(geographic_identifier))
    # fwrite(df_input_not_aggregated, "data/df_input_not_aggregated.csv")
    georef_dataset <- as.data.frame(rbind(one_degree_aggregated, five_degree))

    config$logger.info("Aggregating data that are defined on quadrants or areas inferior to 5° quadrant resolution to corresponding 5° quadrant OK")
 
  }
  
  
  
  #===========================================================================================================================================================
  #===========================================================================================================================================================
  #>(||||*> FILTERS (MAY APPLY TO LEVEL 0, 1 or 2)
  #===========================================================================================================================================================
  #===========================================================================================================================================================
  #-----------------------------------------------------------------------------------------------------------------------------------------------------------
  #-----------------------------------------------------------------------------------------------------------------------------------------------------------
  if (!is.null(opts$resolution_filter)) {
    
    filtering_resolution_filter <- function(datatable, first_digit) {
      filtered_data <- datatable[substr(datatable$geographic_identifier, 1, 1) == first_digit, ]
      return(filtered_data)
    }
    georef_dataset <- filtering_resolution_filter(georef_dataset, opts$resolution_filter)

  }
  
  #-----------------------------------------------------------------------------------------------------------------------------------------------------------
  config$logger.info("Apply filters if filter needed (Filter data by groups of everything) ")
  #-----------------------------------------------------------------------------------------------------------------------------------------------------------
  # Filtering data on multiple dimension if needed for a particular final data
  
  parameter_filtering = if (!is.null(opts$filtering)) opts$filtering else list(species = NULL, fishing_fleet = NULL) # if nothing provided filtering is null so we provided first dimension with no filtering
  if (is.character(parameter_filtering)) {
    parameter_filtering <- eval(parse(text = toString(parameter_filtering)))
  } #if opts$filtering is provided, we need to read the filtering parameters provided in the entities table as following ex parameter_option_filtering:c(species = "YFT", gear = c("09.32", 09.39"))
  
  matchingList <-
    parameter_filtering %>% purrr::keep(~ !is.null(.)) #removing null params in case no option is provided
  
  georef_dataset <- dimension_filtering_function(georef_dataset, filtering_params = matchingList)
  
  #----------------------------------------------------------------------------------------------------------------------------
  
  #we do an aggregation by dimensions
  dataset <- 
    georef_dataset %>% dplyr::group_by(.dots = setdiff(colnames(georef_dataset), "measurement_value")) %>% dplyr::summarise(measurement_value =
                                                                                                                       sum(measurement_value))
  dataset <- data.frame(dataset)
  
  
  #----------------------------------------------------------------------------------------------------------------------------
  #@eblondel additional formatting for next time support
  dataset$time_start <- as.Date(dataset$time_start)
  dataset$time_end <- as.Date(dataset$time_end)
  #we enrich the entity with temporal coverage
  dataset_temporal_extent <- paste(as.character(min(dataset$time_start)), as.character(max(dataset$time_end)), sep = "/")
  entity$setTemporalExtent(dataset_temporal_extent)
  
  #@geoflow -> export as csv
  #-------------------------------------------------------
  output_name_dataset <- file.path("data", paste0(entity$identifiers[["id"]], "_harmonized.csv"))
  readr::write_csv(dataset, output_name_dataset)
  #-------------------------------------------------------
  #@geoflow --> export as csv PUBLIC file (enriched with year, month, quarter)
  output_name_dataset_public <- file.path("data", paste0(entity$identifiers[["id"]], "_public.csv"))
  dataset_enriched = dataset
  dataset_enriched$year = as.integer(format(dataset_enriched$time_end, "%Y"))
  dataset_enriched$month = as.integer(format(dataset_enriched$time_end, "%m"))
  dataset_enriched$quarter = as.integer(substr(quarters(dataset_enriched$time_end), 2, 2))
  columns_to_keep <- c("source_authority", "species", "gear_type", "fishing_fleet", "fishing_mode", "time_start", "time_end", "year", "month", "quarter", "geographic_identifier", "measurement", "measurement_type", "measurement_unit", "measurement_value")
  columns_to_keep <- intersect(colnames(dataset_enriched), columns_to_keep)
  dataset_enriched = dataset_enriched[,columns_to_keep]
  readr::write_csv(dataset_enriched, output_name_dataset_public)
  
  # ---------------------------------------------------------------------------------------------------------------------------
  entity$addResource("harmonized", output_name_dataset)
  entity$addResource("public", output_name_dataset_public)
  entity$addResource("geom_table", opts$geom_table)
  #### END
  config$logger.info(
    "-----------------------------------------------------------------------------------------------------"
  )
  config$logger.info("End: Your tuna atlas dataset has been created!")
  config$logger.info(
    "-----------------------------------------------------------------------------------------------------"
  )
  #write to service dbi
  dataset_enriched$geographic_identifier = as.character(dataset_enriched$geographic_identifier)
  entity$data$features = dataset_enriched
  writeWorkflowJobDataResource(entity=entity,config=config,type="dbtable",useFeatures=TRUE,useUploadSource=TRUE, createIndexes=TRUE)
  
  entity$addResource("fact", action$options$fact)
  entity$addResource("geom_table", action$options$geom_table)
  
  rm(georef_dataset)
  rm(dataset_enriched)
  gc()
  
  
 
}