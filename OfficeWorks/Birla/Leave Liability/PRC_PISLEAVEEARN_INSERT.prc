CREATE OR REPLACE PROCEDURE BIRLANEW.PRC_PISLEAVEEARN_INSERT 
( 
    P_COMPCODE      Varchar2, 
    P_DIVCODE       Varchar2,
    P_YEARMONTH     Varchar2,
    P_LEAVECODE     Varchar2    DEFAULT NULL, 
    P_UNIT          Varchar2    DEFAULT NULL,
    P_CATEGORY      Varchar2    DEFAULT NULL,
    P_GRADE         Varchar2    DEFAULT NULL,
    P_DEPARTMENT    Varchar2    DEFAULT NULL,
    P_WORKERSERIAL  VARCHAR2    DEFAULT NULL,
    P_ISWAGEPROCESS  VARCHAR2    DEFAULT 'N'
)
as 

-- EXEC PRC_PISLEAVEEARN_INSERT('BJ0056','0001','202101','PL')

 


lv_fn_stdt DATE := TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY');
lv_fn_endt DATE := LAST_DAY(TO_DATE('01/'||SUBSTR(P_YEARMONTH,5,2)||'/'||SUBSTR(P_YEARMONTH,5,2),'DD/MM/YYYY'));

lv_TableName        varchar2(50);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(4000);
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_PISLEAVEEARN_INSERT';
lv_TranType         varchar2(20) := 'ATTENDANCE';

LV_TRANTABLE        VARCHAR2(30) := 'PISPAYTRANSACTION';
 LV_YEARCODE      Varchar2(10);

begin

IF P_ISWAGEPROCESS = 'Y' THEN
    LV_TRANTABLE := 'PISPAYTRANSACTION_SWT';
END IF;


