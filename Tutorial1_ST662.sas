/* Generated Code (IMPORT) */
/* Source File: Toenail.xlsx */
/* Source Path: /home/estevaoprado200/my_shared_file_links/rafaeldeandrade0/ST662_data */
/* Code generated on: 2/23/22, 3:41 PM */
​
%web_drop_table(WORK.TOENAIL);
​
FILENAME REFFILE '/home/estevaoprado200/my_shared_file_links/rafaeldeandrade0/ST662_data/Toenail.xlsx';
​
PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.TOENAIL;
	GETNAMES=YES;
RUN;
​
/* b */
​
data TOENAIL;
set TOENAIL;
Obs = _n_;
run;
​
proc contents data=TOENAIL;
​
/* c */
/*--------------------------------------------*/
/* Character variables only */
​
proc freq data=TOENAIL;
table treat gender;
run;
​
proc print data=TOENAIL;
	/*where treat = 'A' or gender = 'A';*/
	where treat not in (0,1); or
		  gender not in ('Male', 'Female');
quit;
​
proc print data=TOENAIL;
	/*where treat = 'A' or gender = 'A';*/
	where id in (163, 174, 252);
quit;
​
/*id = 163 didn't get the treatment (code 0), based on previous records*/
/*id = 174 is Female, based on previous records */
/*id = 252 it's not possible to tell what happened*/
​
/*--------------------------------------------*/
/* Numeric variables only */
​
proc freq data=TOENAIL;
table Time y;
quit;
​
proc print data=TOENAIL;
	where time > 12 or y > 1;
quit;
​
proc print data=TOENAIL;
where id in (55,67,123);
quit;
​
/*id = 55: it seems to be a typo (it should be 12)*/
/*ids 67 and 123 I have no idea*/
​
/* d */
​
/* CORRECT VALUES */
data TOENAIL2;
	set TOENAIL;
​
		if id = 163 and treat="A" then treat="0";
		if id = 174 and Gender="A" then Gender="Female"; 
		if id = 252 then Gender='';
		if id = 722 then id = 272;
		if id = 55 and time=13 then time=12;
		if y not in (0,1) then y=.;
run;