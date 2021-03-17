DROP PROCEDURE NJMCL_WEB.PROC_WPS_VB_MCH_HRSRATE_PICK;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPS_VB_MCH_HRSRATE_PICK ( P_COMPCODE VARCHAR2, P_DIVCODE VARCHAR2, P_YEARCODE VARCHAR2,P_FN_STDT VARCHAR2, P_FN_ENDT VARCHAR2, P_1ST_WK_ENDT VARCHAR2 DEFAULT NULL, 
                                                         P_TABLENAME varchar2 DEFAULT 'WPSVBDETAILS', P_PRODUCTIONTYPE VARCHAR2 DEFAULT NULL, 
                                                         P_DEPARTMENT VARCHAR2 DEFAULT NULL, P_SECTION VARCHAR2 DEFAULT NULL, 
                                                         P_OCCUPATION VARCHAR2 DEFAULT NULL, P_WORKERSERIAL VARCHAR2 DEFAULT NULL)
AS
----- THIS PROCEDURE WRITTEN BY PRASUN CHAKRABORTY ON 17.07.2019 ----
----- THIS PROCEDURE USE FOR CALCULATE VARIABLE BASIC BASED ON FORTNIGHTLY INDIVIDUAL MACHINEWISE, QUALITY WISE PRODUCTION 
----- QUALITYRATE TAKE FROM  - WPSQUALITYRATE_ON_REEDSPACE TABLE ----- 

lv_Sql      varchar2(20000) := '';
lv_ProcName varchar2(30) := 'PROC_WPS_VB_MCH_HRSRATE_PICK';
lv_ParValue varchar2(200) := '';
lv_Remarks  varchar2(200) := '';
lv_FN_STDT  date := to_date(P_FN_STDT,'DD/MM/YYYY');
lv_FN_ENDT  date := to_date(P_FN_ENDT,'DD/MM/YYYY');
lv_SqlErr   varchar2(200) := '';
lv_SectionCode   varchar2(10) := '';

