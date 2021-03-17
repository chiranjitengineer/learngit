DROP PROCEDURE NJMCL_WEB.PRCWPS_COMPONENT_B4SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_COMPONENT_B4SAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_WPSCOMPONENTMASTER%rowtype;
lv_MaxDRCRdate            date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      

begin

    lv_result:='#SUCCESS#';
    
    
        select *
        into lv_Master
        from GBL_WPSCOMPONENTMASTER
        WHERE ROWNUM<=1;
                  
        

        select count(*)
        into lv_cnt
        from GBL_WPSCOMPONENTMASTER;
        
         IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;            

        if nvl(lv_Master.operationmode,'NA') = 'A' then
           
            lv_cnt :=0;
            SELECT COUNT(*) 
            INTO lv_cnt
            FROM
            (
            SELECT trim(COMPANYCODE||DIVISIONCODE||COMPONENTCODE)
            FROM GBL_WPSCOMPONENTMASTER
            WHERE trim(COMPANYCODE||DIVISIONCODE||COMPONENTCODE) IN
                  (  SELECT trim(COMPANYCODE||DIVISIONCODE||COMPONENTCODE)
                            FROM WPSCOMPONENTMASTER
                  )
            );
            
            IF nvl(lv_cnt,0)>0 THEN
                    lv_error_remark := 'Validation Failure : [Duplicate COMPONENTCODE : ' ||' You can not save duplicate Componet code.]';
                    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            END IF;
            
        end if;

--exception when others then
--    lv_error_remark:= lv_error_remark || '#UNSUCC#ESSFULL#';
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
end;
/


