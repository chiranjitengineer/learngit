DROP PROCEDURE NJMCL_WEB.PRCWPS_WORKERRATECHANGE_B4SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_WORKERRATECHANGE_B4SAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_WPSWORKERWISERATEUPDATE%rowtype;
lv_MaxDRCRdate            date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      

begin

    lv_result:='#SUCCESS#';
    
    --RETURN;
   
    select *
    into lv_Master
    from GBL_WPSWORKERWISERATEUPDATE
    WHERE ROWNUM<=1;
    
    DELETE FROM WPSWORKERWISERATEUPDATE
    WHERE WORKERSERIAL IN (SELECT WORKERSERIAL FROM GBL_WPSWORKERWISERATEUPDATE)
    AND   EFFECTIVEDATE = lv_Master.EFFECTIVEDATE
    AND   WORKERCATEGORYCODE = lv_Master.WORKERCATEGORYCODE;

end;
/


