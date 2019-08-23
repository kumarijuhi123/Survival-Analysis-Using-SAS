/* Setting the project library*/
libname Project 'P:\SAS Practice\Project';

/*Importing dataset*/
proc import datafile="P:\SAS Practice\Project\FermaLogis_Event_Type.csv" 
out=Project.FermaLogis dbms=csv replace;
getnames=YES;
run;

/*Creating a column named turnover type using the type column*/

data Project.FermaLogis;
length turnovertype $30.;
set Project.FermaLogis;

if turnover='Yes' then;

if type=1 then
	turnovertype="Retirement";
else if type=2 then
	turnovertype="Voluntary Resignation";
else if type=3 then
	turnovertype="Involuntary Resignation";
else if type=4 then
	turnovertype="Job Termination";
else
	turnovertype="No turnover";
run;

/*Checking the frequency of occurrence of each type of events*/
proc datasets library=project memtype=data;
	contents data=FermaLogis;
	run;

proc freq data=Project.FermaLogis;
	where turnovertype ne 'No turnover';
	tables Type /chisq;
run;

/*Replacing the NA's in Bonus column*/

data project.fermalogis;
	set project.fermalogis;
	array bonus _character_;

	do i=1 to dim(bonus);

		if bonus(i)="NA" then
			bonus(i)="0";
	end;
run;

/*Data Preprocessing*/

data Project.FermaLogis;
	SET Project.FermaLogis;

	IF StockOptionLevel>0 then
		hasStock='Yes';
	else
		hasStock='No';

	IF Education=3 or Education=4 or Education=5 then
		HigherEdu='Yes';
	Else
		HigherEdu='No';

	IF JobSatisfaction>=3 then
		Satisfied='Yes';
	Else
		Satisfied='No';

	IF JobInvolvement>=3 then
		JobInvolved='Yes';
	Else
		JobInvolved='No';

	IF MaritalStatus="Single" then
		MaritalStatusRecode=0;
	ELSE IF MaritalStatus="Married" then
		MaritalStatusRecode=1;
	ELSE 
		MaritalStatusRecode=2;
	
	IF Gender="Male" then
		GenderRecode=0;
	ELSE 
		GenderRecode=1;

	IF Overtime="No" then
		OvertimeRecode=0;
	ELSE 
		OvertimeRecode=1;

	IF Department="Human Resources" then
		DepartmentRecode=0;
	ELSE IF Department="Research & Development" then
		DepartmentRecode=1;
	ELSE 
		DepartmentRecode=2;

	IF BusinessTravel="Non-Travel" then
		BusinessTravRecode=0;
	ELSE IF BusinessTravel="Travel_Frequently" then
		BusinessTravRecode=1;
	ELSE 
		BusinessTravRecode=2;
run;

/*Dropping the first two columns and Over18 EmployeeCount EmployeeNumber  in the data set , as they have only the serial numbers
and 0 variance in data*/

DATA Project.FermaLogis(DROP=','n X Over18 EmployeeCount EmployeeNumber i);
	SET Project.FermaLogis;
RUN;

/*Calculating Sum of Bonus */

DATA Project.FermaLogis;
	SET Project.FermaLogis;
	ARRAY bonus_(*) bonus_1-bonus_40;
	ARRAY cum(*) cum1-cum40;
	cum1=bonus_1;

	DO i=2 TO 40;
		cum(i)=cum(i-1)+bonus_(i);
	END;
run;


/*reordering the data to get censored to the begining*/

data Project.FermaLogis;
	retain turnovertype;
	retain YearsAtCompany;
	set Project.FermaLogis;
run;

/*type of turnovers*/
PROC SGPLOT DATA = Project.FermaLogis;
VBAR turnovertype;
where turnovertype<>"No turnover";
TITLE "Type of Resignation vs Attrition";
RUN;

/*Splitting dataset into volunteer and others*/

DATA Project.vol_resign;  /*create voluntary resignation data*/
  SET Project.FermaLogis;
 where  turnovertype = "Voluntary Resignation";
 run;
