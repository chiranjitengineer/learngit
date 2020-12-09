 CREATE TABLE GPSCOMPTYPERATE_TEMP_SWT AS 
 
 SELECT A.WORKERSERIAL,  M.TOKENNO, A.LEAVECODE, 'MATERNITY LEAVE' COMPONENTTYPE, MIN(A.LEAVEDATE) LEAVEDATE, A.LEAVEAPPLIEDON, A.WAGERATE 
 FROM GPSLEAVEAPPLICATION A, GPSEMPLOYEEMAST M, 
 ( 
    SELECT WORKERSERIAL, LEAVECODE, MIN(LEAVEAPPLIEDON) /* MIN(LEAVEDATE)*/ LEAVEAPPLIEDON 
    FROM ( 
            SELECT  WORKERSERIAL, LEAVECODE, LEAVEDATE, LEAVEAPPLIEDON 
            FROM GPSLEAVEAPPLICATION 
            WHERE COMPANYCODE = 'BDBR01' AND DIVISIONCODE= '0002' 
              AND LEAVECODE = 'ML' 
              AND LEAVEDATE = TO_DATE('06/11/2020','DD/MM/YYYY') 
              AND LEAVESANCTIONEDON IS NOT NULL 
              /*AND TOKENNO='K01863' */  
              AND NVL(WAGERATE,0) > 0 
        ) 
    GROUP BY WORKERSERIAL, LEAVECODE 
 ) B    
 WHERE A.COMPANYCODE = 'BDBR01' AND A.DIVISIONCODE= '0002' 
   AND A.WORKERSERIAL = B.WORKERSERIAL 
   AND A.LEAVECODE = B.LEAVECODE 
   AND A.LEAVEAPPLIEDON = B.LEAVEAPPLIEDON 
   AND A.COMPANYCODE = M.COMPANYCODE AND A.DIVISIONCODE = M.DIVISIONCODE 
   AND A.WORKERSERIAL = M.WORKERSERIAL  
 GROUP BY A.WORKERSERIAL, M.TOKENNO, A.LEAVECODE, A.LEAVEAPPLIEDON, A.WAGERATE 



--------------------------------------------------------------------------------

SELECT * FROM GPSEMPLOYEERATE_MAXDT

 CREATE TABLE GPSEMPLOYEERATE_MAXDT as 
 
 SELECT WORKERSERIAL, MAX(EFFECTIVEDATE) EFFECTIVEDATE 
 FROM GPSCOMPONENTASSIGNMENT 
 WHERE COMPANYCODE = 'BDBR01' AND DIVISIONCODE = '0002' 
   AND TRANSACTIONTYPE = 'ASSIGNMENT' 
   AND EFFECTIVEDATE <= TO_DATE('06/11/2020','DD/MM/YYYY') 
 GROUP BY WORKERSERIAL 



--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW GPSATTN_VW AS 

 SELECT A.COMPANYCODE, A.DIVISIONCODE, '2020-2021' AS YEARCODE, A.ATTN_TYPECODE, /*A.CLUSTERCODE, */ 
 A.WORKERSERIAL, A.TOKENNO, A.CATEGORYCODE, 'SYSTEM' OCCUPATIONCODE, SUM(NVL(A.HAZIRA,0)) HAZIRA, SUM(NVL(A.EXTRAHAZIRA,0)) EXTRAHAZIRA, 
 SUM(NVL(A.ATTENDANCEHOURS,0)) ATTENDANCEHOURS, SUM(NVL(A.OVERTIMEHOURS,0)) OVERTIMEHOURS,  
 SUM(NVL(A.OUTPUTFORTHEDAY1,0) + NVL(A.OUTPUTFORTHEDAY2,0) + NVL(A.OUTPUTFORTHEDAY3,0) + NVL(A.OUTPUTFORTHEDAY4,0) + NVL(A.OUTPUTFORTHEDAY5,0)) TOTALOUTPUT 
 FROM GPSATTENDANCEDETAILS A 
 WHERE A.COMPANYCODE = 'BDBR01' AND A.DIVISIONCODE = '0002' 
   AND ATTENDANCEDATE >=  '28-OCT-20'  
   AND ATTENDANCEDATE <=  '28-OCT-20' 
