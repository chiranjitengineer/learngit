DROP PROCEDURE NJMCL_WEB.PROC_WPS_NONENTILE_VB_DELETE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPS_NONENTILE_VB_DELETE ( P_COMPCODE VARCHAR2, P_DIVCODE VARCHAR2, P_YEARCODE VARCHAR2,P_FN_STDT VARCHAR2, P_FN_ENDT VARCHAR2, 
                                                         P_TABLENAME varchar2 DEFAULT 'WPSVBDETAILS', P_PRODUCTIONTYPE VARCHAR2 DEFAULT NULL, 
                                                         P_DEPARTMENT VARCHAR2 DEFAULT NULL, P_SECTION VARCHAR2 DEFAULT NULL, 
                                                         P_OCCUPATION VARCHAR2 DEFAULT NULL)
AS
----- THIS PROCEDURE WRITTEN BY Amalesh Das ON 05.05.2020 ----
----- THIS PROCEDURE USE FOR DELETE THE WORKER'S WHO NOT ENTITLE FRO PRODUCTION BASIC(VBASIC)  
----- Naihati not provide the any logic for entitle vbasic, they only provide tokenno who are not entitle for production basic -----
----- So we maintain separate table <<WPSNOTENTITLEVBASIC>> for token and department wise not etitle list ---- 

lv_Sql      varchar2(20000) := '';
lv_ProcName varchar2(30) := 'PROC_WPS_NONENTILE_VB_DELETE';
lv_ParValue varchar2(200) := 'PERIOD - '||P_FN_STDT||'-'||P_FN_ENDT||', PROD - '||P_PRODUCTIONTYPE;
lv_Remarks  varchar2(200) := '';
lv_FN_STDT  date := to_date(P_FN_STDT,'DD/MM/YYYY');
lv_FN_ENDT  date := to_date(P_FN_ENDT,'DD/MM/YYYY');
lv_SqlErr   varchar2(200) := '';
lv_DeptCode varchar2(10) := '';
lv_DeptSecOcp_Exception varchar2(100) :='';


Begin
     if P_DEPARTMENT is null then
        SELECT DEPARTMENTCODE INTO lv_DeptCode
        FROM WPSPRODUCTIONTYPEMAST
        WHERE COMPANYCODE = P_COMPCODE
          AND DIVISIONCODE = P_DIVCODE
          AND PRODUCTIONTYPECODE = P_PRODUCTIONTYPE;
     ELSE
        lv_DeptCode :=  P_DEPARTMENT;    
     end if;
     
     select departmentcode||sectioncode||OCCUPATIONCODE INTO lv_DeptSecOcp_Exception
     FROM WPSPRODUCTIONTYPEMAST
     WHERE COMPANYCODE = P_COMPCODE
       AND DIVISIONCODE = P_DIVCODE
       AND PRODUCTIONTYPECODE = P_PRODUCTIONTYPE;     
        
    lv_Remarks := 'NON ENTITLE WORKER DATA DELETE FROM WPSVBDETAILS FROM DEPT ' ||P_PRODUCTIONTYPE;
     
    lv_Sql := ' DELETE FROM WPSVBDETAILS '||chr(10)  
            ||' WHERE COMPANYCODE = '''||P_COMPCODE||''' '||chr(10)  
            ||'  AND DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
            ||'  AND FORTNIGHTSTARTDATE = '''||lv_FN_STDT||''' '||chr(10)  
            ||'  AND FORTNIGHTENDDATE = '''||lv_FN_ENDT||''' '||chr(10)  
            ||'  AND DEPARTMENTCODE LIKE '''||'%'||lv_DeptCode||'%'||''' '||CHR(10)
            ||'  AND WORKERSERIAL IN ( '||CHR(10)
            ||'                        SELECT WORKERSERIAL  '||CHR(10) 
            ||'                        FROM WPSNOTENTITLEVBASIC  '||CHR(10)
            ||'                        WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'                          AND DEPARTMENTCODE LIKE '''||'%'||lv_DeptCode||'%'||''' '||CHR(10);
     if lv_DeptCode ='16' then
        lv_Sql := lv_Sql ||'                          AND (DEPTSECOCP_EXCEPTION LIKE '''||'%'||lv_DeptSecOcp_Exception||'%'||''' or DEPTSECOCP_EXCEPTION is null)'||CHR(10);
     end if;       

     lv_Sql := lv_Sql ||'                          AND EFFECTIVEDATE = (   '||CHR(10)
            ||'                                                 SELECT MAX(EFFECTIVEDATE) FROM WPSNOTENTITLEVBASIC  '||CHR(10)
            ||'                                                 WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
            ||'                                                   AND TO_DATE(EFFECTIVEDATE,''DD/MM/YYYY'') <= TO_DATE('''||lv_FN_STDT||''',''DD/MM/YYYY'')  '||CHR(10)
            ||'                                              )   '||CHR(10)
            ||'                      )'||CHR(10);
    
    --DBMS_OUTPUT.PUT_LINE (lv_Sql);        
    
    --return;
    EXECUTE IMMEDIATE lv_Sql;
             
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,'',SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks); 
    COMMIT; 
exception    
    when others then
        lv_SqlErr := sqlerrm;
    INSERT INTO WPS_ERROR_LOG (COMPANYCODE, DIVISIONCODE, PROC_NAME, ORA_ERROR_MESSG, ERROR_DATE, ERROR_QUERY, PAR_VALUES, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS) 
    values ( P_COMPCODE, P_DIVCODE, lv_ProcName,lv_SqlErr,SYSDATE, lv_Sql,lv_ParValue, lv_FN_STDT, lv_FN_ENDT, lv_Remarks);
    commit; 
End;
/


