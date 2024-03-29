CREATE OR REPLACE PROCEDURE FORTWILLIAM_WPS.PRCWPS_WAGES_PROCESS(P_PROCESSTYPE varchar2, P_COMPCODE varchar2, P_DIVCODE varchar2, P_YEARCODE varchar2,
                                                  P_USERNAME VARCHAR2,   
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_WORKKERSERIAL VARCHAR2 DEFAULT NULL)
as
lv_SqlStr VARCHAR2(4000) := '';
lv_result VARCHAR2(1000);
lv_error_remark         varchar2(4000) := '' ;
lv_Cnt number(10);
begin
    lv_result:='#SUCCESS#';
    
    DELETE FROM WPS_ERROR_LOG;
    COMMIT;
    
    
    for cur_proc_params in( select COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3 
                            from WPSWAGESPROCESSTYPE_PHASE  
                            where COMPANYCODE = P_COMPCODE and DIVISIONCODE = P_DIVCODE
                              and PROCESSTYPE = P_PROCESSTYPE
                            ORDER BY PHASE, CALCULATIONINDEX
                          )     
    loop
        lv_SqlStr := cur_proc_params.PROCEDURE_NAME||'('''||P_COMPCODE||''','''||P_DIVCODE||''','''||P_YEARCODE||''','''||P_FNSTDT||''','''||P_FNENDT||''','''||cur_proc_params.PHASE||''','''||cur_proc_params.PARAM_1||''','''||cur_proc_params.PARAM_2||''','''||REPLACE(P_WORKKERSERIAL,'''','''''')||''','''||P_PROCESSTYPE||''')' ;
        --lv_SqlStr := cur_proc_params.PROCEDURE_NAME||'('''||P_COMPCODE||''','''||P_DIVCODE||''','''||P_YEARCODE||''','''||P_FNSTDT||''','''||P_FNENDT||''','''||cur_proc_params.PHASE||''','''||cur_proc_params.PARAM_1||''','''||cur_proc_params.PARAM_2||''','''||P_WORKKERSERIAL||''')' ;
        dbms_output.put_line(lv_sqlstr);
        execute immediate 'BEGIN '||lv_SqlStr||'; END ;';
        
        

        ------ ERROR CHECING IN WAGES PROCESS -----
        SELECT count(*) into lv_Cnt from WPS_ERROR_LOG
        WHERE 1=1 --COMPANYCODE =P_COMPCODE AND DIVISIONCODE=P_DIVCODE
          AND ORA_ERROR_MESSG IS NOT NULL;
        if lv_Cnt > 0 then
            lv_result:='Error found in Wages Process... Contact SWT Adminsitrator...';
            lv_error_remark :='Error found in Wages Process... Contact SWT Adminsitrator...';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            return;
        end if;  
        
        
        
    end loop;
--exception
--when others then
--    lv_error_remark := sqlerrm;
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    --dbms_output.put_line(sqlerrm);
end;
/
