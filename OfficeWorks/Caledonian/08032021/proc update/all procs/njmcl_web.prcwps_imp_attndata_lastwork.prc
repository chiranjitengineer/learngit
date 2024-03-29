DROP PROCEDURE NJMCL_WEB.PRCWPS_IMP_ATTNDATA_LASTWORK;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_IMP_ATTNDATA_LASTWORK" (P_COMPCODE VARCHAR2, 
                                                          P_DIVCODE VARCHAR2,
                                                          P_DATEOFATTENDANCE VARCHAR2, 
                                                          P_MACHINECODE VARCHAR2,
                                                          P_YEARCODECODE VARCHAR2,
                                                          P_USERNAME VARCHAR2 
                                                        )
IS
LV_CNT                          NUMBER := 0;
lv_DateOfAttendance  date := to_date(P_DATEOFATTENDANCE,'DD/MM/YYYY');
lv_NextDate varchar2(10) := to_char(lv_DateOfAttendance+1,'dd/mm/yyyy');
lv_lastTime varchar2(10) := '';
lv_NextDateTime date;
lv_FirstDateTime date;    
lv_FirstInTime  varchar2(10) :='';     
lv_FNSDT    date;
lv_FNEDT    date;
lv_ddmmyyyy varchar2(30) := replace(P_DATEOFATTENDANCE,'/','');
LV_SQLERRM VARCHAR2(2000):='';
lv_Sql      varchar2(6000) := '';
BEGIN


if to_number(substr(P_DATEOFATTENDANCE,1,2)) >= 16 then
    lv_FNSDT := to_date('16'||substr(P_DATEOFATTENDANCE,3,8),'dd/mm/yyyy');
    lv_FNEDT := LAST_DAY(lv_DateOfAttendance);   
else
    lv_FNSDT := to_date('01'||substr(P_DATEOFATTENDANCE,3,8),'dd/mm/yyyy');
    lv_FNEDT := to_date('15'||substr(P_DATEOFATTENDANCE,3,8),'dd/mm/yyyy');
end if;

select TIMETO1 into lv_lastTime from wpsshiftmast where shiftcode = '3';
select TIMEFROM into lv_FirstInTime from wpsshiftmast where shiftcode = '1';

lv_NextDateTime := TO_DATE(lv_NextDate||' '||lv_lastTime,'DD/MM/YYYY HH24:MI:SS');
lv_FirstDateTime := TO_DATE(P_DATEOFATTENDANCE||' '||lv_FirstInTime ,'DD/MM/YYYY HH24:MI:SS');
--dbms_output.put_line(to_char(lv_NextDateTime,'dd/mm/yyyy HH24:MI:SS'));
    
SELECT COUNT(*)
    INTO LV_CNT
    FROM (  
            SELECT TOKENNO FROM WPSATTENDANCEDEVICERAWDATA
            WHERE TO_DATE(TRIM(ATTENDATETIME),'DD/MM/YYYY HH24:MI:SS') >= lv_FirstDateTime
              AND TO_DATE(TRIM(ATTENDATETIME),'DD/MM/YYYY HH24:MI:SS') <= lv_NextDateTime
         );
