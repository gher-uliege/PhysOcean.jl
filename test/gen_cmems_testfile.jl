using NCDatasets

ds = Dataset("cmems_testfile1.nc","c")
# Dimensions

ds.dim["LONGITUDE"] = 3
ds.dim["DEPTH"] = 1
ds.dim["STRING32"] = 32
ds.dim["TIME"] = 3
ds.dim["LATITUDE"] = 3
ds.dim["POSITION"] = 3

# Declare variables

ncTIME = defVar(ds,"TIME", Float64, ("TIME",)) 
ncTIME.attrib["long_name"] = "time"
ncTIME.attrib["standard_name"] = "time"
ncTIME.attrib["units"] = "days since 1950-01-01 00:00:00"
ncTIME.attrib["valid_min"] = 0.0
ncTIME.attrib["valid_max"] = 90000.0
ncTIME.attrib["QC_indicator"] = 1
ncTIME.attrib["QC_procedure"] = 1
ncTIME.attrib["uncertainty"] = " "
ncTIME.attrib["comment"] = " "
ncTIME.attrib["axis"] = "T"

ncTIME_QC = defVar(ds,"TIME_QC", Int8, ("TIME",)) 
ncTIME_QC.attrib["long_name"] = "quality flag"
ncTIME_QC.attrib["conventions"] = "OceanSites reference table 2"
ncTIME_QC.attrib["_FillValue"] = Int8(-128)
ncTIME_QC.attrib["valid_min"] = 0
ncTIME_QC.attrib["valid_max"] = 9
ncTIME_QC.attrib["flag_values"] = Int8[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
ncTIME_QC.attrib["flag_meanings"] = "no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed not_used nominal_value interpolated_value missing_value"

ncDC_REFERENCE = defVar(ds,"DC_REFERENCE", Char, ("STRING32", "TIME")) 
ncDC_REFERENCE.attrib["long_name"] = "Location unique identifier in data centre"
ncDC_REFERENCE.attrib["conventions"] = "Data centre convention"
ncDC_REFERENCE.attrib["_FillValue"] = " "

ncLATITUDE = defVar(ds,"LATITUDE", Float32, ("LATITUDE",)) 
ncLATITUDE.attrib["long_name"] = "Latitude of each location"
ncLATITUDE.attrib["standard_name"] = "latitude"
ncLATITUDE.attrib["units"] = "degrees_north"
ncLATITUDE.attrib["valid_min"] = -90.0
ncLATITUDE.attrib["valid_max"] = 90.0
ncLATITUDE.attrib["QC_indicator"] = 1
ncLATITUDE.attrib["QC_procedure"] = 1
ncLATITUDE.attrib["uncertainty"] = " "
ncLATITUDE.attrib["comment"] = " "
ncLATITUDE.attrib["axis"] = "Y"

ncLONGITUDE = defVar(ds,"LONGITUDE", Float32, ("LONGITUDE",)) 
ncLONGITUDE.attrib["long_name"] = "Longitude of each location"
ncLONGITUDE.attrib["standard_name"] = "longitude"
ncLONGITUDE.attrib["units"] = "degrees_east"
ncLONGITUDE.attrib["valid_min"] = -180.0
ncLONGITUDE.attrib["valid_max"] = 180.0
ncLONGITUDE.attrib["QC_indicator"] = 1
ncLONGITUDE.attrib["QC_procedure"] = 1
ncLONGITUDE.attrib["uncertainty"] = " "
ncLONGITUDE.attrib["comment"] = " "
ncLONGITUDE.attrib["axis"] = "X"

ncPOSITION_QC = defVar(ds,"POSITION_QC", Int8, ("POSITION",)) 
ncPOSITION_QC.attrib["long_name"] = "quality flag"
ncPOSITION_QC.attrib["conventions"] = "OceanSites reference table 2"
ncPOSITION_QC.attrib["_FillValue"] = Int8(-128)
ncPOSITION_QC.attrib["valid_min"] = 0
ncPOSITION_QC.attrib["valid_max"] = 9
ncPOSITION_QC.attrib["flag_values"] = Int8[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
ncPOSITION_QC.attrib["flag_meanings"] = "no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed not_used nominal_value interpolated_value missing_value"

ncPOSITIONING_SYSTEM = defVar(ds,"POSITIONING_SYSTEM", Char, ("POSITION",)) 
ncPOSITIONING_SYSTEM.attrib["long_name"] = "Positioning system"
ncPOSITIONING_SYSTEM.attrib["_FillValue"] = " "
ncPOSITIONING_SYSTEM.attrib["flag_values"] = "A, G, L, N, U"
ncPOSITIONING_SYSTEM.attrib["flag_meanings"] = "Argos, GPS, Loran, Nominal, Unknown"

ncTEMP = defVar(ds,"TEMP", Float32, ("DEPTH", "TIME")) 
ncTEMP.attrib["long_name"] = "Sea temperature"
ncTEMP.attrib["standard_name"] = "sea_water_temperature"
ncTEMP.attrib["units"] = "degree_Celsius"
ncTEMP.attrib["_FillValue"] = Float32(9.96921e36)

ncTEMP_QC = defVar(ds,"TEMP_QC", Int8, ("DEPTH", "TIME")) 
ncTEMP_QC.attrib["long_name"] = "quality flag"
ncTEMP_QC.attrib["conventions"] = "OceanSites reference table 2"
ncTEMP_QC.attrib["_FillValue"] = Int8(-128)
ncTEMP_QC.attrib["valid_min"] = 0
ncTEMP_QC.attrib["valid_max"] = 9
ncTEMP_QC.attrib["flag_values"] = Int8[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
ncTEMP_QC.attrib["flag_meanings"] = "no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed not_used nominal_value interpolated_value missing_value"

ncTEMP_DM = defVar(ds,"TEMP_DM", Char, ("DEPTH", "TIME")) 
ncTEMP_DM.attrib["long_name"] = "method of data processing"
ncTEMP_DM.attrib["conventions"] = "OceanSITES reference table 5"
ncTEMP_DM.attrib["flag_values"] = "R, P, D, M"
ncTEMP_DM.attrib["flag_meanings"] = "realtime post-recovery delayed-mode mixed"
ncTEMP_DM.attrib["_FillValue"] = " "

ncPSAL = defVar(ds,"PSAL", Float32, ("DEPTH", "TIME")) 
ncPSAL.attrib["long_name"] = "Practical salinity"
ncPSAL.attrib["standard_name"] = "sea_water_salinity"
ncPSAL.attrib["units"] = "psu"
ncPSAL.attrib["_FillValue"] = Float32(9.96921e36)

ncPSAL_QC = defVar(ds,"PSAL_QC", Int8, ("DEPTH", "TIME")) 
ncPSAL_QC.attrib["long_name"] = "quality flag"
ncPSAL_QC.attrib["conventions"] = "OceanSites reference table 2"
ncPSAL_QC.attrib["_FillValue"] = Int8(-128)
ncPSAL_QC.attrib["valid_min"] = 0
ncPSAL_QC.attrib["valid_max"] = 9
ncPSAL_QC.attrib["flag_values"] = Int8[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
ncPSAL_QC.attrib["flag_meanings"] = "no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed not_used nominal_value interpolated_value missing_value"

ncPSAL_DM = defVar(ds,"PSAL_DM", Char, ("DEPTH", "TIME")) 
ncPSAL_DM.attrib["long_name"] = "method of data processing"
ncPSAL_DM.attrib["conventions"] = "OceanSITES reference table 5"
ncPSAL_DM.attrib["flag_values"] = "R, P, D, M"
ncPSAL_DM.attrib["flag_meanings"] = "realtime post-recovery delayed-mode mixed"
ncPSAL_DM.attrib["_FillValue"] = " "

ncDEPH = defVar(ds,"DEPH", Float32, ("DEPTH", "TIME")) 
ncDEPH.attrib["long_name"] = "Depth"
ncDEPH.attrib["standard_name"] = "depth"
ncDEPH.attrib["units"] = "meter"
ncDEPH.attrib["_FillValue"] = Float32(-99999.0)
ncDEPH.attrib["valid_min"] = Float32(0.0)
ncDEPH.attrib["valid_max"] = Float32(12000.0)

ncDEPH_QC = defVar(ds,"DEPH_QC", Int8, ("DEPTH", "TIME")) 
ncDEPH_QC.attrib["long_name"] = "quality flag"
ncDEPH_QC.attrib["conventions"] = "OceanSites reference table 2"
ncDEPH_QC.attrib["_FillValue"] = Int8(-128)
ncDEPH_QC.attrib["valid_min"] = 0
ncDEPH_QC.attrib["valid_max"] = 9
ncDEPH_QC.attrib["flag_values"] = Int8[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
ncDEPH_QC.attrib["flag_meanings"] = "no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed not_used nominal_value interpolated_value missing_value"

ncDEPH_DM = defVar(ds,"DEPH_DM", Char, ("DEPTH", "TIME")) 
ncDEPH_DM.attrib["long_name"] = "method of data processing"
ncDEPH_DM.attrib["conventions"] = "OceanSITES reference table 5"
ncDEPH_DM.attrib["flag_values"] = "R, P, D, M"
ncDEPH_DM.attrib["flag_meanings"] = "realtime post-recovery delayed-mode mixed"
ncDEPH_DM.attrib["_FillValue"] = " "

# Global attributes
ds.attrib["conventions"] = "OceanSITES Manual 1.2, InSituTac-Specification-Document"
ds.attrib["id"] = "GL_PR_BA_FQRQ_2000"

# Define variables

ncTIME[:] = 123
ncTIME_QC[:] = 1
ncDC_REFERENCE[:] = 'x'
ncLATITUDE[:] = 123
ncLONGITUDE[:] = 123
ncPOSITION_QC[:] = 1
ncPOSITIONING_SYSTEM[:] = 123
ncTEMP[:] = 123
ncTEMP_QC[:] = 1
ncTEMP_DM[:] = 'x'
ncPSAL[:] = 123
ncPSAL_QC[:] = 1
ncPSAL_DM[:] = 123
ncDEPH[:] = 123
ncDEPH_QC[:] = 1
ncDEPH_DM[:] = 'x'

close(ds)
