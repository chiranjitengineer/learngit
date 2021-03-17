DROP PROCEDURE NJMCL_WEB.PRCWPS_HOLIDAY_PROCESS;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_HOLIDAY_PROCESS" ( p_CompCode varchar2, p_DivisionCode varchar2, p_YearCode varchar2, 
                                                     p_UserName varchar2, p_HolidayDate varchar2,lv_HolidayHours number,
                                                     p_LastWorkingDate varchar2, p_NextWorkingDt varchar2 default 'NONE',
                                                     p_DayOffType varchar2 default 'MASTER' ,p_DayOffDay varchar2 default 'NONE'  
                                                   )
as
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_SqlStr               varchar2(10000):='';
lv_SqlStr1              varchar2(4000):='';
lv_Remarks              varchar2(1000) := '';
lv_SqlErrm              varchar2(500) := '';
lv_parvalues            varchar2(500) := '';   
lv_LastWorkingDay       varchar2(20) := ''; --to_date(p_LastWorkingDate,'dd/mm/yyyy');
lv_NextWorkingDay       varchar2(20);
lv_NextWorkingDate      varchar2(10):='';
lv_BeforeLastWorkingDate date;      -- for day off consider last working date
lv_AfterNextWorkingDate date;       -- for day off consider after next working date
lv_FNStartDate          date;
lv_FNEndDate            date;
lv_Cnt                  number:=0;
lv_ProcName             varchar2(30) := 'PRCWPS_HOLIDAY_PROCESS';

lv_ConsiderMasterOffDay varchar2(10);       --- use for Dayoff considet from worker master or not
lv_HolidayType          varchar2(20):='';
     
begin
    lv_result:='#SUCCESS#';
    lv_Remarks := 'HOLIDAY PROCESS';
    lv_parvalues := p_HolidayDate;
    lv_NextWorkingDate := p_NextWorkingDt;
    --- when next working data not required then we treat the last working date as next working data ------- 
    lv_LastWorkingDay := TRIM(TO_CHAR(TO_DATE(p_LastWorkingDate,'DD/MM/YYYY'),'DAY')); 
    
    if (length(p_NextWorkingDt)<=0 or nvl(p_NextWorkingDt,'N') = 'N') THEN
        lv_NextWorkingDate := p_LastWorkingDate;
        lv_NextWorkingDay := to_date(lv_NextWorkingDate,'dd/mm/yyyy');
    else
        lv_NextWorkingDay := to_date(lv_NextWorkingDate,'dd/mm/yyyy');
    end if;
    
--    IF LTRIM(RTRIM(TO_CHAR(lv_LastWorkingDay,'DAY'))) = 'MONDAY' THEN
    IF lv_LastWorkingDay = 'MONDAY' THEN
        PRC_WORKER_ATTNSTATUS_GENERATE(p_CompCode, p_DivisionCode, p_HolidayDate, p_LastWorkingDate, 'W',p_UserName);
    END IF;
    
    lv_BeforeLastWorkingDate := to_date(p_LastWorkingDate,'dd/mm/yyyy')-1; 
    lv_AfterNextWorkingDate := to_date(lv_NextWorkingDate,'dd/mm/yyyy')+1;
    
    select nvl(HOLIDAYTYPE,'GENERAL') INTO lv_HolidayType from WPSHOLIDAYMASTER 
    WHERE COMPANYCODE = p_CompCode AND DIVISIONCODE = p_DivisionCode 
      AND HOLIDAYDATE = TO_DATE(p_HolidayDate,'DD/MM/YYYY');
    
    SELECT DAYOFFCONSIDER_ATTN_IMPORT INTO lv_ConsiderMasterOffDay FROM WPSWAGESPARAMETER WHERE DIVISIONCODE = p_DivisionCode;
    
    select FORTNIGHTSTARTDATE, FORTNIGHTENDDATE into lv_FNStartDate, lv_FNEndDate
    FROM WPSWAGEDPERIODDECLARATION WHERE COMPANYCODE = p_CompCode AND DIVISIONCODE = p_DivisionCode
     AND FORTNIGHTSTARTDATE <= TO_DATE(p_HolidayDate,'dd/mm/yyyy')
     AND FORTNIGHTENDDATE >= TO_DATE(p_HolidayDate,'dd/mm/yyyy') ;
     ----- chekcing for whage already process or not ----
    
    SELECT COUNT(*) into lv_Cnt FROM WPSWAGESDETAILS_MV  
    WHERE COMPANYCODE = p_CompCode AND DIVISIONCODE = p_DivisionCode 
    AND YEARCODE = p_YearCode 
    AND FORTNIGHTSTARTDATE = lv_FNStartDate
    AND FORTNIGHTENDDATE = lv_FNEndDate;
    
