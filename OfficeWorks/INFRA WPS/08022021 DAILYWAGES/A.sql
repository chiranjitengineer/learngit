SELECT * FROM WPSWAGESDETAILS
WHERE FORTNIGHTSTARTDATE='16-DEC-2020'


INSERT INTO WPSWAGESPROCESSTYPE_PHASE

SELECT COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, 
CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3, PARAM_4, PARAM_5 
FROM WPSWAGESPROCESSTYPE_PHASE
WHERE PHASE IN (0,1,2,4)



CREATE TABLE WPSDAILYWAGESDETAILS AS

SELECT * FROM WPSWAGESDETAILS
WHERE FORTNIGHTSTARTDATE='16-DEC-2020'
AND 1=2

SELECT * FROM WPSCOMPONENTMASTER


ALTER TABLE WPSCOMPONENTMASTER
ADD MISCPAYMENT VARCHAR2(1)

SELECT * FROM LOGIN

SELECT  * FROM WPSCOMPONENTMASTER
WHERE COMPONENTSHORTNAME LIKE '%BONUS%'


SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%BONUS%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE like '0110040%'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE='01100410'

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''

prcWPS_Component_b4Save

EXEC PRCWPS_COMPONENT_AFTERSAVE


SELECT *
           FROM COL
           WHERE TNAME ='WPSWAGESDETAILS_WV'
           AND CNAME LIKE 'DAILY%'
           
             AND (CNAME=LV_MASTER.COMPONENTNAME OR CNAME=LV_MASTER.COMPONENTSHORTNAME);
             
             
             CREATE TABLE GBL_WPSCOMPONENTMASTER_TMP AS
             SELECT * FROM GBL_WPSCOMPONENTMASTER
             
             INSERT INTO  GBL_WPSCOMPONENTMASTER_TMP
             
             
             SELECT * FROM GBL_WPSCOMPONENTMASTER_TMP  
             
             
             INSERT INTO  GBL_WPSCOMPONENTMASTER
             SELECT * FROM GBL_WPSCOMPONENTMASTER_TMP  
             
             
             
             
  SET DEFINE OFF;
Insert into MENUMASTER_RND
   (MENUCODE, MENUNAME, MENUDESC, MENUTYPE, MENUTAG, MENUTAG1, MENUTAG2, ENTRYPOSSIBLE, EDITPOSSIBLE, DELETEPOSSIBLE, REPORTSPOSSIBLE, UTILITIESPOSSIBLE, ACTIVE, PROJECTNAME, MENUDETAILS, EFFECTIVEDIVISION, EFFECTIVEINDIVISION, PROCEDURE_SAVE_EDIT, URLSRC, FRM_HEIGHT, FRM_WIDTH, FUNCTIONCALL_BEFORE, FUNCTIONCALL_AFTER, VIEWPOSSIBLE, PRINTPOSSIBLE, DOCDATEVALIDATEFIELD, AUDITTABLE)
 Values
    ('01100412', NULL, 'Daily Wages Process', 'PROCESS', 'DAILY WAGES PROCESS', 
    NULL, NULL, 'Y', 'N', 'N', 
    'N', 'N', 'Y', 'WPS', NULL, 
    NULL, '''0022''', NULL, 'WPS/Pages/Process/pgWPSFortnightProcess.aspx', NULL, 
    NULL, NULL, NULL, 'Y', NULL, 
    NULL, NULL);
COMMIT;
           

D:\SWT_ERP_ONLINE\SWTERP_WPS\swterp\swterp\WPS\Pages\Process\pgWPSDailyWagesProcess.aspx
             
SET DEFINE OFF;
Insert into ROLEDETAILS
   (ROLEID, MENUCODE, ACCESSENTRY, ACCESSEDIT, ACCESSDELETE, ACCESSREPORT, ACCESSUTILITIES, ACCESSVIEW, ACCESSPRINT, PROJECTNAME, SYSROWID)
 Values
   ('1', '01100412', 'Y', 'N', 'N', 
    'X', 'X', 'X', 'X', 'WPS', 
    '201504301142320000273797');
COMMIT;


select *from WPSWORKERMAST

--------------------------------------------------------------------------------

SELECT TOKENNO||'~'||WORKERNAME||'~'||'01/02/2020'||'~'||'01/02/2020'||'~'||WORKERSERIAL||'~'||COMPANYCODE||'~'||DIVISIONCODE||'~'||'2020-2021'||'~'||''||'~'||'SWT' AS XX 
  FROM WPSWORKERMAST 
 WHERE COMPANYCODE = '0002' 
   AND DIVISIONCODE = '0022' 