/*
PROC SGPLOT DATA = Project.vol_resign;
VBAR Satisfied ;
where turnovertype= "Voluntary Resignation";
RUN;

PROC SGPLOT DATA = Project.vol_resign;
VBAR Department;
where turnovertype= "Voluntary Resignation";
TITLE "Attrition by Department";
RUN;

PROC SGPLOT DATA = Project.vol_resign;
VBAR Gender;
where turnovertype= "Voluntary Resignation";
TITLE "Attrition by Gender";
RUN;

PROC SGPLOT DATA = Project.vol_resign;
VBAR MaritalStatus ;
where turnovertype= "Voluntary Resignation";
TITLE "Attrition by Marital Status";
RUN;


PROC SGPLOT DATA = Project.vol_resign;
VBAR hasStock;
where turnovertype= "Voluntary Resignation";
TITLE "Attrition by Bonus";
RUN;
Proc sgplot data=Project.FermaLogis;
	vbar Overtime;
	Title 'Attrition by Overtime';
	where TurnoverType = "Voluntary Resignation";
run;
Proc sgplot data=Project.FermaLogis;
	vbar BusinessTravel;
	Title 'Attrition by Business Travel Types';
	where TurnoverType = "Voluntary Resignation";
run;

*/

PROC SGPLOT DATA = Project.vol_resign;
VBAR JobRole;
TITLE "Attrition by Job Roles";
RUN;

PROC SGPLOT DATA = Project.vol_resign;
VBAR TrainingTimesLastYear ;
TITLE "Attrition by Training Attended Last Year";
RUN;

PROC SGPLOT DATA = Project.vol_resign;
VBAR YearsSinceLastPromotion;
TITLE "Attrition by Time Since Last Promotion";
RUN;


Proc sgplot data=Project.FermaLogis;
	vbar TurnoverType /group=BusinessTravel;
	Title 'TurnOver by Business Travel';
	where TurnoverType ne 'No turnover';
run;

Proc sgplot data=Project.FermaLogis;
	vbar TurnoverType /group=Overtime;
	Title 'TurnOver by Overtime';
	where TurnoverType ne 'No turnover';
run;

Proc sgplot data=Project.FermaLogis;
	vbar TurnoverType /group=MaritalStatus;
	Title 'TurnOver by Marital Status';
	where TurnoverType ne 'No turnover';
run;

Proc sgplot data=Project.FermaLogis;
	vbar TurnoverType /group=Department;
	Title 'TurnOver by Department';
	where TurnoverType ne 'No turnover';
run;

Proc sgplot data=Project.FermaLogis;
	vbar TurnoverType /group=Satisfied;
	Title 'TurnOver By Job Satisfaction';
	where TurnoverType ne 'No turnover';
run;

Proc sgplot data=Project.FermaLogis;
	vbar TurnoverType /group=HigherEdu;
	Title 'TurnOver By Higher Education';
	where TurnoverType ne 'No turnover';
run;

Proc sgplot data=Project.FermaLogis;
	vbar TurnoverType /group=JobInvolved;
	Title 'TurnOver By Job Involved';
	where TurnoverType ne 'No turnover';
run;

Proc sgplot data=Project.FermaLogis;
	vbar TurnoverType /group=hasStock;
	Title 'TurnOver By Has Stock';
	where TurnoverType ne 'No turnover';
run;

Proc sgplot data=Project.FermaLogis;
	vbar TurnoverType /group=YearsAtCompany;
	Title 'TurnOver By Years At Company';
	where TurnoverType ne 'No turnover';
run;

Proc sgplot data=Project.FermaLogis;
	vbar TurnoverType /group=yearssincelastpromotion;
	Title 'TurnOver By Years Since Last Promotion';
	where TurnoverType ne 'No turnover';
run;

Proc sgplot data=Project.FermaLogis;
	vbar TurnoverType /group=YearsInCurrentRole;
	Title 'TurnOver By Years In Current Role';
	where TurnoverType ne 'No turnover';
run;

Proc sgplot data=Project.FermaLogis;
	vbar TurnoverType /group=PercentSalaryHike;
	Title 'TurnOver By % Salary Hike';
	where TurnoverType ne 'No turnover';
run;


