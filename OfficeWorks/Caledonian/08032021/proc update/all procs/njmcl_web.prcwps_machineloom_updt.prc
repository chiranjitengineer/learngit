DROP PROCEDURE NJMCL_WEB.PRCWPS_MACHINELOOM_UPDT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRCWPS_MACHINELOOM_UPDT (P_COMPCODE VARCHAR2,
                                                       P_DIVCODE VARCHAR2,
                                                       P_DATEOFPRODUCTION VARCHAR2,
                                                       P_DEPARTMENT VARCHAR2 DEFAULT NULL,  
                                                       P_TABLENAME VARCHAR2 DEFAULT 'WPSPRODUCTIONSUMMARY',
                                                       P_USER          VARCHAR2 DEFAULT 'SWT', 
                                                       P_UNITCODE VARCHAR2 DEFAULT NULL)
AS 

lv_SqlStr           VARCHAR2(20000) := '';
lv_YearCode         VARCHAR2(10) := '';
lv_ParValue         varchar2(200):='';
lv_Remarks          varchar2(100):='';
lv_ProcName         varchar2(30) := 'PRCWPS_MACHINELOOM_UPDT';
BEGIN

    SELECT YEARCODE INTO lv_YearCode  FROM WPSWAGEDPERIODDECLARATION
    WHERE TO_DATE(P_DATEOFPRODUCTION,'DD/MM/YYYY') BETWEEN FORTNIGHTSTARTDATE AND FORTNIGHTENDDATE
    AND COMPANYCODE = P_COMPCODE
    AND DIVISIONCODE = P_DIVCODE;
    
    ----------- LOOM CODE UPDATE MACHINE CODE FOR WEAVING PRODUCTION ---------
    
    
    
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE WPSTEMP_MACHINELOOM';
    EXCEPTION
        when others then null;    
    END;
    
    lv_SqlStr := 'CREATE TABLE WPSTEMP_MACHINELOOM AS 
        SELECT DEPARTMENTCODE, SECTIONCODE, MACHINECODE, LOOMCODE  
        FROM WPSMACHINELOOMMAPPING
        WHERE COMPANYCODE='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||'''
          AND DEPARTMENTCODE = ''22''
          AND EFFECTIVEDATE = ( SELECT MAX(EFFECTIVEDATE) FROM WPSMACHINELOOMMAPPING
                                WHERE COMPANYCODE='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||'''
                                  AND DEPARTMENTCODE =''22''
                              )';
                      
    
    lv_Remarks := 'TEMP TABLE CREATION FOR LOOM UPDATE';
    lv_Parvalue := '';
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
        values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',lv_SqlStr,lv_ParValue, TO_DATE(P_DATEOFPRODUCTION,'DD/MM/YYYY'), TO_DATE(P_DATEOFPRODUCTION,'DD/MM/YYYY'), lv_Remarks);

      --  DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    EXECUTE IMMEDIATE lv_SqlStr;  
    COMMIT;    
    
    IF P_TABLENAME='WPSPRODUCTIONSUMMARY' THEN
        lv_ParValue := 'WPSPRODUCTIONSUMMARY'; 
        lv_SqlStr := 'UPDATE WPSPRODUCTIONSUMMARY A SET A.LOOMCODE = ( SELECT B.LOOMCODE FROM WPSTEMP_MACHINELOOM B 
                                                         WHERE A.DEPARTMENTCODE = B.DEPARTMENTCODE AND A.SECTIONCODE = B.SECTIONCODE
                                                           AND A.MACHINECODE= B.MACHINECODE
                                                       )
        WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||'''
          AND STARTDATE = TO_DATE('''||P_DATEOFPRODUCTION||''',''DD/MM/YYYY'')
          AND DEPARTMENTCODE =''22''
          AND A.MACHINECODE IN (SELECT MACHINECODE FROM WPSTEMP_MACHINELOOM)';
    ELSE
        lv_ParValue := 'WPSATTENDANCEDAYWISE';
        lv_SqlStr := 'UPDATE WPSATTENDANCEDAYWISE A SET A.LOOMCODE = ( SELECT B.LOOMCODE FROM WPSTEMP_MACHINELOOM B 
                                                         WHERE A.DEPARTMENTCODE = B.DEPARTMENTCODE AND A.SECTIONCODE = B.SECTIONCODE
                                                           AND A.MACHINECODE1= B.MACHINECODE
                                                       )
        WHERE A.COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||'''
          AND A.YEARCODE ='''||lv_YearCode||'''  
          AND A.DATEOFATTENDANCE = TO_DATE('''||P_DATEOFPRODUCTION||''',''DD/MM/YYYY'')
          AND A.MACHINECODE1 IS NOT NULL 
          AND DEPARTMENTCODE =''22''
          AND A.MACHINECODE1 IN (SELECT MACHINECODE FROM WPSTEMP_MACHINELOOM)';        
    END IF;  
      
    insert into wps_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
        values( P_COMPCODE, P_DIVCODE,lv_ProcName,'',lv_SqlStr,lv_ParValue, TO_DATE(P_DATEOFPRODUCTION,'DD/MM/YYYY'), TO_DATE(P_DATEOFPRODUCTION,'DD/MM/YYYY'), lv_Remarks);

    EXECUTE IMMEDIATE lv_SqlStr;  
    COMMIT;    
    

END;
/


