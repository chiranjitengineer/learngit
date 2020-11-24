CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_GRATUITY_SETTLE_B4SAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_GRATUITYSETTLEMENT%rowtype;
lv_MaxDRCRdate          date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      
lv_message varchar2(250);
begin

    lv_result:='#SUCCESS#';
    
    select *
    into lv_Master
    from GBL_GRATUITYSETTLEMENT
    WHERE ROWNUM =1;

             

    if nvl(lv_Master.OPERATIONMODE,'NA') = 'A' then
        select fn_autogen_params(lv_Master.companycode,lv_Master.divisioncode,lv_Master.yearcode,
        'GRATUITYSETTLEMENT',TO_CHAR(lv_Master.SETTLEMENTDATE,'DD/MM/YYYY')) 
        into lv_TransactionNo
        from dual;
                     
        
        UPDATE GBL_GRATUITYSETTLEMENT SET GRATUITYSETTLEMENTNO=lv_TransactionNo;
        lv_message := ' [GRATUITY SETTLEMENT NO GENERATED : ' || lv_TransactionNo || ' Dated : ' || TO_CHAR(lv_Master.SETTLEMENTDATE,'DD/MM/YYYY') || ']';
        insert into SYS_GBL_PROCOUTPUT_INFO(SYS_SAVE_INFO) values(lv_message);
    ELSE
        SELECT COUNT(TOKENNO) INTO lv_cnt FROM GRATUITYSETTLEMENT
        WHERE ISFINALIZE = 'Y'
        AND COMPANYCODE=lv_Master.COMPANYCODE
        AND DIVISIONCODE=lv_Master.DIVISIONCODE
        AND WORKERSERIAL=lv_Master.WORKERSERIAL;
        
        IF lv_cnt > 0 THEN
            lv_error_remark := 'Validation Failure : [This Employee has already finalize. Can not edit.... ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;
          
    end if;
        
--    if nvl(lv_Master.operationmode,'NA') = 'A' then
--        insert into SYS_GBL_PROCOUTPUT_INFO
--        values (' WPS LOAN STOP APPLICATION NUMBER : ' || lv_TransactionNo || ' Dated : ' || TO_CHAR(lv_Master.applicationdate,'DD/MM/YYYY'));
--    end if;  
end;
/