--   AND A.ATTENDANCETYPE = 'ARREAR' 
 group by A.COMPANYCODE, A.DIVISIONCODE, /*A.YEARCODE,*/ A.ATTN_TYPECODE, /*A.CLUSTERCODE, */A.WORKERSERIAL, A.TOKENNO, A.CATEGORYCODE 


select distinct ATTENDANCETYPE from GPSATTENDANCEDETAILS

--------------------------------------------------------------------------------



PROC_GPSMATERNITY_RATE_UPDT('BDBR01','0002','ARREAR','2020-2021','28/10/2020','28/10/2020','28/10/2020','0','SWT_GPS_PHASE_0_1','GPSDAILYPAYSHEETDETAILS_SWT','','WORKER','','')
PROC_GPSWAGESPROCESS_INSERT('BDBR01','0002','ARREAR','2020-2021','28/10/2020','28/10/2020','28/10/2020','0','SWT_GPS_PHASE_0','GPSDAILYPAYSHEETDETAILS_SWT','','WORKER','','')
PROC_GPSWAGESPROCESS_UPDATE('BDBR01','0002','ARREAR','2020-2021','28/10/2020','28/10/2020','28/10/2020','1','SWT_GPS_PHASE_1','GPSDAILYPAYSHEETDETAILS_SWT','','WORKER','','')
PROC_GPSWAGESPROCESS_UPDATE('BDBR01','0002','ARREAR','2020-2021','28/10/2020','28/10/2020','28/10/2020','2','SWT_GPS_PHASE_2','GPSDAILYPAYSHEETDETAILS_SWT','','WORKER','','')
PROC_GPSWAGESPROCESS_UPDATE('BDBR01','0002','ARREAR','2020-2021','28/10/2020','28/10/2020','28/10/2020','4','SWT_GPS_PHASE_4','GPSDAILYPAYSHEETDETAILS_SWT','','WORKER','','')
PROC_GPSWAGESPROCESS_TRANSFER('BDBR01','0002','ARREAR','2020-2021','28/10/2020','28/10/2020','28/10/2020','100','GPSDAILYPAYSHEETDETAILS_SWT','GPSARREARDAILYPAYSHEETDETAILS','','WORKER','','')




--------------------------------------------------------------------------------

SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.EFFECTIVEDATE 
,  NVL(A.BASIC,0) AS BASIC, NVL(A.SPL_ALLOW,0) AS SPL_ALLOW, NVL(A.CYCLE_ALLOW,0) AS CYCLE_ALLOW, NVL(A.MED_ALLOW,0) AS MED_ALLOW, NVL(A.AGRE_ALLOW,0) AS AGRE_ALLOW 
 FROM GPSCOMPONENTASSIGNMENT A, GPSEMPLOYEERATE_MAXDT B
 WHERE A.COMPANYCODE = 'BDBR01' AND A.DIVISIONCODE = '0002' 
   AND A.TRANSACTIONTYPE = 'ASSIGNMENT' 
   AND A.WORKERSERIAL = B.WORKERSERIAL AND A.EFFECTIVEDATE = B.EFFECTIVEDATE 

--------------------------------------------------------------------------------

