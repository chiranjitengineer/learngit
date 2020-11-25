CREATE OR REPLACE PROCEDURE PROC_UNREALIZED_COMP_BLNC (
    P_COMPCODE      VARCHAR2,
    P_DIVCODE       VARCHAR2,
    P_STARTDATE     VARCHAR2,
    P_ENDDATE       VARCHAR2,    
    P_COMPONENT     VARCHAR2,
    P_YEARCODE     VARCHAR2,
    P_MODULE        VARCHAR2 DEFAULT 'WPS',
    P_WAGEPROCESS   VARCHAR2 DEFAULT 'NO',
    P_WORKERSERIAL  VARCHAR2 DEFAULT NULL
)
AS 
    LV_SQLSTR      VARCHAR2(20000);
    lv_ProcName    VARCHAR2(30) := 'PROC_UNREALIZED_COMP_BLNC';
    lv_fn_stdt     date := to_date(P_STARTDATE,'dd/mm/yyyy');
    lv_fn_endt     date := to_date(P_ENDDATE,'dd/mm/yyyy');
    lv_Remarks     varchar2(200):='';
    lv_parvalues   varchar2(200) := '';
    lv_sqlerrm     varchar2(500) := '';    
    lv_TableName   varchar2(30) := ''; 
      
    lv_EmpTableName   varchar2(30) := ''; 
    lv_YEARMONTH   varchar2(30) := ''; 
    
