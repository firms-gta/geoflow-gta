function(action, entity, config) {

	opts <- action$options
	con <- config$software$output$dbi
	options(encoding = "UTF-8")
	
	#action options
	SBF_data_rfmo_to_keep = if(!is.null(opts$SBF_data_rfmo_to_keep)) opts$SBF_data_rfmo_to_keep else "CCSBT"
	
	#scripts
	url_scripts_create_own_tuna_atlas <- "https://raw.githubusercontent.com/firms-gta/geoflow-tunaatlas/master/tunaatlas_scripts/generation"
	source(file.path(url_scripts_create_own_tuna_atlas, "retrieve_nominal_catch.R"))
	
	#data
	nominal_catch = entity$data$features
	
	
	### filtering on minimum time_start (TRUE  by default) 
    # extract the maximum year of declaration for each source_authority
    max_years <- nominal_catch %>%
      dplyr::group_by(source_authority) %>%
      dplyr::summarise(max_time_start = max(time_start))
    
    # check if not all the source_authority columns have the same maximum year of declaration
    if (length(unique(max_years$max_time_start)) > 1) {
      config$logger.info("Careful, not all the source_authority has the same maximum year of declaration")
      
      # get the minimum time_start of all the maximum time_start of each source_authority
      min_time_start <- min(max_years$max_time_start)
      
      # filter the georef_dataset based on the minimum time_start of all the maximum time_start of each source_authority
      nominal_catch <- nominal_catch %>%
        dplyr::filter(time_start <= min_time_start)
    }
	
	##for now we keep only landings excluding discards for now
	nominal_catch <- nominal_catch %>%
		dplyr::filter(measurement_type != "D")
	
   #### 2) Southern Bluefin Tuna (SBF): SBF data: keep data from CCSBT or data from the other tuna RFMOs?
  
	if (!is.null(SBF_data_rfmo_to_keep)){
    
    config$logger.info(paste0("Keeping only data from ",SBF_data_rfmo_to_keep," for the Southern Bluefin Tuna..."))
    if (SBF_data_rfmo_to_keep=="CCSBT"){
      nominal_catch <- nominal_catch[ which(!(nominal_catch$species %in% "SBF" & nominal_catch$source_authority %in% c("ICCAT","IOTC","IATTC","WCPFC"))), ]
    } else {
      nominal_catch <- nominal_catch[ which(!(nominal_catch$species %in% "SBF" & nominal_catch$source_authority == "CCSBT")), ]
    }
    config$logger.info(paste0("Keeping only data from ",SBF_data_rfmo_to_keep," for the Southern Bluefin Tuna OK")) 
    
  }
  
  #final step
  dataset<-nominal_catch %>% dplyr::group_by(.dots = setdiff(colnames(nominal_catch),"masurement_value")) %>% dplyr::summarise(measurement_value=sum(measurement_value))
  dataset<-data.frame(dataset)
  if(!is.na(any(dataset$measurement_unit) == "TRUE")) if(any(dataset$measurement_unit) == "TRUE") dataset[(dataset$measurement_unit) == "TRUE",]$measurement_unit <- "t"  #patch because of https://github.com/firms-gta/geoflow-tunaatlas/issues/41
  
  #----------------------------------------------------------------------------------------------------------------------------
  #@eblondel additional formatting for next time support
  dataset$time_start <- as.Date(dataset$time_start)
  dataset$time_end <- as.Date(dataset$time_end)
  #we enrich the entity with temporal coverage
  dataset_temporal_extent <- paste(as.character(lubridate::year(min(dataset$time_start))), as.character(lubridate::year(max(dataset$time_end))), sep = "/")
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
  if(entity$data$upload) writeWorkflowJobDataResource(entity=entity,config=config,type="dbtable",useFeatures=TRUE,useUploadSource=TRUE, createIndexes=TRUE)
  
  entity$addResource("fact", action$options$fact)
  entity$addResource("geom_table", action$options$geom_table)
  
  rm(nominal_catch)
  rm(dataset_enriched)
  gc()
  
  
 
}