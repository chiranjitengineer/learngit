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
        
       

DELETE FROM PFLOANINTEREST A
WHERE 1=1
AND A.COMPANYCODE=lv_Master.COMPANYCODE
AND A.DIVISIONCODE=lv_Master.DIVISIONCODE
AND A.WORKERSERIAL=lv_Master.WORKERSERIAL
AND A.LOANCODE=lv_Master.LOANCODE
AND A.LOANDATE=lv_Master.LOANDATE
AND A.TRANSACTIONTYPE='ADJUSTMENT';

IF lv_Master.OPERATIONMODE = 'A' THEN 

    DELETE FROM PFLOANINTERESTADJUSMENT A
    WHERE 1=1
    AND A.COMPANYCODE=lv_Master.COMPANYCODE
    AND A.DIVISIONCODE=lv_Master.DIVISIONCODE
    AND A.WORKERSERIAL=lv_Master.WORKERSERIAL
    AND A.LOANCODE=lv_Master.LOANCODE
    AND A.LOANDATE=lv_Master.LOANDATE;



    INSERT INTO PFLOANINTEREST
    (
        COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, 
        PFNO, LOANCODE, LOANDATE, LOANAMOUNT, INTERESTAPPLICABLEON, INTERESTPERCENTAGE, INTERESTAMOUNT, 
        EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, MODULE, TRANSACTIONTYPE, REMARKS, USERNAME, SYSROWID, WORKERSERIAL, TOKENNO
    )
    SELECT A.COMPANYCODE, A.DIVISIONCODE, C.YEARCODE, C.YEARMONTH, C.FORTNIGHTSTARTDATE, 
    C.FORTNIGHTENDDATE, B.PFNO, A.LOANCODE, A.LOANDATE,C.LOANAMOUNT LOANAMOUNT, C.INTERESTAPPLICABLEON, 
    C.INTERESTPERCENTAGE,A.ADJUSTEDAMOUNT INTERESTAMOUNT, C.EMPLOYEECOMPANYCODE, C.EMPLOYEEDIVISIONCODE, 
    C.MODULE,'ADJUSTMENT' TRANSACTIONTYPE, NVL(A.REMARKS,'INSERT DATA FROM PF LOAN INTEREST ADJUSTMENT ON '||TO_CHAR(SYSDATE,'DD/MM/YYYY')) REMARKS, A.USERNAME,SYS_GUID() SYSROWID, A.WORKERSERIAL, A.TOKENNO
    FROM GBL_PFLOANINTERESTADJUSMENT A, PFEMPLOYEEMASTER B, PFLOANINTEREST C
    WHERE A.COMPANYCODE=B.COMPANYCODE
    AND A.DIVISIONCODE=B.DIVISIONCODE
    AND A.WORKERSERIAL=B.WORKERSERIAL
    AND A.COMPANYCODE=C.COMPANYCODE
    AND A.DIVISIONCODE=C.DIVISIONCODE
    AND A.WORKERSERIAL=C.WORKERSERIAL
    AND A.LOANCODE=C.LOANCODE
    AND A.LOANDATE=C.LOANDATE; 
END IF;


end;
/