BEGIN

    lv_YEARMONTH := TO_CHAR(TO_DATE(P_STARTDATE,'DD/MM/YYYY'),'YYYYMM');

      if P_WAGEPROCESS = 'YES' THEN
     
         if P_MODULE = 'WPS' then
            lv_TableName := 'PISWPSUNREALIZEDDATA';
            lv_EmpTableName := 'WPSWORKERMAST';
         else
            lv_TableName := 'PISWPSUNREALIZEDDATA';
            lv_EmpTableName := 'PISEMPLOYEEMASTER';
         end if;
         
         LV_SQLSTR := NULL;
         LV_SQLSTR := LV_SQLSTR || 'DELETE FROM '||lv_TableName||' '||CHR(10);
         LV_SQLSTR := LV_SQLSTR ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10);
         LV_SQLSTR := LV_SQLSTR ||'   AND TRANTYPE IN (''UNREALIZED'',''REALIZED'') '||CHR(10);
         
         IF NVL(P_COMPONENT, 'ALL') <> 'ALL' THEN
         
            LV_SQLSTR := LV_SQLSTR ||'   AND COMPONENTCODE =''' || P_COMPONENT || ''' '||CHR(10); 
        
         END IF;
         
         IF P_MODULE = 'WPS' THEN         
            LV_SQLSTR := LV_SQLSTR ||'   AND FORTNIGHTSTARTDATE = TO_DATE('''||P_STARTDATE||''',''DD/MM/YYYY'') '||CHR(10);
            LV_SQLSTR := LV_SQLSTR ||'   AND FORTNIGHTENDDATE = TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') '||CHR(10);
         ELSE
            LV_SQLSTR := LV_SQLSTR ||'   AND YEARMONTH = '''||lv_YEARMONTH||''' '||CHR(10);
           
         END IF;
         
         
        
        IF NVL(P_WORKERSERIAL,'NONE') <> 'NONE' THEN
            LV_SQLSTR := LV_SQLSTR ||'    AND WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);
        END IF;
        
        lv_Remarks := 'UNREALIZED COMPONENT DATA DELETE ';
        insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_Remarks);
        COMMIT;
        EXECUTE IMMEDIATE LV_SQLSTR;
        COMMIT;
      end if;                   
     
     DELETE FROM GBL_UNREALIZEDCOMPAMT;
     
--     LV_SQLSTR := 'INSERT INTO GBL_UNREALIZEDCOMPAMT '|| CHR(10)
--            ||' SELECT A.WORKERSERIAL, A.TOKENNO, NULL AS INSURANCEAPPLICABLE, NVL(SHOP_RENT,0) SHOP_EMI, NVL(UNREALIZEDAMOUNT,0) SHOP_UNREALIZED, '|| CHR(10) 
--            ||'        NVL(SHOP_RENT,0) +NVL(UNREALIZEDAMOUNT,0) TOTAL_AMOUNT,'''||P_MODULE||'''   '|| CHR(10)
--            ||'   FROM '||lv_EmpTableName||' A,  '|| CHR(10)
--            ||' (  '|| CHR(10)
--            ||'     SELECT WORKERSERIAL, SUM(COMPONENTAMOUNT) UNREALIZEDAMOUNT '|| CHR(10)
--            ||'     FROM '||lv_TableName|| CHR(10)
--            ||'     WHERE COMPANYCODE = '''||P_COMPCODE||'''  '|| CHR(10)
--            ||'       AND COMPONENTCODE = '''||P_COMPONENT||''' '|| CHR(10)
--            ||'       AND TRANTYPE IN(''REALIZED'',''UNREALIZED'') '|| CHR(10)
--            ||'       AND YEARCODE = '''|| P_YEARCODE || ''''||  CHR(10)
--            ||'       AND FORTNIGHTENDDATE < TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'')  '|| CHR(10)
--            ||'     GROUP BY WORKERSERIAL  '|| CHR(10)
--            ||' ) B  '|| CHR(10)
--            ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '|| CHR(10)
--            ||'   AND A.WORKERSERIAL = B.WORKERSERIAL (+)       '|| CHR(10)
--            ||'   AND (NVL(SHOP_RENT,0)+NVL(UNREALIZEDAMOUNT,0)) > 0  '|| CHR(10);
--            
--            
               
    LV_SQLSTR :=   NULL;
    LV_SQLSTR :=   LV_SQLSTR  ||  'INSERT INTO GBL_UNREALIZEDCOMPAMT '|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  '('|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  '    WORKERSERIAL, TOKENNO, COMPONENT_AMT, COMPONENT_UNREALIZED, '|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  '    TOTAL_COMPONENT_EMI, MODULE'|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  ')'|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  'SELECT A.WORKERSERIAL,B.TOKENNO, SUM(COMPONENTAMOUNT) COMPONENT_AMT, SUM(COMPONENTAMOUNT) UNREALIZEDAMOUNT,'|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  'SUM(COMPONENTAMOUNT) TOTAL_COMPONENT_EMI, '''||P_MODULE||''' MODULE '|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  'FROM PISWPSUNREALIZEDDATA A, PISEMPLOYEEMASTER B'|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  'WHERE A.WORKERSERIAL=B.WORKERSERIAL'|| CHR(10);
    LV_SQLSTR :=   LV_SQLSTR  ||  'AND B.COMPANYCODE='''||P_COMPCODE||''' '|| CHR(10);
--    LV_SQLSTR :=   LV_SQLSTR  ||  'AND B.DIVISIONCODE=''0001'''|| CHR(10);
--    LV_SQLSTR :=   LV_SQLSTR  ||  'AND A.YEARMONTH < ''202011'''|| CHR(10);
        
     IF P_MODULE = 'WPS' THEN         
--        LV_SQLSTR := LV_SQLSTR ||'   AND A.FORTNIGHTSTARTDATE = TO_DATE('''||P_STARTDATE||''',''DD/MM/YYYY'') '||CHR(10);
        LV_SQLSTR := LV_SQLSTR ||'   AND A.FORTNIGHTENDDATE < TO_DATE('''||P_ENDDATE||''',''DD/MM/YYYY'') '||CHR(10);
     ELSE
        LV_SQLSTR := LV_SQLSTR ||'   AND A.YEARMONTH < '''||lv_YEARMONTH||''' '||CHR(10);
           
     END IF;
         
    IF NVL(P_WORKERSERIAL,'NONE') <> 'NONE' THEN
        LV_SQLSTR := LV_SQLSTR ||'    AND A.WORKERSERIAL = '''||P_WORKERSERIAL||''' '||CHR(10);
    END IF;

         
    LV_SQLSTR :=   LV_SQLSTR  ||  'GROUP BY A.WORKERSERIAL,B.TOKENNO '|| CHR(10);
            
    DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
    
    lv_Remarks := 'UNREALIZED COMPONENT GBL TABLE DATA PREPARE';
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
