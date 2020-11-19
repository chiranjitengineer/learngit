CREATE OR REPLACE PROCEDURE JOONK.PROC_RPT_PISPFUPLOAD
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_YEARMONTH VARCHAR2,
    P_UNITCODE VARCHAR2 DEFAULT NULL,
    P_CATEGORYCODE VARCHAR2 DEFAULT NULL,
    P_GRADECODE VARCHAR2 DEFAULT NULL,
    P_WORKERSERIAL VARCHAR2 DEFAULT NULL,
    P_REPORTOPTION VARCHAR2 DEFAULT 'SALARY'
)
AS 
    LV_SQLSTR VARCHAR2(15000);
   
    P_FROMDATE VARCHAR2(20);
    P_TODATE VARCHAR2(20);
    REPMONTH VARCHAR2(20);
    LV_MAIN_TABLE VARCHAR2(30);
    
BEGIN

--EXEC PROC_RPT_PISPFUPLOAD('JT0069','0001','201907','','','','')
    DELETE FROM GTT_RPT_PISPFUPLOAD;   
    
      
    IF UPPER(P_REPORTOPTION) = 'SALARY' THEN
        LV_MAIN_TABLE:=  'PISPAYTRANSACTION';
    ELSE
        LV_MAIN_TABLE:=  'PISARREARTRANSACTION';
    END IF;
    
    
                
                SELECT TO_CHAR(TO_DATE(''||P_YEARMONTH||'','YYYYMM'),'DD/MM/YYYY') INTO  P_FROMDATE FROM DUAL;
                        
                SELECT TRIM(TO_CHAR(TO_DATE(''|| P_FROMDATE ||'','DD/MM/YYYY'),'MONTH')) ||'-'||TO_CHAR(TO_DATE(''|| P_FROMDATE ||'','DD/MM/YYYY'),'YYYY')  INTO REPMONTH FROM DUAL;
                        
                --FIRST DATE OF THE MONTH CURRENT YEAR
                SELECT TO_CHAR(LAST_DAY(ADD_MONTHS(TO_DATE(''|| P_FROMDATE ||'','DD/MM/YYYY'),-1)), 'DD/MM/YYYY') INTO P_TODATE FROM DUAL;

                SELECT TO_CHAR(LAST_DAY(TO_DATE(''|| P_FROMDATE ||'','DD/MM/YYYY')), 'DD/MM/YYYY') INTO P_TODATE FROM DUAL;
                     
             LV_SQLSTR :=      '    INSERT INTO GTT_RPT_PISPFUPLOAD '|| CHR(10) 
                            || '              SELECT C.COMPANYNAME, D.DIVISIONNAME, '''||REPMONTH||''',B.UANNO, B.EMPLOYEENAME || '' '',ROUND(A.GROSSWAGES,0) GROSSWAGES,  ROUND(A.PF_GROSS,0) PF_GROSS, '|| CHR(10)  
                            || '              ( '|| CHR(10) 
                            || '                    CASE WHEN ROUND(A.PF_GROSS,0) >=15000 THEN 15000 ELSE ROUND(A.PF_GROSS,0) END '|| CHR(10) 
                            || '              ) PF_GROSS1, '|| CHR(10) 
                            || '              ( '|| CHR(10) 
                            || '                    CASE WHEN ROUND(A.PF_GROSS,0) >=15000 THEN (ROUND(A.PF_GROSS,0)-15000) ELSE 0 END '|| CHR(10) 
                            || '              ) PF_TMP, '|| CHR(10) 
                            || '              ROUND(A.PF_E,0),PEN_GROSS PF_E1, FPF PF1, PF_C PF2,NULL,NULL,PF_C '|| CHR(10) 
                            || '             FROM (  '|| CHR(10) 
                            || '                SELECT COMPANYCODE, DIVISIONCODE , WORKERSERIAL, TOKENNO,SUM(GROSSEARN) GROSSWAGES,SUM (PEN_GROSS) PEN_GROSS, '|| CHR(10) 
                            || '                SUM(PF_GROSS) PF_GROSS, (SUM(NVL(PF_E,0)) + SUM(NVL(VPF,0))) PF_E , SUM(NVL(PF_C,0)) PF_C , SUM(NVL(FPF,0)) FPF '|| CHR(10) 
                            || '                FROM '|| LV_MAIN_TABLE ||' WHERE YEARMONTH >=''' || P_YEARMONTH ||'''  '|| CHR(10) 
                            || '                AND DIVISIONCODE =''' || P_DIVISIONCODE || '''  '|| CHR(10) 
                            || '                AND COMPANYCODE =''' || P_COMPANYCODE || '''';
                                IF P_UNITCODE IS NOT NULL THEN
                                    LV_SQLSTR := LV_SQLSTR || '    AND  UNITCODE IN ('|| P_UNITCODE || ')';
                                END IF;
                                IF  P_CATEGORYCODE IS NOT NULL THEN
                                    LV_SQLSTR := LV_SQLSTR || '    AND  CATEGORYCODE IN ('|| P_CATEGORYCODE || ')';
                                END IF;
                                IF P_GRADECODE IS NOT NULL THEN
                                    LV_SQLSTR := LV_SQLSTR || '    AND  GRADECODE IN ('|| P_GRADECODE || ')';
                                END IF;
                                IF P_WORKERSERIAL IS NOT NULL THEN
                                    LV_SQLSTR := LV_SQLSTR || '    AND  WORKERSERIAL IN ('|| P_WORKERSERIAL || ')';
                                END IF;
                
                                         
                                IF(NVL(P_REPORTOPTION,'NA') <> 'SALARY')  THEN
                                    LV_SQLSTR := LV_SQLSTR || 'AND TRANSACTIONTYPE=''ARREAR'' '|| CHR(10);
                                END IF ;      
                                
          
                            LV_SQLSTR := LV_SQLSTR || '    AND PF_E>0                                      
                                                    GROUP BY COMPANYCODE, DIVISIONCODE , WORKERSERIAL, TOKENNO
                                              ) A, PISEMPLOYEEMASTER B, COMPANYMAST C, DIVISIONMASTER D '|| CHR(10)
                            || '              WHERE A.COMPANYCODE=B.COMPANYCODE '|| CHR(10)
                            || '              AND A.DIVISIONCODE=B.DIVISIONCODE '|| CHR(10)
                            || '              AND A.WORKERSERIAL=B.WORKERSERIAL '|| CHR(10)
                            || '              AND A.COMPANYCODE=C.COMPANYCODE '|| CHR(10)
                            || '              AND A.DIVISIONCODE=D.DIVISIONCODE '|| CHR(10)
                            || '              AND A.DIVISIONCODE=D.DIVISIONCODE '|| CHR(10);

             LV_SQLSTR := LV_SQLSTR || '   ORDER BY B.EMPLOYEENAME' || CHR(10);
            
            
             DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
             EXECUTE IMMEDIATE LV_SQLSTR;    
             
--             
--             UPDATE GTT_RPT_PISPFUPLOAD SET PF_E1 = ROUND(PF_GROSS1*0.12,0), PF1= ROUND((PF_GROSS1*0.0833),0);
--             UPDATE GTT_RPT_PISPFUPLOAD SET PF2=ROUND((PF_E-PF1),0);
--            
END;
/
