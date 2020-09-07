CREATE OR REPLACE PROCEDURE NJMCL_WEB.prcPFLOANINT_ADJ_b4Save
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PFLOANINTERESTADJUSMENT%rowtype;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_CompCode             varchar2(10):='';
lv_DivCode             varchar2(10):='';
lv_YearCode             varchar2(10):='';
lv_YYYYMM               varchar2(6):=''; 
lv_Module               varchar2(10):='';                  

begin

    lv_result:='#SUCCESS#';
    
    
        select *
        into lv_Master
        from GBL_PFLOANINTERESTADJUSMENT
        WHERE ROWNUM<=1;

        select count(*)
        into lv_cnt
        from GBL_PFLOANINTERESTADJUSMENT;
        
         IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;            
        
       
end;
/