DROP PROCEDURE NJMCL_WEB.PRCWPS_IMP_ATTNOTDATA_LASTWORK;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRCWPS_IMP_ATTNOTDATA_LASTWORK(P_COMPCODE VARCHAR2, 
                                                          P_DIVCODE VARCHAR2,
                                                          P_DATEOFATTENDANCE VARCHAR2, 
                                                          P_YEARCODE VARCHAR2,
                                                          P_USERNAME VARCHAR2 
                                                        )
IS
LV_CNT                          NUMBER := 0;
lv_Cnt1                         NUMBER := 0;
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
lv_Sql        varchar2(6000):='';

lv_DayOffConsiderMaster varchar2(1) := 'Y';
lv_Day         varchar2(15):='';

lv_TmFrom_A1    varchar2(10):='';
lv_TmTo_A1      varchar2(10):='';
lv_TmFrom_A2    varchar2(10):='';
lv_TmTo_A2      varchar2(10):='';
lv_TmFrom_B1    varchar2(10):='';
lv_TmTo_B1      varchar2(10):='';
lv_TmFrom_B2    varchar2(10):='';
lv_TmTo_B2      varchar2(10):='';
lv_TmFrom_C1    varchar2(10):='';
lv_TmTo_C1      varchar2(10):='';
lv_TmFrom_C2    varchar2(10):='';
lv_TmTo_C2      varchar2(10):='';

BEGIN


