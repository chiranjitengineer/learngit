CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_ELECBLNC_WITH_BILL_EMI_BK
(
    P_COMPCODE  VARCHAR2,
    P_DIVCODE VARCHAR2,
    P_STARTDATE    VARCHAR2,
    P_ENDDATE      VARCHAR2,    
    P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
    P_MODULE       VARCHAR2 DEFAULT 'WPS',
    P_WAGEPROCESS  VARCHAR2 DEFAULT 'NO'
)
AS 
    LV_SQLSTR           VARCHAR2(20000);
BEGIN
     DELETE FROM GBL_ELECBLNC;
     COMMIT;
    IF P_WAGEPROCESS ='YES' THEN
        DELETE FROM ELECTRICDEDUCTIONBREAKUP WHERE DEDUCTIONDATE= TO_DATE(P_ENDDATE,'DD/MM/YYYY') AND MODULE=P_MODULE;
    END IF;
    LV_SQLSTR := ' INSERT INTO GBL_ELECBLNC '||CHR(10)
           ||'  SELECT A.WORKERSERIAL, A.TOKENNO, A.QUARTERNO, READINGDATE, BILLAMOUNT, PREVIOUSDUEAMOUNT, NVL(CONTRIBUTIONAMOUNT,0)+NVL(PREVIOUSDUEAMOUNT,0) TOTALCONTRIBUTION,  '||CHR(10) 
           ||'  C.ELEC_BAL_AMT, EMIAMOUNT '||CHR(10)
           ||'  FROM ELECTRICMETERREADING A, '||CHR(10)
           ||'  ( '||CHR(10)
           ||'      SELECT WORKERSERIAL, MAX(FORTNIGHTSTARTDATE) FORTNIGHTSTARTDATE  '||CHR(10)
           ||'      FROM ELECTRICMETERREADING  '||CHR(10)
           ||'      WHERE COMPANYCODE = '''||P_COMPCODE||'''  '||CHR(10)
           ||'        AND FORTNIGHTSTARTDATE <= TO_DATE('''||P_STARTDATE||''',''DD/MM/YYYY'')  '||CHR(10) 
           ||'      GROUP BY WORKERSERIAL  '||CHR(10)
           ||'  ) B,  '||CHR(10)
           ||'  (  '||CHR(10)
           ||'      SELECT WORKERSERIAL, SUM(ELEC_BAL_AMT) ELEC_BAL_AMT  '||CHR(10)
           ||'      FROM (  '||CHR(10)
           ||'              SELECT WORKERSERIAL, SUM(NVL(CONTRIBUTIONAMOUNT,0))+SUM(NVL(PREV_DUE_AMT,0)) ELEC_BAL_AMT  '||CHR(10)
           ||'              FROM ELECTRICMETERREADING   '||CHR(10)
           ||'               WHERE COMPANYCODE= '''||P_COMPCODE||'''    '||CHR(10)
           ||'                 AND DIVISIONCODE='''||P_DIVCODE||'''     '||CHR(10)
           ||'                 AND FORTNIGHTSTARTDATE <= TO_DATE('''||P_STARTDATE||''',''DD/MM/YYYY'')  '||CHR(10)
           ||'              GROUP BY WORKERSERIAL   '||CHR(10)
           ||'              UNION ALL  '||CHR(10)
           ||'              SELECT WORKERSERIAL,-1* SUM(NVL(DEDUCTEDAMT,0)) ELEC_BAL_AMT  '||CHR(10)
           ||'              FROM ELECTRICDEDUCTIONBREAKUP    '||CHR(10)
           ||'               WHERE COMPANYCODE='''||P_COMPCODE||'''     '||CHR(10)
           ||'                 AND DIVISIONCODE= '''||P_DIVCODE||'''  '||CHR(10)
           ||'                 AND DEDUCTIONDATE <= TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')  '||CHR(10)
           ||'              GROUP BY WORKERSERIAL        '||CHR(10)
           ||'         )   '||CHR(10)
           ||'       GROUP BY WORKERSERIAL   '||CHR(10)
           ||'  ) C  '||CHR(10)
           ||'  WHERE A.COMPANYCODE ='''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''   '||CHR(10)
           ||'    AND A.WORKERSERIAL=B.WORKERSERIAL   '||CHR(10)
           ||'    AND A.FORTNIGHTSTARTDATE =B.FORTNIGHTSTARTDATE   '||CHR(10)
           ||'    AND A.WORKERSERIAL = C.WORKERSERIAL   '||CHR(10);


