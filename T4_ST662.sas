/* Assignment 4 - Topics in Data Analytics */

/* Generated Code (IMPORT) */
/* Source File: Dates.csv */
/* Source Path: /home/estevaoprado200/ST662Lib */
/* Code generated on: 4/15/21, 7:54 PM */

%web_drop_table(WORK.DATES);


FILENAME REFFILE '/home/estevaoprado200/ST662Lib/Dates.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.DATES;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.DATES; RUN;

/*EXERCISE 1A*/

DATA WORK.DATES;
	SET WORK.DATES;
	
FORMAT DATE DDMMYY10.;

DATE = MDY(MONTH, DAY,YEAR);

RUN;

/*EXERCISE 1B*/

DATA SCREEN_DATA;
	SET WORK.DATES;

IF DATE = . THEN OUTPUT SCREEN_DATA;
IF DATE < '01Jan2000'D OR DATE > '31Dec2015'D THEN OUTPUT SCREEN_DATA;

RUN;

/*EXERCISE 1C*/

/*SHOWN IN SCREEN_DATA*/


































/*----------------------------------------------------------------------*/
/*EXERCISE 2A*/

FILENAME REFFILE2 '/home/estevaoprado200/ST662Lib/Bricks.csv';

PROC IMPORT DATAFILE=REFFILE2
	DBMS=CSV
	OUT=WORK.BRICKS;
	GETNAMES=YES;
RUN;


DATA BRICKS;
SET BRICKS;
DATE = YYQ(YEAR,QUARTER);
FORMAT DATE YYQS8.;
RUN;


/*----------------------------------------------------------------------*/
/*EXERCISE 2B*/


PROC SGPLOT DATA=BRICKS;
SERIES X=DATE Y=BRICKS;
XAXIS LABELATTRS=(SIZE=12PT) VALUEATTRS=(SIZE=12PT)
LABEL = 'TIME (YEARS)';
YAXIS LABELATTRS=(SIZE=12PT) VALUEATTRS=(SIZE=12PT)
LABEL = 'BRICK PRODUCTION';
RUN;

/*COMMENT: THERE IS AN INCREASING TREND AND SEASONALITY EVIDENT IN THE PLOT. NO INDICATION OF CYCLIC
BEHAVIOUR.*/

/*----------------------------------------------------------------------*/
/*EXERCISE 2C*/

PROC ESM DATA=BRICKS OUT=PREDS PRINT=FORECASTS PLOT=(FORECASTS) LEAD=9 PRINT=ESTIMATES;
ID DATE INTERVAL=QUARTER;
FORECAST BRICKS /MODEL=ADDWINTERS USE=PREDICT;
RUN;


/*
OTHER OPTIONS
– simple
– double
– linear
– damped trend – seasonal
– Winters method (additive and multiplicative)
*/



























/*----------------------------------------------------------------------*/
/*EXERCISE 3A*/

FILENAME REFFILE3 '/home/estevaoprado200/ST662Lib/LakeHuron.csv';

PROC IMPORT DATAFILE=REFFILE3
	DBMS=CSV
	OUT=WORK.LAKE;
	GETNAMES=YES;
RUN;

DATA LAKE;
SET LAKE;
DLAG1 = LAG(DEPTH);
DLAG2 = LAG2(DEPTH);
DLAG3 = LAG3(DEPTH);
DLAG4 = LAG4(DEPTH);
RUN;

/*----------------------------------------------------------------------*/
/*EXERCISE 3B*/
PROC SGPLOT DATA=LAKE;
SCATTER X=DLAG1 Y=DEPTH;
XAXIS LABELATTRS=(SIZE=12PT) VALUEATTRS=(SIZE=12PT) LABEL = 'DEPTH';
YAXIS LABELATTRS=(SIZE=12PT) VALUEATTRS=(SIZE=12PT) LABEL = 'DEPTH LAG1';
RUN;

/*----------------------------------------------------------------------*/
/*EXERCISE 3C*/

/*Autocorrelation is the correlation between a time series and a lagged version of the time series.
It is clear that there is very strong autocorrelation at lag 1 and that this decreases as the lag
increases. However, there is still positive autocorrelation at lag 4.*/