--    if lv_Cnt > 0 then
--        lv_error_remark := 'Validation Failure : [WAGES ALREADY PROCESS]';
--        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
--    end if;    
    
    
    Case lv_HolidayType
        when 'GENERAL' then
         ------- holiday data delete -----------
            DELETE FROM WPSHOLIDAYDATA 
            WHERE COMPANYCODE = p_CompCode AND DIVISIONCODE = p_DivisionCode 
            AND HOLIDAY = TO_DATE(p_HolidayDate,'DD/MM/YYYY');
            ---- ATTENDANCE DATA DELETE FROM ATTENANCDE TABLE BASED HOLIDAY DATE AND ATTENDANCE TAG ----
            DELETE FROM WPSATTENDANCEDAYWISE 
            WHERE COMPANYCODE = p_CompCode AND DIVISIONCODE = p_DivisionCode
              AND YEARCODE = p_YearCode 
              AND DATEOFATTENDANCE = TO_DATE(p_HolidayDate,'DD/MM/YYYY')
              AND ATTENDANCETAG = 'HD';
              
            ---- DATAA INSERT FOR THOSE WORKER WHO WORKED IN BOTH LATST WORKING DATE OR NEXT WORKING DATE , 
            ---- IN CASE WHO NOT MAINTAIN THE NEXT WORKING DATE THEN WE CONSIDER NEXT WORKING VAIRABLE VALUE SAME AS LAST WORKING DATE VALUE
            lv_SqlStr := ' INSERT INTO  WPSHOLIDAYDATA '||CHR(10) 
                    ||' (COMPANYCODE, DIVISIONCODE,YEARCODE, HOLIDAY, BEFOREHOLIDAYDATEBASEDON,AFTERHOLIDAYDATEBASEDON, '||CHR(10)
                    ||' GROUPCODE,SHIFTCODE, DEPARTMENTCODE, SECTIONCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, OCCUPATIONCODE, '||CHR(10)  
                    ||' ATTENDANCEHOURS, HOLIDAYHOURS, OVERTIMEHOURS, OTHERHOURS, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERTYPECODE, ATTENDANCETAG, ISDAYOFF, USERNAME,LASTMODIFIED, SERIALNO, UNITCODE) '||CHR(10) 
                    ||' SELECT A.COMPANYCODE, A.DIVISIONCODE,A.YEARCODE, TO_DATE('''||p_HolidayDate||''',''DD/MM/YYYY'') HOLIDAY,  A.DATEOFATTENDANCE BEFOREHOLIDAYDATEBASEDON,TO_DATE('''||lv_NextWorkingDate||''',''DD/MM/YYYY'') AFTERHOLIDAYDATEBASEDON, '||CHR(10)
                    ||' M.GROUPCODE, A.SHIFTCODE,A.DEPARTMENTCODE, A.SECTIONCODE, A.WORKERSERIAL, A.TOKENNO, M.WORKERCATEGORYCODE, A.OCCUPATIONCODE, '||CHR(10) 
                    ||' 0 ATTENDANCEHOURS, '''|| lv_HolidayHours||'''  HOLIDAYHOURS, 0 OVERTIMEHOURS, 0 OTHERHOURS, '''||lv_FNStartDate||''' AS FORTNIGHTSTARTDATE, '''||lv_FNEndDate||''' AS FORTNIGHTENDDATE, '||CHR(10)  
                    ||' B.WORKERTYPECODE, ''HD'' ATTENDANCETAG, ''N'' ISDAYOFF, '''||p_UserName||''', SYSDATE LASTMODIFIED, 1 AS SERIALNO, A.UNITCODE'||CHR(10)
                    ||' FROM WPSATTENDANCEDAYWISE A, WPSOCCUPATIONMAST B, WPSWORKERMAST M, '||CHR(10) 
                    ||' ( '||CHR(10)
                    ||'     SELECT WORKERSERIAL  FROM WPSATTENDANCEDAYWISE A '||CHR(10)
                    ||'     WHERE A.COMPANYCODE = '''||p_CompCode||''' AND A.DIVISIONCODE = '''||p_DivisionCode||'''  '||CHR(10) 
                    ||'       AND A.YEARCODE = '''||p_YearCode||'''         '||CHR(10) 
                    ||'       AND A.DATEOFATTENDANCE = TO_DATE('''||lv_NextWorkingDate||''',''DD/MM/YYYY'') '||CHR(10)
                    ||'     GROUP BY WORKERSERIAL '||CHR(10)
                    ||'     HAVING SUM((NVL(A.ATTENDANCEHOURS,0)+NVL(A.NIGHTALLOWANCEHOURS,0))) >= 8 '||CHR(10) 
                    ||' ) C,        '||CHR(10)
                    ||' ( '||CHR(10)
                    ||'    SELECT DISTINCT WORKERSERIAL '||CHR(10)
                    ||'    FROM ( '||CHR(10) 
                    ||'             SELECT WORKERSERIAL  FROM WPSATTENDANCEDAYWISE A '||CHR(10)
                    ||'             WHERE A.COMPANYCODE = '''||p_CompCode||''' AND A.DIVISIONCODE = '''||p_DivisionCode||''' '||CHR(10) 
                    ||'               AND A.YEARCODE = '''||p_YearCode||'''         '||CHR(10) 
                    ||'               AND A.DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') '||CHR(10)
                    ||'             GROUP BY WORKERSERIAL '||CHR(10)
                    ||'             HAVING SUM((NVL(A.ATTENDANCEHOURS,0)+NVL(A.NIGHTALLOWANCEHOURS,0))) >= 8 '||CHR(10) 
                    ||'         ) '||CHR(10)
                    ||' ) D,        '||CHR(10)
                    ||' (           '||CHR(10)
                    ||'     SELECT WORKERCATEGORYCODE FROM WPSWORKERCATEGORYVSCOMPONENT '||CHR(10)
                    ||'     WHERE COMPANYCODE = '''||p_CompCode||''' AND DIVISIONCODE = '''||p_DivisionCode||''' '||CHR(10) 
                    ||'     AND EFFECTIVEDATE = ( '||CHR(10) 
                    ||'                           SELECT MAX(EFFECTIVEDATE) FROM WPSWORKERCATEGORYVSCOMPONENT '||CHR(10)
                    ||'                           WHERE COMPANYCODE = '''||p_CompCode||''' AND DIVISIONCODE = '''||p_DivisionCode||''' '||CHR(10)  
                    ||'                         ) '||CHR(10)
                    ||'     AND COMPONENTSHORTNAME = ''H_WAGES'' '||CHR(10)
                    ||'     AND APPLICABLE = ''YES''  '||CHR(10) 
                    ||' ) E '||CHR(10)
                    ||' WHERE A.COMPANYCODE = '''||p_CompCode||''' AND A.DIVISIONCODE = '''||p_DivisionCode||''' '||CHR(10) 
                    ||'   AND A.YEARCODE = '''||p_YearCode||'''   '||CHR(10) 
                    ||'   AND A.DATEOFATTENDANCE =TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') '||CHR(10)
                  --  ||'   AND A.SPELLTYPE = ''SPELL 1'' '||CHR(10)
                    ||'   AND (NVL(A.ATTENDANCEHOURS,0)+NVL(A.NIGHTALLOWANCEHOURS,0)) <> 0 '||CHR(10) 
                    ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10) 
                    ||'   AND A.DEPARTMENTCODE = B.DEPARTMENTCODE AND A.OCCUPATIONCODE = B.OCCUPATIONCODE '||CHR(10) 
                    ||'   AND A.WORKERSERIAL = C.WORKERSERIAL '||CHR(10) 
                    ||'   AND A.WORKERSERIAL = D.WORKERSERIAL '||CHR(10)
                    ||'   AND A.WORKERSERIAL = M.WORKERSERIAL '||CHR(10) 
                    ||'   AND M.WORKERCATEGORYCODE = E.WORKERCATEGORYCODE '||CHR(10)
                    ||' UNION ALL '||CHR(10)  --- BELOW INCLUDE DAY BEFORE HOLIDAY IS THE STLTO DATE 
                    ||' SELECT DISTINCT A.COMPANYCODE, A.DIVISIONCODE,A.YEARCODE, TO_DATE('''||p_HolidayDate||''',''DD/MM/YYYY'') HOLIDAY,  A.LEAVETODATE BEFOREHOLIDAYDATEBASEDON,TO_DATE('''||lv_NextWorkingDate||''',''DD/MM/YYYY'') AFTERHOLIDAYDATEBASEDON,  '||CHR(10) 
                    ||'  M.GROUPCODE, A.SHIFTCODE,A.DEPARTMENTCODE, A.SECTIONCODE, A.WORKERSERIAL, A.TOKENNO, M.WORKERCATEGORYCODE, A.OCCUPATIONCODE,   '||CHR(10)
                    ||'  0 ATTENDANCEHOURS, '''|| lv_HolidayHours||'''  HOLIDAYHOURS, 0 OVERTIMEHOURS, 0 OTHERHOURS, '''||lv_FNStartDate||''' AS FORTNIGHTSTARTDATE, '''||lv_FNEndDate||''' AS FORTNIGHTENDDATE,   '||CHR(10)
                    ||'  O.WORKERTYPECODE, ''HD'' ATTENDANCETAG, ''N'' ISDAYOFF, '''||p_UserName||''', SYSDATE LASTMODIFIED, 1 AS SERIALNO, M.UNITCODE  '||CHR(10)
                    ||' FROM WPSSTLENTRYDETAILS A, WPSWORKERMAST M, WPSOCCUPATIONMAST O   '||CHR(10)
                    ||' WHERE A.COMPANYCODE ='''||p_CompCode||''' AND A.DIVISIONCODE = '''||p_DivisionCode||'''  '||CHR(10)
                    ||'   AND A.LEAVETODATE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'')  '||CHR(10)
                    ||'   AND A.LEAVECODE = ''STL'' '||CHR(10)
                    ||'   AND A.COMPANYCODE = M.COMPANYCODE AND A.DIVISIONCODE = M.DIVISIONCODE AND A.WORKERSERIAL = M.WORKERSERIAL  '||CHR(10)
                    ||'   AND A.COMPANYCODE = O.COMPANYCODE AND A.DIVISIONCODE = O.DIVISIONCODE  '||CHR(10)
                    ||'   AND A.DEPARTMENTCODE = O.DEPARTMENTCODE AND A.SECTIONCODE = O.SECTIONCODE AND A.OCCUPATIONCODE = O.OCCUPATIONCODE  '||CHR(10); 
                    
                    
            insert into WPS_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                               values(p_CompCode, p_DivisionCode, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_FNStartDate,lv_FNEndDate, lv_remarks);
            commit;
            execute immediate lv_SqlStr;
            commit;
--            dbms_output.put_line ('phase 1 complete');
--            dbms_output.put_line ('CONSIDER MASTER OFF DAY '||lv_ConsiderMasterOffDay);
            ---- NOW CONSIDER DAY OF ON LAST WORKING DATE --- WORKER SHOULD WORKED ON DAY BEFORE LAST WORKING DATE ----
            lv_SqlStr1 := '';
            lv_SqlStr1 := ' SELECT DISTINCT WORKERSERIAL FROM '||CHR(10)
                       || ' ( '||CHR(10) ;
            if p_LastWorkingDate = lv_NextWorkingDate then
                lv_SqlStr1 := lv_SqlStr1 ||' select distinct workerserial from WPSWORKERDAILYSTATUS /*WPSATTENDANCEDAYWISE */'||chr(10)
                                         ||' where companycode = '''||p_CompCode||''' '||chr(10)
                                         ||'   and divisioncode = '''||p_DivisionCode||''' '||chr(10)
                                         ||'   and yearcode = '''||p_YearCode||'''  '||chr(10)
                                         ||'   and dateofattendance = to_date('''||p_LastWorkingDate||''',''dd/mm/yyyy'') '||chr(10)
                                         ||'   AND WORKERSTATUS=''W'' /*and nvl(ISDAYOFF,''N'') = ''Y'' */'||CHR(10);
                if lv_ConsiderMasterOffDay ='Y' then
                    lv_SqlStr1 := lv_SqlStr1 ||' union all '||chr(10)
                                             ||' SELECT DISTINCT WORKERSERIAL '||CHR(10)
                                             ||' FROM ('||CHR(10) 
                                             ||'        select WORKERSERIAL from WPSWORKERMAST '||chr(10)
                                             ||'        where companycode = '''||p_CompCode||''' '||chr(10)
                                             ||'          and divisioncode = '''||p_DivisionCode||''' '||chr(10)
                                             ||'          AND NVL(active,''N'')= ''Y'' '||CHR(10)
                                             ||'          AND NVL(DAYOFFDAY,''NONE'') = TRIM(TO_CHAR(TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY''),''DAY'')) '||chr(10)
                                             ||'        MINUS '||CHR(10)
                                             ||'        SELECT WORKERSERIAL FROM WPSATTENDANCEDAYWISE '||CHR(10)
                                             ||'        WHERE COMPANYCODE = '''||p_CompCode||''' AND DIVISIONCODE = '''||p_DivisionCode||''' '||CHR(10)
                                             ||'          AND YEARCODE = '''||p_YearCode||'''  '||CHR(10)
                                             ||'          AND DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') - 1 '||CHR(10)
                                             ||'          AND SHIFTCODE = ''3'' '||CHR(10)
                                             ||'          AND NVL(ATTENDANCEHOURS,0) > 0 '||CHR(10)
                                             ||'    ) '||CHR(10);
                end if;          
                lv_SqlStr1 := lv_SqlStr1 ||') '||CHR(10);
                
                --dbms_output.put_line ('lv_SqlStr1 '||lv_SqlStr1);
                
                lv_SqlStr := ' INSERT INTO  WPSHOLIDAYDATA '||CHR(10) 
                        ||' (COMPANYCODE, DIVISIONCODE,YEARCODE, HOLIDAY, BEFOREHOLIDAYDATEBASEDON,AFTERHOLIDAYDATEBASEDON, '||CHR(10)
                        ||' GROUPCODE,SHIFTCODE, DEPARTMENTCODE, SECTIONCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, OCCUPATIONCODE, '||CHR(10)  
                        ||' ATTENDANCEHOURS, HOLIDAYHOURS, OVERTIMEHOURS, OTHERHOURS, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERTYPECODE, ATTENDANCETAG, ISDAYOFF, USERNAME, LASTMODIFIED, SERIALNO, UNITCODE) '||CHR(10) 
                        ||' SELECT A.COMPANYCODE, A.DIVISIONCODE,A.YEARCODE, TO_DATE('''||p_HolidayDate||''',''DD/MM/YYYY'') HOLIDAY,  A.DATEOFATTENDANCE BEFOREHOLIDAYDATEBASEDON,TO_DATE('''||lv_NextWorkingDate||''',''DD/MM/YYYY'') AFTERHOLIDAYDATEBASEDON, '||CHR(10)
                        ||' M.GROUPCODE, A.SHIFTCODE,A.DEPARTMENTCODE, A.SECTIONCODE, A.WORKERSERIAL, A.TOKENNO, M.WORKERCATEGORYCODE, A.OCCUPATIONCODE, '||CHR(10) 
                        ||' 0 ATTENDANCEHOURS, '''|| lv_HolidayHours||'''  HOLIDAYHOURS, 0 OVERTIMEHOURS, 0 OTHERHOURS, '''||lv_FNStartDate||''' AS FORTNIGHTSTARTDATE, '''||lv_FNEndDate||''' AS FORTNIGHTENDDATE, '||CHR(10)  
                        ||' B.WORKERTYPECODE, ''HD'' ATTENDANCETAG, ''N'' ISDAYOFF,'''||p_UserName||''', SYSDATE LASTMODIFIED, 1 AS SERIALNO, A.UNITCODE'||CHR(10)
                        ||' FROM WPSATTENDANCEDAYWISE A, WPSOCCUPATIONMAST B, WPSWORKERMAST M, '||CHR(10) 
                        ||' ( '||CHR(10)
                        ||'     SELECT WORKERSERIAL  FROM WPSATTENDANCEDAYWISE A '||CHR(10)
                        ||'     WHERE A.COMPANYCODE = '''||p_CompCode||''' AND A.DIVISIONCODE = '''||p_DivisionCode||''' '||CHR(10) 
                        ||'       AND A.YEARCODE = '''||p_YearCode||'''         '||CHR(10) 
                        ||'       AND A.DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'')-1 '||CHR(10)
                        ||'     GROUP BY WORKERSERIAL '||CHR(10)   
                        ||'     HAVING SUM((NVL(A.ATTENDANCEHOURS,0)+NVL(A.NIGHTALLOWANCEHOURS,0))) >= 8 '||CHR(10)
                        ||' ) C,        '||CHR(10)
                        ||' (           '||CHR(10)
                        ||'     SELECT WORKERCATEGORYCODE FROM WPSWORKERCATEGORYVSCOMPONENT '||CHR(10)
                        ||'     WHERE COMPANYCODE = '''||p_CompCode||''' AND DIVISIONCODE = '''||p_DivisionCode||''' '||CHR(10) 
                        ||'     AND EFFECTIVEDATE = ( '||CHR(10) 
                        ||'                           SELECT MAX(EFFECTIVEDATE) FROM WPSWORKERCATEGORYVSCOMPONENT '||CHR(10)
                        ||'                           WHERE COMPANYCODE = '''||p_CompCode||''' AND DIVISIONCODE = '''||p_DivisionCode||''' '||CHR(10)  
                        ||'                         ) '||CHR(10)
                        ||'     AND COMPONENTSHORTNAME = ''H_WAGES'' '||CHR(10)
                        ||'     AND APPLICABLE = ''YES''  '||CHR(10)
                        ||' ) D, '||CHR(10);
                lv_SqlStr := lv_SqlStr ||'('||lv_SqlStr1||') L '||CHR(10)         
                        ||' WHERE A.COMPANYCODE = '''||p_CompCode||''' AND A.DIVISIONCODE = '''||p_DivisionCode||''' '||CHR(10) 
                        ||'   AND A.YEARCODE = '''||p_YearCode||'''   '||CHR(10) 
                        ||'   AND A.DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'')-1 '||CHR(10)
                        ||'   AND (NVL(A.ATTENDANCEHOURS,0)+NVL(A.NIGHTALLOWANCEHOURS,0)) <> 0 '||CHR(10)
                        ||'   /*AND SPELLTYPE = ''SPELL 1'' */'||CHR(10) 
                        ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10) 
                        ||'   AND A.DEPARTMENTCODE = B.DEPARTMENTCODE AND A.OCCUPATIONCODE = B.OCCUPATIONCODE '||CHR(10) 
                        ||'   AND A.WORKERSERIAL = C.WORKERSERIAL '||CHR(10)
                        ||'   AND A.WORKERSERIAL = L.WORKERSERIAL '||CHR(10) 
                        ||'   AND A.WORKERSERIAL = M.WORKERSERIAL '||CHR(10) 
                        ||'   AND M.WORKERCATEGORYCODE = D.WORKERCATEGORYCODE '||CHR(10);
                        
                insert into WPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                values( p_CompCode, p_DivisionCode, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_FNStartDate,lv_FNEndDate, lv_remarks);
                execute immediate lv_SqlStr;
                commit;
                -----  consider worker's whose last working data is day off and stl todate is just before of last woring date 
                lv_remarks := 'LAST WORKING DATE AS DAYOFF BY STL TO DATE DAY B4 LAST WORKING DATE';
                lv_SqlStr := 'INSERT INTO WPSHOLIDAYDATA ( '||CHR(10)
                    ||' COMPANYCODE, DIVISIONCODE,YEARCODE, HOLIDAY, BEFOREHOLIDAYDATEBASEDON,AFTERHOLIDAYDATEBASEDON,  '||CHR(10) 
                    ||' GROUPCODE,SHIFTCODE, DEPARTMENTCODE, SECTIONCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, OCCUPATIONCODE,  '||CHR(10)   
                    ||' ATTENDANCEHOURS, HOLIDAYHOURS, OVERTIMEHOURS, OTHERHOURS, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERTYPECODE,  '||CHR(10)
                    ||' ATTENDANCETAG, ISDAYOFF, USERNAME, LASTMODIFIED, SERIALNO, UNITCODE)  '||CHR(10)
                    ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE, TO_DATE('''||p_HolidayDate||''',''DD/MM/YYYY'') HOLIDAY ,TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'')-1 BEFOREHOLIDAYDATEBASEDON ,TO_DATE('''||lv_NextWorkingDate||''',''DD/MM/YYYY'') AFTERHOLIDAYDATEBASEDON,  '||CHR(10) 
                    ||' B.GROUPCODE, A.SHIFTCODE, A.DEPARTMENTCODE, A.SECTIONCODE, A.WORKERSERIAL, A.TOKENNO, A.WORKERCATEGORYCODE, A.OCCUPATIONCODE,  '||CHR(10)
                    ||' 0 ATTENDANCEHOURS, '''|| lv_HolidayHours||''' HOLIDAYHOURS, 0 OVERTIMEHOURS, 0 OTHERHOURS, '''||lv_FNStartDate||''' AS  FORTNIGHTSTARTDATE, '''||lv_FNEndDate||''' AS FORTNIGHTENDDATE, B.WORKTYPECODE,  '||CHR(10) 
                    ||' ''HD'' ATTENDANCETAG, ''N'' ISDAYOFF, '''||p_UserName||''' USERNAME, SYSDATE LASTMODIFIED, 0 SERIALNO, B.UNITCODE   '||CHR(10)
                    ||' FROM WPSSTLENTRY A, WPSWORKERMAST B  '||CHR(10)
                    ||' WHERE A.COMPANYCODE ='''||p_CompCode||''' AND A.DIVISIONCODE = '''||p_DivisionCode||'''  '||CHR(10)
                    ||'   AND A.STLTODATE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'')-1  '||CHR(10)
                    ||'   AND A.LEAVECODE = ''STL'' '||CHR(10)
                    ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE  '||CHR(10)
                    ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||CHR(10)
                    ||'   AND NVL(DAYOFFDAY,''NONE'') = TRIM(TO_CHAR(TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY''),''DAY'')) '||chr(10)
                    ||'   AND A.WORKERSERIAL NOT IN (SELECT WORKERSERIAL FROM WPSSTLENTRY '||CHR(10)
                    ||'                              WHERE COMPANYCODE = '''||p_CompCode||''' AND A.DIVISIONCODE = '''||p_DivisionCode||'''  '||CHR(10)
                    ||'                                AND STLFROMDATE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') AND LEAVECODE = ''STL'' '||CHR(10)
                    ||'                             ) '||CHR(10) ;
                insert into WPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                values( p_CompCode, p_DivisionCode, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_FNStartDate,lv_FNEndDate, lv_remarks);
                execute immediate lv_SqlStr;
                commit;
                
                --START ADDED BY PRASUN ON 20102019
                
                IF lv_LastWorkingDay = 'TUESDAY' THEN
                               

                     lv_remarks := 'INSERT WHEN MONDAY AND TUESDAY BOTH DAY OFF' ;   
                                    
                        lv_SqlStr := ' INSERT INTO  WPSHOLIDAYDATA '||CHR(10) 
                        ||' (COMPANYCODE, DIVISIONCODE,YEARCODE, HOLIDAY, BEFOREHOLIDAYDATEBASEDON,AFTERHOLIDAYDATEBASEDON, '||CHR(10)
                        ||' GROUPCODE,SHIFTCODE, DEPARTMENTCODE, SECTIONCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, OCCUPATIONCODE, '||CHR(10)  
                        ||' ATTENDANCEHOURS, HOLIDAYHOURS, OVERTIMEHOURS, OTHERHOURS, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERTYPECODE, ATTENDANCETAG, ISDAYOFF, USERNAME, LASTMODIFIED, SERIALNO, UNITCODE) '||CHR(10)
                        ||' SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, TO_DATE('''||p_HolidayDate||''',''DD/MM/YYYY'') HOLIDAY ,TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'')-2 BEFOREHOLIDAYDATEBASEDON ,TO_DATE('''||lv_NextWorkingDate||''',''DD/MM/YYYY'') AFTERHOLIDAYDATEBASEDON,  '||CHR(10) 
                        ||' GROUPCODE, SHIFTCODE, DEPARTMENTCODE, SECTIONCODE, A.WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, OCCUPATIONCODE,  '||CHR(10)
                        ||' 0 ATTENDANCEHOURS, '''|| lv_HolidayHours||''' HOLIDAYHOURS, 0 OVERTIMEHOURS, 0 OTHERHOURS, '''||lv_FNStartDate||''' AS  FORTNIGHTSTARTDATE, '''||lv_FNEndDate||''' AS FORTNIGHTENDDATE, WORKERTYPECODE,  '||CHR(10) 
                        ||' ''HD'' ATTENDANCETAG, ''N'' ISDAYOFF, '''||p_UserName||''' USERNAME, SYSDATE LASTMODIFIED, 0 SERIALNO, '''' UNITCODE   '||CHR(10)   
                        ||'    FROM WPSATTENDANCEDAYWISE    A, '||CHR(10)
                        ||'(    '||CHR(10) 
                        ||'    SELECT WORKERSERIAL  '||CHR(10)
                        ||'    FROM WPSATTENDANCEDAYWISE   '||CHR(10)   
                        ||'    WHERE  COMPANYCODE = '''||p_CompCode||'''   '||CHR(10)   
                        ||'    AND DIVISIONCODE = '''||p_DivisionCode||'''    '||CHR(10)   
                        ||'    AND YEARCODE = '''||p_YearCode||'''   '||CHR(10)   
                        ||'    AND DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'')-2   '||CHR(10)   
                        ||'    AND SHIFTCODE = ''3''   '||CHR(10)   
                        ||'    AND ATTENDANCEHOURS > 0   '||CHR(10)   
                        ||'    INTERSECT   '||CHR(10) 
                        ||'    (   '||CHR(10)   
                        ||'    SELECT WORKERSERIAL  '||CHR(10)   
                        ||'    FROM WPSATTENDANCEDAYWISE     '||CHR(10)     
                        ||'    WHERE  COMPANYCODE = '''||p_CompCode||'''   '||CHR(10)   
                        ||'    AND DIVISIONCODE = '''||p_DivisionCode||'''    '||CHR(10)   
                        ||'    AND YEARCODE = '''||p_YearCode||'''   '||CHR(10)   
                        ||'    AND DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'')   '||CHR(10)   
                        ||'    AND SHIFTCODE = ''3''   '||CHR(10)   
                        ||'    AND ATTENDANCEHOURS > 0   '||CHR(10)   
                        ||'    UNION    '||CHR(10)   
                        ||'    SELECT WORKERSERIAL  '||CHR(10)   
                        ||'    FROM WPSWORKERMAST  '||CHR(10)   
                        ||'    WHERE  COMPANYCODE = '''||p_CompCode||'''   '||CHR(10)   
                        ||'    AND DIVISIONCODE = '''||p_DivisionCode||'''   '||CHR(10)   
                        ||'    AND ACTIVE = ''Y''   '||CHR(10)   
                        ||'    AND DAYOFFDAY = ''TUESDAY''  '||CHR(10)   
                        ||'    )   '||CHR(10)  
                        ||' ) B    '||CHR(10)  
                        ||' WHERE A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)  
                        ||'    AND  COMPANYCODE = '''||p_CompCode||'''   '||CHR(10)   
                        ||'    AND DIVISIONCODE = '''||p_DivisionCode||'''    '||CHR(10)   
                        ||'    AND YEARCODE = '''||p_YearCode||'''   '||CHR(10)   
                        ||'    AND DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'')-2   '||CHR(10)   
                        ||'    AND SHIFTCODE = ''3''   '||CHR(10)   
                        ||'    AND ATTENDANCEHOURS > 0   '||CHR(10)   
                        ||'    AND A.WORKERSERIAL NOT IN (   '||CHR(10)   
                        ||'    SELECT WORKERSERIAL FROM WPSHOLIDAYDATA   '||CHR(10)   
                        ||'    WHERE COMPANYCODE = '''||p_CompCode||'''    '||CHR(10)   
                        ||'    AND DIVISIONCODE = '''||p_DivisionCode||'''   '||CHR(10)   
                        ||'    AND HOLIDAY = TO_DATE('''||p_HolidayDate||''',''DD/MM/YYYY''))';   
  
            
                        insert into WPS_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                        values( p_CompCode, p_DivisionCode, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_FNStartDate,lv_FNEndDate, lv_remarks);
                        COMMIT;
                        execute immediate lv_SqlStr;
                        commit;       
                             
                             
                             
                      ----- DELETE FROM WPSHOLIDAY DATA  WHEN MODAY IS SHIFT '2' AND TUESDAY IS SHIFT '3'
                               
                    lv_remarks :=  'DELETE FROM WPSHOLIDAY DATA  WHEN MODAY IS SHIFT "2" AND TUESDAY IS SHIFT "3"  ';
                            
                              
                        lv_SqlStr := ' DELETE FROM WPSHOLIDAYDATA   '||chr(10)
                               ||'  WHERE WORKERSERIAL IN (  '||chr(10)
                               ||'         SELECT T1.WORKERSERIAL FROM WPSHOLIDAYDATA T1, WPSWORKERMAST T2,  '||chr(10)
                               ||'         (   '||chr(10)
                               ||'             SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL FROM WPSATTENDANCEDAYWISE  '||chr(10) 
                               ||'             WHERE  COMPANYCODE = '''||p_CompCode||'''  '||chr(10)
                               ||'             AND DIVISIONCODE ='''||p_DivisionCode||''' '||chr(10)
                               ||'             AND YEARCODE = '''||p_YearCode||'''  '||chr(10)
                               ||'             AND DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'')-1  '||chr(10)
                               ||'             AND SHIFTCODE = ''2''  '||chr(10)
                               ||'             AND ATTENDANCEHOURS > 0  '||chr(10)
                               ||'             MINUS  '||chr(10)
                               ||'             SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL FROM WPSATTENDANCEDAYWISE  '||chr(10)
                               ||'             WHERE COMPANYCODE = '''||p_CompCode||'''  '||chr(10)
                               ||'             AND DIVISIONCODE = '''||p_DivisionCode||'''  '||chr(10)
                               ||'             AND YEARCODE = '''||p_YearCode||'''  '||chr(10)
                               ||'             AND DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'')  '||chr(10)
                               ||'             AND SHIFTCODE = ''3''  '||chr(10)
                               ||'             AND ATTENDANCEHOURS > 0  '||chr(10)
                               ||'         ) T3  '||chr(10)
                               ||'         WHERE  T1.COMPANYCODE = T2.COMPANYCODE  '||chr(10)
                               ||'         AND    T1.DIVISIONCODE = T2.DIVISIONCODE  '||chr(10)
                               ||'         AND    T1.WORKERSERIAL = T2.WORKERSERIAL  '||chr(10)
                               ||'         AND    T1.COMPANYCODE = T3.COMPANYCODE  '||chr(10)
                               ||'         AND    T1.DIVISIONCODE = T3.DIVISIONCODE  '||chr(10)
                               ||'         AND    T1.WORKERSERIAL = T3.WORKERSERIAL  '||chr(10)
                               ||'         AND    T1.HOLIDAY = TO_DATE('''||p_HolidayDate||''',''DD/MM/YYYY'')  '||chr(10)
                               ||'         AND    T2.DAYOFFDAY = ''TUESDAY''  '||chr(10)
                               ||'         AND    T2.ACTIVE  = ''Y''    '||chr(10)
                               ||'   )       '||chr(10)
                               ||'   AND HOLIDAY  = TO_DATE('''||p_HolidayDate||''',''DD/MM/YYYY'') '||chr(10)
                               ||'   AND COMPANYCODE = '''||p_CompCode||'''  '||chr(10)
                               ||'   AND DIVISIONCODE = '''||p_DivisionCode||'''  '||chr(10)
                               ||'   AND YEARCODE = '''||p_YearCode||''' '||chr(10);
                                       

                        insert into WPS_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                        values( p_CompCode, p_DivisionCode, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_FNStartDate,lv_FNEndDate, lv_remarks);
                        COMMIT;
                        execute immediate lv_SqlStr;
                        commit;  

                END IF;
                
                --END ADDED BY PRASUN ON 20102019
                
                
                DELETE FROM WPSHOLIDAYDATA AA
                WHERE ROWID < ( SELECT MAX(ROWID) FROM WPSHOLIDAYDATA BB
                       WHERE AA.WORKERSERIAL = BB.WORKERSERIAL
                         AND AA.HOLIDAY=BB.HOLIDAY)
                         AND HOLIDAY=TO_DATE(P_HOLIDAYDATE,'dd/mm/yyyy');
             commit;
                ------- DATA INSERT INTO ATTENDANCE TABLE ------------------
                lv_remarks := 'DATA TRANFER FROM HOLDIAY DATA TO ATTENDANCE';                
                lv_SqlStr := 'INSERT INTO WPSATTENDANCEDAYWISE( COMPANYCODE, DIVISIONCODE, YEARCODE, DATEOFATTENDANCE, '||CHR(10) 
                        ||' SHIFTCODE, DEPARTMENTCODE, SECTIONCODE, SERIALNO, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, OCCUPATIONCODE, '||CHR(10) 
                        ||' ATTENDANCEHOURS, HOLIDAYHOURS, OVERTIMEHOURS, MACHINECODE1, MACHINECODE2, BOOKNO,  '||CHR(10)
                        ||' LINENO, HELPERNO, SARDERNO, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERTYPECODE, ATTENDANCETAG, ISDAYOFF, SPELLTYPE,  '||CHR(10) 
                        ||' USERNAME, LASTMODIFIED, SYSROWID, UNITCODE)  '||CHR(10)
                        ||' SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, HOLIDAY,  '||CHR(10)  
                        ||' SHIFTCODE, DEPARTMENTCODE, SECTIONCODE, SERIALNO, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, OCCUPATIONCODE,  '||CHR(10) 
                        ||' ATTENDANCEHOURS, HOLIDAYHOURS, OVERTIMEHOURS, MACHINECODE1, MACHINECODE2, ''HD/''||TO_CHAR(HOLIDAY,''DDMMYYYY'')||''/''||SHIFTCODE||''/''||TOKENNO BOOKNO,  '||CHR(10) 
                        ||' LINENO, HELPERNO, SARDERNO, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERTYPECODE, ATTENDANCETAG, ISDAYOFF, ''SPELL 1'' SPELLTYPE,  '||CHR(10)
                        ||' USERNAME, LASTMODIFIED, ''HD/''||TO_CHAR(HOLIDAY,''DDMMYYYY'')||''/''||SHIFTCODE||''/''||TOKENNO SYSROWID, UNITCODE  '||CHR(10)
                        ||' FROM WPSHOLIDAYDATA  '||CHR(10)
                        ||' WHERE HOLIDAY = TO_DATE('''||p_HolidayDate||''',''DD/MM/YYYY'') '||CHR(10);                
                ------ NOW CHECK THE DUPLICATE WORKERSERIAL FOUND IN THE HOLIDAYDATE OR NOT? IF FOUND THEN DELETE ONE RECORD ----
                --dbms_output.put_line(lv_SqlStr);
                insert into WPS_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                values( p_CompCode, p_DivisionCode, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_FNStartDate,lv_FNEndDate, lv_remarks);
                COMMIT;
                execute immediate lv_SqlStr;
                commit;
                
                
            end if;     
                                    
            --if lv_ConsiderMasterOffDay ='Y'
            
    end CASE;
    COMMIT;
--EXCEPTION
--     WHEN OTHERS THEN
--    lv_sqlerrm := sqlerrm ;
--    insert into WPS_error_log(COMPANYCODE, DIVISIONCODE, PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
--    values( p_CompCode, p_DivisionCode, lv_ProcName,lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_FNStartDate,lv_FNEndDate, lv_remarks);     
--     COMMIT;           
        
end;
/


