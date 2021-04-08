CREATE OR REPLACE procedure GLOSTER_WEB.prcSalary_Bf_MainSave
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
   
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in Salary Process Entry]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    select *
    into lv_Master
    from GBL_PISPROCESS
    WHERE ROWNUM<=1;   
    
    --ADDED ON 01/04/2021
    UPDATE PISEMPLOYEEMASTER SET EPFAPPLICABLE = 'N'
    WHERE WORKERSERIAL IN 
    (
        SELECT WORKERSERIAL FROM(
            SELECT TOKENNO,WORKERSERIAL,(ADD_MONTHS(DATEOFBIRTH,58*12)) DTRETIRE, LAST_DAY(TO_DATE(LV_MASTER.YEARMONTH,'YYYYMM')) DT_TODATE FROM PISEMPLOYEEMASTER
        )
        WHERE DTRETIRE < DT_TODATE
    );
    --ADDED ON 01/04/2021


-----------------------  Auto Number

    if nvl(lv_Master.OPERATIONMODE,'NA') = 'A' then
        PRC_PIS_SALARY_PROCESS( lv_Master.COMPANYCODE,
                                lv_Master.DIVISIONCODE, 
                                'SALARY', 
                                lv_Master.USERNAME,
                                lv_Master.YEARMONTH, 
                                lv_Master.YEARMONTH,
                                lv_Master.UNITCODE,
                                lv_Master.CATEGORYCODE,
                                lv_Master.GRADECODE,
                                '',
                                lv_Master.WORKERSERIAL                                           
                              );
    end if;
end;
/
