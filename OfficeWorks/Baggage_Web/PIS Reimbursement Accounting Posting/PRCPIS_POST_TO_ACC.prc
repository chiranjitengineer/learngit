CREATE OR REPLACE procedure BAGGAGE_WEB.prcpis_post_to_acc
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_processtype varchar2 default 'SALARY PROCESS',
    p_yearmonth varchar2,
    p_unitcode varchar2,
    p_categorycode varchar2 default null,
    p_gradecode varchar2 default null,
    p_componentcode varchar2 default null
)
is
lv_sql                  varchar2(8000);
lv_cnt                  number;
lv_cnt1                 number;
lv_cnt_temp             number;             
lv_cnt_worker           number;
lv_yearcode             varchar2(10);
lv_result               varchar2(10);
lv_error_remark         varchar2(4000);
lv_refsystemvoucherno   varchar2(100);
lv_systemvoucherno      varchar2(100);
lv_systemvoucherdate    varchar2(10);
lv_master               pissalary_postingdata%rowtype;
lv_voucherno            varchar2(100);
lv_voucherdate          varchar2(10);
lv_divisioncode_target  varchar2(100);
lv_accode_creditor      varchar2(100);
lv_accode_sales         varchar2(100);
lv_amount               number;
lv_totalamount          number;
lv_amount_dr            number;
lv_amount_cr            number;
lv_sysrowid             varchar2(50);
lv_partyname            varchar2(1000);
lv_narration            varchar(4000);
lv_serialno_dr          number;
lv_serialno_cr          number;
lv_serialno_cc_cr       number;
lv_finyearenddate       varchar2(10) := '';
lv_partycode            varchar2(20);
lv_startdate            varchar2(10);
lv_enddate              varchar2(10);
lv_accode_netsalary     varchar2(10);
lv_net_amount           number;
lv_fn_stdt              varchar2(10) := '01/' || substr(p_yearmonth,-2,2) || '/' || substr(p_yearmonth,1,4);
lv_fn_endt              varchar2(10) := to_char(last_day(to_date(lv_fn_stdt,'dd/mm/yyyy')),'DD/MM/YYYY');           
lv_param_voucher_no     varchar2(50);
lv_param_sys_voucher_no varchar2(50);
lv_salaryorarrear       varchar2(50);
begin
    lv_result:='#SUCCESS#';
    
    --Added by Bishwanath on 10/12/2019 to add arrear posting
    
    if p_processtype = 'SALARY PROCESS' then
       lv_param_voucher_no := 'AC_VOUCHERNO_PIS_STAFF';
       lv_param_sys_voucher_no := 'AC_SYS_VOUCHERNO_PIS_STAFF';
       lv_salaryorarrear := 'PAYROLL' ;
    elsif p_processtype = 'ARREAR PROCESS' then 
       lv_param_voucher_no := 'AC_VOUCHERNO_PIS_STAFF_ARR';
       lv_param_sys_voucher_no := 'AC_SYS_VOUCHERNO_PIS_STAFF_ARR';
       lv_salaryorarrear := 'ARREAR' ;
    end if;
    
    --DBMS_OUTPUT.PUT_LINE (lv_param_voucher_no || ' - ' || lv_param_sys_voucher_no );
    
    --RETURN;
    
    --Added by Bishwanath on 10/12/2019 to add arrear posting
    
    select count(*)
    into lv_cnt
    from pissalary_postingdata
    where companycode = p_companycode
      and divisioncode = p_divisioncode
      and periodfrom >= to_date(lv_fn_stdt,'dd/mm/yyyy')
      and periodto <= to_date(lv_fn_endt,'dd/mm/yyyy');
    
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No data found for Payroll Posting]';
        raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark));
    end if;


    if lv_cnt > 0 then
    
    lv_sql := 'CREATE OR REPLACE VIEW VW_PISCOMPONENTLEDGERMAPPING '||chr(10) 
    ||' AS '||chr(10)
    ||' SELECT COMPANYCODE, DIVISIONCODE, QUALITY_GROUP_CODE as COMPONENTCODE,  ACCODE ACCCODE '||chr(10)
    ||' FROM SYS_PARAM_ACPOST_PAYROLL '||chr(10)
    ||' WHERE COMPANYCODE = '''||p_companycode||''' AND DIVISIONCODE = '''||p_divisioncode||''' '||chr(10);
      
    lv_sql :=  lv_sql ||' AND  POSTING_PARAM_NAME = ''PIS SALARY POSTING TO ACCOUNTS'' '||chr(10);
    
    lv_sql :=  lv_sql ||' AND  MODULENAME = ''PIS'' '||chr(10);   
        --DBMS_OUTPUT.PUT_LINE ('1. '||lv_sql);
    
        execute immediate lv_sql;
        
        begin
            select count(*)
            into lv_cnt_worker 
            from pispaytransaction
            where companycode = p_companycode
              and divisioncode = p_divisioncode
              and unitcode = p_unitcode
              and yearmonth = p_yearmonth;
        exception
            when others then
                lv_cnt_worker := null;
                lv_yearcode := null;   
        end;
    
        select yearcode
        into lv_yearcode
        from financialyear
        where companycode = p_companycode
          and divisioncode = p_divisioncode
          and to_date(lv_fn_stdt,'dd/mm/yyyy') >= startdate
          and to_date(lv_fn_endt,'dd/mm/yyyy') <= enddate;
    
        select to_char(enddate,'dd/mm/yyyy')
        into lv_finyearenddate
        from financialyear
        where companycode = p_companycode
          and divisioncode = p_divisioncode
          and yearcode = lv_yearcode;
          
        if trunc(sysdate) > to_date(lv_finyearenddate,'dd/mm/yyyy') then 
            lv_systemvoucherdate := lv_finyearenddate;
        else
            lv_systemvoucherdate := to_char(trunc(sysdate),'dd/mm/yyyy');    
        end if;

        
        begin
        
            select distinct systemvoucherno, voucherno, to_char(voucherdate,'dd/mm/yyyy') voucherdate
            into lv_systemvoucherno, lv_voucherno, lv_voucherdate
            from acvoucher
            where companycode = p_companycode
              and divisioncode = p_divisioncode
              and yearcode = lv_yearcode
              and voucherdate = to_date(lv_fn_endt,'dd/mm/yyyy')
--              and documenttype = 'PIS ' || p_categorycode || ' ' || lv_salaryorarrear
              and documenttype = 'PIS ' || p_unitcode || ' ' || lv_salaryorarrear
              --and documenttype = 'PIS ' || p_categorycode || ' PAYROLL'
              and narration like '%' || p_unitcode || '%FROM ' || lv_fn_stdt || ' TO ' || lv_fn_endt || '%'
              and substr(voucherno,1,8) = (select substr(prefix,1,8) prefix  
                                          from sys_autogen_params 
                                          where companycode= p_companycode 
                                            and divisioncode = p_divisioncode 
                                            and yearcode = lv_yearcode  
                                            --and param_name = 'AC_VOUCHERNO_PIS_STAFF'  Change by Bishwanath on 10/12/2019 to add arrear posting
                                            and param_name = lv_param_voucher_no
                                          );
        exception
        when others then
            lv_systemvoucherno := null;
            lv_voucherno := null;
            lv_voucherdate := null;
        end;           
        
        --DBMS_OUTPUT.PUT_LINE (lv_systemvoucherno || ' - ' || lv_voucherno || ' - ' || lv_voucherdate );
        
        --RETURN;
                                      
        select count(*)
        into lv_cnt_temp
        from acvoucher
        where companycode = p_companycode
          and divisioncode = p_divisioncode
          and voucherdate = to_date(lv_fn_endt,'dd/mm/yyyy')
          and vouchertype = 'JOURNAL'
          and systemvoucherno = lv_systemvoucherno;
        
        if lv_cnt_temp = 0 then
            --select fn_autogen_params(p_companycode,p_divisioncode,lv_yearcode,'AC_SYS_VOUCHERNO_PIS_STAFF',lv_fn_endt) 
            select fn_autogen_params(p_companycode,p_divisioncode,lv_yearcode,lv_param_sys_voucher_no,lv_fn_endt) -- Change by Bishwanath on 10/12/2019 to add arrear posting
            into lv_systemvoucherno
            from dual;
            
            --select fn_autogen_params(p_companycode,p_divisioncode,lv_yearcode,'AC_VOUCHERNO_PIS_STAFF',lv_fn_endt) 
            select fn_autogen_params(p_companycode,p_divisioncode,lv_yearcode,lv_param_voucher_no,lv_fn_endt) -- Change by Bishwanath on 10/12/2019 to add arrear posting
            into lv_voucherno
            from dual;
            lv_voucherdate := lv_fn_endt;
        end if;
    end if;
       
    prc_delete_systemvoucher(p_companycode,p_divisioncode,lv_yearcode,lv_systemvoucherno,'FORCED');
    
    lv_narration := '';

    lv_narration :=
         --'EXECUTIVE PAYROLL POSTING OF '  ---[14] from 19/08/2018 to 01/09/2018 
         'EXECUTIVE ' || lv_salaryorarrear ||' POSTING OF '  --  Change by Bishwanath on 11/12/2019 to add arrear posting
      || p_unitcode || '[' || lv_cnt_worker || ']'
      || ' FROM '
      || lv_fn_stdt
      || ' TO '
      || lv_fn_endt;


    insert into acvoucher
    (companycode, divisioncode, yearcode, 
     voucherno, voucherdate, vouchertype, 
     systemvoucherno, systemvoucherdate, voucheramount, 
     narration, automanualmark, preparedby, prepareddate, 
     modulename, documenttype, manualvoucherno, 
     username, sysrowid,vouchernature,liabilitytype
    )
    select             
     p_companycode,p_divisioncode, lv_yearcode,
     lv_voucherno, to_date(lv_voucherdate,'dd/mm/yyyy'),'JOURNAL' as vouchertype,
     lv_systemvoucherno, to_date(lv_systemvoucherdate,'dd/mm/yyyy'), 0 as voucheramount, 
     lv_narration as narration, 'AUTO VOUCHER' as automanualmark,'prcpis_post_to_acc' as preparedby, trunc(sysdate) as prepareddate,
     --'PIS' as modulename, 'PIS ' || p_categorycode || ' PAYROLL' as documenttype, null manualvoucherno,  --  Change by Bishwanath on 11/12/2019 to add arrear posting
     'PIS' as modulename, 'PIS ' || p_unitcode || ' ' || lv_salaryorarrear as documenttype, null manualvoucherno,           
     'SWT' username,fn_generate_sysrowid(),null vouchernature,null liabilitytype
    from dual;
    
    select systemvoucherno into lv_sql from acvoucher
    where systemvoucherno = lv_systemvoucherno;
    
    dbms_output.put_line(lv_sql);

    lv_serialno_cr:= 0;
    for c1 in ( select companycode, divisioncode, accode, achead, drcr, sum(amount) amount, accostcentrecode
                    from pissalary_postingdata
                    where companycode = p_companycode
                      and divisioncode = p_divisioncode
                      and periodfrom >= to_date(lv_fn_stdt,'dd/mm/yyyy')
                      and periodto <= to_date(lv_fn_endt,'dd/mm/yyyy')
                      and amount <> 0 
                 group by companycode, divisioncode, accode, achead, drcr, accostcentrecode
              ) loop
        
                lv_serialno_cr := lv_serialno_cr + 1;
                
                insert into acvoucherdetails_entry
                (sysrowid, companycode, divisioncode, divisioncodefor, 
                 yearcode, systemvoucherno, systemvoucherdate, 
                 serialnofor, amount, 
                 drcr, onaccount, remarks, masterdetailmark, 
                 accodefor, username
                )
                select             
                 fn_generate_sysrowid() ,c1.companycode,c1.divisioncode, c1.divisioncode as divisioncodefor,
                 lv_yearcode,lv_systemvoucherno,to_date(lv_systemvoucherdate,'dd/mm/yyyy'),
                 lv_serialno_cr , c1.amount ,
                 substr(c1.drcr,1,1) drcr,null  onaccount,null as remarks,'D' as masterdetailmark,
                 c1.accode as accodefor, 'SWT' username
                from dual;
                lv_serialno_cc_cr :=0;
                    /*--------------------------*/
                for c2 in ( select companycode, divisioncode, accode, achead, drcr, sum(amount) amount, accostcentrecode
                    from pissalary_postingdata_cc
                    where companycode = p_companycode
                      and divisioncode = p_divisioncode
                      and periodfrom >= to_date(lv_fn_stdt,'dd/mm/yyyy')
                      and periodto <= to_date(lv_fn_endt,'dd/mm/yyyy')
                      and amount <> 0 
                      and accode = c1.accode
                 group by companycode, divisioncode, accode, achead, drcr, accostcentrecode
                ) loop
        
                lv_serialno_cc_cr := lv_serialno_cc_cr + 1;
                
                insert into accostcentredetails_entry
                (
                sysrowid, companycode, divisioncode, yearcode, systemvoucherno, systemvoucherdate, 
                voucherserialno, serialno, costcentrecode, amount, drcr, lastmodified, 
                synchronized, divisioncodefor, accodefor, username
                )
                select             
                 fn_generate_sysrowid() ,c2.companycode,c2.divisioncode, lv_yearcode,lv_systemvoucherno,to_date(lv_systemvoucherdate,'dd/mm/yyyy'),
                 lv_serialno_cr , lv_serialno_cc_cr, c2.accostcentrecode, c2.amount,substr(c2.drcr,1,1) drcr, to_date(lv_systemvoucherdate,'dd/mm/yyyy'),
                 null,  c2.divisioncode,  c2.accode as accodefor, 
                 'SWT' username
                from dual;
                
                end loop;
                    /*--------------------------*/
                
            end loop;
--    dbms_output.put_line('[JOURNAL NO : '|| lv_voucherno ||', JOURNAL DATE : '|| to_date(lv_voucherdate,'DD/MM/YYYY') || ' SYSTEM VOUCHER NUMBER GENERATED: ' || lv_systemvoucherno || ' Dated : ' || to_date(lv_systemvoucherdate,'dd/mm/yyyy') || ']');
--    return;

    if fn_drcr_mismatch(p_companycode,p_divisioncode, lv_yearcode,lv_systemvoucherno) > 0 then
        lv_error_remark := 'validation failure : '||lv_systemvoucherno||' [total debit amount is not matched with total credit amount.... hence voucher could not be saved]';
        raise_application_error(to_number(fn_display_error( 'common')),fn_display_error( 'common',6,lv_error_remark));
    end if;
       
--       
--    if fn_tds_mismatch(p_companycode,p_divisioncode, lv_yearcode,lv_systemvoucherno) > 0 then
--        lv_error_remark := 'validation failure : [tds amount of voucher is not matching with tds amount of tds details... hence voucher could not be saved]';
--        raise_application_error(to_number(fn_display_error( 'common')),fn_display_error( 'common',6,lv_error_remark));
--    end if;
--
--    if fn_bill_mismatch(p_companycode,p_divisioncode, lv_yearcode,lv_systemvoucherno) > 0 then
--        lv_error_remark := 'validation failure : [bill amount of voucher is not matching with bill amount of bill details.... hence voucher could not be saved]';
--        raise_application_error(to_number(fn_display_error( 'common')),fn_display_error( 'common',6,lv_error_remark));
--    end if;
--

    select count(*)
    into lv_cnt
    from sys_gbl_procoutput_info;
    
    --delete from sys_gbl_procoutput_info;
    
    
    if lv_cnt = 0 then
        insert into sys_gbl_procoutput_info
        values ('[JOURNAL NO : '|| lv_voucherno ||', JOURNAL DATE : '|| to_date(lv_voucherdate,'DD/MM/YYYY') || ' SYSTEM VOUCHER NUMBER GENERATED: ' || lv_systemvoucherno || ' Dated : ' || to_date(lv_systemvoucherdate,'dd/mm/yyyy') || ']');
    else
        update sys_gbl_procoutput_info
        set sys_save_info = nvl(sys_save_info,'') || ('[JOURNAL NO : '|| lv_voucherno ||', JOURNAL DATE : '|| to_date(lv_voucherdate,'DD/MM/YYYY') || ' SYSTEM VOUCHER NUMBER GENERATED: ' || lv_systemvoucherno || ' Dated : ' || to_date(lv_systemvoucherdate,'dd/mm/yyyy') || ']');
    end if;
              
end;
/