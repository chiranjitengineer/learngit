DROP PROCEDURE NJMCL_WEB.PRCWPS_LOANINTSTOP_AFTERSAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRCWPS_LOANINTSTOP_AFTERSAVE" 
AS
LV_CNT                  NUMBER;
LV_SERIALNO               NUMBER;
LV_RESULT               VARCHAR2(10);
LV_ERROR_REMARK         VARCHAR2(4000) := '' ;
LV_MASTER               GBL_LOANINTERESTCALCSTOP%ROWTYPE;
LV_TRANSACTIONNO        VARCHAR2(50);
LV_SQLSTR               VARCHAR2(5000) := '' ;
LV_SYS_TFMAP_TABLEID    NUMBER := 0;
LV_SYS_TFMAP_COLUMN_SEQUENCE    NUMBER := 0;          
      

BEGIN

    LV_RESULT:='#SUCCESS#';

        SELECT COUNT(*)
        INTO LV_CNT
        FROM GBL_LOANINTERESTCALCSTOP;

        SELECT *
        INTO LV_MASTER
        FROM GBL_LOANINTERESTCALCSTOP
        WHERE ROWNUM<=1;        
        
         IF NVL(LV_CNT,0)=0 THEN
            LV_ERROR_REMARK := 'Validation Failure : [Blank data not allowded to save!]';
            RAISE_APPLICATION_ERROR(TO_NUMBER(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,LV_ERROR_REMARK));
        END IF;
  
        IF LV_MASTER.OPERATIONMODE IS NULL THEN
            LV_ERROR_REMARK := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            RAISE_APPLICATION_ERROR(TO_NUMBER(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,LV_ERROR_REMARK));
        END IF;            

        IF (NVL(LV_MASTER.OPERATIONMODE,'NA') = 'A')   THEN        
            UPDATE LOANTRANSACTION  SET LOANSTOP='Y' WHERE TOKENNO=LV_MASTER.TOKENNO AND LOANCODE=LV_MASTER.LOANCODE
             AND LOANDATE=LV_MASTER.LOANDATE;           
        END IF;
        
         IF (NVL(LV_MASTER.OPERATIONMODE,'NA') = 'D')   THEN
        
            UPDATE LOANTRANSACTION  SET LOANSTOP='N' WHERE TOKENNO=LV_MASTER.TOKENNO AND LOANCODE=LV_MASTER.LOANCODE
             AND LOANDATE=LV_MASTER.LOANDATE;           
        END IF;

END;
/


