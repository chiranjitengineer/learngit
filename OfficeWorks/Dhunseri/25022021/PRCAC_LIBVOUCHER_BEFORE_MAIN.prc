CREATE OR REPLACE procedure DHUNSERI.prcAC_LIBVoucher_Before_Main
is
lv_cnt                      number;
lv_result                   varchar2(200);
lv_error_remark             varchar2(4000) := '' ;
lv_Master                   gbl_ACVOUCHER_LIB%rowtype;
lv_Prefix_SystemVoucherno    varchar2(30);
lv_SYSTEMVOUCHERNO          varchar2(100) := '';
lv_systemvoucherdate        date;
lv_voucherno                varchar2(100) := '';
lv_voucherdate              varchar2(10);
lv_MaxVoucherdate           date;
lv_finyearclosed            varchar2(100) := '';
lv_voucherserialno_dr       number := 0 ;
lv_voucherserialno_cr       number := 0 ;
lv_originalbillamount       number;
lv_originaldrcr             char(1);
lv_automanualmark           varchar2(100);
lv_amount_adjusted          number;
lv_sysrowid                 varchar2(1000);
lv_AllowCheckedBy           char(3);
lv_PREPAREDBY               varchar2(100);
lv_PREPAREDDATE             varchar2(100);
lv_cntpreparedby            number;
LV_CHECKEDBYCNT             number;
lv_cntcheckedby             number;
begin
    lv_result:='#SUCCESS#';
   
    --Master
    select count(*)
    into lv_cnt
    from GBL_ACVOUCHER_LIB;
   
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No Entry is found in Voucher]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;

    
    select count(*)
    into lv_cnt
    from GBL_ACVOUCHERDETAILS_LIB;
   
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No Entries are found in Voucher Details]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;

    select *
    into lv_Master
    from GBL_ACVOUCHER_LIB;    

    if lv_Master.OperationMode is null then
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT / VIEW ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

    select count(*)
    into lv_cnt
    from financialyear
    where companycode = lv_Master.CompanyCode
      and divisioncode = lv_Master.Divisioncode
      and yearcode = lv_Master.Yearcode;
          
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [Either Company or Division or Year is not correct. Hence Voucher could not be saved]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;


    select nvl(finyearclosed,'NO')
    into lv_finyearclosed
    from financialyear
    where companycode = lv_Master.CompanyCode
      and divisioncode = lv_Master.Divisioncode
      and yearcode = lv_Master.Yearcode;
          
    if lv_finyearclosed = 'YES' or lv_finyearclosed = 'Y' then
        lv_finyearclosed := 'YES';
    end if;

    if lv_finyearclosed = 'YES' then
        lv_error_remark := 'Validation Failure : [The Financial Year [' || lv_Master.Yearcode || '] is closed. Hence Voucher could not be saved]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;


    lv_automanualmark := nvl(lv_Master.automanualmark,'MANUAL VOUCHER');
    