/* Find whether the hazard rates are same for the event types */
proc freq data=Project.FermaLogis;
	where turnovertype ne 'No turnover';
	tables Type /chisq;
run;
*Hazard and Survival Curves rate by stratifying with Stock levels of an employee in fermalogis;
*Retiring employees;
proc lifetest data=project.fermalogis plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 2, 3, 4);
	strata hasstock;
	title "Survival curves of Retirement type with respect to stock";
run;
*Hazard and Survival Curves rate by stratifying with Stock;
*Voluntary Resignation;

proc lifetest data=project.fermalogis plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 1, 3, 4);
	strata hasstock;
	title "Survival curves of Voluntary Resignation type with respect to stock";
run;

*Hazard and Survival Curves rate by stratifying with Stock;
*Involuntary Resignation;

proc lifetest data=project.fermalogis plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 1, 2, 4);
	strata hasstock;
	title "Survival curves of Involuntary Resignation type with respect to stock";
run;

*Hazard and Survival Curves rate by stratifying with Stock;
*Job Termination;

proc lifetest data=project.fermalogis plots=(S H) method=LIFE;
	TIME YearsAtCompany*Type(0, 1, 2, 3);
	strata hasstock;
	title "Survival curves of Job Termination type with respect to stock";
run;

/*Graphically test for linear relation between type hazards*/
DATA Retirement;
	/*create Retirementexit data*/
	SET Project.FermaLogis;
	event=(Type=1);

	/*this is for censoring out other types, another way to write if statement*/
	turnoverType='Retirement';

DATA Project.VoluntaryResignation;
	/*create Voluntary Resignation exit data*/
	SET Project.FermaLogis;
	event=(Type=2);

	/*this is for censoring out other types, another way to write if statement*/
	turnoverType='Voluntary Resignation';

DATA InvoluntaryResignation;
	/*create Involuntary Resignation  exit data*/
	SET Project.FermaLogis;
	event=(Type=3);

	/*this is for censoring out other types, another way to write if statement*/
	turnoverType='Involuntary Resignation';

DATA JobTermination;
	/*create Job Termination  exit data*/
	SET Project.FermaLogis;
	event=(Type=4);

	/*this is for censoring out other types, another way to write if statement*/
	turnoverType='Job Termination';

Data Project.combine;
	set Retirement VoluntaryResignation InvoluntaryResignation JobTermination;

	/*Graphically test for linear relation between type hazards*/
PROC LIFETEST DATA=project.combine method=life PLOTS=(LLS);
	/*LLS plot is requested*/
	TIME YearsAtCompany*event(0);
	STRATA turnoverType /diff=all;
RUN;


*calculating the cumulative bonus effect;

DATA Project.bonusFerma;
	SET Project.fermalogis;
	ARRAY bonus_(*) bonus_1-bonus_40;
	ARRAY cum(*) cum1-cum40;
	cum1=bonus_1;

	DO i=2 TO 40;
		cum(i)=cum(i-1)+bonus_(i);
	END;
run;


/**shoenfeld residuals**/
PROC PHREG DATA=Project.VoluntaryResignation;
MODEL YearsAtCompany*event(0)= Age DailyRate DistanceFromHome HourlyRate MonthlyIncome MonthlyRate NumCompaniesWorked
PercentSalaryHike TotalWorkingYears TrainingTimesLastYear 
YearsInCurrentRole YearsSinceLastPromotion YearsWithCurrManager
Education EnvironmentSatisfaction JobInvolvement JobLevel JobSatisfaction /TIES=EFRON;
OUTPUT OUT=TimeDepVarModel RESSCH=schAge schDailyRate schDistanceFromHome schHourlyRate schMonthlyIncome schMonthlyRate schNumCompaniesWorked
schPercentSalaryHike schTotalWorkingYears schTrainingTimesLastYear 
schYearsInCurrentRole schYearsSinceLastPromotion schYearsWithCurrManager
schEducation schEnvironmentSatisfaction  schJobInvolvement schJobLevel
 schJobSatisfaction 
RUN;
DATA TimeDepVarModel;
	SET TimeDepVarModel;
	id= _n_;
RUN;

