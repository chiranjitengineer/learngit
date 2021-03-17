CREATE OR REPLACE PROCEDURE FORTWILLIAM_WPS.PROC_CASHOT_BLNC (
    P_COMPCODE      VARCHAR2,
    P_DIVCODE       VARCHAR2,
    P_STARTDATE     VARCHAR2,
    P_ENDDATE       VARCHAR2,    
    P_COMPONENT     VARCHAR2,
    P_YEARCODE      VARCHAR2,
    P_MODULE        VARCHAR2 DEFAULT 'WPS',
    P_WAGEPROCESS   VARCHAR2 DEFAULT 'NO',
    P_WORKERSERIAL  VARCHAR2 DEFAULT NULL
)
AS 
    LV_SQLSTR      VARCHAR2(20000);
    lv_ProcName    VARCHAR2(30) := 'PROC_CASHOT_BLNC';
    lv_fn_stdt     date := to_date(P_STARTDATE,'dd/mm/yyyy');
    lv_fn_endt     date := to_date(P_ENDDATE,'dd/mm/yyyy');
    lv_Remarks     varchar2(200):='';
    lv_parvalues   varchar2(200) := '';
    lv_sqlerrm     varchar2(500) := '';    
    lv_TableName   varchar2(30) := ''; 
    
BEGIN
      if P_WAGEPROCESS = 'YES' THEN
     
         if P_MODULE = 'WPS' then
            lv_TableName := 'WPSUNREALIZEDDATA';
         else
            lv_TableName := 'WPSUNREALIZEDDATA';
         end if;
         
         LV_SQLSTR := 'DELETE FROM '||lv_TableName||' '||CHR(10)
                ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10) 
                ||'   AND TRANTYPE IN (''UNREALIZED'',''REALIZED'') '||CHR(10)
                ||'   AND COMPONENTCODE =''' || P_COMPONENT || ''' '||CHR(10) 
                ||'   AND FORTNIGHTSTARTDATE = TO_DATE('''||P_STARTDATE||''',''DD/MM/YYYY'') '||CHR(10)
                ||'   AND FORTNIGHTENDDATE = TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') '||CHR(10);
        
        IF NVL(P_WORKERSERIAL,'NONE') <> 'NONE' THEN
            LV_SQLSTR := LV_SQLSTR ||'    AND WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);
        END IF;
        
        lv_Remarks := 'CASH OT UNREALIZED DATA DELETE ';
        insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
        COMMIT;
        EXECUTE IMMEDIATE LV_SQLSTR;
        COMMIT;
      end if;                   
     
     DELETE FROM GBL_CASHOTUNREALIZED;
        
LV_SQLSTR := 'INSERT INTO GBL_CASHOTUNREALIZED '|| CHR(10)
        ||' ( '|| CHR(10)
        ||'      WORKERSERIAL, TOKENNO, MODULE, CASHOT_EMI, CASHOT_UNREALIZED '|| CHR(10)
        ||' ) '|| CHR(10)
        ||' SELECT WORKERSERIAL,TOKENNO,MODULE, SUM(COMPONENTAMOUNT) CASHOT_EMI, SUM(COMPONENTAMOUNT) UNREALIZEDAMOUNT '|| CHR(10)
        ||' FROM WPSUNREALIZEDDATA '|| CHR(10)
        ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' '|| CHR(10)
        ||' AND DIVISIONCODE = '''||P_DIVCODE||''' '|| CHR(10)
        ||' AND COMPONENTCODE = '''||P_COMPONENT||''' '|| CHR(10)
        ||' AND TRANTYPE IN(''REALIZED'',''UNREALIZED'') '|| CHR(10)
        ||' AND YEARCODE = '''|| P_YEARCODE || ''' '|| CHR(10)
        ||' AND FORTNIGHTENDDATE < TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') '|| CHR(10)
        ||' GROUP BY WORKERSERIAL,TOKENNO,MODULE '|| CHR(10);
            
    IF NVL(P_WORKERSERIAL,'NONE') <> 'NONE' THEN
        LV_SQLSTR := LV_SQLSTR ||'    AND WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);
    END IF;
        

    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    
    lv_Remarks := 'CASHOT GBL TABLE DATA PREPARE';
    insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
    COMMIT;
    
    EXECUTE IMMEDIATE LV_SQLSTR;
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
    lv_sqlerrm := sqlerrm ;    
    insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);

END;
/
