CREATE OR REPLACE procedure JIAJURI.prcgps_wages_process(p_processtype varchar2, p_compcode varchar2, p_divcode varchar2, p_yearcode varchar2,
                                                  p_username varchar2,   
                                                  p_fnstdt varchar2, 
                                                  p_fnendt varchar2,
                                                  p_categorytype    varchar2 default null,
                                                  p_categorycode varchar2 default null,
                                                  p_workkerserial varchar2 default null,
                                                  p_processbased_on varchar2 default 'DAILY')
as
lv_sqlstr varchar2(4000) := '';
lv_result varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_cntfinyr           number;
begin


--update GPSCATEGORYMAST SET CALCFACTRODAYS=(TO_NUMBER(TO_CHAR (LAST_DAY (TO_DATE (p_fnstdt, 'DD/MM/YYYY')),'DD'))- fn_NoofOffDays (p_fnstdt,TO_CHAR (LAST_DAY (TO_DATE (p_fnstdt, 'DD/MM/YYYY')),'DD/MM/YYYY'),'SUNDAY',p_compcode,p_divcode)) WHERE COMPANYCODE =p_compcode AND DIVISIONCODE =p_divcode AND CATEGORYTYPE<> 'WORKER';  

--COMMIT;

       DELETE FROM GPSDAILYPAYSHEETDETAILS_SWT WHERE COMPANYCODE=p_compcode AND DIVISIONCODE=p_divcode ;
       DELETE FROM GPSPAYSHEETDETAILS_SWT WHERE COMPANYCODE=p_compcode AND DIVISIONCODE=p_divcode ;
       COMMIT;
             
    lv_result:='#SUCCESS#';
    if p_processtype = 'DAILY' or p_processtype = 'CASH'  or p_processtype = 'BILLTAP' or p_processtype = 'CASHTAP' or p_processtype = 'CLOSERTAP' then ---- for daily process multiple day process at a time 
        
        SELECT fn_get_validdate_finyear(p_compcode,p_divcode,p_yearcode,p_fnstdt)
        INTO lv_cntfinyr 
        FROM DUAL;
    
        IF  NVL(lv_cntfinyr,0) =0 THEN
            LV_ERROR_REMARK := 'Date does not belongs to financial year!!';
            RAISE_APPLICATION_ERROR(TO_NUMBER(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,LV_ERROR_REMARK));
        END IF;
        
        for cdate in (  select to_char(to_date(p_fnstdt,'DD/MM/YYYY') + rownum -1,'DD/MM/YYYY') dailydate
                        from all_objects
                        where rownum <= to_date(p_fnendt,'DD/MM/YYYY')-to_date(p_fnstdt,'DD/MM/YYYY')+1
                     )
        loop
            for c1 in( select companycode, divisioncode, processtype, procedure_name, phase, calculationindex, param_1, param_2, param_3 
                                    from wagesprocesstype_phase  
                                    where companycode = p_compcode and divisioncode = p_divcode
                                      and processtype = p_processtype
                                    order by phase, calculationindex
                                  )     
            loop
                lv_sqlstr := c1.procedure_name||'('''||p_compcode||''','''||p_divcode||''','''||c1.processtype||''','''||p_yearcode||''','''||cdate.dailydate||''','''||cdate.dailydate||''','''||cdate.dailydate||''','''||c1.phase||''','''||c1.param_1||''','''||c1.param_2||''','''||p_username||''','''||p_categorytype||''','''||p_categorycode||''','''||p_workkerserial||''')' ;
             --dbms_output.put_line(lv_sqlstr);
               execute immediate 'BEGIN '||lv_sqlstr||'; END ;';
            end loop;
        
        end loop;     
        --dbms_output.put_line(lv_sqlstr);
                                  
    elsif p_processtype = 'WAGES PROCESS' then
    
         dbms_output.put_line('1' || p_processbased_on); 
        for c1 in( select companycode, divisioncode, processtype, LTRIM(TRIM(procedure_name)) procedure_name, phase, calculationindex, param_1, param_2, param_3 
                                from wagesprocesstype_phase  
                                where companycode = p_compcode and divisioncode = p_divcode
                                  and processtype = p_processtype 
                                  and nvl(param_3,'DAILY') = nvl(p_processbased_on,'DAILY')
                                order by phase, calculationindex
                              )     
        loop
                lv_sqlstr := c1.procedure_name||'('''||p_compcode||''','''||p_divcode||''','''||c1.processtype||''','''||p_yearcode||''','''||p_fnstdt||''','''||p_fnendt||''','''||p_fnendt||''','''||c1.phase||''','''||c1.param_1||''','''||c1.param_2||''','''||p_username||''','''||p_categorytype||''','''||p_categorycode||''','''||p_workkerserial||''')' ;
            dbms_output.put_line(lv_sqlstr);
          execute immediate 'BEGIN '||lv_sqlstr||'; END ;';
        end loop;
        dbms_output.put_line(lv_sqlstr);
            
    else
        for c1 in( select companycode, divisioncode, processtype, procedure_name, phase, calculationindex, param_1, param_2, param_3 
                                from wagesprocesstype_phase  
                                where companycode = p_compcode and divisioncode = p_divcode
                                  and processtype = p_processtype
                                order by phase, calculationindex
                              )     
        loop
                lv_sqlstr := c1.procedure_name||'('''||p_compcode||''','''||p_divcode||''','''||c1.processtype||''','''||p_yearcode||''','''||p_fnstdt||''','''||p_fnendt||''','''||p_fnendt||''','''||c1.phase||''','''||c1.param_1||''','''||c1.param_2||''','''||p_username||''','''||p_categorytype||''','''||p_categorycode||''','''||p_workkerserial||''')' ;
            execute immediate 'BEGIN '||lv_sqlstr||'; END ;';
            --dbms_output.put_line(lv_sqlstr);
        end loop;
    end if;
            
    dbms_output.put_line('END');
/* exception
when others then    lv_error_remark := sqlerrm;
    raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark)) ;*/
  ENd;
/