--    SELECT COUNT(*)
--    INTO LV_CHECKEDBYCNT
--    FROM SYS_PARAMETER
--    WHERE PARAMETER_NAME ='CHECKEDBY'
--    AND COMPANYCODE=lv_Master.companycode
--    AND DIVISIONCODE=lv_Master.divisioncode
--    AND PROJECTNAME='ACCOUNTS'
--    AND PARAMETER_VALUE='YES';
--    
--    if nvl(lv_Master.OperationMode,'NA') = 'M' AND NVL(LV_CHECKEDBYCNT,0) > 0 THEN
--    
--       IF lv_Master.transactiontype NOT like '%CHECKED' AND lv_Master.transactiontype NOT like '%-%APPROVED' THEN
--           select count(systemvoucherno)
--           into lv_cntcheckedby
--           from acvoucher
--           where companycode = lv_Master.companycode
--           and divisioncode = lv_Master.divisioncode
--           and yearcode = lv_Master.yearcode
--           and systemvoucherno = lv_Master.systemvoucherno
--           AND CHECKEDBY IS NOT NULL;
--           
--           if nvl(lv_cntcheckedby,0) > 0 then
--              lv_error_remark := 'Cannot Update Already Checked This Voucher';
--              raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
--           end if;
--       END IF;
--             
--    END IF;
-----------------------  systemvouchernumber generation for manual vouchers

    if nvl(lv_Master.OperationMode,'NA') = 'A' or (nvl(lv_Master.OperationMode,'NA') = 'M' ) then
        if nvl(lv_Master.OperationMode,'NA') = 'A' then
            
            lv_systemvoucherdate := to_date(FN_GET_ACC_EFFECTSYSDATE(lv_Master.companycode, lv_Master.divisioncode, lv_Master.yearcode, to_char(trunc(sysdate),'dd/mm/yyyy')),'dd/mm/yyyy');
      
            update GBL_ACVOUCHER_LIB
            set systemvoucherdate = lv_systemvoucherdate;
            
            update GBL_ACVOUCHERDETAILS_LIB
            set systemvoucherdate = lv_systemvoucherdate;

            update GBL_ACTDSDETAILS_LIB
            set systemvoucherdate = lv_systemvoucherdate;

            update GBL_ACCOSTCENTREDETAILS_LIB
            set systemvoucherdate = lv_systemvoucherdate;

            update GBL_ACBILLDETAILS_LIB
            set systemvoucherdate = lv_systemvoucherdate;
            
            update GBL_ACSERVICETAXDETAILS_LIB
            set systemvoucherdate = lv_systemvoucherdate;
            
            update GBL_ACGSTDETAILS_LIB
            set systemvoucherdate = lv_systemvoucherdate;
            
        end if;
        select *
        into lv_Master
        from GBL_ACVOUCHER_LIB;
        
        if lv_Master.systemvoucherno is null then
            lv_Prefix_SystemVoucherno:=fn_sysvoucher_nature_prefix(lv_Master.companycode,lv_Master.divisioncode,lv_Master.yearcode,'AC_SYS_VOUCHERNO_PURCHASE_MANUAL',lv_Master.vouchernature);

            if nvl(lv_Prefix_SystemVoucherno,'~na~') = '~na~' then
                select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'AC_SYS_VOUCHERNO_PURCHASE_MANUAL',to_char(lv_Master.systemvoucherdate,'dd/mm/yyyy')) 
                into lv_SYSTEMVOUCHERNO
                from dual;
            else
                select fn_autogen_params_n(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'AC_SYS_VOUCHERNO_PURCHASE_MANUAL',to_char(lv_Master.systemvoucherdate,'dd/mm/yyyy'),lv_Prefix_SystemVoucherno) 
                into lv_SYSTEMVOUCHERNO
                from dual;
            end if;
        else
            lv_SYSTEMVOUCHERNO := lv_Master.systemvoucherno;
        end if; 

        --added date 23-01-2020
        if nvl(lv_Master.OperationMode,'NA') = 'M' and lv_Master.transactiontype like '%CHECKED' then 
                         
          select count(systemvoucherno)
          into lv_cntpreparedby
          from acvoucher
          where companycode = lv_Master.companycode
          and divisioncode = lv_Master.divisioncode
          and yearcode = lv_Master.yearcode
          and systemvoucherno = lv_Master.systemvoucherno;
        
          if lv_cnt > 0 then
                select distinct PREPAREDBY, TO_CHAR(PREPAREDDATE,'DD/MM/YYYY')
                into lv_PREPAREDBY,lv_PREPAREDDATE
                from acvoucher
                where companycode = lv_Master.companycode
                and divisioncode = lv_Master.divisioncode
                and yearcode = lv_Master.yearcode
                and systemvoucherno = lv_Master.systemvoucherno;
          end if;
                              
         end if;

         --added date 23-01-2020

        update GBL_ACVOUCHER_LIB
        set SYSTEMVOUCHERNO = lv_SYSTEMVOUCHERNO;
            
        update GBL_ACVOUCHERDETAILS_LIB
        set SYSTEMVOUCHERNO = lv_SYSTEMVOUCHERNO;
            
        update GBL_ACTDSDETAILS_LIB
        set SYSTEMVOUCHERNO = lv_SYSTEMVOUCHERNO;

        update GBL_ACCOSTCENTREDETAILS_LIB
        set SYSTEMVOUCHERNO = lv_SYSTEMVOUCHERNO;
            
        update GBL_ACBILLDETAILS_LIB
        set SYSTEMVOUCHERNO = lv_SYSTEMVOUCHERNO;
        
        update GBL_ACSERVICETAXDETAILS_LIB
        set SYSTEMVOUCHERNO = lv_SYSTEMVOUCHERNO;
        
        update GBL_ACGSTDETAILS_LIB
        set SYSTEMVOUCHERNO = lv_SYSTEMVOUCHERNO;
        
   
        delete from acbilldetails_entry
        where companycode = lv_Master.companycode
          and divisioncode = lv_Master.divisioncode
          and yearcode = lv_Master.yearcode
          and systemvoucherno = lv_Master.systemvoucherno;

        delete from actdsdetails_entry
        where companycode = lv_Master.companycode
          and divisioncode = lv_Master.divisioncode
          and yearcode = lv_Master.yearcode
          and systemvoucherno = lv_Master.systemvoucherno;

        delete from accostcentredetails_entry
        where companycode = lv_Master.companycode
          and divisioncode = lv_Master.divisioncode
          and yearcode = lv_Master.yearcode
          and systemvoucherno = lv_Master.systemvoucherno;

        delete from acservicetaxdetails_entry
        where companycode = lv_Master.companycode
          and divisioncode = lv_Master.divisioncode
          and yearcode = lv_Master.yearcode
          and systemvoucherno = lv_Master.systemvoucherno;

        delete from acvoucherdetails_entry
        where companycode = lv_Master.companycode
          and divisioncode = lv_Master.divisioncode
          and yearcode = lv_Master.yearcode
          and systemvoucherno = lv_Master.systemvoucherno;

        delete from acadvancedetails_entry
        where companycode = lv_Master.companycode
          and divisioncode = lv_Master.divisioncode
          and yearcode = lv_Master.yearcode
          and systemvoucherno = lv_Master.systemvoucherno;

        delete from acgstdetails_entry
        where companycode = lv_Master.companycode
          and divisioncode = lv_Master.divisioncode
          and yearcode = lv_Master.yearcode
          and systemvoucherno = lv_Master.systemvoucherno;

        delete from acvoucher
        where companycode = lv_Master.companycode
          and divisioncode = lv_Master.divisioncode
          and yearcode = lv_Master.yearcode
          and systemvoucherno = lv_Master.systemvoucherno;
              
        select *
        into lv_Master
        from GBL_ACVOUCHER_LIB;
            
        ---- Inserting data into ACVOUHER - Start
        select count(*)
        into lv_cnt
        from acvoucher
        where companycode = lv_Master.companycode
          and divisioncode = lv_Master.divisioncode
          and yearcode = lv_Master.yearcode
          and systemvoucherno = lv_Master.systemvoucherno;
            
        if lv_cnt > 0 then
            lv_error_remark := 'Validation Failure : [This voucher is already existing how can have the same systemvoucherno generated???? Hence Voucher could not be saved]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;
            
        select achead
        into lv_result
        from acacledger
        where companycode = lv_Master.companycode
          and accode = lv_Master.accode;
            
        insert into acvoucher
        (companycode, divisioncode, yearcode, 
         VOUCHERTYPE, 
         SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, PARTY, VOUCHERAMOUNT, 
         NARRATION, AUTOMANUALMARK, PREPAREDBY, PREPAREDDATE, 
         CHECKEDBY,CHECKEDDATE,
         MODULENAME, DOCUMENTTYPE, MANUALVOUCHERNO, 
         USERNAME, SYSROWID,VOUCHERNATURE,LIABILITYTYPE
        )
        select             
         companycode,divisioncode, yearcode,
         (case when TRANSACTIONTYPE like 'AGAINST BILL%' then 'PURCHASE BILL' else 'JOURNAL' end) as vouchertype,
         SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, lv_result as party,AMOUNT as voucheramount, 
         NARRATION, lv_automanualmark as AUTOMANUALMARK,username as preparedby, trunc(sysdate) as prepareddate,
         (case when TRANSACTIONTYPE like 'AGAINST BILL CHECKED%' then lv_master.username end) as checkedby,
         (case when TRANSACTIONTYPE like 'AGAINST BILL CHECKED%' then trunc(sysdate) end) as checkeddate,
         nvl(modulename,'ACCOUNTS') as modulename, nvl(documenttype,transactiontype) as documenttype, manualvoucherno,            
         username,SYSROWID,VOUCHERNATURE,LIABILITYTYPE
        from GBL_ACVOUCHER_LIB; 

        -- Initialising Voucher Serial No
        
        lv_voucherserialno_dr  := 0 ;
        lv_voucherserialno_cr  := 999 ;


        ---- Inserting data into ACVOUHER - End
            
        -- inserting into acvoucherdetails_entry
        -- creditor / debtor part
        lv_voucherserialno_dr  := lv_voucherserialno_dr + 1 ;
        lv_voucherserialno_cr  := lv_voucherserialno_cr + 1 ;
            
        for data1 in (select * from GBL_ACVOUCHER_LIB) loop
            if data1.drcr = 'D' then
                lv_voucherserialno_dr := lv_voucherserialno_dr + 1;
            else
                lv_voucherserialno_cr := lv_voucherserialno_cr + 1;
            end if;
            
            insert into acvoucherdetails_entry
            (SYSROWID, COMPANYCODE, DIVISIONCODE, DIVISIONCODEFOR, 
             YEARCODE, SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, 
             AMOUNT, 
             DRCR, ONACCOUNT, REMARKS, MASTERDETAILMARK, 
             ACCODEFOR, SERIALNOFOR, USERNAME
            )
            select             
             data1.sysrowid,data1.companycode,data1.divisioncode, data1.divisioncode as divisioncodefor,
             data1.yearcode,data1.systemvoucherno,data1.systemvoucherdate,
             (case when data1.TRANSACTIONTYPE like 'AGAINST BILL%' then (data1.amount-nvl(data1.totaltdsamount,0)) else data1.amount end) as amount,
             data1.drcr,'BILL WISE' as onaccount,null as remarks,'D' as masterdetailmark,
             data1.accode as accodefor, case when data1.drcr='D' then lv_voucherserialno_dr else lv_voucherserialno_cr end as serialnofor, data1.username
            from dual; 
        end loop;
         
        -- inserting into acbilldetails_entry
        -- bill part of debtors or creditors
        insert into acbilldetails_entry
        (SYSROWID, COMPANYCODE, DIVISIONCODE, DIVISIONCODEFOR, 
         YEARCODE, SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, 
         TRANSACTIONDATE, BILLNO, BILLDATE, 
         REFBILLNO, REFBILLDATE, ORIGINALBILLAMOUNT,ORIGINALDRCR,
         BILLAMOUNT, DRCR, 
         TRANSACTIONTYPE, MANUALAUTO, 
         VOUCHERSERIALNO, ACCODEFOR, 
         USERNAME
        )
        select             
         sysrowid,companycode,divisioncode, divisioncode as divisioncodefor,
         yearcode,systemvoucherno,systemvoucherdate,
         lv_Master.voucherdate as transactiondate,refbillno as billno, refbilldate as billdate,
         lv_Master.voucherno as refbillno, lv_Master.voucherdate as refbilldate,amount as originalbillamount,drcr as originaldrcr, 
         (case when TRANSACTIONTYPE like 'AGAINST BILL%' then (amount-nvl(totaltdsamount,0)) else amount end) as billamount, drcr,
         (case when TRANSACTIONTYPE like 'ADVANCE%' and drcr = 'D' then 'ADVANCE PAYMENT' 
               when TRANSACTIONTYPE like 'ADVANCE%' and drcr = 'C' then 'ADVANCE RECEIVED'
               when TRANSACTIONTYPE like 'AGAINST BILL%'    and drcr = 'C' then 'PURCHASE BILL' 
               when TRANSACTIONTYPE like 'AGAINST BILL%'    and drcr = 'D' then 'SALES BILL' 
               else 'NONE' end) as transactiontype,lv_automanualmark as manualauto,              
          case when drcr='D' then lv_voucherserialno_dr else lv_voucherserialno_cr end as voucherserialno, accode as accodefor,
          username
        from GBL_ACVOUCHER_LIB; 

        --- Handling the situation where Liability is bookied while adjusting the Advances
        if lv_Master.transactiontype like 'AGAINST BILL%' and lv_Master.drcr = 'C' then
            lv_amount_adjusted := 0;
            for c1 in (select * from gbl_acbilldetails_lib) loop
                insert into acbilldetails_entry
                (SYSROWID, COMPANYCODE, DIVISIONCODE, DIVISIONCODEFOR, 
                 YEARCODE, SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, 
                 TRANSACTIONDATE, BILLNO, BILLDATE, 
                 REFBILLNO, REFBILLDATE, ORIGINALBILLAMOUNT,ORIGINALDRCR,
                 BILLAMOUNT, DRCR, 
                 TRANSACTIONTYPE, MANUALAUTO, 
                 VOUCHERSERIALNO, ACCODEFOR, 
                 USERNAME
                )
                select             
                 c1.sysrowid,lv_Master.companycode,lv_Master.divisioncode, lv_Master.divisioncode as divisioncodefor,
                 lv_Master.yearcode,lv_Master.systemvoucherno,lv_Master.systemvoucherdate,
                 lv_Master.voucherdate as transactiondate,c1.billno as billno, c1.billdate as billdate,
                 c1.refbillno as refbillno, c1.refbilldate as refbilldate,c1.originalbillamount,c1.originaldrcr, 
                 c1.billamount, c1.drcr,
                 c1.transactiontype || ' ADJUSTMENT' as transactiontype,lv_automanualmark as manualauto,              
                 lv_voucherserialno_cr as voucherserialno, c1.accode as accodefor,
                 lv_Master.username
                from dual; 
                
                lv_amount_adjusted := lv_amount_adjusted + (case when c1.drcr='C' then nvl(c1.billamount,0) else -nvl(c1.billamount,0) end);
                
            end loop;
            if lv_amount_adjusted <> 0 then
                -- Generating the sysrowid
                delete from gbl_acvoucher_pymt;
                
                insert into gbl_acvoucher_pymt 
                 (companycode) 
                select 
                 lv_Master.companycode 
                from dual;
                
                select sysrowid into lv_sysrowid from gbl_acvoucher_pymt;
                
                delete from gbl_acvoucher_pymt;
                -- end
                insert into acbilldetails_entry
                (SYSROWID, COMPANYCODE, DIVISIONCODE, DIVISIONCODEFOR, 
                 YEARCODE, SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, 
                 TRANSACTIONDATE, BILLNO, BILLDATE, 
                 REFBILLNO, REFBILLDATE, ORIGINALBILLAMOUNT,ORIGINALDRCR,
                 BILLAMOUNT, DRCR, 
                 TRANSACTIONTYPE, MANUALAUTO, 
                 VOUCHERSERIALNO, ACCODEFOR, 
                 USERNAME
                )
                select             
                 lv_sysrowid,companycode,divisioncode, divisioncode as divisioncodefor,
                 yearcode,systemvoucherno,systemvoucherdate,
                 lv_Master.voucherdate as transactiondate,refbillno as billno, refbilldate as billdate,
                 lv_Master.voucherno as refbillno, lv_Master.voucherdate as refbilldate,amount as originalbillamount,drcr as originaldrcr, 
                 abs(lv_amount_adjusted) as billamount, (case when lv_amount_adjusted > 0 then 'D' else 'C' end ) as drcr,
                 'PURCHASE BILL ADJUSTMENT' as transactiontype,lv_automanualmark as manualauto,              
                  case when drcr='D' then lv_voucherserialno_dr else lv_voucherserialno_cr end as voucherserialno, accode as accodefor,
                  username
                from GBL_ACVOUCHER_LIB; 
            end if;

        end if; 

        -- tds part in acvoucherdetails_entry
        for data1 in (select * from GBL_actdsdetails_LIB order by tdstype) loop
            if data1.drcr = 'D' then
                lv_voucherserialno_dr := lv_voucherserialno_dr + 1;
            else
                lv_voucherserialno_cr := lv_voucherserialno_cr + 1;
            end if;
            
            insert into acvoucherdetails_entry
            (SYSROWID, COMPANYCODE, DIVISIONCODE, DIVISIONCODEFOR, 
             YEARCODE, SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, 
             AMOUNT, DRCR, ONACCOUNT, REMARKS, MASTERDETAILMARK, 
             ACCODEFOR, SERIALNOFOR, USERNAME
            )
            select             
             data1.sysrowid,data1.companycode,data1.divisioncode, data1.divisioncode as divisioncodefor,
             data1.yearcode,data1.systemvoucherno,data1.systemvoucherdate,
             data1.nettdsamount as amount,data1.drcr,'NONE' as onaccount,null as remarks,'D' as masterdetailmark,
             data1.accode as accodefor, lv_voucherserialno_cr as serialnofor, data1.username
            from dual;
            
             --AUTO VOUCHER 03/11/2020
            IF NVL(lv_automanualmark,'NA')='AUTO VOUCHER' THEN
            
              DELETE FROM ACTDSDETAILS_LIB
              WHERE COMPANYCODE=data1.COMPANYCODE
              AND DIVISIONCODE=data1.DIVISIONCODE
              AND YEARCODE=data1.YEARCODE
              AND SYSTEMVOUCHERNO=data1.SYSTEMVOUCHERNO;
            
              INSERT INTO ACTDSDETAILS_LIB(
                SYSROWID, COMPANYCODE, DIVISIONCODE, DIVISIONCODEFOR, YEARCODE, SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, TRANSACTIONDATE, ACCODE
                , TDSTYPE, PERCENTAGE, BILLNO, BILLDATE, BILLAMOUNT, TOTALTDSAMOUNT, NETAMOUNT, SERVICETAXAMOUNT, EDUCATIONCESSAMOUNT
                , NETTDSAMOUNT, DRCR, TDSDEDUCTEDON, TRANSACTIONTYPE, MANUALAUTO, SYNCHRONIZED, CERTIFICATENO, CERTIFICATEDATE
                , WITHEFFECTFROM, PARTYCODE, HSEDUCATIONCESSAMOUNT, REFSYSTEMVOUCHERNO, NETPERCENTAGE, BSRCODE, ACCODEFOR, USERNAME
                )
                SELECT data1.SYSROWID, data1.COMPANYCODE, data1.DIVISIONCODE, data1.DIVISIONCODEFOR, data1.YEARCODE, data1.SYSTEMVOUCHERNO
                , data1.SYSTEMVOUCHERDATE, data1.TRANSACTIONDATE, data1.ACCODE
                , data1.TDSTYPE, data1.PERCENTAGE, data1.BILLNO, data1.BILLDATE, data1.BILLAMOUNT, data1.TOTALTDSAMOUNT, data1.NETAMOUNT
                , data1.SERVICETAXAMOUNT, data1.EDUCATIONCESSAMOUNT
                , data1.NETTDSAMOUNT, data1.DRCR, data1.TDSDEDUCTEDON, data1.TRANSACTIONTYPE, data1.MANUALAUTO, data1.SYNCHRONIZED
                , data1.CERTIFICATENO, data1.CERTIFICATEDATE
                , data1.WITHEFFECTFROM, data1.PARTYCODE, data1.HSEDUCATIONCESSAMOUNT, data1.REFSYSTEMVOUCHERNO, data1.NETPERCENTAGE
                , data1.BSRCODE, data1.ACCODEFOR, data1.USERNAME
                FROM DUAL;
            END IF;
            
            --AUTO VOUCHER 03/11/2020

            -- tds part in actdsdetails_entry
            insert into actdsdetails_entry
            (SYSROWID, COMPANYCODE, DIVISIONCODE, DIVISIONCODEFOR, 
             YEARCODE, SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, 
             TRANSACTIONDATE, ACCODEFOR, TDSTYPE, PERCENTAGE, 
             BILLNO, BILLDATE, BILLAMOUNT, TOTALTDSAMOUNT, 
             NETAMOUNT, SERVICETAXAMOUNT, EDUCATIONCESSAMOUNT, 
             NETTDSAMOUNT, DRCR, TDSDEDUCTEDON, 
             TRANSACTIONTYPE, MANUALAUTO, PARTYCODE, 
             HSEDUCATIONCESSAMOUNT, NETPERCENTAGE, USERNAME
            )
            select             
             data1.sysrowid,data1.companycode,data1.divisioncode, data1.divisioncode as divisioncodefor,
             data1.yearcode,data1.systemvoucherno,data1.systemvoucherdate,
             lv_Master.voucherdate as transactiondate, data1.accode as accodefor, data1.tdstype,data1.percentage,
             lv_Master.refbillno as billno, lv_Master.refbilldate as billdate,data1.tdsdeductedon as billamount,data1.totaltdsamount,
             data1.netamount,data1.servicetaxamount, data1.educationcessamount, 
             data1.nettdsamount, data1.drcr, data1.tdsdeductedon, 
             'TDS LIABILITY' as transactiontype,lv_automanualmark as manualauto, data1.partycode,
             data1.hseducationcessamount, data1.percentage as netpercentage, data1.username
            from dual; 
        end loop;

        -- voucherdetails_part in acvoucherdetails_entry
        for data1 in (select * from GBL_acvoucherdetails_LIB) loop
            if data1.drcr = 'D' then
                lv_voucherserialno_dr := lv_voucherserialno_dr + 1;
            else
                lv_voucherserialno_cr := lv_voucherserialno_cr + 1;
            end if;

            insert into acvoucherdetails_entry
            (SYSROWID, COMPANYCODE, DIVISIONCODE, DIVISIONCODEFOR, 
             YEARCODE, SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, 
             AMOUNT, DRCR, ONACCOUNT, REMARKS, MASTERDETAILMARK, 
             ACCODEFOR, SERIALNOFOR, USERNAME,CASHFLOWCODE
            )
            select             
             data1.sysrowid,data1.companycode,data1.divisioncode, data1.divisioncodefor,
             data1.yearcode,data1.systemvoucherno,data1.systemvoucherdate,
             data1.amount,data1.drcr,'NONE' as onaccount,null as remarks,'D' as masterdetailmark,
             data1.accode as accodefor, case when data1.drcr='D' then lv_voucherserialno_dr else lv_voucherserialno_cr end  as serialnofor, data1.username,data1.CASHFLOWCODE
            from dual; 

            if lv_Master.transactiontype like 'ADVANCE%' then 
                insert into acadvancedetails_entry
                (SYSROWID, COMPANYCODE, DIVISIONCODE, DIVISIONCODEFOR, 
                 YEARCODE, SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE,  
                 REFERENCENO, REFERENCEDATE, AMOUNT, DRCR,
                 ORIGINALBILLAMOUNT,ORIGINALDRCR, 
                 TRANSACTIONTYPE, LASTMODIFIED, PARTYCODE, ACCODEFOR, USERNAME
                )
                select             
                 data1.sysrowid,data1.companycode,data1.divisioncode, data1.divisioncode as divisioncodefor,
                 data1.yearcode,data1.systemvoucherno,data1.systemvoucherdate,
                 lv_Master.refbillno as referenceno, lv_Master.refbilldate as referencedate,(lv_Master.amount-nvl(lv_Master.totaltdsamount,0)) as amount,case when lv_Master.drcr='D' then 'C' else 'D' end as drcr,
                 lv_Master.amount as originalbillamount,case when lv_Master.drcr='D' then 'C' else 'D' end as originaldrcr,
                 'LIABILITY FOR ADVANCE' as transactiontype,sysdate as lastmodified,lv_Master.accode as partycode,data1.accode as accodefor,data1.username
                from dual;
            end if;

        
            --- Inserting Data into AcCostcentreDeails_Entry
            -- Start
            insert into accostcentredetails_entry
            (SYSROWID, COMPANYCODE, DIVISIONCODE, YEARCODE, 
             SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, 
             VOUCHERSERIALNO, SERIALNO, COSTCENTRECODE, 
             AMOUNT, DRCR, DIVISIONCODEFOR, ACCODEFOR, USERNAME
            )
            select 
             SYSROWID, COMPANYCODE, DIVISIONCODE, YEARCODE, 
             SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, 
             voucherserialno as voucherserialno , SERIALNO, COSTCENTRECODE, 
             AMOUNT, DRCR, DIVISIONCODEFOR, ACCODEFOR, USERNAME
            from GBL_ACCOSTCENTREDETAILS_LIB
            where accode = data1.accode
              and voucherserialno = data1.serialno;
            --- End

        end loop;
        
        ---- Service Tax Details
        insert into acservicetaxdetails_entry
        (BILLNO, BILLDATE, BILLAMOUNT, 
         NATUREOFSERVICE, ABETMENTPERCENTAGE,COMPANYBOURNEPERCENTAGE, SERVICETAXON, 
         SERVICETAXPERCENT, EDUCATIONCESSPERCENT, HSEDUPERCENT, 
         SWACHHBHARATCESSPERCENT,KRISHIKALYANCESSPERCENT, SERVICETAXAMOUNT, EDUCATIONCESSAMOUNT, 
         HSEDUAMOUNT, SWACHHBHARATCESSAMOUNT,KRISHIKALYANCESSAMOUNT, NETTAXAMOUNT, 
         PARTYCODE, ACCODE, ACCODEFOR, 
         COMPANYCODE, DIVISIONCODE, YEARCODE, 
         SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, 
         USERNAME, SYSROWID, VOUCHERSERIALNO, 
         DIVISIONCODEFOR
        )
        select 
         BILLNO, BILLDATE, BILLAMOUNT, 
         NATUREOFSERVICE, ABETMENTPERCENTAGE,COMPANYBOURNEPERCENTAGE, SERVICETAXON, 
         SERVICETAXPERCENT, EDUCATIONCESSPERCENT, HSEDUPERCENT, 
         SWACHHBHARATCESSPERCENT,KRISHIKALYANCESSPERCENT, SERVICETAXAMOUNT, EDUCATIONCESSAMOUNT, 
         HSEDUAMOUNT, SWACHHBHARATCESSAMOUNT,KRISHIKALYANCESSAMOUNT, NETTAXAMOUNT, 
         PARTYCODE, ACCODE, ACCODE as accodefor, 
         COMPANYCODE, DIVISIONCODE, YEARCODE, 
         SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, 
         USERNAME, SYSROWID, VOUCHERSERIALNO, 
         DIVISIONCODEFOR
        from gbl_acservicetaxdetails_lib where nvl(nettaxamount,0)<>0;
        
        ---- GST Details
        insert into acgstdetails_entry
        (COMPANYCODE, DIVISIONCODE, DIVISIONCODEFOR, 
         YEARCODE, SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, 
         TRANSACTION_TYPE, TRANSACTION_NATURE, IS_TRAN_WITH_REGISTERED_PARTY, 
         ACCODEFOR, ACCODE, VOUCHERSERIALNO, 
         DRCR, GSTN_SENDER, GSTN_SENDER_NAME, 
         GSTN_SENDER_ADDRESS, GSTN_SENDER_STATECODE, GSTN_SENDER_STATENAME, 
         GSTN_RECIPIENT, GSTN_RECIPIENT_NAME, GSTN_RECIPIENT_ADDRESS, 
         GSTN_RECIPIENT_STATECODE, GSTN_RECIPIENT_STATENAME, GSTN_CONSINEE, 
         GSTN_CONSINEE_NAME, GSTN_CONSINEE_ADDRESS, GSTN_CONSINEE_STATECODE, 
         GSTN_CONSINEE_STATENAME, PLACE_OF_SUPPLY_STATECODE, PLACE_OF_SUPPLY_STATENAME, 
         INVOICE_NO, INVOICE_DATE, DEBIT_CREDIT_NOTE_NO, 
         DEBIT_CREDIT_NOTE_DATE, SHIPPING_BILL_NO, SHIPPING_BILL_DATE, 
         IS_REVERSE_CHARGE_BY_RECIPIENT, SERIAL_NO, HSN_SAC_CODE, 
         HSN_SAC_DESCRIPTION, IS_GOODS_OR_SERVICE, IS_EXEMPTED, 
         INPUT_CREDIT_AVAILABLE, ITEM_DESCRIPTION, UOM, 
         QUANTITY, RATE_PER_UNIT, HSN_SAC_AMOUNT, 
         DISCOUNT_PER_UNIT, DISCOUNT_PERCENTAGE, DISCOUNT_AMOUNT, 
         HSN_SAC_ASSESSABLE_AMOUNT, TAX_PERCENTAGE, IGST_RATE, 
         IGST_AMOUNT, CGST_RATE, CGST_AMOUNT, 
         SGST_RATE, SGST_AMOUNT, CESS_RATE, 
         CESS_AMOUNT, SYSROWID, USERNAME, 
         PARTYCODE
        )
        select 
         COMPANYCODE, DIVISIONCODE, DIVISIONCODEFOR, 
         YEARCODE, SYSTEMVOUCHERNO, SYSTEMVOUCHERDATE, 
         TRANSACTION_TYPE, TRANSACTION_NATURE, IS_TRAN_WITH_REGISTERED_PARTY, 
         ACCODEFOR, ACCODE, VOUCHERSERIALNO, 
         DRCR, GSTN_SENDER, GSTN_SENDER_NAME, 
         GSTN_SENDER_ADDRESS, GSTN_SENDER_STATECODE, GSTN_SENDER_STATENAME, 
         GSTN_RECIPIENT, GSTN_RECIPIENT_NAME, GSTN_RECIPIENT_ADDRESS, 
         GSTN_RECIPIENT_STATECODE, GSTN_RECIPIENT_STATENAME, GSTN_CONSINEE, 
         GSTN_CONSINEE_NAME, GSTN_CONSINEE_ADDRESS, GSTN_CONSINEE_STATECODE, 
         GSTN_CONSINEE_STATENAME, PLACE_OF_SUPPLY_STATECODE, PLACE_OF_SUPPLY_STATENAME, 
         INVOICE_NO, INVOICE_DATE, DEBIT_CREDIT_NOTE_NO, 
         DEBIT_CREDIT_NOTE_DATE, SHIPPING_BILL_NO, SHIPPING_BILL_DATE, 
         IS_REVERSE_CHARGE_BY_RECIPIENT, SERIAL_NO, HSN_SAC_CODE, 
         HSN_SAC_DESCRIPTION, IS_GOODS_OR_SERVICE, IS_EXEMPTED, 
         INPUT_CREDIT_AVAILABLE, ITEM_DESCRIPTION, UOM, 
         QUANTITY, RATE_PER_UNIT, HSN_SAC_AMOUNT, 
         DISCOUNT_PER_UNIT, DISCOUNT_PERCENTAGE, DISCOUNT_AMOUNT, 
         HSN_SAC_ASSESSABLE_AMOUNT, TAX_PERCENTAGE, IGST_RATE, 
         IGST_AMOUNT, CGST_RATE, CGST_AMOUNT, 
         SGST_RATE, SGST_AMOUNT, CESS_RATE, 
         CESS_AMOUNT, SYSROWID, USERNAME, 
         PARTYCODE        
         from gbl_acgstdetails_lib;
      