SELECT   A.COMPANYCODE, A.DIVISIONCODE,A.WORKERSERIAL, A.TOKENNO, A.EMPLOYEENAME, A.CATEGORYCODE, C.CATEGORYTYPE, A.GRADECODE, NVL(C.CALCFACTRODAYS,0) ATTN_CALCF, A.ATTNBOOKCODE, 
 A.CLUSTERCODE, A.OCCUPATIONCODE, A.DESIGNATIONCODE, NVL (A.SEX, 'M') SEX, A.MARITALSTATUS, A.ESINO, A.PFNO, A.RATION_FAMILY_NO, A.HEADOFTHEFAMILY, 
 A.DATEOFBIRTH, A.DATEOFJOINING, A.PAYMODE,  A.IFSCCODE, A.BANKACNO, A.QUARTERALLOTED, A.QUARTERNO, A.DAYOFFDAY, NVL(A.HRAAPPLICABLE,'N') HRAAPPLICABLE, 
 NVL(A.PFAPPLICABLE,'N') PFAPPLICABLE, NVL(A.EPFAPPLICABLE,'N') EPFAPPLICABLE, NVL(A.PTAXAPPLICABLE,'N') PTAXAPPLICABLE, NVL(A.LWFAPPLICABLE,'N') LWFAPPLICABLE, 
 NVL(A.GRATUITYAPPLICABLE,'N') GRATUITYAPPLICABLE, NVL(A.BONUSAPPLICABLE,'N') BONUSAPPLICABLE, A.RELIGION, NVL(A.VPFPERCENT,0) VPFPERCENT, 
 A.EMPLOYEESTATUS, NVL(B.BASIC,0) AS BASIC, NVL(B.SPL_ALLOW,0) AS SPL_ALLOW, NVL(B.CYCLE_ALLOW,0) AS CYCLE_ALLOW, NVL(B.MED_ALLOW,0) AS MED_ALLOW, NVL(B.AGRE_ALLOW,0) AS AGRE_ALLOW,  NVL(C.DAILYWAGES,0) DAILYWAGES 
 ,NVL(D.MAT_RT,0) MAT_RT 
 FROM   GPSEMPLOYEEMAST A, GPSEMPLOYEERATE_ASON B, GPSCATEGORYMAST C 
 , ( 
      SELECT A.WORKERSERIAL, A.RATE MAT_RT 
      FROM GPSEMPLOYEERATE A, 
      ( 
          SELECT WORKERSERIAL, MAX(APPLICABLEON) APPLICABLEON 
          FROM GPSEMPLOYEERATE 
          WHERE COMPANYCODE = 'BDBR01' AND DIVISIONCODE = '0002' 
            AND COMPONENTTYPE = 'MATERNITY LEAVE' 
            AND EFFECTIVEDATE <= TO_DATE('06/11/2020','DD/MM/YYYY') 
          GROUP BY WORKERSERIAL 
      ) B 
      WHERE A.COMPANYCODE = 'BDBR01' AND A.DIVISIONCODE = '0002'  
        AND A.WORKERSERIAL = B.WORKERSERIAL 
        AND A.APPLICABLEON = B.APPLICABLEON  
        AND A.COMPONENTTYPE = 'MATERNITY LEAVE' 
  ) D
 WHERE A.COMPANYCODE = 'BDBR01' AND A.DIVISIONCODE = '0002'  
   AND NVL(A.ACTIVE,'N') ='Y' AND NVL(A.TAKEPARTINWAGES,'N') = 'Y'   
   AND A.COMPANYCODE = B.COMPANYCODE (+) AND A.DIVISIONCODE = B.DIVISIONCODE (+) AND A.WORKERSERIAL = B.WORKERSERIAL (+) 
   AND A.COMPANYCODE = C.COMPANYCODE AND A.DIVISIONCODE = C.DIVISIONCODE AND A.CATEGORYCODE = C.CATEGORYCODE 
   AND A.WORKERSERIAL = D.WORKERSERIAL (+)  


--------------------------------------------------------------------------------