--dbms_output.put_line ('No of records : '||LV_CNT);     
         
    IF LV_CNT > 0 THEN
    
        --- START DATA PREPARE BASED ON LAST WORKING DEPT,OCP,MACHINE, LOOM, HELPER, SARDER
        DELETE FROM GBL_WPSLASTWORKING_DEPT;
        
        INSERT INTO GBL_WPSLASTWORKING_DEPT ( 
        WORKERSERIAL, DEPARTMENTCODE, OCCUPATIONCODE, MACHINECODE1, MACHINECODE2, LOOMCODE, HELPERNO, SARDERNO)
        SELECT A.WORKERSERIAL, A.DEPARTMENTCODE, A.OCCUPATIONCODE, A.MACHINECODE1, A.MACHINECODE2, A.LOOMCODE, A.HELPERNO, A.SARDERNO
        FROM WPSATTENDANCEDAYWISE A,
        (
            SELECT WORKERSERIAL, MAX(DATEOFATTENDANCE) DATEOFATTENDANCE
            FROM WPSATTENDANCEDAYWISE 
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE 
            AND DATEOFATTENDANCE < to_date(P_DATEOFATTENDANCE,'DD/MM/YYYY')
            AND ATTENDANCETAG = 'DEVICE'
            AND SPELLTYPE = 'SPELL 1'
            GROUP BY WORKERSERIAL
        ) B
        WHERE A.COMPANYCODE = P_COMPCODE AND A.DIVISIONCODE = P_DIVCODE
        AND A.DATEOFATTENDANCE = B.DATEOFATTENDANCE
        AND A.WORKERSERIAL = B.WORKERSERIAL
        AND A.ATTENDANCETAG = 'DEVICE'
        AND A.SPELLTYPE = 'SPELL 1';    
        --- END DATA PREPARE BASED ON LAST WORKING DEPT,OCP,MACHINE, LOOM, HELPER, SARDER
           
        UPDATE WPSATTENDANCEDEVICERAWDATA SET DATEOFATTENDANCE= SUBSTR(ATTENDATETIME,1,10), TIMEOFATTENDANCE =  SUBSTR(ATTENDATETIME,12)
        WHERE DATEOFATTENDANCE IS NULL
          AND TO_DATE(TRIM(ATTENDATETIME),'DD/MM/YYYY HH24:MI:SS') >= lv_FirstDateTime; 
        
        ----- FOLLOWING UPDATE STATEMENT WRIITEN DUE TO SOME JUNK CHARETER FOUND IN CSV FILE FORMAT INPORTING 
        UPDATE  WPSATTENDANCEDEVICERAWDATA SET TOKENNO = REPLACE(REPLACE(REPLACE(TOKENNO,CHR(239),''),CHR(187),''),CHR(191),'')
        WHERE TOKENNO LIKE CHR(239)||'%' OR TOKENNO LIKE CHR(187)||'%' OR TOKENNO LIKE CHR(191)||'%'; 

        
        DELETE FROM WPSATTENDANCEDAYWISE WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
        AND YEARCODE = P_YEARCODECODE
        AND DATEOFATTENDANCE = TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY');
        
 -- start TEMPORARY TABLE CREATE FOR 1st SPELL THEN CHECK THE WORKER PROESENT IN 2nd SPELL OR NOT
        DELETE FROM GBL_WPS_PRESENT_SPELL1;
        
        lv_Sql := ' INSERT INTO GBL_WPS_PRESENT_SPELL1  '||CHR(10) 
                ||' (DATEOFATTENDANCE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, OCCUPATIONCODE, GROUPCODE, UNITCODE, SHIFTCODE) '||CHR(10)
                ||' SELECT DISTINCT TO_DATE('''||P_DATEOFATTENDANCE||''',''DD/MM/YYYY'') DATEOFATTENDANCE, '||chr(10)
                ||' A.WORKERSERIAL, A.TOKENNO, A.WORKERCATEGORYCODE, '||chr(10) 
                ||' NVL(A.DEPARTMENTCODE,''NA'') DEPARTMENTCODE, '||chr(10) 
                ||' NVL(A.OCCUPATIONCODE,''01'') OCCUPATIONCODE, A.GROUPCODE, A.UNITCODE, '||chr(10)
                ||' (SELECT SHIFTCODE FROM WPSSHIFTMAST '||chr(10)     
                ||'     WHERE ((TIMEFROM <= TIMEOFATTENDANCE AND TIMETO >= TIMEOFATTENDANCE) OR (TIMEFROM1 <= TIMEOFATTENDANCE AND TIMETO1 >= TIMEOFATTENDANCE))) SHIFTCODE '||chr(10)
                ||' FROM WPSWORKERMAST A,  '||chr(10)  
                ||' ( '||chr(10) 
                ||'     SELECT TOKENNO, DATEOFATTENDANCE, MIN(TIMEOFATTENDANCE) TIMEOFATTENDANCE '||chr(10) 
                ||'     FROM WPSATTENDANCEDEVICERAWDATA A, WPSSHIFTMAST B '||chr(10)  
                ||'     WHERE A.DATEOFATTENDANCE = '''||P_DATEOFATTENDANCE||''' '||chr(10)
                ||'     AND A.TIMEOFATTENDANCE <= GRACETIMETO '||chr(10)      -- TIMETO
                ||'     AND TIMEOFATTENDANCE >= GRACETIMETO1 '||chr(10)       -- TIMETO1  
                ||'     AND B.SHIFTCODE = ''3'' '||chr(10)
                ||'     GROUP BY A.TOKENNO, A.DATEOFATTENDANCE '||chr(10)
                ||'     UNION ALL   '||chr(10)
                ||'     SELECT A.TOKENNO, '''||P_DATEOFATTENDANCE||''' DATEOFATTENDANCE, MIN(TIMEOFATTENDANCE) TIMEOFATTENDANCE '||chr(10) 
                ||'     FROM WPSATTENDANCEDEVICERAWDATA A, WPSSHIFTMAST B '||chr(10) 
                ||'     WHERE A.DATEOFATTENDANCE = '''||lv_NextDate||''' '||chr(10)
                ||'     AND B.SHIFTCODE = ''3'' '||chr(10)
                ||'     AND TIMEOFATTENDANCE <= GRACETIMETO1 '||chr(10)         -- TIMETO1 
                ||'     GROUP BY A.TOKENNO, DATEOFATTENDANCE '||chr(10)              
                ||' ) C '||chr(10)
                ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||''' '||chr(10)
                ||' AND A.TOKENNO = C.TOKENNO '||chr(10); 
            
        insert into WPS_ERROR_LOG (PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE,REMARKS ) 
        values( 'PRCWPS_IMP_ATTNDATA_ONMASTER',LV_SQLERRM,SYSDATE,lv_Sql,P_DATEOFATTENDANCE,TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY'),'ATTENDANCE DEVICE DATA TRANSFER');
        EXECUTE IMMEDIATE lv_Sql;
        COMMIT;        
        
        INSERT INTO WPSATTENDANCEDAYWISE ( COMPANYCODE,DIVISIONCODE,YEARCODE, DATEOFATTENDANCE, SHIFTCODE, PARENTSHIFTCODE, 
        WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, OCCUPATIONCODE, WORKERTYPECODE,   
        ATTENDANCEHOURS,SPELLHOURS,DEDUCTIONHOURS,
        MACHINECODE1, MACHINECODE2, LOOMCODE, HELPERNO, SARDERNO,
        SPELLTYPE, SERIALNO, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, 
        SYSROWID,USERNAME,MODULE, ATTENDANCETAG, BOOKNO, UNITCODE )
        SELECT P_COMPCODE COMPANYCODE, P_DIVCODE DIVISIONCODE, P_YEARCODECODE YEARCODE, DATEOFATTENDANCE, SHIFTCODE, A.GROUPCODE,
        A.WORKERSERIAL, A.TOKENNO, A.WORKERCATEGORYCODE, A.DEPARTMENTCODE, A.OCCUPATIONCODE, B.WORKERTYPECODE,
        DECODE(A.SHIFTCODE,'1',5,DECODE(A.SHIFTCODE,'2',3,8)) ATTENDANCEHOURS, DECODE(A.SHIFTCODE,'1',5,DECODE(A.SHIFTCODE,'2',3,8)) SPELLHOURS, 0 DEDUCTIONHOURS,
        A.MACHINECODE1, A.MACHINECODE2, A.LOOMCODE, A.HELPERNO, A.SARDERNO,
        'SPELL 1' SPELLTYPE, 1 SERIALNO, lv_FNSDT FORTNIGHTSTARTDATE, lv_FNEDT FORTNIGHTENDDATE,
        1 SYSROWID, 'SWT' USERNAME,'WPS' MODULE, 'DEVICE' ATTENDANCETAG, 'ATTN/'||lv_ddmmyyyy||'/'||A.WORKERSERIAL||'/'||A.SHIFTCODE  AS BOOKNO, A.UNITCODE
        FROM WPSOCCUPATIONMAST B,  
        (
            SELECT DISTINCT TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY') DATEOFATTENDANCE,
            A.WORKERSERIAL, A.TOKENNO, A.WORKERCATEGORYCODE, 
            NVL(B.DEPARTMENTCODE,NVL(A.DEPARTMENTCODE,'NA')) DEPARTMENTCODE, 
            NVL(B.OCCUPATIONCODE,NVL(A.OCCUPATIONCODE,'01')) OCCUPATIONCODE, A.GROUPCODE, A.UNITCODE,
            NVL(B.MACHINECODE1,'') MACHINECODE1, NVL(B.MACHINECODE2,'') MACHINECODE2,
            NVL(B.LOOMCODE,'') LOOMCODE, NVL(B.HELPERNO,'') HELPERNO, NVL(B.SARDERNO,'') SARDERNO,
            (SELECT SHIFTCODE FROM WPSSHIFTMAST 
                         WHERE ((TIMEFROM <= TIMEOFATTENDANCE AND TIMETO >= TIMEOFATTENDANCE) OR (TIMEFROM1 <= TIMEOFATTENDANCE AND TIMETO1 >= TIMEOFATTENDANCE))) SHIFTCODE
            FROM WPSWORKERMAST A,  GBL_WPSLASTWORKING_DEPT B, --GBL_WPS_PRESENT_SPELL1 C
            ( 
              SELECT TOKENNO, DATEOFATTENDANCE, MIN(TIMEOFATTENDANCE) TIMEOFATTENDANCE 
              FROM WPSATTENDANCEDEVICERAWDATA A, WPSSHIFTMAST B  
              WHERE A.DATEOFATTENDANCE = P_DATEOFATTENDANCE
                AND A.TIMEOFATTENDANCE <= TIMETO
                AND TIMEOFATTENDANCE >= TIMETO1
                AND B.SHIFTCODE = '3'
              GROUP BY A.TOKENNO, A.DATEOFATTENDANCE
              UNION ALL
              SELECT A.TOKENNO, P_DATEOFATTENDANCE DATEOFATTENDANCE, MIN(TIMEOFATTENDANCE) TIMEOFATTENDANCE 
              FROM WPSATTENDANCEDEVICERAWDATA A, WPSSHIFTMAST B 
              WHERE A.DATEOFATTENDANCE = lv_NextDate
                AND B.SHIFTCODE = '3'
                AND TIMEOFATTENDANCE <= TIMETO1
              GROUP BY A.TOKENNO, DATEOFATTENDANCE              
            ) C 
            WHERE A.COMPANYCODE = P_COMPCODE AND A.DIVISIONCODE = P_DIVCODE
            AND A.TOKENNO = C.TOKENNO 
            AND A.WORKERSERIAL = B.WORKERSERIAL (+)
        ) A
        WHERE A.DEPARTMENTCODE = B.DEPARTMENTCODE AND A.OCCUPATIONCODE = B.OCCUPATIONCODE     
        UNION ALL       --- DATA INSERT FOR SPELL 2 
        SELECT P_COMPCODE COMPANYCODE, P_DIVCODE DIVISIONCODE, P_YEARCODECODE YEARCODE, DATEOFATTENDANCE, SHIFTCODE, A.GROUPCODE,
        A.WORKERSERIAL, A.TOKENNO, A.WORKERCATEGORYCODE, A.DEPARTMENTCODE, A.OCCUPATIONCODE, B.WORKERTYPECODE,
        DECODE(A.SHIFTCODE,'1',3,DECODE(A.SHIFTCODE,'2',5,0)) ATTENDANCEHOURS, DECODE(A.SHIFTCODE,'1',3,DECODE(A.SHIFTCODE,'2',5,0)) SPELLHOURS, 0 DEDUCTIONHOURS,
        A.MACHINECODE1, A.MACHINECODE2, A.LOOMCODE, A.HELPERNO, A.SARDERNO,
        'SPELL 2' SPELLTYPE, 1 SERIALNO, lv_FNSDT FORTNIGHTSTARTDATE, lv_FNEDT FORTNIGHTENDDATE,
        1 SYSROWID, 'SWT' USERNAME,'WPS' MODULE, 'DEVICE' ATTENDANCETAG, 'ATTN/'||lv_ddmmyyyy||'/'||A.WORKERSERIAL||'/'||A.SHIFTCODE  AS BOOKNO, A.UNITCODE
        FROM WPSOCCUPATIONMAST B,  
        (
            SELECT DISTINCT TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY') DATEOFATTENDANCE, A.WORKERSERIAL, A.TOKENNO, A.WORKERCATEGORYCODE, 
             NVL(B.DEPARTMENTCODE,NVL(A.DEPARTMENTCODE,'NA')) DEPARTMENTCODE,
             NVL(B.OCCUPATIONCODE,NVL(A.OCCUPATIONCODE,'01')) OCCUPATIONCODE, A.GROUPCODE, A.UNITCODE,
             NVL(B.MACHINECODE1,'') MACHINECODE1, NVL(B.MACHINECODE2,'') MACHINECODE2,
             NVL(B.LOOMCODE,'') LOOMCODE, NVL(B.HELPERNO,'') HELPERNO, NVL(B.SARDERNO,'') SARDERNO, 
            (SELECT SHIFTCODE FROM WPSSHIFTMAST 
                         WHERE ((TIMEFROM <= TIMEOFATTENDANCE AND TIMETO >= TIMEOFATTENDANCE) OR (TIMEFROM1 <= TIMEOFATTENDANCE AND TIMETO1 >= TIMEOFATTENDANCE))) SHIFTCODE
             --C.SHIFTCODE
            FROM WPSWORKERMAST A,  GBL_WPSLASTWORKING_DEPT B,
            ( 
              SELECT A.TOKENNO, A.DATEOFATTENDANCE, MIN(A.TIMEOFATTENDANCE) TIMEOFATTENDANCE 
              FROM WPSATTENDANCEDEVICERAWDATA A, WPSSHIFTMAST B , GBL_WPS_PRESENT_SPELL1 C      -- ATTN_SPELL1 NEW ADD 
              WHERE A.DATEOFATTENDANCE = P_DATEOFATTENDANCE
                AND A.TOKENNO = C.TOKENNO
                AND A.DATEOFATTENDANCE = TO_CHAR(C.DATEOFATTENDANCE,'DD/MM/YYYY')
                AND B.SHIFTCODE = C.SHIFTCODE              
                AND A.TIMEOFATTENDANCE <= TIMETO
                AND TIMEOFATTENDANCE >= TIMETO1
                AND B.SHIFTCODE <> '3'
              GROUP BY A.TOKENNO, A.DATEOFATTENDANCE
            ) C
            WHERE A.COMPANYCODE = P_COMPCODE AND A.DIVISIONCODE = P_DIVCODE
            AND A.TOKENNO = C.TOKENNO
            AND A.WORKERSERIAL = B.WORKERSERIAL (+) 
        ) A
        WHERE A.DEPARTMENTCODE = B.DEPARTMENTCODE AND A.OCCUPATIONCODE = B.OCCUPATIONCODE
          AND A.SHIFTCODE <> '3'; 
             
          COMMIT;
    
    END IF;
                                 
EXCEPTION
WHEN OTHERS THEN
 --INSERT INTO ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) VALUES( 'ERROR SQL',LV_SQLSTR,LV_SQLSTR,LV_PARVALUES,LV_REMARKS);
 LV_SQLERRM := SQLERRM ;
 INSERT INTO WPS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) VALUES( 'PRCWPS_IMP_ATTNDATA_ONMASTER',LV_SQLERRM,NULL,NULL,TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY'),NULL, 'ATTENDANCE DATA IMPORT');
END;
/


