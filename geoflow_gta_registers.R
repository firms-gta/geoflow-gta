require(readr)
require(magrittr)

#register_source_authority
register_source_authority <- function(config){
	fetched = readr::read_csv("https://raw.githubusercontent.com/fdiwg/fdi-codelists/main/global/firms/gta/cl_tuna_rfmos.csv") %>% as.data.frame()
	out <- fetched[,c("code", "uri", "label", "definition")]
	return(out)
}

#register_fishing_fleet
register_fishing_fleet <- function(config){
	fetched = readr::read_csv("https://raw.githubusercontent.com/fdiwg/fdi-codelists/main/global/firms/gta/cl_fishing_fleet.csv") %>% as.data.frame()
	out <- fetched[,c("code", "uri", "label", "definition")]
	return(out)
}

#register_species
register_species <- function(config){	
	fetched = readr::read_csv("https://raw.githubusercontent.com/fdiwg/fdi-codelists/main/global/firms/gta/cl_species_level0.csv") %>% as.data.frame()
	out <- fetched[,c("code", "uri", "label", "definition")]
	return(out)	
}

#register_fishing_mode
register_fishing_mode <- function(config){
	fetched = readr::read_csv("https://raw.githubusercontent.com/fdiwg/fdi-codelists/main/global/firms/gta/cl_fishing_mode.csv") %>% as.data.frame()
	out <- fetched[,c("code", "uri", "label", "definition")]
	return(out)		
}

#register_gear_type
register_gear_type <- function(config){
	fetched = readr::read_csv("https://raw.githubusercontent.com/fdiwg/fdi-codelists/main/global/cwp/cl_isscfg_gear.csv") %>% as.data.frame()
	out <- fetched[,c("code", "uri", "label", "definition")]
	return(out)			
}

#register_catch_measurement_type
register_catch_measurement_type <- function(config){
	fetched <- readr::read_csv("https://raw.githubusercontent.com/fdiwg/fdi-codelists/main/global/cwp/cl_catch_concepts.csv") %>% as.data.frame()
	out <- fetched[,c("code", "uri", "label", "definition")]
	return(out)		
}

#register_catch_measurement_unit
register_catch_measurement_unit <- function(config){
	out <- data.frame(
		code = c("t","no"),
		uri = NA,
		label = c("Metric tons", "Number of fishes"),
		definition = NA
	)
	return(out)		
}

#register_month
register_month <- function(config){
	out <- data.frame(
		code = as.character(1:12),
		uri = NA,
		label = c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"),
		definition = NA
	)
	return(out)		
}

#register_aggregation_method
register_aggregation_method <- function(config){
	out <- data.frame(
		code = c("none","sum", "avg_by_month", "avg_by_quarter", "avg_by_year"),
		uri = NA,
		label = c("None", "Sum", "Monthly average", "Quarterly average", "Yearly average"),
		definition = NA
	)
}