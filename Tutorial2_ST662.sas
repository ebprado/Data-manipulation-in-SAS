/*=========================================================================================================*/

/*
 Today's goals:
	1 - Review the 2nd assignment step-by-step;
	2 - Perform the same analysis by using the full database, i.e., for all sites, years and treatments.
*/

/*1A Download the biomass.csv dataset and read it into SAS.*/


FILENAME REFFILE '/home/estevaoprado200/my_shared_file_links/rafaeldeandrade0/ST662_data/climate.csv';
FILENAME REFFILE2 '/home/estevaoprado200/my_shared_file_links/rafaeldeandrade0/ST662_data/biomass.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.CLIMATE;
	GETNAMES=YES;
RUN;

PROC IMPORT DATAFILE=REFFILE2
	DBMS=CSV
	OUT=WORK.BIOMASS;
	GETNAMES=YES;
RUN;

/*1B Restrict the dataset to only sites 13, 14, 23, 25, 33 and 52,
 to only the first year of experimental data, and to only treatment 1.
 */

%LET FILTER_SITE = 13, 14, 23, 25, 33, 52;
%LET FILTER_YEAR = 1;
%LET FILTER_TREAT = 1;
%LET DB_BIOMASS = WORK.BIOMASS;
%LET DB_CLIMATE = WORK.CLIMATE;

