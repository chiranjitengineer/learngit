DROP PROCEDURE NJMCL_WEB.PRCWPS_WORKER_B4SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_WORKER_B4SAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_WPSWORKERMAST%rowtype;
lv_MaxDRCRdate            date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      

begin

    lv_result:='#SUCCESS#';
    
    --return;
    
        select *
        into lv_Master
        from GBL_WPSWORKERMAST
        WHERE ROWNUM<=1;

        select count(*)
        into lv_cnt
        from GBL_WPSWORKERMAST;
        
         IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;            

        if nvl(lv_Master.operationmode,'NA') = 'A' then
           
            select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YEARCODE,'WPS_WORKERSERIAL',to_char(lv_Master.DATEOFJOINING,'dd/mm/yyyy')) 
            into lv_TransactionNo
            from dual;
            
            IF nvl(lv_TransactionNo,'NA') <>'NA' then
                update GBL_WPSWORKERMAST
                set WORKERSERIAL = lv_TransactionNo;
                
                update GBL_WPSWORKERWISERATEUPDATE
                set WORKERSERIAL = lv_TransactionNo;
                
                UPDATE GBL_NOMINEMAST
                set WORKERSERIAL = lv_TransactionNo;
                --raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,'PROC_WORKERMAST_RATESAVE ('||LV_MASTER.DEPARTMENTCODE||','|| LV_MASTER.WORKERCATEGORYCODE||','|| lv_TransactionNo||','||lv_Master.operationmode||')'));
                --PROC_WORKERMAST_RATESAVE (LV_MASTER.DEPARTMENTCODE, LV_MASTER.WORKERCATEGORYCODE, lv_TransactionNo);
               -- DELETE FROM GBL_WORKERMAST_RATE;
            else
                lv_error_remark := 'WORKERSERIAL No not generated. Check Parameters for Auto Gen.';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;
            
        end if;
        
 --exception when others then
--    lv_error_remark:= lv_error_remark || '#UNSUCC#ESSFULL#';
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
end;
/


