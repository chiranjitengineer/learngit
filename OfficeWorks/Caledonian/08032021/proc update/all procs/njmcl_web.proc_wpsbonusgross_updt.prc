DROP PROCEDURE NJMCL_WEB.PROC_WPSBONUSGROSS_UPDT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSBONUSGROSS_UPDT" (P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2, 
                                                  P_YEARCODE Varchar2,
                                                  P_FNSTDT Varchar2,  --- 01/05/2016 '  
                                                  P_FNENDT Varchar2,  --- 31/05/2016 '
                                                  P_PHASE  number    DEFAULT NULL, 
                                                  P_SOURCE_TABLENAME Varchar2  DEFAULT 'WPSWAGESDETAILS_MV_SWT',
                                                  P_TARGET_TABLENAME VARCHAR2 DEFAULT 'WPSWAGESDETAILS_MV',
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
AS
lv_Sql          varchar2(32767) := '';
lv_fn_stdt      date := to_date(P_FNSTDT,'DD/MM/YYYY');
lv_fn_endt      date := to_date(P_FNENDT,'DD/MM/YYYY');
lv_ProcName   varchar2(30) := 'PROC_WPSBONUSGROSS_UPDT';
lv_remarks   varchar2(100) := '';
BEGIN

             lv_remarks := 'UPDATE BONUS GROSS FROM PF GROSS ';

              lv_Sql := '  UPDATE '||P_TARGET_TABLENAME||' TT1 SET GR_FOR_BONUS = '||chr(10)
              ||'  (SELECT PF_GROSS  FROM  '||chr(10)
              ||'  (  '||chr(10)
              ||'      SELECT T1.COMPANYCODE, T1.DIVISIONCODE, T1.YEARCODE, T1.WORKERSERIAL, '||chr(10) 
              ||'      CASE WHEN T1.PF_GROSS > (P.MAXBONUSGROSS_MONTHLY*12) THEN (P.MAXBONUSGROSS_MONTHLY*12) ELSE  PF_GROSS END PF_GROSS  FROM '||chr(10)
              ||'      (  '||chr(10)
              ||'          SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, WORKERSERIAL, SUM(PF_GROSS) PF_GROSS FROM '||chr(10)
              ||'          ( '||chr(10)
              ||'          SELECT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, A.WORKERSERIAL, NVL(A.PF_GROSS,0) PF_GROSS '||chr(10)
              ||'          FROM WPSWAGESDETAILS_MV A , WPSWORKERCATEGORYMAST B '||chr(10)
              ||'          WHERE A.COMPANYCODE = B.COMPANYCODE '||chr(10)
              ||'          AND A.DIVISIONCODE = B.DIVISIONCODE '||chr(10)
              ||'          AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE '||chr(10)
              ||'          AND B.BONUSAPPLICABLE = ''Y'' '||chr(10)
              ||'          AND A.COMPANYCODE = '''||P_COMPCODE||''' '||chr(10)
              ||'          AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
              ||'          AND A.FORTNIGHTSTARTDATE < '''||lv_fn_stdt||''' '||chr(10)
              ||'          AND A.YEARCODE = '''||P_YEARCODE||''' '||chr(10)
              ||'          UNION ALL '||chr(10)
              ||'          SELECT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, A.WORKERSERIAL, NVL(A.PF_GROSS,0) PF_GROSS '||chr(10)
              ||'          FROM '||P_SOURCE_TABLENAME||' A, WPSWORKERCATEGORYMAST B '||chr(10)
              ||'          WHERE A.COMPANYCODE = B.COMPANYCODE '||chr(10)
              ||'          AND A.DIVISIONCODE = B.DIVISIONCODE '||chr(10)
              ||'          AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE '||chr(10)
              ||'          AND B.BONUSAPPLICABLE = ''Y'' '||chr(10)
              ||'          AND A.COMPANYCODE = '''||P_COMPCODE||''' '||chr(10)
              ||'          AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
              ||'          AND A.FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' '||chr(10)
              ||'          AND A.YEARCODE = '''||P_YEARCODE||''' '||chr(10)
              ||'          ) '||chr(10)
              ||'          GROUP BY COMPANYCODE, DIVISIONCODE, YEARCODE, WORKERSERIAL '||chr(10)
              ||'      ) T1, BONUSPARAMETER P '||chr(10)
              ||'      WHERE 1 =1 '||chr(10)
              ||'      AND T1.COMPANYCODE = P.COMPANYCODE '||chr(10)
              ||'      AND T1.DIVISIONCODE = P.DIVISIONCODE '||chr(10)
              ||'      AND T1.YEARCODE = P.YEARCODE '||chr(10)
              ||'  ) TT2 '||chr(10)
              ||'  WHERE TT1.COMPANYCODE = TT2.COMPANYCODE '||chr(10)
              ||'  AND TT1.DIVISIONCODE = TT2.DIVISIONCODE '||chr(10)
              ||'  AND TT1.YEARCODE = TT2.YEARCODE '||chr(10)
              ||'  AND TT1.WORKERSERIAL = TT2.WORKERSERIAL '||chr(10)
              ||'  ) '||chr(10)
              ||'  WHERE TT1.FORTNIGHTSTARTDATE = '''||lv_fn_stdt||''' '||chr(10)
              ||'  AND TT1.FORTNIGHTENDDATE = '''||lv_fn_endt||''' '||chr(10);

            INSERT INTO WPS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_sql,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
            COMMIT;
           -- DBMS_OUTPUT.PUT_LINE(lv_Sql);
            EXECUTE IMMEDIATE lv_sql;
            COMMIT;

END;
/


