CREATE OR REPLACE procedure BAGGAGE_WEB.prcArrear_Bf_MainSave
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PISPROCESS%rowtype;
lv_DocumentNo           varchar2(100) := '';
lv_MaxDocumentDate      date;

begin
    lv_result:='#SUCCESS#';
    
    
    
    --Master
    select count(*)
    into lv_cnt
    from GBL_PISPROCESS;
   
   
--   dbms_output.put_line('lv_cnt ' || lv_cnt);
    
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in Salary Process Entry.]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
--   return;
   
--DELETE PISARREAR_TEMP;

--INSERT INTO PISARREAR_TEMP
--SELECT * FROM GBL_PISPROCESS;   


    
    select *
    into lv_Master
    from GBL_PISPROCESS
    WHERE ROWNUM<=1;   

-----------------------  Auto Number

    if nvl(lv_Master.OPERATIONMODE,'NA') = 'A' then
--        PRC_PIS_SALARY_PROCESS( lv_Master.COMPANYCODE,
--                                lv_Master.DIVISIONCODE, 
--                                'ARREAR', 
--                                lv_Master.USERNAME,
--                                lv_Master.YEARMONTH, 
--                                lv_Master.YEARMONTH,
--                                lv_Master.UNITCODE,
--                                lv_Master.CATEGORYCODE,
--                                lv_Master.GRADECODE,
--                                '',
--                                lv_Master.WORKERSERIAL                                           
--                              );


    FOR C1 IN (
        SELECT DISTINCT TO_CHAR(LAST_DAY((TD.END_DATE + 1 - ROWNUM)),'YYYYMM') YRMONTH
        FROM ALL_OBJECTS,
        (
--            SELECT TO_DATE('201904','YYYYMM') START_DATE, TO_DATE('202009','YYYYMM') END_DATE
            SELECT TO_DATE(lv_Master.ARREARFROM,'YYYYMM') START_DATE, TO_DATE(lv_Master.ARREARTO,'YYYYMM') END_DATE
            FROM   DUAL  
        ) TD
        WHERE
        TRUNC ( TD.END_DATE + 1 - ROWNUM,'MM') >= TRUNC(TD.START_DATE,'MM')
        ORDER BY 1
    )
    LOOP
    
        PRC_PIS_SALARY_PROCESS( lv_Master.COMPANYCODE,
                                lv_Master.DIVISIONCODE, 
                                'ARREAR', 
                                lv_Master.USERNAME,
                                C1.YRMONTH, 
                                lv_Master.YEARMONTH,
                                lv_Master.UNITCODE,
                                lv_Master.CATEGORYCODE,
                                lv_Master.GRADECODE,
                                '',
                                lv_Master.WORKERSERIAL                                           
                              );
                              
         dbms_output.put_line('PRC_PIS_SALARY_PROCESS( '''||lv_Master.COMPANYCODE||''','''||lv_Master.DIVISIONCODE||''', ''ARREAR'','''||lv_Master.USERNAME||''','''||C1.YRMONTH||''','''||lv_Master.YEARMONTH||''','''||lv_Master.UNITCODE||''','''||lv_Master.CATEGORYCODE||''','''||lv_Master.GRADECODE||''','''||''''','''|| lv_Master.WORKERSERIAL ||''' )');
                              
   
   --dbms_output.put_line('PRC_PIS_SALARY_PROCESS('||||')' || lv_cnt);                           

    END LOOP;

--    PRC_PISSALARYPROCESS_ARREAR('JT0069','0001','ARREAR', '1002','201909','201909','PISARREARTRANSACTION','PISARREARTRANSACTION','HO','HO','MANAGERIAL','','');
    PRC_PISSALARYPROCESS_ARREAR(lv_Master.COMPANYCODE,lv_Master.DIVISIONCODE,'ARREAR', '1002',
                                lv_Master.ARREARFROM,lv_Master.ARREARTO,lv_Master.YEARMONTH,
                                'PISARREARTRANSACTION','PISARREARTRANSACTION',lv_Master.UNITCODE,lv_Master.CATEGORYCODE,lv_Master.GRADECODE,'',lv_Master.WORKERSERIAL);

    end if;
end;
/
