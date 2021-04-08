CREATE OR REPLACE PROCEDURE BOWREAH_WEB."PRCSALES_DRCR_POSTING_TO_ACC" (p_companycode varchar2,
                                                         p_divisioncode varchar2,
                                                         p_yearcode varchar2,
                                                         p_salebillno varchar2
                                                         )
is
-- Sales Posting to Accounts from SalesBillMaster
lv_cnt                  number;
lv_cnt_temp             number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000);
lv_systemvoucherno      varchar2(100);
lv_systemvoucherdate    varchar2(10);
lv_Master               SalesBillMaster%rowtype;
lv_voucherno            varchar2(100);
lv_voucherdate          varchar2(10);
lv_divisioncode_target  varchar2(100);
lv_accode_debtor        varchar2(100);
lv_accode_sales         varchar2(100);
lv_amount               number;
lv_amount_dr            number;
lv_amount_cr            number;
lv_sysrowid             varchar2(50);
lv_partyname            varchar2(1000);
lv_narration            varchar(4000);
lv_serialno_dr          number;
lv_serialno_cr          number;
lv_FinYearEndDate       varchar2(10) :='';
lv_documenttype         varchar(20);
lv_refinvno             varchar(20);
lv_refinvdt             date;
LV_TDSNATURE            varchar2(200);
LV_TCSRATE                       NUMBER(18,2);
lv_tdscode                      varchar2(50);