Begin


    SELECT SECTIONCODE into lv_SectionCode FROM WPSPRODUCTIONTYPEMAST 
    WHERE COMPANYCODE = P_COMPCODE
    AND DIVISIONCODE = P_DIVCODE
    AND PRODUCTIONTYPECODE = P_PRODUCTIONTYPE ;

     lv_Remarks := 'DELETE FROM WPSLINEHOURLYRATE, PRODUCTION TYPE ' ||  P_PRODUCTIONTYPE;
     
     lv_Sql := ' DELETE FROM WPSLINEHOURLYRATE '||chr(10)  
             ||'WHERE COMPANYCODE = ''' ||P_COMPCODE|| ''' '||chr(10)  
             ||'AND DIVISIONCODE = ''' ||P_DIVCODE|| ''' '||chr(10)  
             ||'AND PRODUCTIONTYPE = ''' ||P_PRODUCTIONTYPE|| ''' '||chr(10)  
             ||'AND FORTNIGHTSTARTDATE = ''' ||lv_FN_STDT|| ''' '||chr(10)  
             ||'AND FORTNIGHTENDDATE = ''' ||lv_FN_ENDT|| ''' '||chr(10)  
             ||'AND TRANSACTIONTYPE = ''PICKS'' '||chr(10)
             ||'AND TRANTYPE = ''VB'' ';  
    
    --EXECUTE IMMEDIATE lv_Sql;
             
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks); 
    COMMIT; 
     
     lv_Remarks := 'INSERT INTO WPSLINEHOURLYRATE, PRODUCTION TYPE ' ||  P_PRODUCTIONTYPE;
     
      lv_Sql := '   INSERT INTO WPSLINEHOURLYRATE    '||chr(10)
            ||'     (    '||chr(10)
            ||'        COMPANYCODE, DIVISIONCODE, PRODUCTIONTYPE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, SHIFTCODE, MACHINECODE1, VBHOURLYRATE, '||chr(10) 
            ||'        TOTALBASIC, LASTMODIFIED, TRANTYPE, USERNAME, SYSROWID, TRANSACTIONTYPE '||chr(10)
            ||'     ) '||chr(10)
            ||'    SELECT P.COMPANYCODE, P.DIVISIONCODE, '''||P_PRODUCTIONTYPE||''' PRODUCTIONTYPE,'''||lv_FN_STDT||''' FORTNIGHTSTARTDATE, '''||lv_FN_ENDT||'''  FORTNIGHTENDDATE,  '||chr(10)
            ||'        P.SHIFTCODE, P.MACHINECODE, ROUND((SUM(NVL(R.TOTALBASIC,0))/(SUM(NVL(A.ATTENDANCEHOURS,0))+SUM(NVL(A.OVERTIMEHOURS,0)))),5) PERHOURRATE  '||chr(10)
            ||'        SUM(NVL(R.TOTALBASIC,0)) VBAMOUNT,  SYSDATE LASTMODIFIED, ''VB'' TRANTYPE, ''SWT'' USERNAME, SYS_GUID() SYSROWID, ''PICKS'' '||chr(10)
            ||'        FROM '||chr(10)
            ||'    FROM WPSPRODUCTIONSUMMARY P, WPSATTENDANCEDAYWISE A, WPSLINEHOURLYRATE R '||chr(10)
            ||'     WHERE P.COMPANYCODE = A.COMPANYCODE '||chr(10)
            ||'        AND P.DIVISIONCODE = A.DIVISIONCODE '||chr(10)
            ||'        AND P.YEARCODE = A.YEARCODE '||chr(10)
            ||'        AND P.LOOMCODE = A.LOOMCODE '||chr(10)
            ||'        AND P.SHIFTCODE = A.SHIFTCODE '||chr(10)
            ||'        AND P.MACHINECODE = R.MACHINECODE1 '||chr(10)
            ||'        AND P.COMPANYCODE = R.COMPANYCODE '||chr(10)
            ||'        AND P.DIVISIONCODE = R.DIVISIONCODE '||chr(10)
            ||'        AND P.PRODUCTIONTYPE = R.PRODUCTIONTYPE '||chr(10)
            ||'        AND P.SHIFTCODE = R.SHIFTCODE '||chr(10)
            ||'        AND P.MACHINECODE = R.MACHINECODE1 '||chr(10)
            ||'        AND A.FORTNIGHTSTARTDATE  = '''||lv_FN_STDT||''' '|| CHR(10)
            ||'        AND A.FORTNIGHTENDDATE = '''||lv_FN_ENDT||''' '|| CHR(10)
            ||'        AND A.DATEOFATTENDANCE BETWEEN '''||lv_FN_STDT||'''  AND '''||lv_FN_ENDT||'''  '||chr(10) 
            ||'        AND P.STARTDATE >= '''||lv_FN_STDT||'''  '||chr(10)
            ||'        AND P.STARTDATE <= '''||lv_FN_STDT||''' '||chr(10)
            ||'        AND P.PRODUCTIONTYPE = '''||P_PRODUCTIONTYPE||'''  '||chr(10)
            ||'        AND P.TRANSACTIONTYPE = ''PICKS'' '||chr(10)
            ||'        AND NVL(P.TOTALPIC,0) > 0 '||chr(10)
            ||'    GROUP BY P.COMPANYCODE, P.DIVISIONCODE, P.YEARCODE, P.SHIFTCODE, P.MACHINECODE  '||chr(10)
            ||'    ORDER BY P.COMPANYCODE, P.DIVISIONCODE, P.YEARCODE, P.MACHINECODE, P.SHIFTCODE  ';
           
    --EXECUTE IMMEDIATE lv_Sql;
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks);
    commit;
    
exception    
    when others then
        lv_SqlErr := sqlerrm;
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_SqlErr,SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks);
    commit; 
End;
/