INSERT INTO GPSDAILYPAYSHEETDETAILS_SWT 
( 
    COMPANYCODE, DIVISIONCODE, SYSROWID, YEARCODE, PERIODFROM, PERIODTO, 
    ATTENDANCEDATE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, 
    OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE, 
    ATTN_CALCF, ATTENDANCEHOURS, OVERTIMEHOURS, HAZIRA, TOTALOUTPUT 
)

 
SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL SYSROWID, --'2020-2021',  '28-OCT-20','28-OCT-20', '28-OCT-20',  
A.WORKERSERIAL, A.TOKENNO, A.CATEGORYCODE, A.CATEGORYTYPE, A.OCCUPATIONCODE,  
A.CLUSTERCODE, A.AREACLASSIFICATIONCODE, A.ATTNBOOKCODE, DECODE(NVL(B.ATTN_CALCF,0),0,TO_NUMBER(SUBSTR(LAST_DAY('28-OCT-20'),1,2)),NVL(B.ATTN_CALCF,0)) ATTN_CALCF,
SUM(ATTENDANCEHOURS) ATTENDANCEHOURS, SUM(NVL(OVERTIMEHOURS,0)) OVERTIMEHOURS, SUM(NVL(HAZIRA,0)) HAZIRA, SUM(NVL(TOTALOUTPUT,0)) TOTALOUTPUT 
FROM 
( 
    SELECT Z.COMPANYCODE, Z.DIVISIONCODE, Z.WORKERSERIAL, Z.TOKENNO,Z.CATEGORYCODE, Z.CATEGORYTYPE, Z.OCCUPATIONCODE, 
    Z.CLUSTERCODE, Z.AREACLASSIFICATIONCODE, Z.ATTNBOOKCODE,
    SUM(ATTENDANCEHOURS) ATTENDANCEHOURS, SUM(OVERTIMEHOURS) OVERTIMEHOURS, SUM(NVL(HAZIRA,0)) HAZIRA, SUM(NVL(TOTALOUTPUT,0)) TOTALOUTPUT  
    FROM 
    (  
        SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.TOKENNO,A.CATEGORYCODE, A.CATEGORYTYPE, CASE WHEN 'WAGES PROCESS' = 'ARREAR' THEN 'SYSTEM' ELSE A.OCCUPATIONCODE END OCCUPATIONCODE,  
        A.CLUSTERCODE, A.AREACLASSIFICATIONCODE1 AREACLASSIFICATIONCODE, A.ATTNBOOKCODE, 
        NVL(ATTENDANCEHOURS,0) ATTENDANCEHOURS, NVL(OVERTIMEHOURS,0) OVERTIMEHOURS,   
        NVL(HAZIRA,0) HAZIRA, (NVL(OUTPUTFORTHEDAY1,0)+NVL(OUTPUTFORTHEDAY2,0)+NVL(OUTPUTFORTHEDAY3,0)+NVL(OUTPUTFORTHEDAY4,0)+NVL(OUTPUTFORTHEDAY5,0)) TOTALOUTPUT   
        FROM GPSATTENDANCEDETAILS A   
        WHERE A.COMPANYCODE = 'BDBR01' AND A.DIVISIONCODE = '0002' 
        AND A.ATTENDANCEDATE >= '28-OCT-20' AND A.ATTENDANCEDATE <= '28-OCT-20' 
        AND A.ATTENDANCETYPE LIKE '%NORMAL%' 
        AND CATEGORYTYPE = 'WORKER' 
    ) Z 
    GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE 
) A, GPSTEMPMAST B 
WHERE A.COMPANYCODE =  'BDBR01' AND A.DIVISIONCODE = '0002'  
AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE  
AND A.WORKERSERIAL = B.WORKERSERIAL 
GROUP BY A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.TOKENNO, A.CATEGORYCODE, A.CATEGORYTYPE, A.OCCUPATIONCODE,
A.CLUSTERCODE, A.AREACLASSIFICATIONCODE, A.ATTNBOOKCODE, NVL(B.ATTN_CALCF,0),
NVL(B.BASIC,0),NVL(B.SPL_ALLOW,0),NVL(B.CYCLE_ALLOW,0),NVL(B.MED_ALLOW,0),NVL(B.AGRE_ALLOW,0) 
HAVING  SUM(NVL(HAZIRA,0))> 0 

     
    
        
        




