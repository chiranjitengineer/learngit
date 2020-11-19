CREATE OR REPLACE PROCEDURE KARNAFULI.PRCGPS_WAGES_PROCESS(P_PROCESSTYPE varchar2, P_COMPCODE varchar2, P_DIVCODE varchar2, P_YEARCODE varchar2,
                                                  P_USERNAME VARCHAR2,   
                                                  P_FNSTDT Varchar2, 
                                                  P_FNENDT Varchar2,
                                                  P_CATEGORYTYPE    VARCHAR2 DEFAULT NULL,
                                                  P_CATEGORYCODE VARCHAR2 DEFAULT NULL,
                                                  P_WORKKERSERIAL VARCHAR2 DEFAULT NULL,
                                                  P_PROCESSBASED_ON VARCHAR2 DEFAULT NULL)
as
lv_SqlStr VARCHAR2(4000) := '';
lv_result VARCHAR2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Category     varchar2(50) := '';
begin
    lv_result:='#SUCCESS#';
    lv_Category := null;    --P_CATEGORYCODE
    IF P_PROCESSTYPE = 'DAILY' THEN ---- for daily process multiple day process at a time 
        FOR cDate in (  SELECT TO_CHAR(TO_DATE(P_FNSTDT,'DD/MM/YYYY') + ROWNUM -1,'DD/MM/YYYY') DAILYDATE
                        FROM ALL_OBJECTS
                        WHERE ROWNUM <= TO_DATE(P_FNENDT,'DD/MM/YYYY')-TO_DATE(P_FNSTDT,'DD/MM/YYYY')+1
                     )
        loop
            for C1 in( select COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3 
                                    from WAGESPROCESSTYPE_PHASE  
                                    where COMPANYCODE = P_COMPCODE and DIVISIONCODE = P_DIVCODE
                                      and PROCESSTYPE = P_PROCESSTYPE
                                    ORDER BY PHASE, CALCULATIONINDEX
                                  )     
            loop
