CREATE OR REPLACE PROCEDURE AMBOOTIA.prcProd_CatgoryTransfer_b4Save
is
lv_cnt                  number;
<<<<<<< HEAD
lv_result               varchar2(10);
=======
lv_result               varchar2(1000);
>>>>>>> 8f31d20b22b3664d3ae98cd4f6f8f453d5ebf1d0
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_PRODCATEGORYTRANSFERDTLS%rowtype;
lv_MaxDRCRdate          date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      

begin

    lv_result:='#SUCCESS#';
    
    
        select *
        into lv_Master
        from GBL_PRODCATEGORYTRANSFERDTLS
        WHERE ROWNUM<=1;

        select count(*)
        into lv_cnt
        from GBL_PRODCATEGORYTRANSFERDTLS;
        
         IF NVL(lv_cnt,0)=0 THEN
            lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;
        
        IF lv_Master.OPERATIONMODE IS NULL THEN
            lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;            
     
        if nvl(lv_Master.operationmode,'NA') = 'A' then
           
            select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YEARCODE,'PROD_TEACATEGORYTRANSFER',to_char(SYSDATE,'dd/mm/yyyy')) 
            into lv_TransactionNo
            from dual;
            
      
--             lv_error_remark := 'DOCUMENT No  ' ||lv_TransactionNo ||' OPT MODE '|| lv_Master.operationmode;
--            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
--      
            IF nvl(lv_TransactionNo,'NA') <> 'NA' then
                update GBL_PRODCATEGORYTRANSFERDTLS
                set DOCUMENTNO = lv_TransactionNo;
<<<<<<< HEAD
=======
                lv_result := ' [DOCUMENT NO GENERATED AS : '||lv_TransactionNo||' ON '||SYSDATE||' ]';
>>>>>>> 8f31d20b22b3664d3ae98cd4f6f8f453d5ebf1d0
            else
                lv_error_remark := 'DOCUMENT No not generated. Check Parameters for Auto Gen.';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;
            
        end if;
        
<<<<<<< HEAD
=======
        DELETE FROM SYS_GBL_PROCOUTPUT_INFO WHERE 1=1;
        
        INSERT INTO SYS_GBL_PROCOUTPUT_INFO(SYS_SAVE_INFO) VALUES(lv_result);	
        
>>>>>>> 8f31d20b22b3664d3ae98cd4f6f8f453d5ebf1d0
 --exception when others then
--    lv_error_remark:= lv_error_remark || '#UNSUCC#ESSFULL#';
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
end;
/