/*INSERT INTO WPSATTENDANCEDEVICERAWDATA
(TOKENNO, ATTENDATETIME, DEVICEID, DATEOFATTENDANCE, TIMEOFATTENDANCE, SHIFT, ATTENHOURS)
SELECT TOKEN, SUBSTR(DT,5,2)||'/'||SUBSTR(DT,3,2)||'/20'||SUBSTR(DT,1,2)||' '||TIMEIN ATTENDATETIME, MACHINEID DEVICEID,
SUBSTR(DT,5,2)||'/'||SUBSTR(DT,3,2)||'/20'||SUBSTR(DT,1,2) DATEOFATTENDANCE, TIMEIN TIMEOFATTENDANCE
FROM GBL_ATTNRAWDATA */


    if to_number(substr(P_DATEOFATTENDANCE,1,2)) >= 16 then
        lv_FNSDT := to_date('16'||substr(P_DATEOFATTENDANCE,3,8),'dd/mm/yyyy');
        lv_FNEDT := LAST_DAY(lv_DateOfAttendance);   
    else
        lv_FNSDT := to_date('01'||substr(P_DATEOFATTENDANCE,3,8),'dd/mm/yyyy');
        lv_FNEDT := to_date('15'||substr(P_DATEOFATTENDANCE,3,8),'dd/mm/yyyy');
    end if;

    lv_Day := TRIM(TO_CHAR(TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY'),'MONTH'));    

    select NVL(DAYOFFCONSIDER_ATTN_IMPORT,'N') INTO lv_DayOffConsiderMaster from WPSWAGESPARAMETER;
    

    select TIMETO1 into lv_lastTime from wpsshiftmast where shiftcode = '3';
    select TIMEFROM into lv_FirstInTime from wpsshiftmast where shiftcode = '1';


    select ATTNFROM, ATTNTO, ATTNFROM1, ATTNTO1 into lv_TmFrom_A1, lv_TmTo_A1, lv_TmFrom_A2, lv_TmTo_A2
    from wpsshiftmast where shiftcode = '1';

    select ATTNFROM, ATTNTO, ATTNFROM1, ATTNTO1 into lv_TmFrom_B1, lv_TmTo_B1, lv_TmFrom_B2, lv_TmTo_B2
    from wpsshiftmast where shiftcode = '2';

    select ATTNFROM, ATTNTO, ATTNFROM1, ATTNTO1 into lv_TmFrom_C1, lv_TmTo_C1, lv_TmFrom_C2, lv_TmTo_C2
    from wpsshiftmast where shiftcode = '3';
     
    lv_NextDateTime := TO_DATE(lv_NextDate||' '||lv_lastTime,'DD/MM/YYYY HH24:MI:SS');
    lv_FirstDateTime := TO_DATE(P_DATEOFATTENDANCE||' '||lv_FirstInTime ,'DD/MM/YYYY HH24:MI:SS');
    --dbms_output.put_line ('LV_DAYOFFCONSIDERMASTER : '||lv_NextDateTime||' '||lv_FirstDateTime);
    lv_Sql := 'SELECT COUNT(*) '||CHR(10)
            ||'  FROM ( '||CHR(10)  
            ||'        SELECT TOKENNO FROM WPSATTENDANCEDEVICERAWDATA '||CHR(10)
            ||'         WHERE TO_DATE(TRIM(ATTENDATETIME),''DD/MM/YYYY HH24:MI:SS'') >= '''||lv_FirstDateTime||''' '||CHR(10)
            ||'           AND TO_DATE(TRIM(ATTENDATETIME),''DD/MM/YYYY HH24:MI:SS'') <= '''||lv_NextDateTime||''' '||CHR(10)
            ||'       ) '||CHR(10);
    --dbms_output.put_line ('Query : '||lv_Sql);     
    EXECUTE IMMEDIATE lv_Sql INTO LV_CNT;
             
        IF LV_CNT > 0 THEN       
             
            --- update shift code based on attendance time -----
             
            lv_Sql := ' UPDATE WPSATTENDANCEDEVICERAWDATA AA '||chr(10)
                    ||' SET SHIFT = ( SELECT CASE WHEN SUBSTR(ATTENDATETIME,12) >= '''||lv_TmFrom_A1||'''  AND SUBSTR(ATTENDATETIME,12) <= '''||lv_TmTo_A1||''' THEN ''A1'' '||chr(10)
                    ||'                           WHEN SUBSTR(ATTENDATETIME,12) >= '''||lv_TmFrom_B1||'''  AND SUBSTR(ATTENDATETIME,12) <= '''||lv_TmTo_B1||''' THEN ''B1'' '||chr(10) 
                    ||'                           WHEN SUBSTR(ATTENDATETIME,12) >= '''||lv_TmFrom_A2||'''  AND SUBSTR(ATTENDATETIME,12) <= '''||lv_TmTo_A2||''' THEN ''A2'' '||chr(10)
                    ||'                           WHEN SUBSTR(ATTENDATETIME,12) >= '''||lv_TmFrom_B2||'''  AND SUBSTR(ATTENDATETIME,12) <= '''||lv_TmTo_B2||''' THEN ''B2'' '||chr(10)
                    ||'                         ELSE ''C1'' '||chr(10)
                    ||'                      END SHIFT FROM WPSATTENDANCEDEVICERAWDATA BB '||chr(10)          
                    ||'               WHERE AA.TOKENNO = BB.TOKENNO AND AA.ROWID = BB.ROWID  '||chr(10)
                    ||'             ), '||chr(10)    
                    ||'     ATTENHOURS = ( SELECT CASE WHEN SUBSTR(ATTENDATETIME,12) >= '''||lv_TmFrom_A1||'''   AND SUBSTR(ATTENDATETIME,12) <= '''||lv_TmTo_A1||''' THEN 5 '||chr(10)
                    ||'                                WHEN SUBSTR(ATTENDATETIME,12) >= '''||lv_TmFrom_B1||'''  AND SUBSTR(ATTENDATETIME,12) <= '''||lv_TmTo_B1||''' THEN 3 '||chr(10)
                    ||'                                WHEN SUBSTR(ATTENDATETIME,12) >= '''||lv_TmFrom_A2||'''  AND SUBSTR(ATTENDATETIME,12) <= '''||lv_TmTo_A2||''' THEN 3 '||chr(10)
                    ||'                                WHEN SUBSTR(ATTENDATETIME,12) >= '''||lv_TmFrom_B2||'''  AND SUBSTR(ATTENDATETIME,12) <= '''||lv_TmTo_B2||''' THEN 5 '||chr(10)
                    ||'                                ELSE 8 '||chr(10)
                    ||'                           END ATTENHOURS '||chr(10)
                    ||'                    FROM WPSATTENDANCEDEVICERAWDATA CC '||chr(10)          
                    ||'                    WHERE AA.TOKENNO = CC.TOKENNO AND AA.ROWID = CC.ROWID '||chr(10)
                    ||'                  ) '||chr(10)
                    ||' ,DATEOFATTENDANCE= SUBSTR(ATTENDATETIME,1,10), TIMEOFATTENDANCE =  SUBSTR(ATTENDATETIME,12) '||CHR(10)
                    ||' WHERE SHIFT IS NULL '||chr(10)
                    ||' AND TO_DATE(TRIM(ATTENDATETIME),''DD/MM/YYYY HH24:MI:SS'') >= '''||lv_FirstDateTime||''' '||chr(10); 
            --DBMS_OUTPUT.PUT_LINE ('Query : '||lv_Sql);
            insert into WPS_ERROR_LOG (PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE,REMARKS ) 
            values( 'PRCWPS_IMP_ATTNOTDATA_LASTWORK',LV_SQLERRM,SYSDATE,lv_Sql,P_DATEOFATTENDANCE,TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY'),'ATTENDANCE DEVICE DATA TRANSFER');
            EXECUTE IMMEDIATE lv_Sql;
            COMMIT;

--            UPDATE WPSATTENDANCEDEVICERAWDATA SET DATEOFATTENDANCE= SUBSTR(ATTENDATETIME,1,10), TIMEOFATTENDANCE =  SUBSTR(ATTENDATETIME,12)
--            WHERE DATEOFATTENDANCE IS NULL
--              AND TO_DATE(TRIM(ATTENDATETIME),'DD/MM/YYYY HH24:MI:SS') >= lv_FirstDateTime;


        DELETE FROM WPSATTENDANCEDAYWISE WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
        AND YEARCODE = P_YEARCODE
        AND DATEOFATTENDANCE = TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY');
            
        ---- LAST WORKING DEPARTMENT AND OCCUPATION ---------
        DELETE FROM GBL_WPSLASTWORKING_DEPT;
        INSERT INTO GBL_WPSLASTWORKING_DEPT ( 
        WORKERSERIAL, DEPARTMENTCODE, OCCUPATIONCODE, LOOMCODE, HELPERNO, SARDERNO, DEPTSERIAL, LINENO, MACHINECODE1, MACHINECODE2)
        SELECT DISTINCT A.WORKERSERIAL, A.DEPARTMENTCODE, A.OCCUPATIONCODE, A.LOOMCODE, A.HELPERNO, A.SARDERNO, A.DEPTSERIAL,
               A.LINENO, A.MACHINECODE1, A.MACHINECODE2
        FROM WPSATTENDANCEDAYWISE A,
        (
            SELECT WORKERSERIAL, MAX(DATEOFATTENDANCE) DATEOFATTENDANCE
            FROM WPSATTENDANCEDAYWISE 
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE 
            AND DATEOFATTENDANCE < to_date(P_DATEOFATTENDANCE,'DD/MM/YYYY')
            AND ATTENDANCETAG = 'DEVICE'
            AND SPELLTYPE = 'SPELL 1'
            AND NVL(ATTENDANCEHOURS,0) > 0
            GROUP BY WORKERSERIAL
        ) B
        WHERE A.COMPANYCODE = P_COMPCODE AND A.DIVISIONCODE = P_DIVCODE
        AND A.DATEOFATTENDANCE = B.DATEOFATTENDANCE
        AND A.WORKERSERIAL = B.WORKERSERIAL
        AND NVL(A.ATTENDANCEHOURS,0) > 0
        AND A.ATTENDANCETAG = 'DEVICE'
        AND A.SPELLTYPE = 'SPELL 1';    
            
        lv_Sql := ' INSERT INTO WPSATTENDANCEDAYWISE ( COMPANYCODE,DIVISIONCODE,YEARCODE, DATEOFATTENDANCE, '||CHR(10) 
                ||' SHIFTCODE, PARENTSHIFTCODE, '||CHR(10) 
                ||' WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, DEPARTMENTCODE, OCCUPATIONCODE, WORKERTYPECODE, '||CHR(10)   
                ||' ATTENDANCEHOURS, OVERTIMEHOURS,'||CHR(10)
                ||' SPELLHOURS,DEDUCTIONHOURS,SPELLTYPE, SERIALNO, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, '||CHR(10) 
                ||' SYSROWID,USERNAME,MODULE, ATTENDANCETAG, BOOKNO, UNITCODE, '||CHR(10)
                ||' LOOMCODE, HELPERNO, SARDERNO, DEPTSERIAL, LINENO, MACHINECODE1, MACHINECODE2 ) '||CHR(10)
                ||' SELECT '''||P_COMPCODE||''' COMPANYCODE, '''||P_DIVCODE||''' DIVISIONCODE, '''||P_YEARCODE||''' YEARCODE, TO_DATE('''||P_DATEOFATTENDANCE||''',''DD/MM/YYYY'') DATEOFATTENDANCE, '||CHR(10)
                ||' CASE WHEN D.SHIFT IN (''A1'',''A2'') THEN ''1'' WHEN D.SHIFT IN (''B1'',''B2'') THEN ''2'' WHEN D.SHIFT IN (''C1'',''C2'') THEN ''3'' END SHIFTCODE, A.GROUPCODE PARENTSHIFTCODE,   '||CHR(10)
                ||' A.WORKERSERIAL, A.TOKENNO, A.WORKERCATEGORYCODE, NVL(L.DEPARTMENTCODE,A.DEPARTMENTCODE) DEPARTMENTCODE, NVL(L.OCCUPATIONCODE,A.OCCUPATIONCODE) OCCUPATIONCODE,  ''T'' WORKERTYPECODE, '||CHR(10);
        IF  lv_DayOffConsiderMaster='Y' then
            lv_Sql := lv_Sql ||' CASE WHEN NVL(A.DAYOFFDAY,''NONE'')='''||lv_Day||''' THEN 0 ELSE D.ATTENHOURS END ATTENHOURS,'||CHR(10)
                             ||' CASE WHEN NVL(A.DAYOFFDAY,''NONE'')='''||lv_Day||''' THEN D.ATTENHOURS ELSE 0 END OVERTIMEHOURS,'||CHR(10);
        else
            lv_Sql := lv_Sql ||' D.ATTENHOURS, 0 OVERTIMEHOURS, '||CHR(10); 
        end if;                   
        lv_Sql := lv_Sql ||' D.ATTENHOURS SPELLHOURS, 0 DEDUCTIONHOURS, DECODE(SUBSTR(D.SHIFT,2,1),''1'',''SPELL 1'',''SPELL 2'') AS SPELL, 1, '''||lv_FNSDT||''', '''||lv_FNEDT||''', '||chr(10)
                ||' ''1'' SYSROWID, ''SWT'' USERNAME,''WPS'' MODULE, ''DEVICE'' ATTENDANCETAG, ''ATTN/'||lv_ddmmyyyy||'/''||A.TOKENNO  AS BOOKNO, A.UNITCODE, '||chr(10)
                ||' L.LOOMCODE, L.HELPERNO, L.SARDERNO, L.DEPTSERIAL, L.LINENO, L.MACHINECODE1, L.MACHINECODE2 '||CHR(10)
                ||' FROM WPSWORKERMAST A, WPSDEPARTMENTMASTER B, WPSOCCUPATIONMAST C, GBL_WPSLASTWORKING_DEPT L, '||chr(10)
                ||' (   '||chr(10)
                ||'   SELECT DISTINCT DATEOFATTENDANCE, TOKENNO, SHIFT, ATTENHOURS '||chr(10)
                ||'   FROM ( ' ||CHR(10)
                ||'         SELECT DISTINCT DATEOFATTENDANCE, TOKENNO, SHIFT, ATTENHOURS '||chr(10) 
                ||'         FROM WPSATTENDANCEDEVICERAWDATA '||chr(10) 
                ||'         WHERE DATEOFATTENDANCE = '''||P_DATEOFATTENDANCE||''' '||CHR(10)
                ||'         AND SHIFT IS NOT NULL   '||CHR(10)
                ||'        )' ||CHR(10)
                ||' ) D  '||CHR(10)
                ||' WHERE A.COMPANYCODE = '''||P_COMPCODE||''' AND A.DIVISIONCODE = '''||P_DIVCODE||'''  '||CHR(10)
                ||' AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
                ||' AND A.DEPARTMENTCODE = B.DEPARTMENTCODE '||CHR(10)
                ||' AND A.TOKENNO  = D.TOKENNO '||CHR(10)
                ||' AND A.COMPANYCODE = C.COMPANYCODE (+) AND A.DIVISIONCODE = C.DIVISIONCODE (+) '||CHR(10)
                ||' AND A.DEPARTMENTCODE = C.DEPARTMENTCODE (+) AND A.OCCUPATIONCODE = C.OCCUPATIONCODE (+) '||CHR(10)
                ||' AND A.WORKERSERIAL = L.WORKERSERIAL (+) '||CHR(10);
        
        insert into WPS_ERROR_LOG (PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE,REMARKS ) 
        values( 'PRCWPS_IMP_ATTNOTDATA_LASTWORK',LV_SQLERRM,SYSDATE,lv_Sql,P_DATEOFATTENDANCE,TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY'),'ATTENDANCE DEVICE DATA TRANSFER');
        EXECUTE IMMEDIATE lv_Sql;
        COMMIT;

        ---------------- WORKING MORE THAN 8 HOURS BUT NOT MULTIPLE ON 8 -------
       /* SELECT DATEOFATTENDANCE, TOKENNO, SUM(ATTENHOURS) ATTENHOURS
        FROM (
                SELECT DISTINCT DATEOFATTENDANCE, TOKENNO, SHIFT, ATTENHOURS 
                FROM WPSATTNDEVICERAWDATA_19042016 
                WHERE DATEOFATTENDANCE = '01/04/2016'
                AND TIMEOFATTENDANCE >= '06:00:00' 
                AND SHIFT IS NOT NULL
                UNION ALL
                SELECT DISTINCT '01/04/2016', TOKENNO, SHIFT, ATTENHOURS 
                FROM WPSATTNDEVICERAWDATA_19042016 
                WHERE DATEOFATTENDANCE = '02/04/2016'
                AND TIMEOFATTENDANCE < '06:00:00' 
                AND SHIFT IS NOT NULL
            )
        GROUP BY DATEOFATTENDANCE, TOKENNO
        HAVING MOD(SUM(ATTENHOURS),8) <> 0
           AND SUM(ATTENHOURS) > 8;
      */
        FOR C1 IN (
                SELECT A.WORKERSERIAL, A.SHIFTCODE, SUM(A.ATTENDANCEHOURS) ATTENDANCEHOURS
                FROM  WPSATTENDANCEDAYWISE A,
                (
                    SELECT WORKERSERIAL, SUM(ATTENDANCEHOURS)
                    FROM WPSATTENDANCEDAYWISE
                    WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                      AND YEARCODE = P_YEARCODE
                      AND DATEOFATTENDANCE = TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                      AND ATTENDANCETAG ='DEVICE'
                    GROUP BY WORKERSERIAL
                    HAVING SUM(ATTENDANCEHOURS) > 8
                      AND MOD(SUM(ATTENDANCEHOURS),8) <> 0
                ) B
                WHERE A.COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                  AND A.YEARCODE = P_YEARCODE  
                  AND A.DATEOFATTENDANCE = TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                  AND ATTENDANCETAG ='DEVICE'
                  AND A.WORKERSERIAL = B.WORKERSERIAL
                  --AND A.WORKERSERIAL = '00134'
                GROUP BY A.WORKERSERIAL, A.SHIFTCODE 
                HAVING SUM(A.ATTENDANCEHOURS) < 8 
              )
        LOOP     
             UPDATE  WPSATTENDANCEDAYWISE SET REMARKS='ATTENDANCE HOURS GREATER THAN 8'
             WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND YEARCODE = P_YEARCODE
              AND DATEOFATTENDANCE = TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
              AND SHIFTCODE = C1.SHIFTCODE
              AND WORKERSERIAL = C1.WORKERSERIAL
              AND ATTENDANCETAG ='DEVICE';
              --DBMS_OUTPUT.PUT_LINE ('WORKERSERIAL '||C1.WORKERSERIAL||' , , '||C1.SHIFTCODE);           
        END LOOP;   
        COMMIT;      
        
        ---------------- WORKING 16 OR 24 HOURS  THEN FISRT SHIFT CONSIDER AS NORMAL ATTENDANCE AND OTHER SHIFT GOES TO TRANSFER TO OT HOURS -------
        
        FOR C16 IN (
                SELECT DATEOFATTENDANCE, WORKERSERIAL, SUM(ATTENDANCEHOURS) ATTENDANCEHOURS, MIN(SHIFTCODE) SHIFTCODE  
                FROM WPSATTENDANCEDAYWISE
                WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                  AND ATTENDANCETAG = 'DEVICE'
                  AND DATEOFATTENDANCE = TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                GROUP BY DATEOFATTENDANCE, WORKERSERIAL
                HAVING (SUM(ATTENDANCEHOURS) = 16 OR SUM(ATTENDANCEHOURS) = 24)           
              )
        LOOP     
             UPDATE  WPSATTENDANCEDAYWISE SET REMARKS='ATTENDANCE HOURS MULTIPLE OF 8'
             WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND YEARCODE = P_YEARCODE
              AND DATEOFATTENDANCE = TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
              AND SHIFTCODE <> C16.SHIFTCODE
              AND WORKERSERIAL = C16.WORKERSERIAL
              AND ATTENDANCETAG ='DEVICE';           
        END LOOP;    
        commit;

        ------ START UPDATE ATTENDANCE DATA TO O.T. WHEN WORKER WORKED IN STL OR LEAVE on 16.05.2016 by Amalesh Das----------------
        FOR cLeave in (
                        SELECT WORKERSERIAL FROM WPSATTENDANCEDAYWISE 
                        WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                          AND YEARCODE = P_YEARCODE
                          AND DATEOFATTENDANCE = TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                          AND ATTENDANCEHOURS >0
                        INTERSECT
                        SELECT WORKERSERIAL FROM WPSSTLENTRY 
                        WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                          AND STLFROMDATE <= TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                          AND STLTODATE >= TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                     )     
        loop
            UPDATE  WPSATTENDANCEDAYWISE SET OVERTIMEHOURS = ATTENDANCEHOURS, ATTENDANCEHOURS= 0, REMARKS = 'WORKED IN LEAVE'
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND YEARCODE = P_YEARCODE
              AND DATEOFATTENDANCE = TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
              AND WORKERSERIAL = cLeave.WORKERSERIAL
              AND ATTENDANCEHOURS > 0 
              AND ATTENDANCETAG ='DEVICE';
        end loop;            
        commit;
        ------ START UPDATE ATTENDANCE DATA TO O.T. WHERE WORKER WORKING CONTINOUSLY last 6 DAYS ON 16.05.2017 BY AMALESH DAS --------------
     /*   FOR c6days in (
            SELECT WORKERSERIAL, COUNT(*) CNT
            FROM (
                    SELECT DISTINCT A.WORKERSERIAL, A.DATEOFATTENDANCE  
                    FROM WPSATTENDANCEDAYWISE A,
                    ( SELECT DISTINCT WORKERSERIAL 
                      FROM WPSATTENDANCEDAYWISE
                      WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
                       AND DATEOFATTENDANCE = TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                       AND ATTENDANCEHOURS > 0
                    ) B   
                    WHERE A.COMPANYCODE = P_COMPCODE AND A.DIVISIONCODE = P_DIVCODE
                      AND A.DATEOFATTENDANCE < TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                      AND A.DATEOFATTENDANCE >= TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')-6
                      AND A.ATTENDANCEHOURS > 0
                      AND A.WORKERSERIAL = B.WORKERSERIAL
                 )
            GROUP BY WORKERSERIAL HAVING COUNT(*) >= 6        
            )
         loop
            UPDATE  WPSATTENDANCEDAYWISE SET OVERTIMEHOURS = ATTENDANCEHOURS, ATTENDANCEHOURS= 0, REMARKS = 'CONTINUOUS 6 DAYS WORKING'
            WHERE COMPANYCODE = P_COMPCODE AND DIVISIONCODE = P_DIVCODE
              AND YEARCODE = P_YEARCODE
              AND DATEOFATTENDANCE = TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
              AND WORKERSERIAL = c6days.WORKERSERIAL
              AND ATTENDANCEHOURS > 0 
              AND ATTENDANCETAG ='DEVICE';
         end loop;
         commit;  */ 
        ------ START UPDATE ATTENDANCE DATA TO O.T. WHERE WORKER WORKING CONTINOUSLY last 6 DAYS ON 16.05.2017 BY AMALESH DAS --------------        
    END IF;  
                                 
EXCEPTION
    WHEN OTHERS THEN
     --INSERT INTO ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) VALUES( 'ERROR SQL',LV_SQLSTR,LV_SQLSTR,LV_PARVALUES,LV_REMARKS);
     LV_SQLERRM := SQLERRM ;
     INSERT INTO WPS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) VALUES( 'PRCWPS_IMP_ATTNOTDATA_ONMASTER',LV_SQLERRM,NULL,NULL,TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY'),NULL, 'ATTENDANCE DATA IMPORT');
END;
/