--                lv_SqlStr := C1.PROCEDURE_NAME||'('''||P_COMPCODE||''','''||P_DIVCODE||''','''||C1.PROCESSTYPE||''','''||P_YEARCODE||''','''||cDate.DAILYDATE||''','''||cDate.DAILYDATE||''','''||cDate.DAILYDATE||''','''||C1.PHASE||''','''||C1.PARAM_1||''','''||C1.PARAM_2||''','''||P_USERNAME||''','''||P_CATEGORYTYPE||''','''||P_CATEGORYCODE||''','''||P_WORKKERSERIAL||''')' ;
                lv_SqlStr := C1.PROCEDURE_NAME||'('''||P_COMPCODE||''','''||P_DIVCODE||''','''||C1.PROCESSTYPE||''','''||P_YEARCODE||''','''||cDate.DAILYDATE||''','''||cDate.DAILYDATE||''','''||cDate.DAILYDATE||''','''||C1.PHASE||''','''||C1.PARAM_1||''','''||C1.PARAM_2||''','''||P_USERNAME||''','''||P_CATEGORYTYPE||''','''||lv_Category||''','''||P_WORKKERSERIAL||''')' ;
                dbms_output.put_line(lv_sqlstr);
                execute immediate 'BEGIN '||lv_SqlStr||'; END ;';
            end loop;
        
        end loop;                        
    ELSIF P_PROCESSTYPE = 'ARREAR' THEN
       FOR cDate in (  SELECT TO_CHAR(TO_DATE(P_FNSTDT,'DD/MM/YYYY') + ROWNUM -1,'DD/MM/YYYY') DAILYDATE
                        FROM ALL_OBJECTS
                        WHERE ROWNUM <= TO_DATE(P_FNENDT,'DD/MM/YYYY')-TO_DATE(P_FNSTDT,'DD/MM/YYYY')+1
                     )
        loop
            for C1 in( select COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3 
                                    from WAGESPROCESSTYPE_PHASE  
                                    where COMPANYCODE = P_COMPCODE and DIVISIONCODE = P_DIVCODE
                                      and PROCESSTYPE = P_PROCESSTYPE
                                    ORDER BY PHASE, CALCULATIONINDEX
                                  )     
            loop
--                lv_SqlStr := C1.PROCEDURE_NAME||'('''||P_COMPCODE||''','''||P_DIVCODE||''','''||C1.PROCESSTYPE||''','''||P_YEARCODE||''','''||cDate.DAILYDATE||''','''||cDate.DAILYDATE||''','''||cDate.DAILYDATE||''','''||C1.PHASE||''','''||C1.PARAM_1||''','''||C1.PARAM_2||''','''||P_USERNAME||''','''||P_CATEGORYTYPE||''','''||P_CATEGORYCODE||''','''||P_WORKKERSERIAL||''')' ;
                lv_SqlStr := C1.PROCEDURE_NAME||'('''||P_COMPCODE||''','''||P_DIVCODE||''','''||C1.PROCESSTYPE||''','''||P_YEARCODE||''','''||cDate.DAILYDATE||''','''||cDate.DAILYDATE||''','''||cDate.DAILYDATE||''','''||C1.PHASE||''','''||C1.PARAM_1||''','''||C1.PARAM_2||''','''||P_USERNAME||''','''||P_CATEGORYTYPE||''','''||lv_Category||''','''||P_WORKKERSERIAL||''')' ;
                dbms_output.put_line(lv_sqlstr);
                execute immediate 'BEGIN '||lv_SqlStr||'; END ;';
            end loop;
        
        end loop;  
        
--        PROC_GPSWAGESPROCESS_ARREAR('BDBR01','0002','ARREAR','2020-2021','20/10/2020','30/10/2020','30/10/2020','100','GPSDAILYPAYSHEETDETAILS_SWT','GPSARREARDAILYPAYSHEETDETAILS','','WORKER','','')
        PROC_GPSWAGESPROCESS_ARREAR(P_COMPCODE,P_DIVCODE,'ARREAR',P_YEARCODE,P_FNSTDT,P_FNENDT,P_FNENDT,'100','GPSDAILYPAYSHEETDETAILS_SWT','GPSARREARDAILYPAYSHEETDETAILS',P_USERNAME,P_CATEGORYTYPE,P_CATEGORYCODE,P_WORKKERSERIAL);

                             
    ELSIF P_PROCESSTYPE = 'WAGES PROCESS' THEN
        for C1 in( select COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3 
                                from WAGESPROCESSTYPE_PHASE  
                                where COMPANYCODE = P_COMPCODE and DIVISIONCODE = P_DIVCODE
                                  and PROCESSTYPE = P_PROCESSTYPE
                                  AND PARAM_3 = NVL(P_PROCESSBASED_ON,'DAILY')
                                ORDER BY PHASE, CALCULATIONINDEX
                              )     
        loop
--                lv_SqlStr := C1.PROCEDURE_NAME||'('''||P_COMPCODE||''','''||P_DIVCODE||''','''||C1.PROCESSTYPE||''','''||P_YEARCODE||''','''||P_FNSTDT||''','''||P_FNENDT||''','''||P_FNENDT||''','''||C1.PHASE||''','''||C1.PARAM_1||''','''||C1.PARAM_2||''','''||P_USERNAME||''','''||P_CATEGORYTYPE||''','''||P_CATEGORYCODE||''','''||P_WORKKERSERIAL||''')' ;
                lv_SqlStr := C1.PROCEDURE_NAME||'('''||P_COMPCODE||''','''||P_DIVCODE||''','''||C1.PROCESSTYPE||''','''||P_YEARCODE||''','''||P_FNSTDT||''','''||P_FNENDT||''','''||P_FNENDT||''','''||C1.PHASE||''','''||C1.PARAM_1||''','''||C1.PARAM_2||''','''||P_USERNAME||''','''||P_CATEGORYTYPE||''','''||lv_Category||''','''||P_WORKKERSERIAL||''')' ;
            --dbms_output.put_line(lv_sqlstr);
            execute immediate 'BEGIN '||lv_SqlStr||'; END ;';
        end loop;
    ELSE
        for C1 in( select COMPANYCODE, DIVISIONCODE, PROCESSTYPE, PROCEDURE_NAME, PHASE, CALCULATIONINDEX, PARAM_1, PARAM_2, PARAM_3 
                                from WAGESPROCESSTYPE_PHASE  
                                where COMPANYCODE = P_COMPCODE and DIVISIONCODE = P_DIVCODE
                                  and PROCESSTYPE = P_PROCESSTYPE
                                ORDER BY PHASE, CALCULATIONINDEX
                              )     
        loop
--                lv_SqlStr := C1.PROCEDURE_NAME||'('''||P_COMPCODE||''','''||P_DIVCODE||''','''||C1.PROCESSTYPE||''','''||P_YEARCODE||''','''||P_FNSTDT||''','''||P_FNENDT||''','''||P_FNENDT||''','''||C1.PHASE||''','''||C1.PARAM_1||''','''||C1.PARAM_2||''','''||P_USERNAME||''','''||P_CATEGORYTYPE||''','''||P_CATEGORYCODE||''','''||P_WORKKERSERIAL||''')' ;
                lv_SqlStr := C1.PROCEDURE_NAME||'('''||P_COMPCODE||''','''||P_DIVCODE||''','''||C1.PROCESSTYPE||''','''||P_YEARCODE||''','''||P_FNSTDT||''','''||P_FNENDT||''','''||P_FNENDT||''','''||C1.PHASE||''','''||C1.PARAM_1||''','''||C1.PARAM_2||''','''||P_USERNAME||''','''||P_CATEGORYTYPE||''','''||lv_Category||''','''||P_WORKKERSERIAL||''')' ;
            dbms_output.put_line(lv_sqlstr);
            execute immediate 'BEGIN '||lv_SqlStr||'; END ;';
        end loop;
    END IF;
    
exception
when others then
    lv_error_remark := sqlerrm;
    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    --dbms_output.put_line(sqlerrm);
end;
/