SELECT * FROM GRATUITYENTITLEMENTYEAR
WHERE TOKENNO='04053'

YEAR	STRIKE DAYS	ACT. WKG DAYS	STL AVAILED DAYS	AL DAYS	SL DAYS	TOTAL DAYS	240 Days YES/NO	GRATUITY ENTITLEMENT YEARS



SELECT TOKENNO,WORKERSERIAL, CALENDARYEAR,0 STRIKE_DAYS, ATTENDANCE,STL,AUTHORIZEDLEAVE,ESI,TOTAL,
CASE WHEN (TOTAL >= 240) THEN 'YES' ELSE 'NO' END YESNO,
DECODE(GRATURITYENTILE,'Y','YES','NO') GRATURITYENTILE FROM GRATUITYENTITLEMENTYEAR
WHERE TOKENNO='04053'
ORDER BY CALENDARYEAR


SELECT name , ' ' || 
    FLOOR(MONTHS_BETWEEN(to_date(SYSDATE),to_date(date_of_birth))/12)||' years ' ||  
    FLOOR(MOD(MONTHS_BETWEEN(to_date(SYSDATE),to_date(date_of_birth)),12)) || ' months ' || 
    FLOOR(MOD(MOD(MONTHS_BETWEEN(to_date(SYSDATE),to_date(date_of_birth)),12),4))|| ' days ' AS "Age"
FROM 
(
    SELECT 'KRISHNA' NAME, TO_DATE('15/11/2019','DD/MM/YYYY') date_of_birth FROM DUAL
);

SELECT SYSDATE,hiredate,TRUNC(months_between(SYSDATE,hiredate)/12) years,
TRUNC(months_between(SYSDATE,hiredate)-(TRUNC(months_between(SYSDATE,hiredate)/12)*12)) months,
TRUNC((months_between(SYSDATE,hiredate) - TRUNC(months_between(SYSDATE,hiredate)))*30) days
FROM 
(
    SELECT 'KRISHNA' NAME, TO_DATE('29/12/2019','DD/MM/YYYY') hiredate FROM DUAL
);

SELECT FN_DATEDIFF('15/10/2019','29/11/2020') FROM DUAL

SELECT * FROM WORKERVIEWGRATUITY
WHERE TOKENNO='04053'

NAME		MMMMM
Token No.		00004
DOJ		01/04/2003
SUP ON		15/07/2019
NOMINEE		


SELECT * 
FROM WORKERVIEWGRATUITY

SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, WORKERNAME,PFMEMBERSHIPDATE,DATEOFTERMINATION 
FROM WORKERVIEWGRATUITY
WHERE COMPANYCODE='NJ0001'
AND DIVISIONCODE ='0002'
--AND UNITCODE=''
AND CATEGORYCODE='B'
--AND GRADECODE=''
AND WORKERSERIAL='000001'
AND TOKENNO='00005'

WHERE TOKENNO='04053'





SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%STATU%')


SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE like '011004040%'

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='0110040404'


SELECT * FROM ROLEDETAILS
WHERE MENUCODE='0110040404'


SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG = ''

SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_ACTUAL=''

Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, ENTRYPOSSIBLE, 
    EDITPOSSIBLE, DELETEPOSSIBLE, REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, 
    PROJECTNAME, EFFECTIVEDIVISION, EFFECTIVEINDIVISION, URLSRC)
 Values
   ('01100414', 'X', 'Gratuity', 'GROUP', 'Y', 
    'Y', 'Y', 'N', 'N', 'Y', 
    'WPS', '''0032''', '''0002'',''0005''', 'pgUnderConstruction.aspx');
COMMIT;


Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('1', '01100414', 'Y', 'Y', 'Y', 
    'Y', 'X', 'X', 'X', 'WPS', 
    '202010120959520004458623');
COMMIT;


delete from MENUMASTER_RND where menucode='0110041401'

Insert into MENUMASTER_RND
   (MENUCODE, MENUDESC, MENUTYPE, MENUTAG, ENTRYPOSSIBLE, 
    EDITPOSSIBLE, DELETEPOSSIBLE, REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, 
    PROJECTNAME, EFFECTIVEINDIVISION, URLSRC)
 Values
   ('0110041401', 'Gratuity Working Sheet', 'REPORTS', 'GRATUITY WORKING SHEET', 'N', 
    'N', 'N', 'Y', 'N', 'N', 
    'WPS', '''0002'',''0005''', 'WPS/Pages/Report/pgReportWPSTemplate.aspx');
COMMIT;


Insert into MENUMASTER_RND
   (MENUCODE, MENUDESC, MENUTYPE, MENUTAG, ENTRYPOSSIBLE, 
    EDITPOSSIBLE, DELETEPOSSIBLE, REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, 
    PROJECTNAME, EFFECTIVEDIVISION, EFFECTIVEINDIVISION, URLSRC)
 Values
   ('0110041401', 'Gratuity Working Sheet', 'REPORTS', 'GRATUITY WORKING SHEET', 'N', 
    'N', 'N', 'Y', 'N', 'Y', 
    'WPS', '''0032''', '''0002'',''0005''', 'WPS/Pages/Report/pgReportWPSTemplate.aspx');
COMMIT;

Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, 
    ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, 
    SYSROWID)
 Values
   ('1', '0110041401', 'X', 'X', 'X', 
    'Y', 'X', 'X', 'X', 'WPS', 
    '202010120959520004458624');
COMMIT;




SELECT TOKENNO,WORKERSERIAL, CALENDARYEAR,0 STRIKE_DAYS, ATTENDANCE,STL,AUTHORIZEDLEAVE,ESI,TOTAL,
CASE WHEN (TOTAL >= 240) THEN 'YES' ELSE 'NO' END YESNO,
DECODE(GRATURITYENTILE,'Y','YES','NO') GRATURITYENTILE FROM GRATUITYENTITLEMENTYEAR
--WHERE TOKENNO='04053'
ORDER BY TOKENNO,CALENDARYEAR
