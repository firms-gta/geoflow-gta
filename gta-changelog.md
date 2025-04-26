# FIRMS Global Tuna Atlas - Change log

## 2025.1.0 (2025-04-26)

- Data format specifications have been consolidated to improve quality of data submitted by tRFMOs for both [nominal catches](https://github.com/fdiwg/fdi-formats/blob/main/cwp_rh_generic_gta_taskI.json) and [georeferenced catches](https://github.com/fdiwg/fdi-formats/blob/main/cwp_rh_generic_gta_taskII.json). It includes the submission of the `measurement_processing_level` to indicate whether data correspond to the original sample or to raised data.
- Global datasets now include discards (when available), and data services now allow users to filter on the `measurement_type` based on the [catch concepts](https://github.com/fdiwg/fdi-codelists/blob/main/global/cwp/cl_catch_concepts.csv) standardized by the CWP.
- Datasets downloadable through DOIs are now available as Parquet format (in addition to zipped CSV data files).
- Dataset metadata have been consolidated to include vocabulary references such as [GEMET](https://www.eionet.europa.eu/gemet) and [AGROVOC](https://aims.fao.org/aos/agrovoc/)

### global_nominal_catch_firms_level0 (DOI: [10.5281/zenodo.5745958](https://doi.org/10.5281/zenodo.5745958))

- temporal coverage includes two additional years of data (2022,2023)

### global_catch_1deg_1m_surface_firms_level0 (DOI: [10.5281/zenodo.5745986](https://doi.org/10.5281/zenodo.5745986))

- temporal coverage includes two additional years of data (2022,2023)

### global_catch_5deg_1m_firms_level0 (DOI: [10.5281/zenodo.5746041](https://doi.org/10.5281/zenodo.5746041))

- temporal coverage includes two additional years of data (2022,2023)

### global_catch_firms_level0 (DOI: [10.5281/zenodo.5747174](https://doi.org/10.5281/zenodo.5747174))

- temporal coverage includes two additional years of data (2022,2023)

## 2024.1.0 (2024-06-01)

- tRFMO datasets are now validated and submitted through an [online tool](https://i-marine.d4science.org/group/fao_tunaatlas/dcrf-data-call-management) based on data calls. Data validation (for structure and content) is made against the CWP Reference harmonization standard.
- a simplified and fully automated workflow has been put in place at [geoflow-gta](https://github.com/firms-gta/geoflow-gta) to compile the global datasets from the data submissions, and publish them as services, including a spatial database, geographic metadata (in the [FAO Fisheries & Aquaculture GeoNetwork](https://www.fao.org/fishery/geonetwork)), data services (in the [FAO Fisheries & Aquaculture GeoServer](https://www.fao.org/fishery/geoserver)) and DOI publication in Zenodo.
- creation of a parent DOI at [10.5281/zenodo.8034731](https://doi.org/10.5281/zenodo.8034731) for the FIRMS Global Tuna Atlas
- dataset improvements:

### global_nominal_catch_firms_level0 (DOI: [10.5281/zenodo.5745958](https://doi.org/10.5281/zenodo.5745958))

- dataset compiled from FIRMS GTA [dcf-shiny](https://i-marine.d4science.org/group/fao_tunaatlas/dcrf-data-call-management) validation and submission tool, and published through services using [geoflow-gta](https://github.com/firms-gta/geoflow-gta) simplified workflow. The action used to process the global nominal catches is available at [geoflow_gta_action_process_nominal_catches.R] (https://github.com/firms-gta/geoflow-gta/blob/main/actions/geoflow_gta_action_process_nominal_catches.R) 
- temporal coverage includes 2 additional years of data (2020,2021)
- geo-referencing was improved based on a harmonized main areas dataset (available at https://github.com/fdiwg/fdi-codelists/blob/main/global/firms/gta/cl_nc_areas.csv)
- improve metadata including title (shortened) abstract, contact/roles, provenance, rights

### global_catch_1deg_1m_surface_firms_level0 (DOI: [10.5281/zenodo.5745986](https://doi.org/10.5281/zenodo.5745986))

- dataset compiled from FIRMS GTA[dcf-shiny](https://i-marine.d4science.org/group/fao_tunaatlas/dcrf-data-call-management) validation and submission tool, and published through services using [geoflow-gta](https://github.com/firms-gta/geoflow-gta) simplified workflow. The action used to process the global geo-referenced catches is available at [geoflow_gta_action_process_georeferenced_catches.R](https://github.com/firms-gta/geoflow-gta/blob/main/actions/geoflow_gta_action_process_georeferenced_catches.R)
- temporal coverage includes 2 additional years of data (2020,2021)
- geo-referencing was improved to rely on CWP reference 1 degree grid system available in [FAO Fisheries & Aquaculture GeoNetwork](https://www.fao.org/fishery/geonetwork/srv/fre/catalog.search#/metadata/cwp-grid-map-1deg_x_1deg) and [fdiwg-codelists repository](https://github.com/fdiwg/fdi-codelists/tree/main/global/cwp) (digital material in support CWP reference harmonization)

### global_catch_5deg_1m_firms_level0 (DOI: [10.5281/zenodo.5746041](https://doi.org/10.5281/zenodo.5746041))

- dataset compiled from FIRMS GTA[dcf-shiny](https://i-marine.d4science.org/group/fao_tunaatlas/dcrf-data-call-management) validation and submission tool, and published through services using [geoflow-gta](https://github.com/firms-gta/geoflow-gta) simplified workflow. The action used to process the global geo-referenced catches is available at [geoflow_gta_action_process_georeferenced_catches.R](https://github.com/firms-gta/geoflow-gta/blob/main/actions/geoflow_gta_action_process_georeferenced_catches.R)
- temporal coverage includes 2 additional years of data (2020,2021)
- geo-referencing was improved to rely on CWP reference 5 degree grid system available in [FAO Fisheries & Aquaculture GeoNetwork](https://www.fao.org/fishery/geonetwork/srv/fre/catalog.search#/metadata/cwp-grid-map-5deg_x_5deg) and [fdiwg-codelists repository](https://github.com/fdiwg/fdi-codelists/tree/main/global/cwp) (digital material in support CWP reference harmonization)

### global_catch_firms_level0 (DOI: [10.5281/zenodo.5747174](https://doi.org/10.5281/zenodo.5747174))

- dataset compiled from FIRMS GTA[dcf-shiny](https://i-marine.d4science.org/group/fao_tunaatlas/dcrf-data-call-management) validation and submission tool, and published through services using [geoflow-gta](https://github.com/firms-gta/geoflow-gta) simplified workflow. The action used to process the global geo-referenced catches is available at [geoflow_gta_action_process_georeferenced_catches.R](https://github.com/firms-gta/geoflow-gta/blob/main/actions/geoflow_gta_action_process_georeferenced_catches.R)
- temporal coverage includes 2 additional years of data (2020,2021)
- geo-referencing was improved to rely on CWP reference 1 and 5 degree grid systems available in [FAO Fisheries & Aquaculture GeoNetwork](https://www.fao.org/fishery/geonetwork) ([1 deg](https://www.fao.org/fishery/geonetwork/srv/fre/catalog.search#/metadata/cwp-grid-map-1deg_x_1deg), [5 deg](https://www.fao.org/fishery/geonetwork/srv/fre/catalog.search#/metadata/cwp-grid-map-5deg_x_5deg)) and [fdiwg-codelists repository](https://github.com/fdiwg/fdi-codelists/tree/main/global/cwp) (digital material in support CWP reference harmonization)