CREATE OR REPLACE procedure HOOGHLY_WEB.prc_delete_systemvoucher(p_companycode varchar2, 
                                                     p_divisioncode varchar2,
                                                     p_yearcode varchar2,
                                                     p_systemvoucherno varchar2,
                                                     p_ForcedDelete varchar2 default 'NONE',
                                                     p_ForceDeleteSales varchar2 default 'NONE',
                                                     p_Delete_Only_Actual_Table char default 'N') 
as
    lv_cnt              number;
    lv_error_remark     varchar2(4000);
begin
    --exec prc_delete_systemvoucher('JT0069', '0009', '2019-2020', 'JMR/JV/M/19-20/0069', 'FORCED')
    
    if p_forcedDelete <> 'FORCED' then
        select count(*)
        into lv_cnt
        from acvoucher
        where companycode = p_companycode
          and divisioncode = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno
          and voucherno is not null;
        if lv_cnt > 0 then
            lv_error_remark := 'Voucher is Authorised. Can not Delete. Contact Softweb..';
            raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark));
        end if;
    end if;
   -- --DBMS_OUTPUT.PUT_LINE( ' FROM INDSIDE PRC_DELETE_SYSTEMVOUCHER ');
   -- return ;
    -- Changes made by Sanjib Banerjee on 23.06.2016 - Start
    -- Checking of refsystemvoucherno
    -- Check - 1
    /*
    select count(*)
    into lv_cnt
    from acvoucher
    where companycode = p_companycode
      and yearcode = p_yearcode
      and refsystemvoucherno = p_systemvoucherno;
    
    if lv_cnt > 0 then
        lv_error_remark := 'There is another voucher contains this Voucher No as reference. Can not Delete. Contact Softweb..';
        raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark));
    end if;
   
    -- Check - 1
    select count(*)
    into lv_cnt
    from acvoucher a, acvoucher b
    where a.companycode = b.companycode
      and a.yearcode = b.yearcode
      and nvl(a.refsystemvoucherno,'~na~') = b.systemvoucherno 
      and a.companycode = p_companycode
      and a.yearcode = p_yearcode
      and a.systemvoucherno = p_systemvoucherno;
    
    if lv_cnt > 0 then
        lv_error_remark := 'There is another voucher exists the Voucher No of which is kept as a reference in this Voucher. Can not Delete. Contact Softweb..';
        raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark));
    end if;
    */
    -- Changes made by Sanjib Banerjee on 23.06.2016 - End

    -- Checking the parameter value "p_Delete_Only_Actual_Table" 
    -- If p_Delete_Only_Actual_Table = "Y" then the table mapped in SYS_TFMAP would not be deleted but only Main Tables would be deleted
    -- Example : Main Tables are [ACVOUCHER, ACVOUCHERDETAILS_ENTRY, ACBILLDETAILS_ENTRY, ACCOSTCENTREDETAILS_ENTRY, ACTDSDETAILS_ENTRY, ACADVANCEDETAILS_ENTRY]
    
    if upper(p_Delete_Only_Actual_Table) in ('Y','N') then

        delete from ACTDSDETAILS_ENTRY
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACCOSTCENTREDETAILS_PROV
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACCOSTCENTREDETAILS_ENTRY
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;
    
        delete from ACSERVICETAXDETAILS_ENTRY
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACSERVICETAXDETAILS_PROV
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;


        delete from ACADVANCEDETAILS_ENTRY
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;
    
        delete from ACBILLDETAILS_ENTRY
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACVOUCHERDETAILS_PROV 
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACVOUCHERDETAILS_ENTRY
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACGSTDETAILS_ENTRY
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACVOUCHER_PROV
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACVOUCHER
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACBRSDETAILS
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;
        

    
    end if;

    if upper(p_Delete_Only_Actual_Table) ='N' then
        delete from ACTDSDETAILS_PYMT 
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACTDSDETAILS_PROV
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACTDSDETAILS_LIB
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;
      
        if p_ForceDeleteSales = 'NONE' then
            delete from ACTDSDETAILS_SALES
            where companycode = p_companycode 
              and divisioncode  = p_divisioncode
              and yearcode = p_yearcode
              and systemvoucherno = p_systemvoucherno;

            delete from ACCOSTCENTREDETAILS_SALES 
            where companycode = p_companycode 
              and divisioncode  = p_divisioncode
              and yearcode = p_yearcode
              and systemvoucherno = p_systemvoucherno;
        end if;
    

        delete from ACCOSTCENTREDETAILS_LIB
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

      
        --

        --

        delete from ACADVANCEDETAILS_PYMT
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;


        --

        delete from ACBILLDETAILS_PYMT
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACBILLDETAILS_LIB
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACBILLDETAILS_RCPT
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;


    --
        if p_ForceDeleteSales = 'NONE' then
            delete from ACVOUCHERDETAILS_SALES 
            where companycode = p_companycode 
              and divisioncode  = p_divisioncode
              and yearcode = p_yearcode
              and systemvoucherno = p_systemvoucherno;
        end if;

        delete from ACVOUCHERDETAILS_RCPT 
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;
        
        delete from ACVOUCHERDETAILS_PYMT 
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;


        delete from ACVOUCHERDETAILS_LIB 
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;


    --
        
        delete from ACGSTDETAILS_LIB
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;


    --
        if p_ForceDeleteSales = 'NONE' then        
            delete from ACVOUCHER_SALES
            where companycode = p_companycode 
              and divisioncode  = p_divisioncode
              and yearcode = p_yearcode
              and systemvoucherno = p_systemvoucherno;
        end if;


        delete from ACVOUCHER_RCPT
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACVOUCHER_PYMT
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

        delete from ACVOUCHER_LIB
        where companycode = p_companycode 
          and divisioncode  = p_divisioncode
          and yearcode = p_yearcode
          and systemvoucherno = p_systemvoucherno;

    end if;
end;
/
