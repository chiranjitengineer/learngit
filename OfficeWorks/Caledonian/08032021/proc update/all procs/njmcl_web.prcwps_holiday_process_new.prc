DROP PROCEDURE NJMCL_WEB.PRCWPS_HOLIDAY_PROCESS_NEW;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_HOLIDAY_PROCESS_NEW" ( p_CompCode varchar2, p_DivisionCode varchar2, p_YearCode varchar2, 
                                                          p_UserName varchar2, p_HolidayDate varchar2, lv_HolidayHours number,
                                                          p_LastWorkingDate varchar2, p_NextWorkingDt varchar2 default 'NONE',
                                                          p_DayOffType varchar2 default 'MASTER', p_DayOffDay varchar2 default 'NONE' 
                                                   )
as
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '';
lv_SqlStr               varchar2(10000):='';
lv_SqlStr1              varchar2(4000):='';
lv_Remarks              varchar2(1000) := '';
lv_SqlErrm              varchar2(500) := '';
lv_parvalues            varchar2(500) := '';   
lv_LastWorkingDay       varchar2(20) := TO_CHAR(TO_DATE(p_LastWorkingDate,'DD/MM/YYYY'),'DAY');
lv_NextWorkingDay       varchar2(20);
lv_NextWorkingDate      varchar2(10):='';
lv_BeforeLastWorkingDate date;      -- for day off consider last working date
lv_AfterNextWorkingDate date;       -- for day off consider after next working date
lv_Dayoffdaybothside VARCHAR2(1) :='';
lv_Dayoffdayeitherside VARCHAR2(1) :='';
lv_FNStartDate          date;
lv_FNEndDate            date;
lv_Cnt                  number:=0;

lv_ConsiderMasterOffDay varchar2(10);       --- use for Dayoff considet from worker master or not
lv_ConsiderBothSideWorking varchar2(10);     --- variable use for checking both side working
lv_ConsiderBothSideCondition varchar2(500) DEFAULT NULL;     --- variable use for checking both side working..conditional worker
lv_ConsiderEitherSideWorking varchar2(10);     --- variable use for checking either side working
lv_ConsiderEitherSideCondition varchar2(500) DEFAULT NULL;     --- variable use for checking both side working..conditional worker
lv_WorkerselectionCondition varchar2(500);

lv_HolidayType          varchar2(20):='';
lv_DayOffDay            varchar2(20);
lv_ConsiderNextWorking  varchar2(10);
lv_ConsiderMasterDayOff varchar2(10):= 'Y';     ---- variable consider for day off from master of user parameter
lv_UnionOrInersectSql   varchar2(20);      --- variable use for UNION or Intersect int the query accroing to commpany consider holiday for both side working or not

/*EXEC prcWPS_Holiday_Process('CJ0048','0003','2016-2017','SWT','01/05/2016','8','29/04/2016','02/05/2016','' ,'SUNDAY')*/
begin
    lv_result:='#SUCCESS#';
    lv_Remarks := 'HOLIDAY PROCESS';
    lv_parvalues := p_HolidayDate;
    lv_NextWorkingDate := p_NextWorkingDt;
    ------ Day off mainting from master or not
    if nvl(p_DayOffDay,'NONE') = 'NONE' then
        lv_ConsiderMasterDayOff := 'N';
    else
        lv_ConsiderMasterDayOff := 'Y';
    end if; 

    SELECT  DAYOFFCONSIDER_ATTN_IMPORT, 
            HOLIDAY_BOTHSIDE_WORKING ,HOLIDAY_BOTHSIDE_CONDITION,
            HOLIDAY_EITHERSIDE_WORKING,HOLIDAY_EITHERSIDE_CONDITION,
            DAYOFFDAY_BOTHSIDE_WORKING,DAYOFFDAY_EITHERSIDE_WORKING
      INTO lv_ConsiderMasterOffDay, 
           lv_ConsiderBothSideWorking,lv_ConsiderBothSideCondition,
           lv_ConsiderEitherSideWorking,lv_ConsiderEitherSideCondition,
           lv_Dayoffdaybothside,lv_Dayoffdayeitherside 
    FROM WPSWAGESPARAMETER;
    
    --- when next working data not required then we treat the last working date as next working data ------- 
    if (length(p_NextWorkingDt)<=0 or nvl(p_NextWorkingDt,'N') = 'N') THEN
        lv_NextWorkingDate := p_LastWorkingDate;
        lv_NextWorkingDay := lv_LastWorkingDay;
    else
        lv_NextWorkingDay := to_date(lv_NextWorkingDate,'dd/mm/yyyy');
    end if;
    --- variable initialize the before last working date and next working date 
    lv_BeforeLastWorkingDate := to_date(p_LastWorkingDate,'dd/mm/yyyy')-1;
    if  lv_NextWorkingDate = p_LastWorkingDate then
        lv_AfterNextWorkingDate := lv_BeforeLastWorkingDate;
    else
        lv_AfterNextWorkingDate := to_date(lv_NextWorkingDate,'dd/mm/yyyy')+1;
    end if;

