
/* There is a dataset in the SAS on-demand common class folder called EURmurders.csv. */

/* a) Read this dataset into SAS. */

%LET DATABASE = ST662LIB.EURMURDERS;

PROC IMPORT DATAFILE='/courses/d81f48adba27fe300/ST662/EURmurders.csv'
OUT=&DATABASE.;
QUIT;

/* b) Create a macro variable called Country_crit which will specify the name of a country.
 Put the value of the macro variable equal to Ireland. Use a print procedure in conjunction
 with the macro variable to produce a print out of the data for Ireland. Create a title
 statement for the printout (using the title statement before the procedure) and use the
 macro variable within the title. By changing only the value of the macro variable, produce
 the same printout for Finland. Hint: to reset the title, after the procedure use: title; */

%LET COUNTRY_CRIT = Ireland;

%MACRO PRINT_COUNTRY();

	TITLE "Print - &COUNTRY_CRIT. is shown";
	PROC PRINT DATA=&DATABASE. (WHERE=(UPCASE(COUNTRY) = UPCASE("&COUNTRY_CRIT."))); QUIT;
	TITLE "";

%MEND PRINT_COUNTRY;
%PRINT_COUNTRY;

/* c) Set up another macro variable called Location_crit and use it to print out the data for
 Southern Europe. Compute the means of rate and count for Southern Europe. Use appropriate 
 titles for each piece of code. Changing only the macro variable, repeat for Western Europe. */

%LET LOCATION_CRIT = Western Europe;

%MACRO PRINT_MEANS_COUNT();

	TITLE "Print - &LOCATION_CRIT. is shown";
	PROC PRINT DATA=&DATABASE. (WHERE=(UPCASE(LOCATION) = UPCASE("&LOCATION_CRIT."))); QUIT;
	TITLE "";
	
	TITLE "PROC MEANS - Mean of rate and count for &LOCATION_CRIT.";
	PROC MEANS DATA = &DATABASE. (WHERE=(UPCASE(LOCATION) = UPCASE("&LOCATION_CRIT."))) MEAN N;
	VAR RATE;
	QUIT;
	TITLE "";
	
	/*By using PROC SQL*/
	
	PROC SQL;
		CREATE TABLE EXERCISE_C AS SELECT
			LOCATION,
			MEAN(RATE) AS MEAN_RATE,
			COUNT(*)   AS N
		FROM &DATABASE. (WHERE=(UPCASE(LOCATION) = UPCASE("&LOCATION_CRIT.")))
		GROUP BY LOCATION
	;
	QUIT;
	
	TITLE "PROC SQL - Mean of rate and count for &LOCATION_CRIT.";
	PROC PRINT DATA=EXERCISE_C; QUIT;
	TITLE "";

%MEND PRINT_MEANS_COUNT;
%PRINT_MEANS_COUNT;

/* d) Produce a macro that will print out any countries with a zero value for a specific murder measure (rate or count), and identify the country with the highest and lowest murder measure for a specific year. */

/* (1) Create a macro that has calling variables Dsn (dataset), Var_val (the variable of interest to study – for our sample dataset this is rate or count), Year_val (the value of the year of interest). */
/* (2) Start with a proc means that identifies the lowest and highest values for the variable of interest and stores them in a new dataset. Hints: use the id statement. Your output statement might look like: */
/* output out=TEMP (drop= country _type_ _freq_) minid=Country_min min=Min_&Var_val maxid=Country_max max=max_&Var_val; */
/* (3) Use a proc print to print out all values that are equal to 0 by using the original database. Use the ‘where’ statement within the procedure. */
/* (4) Use another proc print to print out the lowest and highest values generated in the dataset TEMP. You might include a label statement here. E.g. */
/* label country_min = "Country with lowest murder &Var_val in &Year_val" country_max = "Country with highest murder &Var_val"; */
/* (5) Delete the dataset TEMP. */

%MACRO MURDER_MEASURE (DSN, VAR_VAL, YEAR_VAL) /*(1)*/;
							
	/*(2)*/
	PROC MEANS DATA=&DSN. (WHERE=(&VAR_VAL. > 0 AND YEAR = &YEAR_VAL.)) NOPRINT;
		VAR &VAR_VAL.;
		ID COUNTRY;
		OUTPUT OUT=TEMP (DROP= COUNTRY _TYPE_ _FREQ_) MINID=COUNTRY_MIN MIN=MIN_&VAR_VAL. MAXID=COUNTRY_MAX MAX=MAX_&VAR_VAL.;
	QUIT;
	
	/*(3)*/
	TITLE "Countries with murder &VAR_VAL. = 0 in &YEAR.";
	PROC PRINT DATA=&DSN. (WHERE=(&VAR_VAL. = 0 AND YEAR = &YEAR_VAL.)); QUIT;
	TITLE "";
	
	/*(4)*/
	DATA TEMP;
		SET TEMP;
		LABEL COUNTRY_MIN = "Country with lowest murder &VAR_VAL in &YEAR_VAL";
		LABEL COUNTRY_MAX = "Country with highest murder &VAR_VAL in &YEAR_VAL";
	RUN;	
	
	TITLE "Countries with lowest and highest murder &VAR_VAL. in &YEAR_VAL. (excluding countries with murder &VAR_VAL. = 0)";
	PROC PRINT DATA=TEMP LABEL; QUIT;
	TITLE "";

	/*(5)*/
	%_EG_CONDITIONAL_DROPDS(TEMP);
	
%MEND MURDER_MEASURE;

/* e) Use the macro to produce output for murder rate in 2016 */

%MURDER_MEASURE(&DATABASE., rate, 2016);

/* f) Use the macro for murder count in 2015 */

%MURDER_MEASURE(&DATABASE., count, 2015);