--------------------------------------------------------------------------------


 INSERT INTO GPSDAILYPAYSHEETDETAILS_SWT ( 
    COMPANYCODE, DIVISIONCODE, SYSROWID, YEARCODE, PERIODFROM, PERIODTO, ATTENDANCEDATE, 
    WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, OCCUPATIONCODE,
    CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE, ATTN_CALCF, 
    ATTENDANCEHOURS, OVERTIMEHOURS, HAZIRA, TOTALOUTPUT 
    ) 
    SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL SYSROWID, '2020-2021',  '28-OCT-20','28-OCT-20', '28-OCT-20',  
    A.WORKERSERIAL, A.TOKENNO, A.CATEGORYCODE, A.CATEGORYTYPE, A.OCCUPATIONCODE,  
    A.CLUSTERCODE, A.AREACLASSIFICATIONCODE, A.ATTNBOOKCODE, DECODE(NVL(B.ATTN_CALCF,0),0,TO_NUMBER(SUBSTR(LAST_DAY('28-OCT-20'),1,2)),NVL(B.ATTN_CALCF,0)) ATTN_CALCF,
        
       SUM(ATTENDANCEHOURS) ATTENDANCEHOURS, SUM(NVL(OVERTIMEHOURS,0)) OVERTIMEHOURS,  SUM(NVL(HAZIRA,0)) HAZIRA, SUM(NVL(TOTALOUTPUT,0)) TOTALOUTPUT 
    FROM 
    ( 
        SELECT Z.COMPANYCODE, Z.DIVISIONCODE, Z.WORKERSERIAL, Z.TOKENNO,Z.CATEGORYCODE, Z.CATEGORYTYPE, Z.OCCUPATIONCODE, 
        Z.CLUSTERCODE, Z.AREACLASSIFICATIONCODE, Z.ATTNBOOKCODE,
        SUM(ATTENDANCEHOURS) ATTENDANCEHOURS, SUM(OVERTIMEHOURS) OVERTIMEHOURS, SUM(NVL(HAZIRA,0)) HAZIRA, SUM(NVL(TOTALOUTPUT,0)) TOTALOUTPUT  
        FROM (  
               SELECT A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.TOKENNO,A.CATEGORYCODE, A.CATEGORYTYPE, CASE WHEN 'WAGES PROCESS' = 'ARREAR' THEN 'SYSTEM' ELSE A.OCCUPATIONCODE END OCCUPATIONCODE,  
               A.CLUSTERCODE, A.AREACLASSIFICATIONCODE1 AREACLASSIFICATIONCODE, A.ATTNBOOKCODE, 
               NVL(ATTENDANCEHOURS,0) ATTENDANCEHOURS, NVL(OVERTIMEHOURS,0) OVERTIMEHOURS,   
               NVL(HAZIRA,0) HAZIRA, (NVL(OUTPUTFORTHEDAY1,0)+NVL(OUTPUTFORTHEDAY2,0)+NVL(OUTPUTFORTHEDAY3,0)+NVL(OUTPUTFORTHEDAY4,0)+NVL(OUTPUTFORTHEDAY5,0)) TOTALOUTPUT   
               FROM GPSATTENDANCEDETAILS A   
               WHERE A.COMPANYCODE = 'BDBR01' AND A.DIVISIONCODE = '0002' 
                 AND A.ATTENDANCEDATE >= '28-OCT-20' AND A.ATTENDANCEDATE <= '28-OCT-20' 
                 AND A.ATTENDANCETYPE LIKE '%NORMAL%' 
                 AND CATEGORYTYPE = 'WORKER' 
              ) Z 
        GROUP BY COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, OCCUPATIONCODE, 
           CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE 
    ) A, GPSTEMPMAST B 
    WHERE A.COMPANYCODE =  'BDBR01' AND A.DIVISIONCODE = '0002'  
      AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE  
      AND A.WORKERSERIAL = B.WORKERSERIAL 
    GROUP BY A.COMPANYCODE, A.DIVISIONCODE, A.WORKERSERIAL, A.TOKENNO, A.CATEGORYCODE, A.CATEGORYTYPE, A.OCCUPATIONCODE,
      A.CLUSTERCODE, A.AREACLASSIFICATIONCODE, A.ATTNBOOKCODE, NVL(B.ATTN_CALCF,0),
            NVL(B.BASIC,0),NVL(B.SPL_ALLOW,0),NVL(B.CYCLE_ALLOW,0),NVL(B.MED_ALLOW,0),NVL(B.AGRE_ALLOW,0) 
    HAVING  SUM(NVL(HAZIRA,0))> 0 




--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------


COMPANYCODE, DIVISIONCODE, PROCESSTYPE, YEARCODE, PERIODFROM, PERIODTO, 
ATTENDANCEDATE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, 
OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE,
LALW_AL,LALW_SL,BASIC,DAILYWAGES,INCENTIVE
    