----        
--        IF FN_DRCR_MISMATCH(LV_MASTER.COMPANYCODE,LV_MASTER.DIVISIONCODE, LV_MASTER.YEARCODE,LV_MASTER.SYSTEMVOUCHERNO) > 0 THEN
--            LV_ERROR_REMARK := 'VALIDATION FAILURE : [TOTAL DEBIT AMOUNT IS NOT MATCHED WITH TOTAL CREDIT AMOUNT.... HENCE VOUCHER COULD NOT BE SAVED]';
--            RAISE_APPLICATION_ERROR(TO_NUMBER(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,LV_ERROR_REMARK));
--        END IF;
--      
       
        if fn_tds_mismatch(lv_Master.companycode,lv_Master.divisioncode, lv_Master.yearcode,lv_Master.systemvoucherno) > 0 then
            lv_error_remark := 'Validation Failure : [TDS Amount of Voucher is not matching with TDS amount of TDS Details... Hence Voucher could not be saved]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;
        
        if fn_GST_mismatch(lv_Master.companycode,lv_Master.divisioncode, lv_Master.yearcode,lv_Master.systemvoucherno) > 0 then
            lv_error_remark := 'Validation Failure : [GST Amount of Voucher is not matching with GST amount of GST Details... Hence Voucher could not be saved]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;
        
        if fn_bill_mismatch(lv_Master.companycode,lv_Master.divisioncode, lv_Master.yearcode,lv_Master.systemvoucherno) > 0 then
            lv_error_remark := 'Validation Failure : [Bill Amount of Voucher is not matching with Bill Amount of Bill Details.... Hence Voucher could not be saved]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;

