CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_ESICONT_MONTHLY_NJML(
                                            P_COMPANYCODE VARCHAR2,
                                            P_DIVISIONCODE VARCHAR2,
                                            P_FROMDATE VARCHAR2,
                                            P_TODATE VARCHAR2,
                                            P_TOKENNO VARCHAR2 DEFAULT NULL
                                           )
AS
    LV_SQLSTR      VARCHAR2(26000);
    LV_COMPANY     VARCHAR2(150);
    LV_DIVISION    VARCHAR2(150);
    LV_MONTHDATE   VARCHAR2(15);
BEGIN

     SELECT TO_CHAR(TO_DATE(LAST_DAY(TO_date(P_FROMDATE,'dd/mm/yyyy'))),'DD') INTO LV_MONTHDATE FROM DUAL;

     SELECT COMPANYNAME INTO LV_COMPANY FROM COMPANYMAST WHERE COMPANYCODE=P_COMPANYCODE;
     SELECT DIVISIONNAME INTO LV_DIVISION FROM DIVISIONMASTER WHERE COMPANYCODE=P_COMPANYCODE AND DIVISIONCODE=P_DIVISIONCODE;

    DELETE FROM GTT_ESICONTR_EXCEL_NJML;  
       LV_SQLSTR := 'INSERT INTO GTT_ESICONTR_EXCEL_NJML'||CHR(10)
                              ||'(SRLNO, COMPANYCODE,DIVISIONCODE,COMPANYNAME,EX1,WORKERSERIAL,EMPCODE,EMPNAME,ESINO,TOTALDAYS,TOTALWAGE,ESICONT,AVGDYWAGES,REMARKS,EX2,EX3,EX4,LASTWORKINGDATE,TYPE)'||CHR(10)
       
                              ||'SELECT ROWNUM,COMPANYCODE, DIVISIONCODE, COMPANYNAME, DIVISIONNAME, WORKERSERIAL, EMPCODE, EMPNAME, ESINO, TOTALDAYS, TOTALWAGE, '||CHR(10)
                              ||' ESICONT, AVGDYWAGES, REMARKS, EX2, EX3, EX4,  '||CHR(10)
                              ||'  CASE WHEN LASTWORKINGDATE<=TO_DATE('''|| P_TODATE || ''',''DD/MM/YYYY'') THEN LASTWORKINGDATE ELSE NULL END LASTWORKINGDATE, TYPE /*,fnWorkerReasonCode(WORKERSERIAL,TOTALDAYS,ESINO,EX5)*/ FROM ('||CHR(10)
                              ||'   SELECT '''||P_COMPANYCODE|| ''' COMPANYCODE,'''||P_DIVISIONCODE|| '''DIVISIONCODE,'''||LV_COMPANY||''' AS COMPANYNAME,'''||LV_DIVISION||''' AS DIVISIONNAME, '||CHR(10)
                              ||'      WORKERSERIAL,EMPCODE,EMPNAME,ESINO, CASE WHEN SUM(NVL(TOTALDAYS,0))<='''||LV_MONTHDATE||''' THEN SUM(NVL(TOTALDAYS,0)) ELSE '||LV_MONTHDATE||' END TOTALDAYS ,SUM(NVL(TOTALWAGE,0)) TOTALWAGE , '||CHR(10)
                              ||'      SUM(NVL(ESICONT,0)) ESICONT ,SUM(NVL(AVGDYWAGES,0)) AVGDYWAGES,'''' AS REMARKS,  '||CHR(10)
                              ||'      ''ESI CONTRIBUTION PERIOD  '' AS EX2,''FROM  ''|| TO_CHAR(TO_DATE('''|| P_FROMDATE || ''',''DD/MM/YYYY''),''MON-YYYY'') ||'' TO '' || TO_CHAR(LAST_DAY(TO_DATE('''|| P_FROMDATE || ''',''DD/MM/YYYY'')),''MON-YYYY'') AS EX3,''40-3167-12'' AS EX4, '||CHR(10)
                              ||'       LASTWORKINGDATE, 1 TYPE --,fnWorkerReasonCode(WORKERSERIAL,SUM(NVL(TOTALDAYS,0)),ESINO,1) REASON '||CHR(10)
                              ||'   FROM '||CHR(10)
                              ||'   (  '||CHR(10)  
                              ||'        SELECT A.WORKERSERIAL,A.TOKENNO EMPCODE,B.WORKERNAME EMPNAME,B.ESINO,A.DEPARTMENTCODE DEPT,A.SECTIONCODE SECT, '||CHR(10)
                              ||'          '''' SRLNO,SUM(NVL(STLDAYS,0)) AS TOTALDAYS,SUM(NVL(ESI_GROSS,0)) TOTALWAGE,SUM(NVL(A.ESI_E,0)) ESICONT,0 AVGDYWAGES,DATEOFTERMINATION LASTWORKINGDATE '||CHR(10)
                              ||'        FROM WPSSTLWAGESDETAILS A,WPSWORKERMAST B WHERE 1=1 '||CHR(10)
                              ||'               AND A.COMPANYCODE ='''||P_COMPANYCODE|| ''' '||CHR(10)
                              ||'               AND A.DIVISIONCODE = '''||P_DIVISIONCODE|| ''' '||CHR(10) 
                              ||'               AND A.PAYMENTDATE>=TO_DATE('''|| P_FROMDATE || ''',''DD/MM/YYYY'')            '||CHR(10)
                              ||'               AND A.PAYMENTDATE<=LAST_DAY(TO_DATE('''|| P_FROMDATE || ''',''DD/MM/YYYY''))  '||CHR(10)
                              ||'               AND A.COMPANYCODE = B.COMPANYCODE   (+)                   '||CHR(10)  
                              ||'               AND A.DIVISIONCODE = B.DIVISIONCODE (+)                   '||CHR(10)
                              ||'               AND A.WORKERSERIAL = B.WORKERSERIAL (+)                   '||CHR(10)
                              ||'               AND B.WORKERCATEGORYCODE NOT IN (''O'',''A'')             '||CHR(10)
                              ||'       GROUP BY A.WORKERSERIAL,A.TOKENNO,B.WORKERNAME,A.DEPARTMENTCODE,A.SECTIONCODE,B.ESINO,DATEOFTERMINATION  '||CHR(10)
                              ||'       UNION ALL   '||CHR(10)
                              ||'       SELECT A.WORKERSERIAL,A.TOKENNO EMPCODE,B.WORKERNAME EMPNAME,B.ESINO,A.DEPARTMENTCODE DEPT,A.SECTIONCODE SECT, '||CHR(10)
                              ||'              A.SERIALNO SRLNO,SUM(NVL(A.FEWORKINGDAYS,0)) AS TOTALDAYS,SUM(NVL(A.ESI_GROSS,0)) TOTALWAGE,SUM(NVL(A.ESI_CONT,0)) ESICONT,  '||CHR(10)
                              ||'              0 AVGDYWAGES,DATEOFTERMINATION LASTWORKINGDATE  '||CHR(10)
                              ||'       FROM WPSWAGESDETAILS_MV A,WPSWORKERMAST B WHERE 1=1  '||CHR(10)
                              ||'               AND A.COMPANYCODE ='''||P_COMPANYCODE|| '''  '||CHR(10) 
                              ||'               AND A.DIVISIONCODE = '''||P_DIVISIONCODE|| ''' '||CHR(10)  
                              ||'               AND A.FORTNIGHTSTARTDATE>=TO_DATE('''|| P_FROMDATE || ''',''DD/MM/YYYY'')          '||CHR(10)
                              ||'               AND A.FORTNIGHTENDDATE<=LAST_DAY(TO_DATE('''|| P_FROMDATE || ''',''DD/MM/YYYY''))  '||CHR(10)
                              ||'               AND A.COMPANYCODE = B.COMPANYCODE   (+)  '||CHR(10)
                              ||'               AND A.DIVISIONCODE = B.DIVISIONCODE (+)  '||CHR(10) 
                              ||'               AND A.WORKERSERIAL = B.WORKERSERIAL (+)  '||CHR(10)
                              ||'               AND B.WORKERCATEGORYCODE NOT IN (''O'',''A'')             '||CHR(10)
                              ||'       GROUP BY A.WORKERSERIAL, A.SERIALNO,A.TOKENNO,B.WORKERNAME,A.DEPARTMENTCODE ,A.SECTIONCODE,B.ESINO,DATEOFTERMINATION  '||CHR(10)
--                              ||'       UNION ALL  '||CHR(10)
--                              ||'       SELECT A.TOKENNO EMPCODE,B.WORKERNAME EMPNAME,B.ESINO,A.DEPARTMENTCODE DEPT,A.SECTIONCODE SECT,  '||CHR(10)
--                              ||'              A.SERIALNO SRLNO,SUM(NVL(A.ATN_DAYS,0)) AS TOTALDAYS,SUM(NVL(A.ESI_GROSS,0)) TOTALWAGE,SUM(NVL(A.ESI_CONT,0)) ESICONT, '||CHR(10)
--                              ||'              0 AVGDYWAGES,'''' AS REMARKS  '||CHR(10)
--                              ||'       FROM WPSVOUCHERDETAILS A,WPSWORKERMAST B WHERE 1=1        '||CHR(10) 
--                              ||'                AND A.COMPANYCODE ='''||P_COMPANYCODE|| '''      '||CHR(10)
--                              ||'                AND A.DIVISIONCODE = '''||P_DIVISIONCODE|| '''   '||CHR(10)
--                              ||'                AND A.FORTNIGHTSTARTDATE>=TO_DATE('''|| P_FROMDATE || ''',''DD/MM/YYYY'')          '||CHR(10)
--                              ||'                AND A.FORTNIGHTENDDATE<=LAST_DAY(TO_DATE('''|| P_FROMDATE || ''',''DD/MM/YYYY''))  '||CHR(10)
--                              ||'                AND A.COMPANYCODE = B.COMPANYCODE   (+)   '||CHR(10)
--                              ||'                AND A.DIVISIONCODE = B.DIVISIONCODE (+)   '||CHR(10)
--                              ||'                AND A.WORKERSERIAL = B.WORKERSERIAL (+)   '||CHR(10)
--                              ||'      GROUP BY A.TOKENNO,B.WORKERNAME,A.DEPARTMENTCODE,A.SECTIONCODE,A.SERIALNO,B.ESINO  '||CHR(10)
                              ||'  ) X  '||CHR(10);
                              IF P_TOKENNO   IS NOT NULL THEN     
                                          LV_SQLSTR:=LV_SQLSTR ||' WHERE X.EMPCODE IN ('||P_TOKENNO ||') '||CHR(10);
                              END IF;   
                              LV_SQLSTR:=LV_SQLSTR||' GROUP BY EMPCODE,EMPNAME,ESINO,LASTWORKINGDATE,WORKERSERIAL                               
                              
                        UNION ALL  
                       --*********************
                        SELECT  '''||P_COMPANYCODE|| ''','''||P_DIVISIONCODE|| ''','''||LV_COMPANY||''' AS COMPANYNAME,'''||LV_DIVISION||''' AS DIVISIONNAME, 
                        A.WORKERSERIAL,A.TOKENNO EMPCODE,EMPLOYEENAME WORKERNAME,ESINO,
                        CASE WHEN NVL(ATTN_SALD,0)<='''||LV_MONTHDATE||''' THEN NVL(ATTN_SALD,0) ELSE '||LV_MONTHDATE||' END TOTALDAYS ,ESI_GROSS TOTALWAGE , 
                        NVL(ESI_E,0) ESICONT ,0 AVGDYWAGES,'''' AS REMARKS,
                        ''ESI CONTRIBUTION PERIOD  '' AS EX2,''FROM  ''|| TO_CHAR(TO_DATE('''|| P_FROMDATE || ''',''DD/MM/YYYY''),''MON-YYYY'') ||'' TO '' || TO_CHAR(LAST_DAY(TO_DATE('''|| P_FROMDATE || ''',''DD/MM/YYYY'')),''MON-YYYY'') AS EX3,''40-3167-12'' AS EX4,  
                        STATUSDATE LASTWORKINGDATE,2 TYPE --,fnWorkerReasonCode(A.WORKERSERIAL,ATTN_SALD,ESINO,2) REASON 
                        FROM (           
                            SELECT A.COMPANYCODE,A.DIVISIONCODE,WORKERSERIAL,TOKENNO,A.DEPARTMENTCODE,'''' SECTIONCODE, EMPLOYEENAME, ESINO, 
                            EXTENDEDRETIREDATE AS EMPLOYEEDATEOFRETIRE, A.CATEGORYCODE,  STATUSDATE
                            FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER B 
                            WHERE
                            A.COMPANYCODE=B.COMPANYCODE
                            AND A.DIVISIONCODE=B.DIVISIONCODE
                            AND A.CATEGORYCODE=B.CATEGORYCODE
                            AND A.COMPANYCODE = '''||P_COMPANYCODE|| '''
                            --AND A.DIVISIONCODE= ''0001''  
                            --AND B.CATEGORYCODE IN (2,3)        
                            AND DATEOFJOIN <= TO_DATE('''|| P_TODATE || ''',''DD/MM/YYYY'')    
                            --change 28112020    
                            --AND (STATUSDATE IS NULL OR STATUSDATE >TO_DATE('''|| P_TODATE || ''',''DD/MM/YYYY''))
                            --AND (EMPLOYEESTATUS=''ACTIVE'' OR STATUSDATE >=TO_DATE('''|| P_TODATE || ''',''DD/MM/YYYY'')) -- change 28112020
--                             and ESIAPPLICABLE=''Y''
                            --AND ESINO IS NOT NULL                  
                        ) A,            
                        (     
                            SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO, ESI_GROSS,ESI_E,ESI_C,ATTN_LDAY,ATTN_SALD  
                            FROM PISPAYTRANSACTION  
                            WHERE COMPANYCODE = '''||P_COMPANYCODE|| '''
                            --AND DIVISIONCODE= ''0001''                             
                            AND YEARMONTH = TO_CHAR(TO_DATE('''|| P_FROMDATE || ''',''DD/MM/YYYY''),''YYYYMM'')  
                        ) B  
                        WHERE 1=1
                        --AND ESI_GROSS>0 
                        AND A.COMPANYCODE=B.COMPANYCODE --(+)  
                        --AND A.DIVISIONCODE=B.DIVISIONCODE(+)  
                        AND A.WORKERSERIAL=B.WORKERSERIAL --(+)   
                       --*******************************                                   
                              
                               )Y'||CHR(10)
                              ||' ORDER BY ROWNUM '||CHR(10);
                              
   DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
   EXECUTE IMMEDIATE LV_SQLSTR; 
      
    INSERT INTO GTT_ESICONTR_REASONCODE
    (EMPCODE, WORKERSERIAL, TOTALDAYS, ESINO, TYPE, REASON)
    select EMPCODE,WORKERSERIAL,TOTALDAYS,ESINO,TYPE, fnWorkerReasonCode(WORKERSERIAL,TOTALDAYS,ESINO,TYPE)REASON from GTT_ESICONTR_EXCEL_NJML;

    update GTT_ESICONTR_EXCEL_NJML A set reason=(SELECT REASON FROM  GTT_ESICONTR_REASONCODE B WHERE A.WORKERSERIAL=B.WORKERSERIAL)
    WHERE A.WORKERSERIAL=WORKERSERIAL
    AND A.WORKERSERIAL IN (SELECT WORKERSERIAL FROM  GTT_ESICONTR_REASONCODE) ;
 
--SELECT A.COMPANYCODE,A.DIVISIONCODE, 
--A.TOKENNO,EMPLOYEENAME,ESINO, CASE WHEN NVL(ATTN_SALD,0)<='30' THEN NVL(ATTN_SALD,0) ELSE 30 END TOTALDAYS ,ESI_GROSS TOTALWAGE , 
--NVL(ESI_E,0) ESICONT ,ATTN_SALD AVGDYWAGES,
--'ESI CONTRIBUTION PERIOD  ' AS EX2,'FROM  '|| TO_CHAR(TO_DATE('01/09/2020','DD/MM/YYYY'),'MON-YYYY') ||' TO ' || TO_CHAR(LAST_DAY(TO_DATE('01/09/2020','DD/MM/YYYY')),'MON-YYYY') AS EX3,'40-3167-12' AS EX4, 
--STATUSDATE LASTWORKINGDATE ,fnWorkerReasonCode(A.WORKERSERIAL,ATTN_SALD,ESINO) REASON 
--FROM (           
--            SELECT A.COMPANYCODE,A.DIVISIONCODE,WORKERSERIAL,TOKENNO, EMPLOYEENAME, ESINO, EXTENDEDRETIREDATE AS EMPLOYEEDATEOFRETIRE,  
--            A.CATEGORYCODE,  STATUSDATE
--            FROM PISEMPLOYEEMASTER A, PISCATEGORYMASTER B 
--            WHERE
--            A.COMPANYCODE=B.COMPANYCODE
--            AND A.DIVISIONCODE=B.DIVISIONCODE
--            AND A.CATEGORYCODE=B.CATEGORYCODE
--            AND A.COMPANYCODE = 'NJ0001'  
--            AND A.DIVISIONCODE= '0001'  
--            AND B.CATEGORYCODE IN (2,3)        
--            AND DATEOFJOIN <= LAST_DAY(TO_DATE('202009','YYYYMM'))          
--            AND (STATUSDATE IS NULL OR STATUSDATE > TO_DATE('202002','YYYYMM'))           
--            AND EMPLOYEESTATUS='ACTIVE'          
--            --AND ESINO IS NOT NULL                  
--        ) A,            
--        (     
--            SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO, ESI_GROSS,ESI_E,ESI_C,ATTN_LDAY,ATTN_SALD  
--            FROM PISPAYTRANSACTION  
--            WHERE COMPANYCODE = 'NJ0001'  
--            AND DIVISIONCODE= '0001'  
--            AND YEARCODE ='2020-2021'  
--            AND YEARMONTH = TO_CHAR(TO_DATE('202009','YYYYMM'),'YYYYMM') 
--        ) B  
--    WHERE 1=1
--    --AND ESI_GROSS>0 
--    AND A.COMPANYCODE=B.COMPANYCODE(+)  
--    AND A.DIVISIONCODE=B.DIVISIONCODE(+)  
--    AND A.WORKERSERIAL=B.WORKERSERIAL(+)   
-- 
      
            
     COMMIT;
   
   END;
/
