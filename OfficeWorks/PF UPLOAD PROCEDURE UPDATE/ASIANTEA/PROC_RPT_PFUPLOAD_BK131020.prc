CREATE OR REPLACE PROCEDURE ASIANTEA.PROC_RPT_PFUPLOAD_bk131020
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_YEARMONTH VARCHAR2,
    P_CLUSTERCODE VARCHAR2 DEFAULT NULL
    )
AS 
    LV_SQLSTR VARCHAR2(15000);
   
    P_FROMDATE VARCHAR2(20);
    P_TODATE VARCHAR2(20);
    REPMONTH VARCHAR2(20);
    
BEGIN

    DELETE FROM GTT_RPT_PFUPLOAD;   
                
                SELECT TO_CHAR(TO_DATE(''||P_YEARMONTH||'','YYYYMM'),'DD/MM/YYYY') INTO  P_FROMDATE FROM DUAL;
                        
                SELECT TRIM(TO_CHAR(TO_DATE(''|| P_FROMDATE ||'','DD/MM/YYYY'),'MONTH')) ||'-'||TO_CHAR(TO_DATE(''|| P_FROMDATE ||'','DD/MM/YYYY'),'YYYY')  INTO REPMONTH FROM DUAL;
                        
                --FIRST DATE OF THE MONTH CURRENT YEAR
                SELECT TO_CHAR(LAST_DAY(ADD_MONTHS(TO_DATE(''|| P_FROMDATE ||'','DD/MM/YYYY'),-1)), 'DD/MM/YYYY') INTO P_TODATE FROM DUAL;

                SELECT TO_CHAR(LAST_DAY(TO_DATE(''|| P_FROMDATE ||'','DD/MM/YYYY')), 'DD/MM/YYYY') INTO P_TODATE FROM DUAL;
                     
             LV_SQLSTR :=      '    INSERT INTO GTT_RPT_PFUPLOAD '|| CHR(10) 
                            || '              SELECT C.COMPANYNAME, D.DIVISIONNAME, '''||REPMONTH||''',B.UANNO, B.EMPLOYEENAME || '' '',ROUND(A.GROSSWAGES,0) GROSSWAGES, ROUND(A.PF_GROSS,0) PF_GROSS, '|| CHR(10)  
                            || '              ( '|| CHR(10) 
                            || '                    CASE WHEN ROUND(A.PF_GROSS,0) >=15000 THEN 15000 ELSE ROUND(A.PF_GROSS,0) END '|| CHR(10) 
                            || '              ) PF_GROSS1, '|| CHR(10) 
                            || '              ( '|| CHR(10) 
                            || '                    CASE WHEN ROUND(A.PF_GROSS,0) >=15000 THEN (ROUND(A.PF_GROSS,0)-15000) ELSE 0 END '|| CHR(10) 
                            || '              ) PF_TMP, '|| CHR(10) 
                            || '              ROUND(A.PF_E,0),0 PF_E1, 0 PF1, 0 PF2,NULL,NULL,NULL '|| CHR(10) 
                            || '              FROM  GPSPAYSHEETDETAILS A, GPSEMPLOYEEMAST B, COMPANYMAST C, DIVISIONMASTER D '|| CHR(10)
                            || '              WHERE A.COMPANYCODE=B.COMPANYCODE '|| CHR(10)
                            || '              AND A.DIVISIONCODE=B.DIVISIONCODE '|| CHR(10)
                            || '              AND A.WORKERSERIAL=B.WORKERSERIAL '|| CHR(10)
                            || '              AND A.COMPANYCODE=C.COMPANYCODE '|| CHR(10)
                            || '              AND A.DIVISIONCODE=D.DIVISIONCODE '|| CHR(10)
                            || '              AND A.DIVISIONCODE=D.DIVISIONCODE '|| CHR(10)
                            || '              AND A.PF_E > 0 '|| CHR(10)
                            || '              AND A.COMPANYCODE = ''' || P_COMPANYCODE || '''  '|| CHR(10) 
                            || '              AND A.DIVISIONCODE = ''' || P_DIVISIONCODE || '''  '|| CHR(10)
                            || '              AND A.PERIODFROM >=TO_DATE(''' || P_FROMDATE ||''',''DD/MM/YYYY'') '|| CHR(10) 
                            || '              AND A.PERIODTO <=TO_DATE(''' || P_TODATE ||''',''DD/MM/YYYY'') '|| CHR(10);
      
            IF P_CLUSTERCODE IS NOT NULL THEN
                LV_SQLSTR := LV_SQLSTR || '   AND      B.CLUSTERCODE  IN ('|| P_CLUSTERCODE ||')' || CHR(10);
            END IF;

            LV_SQLSTR := LV_SQLSTR || '   ORDER BY B.EMPLOYEENAME' || CHR(10);
           --  DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
             EXECUTE IMMEDIATE LV_SQLSTR;    
             
             
             UPDATE GTT_RPT_PFUPLOAD SET PF_E1 = ROUND(PF_GROSS1*0.12,0), PF1= ROUND((PF_GROSS1*0.0833),0);
             UPDATE GTT_RPT_PFUPLOAD SET PF2=ROUND((PF_E-PF1),0);
            
END;
/