SELECT DISTINCT YEARCODE INTO LV_YEARCODE FROM FINANCIALYEAR
WHERE TO_DATE(P_YEARMONTH,'YYYYMM') BETWEEN STARTDATE AND ENDDATE;


    lv_SqlStr := NULL;        
    lv_SqlStr := lv_SqlStr || ' DELETE FROM PISLEAVETRANSACTION A'||CHR(10);
    lv_SqlStr := lv_SqlStr || ' WHERE A.COMPANYCODE='''||P_COMPCODE||''''||CHR(10);
    lv_SqlStr := lv_SqlStr || ' AND A.DIVISIONCODE='''||P_DIVCODE||''''||CHR(10);
    lv_SqlStr := lv_SqlStr || ' AND A.YEARCODE='''||LV_YEARCODE||''''||CHR(10);
    lv_SqlStr := lv_SqlStr || ' AND A.YEARMONTH='''||P_YEARMONTH||''''||CHR(10);
    lv_SqlStr := lv_SqlStr || ' AND A.WORKERSERIAL IN '||CHR(10);
    lv_SqlStr := lv_SqlStr || ' ('||CHR(10);
    lv_SqlStr := lv_SqlStr || '     SELECT WORKERSERIAL FROM PISEMPLOYEEMASTER'||CHR(10);
    lv_SqlStr := lv_SqlStr || '     WHERE COMPANYCODE='''||P_COMPCODE||''''||CHR(10);
    lv_SqlStr := lv_SqlStr || '     AND DIVISIONCODE='''||P_DIVCODE||''''||CHR(10);
               
    if NVL(P_UNIT,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND UNITCODE = '''||P_UNIT||''' '||CHR(10);
    end if;
    if NVL(P_CATEGORY,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND CATEGORYCODE = '''||P_CATEGORY||''' '||CHR(10);
    end if;
    if NVL(P_GRADE,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND GRADECODE = '''||P_GRADE||''' '||CHR(10);
    end if;
  
    if NVL(P_WORKERSERIAL,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);
    end if;
    
    lv_SqlStr := lv_SqlStr || ' )'||CHR(10);  
    
              
    if NVL(P_CATEGORY,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.CATEGORYCODE = '''||P_CATEGORY||''' '||CHR(10);
    end if;
    if NVL(P_GRADE,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.GRADECODE = '''||P_GRADE||''' '||CHR(10);
    end if;
  
    if NVL(P_WORKERSERIAL,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);
    end if;
   
    if NVL(P_LEAVECODE,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.LEAVECODE = '''||P_LEAVECODE||''' '||CHR(10);
    end if;
 
    lv_SqlStr := lv_SqlStr || ' AND A.TRANSACTIONTYPE = ''ENT'''||CHR(10);


    DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    BEGIN
        execute immediate lv_SqlStr;
        
      EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    lv_SqlStr := NULL;    
    lv_SqlStr := lv_SqlStr || ' INSERT INTO PISLEAVETRANSACTION'||CHR(10);
    lv_SqlStr := lv_SqlStr || ' ('||CHR(10);
    lv_SqlStr := lv_SqlStr || '     COMPANYCODE, DIVISIONCODE, YEARCODE, CALENDARYEAR, YEARMONTH, CATEGORYCODE, GRADECODE, WORKERSERIAL, '||CHR(10);
    lv_SqlStr := lv_SqlStr || '     TOKENNO, LEAVECODE, NOOFDAYS, ADDLESS, TRANSACTIONTYPE, WITHEFFECTFROM, USERNAME, LASTMODIFIED, SYSROWID'||CHR(10);
    lv_SqlStr := lv_SqlStr || ' )'||CHR(10);
    lv_SqlStr := lv_SqlStr || ' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, '''||substr(P_YEARMONTH,1,4)||''' CALENDARYEAR, '''||P_YEARMONTH||''' YEARMONTH, '||CHR(10);
    lv_SqlStr := lv_SqlStr || ' A.CATEGORYCODE, A.GRADECODE, A.WORKERSERIAL, A.TOKENNO, LEAVECODE,ROUND((ENTITLEMENTS/12)*NVL(C.FACTOR,0),2) NOOFDAYS,'||CHR(10);
    lv_SqlStr := lv_SqlStr || ' ''ADD'' ADDLESS,''ENT'' TRANSACTIONTYPE,SYSDATE WITHEFFECTFROM,''SWT'' USERNAME,SYSDATE LASTMODIFIED,FN_GENERATE_SYSROWID SYSROWID '||CHR(10);
    lv_SqlStr := lv_SqlStr || ' FROM PISLEAVEENTITLEMENT A, PISEMPLOYEEMASTER  B,'||CHR(10);
    
lv_SqlStr := lv_SqlStr || ' ('||CHR(10);
lv_SqlStr := lv_SqlStr || '     SELECT TOKENNO, WORKERSERIAL,DECODE(ATTN_CALCF,0,0,ROUND(ATTN_SALD/ATTN_CALCF,2)) FACTOR  FROM '||LV_TRANTABLE||CHR(10);
lv_SqlStr := lv_SqlStr || '     WHERE COMPANYCODE='''||P_COMPCODE||''''||CHR(10);
lv_SqlStr := lv_SqlStr || '     AND DIVISIONCODE='''||P_DIVCODE||''''||CHR(10);
lv_SqlStr := lv_SqlStr || '     AND YEARCODE='''||LV_YEARCODE||''''||CHR(10);
lv_SqlStr := lv_SqlStr || '     AND YEARMONTH='''||P_YEARMONTH||''''||CHR(10);
--lv_SqlStr := lv_SqlStr || '     AND ROUND(ATTN_SALD/ATTN_CALCF,2)  < 1'||CHR(10);
lv_SqlStr := lv_SqlStr || ' ) C'||CHR(10);


    lv_SqlStr := lv_SqlStr || ' WHERE A.COMPANYCODE='''||P_COMPCODE||''''||CHR(10);
    lv_SqlStr := lv_SqlStr || ' AND A.DIVISIONCODE='''||P_DIVCODE||''''||CHR(10);
    lv_SqlStr := lv_SqlStr || ' AND A.YEARCODE='''||LV_YEARCODE||''''||CHR(10);
    lv_SqlStr := lv_SqlStr || ' AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10);
    lv_SqlStr := lv_SqlStr || ' AND A.COMPANYCODE=B.COMPANYCODE'||CHR(10);
    lv_SqlStr := lv_SqlStr || ' AND A.WORKERSERIAL=B.WORKERSERIAL'||CHR(10); 
    lv_SqlStr := lv_SqlStr || ' AND A.WORKERSERIAL=C.WORKERSERIAL'||CHR(10);
               
               
    if NVL(P_UNIT,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.UNITCODE = '''||P_UNIT||''' '||CHR(10);
    end if;
    if NVL(P_CATEGORY,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.CATEGORYCODE = '''||P_CATEGORY||''' '||CHR(10);
    end if;
    if NVL(P_GRADE,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.GRADECODE = '''||P_GRADE||''' '||CHR(10);
    end if;
  
    if NVL(P_WORKERSERIAL,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);
    end if;
    
    
    if NVL(P_LEAVECODE,'XXXXX') <> 'XXXXX' THEN
        lv_SqlStr := lv_SqlStr ||'   AND A.LEAVECODE = '''||P_LEAVECODE||''' '||CHR(10);
    end if;


   
    lv_SqlStr := lv_SqlStr||'     ORDER BY A.TOKENNO  '||CHR(10); 
               
               
    DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
    execute immediate lv_SqlStr; COMMIT;                      
exception
when others then
 lv_sqlerrm := sqlerrm ;
 insert into PIS_ERROR_LOG(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
 values( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);
end;
/
