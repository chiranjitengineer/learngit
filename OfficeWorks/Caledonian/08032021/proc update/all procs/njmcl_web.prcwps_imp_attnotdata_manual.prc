DROP PROCEDURE NJMCL_WEB.PRCWPS_IMP_ATTNOTDATA_MANUAL;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRCWPS_IMP_ATTNOTDATA_MANUAL (P_COMPCODE VARCHAR2,
                                                       P_DIVCODE VARCHAR2,
                                                       P_DATEOFATTENDANCE VARCHAR2,
                                                       P_DEPARTMENT VARCHAR2 DEFAULT NULL,  
                                                       P_VALIDORUPDATE CHAR DEFAULT NULL,
                                                       P_USER          VARCHAR2 DEFAULT 'SWT', 
                                                       P_UNITCODE VARCHAR2 DEFAULT NULL,
                                                       P_DEPCODE VARCHAR2 DEFAULT NULL)


AS 

    LV_SQLERRM          VARCHAR2(2000):='';
    lv_SqlStr           VARCHAR2(4000) := '';
    lv_YearCode         VARCHAR2(10) := '';
    lv_FortnightStartDate         VARCHAR2(10) := '';
    lv_FortnightEndDate         VARCHAR2(10) := '';
BEGIN

    SELECT YEARCODE, TO_CHAR(FORTNIGHTSTARTDATE,'DD/MM/YYYY'),  TO_CHAR(FORTNIGHTENDDATE,'DD/MM/YYYY') 
    INTO lv_YearCode, lv_FortnightStartDate, lv_FortnightEndDate FROM WPSWAGEDPERIODDECLARATION
    WHERE TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY') BETWEEN FORTNIGHTSTARTDATE AND FORTNIGHTENDDATE
    AND COMPANYCODE = P_COMPCODE
    AND DIVISIONCODE = P_DIVCODE;
    
    

    lv_SqlStr := 'DELETE FROM WPSATTENDANCEDAYWISE
    WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' AND DATEOFATTENDANCE = TO_DATE('''||P_DATEOFATTENDANCE||''',''DD/MM/YYYY'')' ;
    IF P_DEPARTMENT IS NOT NULL THEN
        lv_SqlStr := lv_SqlStr || '  AND DEPARTMENTCODE = '''||P_DEPARTMENT||''' ';
    END IF;
    
   -- DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
     EXECUTE IMMEDIATE  lv_SqlStr;
     
    lv_SqlStr := ' DROP TABLE WPSATTENDANCEDEVICERAWDATA_TMP';
    
    BEGIN
        EXECUTE IMMEDIATE lv_SqlStr;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;  
    
    lv_SqlStr := 'CREATE TABLE WPSATTENDANCEDEVICERAWDATA_TMP AS SELECT * FROM WPSATTENDANCEDEVICERAWDATA WHERE ATTN_DT = '''||P_DATEOFATTENDANCE||'''';
    
    EXECUTE IMMEDIATE lv_SqlStr;
    
    lv_SqlStr := 'UPDATE WPSATTENDANCEDEVICERAWDATA_TMP SET TOKENNO = SUBSTR(TOKENNO,2) WHERE TOKENNO LIKE ''BB%'' AND ATTENDANCETAG=''OTHERS''';
    EXECUTE IMMEDIATE lv_SqlStr;
    COMMIT;
    
    ---- OUTSIDE WORKER TOKEN NO UPDATE BASED DEPARMENT WITH INCREMENTAL SERIAL NO. -------------
