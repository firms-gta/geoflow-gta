store_fdi_codelist <- function(action,entity, config){
	sf = entity$data$features
	sf$code = as.character(sf$code)
	sf = sf[,c("code", "uri", "label", "definition")]
	entity$data$features = sf
	geoflow::writeWorkflowJobDataResource(entity, config = config, useFeatures = TRUE, useUploadSource = TRUE, createIndexes = TRUE,overwrite = TRUE, type = "dbtable")
	
}