proc sgplot data=TimeDepVarModel;
	scatter x=YearsAtCompany y=YearsInCurrentRole / datalabel=id;
    title Residuals of Years In Current Role vs Years At Company;
run;

proc sgplot data=TimeDepVarModel;
	scatter x=YearsAtCompany y=NumCompaniesWorked / datalabel=id;
	title Residuals of Number of Companies Worked vs Years At Company;
run;

proc sgplot data=TimeDepVarModel;
	scatter x=YearsAtCompany y=TotalWorkingYears / datalabel=id;
	title Residuals of Total Working Years vs Years At Company;
run;


/*find the correlations with yearsatcompany and functions of yearsatcompany*/
DATA corryearsatcompany;
  SET TimeDepVarModel;
  where yearsatcompany > 1;
  lyearsatcompany =log(yearsatcompany);
  yearsatcompany2=yearsatcompany **2;
PROC CORR data = corryearsatcompany;
VAR yearsatcompany lyearsatcompany yearsatcompany2;
WITH schAge schDailyRate schDistanceFromHome schHourlyRate schMonthlyIncome schMonthlyRate 
schNumCompaniesWorked schPercentSalaryHike schTotalWorkingYears schTrainingTimesLastYear 
schYearsInCurrentRole schYearsSinceLastPromotion schYearsWithCurrManager
schEducation schEnvironmentSatisfaction  schJobInvolvement schJobLevel
schJobSatisfaction ;
RUN;



PROC CORR data = corryearsatcompany;
VAR yearsatcompany lyearsatcompany yearsatcompany2;
WITH NumCompaniesWorked TotalWorkingYears YearsInCurrentRole;
RUN;


/*-------------------------------------------------------------------------------*/

*Checking for non proportional variables using assess statement for martingale residuals ;

PROC phreg DATA=Project.bonusFerma;
	where YearsAtCompany>1;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel TrainingTimesLastYear 
		WorkLifeBalance hasstock HigherEdu;
	MODEL YearsAtCompany*Type(0)=Age BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobRole JobSatisfaction DistanceFromHome 
		NumCompaniesWorked OverTime TotalWorkingYears YearsInCurrentRole Jobrole 
		hasstock;
	title PHreg validation model/ties=efron;
	ASSESS PH/resample;
	title PHreg Non Proportional check model;
RUN;

*Implementing phreg using programming step for all the turnover types in one model;

PROC phreg DATA=Project.bonusFerma;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel WorkLifeBalance hasstock 
		HigherEdu;
	MODEL YearsAtCompany*Type(0)=BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobRole JobSatisfaction DistanceFromHome 
		NumCompaniesWorked OverTime TotalWorkingYears YearsInCurrentRole Jobrole 
		hasstock EmployBonus TimeIntercatWorkingYears TimeIntercatCurrentRole 
		TimeIntercatNumCompaniesWorked TrainingTimesLastYear/ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg model;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmployBonus=cum[YearsAtCompany-1];
	else
		EmployBonus=bonus_1;
RUN;

*Implementing phreg using programming step for the type Retirement;

PROC phreg DATA=Project.bonusFerma;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel WorkLifeBalance hasstock 
		HigherEdu;
	MODEL YearsAtCompany*Type(0, 2, 3, 4)=Age BusinessTravel 
		EnvironmentSatisfaction JobInvolvement OverTime JobRole JobSatisfaction 
		DistanceFromHome NumCompaniesWorked OverTime TotalWorkingYears 
		YearsInCurrentRole Jobrole hasstock EmployBonus TimeIntercatWorkingYears 
		TimeIntercatCurrentRole TimeIntercatNumCompaniesWorked /ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg Retirement Event Type Model;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmployBonus=cum[YearsAtCompany-1];
	else
		EmployBonus=bonus_1;
RUN;

*Implementing phreg using programming step for the type Voluntary Resignation/ Turnover;