--    lv_SqlStr := 'UPDATE WPSATTENDANCEDEVICERAWDATA_TMP SET TOKENNO = TOKENNO||''-''||LPAD(DEPTSERIAL,3,0) WHERE TOKENNO LIKE ''B%'' AND ATTENDANCETAG=''OTHERS''';
--    DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
--    EXECUTE IMMEDIATE lv_SqlStr;
    
    FOR C1 IN (
                SELECT REMARKS,TOKENNO, DEPARTMENT, SECTION, OCP_CODE, ACTUAL_SHIFT, DEPTSERIAL,
                TOKENNO||'-'||LPAD(RANK () OVER (PARTITION BY TOKENNO, DEPARTMENT 
                                  ORDER BY TOKENNO, DEPARTMENT, SECTION, OCP_CODE, ACTUAL_SHIFT, DEPTSERIAL),3,0) SERIALNO  
                FROM WPSATTENDANCEDEVICERAWDATA_TMP 
                WHERE 1=1
                AND ATTN_DT = P_DATEOFATTENDANCE
                AND TOKENNO LIKE 'B%' 
              )  
    LOOP
        UPDATE WPSATTENDANCEDEVICERAWDATA_TMP SET TOKENNO=C1.SERIALNO
        WHERE TOKENNO = C1.TOKENNO 
          AND DEPARTMENT = C1.DEPARTMENT
          AND SECTION = C1.SECTION AND OCP_CODE = C1.OCP_CODE
          AND ACTUAL_SHIFT=C1.ACTUAL_SHIFT
          AND DEPTSERIAL = C1.DEPTSERIAL
          AND REMARKS = C1.REMARKS
          AND TOKENNO LIKE 'B%';   
    END LOOP          
    
    COMMIT; 
    
    ------------ UPDATE LOOM CODE FOR WEAVING DEPARTMENT -----------------
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE WPSATTN_LOOMUPDT_TMP';
    EXCEPTION
        WHEN OTHERS THEN NULL;     
    END;
    
    lv_SqlStr := ' CREATE TABLE WPSATTN_LOOMUPDT_TMP AS 
                SELECT A.DEPARTMENTCODE, SECTIONCODE, MACHINECODE, A.LOOMCODE FROM WPSMACHINELOOMMAPPING A,
                (
                    SELECT DEPARTMENTCODE, MAX(EFFECTIVEDATE) EFFECTIVEDATE 
                    FROM WPSMACHINELOOMMAPPING
                    WHERE COMPANYCODE ='''||P_COMPCODE||''' AND DIVISIONCODE ='''||P_DIVCODE||'''
                    GROUP BY DEPARTMENTCODE
                ) B
                WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE ='''||P_DIVCODE||'''
                  AND A.DEPARTMENTCODE = B.DEPARTMENTCODE 
                  AND A.EFFECTIVEDATE = B.EFFECTIVEDATE';
    EXECUTE IMMEDIATE lv_SqlStr;                   
    COMMIT;
    
    lv_SqlStr := ' UPDATE WPSATTENDANCEDEVICERAWDATA_TMP A SET A.LOOMCODE = ( SELECT B.LOOMCODE FROM WPSATTN_LOOMUPDT_TMP B
                                                     WHERE /*A.DEPARTMENTCODE*/ A.DEPARTMENT = B.DEPARTMENTCODE AND /*A.MACHINECODE1*/ A.MACHINE1=B.MACHINECODE )
                WHERE 1=1 /*AND A.COMPANYCODE ='''||P_COMPCODE||''' AND A.DIVISIONCODE ='''||P_DIVCODE||'''*/
                  AND TO_DATE(A.ATTN_DT,''DD/MM/YYYY'') >=TO_DATE('''||P_DATEOFATTENDANCE||''',''DD/MM/YYYY'') 
                  AND TO_DATE(A.ATTN_DT,''DD/MM/YYYY'') <=TO_DATE('''||P_DATEOFATTENDANCE||''',''DD/MM/YYYY'')
                  AND /*A.MACHINECODE1*/ A.MACHINE1 IS NOT NULL
                  AND /*A.DEPARTMENTCODE*/ A.DEPARTMENT||/*A.MACHINECODE1*/ A.MACHINE1 IN ( SELECT DEPARTMENTCODE||MACHINECODE FROM WPSATTN_LOOMUPDT_TMP)';
    
    EXECUTE IMMEDIATE lv_SqlStr;                   
    COMMIT;
    
    lv_SqlStr := 'INSERT INTO WPSATTENDANCEDAYWISE ( COMPANYCODE, DIVISIONCODE, YEARCODE, 
    FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DATEOFATTENDANCE, FEWORKINGDAYS, 
    DEPARTMENTCODE, SECTIONCODE, GROUPCODE, SHIFTCODE, 
    WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, OCCUPATIONCODE, DEPTSERIAL, WORKERTYPECODE, HELPERNO, SARDARNO, RELIVERNO, 
    MACHINECODE1, MACHINECODE2, LOOMCODE, ATTENDANCEHOURS, ATN_DAYS, 
    OVERTIMEHOURS, HOLIDAYHOURS, LAYOFFHOURS, FBKHOURS, STATUTORYHOURS, NIGHTALLOWANCEHOURS, OT_NSHRS, 
    SERIALNO, NPF_ADJ, PF_ADJ, PF_ADJ_DEDN, NPF_ADJ_DEDN, 
    INCENTIVE, REMARKS,LASTMODIFIED,USERNAME,SYSROWID,MODULE, ATTENDANCETAG, ATTN_REWARDS_EXTRAHRS)

    SELECT '''||P_COMPCODE||''' COMPANYCODE, '''||P_DIVCODE||''' DIVISIONCODE, '''||lv_YearCode||''' YEARCODE, 
    TO_DATE('''||lv_FortnightStartDate||''',''DD/MM/YYYY'') FORTNIGHTSTARTDATE, TO_DATE('''||lv_FortnightEndDate||''',''DD/MM/YYYY'') FORTNIGHTENDDATE, TO_DATE(ATTN_DT,''DD/MM/YYYY'') DATEOFATTENDANCE, A.ATTN_DAYS FEWORKINGDAYS,
    A.DEPARTMENT DEPARTMENTCODE, A.SECTION SECTIONCODE,  DECODE (A.PARENT_SHIFT,''B'',''2'',''C'',''3'',''1'') GROUPCODE, DECODE (A.PARENT_SHIFT,''B'',''2'',''C'',''3'',''1'') SHIFTCODE,
    B.WORKERSERIAL, A.TOKENNO, B.WORKERCATEGORYCODE, A.OCP_CODE OCCUPATIONCODE, A.DEPTSERIAL,  NULL WORKERTYPECODE, A.HELPERNO, A.SARDARNO, A.RELIVERNO, 
    A.MACHINE1 MACHINECODE1, A.MACHINE2 MACHINECODE2, A.LOOMCODE, A.ATTN_HRS ATTENDANCEHOURS, A.ATTN_DAYS,
    A.OT_HRS OVERTIMEHOURS, A.HOL_HRS HOLIDAYHOURS, NVL(LAYOFF_HRS,0) LAYOFFHOURS,A.FALLBACK_HRS FBKHOURS, 0  STATUTORYHOURS, A.NS_HRS NIGHTALLOWANCEHOURS, A.OTNS_HRS OT_NSHRS,
    A.REMARKS SERIALNO, ADJ_EARN_NON_PF NPF_ADJ, ADJ_EARN_PF_LNKD PF_ADJ,  ADJ_DED_PF_LNKD PF_ADJ_DEDN, A.ADJ_DED_NON_PF NPF_ADJ_DEDN, 
    A.INCENTIVE, A.REMARKS, SYSDATE LASTMODIFIED, '''||P_USER||''' USERNAME, SYS_GUID() SYSROWID, ''WPS'' MODULE, ''IMPORT FROM TAB'' ATTENDANCETAG, A.ATTN_REWARDS_EXTRAHRS 
    FROM /*WPSATTENDANCEDEVICERAWDATA*/ WPSATTENDANCEDEVICERAWDATA_TMP A, WPSWORKERMAST B
    WHERE A.TOKENNO = B.TOKENNO 
    AND ATTN_DT = '''||P_DATEOFATTENDANCE||'''';
    
    IF P_DEPARTMENT IS NOT NULL THEN
        lv_SqlStr := lv_SqlStr || '  AND A.DEPARTMENT = '''||P_DEPARTMENT||''' ';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    EXECUTE IMMEDIATE  lv_SqlStr;
   
   
   
   BEGIN               
    EXECUTE IMMEDIATE 'DROP TABLE WPSATTERAWDATA_EXCLUDED';        
    EXCEPTION WHEN OTHERS THEN NULL;
   END;
   
   
   lv_SqlStr := '  CREATE TABLE WPSATTERAWDATA_EXCLUDED AS   
                   SELECT * FROM WPSATTENDANCEDEVICERAWDATA
                    WHERE TOKENNO IN (
                        SELECT TOKENNO FROM WPSATTENDANCEDEVICERAWDATA -- 5350
                        WHERE ATTN_DT = '''||P_DATEOFATTENDANCE||'''
                    --    AND TOKENNO IN (''BB00385'',''BB02400'') -- 706       
                        MINUS
                        SELECT TOKENNO FROM WPSATTENDANCEDAYWISE
                        WHERE DATEOFATTENDANCE = TO_DATE('''||P_DATEOFATTENDANCE||''',''DD/MM/YYYY'')
                    )
                    AND ATTN_DT = '''||P_DATEOFATTENDANCE||'''';
   
    --DBMS_OUTPUT.PUT_LINE(lv_SqlStr);
    EXECUTE IMMEDIATE  lv_SqlStr;

END;
/


