DROP PROCEDURE NJMCL_WEB.PROC_WPS_PHASE_DEDN_ROWISE_BKP;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPS_PHASE_DEDN_ROWISE_BKP" 
(
P_COMPCODE   varchar2,
P_DIVCODE       varchar2,
P_FNSTDT        varchar2,
P_FNENDT        varchar2
)
as
lv_sql varchar2(32767);
lv_val number;
lv_SqlErr   varchar2(2000) := '';
lv_fnstdt   Date := to_date(P_FNSTDT,'dd/mm/yyyy');
lv_fnendt   Date := to_date(P_FNENDT,'dd/mm/yyyy');
lv_parvalues varchar2(100);
begin
    lv_parvalues := 'COMP ='||P_COMPCODE||', DIV = '||P_DIVCODE||',FNS = '||P_FNSTDT||' FNE = '||P_FNENDT;
    delete  GTT_SWT_PHASE_DEDN ;
    commit;
    for c1 in( select * from  SWT_PHASE_DEDN  ) 
    loop
        for c2 in( select column_name cn from cols where table_name = 'SWT_PHASE_DEDN'
        intersect
        select COMPONENTSHORTNAME cn from WPSCOMPONENTMASTER where COMPANYCODE = P_COMPCODE and DIVISIONCODE = P_DIVCODE and COMPONENTSHORTNAME <> 'GROSS_WAGES'
        ) 
        loop
            lv_sql := 'select '||c2.cn||' from  SWT_PHASE_DEDN where WORKERSERIAL = '''||c1.WORKERSERIAL||''' and WORKERCATEGORYCODE = '''||c1.WORKERCATEGORYCODE||''' ' ;
            execute immediate lv_sql into lv_val ;
            insert into GTT_SWT_PHASE_DEDN(WORKERSERIAL,WORKERCATEGORYCODE,GROSS_WAGES,COMPONENTSHORTNAME, COMPONENTAMOUNT)  values(''||c1.WORKERSERIAL||'',''||c1.WORKERCATEGORYCODE||'',c1.GROSS_WAGES,''||c2.cn||'',lv_val) ;
        end loop ;
        commit;
    end loop;
    insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPS_PHASE_DEDN_ROWISE','','',lv_parvalues, lv_fnstdt, lv_fnendt, 'ROW WISE COMPONENT MERGE SUCCESSFULLY DONE');
    commit;
exception
    when others then
        lv_SqlErr := SqlErrm;
       insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( 'PROC_WPS_PHASE_DEDN_ROWISE',lv_SqlErr,'','', lv_fnstdt, lv_fnendt, 'ROW WISE COMPONENT MERGE ERROR');
    commit;          
end;
/