--    LV_SQLSTR := ' INSERT INTO GBL_ELECBLNC '||CHR(10)
--                ||' SELECT WORKERSERIAL,TOKENNO,'''' QUARTERNO,   '||CHR(10)
--                ||' SUM(NVL(ELEC_BAL_AMT,0)) ELEC_BAL_AMT,   '||CHR(10)
--                ||' /*(CASE WHEN SUBSTR(TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY''),1,2)<>''15'' THEN   '||CHR(10) 
--                ||'           ROUND(SUM(NVL(ELEC_BAL_AMT,0))/2)   '||CHR(10)
--                ||'      ELSE   '||CHR(10)
--                ||'           ROUND(SUM(NVL(ELEC_BAL_AMT,0)))   '||CHR(10)
--                ||'      END) ELEC_EMI_AMT */  SUM(NVL(ELEC_BAL_AMT,0)) ELEC_EMI_AMT   '||CHR(10)
--                ||' FROM (   '||CHR(10)
--                ||'     SELECT WORKERSERIAL,TOKENNO,SUM(NVL(ELEC_DED_AMT,0))+SUM(NVL(PREV_DUE_AMT,0)) /* SUM(NVL(ELEC_EMI,0))*/ ELEC_BAL_AMT   '||CHR(10) 
--                ||'       FROM ELECTRICMETERREADING   '||CHR(10)
--                ||'     WHERE COMPANYCODE='''||P_COMPANYCODE||'''   '||CHR(10)
--                ||'       AND DIVISIONCODE='''||P_DIVISIONCODE||'''   '||CHR(10)
--                ||'       AND READINGDATE >= TO_DATE(''01/08/2018'',''DD/MM/YYYY'') '||CHR(10)  --- THIS LINE ADDED DUE TO WAGES LIVE ON 01/08/2018
--                ||'       AND READINGDATE<=TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')   '||CHR(10)
--                ||'       --AND NVL(PREV_DUE_AMT,0)>0   '||CHR(10)
--                ||'     GROUP BY WORKERSERIAL,TOKENNO     '||CHR(10)
--                ||'     UNION ALL   '||CHR(10)
--                ||'     SELECT WORKERSERIAL,TOKENNO,-1* SUM(NVL(DEDUCTEDAMT,0)) DEDUCTEDAMT   '||CHR(10) 
--                ||'       FROM ELECTRICDEDUCTIONBREAKUP   '||CHR(10)
--                ||'     WHERE COMPANYCODE='''||P_COMPANYCODE||'''   '||CHR(10)
--                ||'       AND DIVISIONCODE='''||P_DIVISIONCODE||'''   '||CHR(10)
--                ||'       AND DEDUCTIONDATE >= TO_DATE(''01/08/2018'',''DD/MM/YYYY'') '||CHR(10)  --- THIS LINE ADDED DUE TO WAGES LIVE ON 01/08/2018
--                ||'       AND DEDUCTIONDATE<TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')   '||CHR(10)
--                ||'     GROUP BY WORKERSERIAL,TOKENNO    '||CHR(10)
--                ||' )GROUP BY WORKERSERIAL,TOKENNO  '||CHR(10);

  DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
  EXECUTE IMMEDIATE LV_SQLSTR;
END;
/
