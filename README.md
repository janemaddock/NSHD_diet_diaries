# Dietary data in the MRC National Survey of Health and Development (1946 British birth cohort)

This repo contains Stata code to support analyses of the dietary data in NSHD. Further information on how diet was measured and coded can be found in this [dietary data resource](https://closer.ac.uk/cross-study-data-guides/dietary-data-guide/). Instructions on how to access NSHD data can be found [here](https://skylark.ucl.ac.uk/NSHD/doku.php?id=home). Please request the raw dietary data to obtain full information as this is not currently (as of Jan 2024) available on skylark.  

## Calculating average consumption  of food groups or nutrients
Since the dietary data is collected over a period of five days, it is usual to calculate average consumption for those who completed at least three days of the diet diary. File `NSHD_2009_DietAgg.do` outlines an example of how to do this using the 60-64 year sweep. 

## DASH diet score
I have used this dietary data to create a DASH diet score for a [previous paper](https://doi.org/10.1017/S0007114517003877). File `DASH_2009.do` outlines an example of how to do this using the 60-64 year sweep. 