--   AND TOKENNO = '21144' 
   AND NVL(ACTIVE,'N') ='Y' 
   
   WPSDAILYWAGESDETAILS_MV
   
   WPSDAILYWAGESDETAILS
   
   
   prcWPS_Wages_Process
   
   
select COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3 
from WPSWAGESPROCESSTYPE_PHASE  
where COMPANYCODE = '0002' and DIVISIONCODE = '0022'
and PROCESSTYPE = 'DAILY WAGES PROCESS'
ORDER BY PHASE, CALCULATIONINDEX

select DISTINCT PROCEDURE_NAME 
from WPSWAGESPROCESSTYPE_PHASE  
where COMPANYCODE = '0002' and DIVISIONCODE = '0022'

and PROCESSTYPE = 'DAILY WAGES PROCESS'

ORDER BY PHASE, CALCULATIONINDEX


PROC_WPSDAILYPROCESS_TRANSFER


select * from WPSWAGESDETAILS_PHASE_2

PROC_WPSWAGESPROCESS_INSERT

PROCEDURE_NAME

----------- DAILY WAGES START -----------------
PROC_WPSWORKERCATEGORY_UPDT

PROC_WPSWAGESPROCESS_INSERT

PRC_WPS_ATTNINCENTIVE_CALC

PRC_WPSATTNINCENTIVE_UPDATE

PROC_WPSWAGESPROCESS_UPDATE

PROC_WPSWAGESPROCESS_UPDATE

PROC_WPSWAGESPROCESS_UPDATE

PROC_WPSDAILYPROCESS_TRANSFER

----------   DAILY WAGES END  ------------------

PROCEDURE_NAME

PROC_WPSWAGES_OTHER_COMP_UPDT   --- (DONE)
PROC_WPSWAGESPROCESS_DEDUCTION  --- (DONE)
PRC_WPS_ATTNINCENTIVE_CALC      --- (DONE)
PROC_WPSDAILYPROCESS_TRANSFER   --- (DONE)
PROC_WPSWAGESPROCESS_UPDATE     --- (DONE)
PROC_WPSWAGESPROCESS_TRANSFER   --- (DONE)
PROC_WPSWORKERCATEGORY_UPDT     --- (DONE)
PROC_WPSWAGESPROCESS_INSERT     --- (DONE)
PRC_WPSATTNINCENTIVE_UPDATE     --- (DONE)



SELECT COMPONENTCODE, COMPONENTSHORTNAME, COMPONENTTYPE, AMOUNTORFORMULA, MANUALFORAMOUNT, FORMULA, CALCULATIONINDEX, PHASE, 
NVL(TAKEPARTINWAGES,'N') AS TAKEPARTINWAGES, NVL(COLUMNINATTENDANCE,'N') AS COLUMNINATTENDANCE, 
NVL(COMPONENTTAG,'N') AS COMPONENTTAG, NVL(COMPONENTGROUP,'N') AS COMPONENTGROUP 
FROM WPSCOMPONENTMASTER
WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
AND PHASE = P_PHASE
AND NVL(TAKEPARTINWAGES,'N') = 'Y'



      SELECT COMPONENTCODE, COMPONENTSHORTNAME, COMPONENTTYPE, AMOUNTORFORMULA, MANUALFORAMOUNT, FORMULA, CALCULATIONINDEX, PHASE, 
            NVL(TAKEPARTINWAGES,'N') AS TAKEPARTINWAGES, NVL(COLUMNINATTENDANCE,'N') AS COLUMNINATTENDANCE, 
            NVL(COMPONENTTAG,'N') AS COMPONENTTAG, NVL(COMPONENTGROUP,'N') AS COMPONENTGROUP, MISCPAYMENT 
            FROM WPSCOMPONENTMASTER
            WHERE COMPANYCODE = '0002' AND DIVISIONCODE = '0022'
            AND PHASE = 1
            AND NVL(TAKEPARTINWAGES,'N') = 'Y'            
            AND NVL(MISCPAYMENT,'N') = NVL2(CASE WHEN 'WAGES PROCESS' ='DAILY WAGES PROCESS' THEN 'XXX' ELSE NULL END,'Y','N')


MISCPAYMENT


    select nvl2(1,'2','3') from dual
    
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------


SELECT TOKENNO,MAX(FORTNIGHTSTARTDATE) FROM WPSWAGESDETAILS_MV
GROUP BY TOKENNO

--------------------------------------------------------------------------------

DELETE FROM WPS_ERROR_LOG


SELECT * FROM WPS_ERROR_LOG

SELECT * FROM WPSCOMPONENTMASTER
WHERE COMPONENTNAME IN ('CASHOT_AMOUNT', 'DAILY_ESI')

 ROUND((ROUND((NVL(MAST.ADHOCRATE,0)+NVL(MAST.FIXEDBASIC,0) + NVL(MAST.ADDLBASIC_RATE,0) + NVL(MAST.DARATE,0))/208,2))*ATTN.OVERTIMEHOURS,2)

