
/* Read through the SAS paper ‘Using PROC SGPLOT for Quick High-Quality Graphs’.
 Recreate the graphs in the paper – do NOT copy and paste code! Compare the 2012
 Olympics to the 2016 Olympics. */


/* Generated Code (IMPORT) */
/* Source File: Olympics2012.csv */
/* Source Path: /home/estevaoprado200/ST662Lib */
/* Code generated on: 4/23/19, 5:14 PM */

/* Information on SASHELP files can be viewed in the following pdf document: */
/* https://support.sas.com/documentation/tools/sashelpug.pdf. */

/* Below, I list a couple of examples of plots using SGPLOT - some of them are in the document
sashelpug.pdf*/

%LET DATA_OLYMPICS = ST662LIB.OLYMPICS2012;

/* Trying to change the colours/style. Below, the command is right, but it's not working. */

/*
ODS LISTING STYLE = JOURNAL;
ODS LISTING STYLE = ANALYSIS;
ODS LISTING STYLE = DEFAULT;
ODS LISTING STYLE = HTMLBLUE;
ODS LISTING STYLE = LISTING;
ODS LISTING STYLE = PRINTER;
ODS LISTING STYLE = RTF;
ODS LISTING STYLE = STATISTICAL;
ODS LISTING STYLE = JOURNAL2;
*/

/* Bar Charts */

 PROC SGPLOT DATA = &DATA_OLYMPICS.;
 VBAR Region;
 TITLE 'Number of coutries by continent in the Olympics of 2012';
 RUN;
 
 PROC SGPLOT DATA = &DATA_OLYMPICS.;
 VBAR Region / GROUP = PopGroup;
 TITLE 'Olympic Countries by Region and Population Group';
 RUN;
 
 PROC SGPLOT DATA = &DATA_OLYMPICS.;
 VBAR Region / GROUP = PopGroup GROUPDISPLAY = CLUSTER;
 TITLE 'Olympic Countries by Region and Population Group';
 RUN;
 
 
 /*Histogram*/

 PROC SGPLOT DATA = &DATA_OLYMPICS.;
 HISTOGRAM TotalAthletes;
 DENSITY TotalAthletes / scale=percent  type=kernel;
 TITLE 'Total of Athletes';
 RUN;
 
 /*Box plot*/
 
 PROC SGPLOT DATA = &DATA_OLYMPICS.;
 VBOX TotalAthletes/CATEGORY=Region;
 TITLE 'Total of Athletes';
 RUN;
 
 PROC SGPLOT DATA = &DATA_OLYMPICS.;
 HBOX Women/CATEGORY=Region;
 TITLE 'Total of Athletes';
 RUN;
 
 /*Scatter plots*/

PROC SGPLOT DATA=&DATA_OLYMPICS.;
 SCATTER X = TotalAthletes Y = TotalMedals;
 REG X = TotalAthletes Y = TotalMedals;
 TITLE 'Number of Athletes by Total Medals Won for Each Country (LINEAR)';
 
 RUN;
 
 PROC SGPLOT DATA=&DATA_OLYMPICS.;
 SCATTER X = TotalAthletes Y = TotalMedals;
 LOESS X = TotalAthletes Y = TotalMedals;
 TITLE 'Number of Athletes by Total Medals Won for Each Country (LOESS)';
 RUN;
 
PROC SGPANEL DATA=&DATA_OLYMPICS.;
 PANELBY Region;
 SCATTER X = TotalAthletes Y = TotalMedals;
 TITLE 'Number of Athletes by Total Medals Won for each Country/Continent';
 RUN;
 
/* Read the information on the two SASHELP datasets: BMT and CARS. */

/* Create the following graphs: */
/* 	BMT: create a histogram of T. */
/* 	BMT: create a histogram of T with suitable density plot overlaid. */
/* 	CARS: pick seven makes of interest to you (at random if have no interest!) and */
/* 		  create a bar chart showing the number of cars for each of the seven makes. */
/* 	CARS: for the same seven makes, create a segmented bar chart for the number */
/* 		  of makes by drivetrains. */

/* For each graph, use axes labels appropriate for the context of the data  */
/* and manipulate various characteristics of the graph (e.g. text size) to improve the look of the graph. */


/*BMT = Bone Marrow Transplant Patients*/
/* T = Disease-Free Survival Time*/

/*BMT: create a histogram of T.*/

%LET DATA = SASHELP.BMT;

 PROC SGPLOT DATA = &DATA.;
 HISTOGRAM T;
 DENSITY T / scale=percent type=kernel (c=0.2);
 TITLE 'Disease-Free Survival Time';
 RUN;
 
 
/*CARS*/
/*The Sashelp.cars data set provides the 2004 car data.*/

%LET DATA = SASHELP.CARS;

PROC FREQ DATA = &DATA.;
TABLE MAKE;
QUIT;

%LET MAKES = 'BMW', 'FORD', 'CHEVROLET', 'Mercedes-Benz', 'Toyota', 'Volkswagen', 'Audi', 'Porsche';

DATA AUX;
	SET &DATA. (WHERE=(UPCASE(MAKE) IN (%SYSFUNC(UPCASE(&MAKES.)))));
RUN;

 PROC SGPLOT DATA = AUX;
 VBAR MAKE / GROUP = TYPE GROUPDISPLAY =stack;
 TITLE 'Number of cars by manufacturer and type';
 RUN;
 
 PROC SGPLOT DATA = AUX;
 VBAR MAKE / GROUP = TYPE GROUPDISPLAY =CLUSTER;
 TITLE 'Number of cars by manufacturer and type';
 RUN;
 
/* CARS: for the same seven makes, create a segmented bar chart for the number */
/* 		  of makes by drivetrains.*/

/*Front = Front-wheel drive car*/
/*Rear = Rear-wheel drive car*/
/*All = Four-wheel drive vehicle*/

 PROC SGPLOT DATA = AUX;
 VBAR MAKE / GROUP = DriveTrain GROUPDISPLAY =stack;
 TITLE 'Number of cars by manufacturer and drivetrain';
 XAXIS LABEL = 'Manufacturer';
 YAXIS LABEL = 'Number of vehicles';
 RUN;
