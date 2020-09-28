CREATE OR REPLACE PROCEDURE JOONK.PROC_RPT_GPSPFREGISTER
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_FROMDATE     VARCHAR2,
    P_TODATE       VARCHAR2,
    P_CATEGORY       VARCHAR2 DEFAULT NULL,
    P_CLUSTER       VARCHAR2 DEFAULT NULL
)
AS 
     
    LV_SQLSTR           VARCHAR2(32000);       
    REPMONTH VARCHAR2(20);
    LV_FPF_PERCENTAGE NUMBER(10,4);
    LV_EPF_PERCENTAGE NUMBER(10,4);
    LV_PF_PERCENTAGE NUMBER(10,4);
--    LV_SQLSTRNEW           VARCHAR2(9000);

BEGIN

        SELECT (NVL(B.FPF, A.FPF)/100), (NVL(C.EPF, A.EPF)/100), (NVL(B.FPF, A.FPF))+(NVL(C.EPF, A.EPF)) 
        INTO LV_FPF_PERCENTAGE, LV_EPF_PERCENTAGE, LV_PF_PERCENTAGE FROM 
        (
            SELECT 'A' J, 8.33 FPF, 3.67 EPF FROM DUAL
        ) A,
        (
            SELECT 'A' J, PARAMETER_VALUE FPF FROM SYS_PARAMETER
            WHERE PARAMETER_NAME LIKE 'FPF%'
            AND COMPANYCODE=P_COMPANYCODE
            AND DIVISIONCODE=P_DIVISIONCODE
            AND ROWNUM=1
        ) B,
        (
            SELECT 'A' J, PARAMETER_VALUE EPF FROM SYS_PARAMETER
            WHERE PARAMETER_NAME LIKE 'EPF%'
            AND COMPANYCODE=P_COMPANYCODE
            AND DIVISIONCODE=P_DIVISIONCODE
            AND ROWNUM=1
        ) C
        WHERE A.J = B.J(+) AND A.J=C.J(+);
        
        -- EXEC PROC_RPT_GPSPFREGISTER('JT0069','0002',''01/07/2019,''31/07/2019)
        DELETE FROM GTT_GPSPFREGISTER; 
        
        LV_SQLSTR :=     '  INSERT INTO GTT_GPSPFREGISTER'|| CHR(10)   
        ||   '          SELECT COMPANYNAME, DIVISIONNAME, CATEGORYCODE, CATEGORYDESC,  GROSSWAGES, EPF, PF_GROSS1, PF_TMP, PF_E, '|| CHR(10)  
                    ||   '              EPF_C, FPF_C, EPF_E, FPF_E,PF_ADM, DLI, DLI_ADM, (EPF_C+FPF_C+EPF_E+FPF_E+DLI+DLI_ADM) TOTAL,  PF_GROSS1 TOTAL_EARN,  '|| CHR(10)  
                    ||   '              '''||P_FROMDATE||''' DATEFROM,'''||P_TODATE||''' DATETO,NULL,NULL,NULL,0,0,0'|| CHR(10)  
                    ||   '              FROM ('|| CHR(10)  
                    ||   '          SELECT C.COMPANYNAME, D.DIVISIONNAME, A.CATEGORYCODE, B.CATEGORYDESC,  GROSSWAGES, PF_GROSS EPF, PF_GROSS1, PF_TMP, PF_E,PF_E EPF_C, 0 FPF_C, '|| CHR(10)  
--                    ||   '              ROUND((PF_E*0.694),0) EPF_E, ROUND(PF_E,0) - ROUND((PF_E*0.694),0)  FPF_E,0 PF_ADM, '|| CHR(10)  
--                    ||   '              ROUND((PF_E*'||LV_PF_PERCENTAGE||'*'||LV_FPF_PERCENTAGE||'),0)  EPF_E, ROUND(PF_E,0) - ROUND((PF_E*'||LV_PF_PERCENTAGE||'*'||LV_FPF_PERCENTAGE||'),0)  FPF_E,0 PF_ADM, '|| CHR(10)  
                    ||   '              CASE WHEN B.CATEGORYTYPE <> ''WORKER'' THEN FPF1 ELSE ROUND(A.FPF,0) END  FPF_E , ROUND(PF_E,0) - CASE WHEN B.CATEGORYTYPE <> ''WORKER'' THEN FPF1 ELSE ROUND(A.FPF,0) END  EPF_E,0 PF_ADM, '|| CHR(10)  
                    ||   '              ROUND((E.DLIPER*PF_GROSS/100),0) DLI, ROUND((E.DLIPER*PF_GROSS/100),0) DLI_ADM FROM'|| CHR(10)  
                    ||   '               ('|| CHR(10)  
                    ||   '                  SELECT COMPANYCODE, DIVISIONCODE, CATEGORYCODE,  ROUND(SUM(GROSSWAGES),0) GROSSWAGES, ROUND(SUM(PF_GROSS),0) PF_GROSS,'|| CHR(10)  
                    ||   '                   ROUND(SUM(PF_GROSS1),0) PF_GROSS1, SUM(ROUND(PF_GROSS1*0.0833,0)) FPF1,  ROUND(SUM(PF_TMP),0) PF_TMP, ROUND(SUM(PF_E),0) PF_E, ROUND(SUM(FPF),0) FPF'|| CHR(10)  
                    ||   '                  FROM '|| CHR(10)  
                    ||   '                  (    '|| CHR(10)  
                    ||   '                      SELECT A.COMPANYCODE, A.DIVISIONCODE, A.CATEGORYCODE, NVL(A.GROSSWAGES,0) GROSSWAGES, NVL(A.PF_GROSS,0) PF_GROSS, '|| CHR(10)  
                    ||   '                      ( '|| CHR(10)  
                    ||   '                          CASE WHEN NVL(A.PF_GROSS,0) >=15000 THEN 15000 ELSE FLOOR(NVL(A.PF_GROSS,0)) END '|| CHR(10)  
                    ||   '                      ) PF_GROSS1, '|| CHR(10)  
                    ||   '                      ( '|| CHR(10)  
                    ||   '                          CASE WHEN ROUND(A.PF_GROSS,0) >=15000 THEN (ROUND(A.PF_GROSS,0)-15000) ELSE 0 END '|| CHR(10)  
                    ||   '                      ) PF_TMP, '|| CHR(10)  
                    ||   '                      ROUND(A.PF_E,0) PF_E, 0 PF1, 0 PF2, A.FPF'|| CHR(10)  
                    ||   '                      FROM ( '|| CHR(10)  
                    ||   '                          SELECT COMPANYCODE, DIVISIONCODE , WORKERSERIAL, TOKENNO,CATEGORYCODE,  '|| CHR(10)  
                    ||   '                          SUM(GROSSWAGES) GROSSWAGES,SUM(PF_GROSS) PF_GROSS, SUM(PF_E) PF_E, ROUND(SUM(FLOOR(PF_GROSS)*0.0833)) FPF    '|| CHR(10)  
                    ||   '                          FROM GPSPAYSHEETDETAILS'|| CHR(10)  
                    ||   '                          WHERE PERIODTO >=TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'') '|| CHR(10)  
                    ||   '                          AND PERIODTO <=TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'') '|| CHR(10)  
                    ||   '                          AND DIVISIONCODE ='''||P_DIVISIONCODE||''' '|| CHR(10)  
                    ||   '                          AND COMPANYCODE ='''||P_COMPANYCODE||''''|| CHR(10);
                    
                                       
                    IF P_CLUSTER IS NOT NULL THEN
                        LV_SQLSTR := LV_SQLSTR ||   '           AND CLUSTERCODE  IN ('|| P_CLUSTER ||')' || CHR(10);
                    END IF;
                                
                    
                                       
                    IF P_CATEGORY IS NOT NULL THEN
                        LV_SQLSTR := LV_SQLSTR ||   '           AND CATEGORYCODE  IN ('|| P_CATEGORY ||')' || CHR(10);
                    END IF;
                                
                    
                    
                      
                    LV_SQLSTR := LV_SQLSTR ||    '                          AND PF_E>0 '|| CHR(10)  
                    ||   '                          GROUP BY COMPANYCODE, DIVISIONCODE,CATEGORYCODE , WORKERSERIAL, TOKENNO'|| CHR(10)  
                    ||   '                      )  A'|| CHR(10)  
                    ||   '                  ) '|| CHR(10)  
                    ||   '                  GROUP BY COMPANYCODE, DIVISIONCODE, CATEGORYCODE'|| CHR(10)  
                    ||   '              ) A, GPSCATEGORYMAST B, COMPANYMAST C, DIVISIONMASTER D,'|| CHR(10)  
                    ||   '              ('|| CHR(10)  
                    ||   '                  SELECT TO_NUMBER(PARAMETER_VALUE) DLIPER FROM SYS_PARAMETER'|| CHR(10)  
                    ||   '                  WHERE PARAMETER_NAME =''DLIPERCENTAGE'''|| CHR(10)  
                    ||   '                  AND COMPANYCODE='''||P_COMPANYCODE||''''|| CHR(10)  
                    ||   '                  AND DIVISIONCODE LIKE ''%''||'||P_DIVISIONCODE||'||''%'''|| CHR(10)  
                    ||   '              )E'|| CHR(10)  
                    ||   '              WHERE A.COMPANYCODE=B.COMPANYCODE'|| CHR(10)  
                    ||   '              AND A.DIVISIONCODE=B.DIVISIONCODE'|| CHR(10)  
                    ||   '              AND A.CATEGORYCODE=B.CATEGORYCODE'|| CHR(10)  
                    ||   '              AND   A.COMPANYCODE=C.COMPANYCODE'|| CHR(10)  
                    ||   '              AND   A.COMPANYCODE=D.COMPANYCODE'|| CHR(10)  
                    ||   '              AND A.DIVISIONCODE=D.DIVISIONCODE'|| CHR(10)  
                    ||   '       )'|| CHR(10);  
                    
                       
--        IF P_GARDENCODE IS NOT NULL THEN
--            LV_SQLSTR := LV_SQLSTR ||   '           AND A.GARDENCODE  IN ('|| P_GARDENCODE ||')' || CHR(10);
--        END IF;
--                        
--        IF P_PERIODNO IS NOT NULL THEN
--            LV_SQLSTR := LV_SQLSTR || '             AND A.PERIODNO  IN ('|| P_PERIODNO ||')' || CHR(10);
--        END IF;
--                        
--                    LV_SQLSTR := LV_SQLSTR ||   '  ORDER BY   A.GARDENCODE, A.PERIODNO' || CHR(10);
                    
  DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
  EXECUTE IMMEDIATE LV_SQLSTR;
     
END;
/