--EXEC prcWPS_Wages_Process('DAILY WAGES PROCESS','0002','0022','2020-2021','SWT','16/12/2020','16/12/2020','''03921''') 

EXEC prcWPS_Wages_Process('DAILY WAGES PROCESS','0002','0022','2020-2021','SWT','17/12/2020','17/12/2020','') 

EXEC prcWPS_Wages_Process('DAILY WAGES PROCESS','0002','0022','2020-2021','SWT','17/12/2021','17/12/2021','')
  
 
EXEC PROC_WPSWORKERCATEGORY_UPDT('0002','0022','2020-2021','16/12/2020','16/12/2020','0','WPSATTENDANCEDAYWISE','WPSATTENDANCEDAYWISE','','DAILY WAGES PROCESS')
 
EXEC PROC_WPSWAGESPROCESS_INSERT('0002','0022','2020-2021','16/12/2020','16/12/2020','0','WPSWAGESDETAILS_PHASE_0','WPSWAGESDETAILS_SWT','','DAILY WAGES PROCESS')

EXEC PRC_WPSATTNINCENTIVE_UPDATE('0002','0022','2020-2021','16/12/2020','16/12/2020','0','WPSWAGESDETAILS_PHASE_0','WPSWAGESDETAILS_SWT','','DAILY WAGES PROCESS')

EXEC PROC_WPSWAGESPROCESS_UPDATE('0002','0022','2020-2021','16/12/2020','16/12/2020','11','WPSWAGESDETAILS_PHASE_11','WPSWAGESDETAILS_SWT','','DAILY WAGES PROCESS')

 


EXEC PROC_WPSDAILYPROCESS_TRANSFER('0002','0022','2020-2021','16/12/2020','16/12/2020','100','WPSWAGESDETAILS_SWT','WPSWAGESDETAILS_MV_SWT','','DAILY WAGES PROCESS')

---------------------------------------------
SELECT DAILY_ESI, CASHOT_AMOUNT, CEIL(TRUNC(CASHOT_AMOUNT *0.0075,2)) FROM WPSWAGESDETAILS_SWT
WHERE CASHOT_AMOUNT > 0

CASE WHEN MAST.ESIAPPLICABLE = 'Y' THEN  CEIL(TRUNC(COMPONENT.CASHOT_AMOUNT *0.0075,2)) ELSE 0 END


 
 SELECT * FROM WPSDAILYWAGESDETAILS
 
 SELECT * FROM WPSWAGESDETAILS_PHASE_11
 
 
 
 
 CREATE TABLE WPSWAGESDETAILS_MV_100221 AS
SELECT * FROM WPSWAGESDETAILS_MV
 
 
 
 CREATE TABLE WPSWAGESDETAILS_100221 AS
 SELECT * FROM WPSWAGESDETAILS
 
SELECT *  FROM WPSWAGESDETAILS_MV
 WHERE FORTNIGHTSTARTDATE='16-DEC-2020'

SELECT *  FROM WPSWAGESDETAILS
 WHERE FORTNIGHTSTARTDATE='16-DEC-2020'

--6730

--------------------------------------------------------------------------------


EXEC PROC_WPSWAGESPROCESS_UPDATE('0002','0022','2020-2021','16/12/2020','16/12/2020','12','WPSWAGESDETAILS_PHASE_12','WPSWAGESDETAILS_SWT','','DAILY WAGES PROCESS')


--------------------------------------------------------------------------------


INSERT INTO WPSWORKERCATEGORYVSCOMPONENT
SELECT A.COMPANYCODE, A.DIVISIONCODE, A.EFFECTIVEDATE, A.WORKERCATEGORYCODE, 
B.COMPONENTCODE, B.COMPONENTSHORTNAME, A.APPLICABLE, A.USERNAME, 
SYSDATE LASTMODIFIED, FN_GENERATE_SYSROWID SYSROWID FROM WPSWORKERCATEGORYVSCOMPONENT A,
(
SELECT COMPONENTCODE,COMPONENTSHORTNAME FROM WPSCOMPONENTMASTER
WHERE COMPONENTNAME IN ('CASHOT_AMOUNT', 'DAILY_ESI')
) B
WHERE A.COMPONENTSHORTNAME='OT_AMT'


SELECT COMPONENTCODE,COMPONENTSHORTNAME FROM WPSCOMPONENTMASTER
WHERE COMPONENTNAME IN ('CASHOT_AMOUNT', 'DAILY_ESI')



--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
SELECT * FROM WPSWAGESDETAILS_SWT

 
 SELECT * FROM WPSDAILYWAGESDETAILS
 
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------    