LALW_AL,LALW_SL,BASIC,DAILYWAGES,INCENTIVE	

SUM(NVL(LALW_AL,0)) LALW_AL,SUM(NVL(LALW_SL,0)) LALW_SL,SUM(NVL(BASIC,0)) BASIC,SUM(NVL(DAILYWAGES,0)) DAILYWAGES,SUM(NVL(INCENTIVE,0)) INCENTIVE	

SUM(NVL(LALW_AL,0))*-1 LALW_AL,SUM(NVL(LALW_SL,0))*-1 LALW_SL,SUM(NVL(BASIC,0))*-1 BASIC,
SUM(NVL(DAILYWAGES,0))*-1 DAILYWAGES,SUM(NVL(INCENTIVE,0))*-1 INCENTIVE



INSERT INTO GPSARREARDAILYPAYSHEETDETAILS
(
    COMPANYCODE, DIVISIONCODE,YEARCODE,PERIODFROM,PERIODTO,ATTENDANCEDATE,
    WORKERSERIAL, TOKENNO,CATEGORYCODE,CATEGORYTYPE, OCCUPATIONCODE, CLUSTERCODE,  ATTNBOOKCODE,
    PROCESSTYPE, 
    LALW_AL,LALW_SL,BASIC, DAILYWAGES, INCENTIVE
)
SELECT COMPANYCODE, DIVISIONCODE,'2020-2021' YEARCODE,'01-OCT-2020' PERIODFROM,'31-OCT-2020' PERIODTO,'31-OCT-2020' ATTENDANCEDATE,
A.WORKERSERIAL, A.TOKENNO,B.CATEGORYCODE,A.CATEGORYTYPE, B.OCCUPATIONCODE, B.CLUSTERCODE,  B.ATTNBOOKCODE,
'DAILY ARREAR PROCESS' PROCESSTYPE, 
SUM(NVL(LALW_AL,0)) LALW_AL,SUM(NVL(LALW_SL,0)) LALW_SL,SUM(NVL(BASIC,0)) BASIC,
SUM(NVL(DAILYWAGES,0)) DAILYWAGES,SUM(NVL(INCENTIVE,0)) INCENTIVE
FROM
(
    SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, 
    ATTENDANCEDATE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, 
    OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE, 
    SUM(NVL(LALW_AL,0)) LALW_AL,SUM(NVL(LALW_SL,0)) LALW_SL,SUM(NVL(BASIC,0)) BASIC,
    SUM(NVL(DAILYWAGES,0)) DAILYWAGES,SUM(NVL(INCENTIVE,0)) INCENTIVE
    FROM GPSARREARDAILYPAYSHEET_TEMP
    WHERE PERIODFROM BETWEEN TO_DATE('01-OCT-2020','DD/MM/YYYY') AND TO_DATE('01-OCT-2020','DD/MM/YYYY')
    AND PROCESSTYPE='NEW DAILY PROCESS'
    GROUP BY COMPANYCODE, DIVISIONCODE, YEARCODE, 
    ATTENDANCEDATE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, 
    OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE
    UNION ALL
    SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, 
    ATTENDANCEDATE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, 
    OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE, 
    SUM(NVL(LALW_AL,0))*-1 LALW_AL,SUM(NVL(LALW_SL,0))*-1 LALW_SL,SUM(NVL(BASIC,0))*-1 BASIC,
    SUM(NVL(DAILYWAGES,0))*-1 DAILYWAGES,SUM(NVL(INCENTIVE,0))*-1 INCENTIVE 
    FROM GPSDAILYPAYSHEETDETAILS_PREV
    WHERE PERIODFROM BETWEEN TO_DATE('01-OCT-2020','DD/MM/YYYY') AND TO_DATE('01-OCT-2020','DD/MM/YYYY')
     AND PROCESSTYPE='DAILY PROCESS'
     GROUP BY COMPANYCODE, DIVISIONCODE, YEARCODE, 
    ATTENDANCEDATE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, 
    OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE
) A, 
(
    SELECT WORKERSERIAL,TOKENNO, CATEGORYCODE, OCCUPATIONCODE, CLUSTERCODE,  ATTNBOOKCODE FROM GPSEMPLOYEEMAST
) B
WHERE A.WORKERSERIAL=B.WORKERSERIAL
GROUP BY COMPANYCODE, DIVISIONCODE, YEARCODE, B.CATEGORYCODE,A.CATEGORYTYPE, B.OCCUPATIONCODE, 
B.CLUSTERCODE, B.ATTNBOOKCODE, A.WORKERSERIAL, A.TOKENNO 
 