begin
    lv_result:='#SUCCESS#';

    select count(*)
    into lv_cnt
    from SalesBillMaster
    where companycode = p_companycode
      and divisioncode = p_divisioncode
      and salebillno = p_salebillno;
   
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [Debit/Credit Note No is not found in Sales Bill Master]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    if lv_cnt > 1 then
        lv_error_remark := 'Validation Failure : [Multiple Debit/Credit Note is found in Sales Bill Master.. Can not Proceed..]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;

    select *
    into lv_Master
    from SalesBillMaster
    where companycode = p_companycode
      and divisioncode = p_divisioncode
      and salebillno = p_salebillno;
    
    select referencetype,againstinvno,againstinvdate
    into lv_documenttype,lv_refinvno,lv_refinvdt
    from salesdebitcreditnotemaster
    where companycode = p_companycode
      and divisioncode = p_divisioncode
      and debitcreditnoteno = p_salebillno;
    
    -- Deriving the Posting Division
    select count(*)
    into lv_cnt
    from SYS_PARAM_ACPOST_DIRECTION
    where companycode = p_companycode
      and divisioncode_source = p_divisioncode
      and modulename = 'SALES'
      and posting_param_name = 'SALES POSTING TO ACCOUNTS';
    
    if lv_cnt = 0 then
        lv_error_remark := '[Posting Parameter in SYS_PARAM_ACPOST_DIRECTION table is not defined... Report Softweb....]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;

    select divisioncode_target
    into lv_divisioncode_target
    from SYS_PARAM_ACPOST_DIRECTION
    where companycode = p_companycode
      and divisioncode_source = p_divisioncode
      and modulename = 'SALES'
      and posting_param_name = 'SALES POSTING TO ACCOUNTS';

    select partyname
    into lv_partyname
    from partymaster
    where module='SALES'
      and companycode = p_companycode
      and partycode = lv_Master.buyercode; 
      
    select accode 
    into lv_accode_debtor
    from SYS_PARAM_ACPOST_PARTY
    where companycode = p_companycode
      and modulename = 'SALES'
      and partycode = lv_Master.buyercode;

    if nvl(lv_accode_debtor,'~NA~') = '~NA~' then
        lv_error_remark := '[Account Ledger Head for Buyer [' || lv_partyname || '] is not mapped with Party Code in SYS_PARAM_ACPOST_PARTY table... Report Softweb....]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;

    lv_voucherno := lv_Master.salebillno;
    lv_voucherdate := to_char(lv_Master.salebilldate,'dd/mm/yyyy');
    
    select to_char(enddate,'dd/mm/yyyy')
    into lv_FinYearEndDate
    from financialyear
    where companycode = lv_Master.companycode
      and divisioncode = lv_Master.divisioncode
      and yearcode = lv_Master.yearcode;
      
    if trunc(sysdate) > to_date(lv_FinYearEndDate,'dd/mm/yyyy') then 
        lv_systemvoucherdate := lv_FinYearEndDate;
    else
        lv_systemvoucherdate := to_char(trunc(sysdate),'dd/mm/yyyy');    
    end if;

    -- Checking whether the same document is already present in Accounts 
    select count(*)
    into lv_cnt
    from acvoucher
    where companycode = p_companycode
      and divisioncode = lv_divisioncode_target
      and yearcode = p_yearcode
      and voucherno = lv_voucherno
      and modulename = 'SALES'
      and documenttype = lv_documenttype
      and automanualmark = 'AUTO VOUCHER';

    if lv_cnt > 0 then
        select systemvoucherno
        into lv_systemvoucherno
        from acvoucher
        where companycode = p_companycode
          and divisioncode = lv_divisioncode_target
          and yearcode = p_yearcode
          and voucherno = lv_voucherno
          and modulename = 'SALES'
          and documenttype = lv_documenttype
          and automanualmark = 'AUTO VOUCHER';
        
        -- before reposting checking whether receipt is already been takes place  
        -- Start
        select count(*)
        into lv_cnt_temp
        from acbilldetails
        where companycode = p_companycode
          and divisioncode = lv_divisioncode_target
          and accode = lv_accode_debtor
          and billno = lv_voucherno
          and billdate = to_date(lv_voucherdate,'dd/mm/yyyy')
          and transactiontype like 'SALE%BILL%ADJ%'
          and drcr=decode(lv_documenttype,'DEBIT NOTE','C','D');
        
        if lv_cnt_temp > 0 then
            lv_error_remark := 'Validation Failure : [Next Step Entries against this Document No is found.. Hence you are not allowed to change this Document..]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;  
        --- End  
    else
        select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'AC_SYS_VOUCHERNO_SALES_BILL',lv_systemvoucherdate) 
        into lv_systemvoucherno
        from dual;
    end if;
               
    if lv_cnt > 0 then        
        prc_delete_systemvoucher(p_companycode,lv_divisioncode_target,p_yearcode,lv_systemvoucherno,'FORCED');
    end if;

    -- start
    -- inserting into gbl_acvoucher_sales    
    
    /*
    lv_narration := '';  -- sudipta

    delete from gbl_acvoucher_sales;
                
    insert into gbl_acvoucher_sales
    (DOCUMENTTYPE, TRANSACTIONTYPE, DRCR, 
     TDSONAMOUNT, REFERENCETYPE, COMPANYCODE, 
     ACCODE, REFBILLNO, TOTALTDSAMOUNT, 
     USERNAME, AUTOMANUALMARK,  
     DIVISIONCODE, REFBILLDATE, YEARCODE, 
     SYSTEMVOUCHERDATE, NARRATION, 
     AMOUNT, SYSTEMVOUCHERNO, 
     OPERATIONMODE, MODULENAME,
     VOUCHERNO,VOUCHERDATE
    )
    select 
     --'SALE BILL','AGAINST BILL', 'D', 
     lv_documenttype,'AGAINST BILL', decode(lv_documenttype,'DEBIT NOTE','D','C'),
     0, 'AGAINST BILL', lv_Master.companycode, 
     --lv_accode_debtor, lv_Master.salebillno, 0, 
     lv_accode_debtor, lv_refinvno, 0,
     lv_Master.username, 'AUTO VOUCHER',  
     --lv_divisioncode_target, lv_Master.salebilldate, lv_Master.yearcode, 
     lv_divisioncode_target, lv_refinvdt, lv_Master.yearcode,
     to_date(lv_systemvoucherdate,'dd/mm/yyyy'), lv_narration, 
     lv_Master.grossamountinr, lv_systemvoucherno, 
     'A', 'SALES',
     lv_voucherno,to_date(lv_voucherdate,'dd/mm/yyyy')
    from dual;
    */
    
    
    lv_narration := lv_documenttype || ' AGAINST INVOICE NUMBER : ' || lv_refinvno || ' Dated : ' || to_char(lv_refinvdt,'dd/mm/yyyy');

    delete from gbl_acvoucher_sales;
                
    insert into gbl_acvoucher_sales
    (DOCUMENTTYPE, TRANSACTIONTYPE, DRCR, 
     TDSONAMOUNT, REFERENCETYPE, COMPANYCODE, 
     ACCODE, REFBILLNO, TOTALTDSAMOUNT, 
     USERNAME, AUTOMANUALMARK,  
     DIVISIONCODE, REFBILLDATE, YEARCODE, 
     SYSTEMVOUCHERDATE, NARRATION, 
     AMOUNT, SYSTEMVOUCHERNO, 
     OPERATIONMODE, MODULENAME,
     VOUCHERNO,VOUCHERDATE
    )
    select 
     --'PREV SALE BILL','AGAINST BILL', 'D', 
     lv_documenttype,'AGAINST BILL', decode(lv_documenttype,'DEBIT NOTE','D','C'),
     0, 'AGAINST BILL', lv_Master.companycode, 
     --ORIGINAL lv_accode_debtor, lv_Master.salebillno, 0, 
     --OLD lv_accode_debtor, lv_refinvno, 0,
     lv_accode_debtor, lv_voucherno, 0,                          -- reverse billno vs ref billno
     lv_Master.username, 'AUTO VOUCHER',  
     --ORIGINAL lv_divisioncode_target, lv_Master.salebilldate, lv_Master.yearcode, 
     -- OLD lv_divisioncode_target, lv_refinvdt, lv_Master.yearcode,
     lv_divisioncode_target, to_date(lv_voucherdate,'dd/mm/yyyy'), lv_Master.yearcode,  --reverse refbillno vs bill date 
     to_date(lv_systemvoucherdate,'dd/mm/yyyy'), lv_narration, 
     lv_Master.grossamountinr, lv_systemvoucherno, 
     'A', 'SALES',
     lv_voucherno,to_date(lv_voucherdate,'dd/mm/yyyy')
    from dual;

    -- inserting into acvoucher_sales
    insert into acvoucher_sales
    (DOCUMENTTYPE, TRANSACTIONTYPE, DRCR, 
     TDSONAMOUNT, REFERENCETYPE, COMPANYCODE, 
     ACCODE, REFBILLNO, TOTALTDSAMOUNT, 
     USERNAME, AUTOMANUALMARK,  
     DIVISIONCODE, REFBILLDATE, YEARCODE, 
     SYSTEMVOUCHERDATE, NARRATION, 
     AMOUNT, SYSTEMVOUCHERNO, 
     MODULENAME,SYSROWID,
     VOUCHERNO,VOUCHERDATE
    )
    select 
     DOCUMENTTYPE, TRANSACTIONTYPE, DRCR, 
     TDSONAMOUNT, REFERENCETYPE, COMPANYCODE, 
     ACCODE, REFBILLNO, TOTALTDSAMOUNT, 
     USERNAME, AUTOMANUALMARK,  
     DIVISIONCODE, REFBILLDATE, YEARCODE, 
     SYSTEMVOUCHERDATE, NARRATION, 
     AMOUNT, SYSTEMVOUCHERNO, 
     MODULENAME,SYSROWID,
     VOUCHERNO,VOUCHERDATE
    from gbl_acvoucher_sales;


    -- Posting of Sales Part into AcvoucherDetails_sales
    -- inserting into gbl_acvoucherdetails_sales
    -- there may be a chance of Sales of multiple quality in one Sales Bill
    lv_serialno_dr := 100;
    lv_serialno_cr := 200;
    for c1 in (select qualitygroupcode,channelcode,
                      sum(totalindianamount) as salesamount 
                      from salesbillview
               where companycode = lv_Master.companycode
                 and divisioncode = lv_Master.divisioncode
                 and yearcode = lv_Master.yearcode
                 and salebillno = lv_Master.salebillno
               group by qualitygroupcode,channelcode
              ) loop

        select accode
        into lv_accode_sales
        from sys_param_acpost_sales
        where companycode = lv_Master.companycode
          and divisioncode = lv_Master.divisioncode
          and modulename = 'SALES'
          and posting_param_name = 'SALES POSTING TO ACCOUNTS'
          and quality_group_code = c1.qualitygroupcode
          and channelcode = c1.channelcode;
    
        if nvl(lv_accode_sales,'~NA~') = '~NA~' then
            lv_error_remark := '[Account Ledger Head for Quality : [' || c1.qualitygroupcode  ||'] & Channel : ['|| c1.channelcode ||'] is not mapped with Quality Type & Channel in SYS_PARAM_ACPOST_SALES table... Report Softweb....]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;

        if lv_documenttype='DEBIT NOTE' then      
            insert into gbl_acvoucherdetails_sales
            (TDSON, USERNAME, DIVISIONCODE, 
             YEARCODE, AMOUNT, 
             OPERATIONMODE, TRANSACTIONTYPE, 
             SYSTEMVOUCHERNO,SYSTEMVOUCHERDATE, 
             COMPANYCODE, ACCODE, DRCR,SERIALNO
            )
            select 
             0,lv_Master.username,lv_divisioncode_target,
             lv_Master.yearcode,c1.salesamount,
             'A','NONE',
             lv_systemvoucherno,to_date(lv_systemvoucherdate,'dd/mm/yyyy'),
             lv_Master.companycode,lv_accode_sales,'C',lv_serialno_cr
            from dual;
        end if;
        
        if lv_documenttype='CREDIT NOTE' then      
            insert into gbl_acvoucherdetails_sales
            (TDSON, USERNAME, DIVISIONCODE, 
             YEARCODE, AMOUNT, 
             OPERATIONMODE, TRANSACTIONTYPE, 
             SYSTEMVOUCHERNO,SYSTEMVOUCHERDATE, 
             COMPANYCODE, ACCODE, DRCR,SERIALNO
            )
            select 
             0,lv_Master.username,lv_divisioncode_target,
             lv_Master.yearcode,c1.salesamount,
             'A','NONE',
             lv_systemvoucherno,to_date(lv_systemvoucherdate,'dd/mm/yyyy'),
             lv_Master.companycode,lv_accode_sales,'D',lv_serialno_cr
            from dual;
        end if;
                
        lv_serialno_cr := lv_serialno_cr + 1;
                
    end loop;



    if lv_documenttype='DEBIT NOTE' then
        for c1 in ( select a.chargecode,b.chargeshortname,a.chargeamount,
                           case when b.addless = 'ADDITION' then 'C' else 'D' end as drcr,
                           b.accode,NVL(B.RATEPERUNIT,0) RATEPERUNIT,a.assessableamount
                    from saleschargedetails a,chargemaster b
                    where a.companycode = lv_Master.companycode
                      and a.divisioncode = lv_Master.divisioncode
                      and a.yearcode = lv_Master.yearcode
                      and a.documenttype ='DEBIT NOTE'
                      and a.channelcode = lv_Master.channelcode
                      and a.documentno = lv_Master.salebillno
                      and a.companycode = b.companycode
                      and a.divisioncode = b.divisioncode
                      and b.module='SALES'
                      and a.chargecode = b.chargecode
                      and a.channelcode = b.channelcode
                      and b.addless in ('ADDITION','SUBSTRACTION')
                    order by b.serialno
                  ) loop

            
            if nvl(c1.accode,'~NA~') = '~NA~' then
                lv_error_remark := '[Account Ledger Head for SALES CHARGES : [' || c1.chargeshortname || '] is not mapped with in SALES CHARGE definition... Report Softweb....]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;
            
           


            insert into gbl_acvoucherdetails_sales
            (TDSON, USERNAME, DIVISIONCODE, 
             YEARCODE, AMOUNT, 
             OPERATIONMODE, TRANSACTIONTYPE, 
             SYSTEMVOUCHERNO,SYSTEMVOUCHERDATE, 
             COMPANYCODE, ACCODE, DRCR,SERIALNO
            )
            select 
             0,lv_Master.username,lv_divisioncode_target,
             lv_Master.yearcode,c1.chargeamount,
             'A','NONE',
             lv_systemvoucherno,to_date(lv_systemvoucherdate,'dd/mm/yyyy'),
             lv_Master.companycode,c1.accode,c1.drcr,case when c1.drcr = 'D' then lv_serialno_dr else lv_serialno_cr end as drcr
            from dual;
            
            
        --**TDS INSERT ***************************
        SELECT COUNT(*)
        INTO lv_cnt 
        FROM ACACLEDGER 
        WHERE COMPANYCODE=lv_Master.companycode
          AND GROUPTYPE='TDS'
          and ACCODE=c1.accode;
         
        IF lv_cnt>0 THEN 
        
            if nvl(c1.RATEPERUNIT,0) = 0 then
                lv_error_remark := '[Rate cannot be 0 for  SALES CHARGES : [' || c1.chargeshortname || ']. Report Softweb....]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;
        
              select m.tdscode
                    into lv_tdscode
                    from actdsledgermaster m
                    where m.companycode = lv_master.companycode
                    and m.accode=c1.accode
                    and m.witheffectfrom = (select max(sm.witheffectfrom)
                                           from actdsledgermaster sm
                                           where sm.companycode = lv_master.companycode
                                             and sm.accode = m.accode
                                             and sm.witheffectfrom <= lv_master.salebilldate
                                          );
                                          
                    select m.TDSNATURE
                    INTO LV_TDSNATURE
                    from actdsmaster m
                    where m.companycode = lv_master.companycode
                    and m.TDSCODE=lv_tdscode
                    and m.witheffectfrom = (select max(sm.witheffectfrom)
                                           from actdsmaster sm
                                           where sm.companycode = lv_master.companycode
                                             and sm.TDSCODE = m.TDSCODE
                                             and sm.WITHEFFECTFROM <= lv_master.salebilldate
                                          );  
    
             insert into ACTDSDETAILS_ENTRY
                   ( companycode, divisioncode, divisioncodefor, yearcode, 
                    systemvoucherno, systemvoucherdate, transactiondate, accode, tdstype, 
                    percentage, billno, billdate, billamount, totaltdsamount, 
                    netamount, servicetaxamount, educationcessamount, nettdsamount, drcr, 
                    tdsdeductedon, transactiontype, manualauto, synchronized, 
                    certificateno, certificatedate, witheffectfrom, partycode, hseducationcessamount, 
                    refsystemvoucherno, netpercentage, bsrcode, accodefor, username,LASTMODIFIED)
                   values
                   (lv_master.companycode, lv_divisioncode_target, lv_divisioncode_target, lv_master.yearcode, 
                    lv_systemvoucherno, to_date(lv_systemvoucherdate,'dd/mm/yyyy'), to_date(lv_systemvoucherdate,'dd/mm/yyyy'), c1.accode, LV_TDSNATURE, 
                    c1.rateperunit, lv_master.salebillno, lv_master.salebilldate, nvl(c1.assessableamount,0), c1.chargeamount, 
                    (nvl(c1.assessableamount,0) - nvl(c1.chargeamount,0)), 0, 0, c1.chargeamount, 'C', 
                    nvl(c1.assessableamount,0), 'TDS LIABILITY', 'AUTO VOUCHER', null, 
                    null, null, null, lv_accode_debtor, 0, 
                    null, c1.rateperunit, null, c1.accode, lv_master.username,SYSDATE);  
            
        END IF;

       --**END TDS INSERT **********************
        
            
            if c1.drcr = 'D' then 
                lv_serialno_dr := lv_serialno_dr + 1;
            else 
                lv_serialno_cr := lv_serialno_cr + 1;
            end if;
        end loop;                 
    end if;
    
    if lv_documenttype='CREDIT NOTE' then
        for c1 in ( select a.chargecode,b.chargeshortname,a.chargeamount,
                           case when b.addless = 'ADDITION' then 'D' else 'C' end as drcr,
                           b.accode,NVL(B.RATEPERUNIT,0) RATEPERUNIT,a.assessableamount
                    from saleschargedetails a,chargemaster b
                    where a.companycode = lv_Master.companycode
                      and a.divisioncode = lv_Master.divisioncode
                      and a.yearcode = lv_Master.yearcode
                      and a.documenttype ='CREDIT NOTE'
                      and a.channelcode = lv_Master.channelcode
                      and a.documentno = lv_Master.salebillno
                      and a.companycode = b.companycode
                      and a.divisioncode = b.divisioncode
                      and b.module='SALES'
                      and a.chargecode = b.chargecode
                      and a.channelcode = b.channelcode
                      and b.addless in ('ADDITION','SUBSTRACTION')
                    order by b.serialno
                  ) loop

            
            if nvl(c1.accode,'~NA~') = '~NA~' then
                lv_error_remark := '[Account Ledger Head for SALES CHARGES : [' || c1.chargeshortname || '] is not mapped with in SALES CHARGE definition... Report Softweb....]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;
            
           


            insert into gbl_acvoucherdetails_sales
            (TDSON, USERNAME, DIVISIONCODE, 
             YEARCODE, AMOUNT, 
             OPERATIONMODE, TRANSACTIONTYPE, 
             SYSTEMVOUCHERNO,SYSTEMVOUCHERDATE, 
             COMPANYCODE, ACCODE, DRCR,SERIALNO
            )
            select 
             0,lv_Master.username,lv_divisioncode_target,
             lv_Master.yearcode,c1.chargeamount,
             'A','NONE',
             lv_systemvoucherno,to_date(lv_systemvoucherdate,'dd/mm/yyyy'),
             lv_Master.companycode,c1.accode,c1.drcr,case when c1.drcr = 'C' then lv_serialno_dr else lv_serialno_cr end as drcr
            from dual;
            
            --**TDS INSERT ***************************
        SELECT COUNT(*)
        INTO lv_cnt 
        FROM ACACLEDGER 
        WHERE COMPANYCODE=lv_Master.companycode
          AND GROUPTYPE='TDS'
          and ACCODE=c1.accode;
         
        IF lv_cnt>0 THEN 
        
             if nvl(c1.RATEPERUNIT,0) = 0 then
                lv_error_remark := '[Rate cannot be 0 for  SALES CHARGES : [' || c1.chargeshortname || ']. Report Softweb....]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;
        
              select m.tdscode
                    into lv_tdscode
                    from actdsledgermaster m
                    where m.companycode = lv_master.companycode
                    and m.accode=c1.accode
                    and m.witheffectfrom = (select max(sm.witheffectfrom)
                                           from actdsledgermaster sm
                                           where sm.companycode = lv_master.companycode
                                             and sm.accode = m.accode
                                             and sm.witheffectfrom <= lv_master.salebilldate
                                          );
                                          
                    select m.TDSNATURE
                    INTO LV_TDSNATURE
                    from actdsmaster m
                    where m.companycode = lv_master.companycode
                    and m.TDSCODE=lv_tdscode
                    and m.witheffectfrom = (select max(sm.witheffectfrom)
                                           from actdsmaster sm
                                           where sm.companycode = lv_master.companycode
                                             and sm.TDSCODE = m.TDSCODE
                                             and sm.WITHEFFECTFROM <= lv_master.salebilldate
                                          );  
    
             insert into ACTDSDETAILS_ENTRY
                   ( companycode, divisioncode, divisioncodefor, yearcode, 
                    systemvoucherno, systemvoucherdate, transactiondate, accode, tdstype, 
                    percentage, billno, billdate, billamount, totaltdsamount, 
                    netamount, servicetaxamount, educationcessamount, nettdsamount, drcr, 
                    tdsdeductedon, transactiontype, manualauto, synchronized, 
                    certificateno, certificatedate, witheffectfrom, partycode, hseducationcessamount, 
                    refsystemvoucherno, netpercentage, bsrcode, accodefor, username,LASTMODIFIED)
                   values
                   (lv_master.companycode, lv_divisioncode_target, lv_divisioncode_target, lv_master.yearcode, 
                    lv_systemvoucherno, to_date(lv_systemvoucherdate,'dd/mm/yyyy'), to_date(lv_systemvoucherdate,'dd/mm/yyyy'), c1.accode, LV_TDSNATURE, 
                    c1.rateperunit, lv_master.salebillno, lv_master.salebilldate, nvl(c1.assessableamount,0), c1.chargeamount, 
                    (nvl(c1.assessableamount,0) - nvl(c1.chargeamount,0)), 0, 0, c1.chargeamount, 'D', 
                    nvl(c1.assessableamount,0), 'TDS LIABILITY', 'AUTO VOUCHER', null, 
                    null, null, null, lv_accode_debtor, 0, 
                    null, c1.rateperunit, null, c1.accode, lv_master.username,SYSDATE);  
            
        END IF;

       --**END TDS INSERT **********************
        
            
            if c1.drcr = 'C' then 
                lv_serialno_dr := lv_serialno_dr + 1;
            else 
                lv_serialno_cr := lv_serialno_cr + 1;
            end if;
        end loop;                 
    end if;
    
    
    
    -- Finally inerting into acvoucherdetails_sales from gbl_acvoucherdetails_sales
    insert into acvoucherdetails_sales
    (TDSON, USERNAME, DIVISIONCODE, 
     YEARCODE, AMOUNT, 
     TRANSACTIONTYPE,SERIALNO,
     SYSTEMVOUCHERNO,SYSTEMVOUCHERDATE, 
     COMPANYCODE, ACCODE, DRCR,SYSROWID
    )
    select
     TDSON, USERNAME, DIVISIONCODE, 
     YEARCODE, AMOUNT, 
     TRANSACTIONTYPE,SERIALNO,
     SYSTEMVOUCHERNO,SYSTEMVOUCHERDATE, 
     COMPANYCODE, ACCODE, DRCR,SYSROWID
    from gbl_acvoucherdetails_sales;

    -- calliing the procedure for sync

    prcAC_SALESVoucher_Before_Main;

    select count(*)
    into lv_cnt
    from SYS_GBL_PROCOUTPUT_INFO;
            
    if lv_cnt = 0 then
        insert into SYS_GBL_PROCOUTPUT_INFO
        values ('[SYSTEM VOUCHER NUMBER GENERATED: ' || lv_systemvoucherno || ' Dated : ' || to_date(lv_systemvoucherdate,'dd/mm/yyyy') || ']');
    else
        update SYS_GBL_PROCOUTPUT_INFO
        set SYS_SAVE_INFO = nvl(SYS_SAVE_INFO,'') || ('[SYSTEM VOUCHER NUMBER GENERATED: ' || lv_systemvoucherno || ' Dated : ' || to_date(lv_systemvoucherdate,'dd/mm/yyyy') || ']');
    end if;        
            
end;
/
