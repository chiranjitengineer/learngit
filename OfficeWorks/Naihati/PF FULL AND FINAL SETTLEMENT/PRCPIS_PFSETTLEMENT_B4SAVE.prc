CREATE OR REPLACE PROCEDURE NJMCL_WEB.prcPIS_PFSettlement_b4Save
is
lv_cnt                  number;
lv_result               varchar2(10);
LV_TEMPSTR               varchar2(100);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PFSETTLEMENT%rowtype;
lv_PFSettlementNo       varchar2(50);
lv_PFSystemVoucherNo    varchar2(50);
lv_PFVoucherNo          varchar2(50);
lv_STR_SQL              varchar2(1000);
begin


--RETURN;

    lv_result:='#SUCCESS#';
    
    select *
    into lv_Master
    from GBL_PFSETTLEMENT
    WHERE ROWNUM<=1;

    select count(*)
    into lv_cnt
    from GBL_PFSETTLEMENT;
        
     IF NVL(lv_cnt,0)=0 THEN
        lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;
        
    IF lv_Master.OPERATIONMODE IS NULL THEN
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    END IF;            

    if nvl(lv_Master.OPERATIONMODE,'NA') = 'A' then
        
        select fn_autogen_params(lv_Master.companycode,lv_Master.divisioncode,lv_Master.yearcode,'PF SETTLEMENT NO',TO_CHAR(lv_Master.SETTLEMENTDATE,'DD/MM/YYYY')) 
        into lv_PFSettlementNo
        from dual;
--        select fn_autogen_params(lv_Master.companycode,lv_Master.divisioncode,lv_Master.yearcode,'PF SETTLEMENT NO',TO_CHAR(lv_Master.SETTLEMENTDATE,'DD/MM/YYYY')) 
--        into lv_PFSystemVoucherNo
--        from dual;
--        select fn_autogen_params(lv_Master.companycode,lv_Master.divisioncode,lv_Master.yearcode,'PF SETTLEMENT NO',TO_CHAR(lv_Master.SETTLEMENTDATE,'DD/MM/YYYY')) 
--        into lv_PFVoucherNo
--        from dual;
        
    
        update GBL_PFSETTLEMENT
        set PFSETTLEMENTNO = lv_PFSettlementNo;--, SYSTEMVOUCHERNO = lv_PFSystemVoucherNo, VOUCHERNO = lv_PFVoucherNo;
                
      end if;
        
    if nvl(lv_Master.OPERATIONMODE,'NA') = 'A' then
        insert into SYS_GBL_PROCOUTPUT_INFO
        values (' PF SETTLEMENT NO : ' || lv_PFSettlementNo || ' Dated : ' || to_date(lv_Master.SettlementDate,'dd/mm/yyyy'));
--        insert into SYS_GBL_PROCOUTPUT_INFO
--        values (' PF LOAN SYSTEM VOUCHER NO : ' || lv_PFSystemVoucherNo || ' Dated : ' || TO_CHAR(lv_Master.SYSTEMVOUCHERDATE,'DD/MM/YYYY'));
--        insert into SYS_GBL_PROCOUTPUT_INFO
--        values (' PF LOAN VOUCHER NO : ' || lv_PFVoucherNo || ' Dated : ' || TO_CHAR(lv_Master.VOUCHERDATE,'DD/MM/YYYY'));
   
    
    --RETURN;
    
        --raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,'SETTLEMENTDATE'||TO_DATE(lv_Master.SettlementDate,'DD/MM/YYYY')));
        IF NVL(lv_Master.SettlementDate,TO_DATE('01/01/1900','DD/MM/YYYY'))<>TO_DATE('01/01/1900','DD/MM/YYYY') THEN
        --raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,'SETTLEMENTDATE'||TO_DATE(lv_Master.SettlementDate,'DD/MM/YYYY')));

         
            EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_INSUPD_WPSWORKERMAST DISABLE';
            EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_INSUPD_PISEMPLOYEEMASTER DISABLE';


             UPDATE PFEMPLOYEEMASTER SET
             PFSETTLEMENTDATE= lv_Master.SettlementDate WHERE MODULE=''||lv_Master.Module||'' AND WORKERSERIAL=''||lv_Master.WorkerSerial||'';

             UPDATE WPSWORKERMAST SET 
             PFSETTELMENTDATE= lv_Master.SettlementDate WHERE MODULE=''||lv_Master.Module||'' AND WORKERSERIAL=''||lv_Master.WorkerSerial||'';
             
             UPDATE PISEMPLOYEEMASTER SET 
             PFSETTELMENTDATE= lv_Master.SettlementDate WHERE MODULE=''||lv_Master.Module||'' AND WORKERSERIAL=''||lv_Master.WorkerSerial||'';
         
             
            EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_INSUPD_WPSWORKERMAST ENABLE';
            EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_INSUPD_PISEMPLOYEEMASTER ENABLE';
         
        END IF;
    
    end if;  
        

end;
/