ORDER BY TOKENNO

GPSDAILYPAYSHEETDETAILS

SELECT TOKENNO, CATEGORYCODE, CATEGORYTYPE, 
OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE FROM GPSEMPLOYEEMAST

SELECT WORKERSERIAL,TOKENNO, CATEGORYCODE, OCCUPATIONCODE, CLUSTERCODE,  ATTNBOOKCODE FROM GPSEMPLOYEEMAST


SELECT * FROM GPSARREARDAILYPAYSHEETDETAILS
WHERE PROCESSTYPE='DAILY ARREAR PROCESS'


CREATE TABLE GPSDAILYPAYSHEETDETAILS_PREV AS 
SELECT * FROM GPSDAILYPAYSHEETDETAILS WHERE 1=2


INSERT INTO GPSDAILYPAYSHEETDETAILS_PREV
SELECT * FROM GPSDAILYPAYSHEETDETAILS
WHERE PERIODFROM BETWEEN '01-OCT-2020' AND '31-OCT-2020'
AND PROCESSTYPE='DAILY PROCESS'
     
SELECT * FROM GPSDAILYPAYSHEETDETAILS_PREV

     
     GROUP BY COMPANYCODE, DIVISIONCODE, YEARCODE, 
    ATTENDANCEDATE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, 
    OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE
    
    INSERT INTO GPSARREARDAILYPAYSHEET_TEMP
     
    
    SELECT * FROM GPSARREARDAILYPAYSHEETDETAILS
    WHERE 1=1 --PERIODFROM BETWEEN '01-OCT-2020' AND '31-OCT-2020'
    AND PROCESSTYPE<>'NEW DAILY PROCESS'
    
    
DELETE FROM GPSARREARDAILYPAYSHEET_TEMP

select * FROM GPSARREARDAILYPAYSHEETDETAILS

select max(periodfrom),count(*) FROM GPSARREARDAILYPAYSHEETDETAILS





    SELECT * FROM GPSARREARDAILYPAYSHEETDETAILS
    WHERE PERIODFROM BETWEEN '01-OCT-2020' AND '31-OCT-2020'
    AND PROCESSTYPE<>'NEW DAILY PROCESS'
    AND DAILYWAGES =0
    
    select * from GPSDAILYPAYSHEETDETAILS_SWT
    
EXEC PROC_GPSWAGESPROCESS_ARREAR('BDBR01','0002','ARREAR','2020-2021','20/10/2020','30/10/2020','30/10/2020','100','GPSDAILYPAYSHEETDETAILS_SWT','GPSARREARDAILYPAYSHEETDETAILS','','WORKER','','')


DELETE FROM GPS_ERROR_LOG


SELECT * FROM GPS_ERROR_LOG

INSERT INTO GPSARREARDAILYPAYSHEETDETAILS
(
    COMPANYCODE, DIVISIONCODE,YEARCODE,PERIODFROM,PERIODTO,ATTENDANCEDATE,
    WORKERSERIAL, TOKENNO,CATEGORYCODE,CATEGORYTYPE, OCCUPATIONCODE, CLUSTERCODE,  ATTNBOOKCODE,
    PROCESSTYPE, 
LALW_AL,LALW_SL,BASIC,DAILYWAGES,INCENTIVE
)