PROC phreg DATA=Project.bonusFerma;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction satisfied MaritalStatus PerformanceRating 
		RelationshipSatisfaction StockOptionLevel WorkLifeBalance StockOptionLevel 
		WorkLifeBalance hasstock HigherEdu Jobinvolved;
	MODEL YearsAtCompany*Type(0, 1, 3, 4)=BusinessTravel EnvironmentSatisfaction 
		OverTime satisfied jobinvolved DistanceFromHome NumCompaniesWorked OverTime 
		TotalWorkingYears YearsInCurrentRole hasstock EmployBonus 
		TimeIntercatWorkingYears TimeIntercatCurrentRole TrainingTimesLastYear 
		/ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	title PHreg model for Voluntary Resignation/ Turnover;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmployBonus=cum[YearsAtCompany-1];
	else
		EmployBonus=cum1;
RUN;

*Implementing phreg using programming step for the type InVoluntary Resignation;

PROC phreg DATA=Project.bonusFerma;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel WorkLifeBalance hasstock 
		HigherEdu satisfied;
	MODEL YearsAtCompany*Type(0, 1, 2, 4)=age BusinessTravel 
		EnvironmentSatisfaction JobInvolvement OverTime JobRole satisfied 
		DistanceFromHome NumCompaniesWorked OverTime TotalWorkingYears 
		YearsInCurrentRole Jobrole hasstock EmployBonus TimeIntercatWorkingYears 
		TimeIntercatCurrentRole TimeIntercatNumCompaniesWorked TrainingTimesLastYear 
		HigherEdu /ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg model;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmployBonus=cum[YearsAtCompany-1];
	else
		EmployBonus=bonus_1;
RUN;

*Implementing phreg using programming step for the type Termination;

PROC phreg DATA=Project.bonusFerma;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel TrainingTimesLastYear 
		WorkLifeBalance hasstock HigherEdu;
	MODEL YearsAtCompany*Type(0, 1, 2, 3)=BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobRole JobSatisfaction DistanceFromHome OverTime 
		TotalWorkingYears YearsInCurrentRole Jobrole hasstock EmployBonus 
		TotalWorkingYears TimeIntercatWorkingYears YearsInCurrentRole 
		TimeIntercatCurrentRole NumCompaniesWorked TimeIntercatNumCompaniesWorked 
		/ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg model;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmployBonus=cum[YearsAtCompany-1];
	else
		EmployBonus=bonus_1;
RUN;

DATA LogRatioTest_PHregTime;
	Nested=2221.764;
	Retirement=128.640;
	VoluntaryResignation=971.656;
	InVoluntaryResignation=499.934;
	Termination=379.974;
	Total=Retirement+ VoluntaryResignation+InVoluntaryResignation+Termination;
	Diff=Nested - Total;
	P_value=1 - probchi(Diff, 66);
	*30-(30+17+30+29coef. in 3 models - 26coef. in nested;
RUN;


PROC PRINT DATA=LogRatioTest_PHregTime;
	FORMAT P_Value 5.3;
	title total nested vs individual hypothesis;
RUN;

*checking involuntry  resignation and job termination;

PROC phreg DATA=Project.bonusFerma;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel TrainingTimesLastYear 
		WorkLifeBalance hasstock HigherEdu satisfied ;
	MODEL YearsAtCompany*Type(0, 1, 2)=BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobSatisfaction DistanceFromHome NumCompaniesWorked 
		OverTime TotalWorkingYears YearsInCurrentRole Jobrole hasstock EmployBonus 
		TimeIntercatWorkingYears TimeIntercatCurrentRole 
		TimeIntercatNumCompaniesWorked /ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg model for involuntary resignation and job termination;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmployBonus=cum[YearsAtCompany-1];
	else
		EmployBonus=bonus_1;
RUN;

*checking involuntry  resignation and job termination;

DATA LogRatioTest_PHregIVJT;
	Nested=916.165;
	InVoluntaryResignation=499.944;
	Termination=379.74;
	Total=InVoluntaryResignation+Termination;
	Diff=Nested - Total;
	P_value=1 - probchi(Diff, 30);
	*26*2coef. in 2 models - 26coef. in nested;
RUN;

*checking involuntry  resignation and job termination;

PROC PRINT DATA=LogRatioTest_PHregIVJT;
	FORMAT P_Value 5.3;
	title nested(involuntry, termination) vs individual hypothesis;
RUN;