---- when company not follow the next working date then we consider the next working is a last working date ----
--    if lv_NextWorkingDate = p_LastWorkingDate then
--        lv_AfterNextWorkingDate := to_date(p_LastWorkingDate,'dd/mm/yyyy')-1;
--    end if;

    select nvl(HOLIDAYTYPE,'GENERAL') INTO lv_HolidayType from WPSHOLIDAYMASTER 
    WHERE COMPANYCODE = p_CompCode AND DIVISIONCODE = p_DivisionCode 
      AND HOLIDAYDATE = TO_DATE(p_HolidayDate,'DD/MM/YYYY');
    
    
    SELECT FORTNIGHTSTARTDATE, FORTNIGHTENDDATE into lv_FNStartDate, lv_FNEndDate
    FROM WPSWAGEDPERIODDECLARATION WHERE COMPANYCODE = p_CompCode AND DIVISIONCODE = p_DivisionCode
     AND FORTNIGHTSTARTDATE <= TO_DATE(p_HolidayDate,'dd/mm/yyyy')
     AND FORTNIGHTENDDATE >= TO_DATE(p_HolidayDate,'dd/mm/yyyy') ;
     ----- chekcing for whage already process or not ----
    
    SELECT COUNT(*) into lv_Cnt FROM WPSWAGESDETAILS_MV  
    WHERE COMPANYCODE = p_CompCode AND DIVISIONCODE = p_DivisionCode 
    AND YEARCODE = p_YearCode 
    AND FORTNIGHTSTARTDATE = lv_FNStartDate
    AND FORTNIGHTENDDATE = lv_FNEndDate;
    
    if lv_Cnt > 0 then
        lv_error_remark := 'Validation Failure : [WAGES ALREADY PROCESS]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    
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
    
    lv_Cnt :=0;
    if nvl(lv_ConsiderBothSideWorking,'N') = 'Y' and nvl(lv_ConsiderEitherSideWorking,'N') ='Y' then
        lv_Cnt :=2;
        lv_UnionOrInersectSql := 'INTERSECT';
        IF lv_ConsiderBothSideCondition IS NOT NULL THEN
            lv_WorkerselectionCondition :=lv_ConsiderBothSideCondition;
        END IF;
    ELSif nvl(lv_ConsiderBothSideWorking,'N') = 'Y' then
        lv_Cnt :=1;
        lv_UnionOrInersectSql := 'INTERSECT';
        IF lv_ConsiderBothSideCondition IS NOT NULL THEN
            lv_WorkerselectionCondition :=lv_ConsiderBothSideCondition;
        END IF;
    elsif nvl(lv_ConsiderEitherSideWorking,'N') ='Y' then
        lv_Cnt :=1;
        lv_UnionOrInersectSql := 'UNION';
        IF lv_ConsiderBothSideCondition IS NOT NULL THEN
            lv_WorkerselectionCondition :=lv_ConsiderEitherSideCondition;
        END IF;
    end if; 
    
    
    Case lv_HolidayType
        when 'GENERAL' then
         for i in  1 .. lv_Cnt loop    
            if lv_Cnt=2 and i = 2 then
                if lv_UnionOrInersectSql = 'INTERSECT' then
                    lv_UnionOrInersectSql := 'UNION';
                else
                    lv_UnionOrInersectSql := 'INTERSECT';
                end if;
                
                if lv_WorkerselectionCondition = lv_ConsiderBothSideCondition then
                    lv_WorkerselectionCondition :=lv_ConsiderEitherSideCondition;
                else
                    lv_WorkerselectionCondition := lv_ConsiderBothSideCondition;
                end if;
            end if;
            ---- DATAA INSERT FOR THOSE WORKER WHO WORKED IN BOTH LATST WORKING DATE OR NEXT WORKING DATE , 
            ---- IN CASE WHO NOT MAINTAIN THE NEXT WORKING DATE THEN WE CONSIDER NEXT WORKING VAIRABLE VALUE SAME AS LAST WORKING DATE VALUE
                lv_SqlStr := ' INSERT INTO  WPSHOLIDAYDATA '||CHR(10) 
                        ||' (COMPANYCODE, DIVISIONCODE,YEARCODE, HOLIDAY, BEFOREHOLIDAYDATEBASEDON,AFTERHOLIDAYDATEBASEDON, '||CHR(10)
                        ||' GROUPCODE,SHIFTCODE, DEPARTMENTCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, OCCUPATIONCODE, '||CHR(10)  
                        ||' ATTENDANCEHOURS, HOLIDAYHOURS, OVERTIMEHOURS, OTHERHOURS, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERTYPECODE, ATTENDANCETAG, ISDAYOFF, USERNAME, SYSROWID, LASTMODIFIED, SERIALNO, UNITCODE) '||CHR(10) 
                        ||' SELECT A.COMPANYCODE, A.DIVISIONCODE,A.YEARCODE, TO_DATE('''||p_HolidayDate||''',''DD/MM/YYYY'') HOLIDAY,  A.DATEOFATTENDANCE BEFOREHOLIDAYDATEBASEDON,TO_DATE('''||lv_NextWorkingDate||''',''DD/MM/YYYY'') AFTERHOLIDAYDATEBASEDON, '||CHR(10)
                        ||' M.GROUPCODE, A.SHIFTCODE,A.DEPARTMENTCODE, A.WORKERSERIAL, A.TOKENNO, M.WORKERCATEGORYCODE, A.OCCUPATIONCODE, '||CHR(10) 
                        ||' 0 ATTENDANCEHOURS, '||lv_HolidayHours||' HOLIDAYHOURS, 0 OVERTIMEHOURS, 0 OTHERHOURS, '''||lv_FNStartDate||''' AS FORTNIGHTSTARTDATE, '''||lv_FNEndDate||''' AS FORTNIGHTENDDATE, '||CHR(10)  
                        ||' B.WORKERTYPECODE, ''HD'' ATTENDANCETAG, ''N'' ISDAYOFF, '''||p_UserName||''', 1 AS SYSROWID, SYSDATE LASTMODIFIED, 1 AS SERIALNO, A.UNITCODE'||CHR(10)
                        ||' FROM WPSATTENDANCEDAYWISE A, WPSOCCUPATIONMAST B, WPSWORKERMAST M, '||CHR(10) 
                        ||' ( '||CHR(10);
                        IF lv_UnionOrInersectSql = 'UNION' THEN
                            lv_SqlStr := lv_SqlStr || 'SELECT A.WORKERSERIAL, MIN(DATEOFATTENDANCE) DATEOFATTENDANCE FROM ' ||CHR(10);
                        ELSE
                            lv_SqlStr := lv_SqlStr ||'     SELECT DISTINCT WORKERSERIAL FROM '||CHR(10);
                        END IF;
                        lv_SqlStr := lv_SqlStr ||'      ( '||CHR(10) 
                        ||'         SELECT WORKERSERIAL  FROM WPSATTENDANCEDAYWISE A '||CHR(10)
                        ||'         WHERE A.COMPANYCODE = '''||p_CompCode||''' AND A.DIVISIONCODE = '''||p_DivisionCode||'''  '||CHR(10) 
                        ||'           AND A.YEARCODE = '''||p_YearCode||'''         '||CHR(10) 
                        ||'           AND A.DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') '||CHR(10)
                            --IF lv_ConsiderBothSideCondition IS NOT NULL THEN
                        ||'          '||lv_WorkerselectionCondition||' '||CHR(10); 
                            --END IF;
                        lv_SqlStr := lv_SqlStr ||'         GROUP BY WORKERSERIAL '||CHR(10)
                        ||'         HAVING SUM((NVL(A.ATTENDANCEHOURS,0)+NVL(A.NIGHTALLOWANCEHOURS,0))) >= 8 '||CHR(10)
                        ||'         '||lv_UnionOrInersectSql||' '||CHR(10)                  -- UNION 
                        ||'         SELECT WORKERSERIAL  FROM WPSATTENDANCEDAYWISE A '||CHR(10)
                        ||'         WHERE A.COMPANYCODE = '''||p_CompCode||''' AND A.DIVISIONCODE = '''||p_DivisionCode||''' '||CHR(10) 
                        ||'           AND A.YEARCODE = '''||p_YearCode||'''         '||CHR(10) 
                        ||'           AND A.DATEOFATTENDANCE = TO_DATE('''||lv_NextWorkingDate||''',''DD/MM/YYYY'') '||CHR(10)
                            --IF lv_ConsiderBothSideCondition IS NOT NULL THEN
                        ||'          '||lv_WorkerselectionCondition||' '||CHR(10); ---------- SELECTED WORKER
                            --END IF;
                        lv_SqlStr := lv_SqlStr ||'         GROUP BY WORKERSERIAL '||CHR(10)
                        ||'         HAVING SUM((NVL(A.ATTENDANCEHOURS,0)+NVL(A.NIGHTALLOWANCEHOURS,0))) >= 8 '||CHR(10)
                        ||'      )'||CHR(10); 
                        IF lv_UnionOrInersectSql = 'UNION'  THEN
                            lv_SqlStr := lv_SqlStr ||'       A, WPSATTENDANCEDAYWISE B '||CHR(10)
                                    ||'        WHERE A.WORKERSERIAL= B.WORKERSERIAL  '||CHR(10)
                                    ||'         AND B.DATEOFATTENDANCE IN (TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY''), TO_DATE('''||lv_NextWorkingDate||''',''DD/MM/YYYY'')) '||CHR(10)   
                                    ||'         GROUP BY A.WORKERSERIAL '||CHR(10);
                        END IF;
                        lv_SqlStr := lv_SqlStr ||' ) C,        '||CHR(10)
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
                        ||'   AND A.YEARCODE = '''||p_YearCode||'''   '||CHR(10);
                        
                        IF lv_UnionOrInersectSql = 'UNION'  THEN
                            lv_SqlStr := lv_SqlStr ||' AND ( A.DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') OR A.DATEOFATTENDANCE = TO_DATE('''||lv_NextWorkingDate||''',''DD/MM/YYYY'')) '||CHR(10);
                        ELSE
                            lv_SqlStr := lv_SqlStr ||'   AND A.DATEOFATTENDANCE =TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') '||CHR(10);
                        END IF; 
                        lv_SqlStr := lv_SqlStr ||'   AND A.SPELLTYPE = ''SPELL 1'' '||CHR(10)
                        ||'   AND (NVL(A.ATTENDANCEHOURS,0)+NVL(A.NIGHTALLOWANCEHOURS,0)) <> 0 '||CHR(10) 
                        ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10) 
                        ||'   AND A.DEPARTMENTCODE = B.DEPARTMENTCODE AND A.OCCUPATIONCODE = B.OCCUPATIONCODE '||CHR(10);
                       
                         IF lv_UnionOrInersectSql = 'UNION'  THEN
                            lv_SqlStr := lv_SqlStr ||' AND A.WORKERSERIAL = C.WORKERSERIAL AND A.DATEOFATTENDANCE = C.DATEOFATTENDANCE '||CHR(10); 
                        ELSE
                            lv_SqlStr := lv_SqlStr ||'   AND A.WORKERSERIAL = C.WORKERSERIAL '||CHR(10);
                        END IF; 
                        
                        lv_SqlStr := lv_SqlStr ||'   AND A.WORKERSERIAL = M.WORKERSERIAL '||CHR(10) 
                        ||'   AND M.WORKERCATEGORYCODE = E.WORKERCATEGORYCODE '||CHR(10);
                dbms_output.put_line (lv_SqlStr);                    
                insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
                     values( 'prcWPS_Holiday_Process',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_FNStartDate,lv_FNEndDate, lv_remarks);
                commit;
                execute immediate lv_SqlStr;
                commit;
                --dbms_output.put_line ('phase 1 complete');
                --dbms_output.put_line ('CONSIDER MASTER OFF DAY '||lv_ConsiderMasterOffDay);
           end loop;            
      
         for i in  1 .. lv_Cnt loop      
           if lv_Cnt=2 and i = 2 then
                if lv_UnionOrInersectSql = 'INTERSECT' then
                    lv_UnionOrInersectSql := 'UNION';
                else
                    lv_UnionOrInersectSql := 'INTERSECT';
                end if;
                    
                if lv_WorkerselectionCondition = lv_ConsiderBothSideCondition then
                    lv_WorkerselectionCondition :=lv_ConsiderEitherSideCondition;
                else
                    lv_WorkerselectionCondition := lv_ConsiderBothSideCondition;
                end if;
            end if;
            ---- NOW CONSIDER DAY OF ON LAST WORKING DATE --- WORKER SHOULD WORKED ON DAY BEFORE LAST WORKING DATE ----
            ---- DATA INSERT FOR THOSE WORKER WHO NOT WORKED IN BOTH LAST WORKING DATE OR NEXT WORKING DATE , DUE TO OFF DAY
            ---- OFFDAY MAY BE MILL OFF DAY OR AS PER WORKERMAST
            ---- IN CASE WHO NOT MAINTAIN THE NEXT WORKING DATE THEN WE CONSIDER NEXT WORKING VAIRABLE VALUE SAME AS LAST WORKING DATE VALUE
            lv_SqlStr := ' INSERT INTO  WPSHOLIDAYDATA '||CHR(10) 
                    ||' (COMPANYCODE, DIVISIONCODE,YEARCODE, HOLIDAY, BEFOREHOLIDAYDATEBASEDON,AFTERHOLIDAYDATEBASEDON, '||CHR(10)
                    ||' GROUPCODE,SHIFTCODE, DEPARTMENTCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, OCCUPATIONCODE, '||CHR(10)  
                    ||' ATTENDANCEHOURS, HOLIDAYHOURS, OVERTIMEHOURS, OTHERHOURS, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERTYPECODE, ATTENDANCETAG, ISDAYOFF, USERNAME, SYSROWID, LASTMODIFIED, SERIALNO, UNITCODE) '||CHR(10) 
                    ||' SELECT A.COMPANYCODE, A.DIVISIONCODE,A.YEARCODE, TO_DATE('''||p_HolidayDate||''',''DD/MM/YYYY'') HOLIDAY,  A.DATEOFATTENDANCE BEFOREHOLIDAYDATEBASEDON,TO_DATE('''||lv_NextWorkingDate||''',''DD/MM/YYYY'') AFTERHOLIDAYDATEBASEDON, '||CHR(10)
                    ||' M.GROUPCODE, A.SHIFTCODE,A.DEPARTMENTCODE, A.WORKERSERIAL, A.TOKENNO, M.WORKERCATEGORYCODE, A.OCCUPATIONCODE, '||CHR(10) 
                    ||' 0 ATTENDANCEHOURS, '||lv_HolidayHours||' HOLIDAYHOURS, 0 OVERTIMEHOURS, 0 OTHERHOURS, '''||lv_FNStartDate||''' AS FORTNIGHTSTARTDATE, '''||lv_FNEndDate||''' AS FORTNIGHTENDDATE, '||CHR(10)  
                    ||' B.WORKERTYPECODE, ''HD'' ATTENDANCETAG, ''N'' ISDAYOFF, '''||p_UserName||''', 1 AS SYSROWID, SYSDATE LASTMODIFIED, 1 AS SERIALNO, A.UNITCODE'||CHR(10)
                    ||' FROM WPSATTENDANCEDAYWISE A, WPSOCCUPATIONMAST B, WPSWORKERMAST M, '||CHR(10) 
                    ||' ( '||CHR(10);
                        IF lv_UnionOrInersectSql = 'UNION' THEN
                            lv_SqlStr := lv_SqlStr || 'SELECT A.WORKERSERIAL, MIN(DATEOFATTENDANCE) DATEOFATTENDANCE FROM' ||CHR(10);
                        ELSE
                            lv_SqlStr := lv_SqlStr ||'     SELECT DISTINCT WORKERSERIAL FROM '||CHR(10);
                        END IF;
                    lv_SqlStr := lv_SqlStr ||'      ( '||CHR(10) 
                    ||'         SELECT WORKERSERIAL  FROM WPSATTENDANCEDAYWISE A '||CHR(10)
                    ||'         WHERE A.COMPANYCODE = '''||p_CompCode||''' AND A.DIVISIONCODE = '''||p_DivisionCode||'''  '||CHR(10) 
                    ||'           AND A.YEARCODE = '''||p_YearCode||'''         '||CHR(10);
                    --dbms_output.put_line ('p_DayOffDay p_LastWorkingDateDAY '||p_DayOffDay||'  '||TO_CHAR(TO_DATE(p_LastWorkingDate,'''DD/MM/YYYY''')+1,'''DAY'''));

                    IF p_DayOffDay = 'NONE' THEN
                        lv_SqlStr := lv_SqlStr ||'        AND A.DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') -1  '||CHR(10);         
                        lv_SqlStr := lv_SqlStr ||'        AND A.WORKERSERIAL IN(SELECT WORKERSERIAL FROM WPSWORKERMAST WHERE DAYOFFDAY='''||lv_LastWorkingDay||''') '||CHR(10); 
                    ELSif TO_CHAR(TO_DATE(p_LastWorkingDate,'DD/MM/YYYY')-1,'DAY') = p_DayOffDay THEN
                        lv_SqlStr := lv_SqlStr||'         AND A.DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') -2 '||CHR(10);
                    ELSE
                        lv_SqlStr := lv_SqlStr||'         AND 1=2'||CHR(10);                                
                    END IF;
                    
                    IF lv_ConsiderBothSideCondition IS NOT NULL THEN
                        lv_SqlStr := lv_SqlStr ||'          '||lv_ConsiderBothSideCondition||' '||CHR(10); ---------- SELECTED WORKER
                    END IF;
                    
                    lv_SqlStr := lv_SqlStr ||'         GROUP BY WORKERSERIAL '||CHR(10)
                    ||'         HAVING SUM((NVL(A.ATTENDANCEHOURS,0)+NVL(A.NIGHTALLOWANCEHOURS,0))) >= 8 '||CHR(10)
                    ||'         '||lv_UnionOrInersectSql||' '||CHR(10)                  -- UNION 
                    ||'         SELECT WORKERSERIAL  FROM WPSATTENDANCEDAYWISE A '||CHR(10)
                    ||'          WHERE A.COMPANYCODE = '''||p_CompCode||''' AND A.DIVISIONCODE = '''||p_DivisionCode||''' '||CHR(10) 
                    ||'            AND A.YEARCODE = '''||p_YearCode||'''         '||CHR(10) ;
                    
                    IF p_DayOffDay = 'NONE' THEN
                        lv_SqlStr := lv_SqlStr ||'       AND A.DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') +1 '||CHR(10);         
                        lv_SqlStr := lv_SqlStr ||'       AND A.WORKERSERIAL IN(SELECT WORKERSERIAL FROM WPSWORKERMAST WHERE DAYOFFDAY='''||lv_LastWorkingDay||''') '||CHR(10); ---------- SELECTED WORKER
                    ELSIF TO_CHAR(TO_DATE(p_LastWorkingDate,'DD/MM/YYYY')+1,'DAY') = p_DayOffDay THEN
                        lv_SqlStr := lv_SqlStr||'             AND A.DATEOFATTENDANCE = TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') +2 '||CHR(10);
                     ELSE
                        lv_SqlStr := lv_SqlStr||'         AND 1=2'||CHR(10);                                
                    END IF;
                    
                    IF lv_ConsiderBothSideCondition IS NOT NULL THEN
                        lv_SqlStr := lv_SqlStr ||'          '||lv_ConsiderBothSideCondition||' '||CHR(10); ---------- SELECTED WORKER
                    END IF;
                    lv_SqlStr := lv_SqlStr ||'         GROUP BY WORKERSERIAL '||CHR(10)
                    ||'         HAVING SUM((NVL(A.ATTENDANCEHOURS,0)+NVL(A.NIGHTALLOWANCEHOURS,0))) >= 8 '||CHR(10)
                    ||'      )'||CHR(10) ;
                    
                    IF lv_UnionOrInersectSql = 'UNION'  THEN
                        lv_SqlStr := lv_SqlStr ||'       A, WPSATTENDANCEDAYWISE B '||CHR(10)
                                               ||'       WHERE A.WORKERSERIAL= B.WORKERSERIAL  '||CHR(10);
                                               
                        IF p_DayOffDay = 'NONE' THEN
                            lv_SqlStr := lv_SqlStr ||'        AND B.DATEOFATTENDANCE IN ( TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') -1,TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') +1 )'||CHR(10)         
                                                   ||'       AND A.WORKERSERIAL IN(SELECT WORKERSERIAL FROM WPSWORKERMAST WHERE DAYOFFDAY='''||lv_LastWorkingDay||''') '||CHR(10);        
                        ELSif TO_CHAR(TO_DATE(p_LastWorkingDate,'DD/MM/YYYY')-1,'DAY') = p_DayOffDay THEN
                            lv_SqlStr := lv_SqlStr||'         AND B.DATEOFATTENDANCE IN ( TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') -2 , '
                                                  ||'        ,TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') +2 ) '||CHR(10);
                        ELSE
                            lv_SqlStr := lv_SqlStr||'         AND 1=2'||CHR(10);
                        END IF;
                        lv_SqlStr := lv_SqlStr ||'         GROUP BY A.WORKERSERIAL '||CHR(10);
                     END IF;
                    
                    lv_SqlStr := lv_SqlStr ||' ) C,        '||CHR(10)
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
                    ||'   AND A.YEARCODE = '''||p_YearCode||'''   '||CHR(10); 
                  IF lv_UnionOrInersectSql = 'UNION'  THEN  
                           IF p_DayOffDay = 'NONE' THEN
                                lv_SqlStr := lv_SqlStr ||'       AND A.DATEOFATTENDANCE IN ( TO_DATE('''||lv_NextWorkingDate||''',''DD/MM/YYYY'') +1 '
                                                       ||'                                  , TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') +1 )'||CHR(10)         
                                                       ||'       AND A.WORKERSERIAL IN(SELECT WORKERSERIAL FROM WPSWORKERMAST WHERE DAYOFFDAY='''||lv_LastWorkingDay||''') '||CHR(10); 
                            ELSif TO_CHAR(TO_DATE(p_LastWorkingDate,'DD/MM/YYYY')+1,'DAY') = p_DayOffDay THEN
                                lv_SqlStr := lv_SqlStr||'        AND A.DATEOFATTENDANCE in ( TO_DATE('''||lv_NextWorkingDate||''',''DD/MM/YYYY'') +2 '
                                                      ||'        ,TO_DATE('''||p_LastWorkingDate||''',''DD/MM/YYYY'') +2 ) '||CHR(10);
                            ELSE
                                lv_SqlStr := lv_SqlStr||'         AND 1=2'||CHR(10);                                
                            END IF;
                  END IF;                             
                    lv_SqlStr := lv_SqlStr||'   AND A.SPELLTYPE = ''SPELL 1'' '||CHR(10)
                    ||'   AND (NVL(A.ATTENDANCEHOURS,0)+NVL(A.NIGHTALLOWANCEHOURS,0)) <> 0 '||CHR(10) 
                    ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10) 
                    ||'   AND A.DEPARTMENTCODE = B.DEPARTMENTCODE AND A.OCCUPATIONCODE = B.OCCUPATIONCODE '||CHR(10) 
                    ||'   AND A.WORKERSERIAL = C.WORKERSERIAL '||CHR(10) 
                    ||'   AND A.WORKERSERIAL = M.WORKERSERIAL '||CHR(10) 
                    ||'   AND M.WORKERCATEGORYCODE = E.WORKERCATEGORYCODE '||CHR(10);
                --dbms_output.put_line (lv_SqlStr);
                insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'prcWPS_Holiday_Process',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_FNStartDate,lv_FNEndDate, lv_remarks);
                COMMIT;
                execute immediate lv_SqlStr;
                commit;
         end loop;
         
          DELETE FROM WPSHOLIDAYDATA AA
          WHERE ROWID < ( SELECT MAX(ROWID) FROM WPSHOLIDAYDATA BB
                           WHERE AA.WORKERSERIAL = BB.WORKERSERIAL
                           AND AA.HOLIDAY=BB.HOLIDAY)
            AND HOLIDAY=TO_DATE(P_HOLIDAYDATE,'dd/mm/yyyy');
         commit;
        ------- DATA INSERT INTO ATTENDANCE TABLE ------------------
        lv_remarks := 'DATA TRANFER FROM HOLDIAY DATA TO ATTENDANCE';                
        lv_SqlStr := 'INSERT INTO WPSATTENDANCEDAYWISE( COMPANYCODE, DIVISIONCODE, YEARCODE, DATEOFATTENDANCE, '||CHR(10) 
                ||' SHIFTCODE, DEPARTMENTCODE, SERIALNO, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, OCCUPATIONCODE, '||CHR(10) 
                ||' ATTENDANCEHOURS, HOLIDAYHOURS, OVERTIMEHOURS, MACHINECODE1, MACHINECODE2, BOOKNO,  '||CHR(10)
                ||' LOOMCODE, HELPERNO, SARDERNO, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERTYPECODE, ATTENDANCETAG, ISDAYOFF, SPELLTYPE,  '||CHR(10) 
                ||' USERNAME, LASTMODIFIED, SYSROWID, UNITCODE)  '||CHR(10)
                ||' SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, HOLIDAY,  '||CHR(10)  
                ||' SHIFTCODE, DEPARTMENTCODE, SERIALNO, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, OCCUPATIONCODE,  '||CHR(10) 
                ||' ATTENDANCEHOURS, HOLIDAYHOURS, OVERTIMEHOURS, MACHINECODE1, MACHINECODE2, ''HD/''||TO_CHAR(HOLIDAY,''DDMMYYYY'')||''/''||SHIFTCODE||''/''||TOKENNO BOOKNO,  '||CHR(10) 
                ||' LINENO, HELPERNO, SARDERNO, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, WORKERTYPECODE, ATTENDANCETAG, ISDAYOFF, ''SPELL 1'' SPELLTYPE,  '||CHR(10)
                ||' USERNAME, LASTMODIFIED, ''HD/''||TO_CHAR(HOLIDAY,''DDMMYYYY'')||''/''||SHIFTCODE||''/''||TOKENNO SYSROWID, UNITCODE  '||CHR(10)
                ||' FROM WPSHOLIDAYDATA  '||CHR(10)
                ||' WHERE HOLIDAY = TO_DATE('''||p_HolidayDate||''',''DD/MM/YYYY'') '||CHR(10);                
        ------ NOW CHECK THE DUPLICATE WORKERSERIAL FOUND IN THE HOLIDAYDATE OR NOT? IF FOUND THEN DELETE ONE RECORD ----
        insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'prcWPS_Holiday_Process',lv_sqlerrm,lv_SqlStr,lv_parvalues,lv_FNStartDate,lv_FNEndDate, lv_remarks);
        COMMIT;
        execute immediate lv_SqlStr;
        commit;
            --if lv_ConsiderMasterOffDay ='Y'
    end CASE;
    
        
end;
/