-- Cehcking if there is any over Payment
        for bill in (select * from acbilldetails
                     where companycode = lv_Master.companycode
                       and divisioncode = lv_Master.divisioncode
                       and yearcode = lv_Master.yearcode
                       and systemvoucherno = lv_Master.systemvoucherno
                    ) loop
            if fn_bill_check_overpayment(bill.companycode,bill.divisioncode,bill.accode,bill.billno,to_char(bill.billdate,'dd/mm/yyyy'),bill.originalbillamount,bill.originaldrcr,bill.refbillno,case when bill.refbillno is null then null else to_char(bill.refbilldate,'dd/mm/yyyy') end ) > 0 then            
                lv_error_remark := 'Validation Failure : [Over adjustment against Ref No : ' || bill.billno || ' Dated : ' || to_char(bill.billdate,'dd/mm/yyyy') || ' is not allowed .... Hence could not be saved]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;
        end loop;
       --
       
        if nvl(lv_Master.OperationMode,'NA') = 'A' then
            select count(*)
            into lv_cnt
            from SYS_GBL_PROCOUTPUT_INFO;
                
            if lv_cnt = 0 then
                insert into SYS_GBL_PROCOUTPUT_INFO
                values ('[SYSTEM VOUCHER NUMBER GENERATED: ' || lv_Master.SYSTEMVOUCHERNO || ' Dated : ' || to_date(lv_Master.SYSTEMVOUCHERDATE,'dd/mm/yyyy') || ']');
            else
                update SYS_GBL_PROCOUTPUT_INFO
                set SYS_SAVE_INFO = nvl(SYS_SAVE_INFO,'') || '<br/>' || ('[SYSTEM VOUCHER NUMBER GENERATED: ' || lv_Master.SYSTEMVOUCHERNO || ' Dated : ' || to_date(lv_Master.SYSTEMVOUCHERDATE,'dd/mm/yyyy') || ']');
            end if;        
        end if;
               

        if nvl(lv_Master.OperationMode,'NA') = 'M' and lv_Master.transactiontype like '%-%APPROVED' then 
            
            if lv_Master.voucherdate is null then
                ----dbms_output.put_line ('companycode ,divisioncode, yearcode ' || lv_Master.companycode || ',' || lv_Master.divisioncode || ',' || lv_Master.yearcode);
                select to_char(case when trunc(sysdate) > enddate then enddate else trunc(sysdate) end,'dd/mm/yyyy')
                into lv_voucherdate
                from financialyear
                where companycode = lv_Master.companycode
                  and divisioncode = lv_Master.divisioncode
                  and yearcode = lv_Master.yearcode;
            else
                lv_voucherdate := to_char(lv_Master.voucherdate,'dd/mm/yyyy');
            end if;

            if lv_Master.voucherno is null then
                -------- generating the voucher number when authorised
                select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'AC_VOUCHERNO_PURCHASE_MANUAL',lv_voucherdate) 
                into lv_voucherno
                from dual;
            else
                lv_voucherno := lv_Master.voucherno;
            end if;

            update GBL_ACVOUCHER_LIB
            set voucherdate = to_date(lv_voucherdate,'dd/mm/yyyy'),
                voucherno = lv_voucherno;
                
            update GBL_ACTDSDETAILS_LIB
            set transactiondate = to_date(lv_voucherdate,'dd/mm/yyyy');

            update GBL_ACBILLDETAILS_LIB
            set transactiondate = to_date(lv_voucherdate,'dd/mm/yyyy');

            --update GBL_ACSERVICETAXDETAILS_LIB
            --set systemvoucherdate = trunc(sysdate);
                
            select *
            into lv_Master
            from GBL_ACVOUCHER_LIB;

            update acvoucher
            set voucherno = lv_Master.voucherno,
                voucherdate = lv_Master.voucherdate
            where companycode = lv_Master.companycode
              and divisioncode = lv_Master.divisioncode
              and yearcode = lv_Master.yearcode
              and systemvoucherno = lv_Master.systemvoucherno;
                  
            update acbilldetails_entry
            set transactiondate = lv_Master.voucherdate
            where companycode = lv_Master.companycode
              and divisioncode = lv_Master.divisioncode
              and yearcode = lv_Master.yearcode
              and systemvoucherno = lv_Master.systemvoucherno;

            update actdsdetails_entry
            set transactiondate = lv_Master.voucherdate
            where companycode = lv_Master.companycode
              and divisioncode = lv_Master.divisioncode
              and yearcode = lv_Master.yearcode
              and systemvoucherno = lv_Master.systemvoucherno;

            update acadvancedetails_entry
            set transactiondate = lv_Master.voucherdate,
                billno = lv_Master.VoucherNo,
                billdate = lv_Master.voucherdate
            where companycode = lv_Master.companycode
              and divisioncode = lv_Master.divisioncode
              and yearcode = lv_Master.yearcode
              and systemvoucherno = lv_Master.systemvoucherno;
                  
            select count(*)
            into lv_cnt
            from SYS_GBL_PROCOUTPUT_INFO;
                    
            if lv_cnt = 0 then
                insert into SYS_GBL_PROCOUTPUT_INFO
                values ('[VOUCHER APPROVED xx GENERATED: ' || lv_Master.VOUCHERNO || ' Dated : ' || to_date(lv_Master.VOUCHERDATE,'dd/mm/yyyy') || ']');
            else
                update SYS_GBL_PROCOUTPUT_INFO
                set SYS_SAVE_INFO = nvl(SYS_SAVE_INFO,'') || '<br/>' || ('[VOUCHER APPROVED  GENERATED: ' || lv_Master.VOUCHERNO || ' Dated : ' || to_date(lv_Master.VOUCHERDATE,'dd/mm/yyyy') || ']');
            end if;                  

        end if;    
        
         -- added by sudipta on 20/01/2020 for update checkedby column in acvoucher 
         if nvl(lv_Master.OperationMode,'NA') = 'M' and lv_Master.transactiontype like '%CHECKED' then 
            select *
            into lv_Master
            from GBL_ACVOUCHER_LIB;

            update acvoucher
            set checkedby = lv_Master.username,
                checkeddate = trunc(sysdate),
                PREPAREDBY=lv_PREPAREDBY,
                PREPAREDDATE=TO_DATE(lv_PREPAREDDATE,'DD/MM/YYYY')
            where companycode = lv_Master.companycode
              and divisioncode = lv_Master.divisioncode
              and yearcode = lv_Master.yearcode
              and systemvoucherno = lv_Master.systemvoucherno;
              --and checkedby is null;
         end if;
         
 /*       
        -- added by sudipta on 07/01/2020 for update checkedby column in acvoucher 
        lv_AllowCheckedBy:=FN_GET_SYS_PARAM_VALUE(lv_Master.companycode, lv_Master.divisioncode,'ACCOUNTS','CHECKEDBY');
         if lv_AllowCheckedBy = 'NO' then         
            update ACVOUCHER
                set checkeddate = lv_systemvoucherdate,
                    checkedby = lv_Master.username
                where companycode = lv_Master.companycode
                and divisioncode = lv_Master.divisioncode
                and yearcode = lv_Master.yearcode
                and systemvoucherno = lv_Master.systemvoucherno
                and checkedby is null;
         end if;
  */          
    end if;
