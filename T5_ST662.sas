/*
Tutorial 1

Read the Iris.csv dataset into SAS. Screen and clean the data, bearing the following in mind:

Species should be one of the following values: setosa, versicolor or virginica.

All measured numerical properties of an iris should be positive. 
The petal length of an iris is at least 2 times its petal width. 
The sepal length of an iris cannot exceed 30 cm. 
The sepals of an iris are longer than its petals.
*/

/*It is necessary to upload and save the Iris.csv into SAS. In my case, ST662LIB is my permanent libname*/
DATA ST662LIB.EBP_IRIS;
	SET WORK.IMPORT;
RUN;

/*Getting information about the dataset*/
PROC CONTENTS DATA=ST662LIB.EBP_IRIS;

/*Some descriptive statistics =========================================================================== */

PROC MEANS DATA=ST662LIB.EBP_IRIS MISSING MAXDEC=2 N NMISS MIN P1 P10 P25 P50 MEAN MEDIAN P75 P90 P95 P99 MAX;
	VAR Petal_Length
		Petal_Width
		Sepal_Length
		Sepal_Width;
		
	CLASS Species;
	OUTPUT OUT = ST662LIB.EBP_IRIS_DESC_STATS;
QUIT;

PROC UNIVARIATE DATA=ST662LIB.EBP_IRIS PLOTS ROUND=2 NOPRINT;
	VAR Petal_Length
		Petal_Width
		Sepal_Length
		Sepal_Width;
		
	HISTOGRAM Petal_Length
			  Petal_Width
			  Sepal_Length
			  Sepal_Width;
QUIT;

PROC FREQ DATA=ST662LIB.EBP_IRIS;
	TABLE Species/ 
	NOCOL NOROW NOCUM NOPERCENT MISSING
;
QUIT;

/*Cleaning the database =========================================================================== */

DATA WORK.EBP_IRIS;
	SET ST662LIB.EBP_IRIS;
	
LABEL CONDITION1 = 'All measured numerical properties of an iris should be positive';
LABEL CONDITION2 = 'The petal length of an iris is at least 2 times its petal width';
LABEL CONDITION3 = 'The sepal length of an iris cannot exceed 30 cm';
LABEL CONDITION4 = 'The sepals of an iris are longer than its petals';

LENGTH CONDITION1 $10.;
LENGTH CONDITION2 $10.;
LENGTH CONDITION3 $10.;
LENGTH CONDITION4 $10.;

/* Specifying all together (label, length, format, informat etc)
 ATTRIB CONDITION1 LENGTH = $6. LABEL='All measured numerical properties of an iris should be positive';
*/

/*IMPORTANT NOTE: missing in SAS is "minus infinite", i.e., there is no value less than missing.*/
IF Petal_Length > 0 AND
   Petal_Width  > 0 AND
   Sepal_Length > 0 AND
   Sepal_Width  > 0 THEN CONDITION1 = '00. OK'; ELSE CONDITION1 = '01. Non OK';
   
IF 2*Petal_Length > Petal_Width THEN CONDITION2 = '00. OK'; ELSE CONDITION2 = '01. Non OK';

IF Sepal_Length < 30 THEN CONDITION3 = '00. OK'; ELSE CONDITION3 = '01. Non OK';

IF Sepal_Length > Petal_Length and Sepal_Width > Petal_Width THEN CONDITION4 = '00. OK'; ELSE CONDITION4 = '01. Non OK';

/*
IF CONDITION1 = '00. OK' AND
   CONDITION2 = '00. OK' AND
   CONDITION3 = '00. OK' AND
   CONDITION4 = '00. OK' THEN OUTPUT;
*/

RUN;

PROC FREQ DATA=EBP_IRIS;
TABLE 	CONDITION1
		CONDITION2
		CONDITION3
		CONDITION4
/MISSING;
TABLE 
		CONDITION1 * CONDITION2
		CONDITION3 * CONDITION4
/NOCOL NOROW NOPERCENT NOCUM MISSING;
QUIT;

/*
IMPORTANT MESSAGES:
	1- Always label the variables! Even if you have 200, 500, 1000 variables, find a way (preferably an automatic one) to identify ALL of them;
	2- It's possible to clean the dataset applying the same conditions by using PROC SQL. 	
 */