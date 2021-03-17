DROP PROCEDURE NJMCL_WEB.PRCWPS_LOANSTOP_B4SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_LOANSTOP_B4SAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PFLOANDEDUCTIONSTOP%rowtype;
lv_MaxDRCRdate          date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      

begin

    lv_result:='#SUCCESS#';
    
    select *
    into lv_Master
    from GBL_PFLOANDEDUCTIONSTOP
    WHERE ROWNUM<=1;

    select count(*)
    into lv_cnt
    from GBL_PFLOANDEDUCTIONSTOP;
        
     IF NVL(lv_cnt,0)=0 THEN
        lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;
        
    IF lv_Master.OPERATIONMODE IS NULL THEN
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    END IF;            

    if nvl(lv_Master.operationmode,'NA') = 'A' then
        select fn_autogen_params(lv_Master.companycode,lv_Master.divisioncode,lv_Master.yearcode,'WPS LOAN STOP APPLICATION',TO_CHAR(lv_Master.applicationdate,'DD/MM/YYYY')) 
        into lv_TransactionNo
        from dual;
            
        update GBL_PFLOANDEDUCTIONSTOP
        set APPLICATIONNO = lv_TransactionNo;
                
        UPDATE GBL_PFLOANDEDUCTIONSTOP
          SET MODULE='WPS';  
          
        if nvl(lv_Master.pfno,'NA') = 'NA' then
           UPDATE GBL_PFLOANDEDUCTIONSTOP
              SET FULLMILLCAPITAL='Y', FULLMILLINTEREST='Y';
        end if;
    end if;
        
    if nvl(lv_Master.operationmode,'NA') = 'A' then
        insert into SYS_GBL_PROCOUTPUT_INFO
        values (' WPS LOAN STOP APPLICATION NUMBER : ' || lv_TransactionNo || ' Dated : ' || TO_CHAR(lv_Master.applicationdate,'DD/MM/YYYY'));
    end if;  
end;
/