---------------------------------------    Numbering    

--    if nvl(lv_Master.OperationMode,'NA') = 'D' then
--        select count(*)
--        into lv_cnt
--        from acvoucher
--        where companycode = lv_Master.Companycode
--          and divisioncode = lv_Master.Divisioncode
--          and yearcode = lv_Master.Yearcode
--          and systemvoucherno = lv_Master.Systemvoucherno
--          and voucherno is not null ;
--          
--        if lv_cnt > 0 then
--            lv_error_remark := 'Validation Failure : [The Voucher has already been passed. Could not be deleted....';
--            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
--        end if;
--
--        prc_delete_systemvoucher(lv_master.companycode,lv_master.divisioncode,lv_master.yearcode,lv_master.systemvoucherno);
--        delete from acbilldetails_entry
--        where companycode = lv_Master.companycode
--          and divisioncode = lv_Master.divisioncode
--          and yearcode = lv_Master.yearcode
--          and systemvoucherno = lv_Master.systemvoucherno;

--        delete from actdsdetails_entry
--        where companycode = lv_Master.companycode
--          and divisioncode = lv_Master.divisioncode
--          and yearcode = lv_Master.yearcode
--          and systemvoucherno = lv_Master.systemvoucherno;

--        delete from accostcentredetails_entry
--        where companycode = lv_Master.companycode
--          and divisioncode = lv_Master.divisioncode
--          and yearcode = lv_Master.yearcode
--          and systemvoucherno = lv_Master.systemvoucherno;

--        delete from acservicetaxdetails_entry
--        where companycode = lv_Master.companycode
--          and divisioncode = lv_Master.divisioncode
--          and yearcode = lv_Master.yearcode
--          and systemvoucherno = lv_Master.systemvoucherno;

--        delete from acvoucherdetails_entry
--        where companycode = lv_Master.companycode
--          and divisioncode = lv_Master.divisioncode
--          and yearcode = lv_Master.yearcode
--          and systemvoucherno = lv_Master.systemvoucherno;

--        delete from acadvancedetails_entry
--        where companycode = lv_Master.companycode
--          and divisioncode = lv_Master.divisioncode
--          and yearcode = lv_Master.yearcode
--          and systemvoucherno = lv_Master.systemvoucherno;

--        delete from acvoucher
--        where companycode = lv_Master.companycode
--          and divisioncode = lv_Master.divisioncode
--          and yearcode = lv_Master.yearcode
--          and systemvoucherno = lv_Master.systemvoucherno;

--    end if;


--exception when others then
--    lv_error_remark:= lv_error_remark || '#UNSUCC#ESSFULL#';
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
end;
/
