CREATE OR REPLACE PROCEDURE BIRLANEW.PRC_PISSALARY_OTHCOMP_UPDATE ( P_COMPCODE Varchar2, 
                                                  P_DIVCODE Varchar2,
                                                  P_TRANTYPE Varchar2, 
                                                  P_PHASE  number, 
                                                  P_YEARMONTH Varchar2,
                                                  P_EFFECTYEARMONTH Varchar2, 
                                                  P_TABLENAME Varchar2,
                                                  P_PHASE_TABLENAME Varchar2,
                                                  P_UNIT  Varchar2,
                                                  P_CATEGORY    Varchar2  DEFAULT NULL,
                                                  P_GRADE       Varchar2  DEFAULT NULL,
                                                  P_DEPARTMENT  Varchar2  DEFAULT NULL,
                                                  P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
as 
lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY'));
lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PISSALARY_OTHCOMP_UPDATE';
lv_Sql_TblCreate    varchar2(4000) := '';
lv_Component        varchar2(4000) := ''; 
lv_SqlComponent     varchar2(2000) := ''; 

lv_MaxPensionGrossAmt   number(11,2) := 0;
lv_MaxPensionAmt        number(11,2) := 0;
lv_PensionPercentage    number(11,2) := 0;
lv_ESI_C_Percentage     number(11,2) := 0;
lv_updtable             varchar2(30)    := '';

Begin
    ---  update Pension Gross, pension and pf company contribution 
    SELECT MAXIMUMPENSIONGROSS, PENSION_PERCENTAGE, ESI_C_PERCENT 
    INTO lv_MaxPensionGrossAmt, lv_PensionPercentage, lv_ESI_C_Percentage
    FROM PISALLPARAMETER
    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE;
    
    select SUBSTR( ( 'PIS_OTH_COMP'||SYS_CONTEXT('USERENV', 'SESSIONID')) ,1,30) into lv_updtable  from dual ;   
    
    lv_SqlStr := ' CREATE TABLE '||lv_updtable||' AS '||CHR(10)
                ||' SELECT COMPANYCODE, DIVISIONCODE, UNITCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, YEARMONTH, PFAPPLICABLE, EPFAPPLICABLE, PF_GROSS, PEN_GROSS, PF_E, FPF, PF_E- FPF PF_C, ESI_GROSS, ESI_E, ESI_C '||CHR(10)
                ||' FROM (  '||CHR(10)
                ||'         SELECT A.COMPANYCODE, A.DIVISIONCODE, A.UNITCODE, A.CATEGORYCODE, A.GRADECODE,A.WORKERSERIAL,YEARMONTH, NVL(A.PFAPPLICABLE,''N'') PFAPPLICABLE, NVL(A.EPFAPPLICABLE,''N'') EPFAPPLICABLE, NVL(B.PF_GROSS,0) PF_GROSS,  '||CHR(10) 
                ||'         CASE WHEN  NVL(A.EPFAPPLICABLE,''N'') = ''Y'' AND  NVL(A.EPFAPPLICABLE,''N'') =''Y'' THEN   '||CHR(10)
                ||'                        CASE WHEN NVL(B.PF_E,0) > 0 THEN CASE WHEN B.PF_GROSS > '||lv_MaxPensionGrossAmt||' THEN '||lv_MaxPensionGrossAmt||' ELSE PF_GROSS END ELSE 0 END ELSE 0 END PEN_GROSS,  '||CHR(10)
                ||'         NVL(B.PF_E,0) PF_E,  '||CHR(10)               
                ||'         CASE WHEN  NVL(A.PFAPPLICABLE,''N'') = ''Y'' AND  NVL(A.EPFAPPLICABLE,''N'') = ''Y'' THEN  '||CHR(10) 
                ||'                        CASE WHEN NVL(B.PF_E,0) > 0 THEN ROUND(CASE WHEN NVL(B.PF_GROSS,0) > '||lv_MaxPensionGrossAmt||' THEN '||lv_MaxPensionGrossAmt||' ELSE NVL(PF_GROSS,0) END * '||lv_PensionPercentage||'/100,0) ELSE 0 END ELSE 0 END FPF,  '||CHR(10) 
                ||'                         B.PF_C, NVL(B.ESI_GROSS,0) ESI_GROSS, NVL(B.ESI_E,0) ESI_E, CASE WHEN NVL(ESI_E,0) > 0 THEN CEIL(NVL(ESI_GROSS,0)*'||lv_ESI_C_Percentage||'/100) ELSE 0 END ESI_C   '||CHR(10)
                ||'         FROM PISEMPLOYEEMASTER A, '||P_TABLENAME||' B   '||CHR(10)
                ||'         WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10) 
                ||'           AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE  '||CHR(10) 
                ||'           AND A.WORKERSERIAL = B.WORKERSERIAL   '||CHR(10)
                ||'           AND B.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10);
            if NVL(P_UNIT,'AMALESH_SWT') <> 'AMALESH_SWT' THEN
                lv_SqlStr := lv_SqlStr ||'           AND B.UNITCODE = '''||P_UNIT||''' '||CHR(10);
            end if;                
            if NVL(P_CATEGORY,'AMALESH_SWT') <> 'AMALESH_SWT' THEN
                lv_SqlStr := lv_SqlStr ||'           AND B.CATEGORYCODE = '''||P_CATEGORY||''' '||CHR(10);
            end if;
            if NVL(P_GRADE,'AMALESH_SWT') <> 'AMALESH_SWT' THEN
                lv_SqlStr := lv_SqlStr ||'           AND B.GRADECODE = '''||P_GRADE||''' '||CHR(10);
            end if; 
            if NVL(P_WORKERSERIAL,'AMALESH_SWT') <> 'AMALESH_SWT' THEN
                lv_SqlStr := lv_SqlStr ||'           AND B.WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);
            end if;       
    lv_SqlStr := lv_SqlStr ||'      )  '||CHR(10);
                
    insert into PIS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'',lv_SqlStr,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
    COMMIT;
    EXECUTE IMMEDIATE lv_SqlStr;
    COMMIT;
    
    lv_SqlStr := 'UPDATE '||P_TABLENAME||' A SET (PEN_GROSS, FPF, PF_C, ESI_C  ) = ( SELECT PEN_GROSS, FPF, PF_C, ESI_C  FROM '||lv_updtable||' B '||CHR(10) 
            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||' AND A.YEARMONTH = '''||P_YEARMONTH||'''   '||CHR(10)
            ||' AND A.UNITCODE = B.UNITCODE AND A.CATEGORYCODE = B.CATEGORYCODE AND A.GRADECODE = B.GRADECODE '||CHR(10) 
            ||' AND A.WORKERSERIAL = B.WORKERSERIAL )'||CHR(10)
            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
            ||'   AND A.YEARMONTH = '''||P_YEARMONTH||''' '||CHR(10);
    lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE PENSION GROSS, FPF, PF_C, ESI_C';
    INSERT INTO PIS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_SqlStr,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
    COMMIT;
    EXECUTE IMMEDIATE lv_SqlStr;
    --COMMIT;
    lv_SqlStr := 'DROP TABLE '||lv_updtable||'';     
    EXECUTE IMMEDIATE lv_SqlStr;
    COMMIT;
    
    
  --ADDED ON 24/12/2020 FOR RETIREMENT EMPLOYEE FOR THIS MONTH
    lv_SqlStr := NULL;
    lv_SqlStr := lv_SqlStr || 'UPDATE '||P_TABLENAME||' A SET (PEN_GROSS,FPF, PF_C) = ('|| CHR(10);
    lv_SqlStr := lv_SqlStr || '    SELECT NEW_PEN_GR, (NEW_PEN_GR* FPF_PERC) FPF, (PF_E-FPF) PF_C'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '    FROM '|| CHR(10);
    lv_SqlStr := lv_SqlStr || '    ('|| CHR(10);
    lv_SqlStr := lv_SqlStr || '        SELECT A.TOKENNO, A.WORKERSERIAL,ROUND((PF_GROSS/MONTHDAYS)*PENDAYS,2) NEW_PEN_GR, B.PEN_GROSS, ROUND(('||lv_PensionPercentage||'/100),2) FPF_PERC FROM '|| CHR(10);
    lv_SqlStr := lv_SqlStr || '        ('|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            SELECT TOKENNO,WORKERSERIAL, DATEOFBIRTH,DATEOFRETIRE,RETIRE_DATE,MONTH_START_DATE, TO_CHAR(MONTH_END_DATE,''MON-YYYY'') MM ,'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            (RETIRE_DATE-MONTH_START_DATE)+1 PENDAYS, (MONTH_END_DATE-MONTH_START_DATE)+1 MONTHDAYS'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            FROM '|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            ('|| CHR(10);
    lv_SqlStr := lv_SqlStr || '                SELECT TOKENNO,WORKERSERIAL,EMPLOYEENAME, DATEOFBIRTH,DATEOFRETIRE, '|| CHR(10);
    lv_SqlStr := lv_SqlStr || '                ADD_MONTHS(DATEOFBIRTH, 58*12) RETIRE_DATE , TO_DATE('''||P_YEARMONTH||''',''YYYYMM'') MONTH_START_DATE,'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '                LAST_DAY(TO_DATE('''||P_YEARMONTH||''',''YYYYMM'')) MONTH_END_DATE'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '                FROM PISEMPLOYEEMASTER'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            ) '|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            WHERE 1=1'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            AND RETIRE_DATE BETWEEN MONTH_START_DATE AND MONTH_END_DATE'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '        ) A,'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '        ('|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            SELECT TOKENNO, WORKERSERIAL, YEARMONTH, PF_GROSS,PEN_GROSS, PF_E '|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            FROM '||P_TABLENAME|| CHR(10);
    lv_SqlStr := lv_SqlStr || '            WHERE YEARMONTH='''||P_YEARMONTH||''''|| CHR(10);
    lv_SqlStr := lv_SqlStr || '        ) B'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '        WHERE A.WORKERSERIAL=B.WORKERSERIAL'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '    )'|| CHR(10);
    lv_SqlStr := lv_SqlStr || '    WHERE A.WORKERSERIAL=WORKERSERIAL'|| CHR(10);
    lv_SqlStr := lv_SqlStr || ')'|| CHR(10);
    lv_SqlStr := lv_SqlStr || 'WHERE YEARMONTH='''||P_YEARMONTH||''''|| CHR(10);
    lv_SqlStr := lv_SqlStr || 'AND NVL(FPF,0) > 0'|| CHR(10);
    
    
    lv_remarks := NVL(lv_remarks,'XX ') ||' UPDATE PENSION GROSS, FPF, PF_C, ESI_C FOR RETIRE EMPLYEE';
    INSERT INTO PIS_ERROR_LOG ( PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) VALUES (lv_ProcName,'',sysdate,lv_SqlStr,'', lv_fn_stdt, lv_fn_endt, lv_remarks);    
    COMMIT;
    EXECUTE IMMEDIATE lv_SqlStr;
        COMMIT;
  --ENDED ON 24/12/2020  
    
    
    
end;
/
