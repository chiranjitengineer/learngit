CREATE OR REPLACE PROCEDURE CJIL_WEB."PRCSTORES_CHALLANINB4MAIN" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_STORESCHALLANINDETAILS%rowtype;
lv_MaxTransactiondate            date;
lv_TransactionNo        varchar2(50);

begin
    lv_result:='#SUCCESS#';
   
     UPDATE GBL_STORESCHALLANINDETAILS  SET ITEMTYPE=(SELECT RETURNTYPE
                           FROM STORESCHALLANOUTTYPE 
                           WHERE ROWNUM=1 AND OUTTYPE=GBL_STORESCHALLANINDETAILS.OUTTYPE);
     DELETE FROM GBL_STORESCHALLANINDETAILS  WHERE  QUANTITY=0;
    
        select *
        into lv_Master
        from GBL_STORESCHALLANINDETAILS
        WHERE ROWNUM=1;
        
        select count(*)
        into lv_cnt
        from STORESCHALLANINDETAILS;

        if lv_cnt > 0 AND nvl(lv_Master.operationmode,'NA') = 'A' then
            select max(TRANSACTIONDATE)
            into lv_MaxTransactiondate
            from STORESCHALLANINDETAILS
            where companycode = lv_Master.CompanyCode
              and divisioncode = lv_Master.DivisionCode
              and YearCode = lv_Master.YearCode;
              
            if lv_Master.TRANSACTIONDATE < lv_MaxTransactiondate then
                lv_error_remark := 'Validation Failure : [Last Transaction Date was : ' || to_char(lv_MaxTransactiondate,'dd/mm/yyyy') || ' You can not save before this date.]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;     
  
        end if;
        
        if nvl(lv_Master.operationmode,'NA') = 'A' then
            -----------------------  Generate Transaction No --START-----------------------
            IF NVL(LV_MASTER.OUTTYPE, 'MISC') = 'STORE' THEN
                select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'STORES_CHALLANIN_NO',to_char(lv_Master.TRANSACTIONDATE,'dd/mm/yyyy')) 
                into lv_TransactionNo
                from dual;
            ELSE
                select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'STORES_CHALLANIN_NO_GENERAL',to_char(lv_Master.TRANSACTIONDATE,'dd/mm/yyyy')) 
                into lv_TransactionNo
                from dual;
            END IF;
            -----------------------  Generate Transaction No --END-----------------------
            IF nvl(lv_TransactionNo,'NA') <>'NA' then
                update GBL_STORESCHALLANINDETAILS
                set TRANSACTIONNO = lv_TransactionNo;
               
            else
                lv_error_remark := 'Challan No not generated. Check Parameters for Auto Gen.';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;
            
        end if;
        IF lv_Master.TRANSACTIONDATE > TRUNC(SYSDATE) THEN
            lv_error_remark := 'Validation Failure : [Challan Date cannot be greater than current date.]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        END IF;
        
        lv_cnt := 0;
        select count(*)
        into lv_cnt
        from GBL_STORESCHALLANINDETAILS;
        
        if  nvl(lv_cnt,0) =0 then
            lv_error_remark := 'No details available to save.';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;
        
          
           
--    IF nvl(lv_TransactionNo,'NA') <>'NA' then
--        DELETE FROM GBL_STORESCHALLANINDETAILS  WHERE TRANSACTIONNO=lv_TransactionNo AND QUANTITY=0;
--    end if;
      
    if lv_Master.OperationMode = 'A' then
        select count(*)
        into lv_cnt
        from SYS_GBL_PROCOUTPUT_INFO;
        
        if lv_cnt = 0 then
            insert into SYS_GBL_PROCOUTPUT_INFO
            values ('[CHALLAN IN NUMBER : ' || lv_TransactionNo || ' Dated : ' || lv_Master.TRANSACTIONDATE || ']');
        else
            update SYS_GBL_PROCOUTPUT_INFO
            set SYS_SAVE_INFO = nvl(SYS_SAVE_INFO,'') || ('[CHALLAN IN NUMBER : ' || lv_TransactionNo || ' Dated : ' || lv_Master.TRANSACTIONDATE || ']');
        end if;

    end if;


--exception when others then
--    lv_error_remark:= lv_error_remark || '#UNSUCC#ESSFULL#';
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
end;
/