SELECT COMPANYCODE, DIVISIONCODE,'2020-2021' YEARCODE,TO_DATE('01/10/2020','DD/MM/YYYY') PERIODFROM,TO_DATE('30/10/2020','DD/MM/YYYY') PERIODTO,TO_DATE('30/10/2020','DD/MM/YYYY') ATTENDANCEDATE,
A.WORKERSERIAL, A.TOKENNO,B.CATEGORYCODE,A.CATEGORYTYPE, B.OCCUPATIONCODE, B.CLUSTERCODE,  B.ATTNBOOKCODE,
'DAILY ARREAR PROCESS' PROCESSTYPE, 
SUM(NVL(LALW_AL,0)) LALW_AL,SUM(NVL(LALW_SL,0)) LALW_SL,SUM(NVL(BASIC,0)) BASIC,SUM(NVL(DAILYWAGES,0)) DAILYWAGES,SUM(NVL(INCENTIVE,0)) INCENTIVE
FROM
(
    SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, 
    ATTENDANCEDATE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, 
    OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE, 
    SUM(NVL(LALW_AL,0)) LALW_AL,SUM(NVL(LALW_SL,0)) LALW_SL,SUM(NVL(BASIC,0)) BASIC,SUM(NVL(DAILYWAGES,0)) DAILYWAGES,SUM(NVL(INCENTIVE,0)) INCENTIVE
    FROM GPSARREARDAILYPAYSHEET_TEMP
    WHERE PERIODFROM BETWEEN TO_DATE('01/10/2020','DD/MM/YYYY') AND TO_DATE('30/10/2020','DD/MM/YYYY')
    AND PROCESSTYPE='NEW DAILY PROCESS'
    GROUP BY COMPANYCODE, DIVISIONCODE, YEARCODE, 
    ATTENDANCEDATE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, 
    OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE
    UNION ALL
    SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, 
    ATTENDANCEDATE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, 
    OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE, 
    SUM(NVL(LALW_AL,0))*-1 LALW_AL,SUM(NVL(LALW_SL,0))*-1 LALW_SL,SUM(NVL(BASIC,0))*-1 BASIC,SUM(NVL(DAILYWAGES,0))*-1 DAILYWAGES,SUM(NVL(INCENTIVE,0))*-1 INCENTIVE
    FROM GPSDAILYPAYSHEETDETAILS_PREV
    WHERE PERIODFROM BETWEEN TO_DATE('01/10/2020','DD/MM/YYYY') AND TO_DATE('30/10/2020','DD/MM/YYYY')
     AND PROCESSTYPE='DAILY PROCESS'
     GROUP BY COMPANYCODE, DIVISIONCODE, YEARCODE, 
    ATTENDANCEDATE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, 
    OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE
) A, 
(
    SELECT WORKERSERIAL,TOKENNO, CATEGORYCODE, OCCUPATIONCODE, CLUSTERCODE,  ATTNBOOKCODE FROM GPSEMPLOYEEMAST
) B
WHERE A.WORKERSERIAL=B.WORKERSERIAL
GROUP BY COMPANYCODE, DIVISIONCODE, YEARCODE, B.CATEGORYCODE,A.CATEGORYTYPE, B.OCCUPATIONCODE, 
B.CLUSTERCODE, B.ATTNBOOKCODE, A.WORKERSERIAL, A.TOKENNO


SELECT TOKENNO, PERIODFROM,DAILYWAGES FROM GPSARREARDAILYPAYSHEET_TEMP
WHERE TOKENNO='K00188'


SELECT TOKENNO, PERIODFROM,DAILYWAGES FROM GPSDAILYPAYSHEETDETAILS_PREV
WHERE TOKENNO='K00188'

GROUP BY TOKENNO



SELECT TOKENNO, COUNT(TOKENNO),SUM(NVL(DAILYWAGES,0))*-1 DAILYWAGES FROM GPSDAILYPAYSHEETDETAILS_PREV
WHERE TOKENNO='K00188'
GROUP BY TOKENNO


    WHERE PERIODFROM BETWEEN TO_DATE('01/10/2020','DD/MM/YYYY') AND TO_DATE('30/10/2020','DD/MM/YYYY')
    AND PROCESSTYPE='NEW DAILY PROCESS'
    GROUP BY COMPANYCODE, DIVISIONCODE, YEARCODE, 
    ATTENDANCEDATE, WORKERSERIAL, TOKENNO, CATEGORYCODE, CATEGORYTYPE, 
    OCCUPATIONCODE, CLUSTERCODE, AREACLASSIFICATIONCODE, ATTNBOOKCODE
    
    

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