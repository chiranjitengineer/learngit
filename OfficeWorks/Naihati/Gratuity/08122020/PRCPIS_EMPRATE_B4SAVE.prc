CREATE OR REPLACE PROCEDURE NJMCL_WEB.prcPIS_EmpRate_b4Save
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PISEMPLOYEEMASTER%rowtype;
lv_MaxDRCRdate          date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      
lv_YearCode             varchar2(10);

begin

    lv_result:='#SUCCESS#';
    
    
        select *
        into lv_Master
        from GBL_PISEMPLOYEEMASTER
        WHERE ROWNUM<=1;

        select count(*)
        into lv_cnt
        from GBL_PISEMPLOYEEMASTER;
        
        
         IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;            

        select YEARCODE into lv_YearCode 
        from financialyear
        where COMPANYCODE = lv_Master.COMPANYCODE AND DIVISIONCODE = lv_Master.DIVISIONCODE
        AND STARTDATE <= SYSDATE AND ENDDATE >= SYSDATE; 

        if nvl(lv_Master.operationmode,'NA') = 'A' then
           
            select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_YearCode,'PIS_WORKERSERIAL',to_char(SYSDATE,'dd/mm/yyyy')) 
            into lv_TransactionNo
            from dual;
            
            IF nvl(lv_TransactionNo,'NA') <>'NA' then
                update GBL_PISEMPLOYEEMASTER
                set WORKERSERIAL = lv_TransactionNo;
                
                update GBL_PISCOMPONENTASSIGNMENT
                set WORKERSERIAL= lv_TransactionNo;
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