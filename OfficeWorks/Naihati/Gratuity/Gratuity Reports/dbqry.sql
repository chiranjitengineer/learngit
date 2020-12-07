SELECT DISTINCT YEARCODE 
FROM FINANCIALYEAR
ORDER BY YEARCODE


SELECT *
FROM FINANCIALYEAR
ORDER BY YEARCODE

6212

SELECT * FROM SYS_HELP_QRY
WHERE MODULENAME='WPS'
ORDER BY QRY_ID


SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%GRATUITY %')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE like '011004140%'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE='0110041402'


SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''

PROC_BONUSPROCESS_ONPFGROSS



SELECT 'WPS' MODULE, YEARCODE, MAXBONUSAMOUNT, MAXBONUSGROSS_MONTHLY, 
ELIGIBLE_BONUSGROSS_MONTHLY, PERDAY_BONUSRATE, BONUSPERCENTAGE 
FROM   BONUSPARAMETER


SELECT *  
FROM BONUSPARAMETER
WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002'
AND YEARCODE = '2020-2019';


SELECT *  
FROM BONUSPARAMETER
WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002'
AND YEARCODE = 
(
    SELECT MAX(YEARCODE) FROM BONUSPARAMETER
    WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002'
    HAVING COUNT(YEARCODE) =0
);

SELECT COUNT(YEARCODE) FROM BONUSPARAMETER
    WHERE COMPANYCODE = 'NJ0001' AND DIVISIONCODE = '0002'
    AND YEARCODE = '2020-2019'
    HAVING COUNT(YEARCODE) =0
    
    
    
    SET DEFINE OFF;
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, DOCDATEVALIDATEFIELD, KEY_TABLE, KEY_COLUMN)
 Values
   ('0110041403', NULL, 'Gratuity Calculation Details', 'REPORTS', 'GRATUITY CALCULATION DETAILS', 
    NULL, NULL, 'N', 'N', 'N', 
    'Y', 'N', 'Y', 'WPS', NULL, 
    '''0032''', '''0002'',''0005''', NULL, 'WPS/Pages/Report/pgReportWPSTemplate.aspx', NULL, 
    NULL, NULL, NULL, NULL, NULL, 
    NULL, NULL, NULL);
COMMIT;


    
SET DEFINE OFF;
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, SYSROWID)
 Values
   ('1', '0110041403', 'X', 'X', 'X', 
    'Y', 'X', 'X', 'X', 'WPS', 
    '202010120959520004458624');
COMMIT;

