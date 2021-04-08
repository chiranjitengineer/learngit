CREATE OR REPLACE procedure prc_DeductTDS(
                                        p_companycode       VARCHAR2,
                                        p_divisioncode      VARCHAR2,
                                        p_yearcode          VARCHAR2,
                                        p_partycode         varchar2,
                                        p_tdscode           varchar2,
                                        p_amount_on_TDS     number,
                                        p_Billdate          varchar2 default null  --SAMRAT FOR ADDING BILLDATE WISE TDS % DATE 04/06/2020
                                      ) 
is
lv_cnt                          number := 0;
lv_error_remark                 varchar2(1000);
lv_proceed_next                 number := 0;
lv_actdsledgermaster            actdsledgermaster%rowtype;
lv_actdsmaster                  actdsmaster%rowtype;
lv_tds_amount                   number := 0;
lv_educationcess                number := 0;
lv_sreducationcess              number := 0;
lv_tds_amount_total             number := 0;
lv_bill_amount_net              number := 0;
lv_check_limit                  number := 0;
lv_singletransactionlimit       number := 0;
lv_tdsledgercode                varchar2(100);
lv_netBillAmt_TillDate          number := 0;
lv_DeductedOn_TillDate          number := 0;
lv_tdsdeductedon                number := 0;
lv_percentage                   number := 0;
lv_Billdate                     varchar2(10);
begin
    if nvl(p_Billdate,'~na~') = '~na~' then
        lv_Billdate := to_char(trunc(sysdate),'dd/mm/yyyy');
    else
        lv_Billdate := p_Billdate;
    end if;
    -- Checking whether the basic Input Parameters are correctly provided
    lv_proceed_next := 0;
    select count(*)
    into lv_cnt
    from financialyear
    where companycode = p_companycode
      and divisioncode = p_divisioncode
      and yearcode = p_yearcode;
    
    if lv_cnt = 0 then
        lv_error_remark := 'Either Company or Division or Year is not proper. Hence TDS could not be calculated....';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    --Checking the tds setting in ACACLEDGER 
    select count(*)
    into lv_cnt
    from acacledger
    where companycode = p_companycode
      and accode = p_partycode
      and nvl(ISTDSAPPLICABLE,'N') = 'Y';
      
    if lv_cnt = 0 then
        lv_proceed_next := 0;
        -- NO TDS DEDUCTION IS REQUIRED
    else
        lv_proceed_next := 1;
        -- TDS TO BE DEDUCTED BUT SUV=BJECT TO VARIOUS CONDITION
    end if;    
    
    
    if lv_proceed_next = 1 then      -- To Identify the TDS Ledger Code from ACACLEDGER
        select count(*)
        into lv_cnt
        from (
                select a.accode,b.tdscode 
                from acacledger a, ACTDSLEDGERMASTER b
                where a.companycode = b.companycode
                  and a.grouptype = 'TDS'
                  and b.tdscode = p_tdscode
                  and a.companycode = p_companycode
                  and a.accode = b.accode
                  and b.witheffectfrom = (select max(b.witheffectfrom)
                                            from acacledger a, ACTDSLEDGERMASTER b
                                            where a.companycode = b.companycode
                                              and a.grouptype = 'TDS'
                                              and b.tdscode = p_tdscode
                                              and a.companycode = p_companycode
                                              and a.accode = b.accode
                                              and witheffectfrom <= to_date(lv_billdate,'dd/MM/yyyy')  --SAMRAT FOR ADDING BILLDATE WISE TDS % DATE 04/06/2020
                                         )
            );
              
        if lv_cnt = 0 then
            lv_proceed_next := 0;
            lv_error_remark := 'TDS Ledger must be defined and mapped with TDS Nature. Hence TDS could not be calculated....';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        elsif lv_cnt > 1 then
            lv_proceed_next := 0;
            lv_error_remark := 'TDS Ledger must be mapped with a single TDS Nature. Hence TDS could not be calculated....';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        else
            lv_proceed_next := 1;
            select a.accode
            into lv_tdsledgercode
            from acacledger a, ACTDSLEDGERMASTER b
            where a.companycode = b.companycode
              and a.grouptype = 'TDS'
              and b.tdscode = p_tdscode
              and a.companycode = p_companycode
              and a.accode = b.accode
              and b.witheffectfrom = (select max(b.witheffectfrom)
                                      from acacledger a, ACTDSLEDGERMASTER b
                                      where a.companycode = b.companycode
                                        and a.grouptype = 'TDS'
                                        and b.tdscode = p_tdscode
                                        and a.companycode = p_companycode
                                        and a.accode = b.accode
                                        and witheffectfrom <= to_date(lv_billdate,'dd/MM/yyyy') --SAMRAT FOR ADDING BILLDATE WISE TDS % DATE 04/06/2020
                                     );
        end if;                                           
    else
        lv_proceed_next := 0;
    end if;              


    if lv_proceed_next = 1 then      -- TDS Calculation is required
        select *
        into lv_actdsmaster
        from actdsmaster
        where companycode = p_companycode
          and tdscode = p_tdscode
          and witheffectfrom = (select max(witheffectfrom)
                                from actdsmaster
                                where companycode = p_companycode
                                  and tdscode = p_tdscode
                                  and witheffectfrom <= to_date(lv_billdate,'dd/MM/yyyy') --SAMRAT FOR ADDING BILLDATE WISE TDS % DATE 04/06/2020
                               );
        
        --raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,'TDSCODE ' || p_tdscode || ' PARTYCODE ' || p_partycode));
        
        select *
        into lv_actdsledgermaster
        from actdsledgermaster
        where companycode = p_companycode
          and accode = p_partycode
          and tdscode = p_tdscode
          and witheffectfrom = (select max(witheffectfrom)
                                from actdsledgermaster
                                where companycode = p_companycode
                                  and accode = p_partycode
                                  and tdscode = p_tdscode
                                  and witheffectfrom <= to_date(lv_billdate,'dd/MM/yyyy') --SAMRAT FOR ADDING BILLDATE WISE TDS % DATE 04/06/2020
                               );
        
        -- Changes Made by Sanjib Banerjee on 26.05.2020
        -- Start 
        -- Reason : Due to Covid - 19 Govt has suddenly reduced the rate of TDS
        --          for which user need to change the Rate in ACTDSMASTER and individually as well for the Creditors / Debtors Ledger which is cumbersome
        --          In order to address these cases where Govt reduce the rate of Tax then
        --          System will compare between the TDS Rate defined in ACTDSMASTER and TDS Rate (defined last WEF date) in the recpective Ledger while deducting the TDS
        --          The system will take the Lowest Rate in between these two rates
        
        -- lv_percentage := nvl(lv_actdsledgermaster.percentnew,0);
            
        if nvl(lv_actdsmaster.TDSPERCENT,0) >= nvl(lv_actdsledgermaster.percentnew,0) then
            lv_percentage := nvl(lv_actdsledgermaster.percentnew,0);
        else
            lv_percentage := nvl(lv_actdsmaster.TDSPERCENT,0);
        end if;
        -- End
        
        
        
        if nvl(lv_actdsledgermaster.alwaysdeduct,'N') = 'Y' then
            ----Deduction has to be made on p_amount_on_TDS
            --- No other checking is necessary 
            ---- deduct as per rule and percentage provided
            lv_tds_amount := round(p_amount_on_TDS * lv_percentage/100,0);
            lv_educationcess := round(lv_tds_amount * lv_actdsmaster.educationcess/100,0);
            lv_sreducationcess := round(lv_tds_amount * lv_actdsmaster.sreducationcess/100,0);
            lv_tds_amount_total := lv_tds_amount + lv_educationcess + lv_sreducationcess;
            lv_bill_amount_net := p_amount_on_TDS - lv_tds_amount_total;
            lv_tdsdeductedon := p_amount_on_TDS ;
        else
            if nvl(lv_actdsledgermaster.lowerdeductlimit,0) > 0 then
                lv_check_limit := nvl(lv_actdsledgermaster.lowerdeductlimit,0);
            else
                lv_check_limit := nvl(lv_actdsmaster.yearlylimit,0);
            end if;
            lv_singletransactionlimit := nvl(lv_actdsmaster.singletransactionlimit,0);
            
            if p_amount_on_TDS > lv_singletransactionlimit then
                ----Since Bill Amount has crossed the Single Transaction Limit defined in TDS MASTER 
                --  Deduction has to be made on p_amount_on_TDS
                --- No other checking is necessary 
                ---- deduct as per rule and percentage provided
                lv_tds_amount := round(p_amount_on_TDS * lv_percentage/100,0);
                lv_educationcess := round(lv_tds_amount * lv_actdsmaster.educationcess/100,0);
                lv_sreducationcess := round(lv_tds_amount * lv_actdsmaster.sreducationcess/100,0);
                lv_tds_amount_total := lv_tds_amount + lv_educationcess + lv_sreducationcess;
                lv_bill_amount_net := p_amount_on_TDS - lv_tds_amount_total;
                lv_tdsdeductedon := p_amount_on_TDS ;
            else
                select sum(nvl(a.billamount,0))+p_amount_on_TDS,sum(nvl(a.tdsdeductedon,0))
                into lv_netBillAmt_TillDate,lv_DeductedOn_TillDate
                from actdsdetails a, acvoucher b
                where a.companycode = b.companycode
                  and a.divisioncode = b.divisioncode
                  and a.yearcode = b.yearcode
                  and a.systemvoucherno = b.systemvoucherno
                  and b.voucherno is not null
                  and a.companycode = p_companycode
                  and a.divisioncode = p_divisioncode
                  and a.yearcode = p_yearcode
                  and a.accode = lv_tdsledgercode
                  and a.partycode = p_yearcode
                  and a.drcr = 'C'
                  and a.systemvoucherno not in (select distinct systemvoucherno
                                                from (
                                                        select a.companycode,a.divisioncode,a.yearcode,a.systemvoucherno
                                                        from acvoucher a,(select companycode,divisioncode,yearcode,systemvoucherno
                                                                          from actdsdetails
                                                                          where companycode=p_companycode
                                                                            and divisioncode = p_divisioncode
                                                                            and yearcode = p_yearcode
                                                                            and accode = lv_tdsledgercode
                                                                            and partycode = p_partycode
                                                                            and transactiontype = 'TDS LIABILITY REVERSAL'
                                                                         ) b
                                                        where a.companycode = b.companycode
                                                          and a.divisioncode = b.divisioncode
                                                          and a.yearcode = b.yearcode
                                                          and a.systemvoucherno = b.systemvoucherno
                                                          and a.companycode=p_companycode
                                                          and a.divisioncode = p_divisioncode
                                                          and a.yearcode = p_yearcode
                                                        union all
                                                        select a.companycode,a.divisioncode,a.yearcode,a.refsystemvoucherno
                                                        from acvoucher a,(select companycode,divisioncode,yearcode,systemvoucherno
                                                                          from actdsdetails
                                                                          where companycode=p_companycode
                                                                            and divisioncode = p_divisioncode
                                                                            and yearcode = p_yearcode
                                                                            and accode = lv_tdsledgercode
                                                                            and partycode = p_partycode
                                                                            and transactiontype = 'TDS LIABILITY REVERSAL'
                                                                         ) b
                                                        where a.companycode = b.companycode
                                                          and a.divisioncode = b.divisioncode
                                                          and a.yearcode = b.yearcode
                                                          and a.systemvoucherno = b.systemvoucherno
                                                          and a.companycode=p_companycode
                                                          and a.divisioncode = p_divisioncode
                                                          and a.yearcode = p_yearcode
                                                     )
                                                  )  ;
                  
                if (lv_netBillAmt_TillDate-lv_DeductedOn_TillDate) > lv_check_limit then
                    ----Since Net Bill Amount minus Deducted on Till Date has crossed the Yearly Transaction / Lower Deduction Limit defined in TDS MASTER 
                    --  Deduction has to be made on p_amount_on_TDS+Pending Amount
                    ---- deduct as per rule and percentage provided
                    lv_tds_amount := round((lv_netBillAmt_TillDate-lv_DeductedOn_TillDate) * lv_percentage/100,0);
                    lv_educationcess := round(lv_tds_amount * lv_actdsmaster.educationcess/100,0);
                    lv_sreducationcess := round(lv_tds_amount * lv_actdsmaster.sreducationcess/100,0);
                    lv_tds_amount_total := lv_tds_amount + lv_educationcess + lv_sreducationcess;
                    lv_bill_amount_net := p_amount_on_TDS - lv_tds_amount_total;
                    lv_tdsdeductedon := (lv_netBillAmt_TillDate-lv_DeductedOn_TillDate) ;
                    if lv_bill_amount_net < 0 then
                        lv_tds_amount := p_amount_on_TDS;
                        lv_educationcess := 0;
                        lv_sreducationcess := 0;
                        lv_tds_amount_total := lv_tds_amount + lv_educationcess + lv_sreducationcess;
                        lv_bill_amount_net := p_amount_on_TDS - lv_tds_amount_total;
                        lv_tdsdeductedon := (lv_netBillAmt_TillDate-lv_DeductedOn_TillDate) ;
                    end if;
                else    
                    ---- Nothing to be deducted
                    ---- Because the transactions are not yet crossed the limit
                    lv_tds_amount := 0 ;
                    lv_educationcess := 0;
                    lv_sreducationcess := 0;
                    lv_tds_amount_total := lv_tds_amount + lv_educationcess + lv_sreducationcess;
                    lv_bill_amount_net := p_amount_on_TDS - lv_tds_amount_total;
                    lv_tdsdeductedon := 0 ;
                end if;  
            end if;
        end if;      
    end if;      

    insert into gbl_tdstobededucted
    (   companycode,divisioncode,yearcode,accode,tdscode,
        percentage,billamount,totaltdsamount,netamount,servicetaxamount,
        educationcessamount,nettdsamount,drcr,tdsdeductedon,transactiontype,
        partycode,hseducationcessamount,netpercentage
    )
    select p_companycode,p_divisioncode,p_yearcode,lv_tdsledgercode,p_tdscode,
           lv_percentage,p_amount_on_TDS,lv_tds_amount,lv_bill_amount_net,0,
           lv_educationcess,lv_tds_amount_total,'C',lv_tdsdeductedon,'TDS LIABILITY',
           p_partycode,lv_sreducationcess,lv_percentage
    from dual;
/*
    if lv_proceed_next = 1 then      
        return 1;
    else
        return 0;
    end if;
*/
end ;
/
