DROP PROCEDURE NJMCL_WEB.PRCWPS_LOANENTRY_B4SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_LOANENTRY_B4SAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_LOANTRANSACTION%rowtype;
lv_ApplicationNo        varchar2(50);

begin

    lv_result:='#SUCCESS#';
    
    select *
    into lv_Master
    from GBL_LOANTRANSACTION
    WHERE ROWNUM<=1;

    select count(*)
    into lv_cnt
    from GBL_LOANTRANSACTION;
        
     IF NVL(lv_cnt,0)=0 THEN
        lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;
        
    IF lv_Master.OPERATIONMODE IS NULL THEN
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    END IF;            

    if nvl(lv_Master.operationmode,'NA') = 'A' then
        select fn_autogen_params(lv_Master.companycode,lv_Master.divisioncode,lv_Master.yearcode,'LOAN TRANSACTION',TO_CHAR(lv_Master.LOANDATE,'DD/MM/YYYY')) 
        into lv_ApplicationNo
        from dual;
            
        update GBL_LOANTRANSACTION
        set APPLICATIONNO = lv_ApplicationNo;
                
      end if;
        
    if nvl(lv_Master.operationmode,'NA') = 'A' then
        insert into SYS_GBL_PROCOUTPUT_INFO
        values (' WPS LOAN TRANSACTION NUMBER : ' || lv_ApplicationNo || ' Dated : ' || TO_CHAR(lv_Master.LOANDATE,'DD/MM/YYYY'));
    end if;  
    
    IF lv_master.LOANCF='F' AND NVL(lv_master.LOANAMOUNTADJUSTED,0)+NVL(lv_master.LOANINTAMOUNTADJUSTED,0)>0 THEN
     UPDATE GBL_LOANTRANSACTION SET 
     AMOUNT=NVL(AMOUNT,0)+NVL(lv_master.LOANAMOUNTADJUSTED,0)+NVL(lv_master.LOANINTAMOUNTADJUSTED,0);
    
    END IF;
    
    IF NVL(lv_master.LOANAMOUNTADJUSTED,0)+NVL(lv_master.LOANINTAMOUNTADJUSTED,0)>0 AND lv_Master.OPERATIONMODE <>'D' THEN
     INSERT INTO LOANBREAKUP 
     (COMPANYCODE, DIVISIONCODE, MODULE, YEARCODE, YEARMONTH, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO,
      LOANCODE, LOANDATE, EFFECTYEARMONTH, INTERESTPERCENTAGE, AMOUNT, REPAYAMOUNT, REPAYCAPITAL, REPAYINTEREST,REMARKS,
      TRANSACTIONTYPE, EFFECTFORTNIGHT, PAIDON, DEDUCTEDAMT, SYSROWID, USERNAME
     )
     SELECT COMPANYCODE, DIVISIONCODE, MODULE, YEARCODE, YEARMONTH, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO,
      LOANCODE, LOANDATE, YEARMONTH, INTERESTPERCENTAGE, AMOUNT, 0, LOANAMOUNTADJUSTED, LOANINTAMOUNTADJUSTED, 'ADJUSTED WITH THE LOAN CODE '|| LOANCODE || ' DATED ' || TO_DATE(LOANDATE,'DD/MM/YYYY'),
      'REPAY', LOANDATE, LOANDATE, 0, SYSROWID, USERNAME FROM GBL_LOANTRANSACTION;
    END IF;
    
      
    IF NVL(lv_master.LOANAMOUNTADJUSTED,0)+NVL(lv_master.LOANINTAMOUNTADJUSTED,0)>0 AND lv_Master.OPERATIONMODE ='D' THEN
          DELETE FROM LOANBREAKUP 
           WHERE  TOKENNO=LV_MASTER.TOKENNO 
           AND WORKERSERIAL=LV_MASTER.WORKERSERIAL
           AND LOANCODE=LV_MASTER.LOANCODE
           AND LOANDATE=LV_MASTER.LOANDATE;
    END IF;
end;
/