%MACRO DATABASE_ECOLOGY (BIOMASS = &DB_BIOMASS., CLIMATE = &DB_CLIMATE., SITE = &FILTER_SITE., YEAR = &FILTER_YEAR., TREAT = &FILTER_TREAT.);

	DATA EBP_BIOMASS;
		SET &BIOMASS.  		    %IF %LENGTH(&SITE.)   = 0 AND
									%LENGTH(&YEAR.)  NE 0 AND
									%LENGTH(&TREAT.) NE 0 
								 
								 %THEN %DO; (WHERE=(YEARN IN (&YEAR.) AND TREAT IN (&TREAT.))); %END;
								 %ELSE %DO; (WHERE=(SITE  IN (&SITE.) AND YEARN IN (&YEAR.) AND TREAT IN (&TREAT.))); %END;
		
		LABEL SITE 			= 'Site ID number';
		LABEL COUNTRY 		= 'Country';
		LABEL YEAR 			= 'Year';
		LABEL YEARN 		= 'Experimental year number';
		LABEL NH 			= 'Number of harvests – number of times the whole plot was cut in a year';
		LABEL HARVEST 		= 'Harvest number (within year) ';
		LABEL HARVEST_DATE 	= 'Date of harvest';
		LABEL PLOT 			= 'Plot number as per design (1–30 = core design; 31–48 = treatment plots; 49–68 = additional plots at sites 45 and 46)';
		LABEL TREAT 		= 'Indicator variable: 1=basic 30 plots; 2 and 3=additional treatment plots (some sites implemented two levels of additional treatments)';
		LABEL REP 			= 'Replicate number (applies only to sites 15, 45, and 46)';
		LABEL G1 			= 'Initial sown proportion of fast-establishing grass';
		LABEL G2 			= 'Initial sown proportion of persistent grass';
		LABEL L1 			= 'Initial sown proportion of fast-establishing legume ';
		LABEL L2 			= 'Initial sown proportion of persistent legume ';
		LABEL E 			= 'Initial sown evenness ';
		LABEL DENS 			= 'Indicator variable: high=high level of initial sown biomass, low = low level (60%of high)';
		LABEL G1_Y 			= 'Harvest Dry Matter Yield of fast-establishing grass';
		LABEL G2_Y 			= 'Harvest Dry Matter Yield of persistent grass';
		LABEL L1_Y 			= 'Harvest Dry Matter Yield of fast-establishing legume';
		LABEL L2_Y 			= 'Harvest Dry Matter Yield of persistent legume';
		LABEL WEED_Y 		= 'Harvest Dry Matter Yield of weed species';
		LABEL HARV_YIELD 	= 'Total Harvest Dry Matter Yield';	
		
	RUN;

	/*1C Create a new dataset that provides the annual yield for each plot at each site.*/
	
	PROC SQL;
		CREATE TABLE ANNUAL_YIELD AS SELECT
			SITE,
			PLOT,
			YEAR,
			SUM(HARV_YIELD) AS ANNUAL_YIELD
		FROM EBP_BIOMASS
		GROUP BY SITE, PLOT, YEAR
	;
	QUIT;
	
	/*1D Create a new dataset that provides the average annual yield for each site (i.e. averaged across all plots)*/
	
	/*1st - Me and the majority of the students understand in this way.
			However, each site has more than one observation per plot.
	 */
	
	PROC SQL;
		CREATE TABLE ANNUAL_YIELD_SITE AS SELECT
			SITE,
			YEAR,
			MEAN(HARV_YIELD) AS ANNUAL_YIELD
		FROM EBP_BIOMASS
		GROUP BY SITE, YEAR
	;
	QUIT;

	/*2nd - Few students understand in this way. This one is more correct, given the structure of the data.*/
	PROC SQL;
		CREATE TABLE ANNUAL_YIELD_SITE AS SELECT
			SITE,
			YEAR,
			MEAN(ANNUAL_YIELD) AS ANNUAL_YIELD
		FROM ANNUAL_YIELD
		GROUP BY SITE, YEAR
	;
	QUIT;
	
	/*=========================================================================================================*/
	
	/*2A Download the climate.csv dataset and read it into SAS.*/
	
	/*2B Restrict the dataset to only sites 13, 14, 23, 25, 33 and 52.*/

	DATA EBP_CLIMATE;
		SET &CLIMATE. %IF %LENGTH(&FILTER_SITE.) NE 0 %THEN %DO; (WHERE=(SITE IN (&FILTER_SITE.)));%END;
													  %ELSE %DO; ; %END;
		LABEL Site 		= 'Site ID number';
		LABEL Day 		= 'Day';
		LABEL Month 	= 'Month';
		LABEL Year 		= 'Year';
		LABEL Date 		= 'Date';
		LABEL Precip  	= 'Daily precipitation';
		LABEL air_min 	= 'Minimum daily air temperature';
		LABEL air_mean 	= 'Mean daily air temperature';
		LABEL air_max 	= 'Maximum daily air temperature';
		
	RUN;

	/*2C Create a new dataset that provides the average ‘air_mean’ for each site and each year.*/
	
	PROC SQL;
		CREATE TABLE AIR_MEAN AS SELECT
			SITE,
			YEAR,
			MEAN(AIR_MEAN) AS AIR_MEAN,
			COUNT(*) AS N
		FROM EBP_CLIMATE
		GROUP BY SITE, YEAR
	;
	QUIT;
	
	/*=========================================================================================================*/
	
	/*3A Merge the biomass dataset created in Qu 1d with the relevant year of the climate dataset created in Qu 2c*/
	
	PROC SORT DATA=ANNUAL_YIELD_SITE; BY SITE YEAR; QUIT;
	PROC SORT DATA=AIR_MEAN; BY SITE YEAR; QUIT;
	
	/*Long table! It's WRONG! Here, we're doing a FULL JOIN*/
	
	DATA FINAL_MERGE_WRONG;
	MERGE ANNUAL_YIELD_SITE (IN=A)
		  AIR_MEAN 			(IN=B)
	;
	BY SITE YEAR;
	RUN;
	
	TITLE 'WRONG table';
	PROC PRINT DATA=FINAL_MERGE_WRONG; QUIT;
	
	/*CORRECT! We're doing a LEFT JOIN*/
	
	DATA FINAL_MERGE;
	MERGE ANNUAL_YIELD_SITE (IN=A)
		  AIR_MEAN 			(IN=B)
	;
	BY SITE YEAR;
	IF A;
	RUN;
	
	/*Alternatively, we can do*/
	
	PROC SQL;
		CREATE TABLE FINAL_MERGE AS SELECT
			A.*,
			B.AIR_MEAN
		FROM ANNUAL_YIELD_SITE AS A
		LEFT JOIN AIR_MEAN AS B ON (A.SITE = B.SITE AND A.YEAR = B.YEAR)
	;
	QUIT;
	
	TITLE 'CORRECT table';
	PROC PRINT DATA=FINAL_MERGE; QUIT;
	
	/*3B Create a scatter plot of average annual yield versus average annual temperature.*/
	
	PROC SGPLOT DATA=FINAL_MERGE;
	TITLE 'Average Annual yield vs Average Annual Temperature';
	SCATTER X=ANNUAL_YIELD Y=AIR_MEAN/ DATALABEL=SITE GROUP=YEAR;
	XAXIS LABEL = 'Average Annual temperature';
	YAXIS LABEL = 'Average Annual yield';
	RUN;
	
	PROC SGSCATTER DATA=FINAL_MERGE;
	TITLE 'Average Annual yield vs Average Annual Temperature';
	PLOT AIR_MEAN * ANNUAL_YIELD/ DATALABEL=SITE GROUP=YEAR;
	RUN;

	/*Delete datasets*/

	%_EG_CONDITIONAL_DROPDS(
							EBP_BIOMASS,
							/*AIR_MEAN,*/
							/*ANNUAL_YIELD_SITE,*/
							ANNUAL_YIELD,
							EBP_CLIMATE,
							FINAL_MERGE_WRONG
							);

%MEND DATABASE_ECOLOGY;
%DATABASE_ECOLOGY;

/*IMPORTANT NOTE: As we're beginning with SAS, we can opt by PROC SQL rather than MERGE. Why? See the example below.*/

PROC SORT DATA=ANNUAL_YIELD_SITE; BY DESCENDING ANNUAL_YIELD; QUIT;
PROC SORT DATA=AIR_MEAN; BY DESCENDING N; QUIT;

DATA EXAMPLE;
MERGE ANNUAL_YIELD_SITE (IN=A)
	  AIR_MEAN 			(IN=B)
;
IF A;
/*BY SITE YEAR; I'm supposing that I forgot, by accident, writing the argument BY*/
RUN;

/*The first dataset is correct, but the second one, isn't*/
PROC PRINT DATA=FINAL_MERGE; QUIT;
PROC PRINT DATA=EXAMPLE; QUIT;
