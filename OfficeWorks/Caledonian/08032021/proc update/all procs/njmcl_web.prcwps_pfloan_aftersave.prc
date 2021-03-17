DROP PROCEDURE NJMCL_WEB.PRCWPS_PFLOAN_AFTERSAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRCWPS_PFLOAN_AFTERSAVE 
IS
LV_CNT                  NUMBER;
LV_RESULT               VARCHAR2(10);
LV_ERROR_REMARK         VARCHAR2(4000) := '' ;
LV_MASTER               GBL_PFLOANAPPLICATION%ROWTYPE;
LV_PF_C NUMBER;
LV_PF_E NUMBER;
LV_VPF  NUMBER; 
LV_FORTNIGHTSTARTDATE   VARCHAR2(10);
LV_FORTNIGHTENDDATE     VARCHAR2(10);
LV_LOANADJTYPE          VARCHAR2(1);

BEGIN
    lv_result:='#SUCCESS#';
    
    LV_PF_E :=0;
    LV_PF_C :=0;
    LV_VPF  :=0;
    
    if nvl(lv_master.loantype,'XX')='NONREFUNDABLE' then
        SELECT NVL(PF_E,0) PF_E, NVL(PF_C,0) PF_C, NVL(VPF,0) VPF INTO LV_PF_E ,LV_PF_C ,LV_VPF   
        FROM GBL_LOANSANCTION_DETAILS
        WHERE COMPANYCODE = lv_master.companycode
          AND DIVISIONCODE = lv_master.divisioncode
          AND PFNO = LV_MASTER.PFNO
          AND LOANCODE = LV_MASTER.LOANCODE
          AND LOANDATE = LV_MASTER.LOANDATE
          AND PARAM_NAME = 'SANCTION AMOUNT';
    END IF;    
    
    select *
    into lv_master
    from gbl_pfloanapplication
    where rownum<=1;

    select count(*)
    into lv_cnt
    from gbl_pfloanapplication;
        
    if nvl(lv_cnt,0)=0 then
        lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
        raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',5,lv_error_remark));
    end if;
       
    if lv_master.operationmode is null then
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
        raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark));
    end if;
    
    IF lv_master.operationmode <> 'A' THEN
        RETURN;
    END IF;
    UPDATE GBL_PFLOANAPPLICATION   A
    SET (EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE,GRADECODE, PF_E, PF_C, VPF) =
    (
        SELECT CURRENTCOMPANYCODE,CURRENTDIVISIONCODE,GRADECODE, LV_PF_E ,LV_PF_C ,LV_VPF 
        FROM PFEMPLOYEEMASTER
        WHERE PFNO = LV_MASTER.PFNO
        AND COMPANYCODE = LV_MASTER.COMPANYCODE
        AND DIVISIONCODE = LV_MASTER.DIVISIONCODE
    )
    WHERE PFNO = LV_MASTER.PFNO
    AND COMPANYCODE = LV_MASTER.COMPANYCODE
    AND DIVISIONCODE = LV_MASTER.DIVISIONCODE;
    
    
    UPDATE PFLOANAPPLICATION   A
    SET (EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE,GRADECODE,PF_E, PF_C, VPF) =
    (
        SELECT CURRENTCOMPANYCODE,CURRENTDIVISIONCODE,GRADECODE, LV_PF_E ,LV_PF_C ,LV_VPF 
        FROM PFEMPLOYEEMASTER
        WHERE PFNO = LV_MASTER.PFNO
        AND COMPANYCODE = LV_MASTER.COMPANYCODE
        AND DIVISIONCODE = LV_MASTER.DIVISIONCODE
    )
    WHERE PFNO = LV_MASTER.PFNO
    AND COMPANYCODE = LV_MASTER.COMPANYCODE
    AND DIVISIONCODE = LV_MASTER.DIVISIONCODE;
     
     
    select *
    into lv_master
    from gbl_pfloanapplication
    where rownum<=1;

    INSERT INTO PFLOANTRANSACTION  
    (
        COMPANYCODE, DIVISIONCODE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, YEARCODE, YEARMONTH, CATEGORYCODE, 
        GRADECODE, PFNO, WORKERSERIAL, TOKENNO, LOANCODE, LOANDATE, LOANTYPE, AMOUNT, INTERESTPERCENTAGE, NOOFINSTALLMENTS, 
        AGAINSTCOMPONENT, OPENINGBALANCE, RATIOPERCENT, COMPONENTAMOUNT, CLOSINGBALANCE, ACTUALLOANAMOUNT, ACTUALLOANDATE, 
        COMMITEDRECOVERYPERIOD, LOANCLAIMAMOUNT, INTERESTDEDNMONTHLY, LOANAMOUNTADJUSTED, LOANINTAMOUNTADJUSTED, AGAINSTLOANDATE, 
        AGAINSTLOANCODE, PAYABLEAMOUNT, APPLICATIONNO, AMOUNTINHAND, INTERESTAMOUNT, CAPITALINSTALLMENTAMT, INTERESTINSTALLMENTAMT, 
        REPAYCAPITAL, REPAYINTEREST, ADJUSTMENTDATE, REMARKS, DEPARTMENTCODE, FORTNIGHTSTARTDATE, LOANNL, NEXTLOAN, ACTUALINTERESTAMOUNT, 
        NEWINTERESTAMOUNT, DEDUCTIONSTARTDATE, INTERESTBALANCEAMOUNT, CAPITALBALANCEAMOUNT, CAPITALINSTALLMENTAMOUNT, INTERESTINSTALLMENTAMOUNT, 
        ADJUSTEDLOANDATE, TOTALEMIAMOUNT, PF_E, PF_C, VPF, MINBALANCE, ACTUALBALANCE, MODULE, PFGROSS, VOUCHERNO, VOUCHERDATE, SYSTEMVOUCHERNO, 
        SYSTEMVOUCHERDATE, CHEQUENO, CHEQUEDATE, ELIGIBLE, LASTMODIFIED, USERNAME, SYSROWID, LOANCF, SANCTIONEDAMOUNT, 
        PREV_LOAN_CAP_EMI, PREV_LOAN_INT_EMI, CURR_INT_EMI, CURR_CAP_EMI  
    )    
    SELECT  COMPANYCODE, DIVISIONCODE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, YEARCODE, YEARMONTH, CATEGORYCODE, 
    GRADECODE, PFNO, WORKERSERIAL, TOKENNO, LOANCODE, LOANDATE, LOANTYPE, AMOUNT, INTERESTPERCENTAGE, NOOFINSTALLMENTS, 
    AGAINSTCOMPONENT, OPENINGBALANCE, RATIOPERCENT, COMPONENTAMOUNT, CLOSINGBALANCE, ACTUALLOANAMOUNT, ACTUALLOANDATE, 
    COMMITEDRECOVERYPERIOD, LOANCLAIMAMOUNT, INTERESTDEDNMONTHLY, LOANAMOUNTADJUSTED, LOANINTAMOUNTADJUSTED, AGAINSTLOANDATE, 
    AGAINSTLOANCODE, PAYABLEAMOUNT, APPLICATIONNO, AMOUNTINHAND, INTERESTAMOUNT, CAPITALINSTALLMENTAMT, INTERESTINSTALLMENTAMT, 
    REPAYCAPITAL, REPAYINTEREST, ADJUSTMENTDATE, REMARKS, DEPARTMENTCODE, FORTNIGHTSTARTDATE, LOANNL, NEXTLOAN, ACTUALINTERESTAMOUNT, 
    NEWINTERESTAMOUNT, DEDUCTIONSTARTDATE, INTERESTBALANCEAMOUNT, CAPITALBALANCEAMOUNT, CAPITALINSTALLMENTAMOUNT, INTERESTINSTALLMENTAMOUNT, 
    ADJUSTEDLOANDATE, TOTALEMIAMOUNT, PF_E, PF_C, VPF, MINBALANCE, ACTUALBALANCE, MODULE, PFGROSS, VOUCHERNO, VOUCHERDATE, SYSTEMVOUCHERNO, 
    SYSTEMVOUCHERDATE, CHEQUENO, CHEQUEDATE, ELIGIBLE,SYSDATE LASTMODIFIED, USERNAME, SYSROWID, LOANCF, SANCTIONEDAMOUNT, 
    PREV_LOAN_CAP_EMI, PREV_LOAN_INT_EMI, CURR_INT_EMI, CURR_CAP_EMI
    FROM PFLOANAPPLICATION
    WHERE PFNO = LV_MASTER.PFNO
      AND LOANCODE = LV_MASTER.LOANCODE
      AND LOANDATE = LV_MASTER.LOANDATE;
    
    SELECT LOANADJTYPE INTO LV_LOANADJTYPE
    FROM PFLOANMASTER
    WHERE COMPANYCODE = LV_MASTER.COMPANYCODE
      AND DIVISIONCODE = LV_MASTER.DIVISIONCODE
      AND LOANCODE = LV_MASTER.LOANCODE;
   
--    IF LV_LOANADJTYPE = 'D' THEN 
    IF (LV_MASTER.LOANAMOUNTADJUSTED + LV_MASTER.LOANINTAMOUNTADJUSTED) > 0 THEN 
      
        INSERT INTO PFLOANBREAKUP 
        (
            COMPANYCODE, DIVISIONCODE,EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, MODULE, YEARCODE, YEARMONTH, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO,PFNO,
            LOANCODE, LOANDATE, EFFECTYEARMONTH, INTERESTPERCENTAGE, AMOUNT, REPAYAMOUNT, REPAYCAPITAL, REPAYINTEREST,REMARKS,
            TRANSACTIONTYPE, EFFECTFORTNIGHT, PAIDON, DEDUCTEDAMT, SYSROWID, USERNAME
        )
        SELECT COMPANYCODE, DIVISIONCODE,EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, MODULE, YEARCODE, YEARMONTH, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO,PFNO,
               AGAINSTLOANCODE, AGAINSTLOANDATE, YEARMONTH, INTERESTPERCENTAGE, LOANAMOUNTADJUSTED + LOANINTAMOUNTADJUSTED, 
               LOANAMOUNTADJUSTED + LOANINTAMOUNTADJUSTED, LOANAMOUNTADJUSTED, LOANINTAMOUNTADJUSTED, 
               'ADJUSTED WITH THE LOAN CODE '|| LOANCODE || ' DATED ' || TO_DATE(LOANDATE,'DD/MM/YYYY'),
               'REPAY', DEDUCTIONSTARTDATE, LOANDATE, 0, SYSROWID, USERNAME 
          FROM PFLOANAPPLICATION
         WHERE PFNO = LV_MASTER.PFNO
           AND LOANCODE = LV_MASTER.LOANCODE
           AND LOANDATE = LV_MASTER.LOANDATE;
      
    END IF;  

    if nvl(lv_master.module,'XX')='WPS' then
        select to_char(fortnightstartdate,'DD/MM/RRRR'),to_char(fortnightenddate,'DD/MM/RRRR') 
          into lv_fortnightstartdate,lv_fortnightenddate
          from wpswagedperioddeclaration
         where companycode=lv_master.EMPLOYEECOMPANYCODE and divisioncode=lv_master.EMPLOYEEdivisioncode and to_date(lv_master.loandate,'DD/MM/RRRR') between fortnightstartdate and fortnightenddate;
    else
        select '01/'||substr(lv_master.loandate,4),TO_CHAR(last_day(to_date(lv_master.loandate,'DD/MM/RRRR')),'DD/MM/YYYY') 
          into lv_fortnightstartdate,lv_fortnightenddate
          from dual;
    end if;

    if nvl(lv_master.loantype,'XX')='NONREFUNDABLE' then
--        if nvl(lv_master.module,'XX')='WPS' then
--            select to_char(fortnightstartdate,'DD/MM/RRRR'),to_char(fortnightenddate,'DD/MM/RRRR') 
--              into lv_fortnightstartdate,lv_fortnightenddate
--              from wpswagedperioddeclaration
--             where companycode=lv_master.companycode and divisioncode=lv_master.divisioncode and to_date(lv_master.loandate,'DD/MM/RRRR') between fortnightstartdate and fortnightenddate;
--        else
--            select '01/'||substr(lv_master.loandate,4),TO_CHAR(last_day(to_date(lv_master.loandate,'DD/MM/RRRR')),'DD/MM/YYYY') 
--              into lv_fortnightstartdate,lv_fortnightenddate
--              from dual;
--        end if;
        
        SELECT PF_E,PF_C,VPF INTO LV_PF_E ,LV_PF_C ,LV_VPF   
        FROM GBL_LOANSANCTION_DETAILS
        WHERE COMPANYCODE = lv_master.companycode
          AND DIVISIONCODE = lv_master.divisioncode
          AND PFNO = LV_MASTER.PFNO
          AND LOANCODE = LV_MASTER.LOANCODE
          AND LOANDATE = LV_MASTER.LOANDATE
          AND PARAM_NAME = 'SANCTION AMOUNT';
        
        delete from pftransactiondetails 
        where companycode=lv_master.companycode
          and divisioncode=lv_master.divisioncode
          and yearmonth=lv_master.yearmonth
          and startdate=to_date(lv_fortnightstartdate,'dd/mm/yyyy') 
          and enddate=to_date(lv_fortnightenddate,'dd/mm/yyyy')
          and workerserial=lv_master.workerserial
          and pfno=lv_master.pfno
          and transactiontype='LOAN';
        
        if LV_PF_E >0 then
            insert into pftransactiondetails
            select companycode, divisioncode, yearcode, yearmonth, to_date(lv_fortnightstartdate,'dd/mm/yyyy') startdate, 
                   to_date(lv_fortnightenddate,'dd/mm/yyyy') enddate, pfno, workerserial, tokenno, 
                   'PF_E' componentcode, -1*LV_PF_E componentamount, 'LOAN' transactiontype, lv_master.module postedfrom, 
                   'WORKER' employmenttype, 'LESS' addless, null pftrustcode, 
                   0 int_per, 0 int_amt, pf_e total_amt, null pensionno, 0 averagebalance, employeecompanycode, employeedivisioncode, 
                   module, 0 adj_amt, remarks, voucherno, voucherdate, systemvoucherno, systemvoucherdate, 
                   loandate applicationdate, applicationno,SYSDATE LASTMODIFIEDDATE,username,SYSROWID
             from pfloantransaction
            where companycode=lv_master.companycode
              and divisioncode=lv_master.divisioncode
              and yearmonth=lv_master.yearmonth
              and loandate between to_date(lv_fortnightstartdate,'dd/mm/yyyy') and to_date(lv_fortnightenddate,'dd/mm/yyyy')
              and workerserial=lv_master.workerserial
              and pfno=lv_master.pfno;
        end if;
        
        if LV_PF_C >0 then
            insert into pftransactiondetails
            select companycode, divisioncode, yearcode, yearmonth, to_date(lv_fortnightstartdate,'dd/mm/yyyy') startdate, 
                   to_date(lv_fortnightenddate,'dd/mm/yyyy') enddate, pfno, workerserial, tokenno, 
                   'PF_C' componentcode, -1*LV_PF_C componentamount, 'LOAN' transactiontype, lv_master.module postedfrom, 
                   'WORKER' employmenttype, 'LESS' addless, null pftrustcode, 
                   0 int_per, 0 int_amt, pf_c total_amt, null pensionno, 0 averagebalance, employeecompanycode, employeedivisioncode, 
                   module, 0 adj_amt, remarks, voucherno, voucherdate, systemvoucherno, systemvoucherdate, 
                   loandate applicationdate, applicationno,SYSDATE LASTMODIFIEDDATE,username,SYSROWID
             from pfloantransaction
            where companycode=lv_master.companycode
              and divisioncode=lv_master.divisioncode
              and yearmonth=lv_master.yearmonth
              and loandate between to_date(lv_fortnightstartdate,'dd/mm/yyyy') and to_date(lv_fortnightenddate,'dd/mm/yyyy')
              and workerserial=lv_master.workerserial
              and pfno=lv_master.pfno;
        end if;
        
        if LV_VPF>0 then
            insert into pftransactiondetails
            select companycode, divisioncode, yearcode, yearmonth, to_date(lv_fortnightstartdate,'dd/mm/yyyy') startdate, 
                   to_date(lv_fortnightenddate,'dd/mm/yyyy') enddate, pfno, workerserial, tokenno, 
                   'VPF' componentcode, -1*LV_VPF componentamount, 'LOAN' transactiontype, lv_master.module postedfrom, 
                   'WORKER' employmenttype, 'LESS' addless, null pftrustcode, 
                   0 int_per, 0 int_amt, vpf total_amt, null pensionno, 0 averagebalance, employeecompanycode, employeedivisioncode, 
                   module, 0 adj_amt, remarks, voucherno, voucherdate, systemvoucherno, systemvoucherdate, 
                   loandate applicationdate, applicationno,SYSDATE LASTMODIFIEDDATE,username,SYSROWID
             from pfloantransaction
            where companycode=lv_master.companycode
              and divisioncode=lv_master.divisioncode
              and yearmonth=lv_master.yearmonth
              and loandate between to_date(lv_fortnightstartdate,'dd/mm/yyyy') and to_date(lv_fortnightenddate,'dd/mm/yyyy')
              and workerserial=lv_master.workerserial
              and pfno=lv_master.pfno;
        end if;
    ELSE
       
             FOR C1 IN (SELECT PFNO,LOANCODE,LOANDATE FROM GBL_PFLOANAPPLICATION)
             LOOP
               DELETE FROM PFLOANINTEREST 
               WHERE PFNO = C1.PFNO
               AND LOANCODE = C1.LOANCODE
               AND YEARMONTH=TO_CHAR(C1.LOANDATE,'YYYYMM');
             END LOOP;
           
           
            INSERT INTO PFLOANINTEREST
            (
                COMPANYCODE, DIVISIONCODE,EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, YEARCODE, YEARMONTH, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE,LOANCODE, WORKERSERIAL, TOKENNO, PFNO,
                LOANDATE, LOANAMOUNT, INTERESTAPPLICABLEON, INTERESTPERCENTAGE, INTERESTAMOUNT, MODULE, TRANSACTIONTYPE, REMARKS, 
                USERNAME, SYSROWID
            )
            SELECT COMPANYCODE, DIVISIONCODE,EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, YEARCODE, YEARMONTH, TO_DATE(LV_FORTNIGHTSTARTDATE,'DD/MM/RRRR'), TO_DATE(LV_FORTNIGHTENDDATE,'DD/MM/RRRR'), LOANCODE, WORKERSERIAL, TOKENNO, PFNO,
            LOANDATE, ACTUALLOANAMOUNT, ACTUALLOANAMOUNT, INTERESTPERCENTAGE, INTERESTAMOUNT+LOANINTAMOUNTADJUSTED, MODULE,'ADD',NULL,
            USERNAME, 1 SYSROWID  FROM GBL_PFLOANAPPLICATION; 
            
            
            
            --ADDED ON 29/07/2020
--            IF LV_MASTER.LOANINTAMOUNTADJUSTED > 0 AND LV_LOANADJTYPE = 'D' THEN
--                INSERT INTO PFLOANINTEREST
--                (
--                    COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE,LOANCODE, WORKERSERIAL, TOKENNO, PFNO,
--                    LOANDATE, LOANAMOUNT, INTERESTAPPLICABLEON, INTERESTPERCENTAGE, INTERESTAMOUNT, MODULE, TRANSACTIONTYPE, REMARKS, 
--                    USERNAME, SYSROWID
--                )
--                SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, TO_DATE(LV_FORTNIGHTSTARTDATE,'DD/MM/RRRR'), TO_DATE(LV_FORTNIGHTENDDATE,'DD/MM/RRRR'), AGAINSTLOANCODE, WORKERSERIAL, TOKENNO, PFNO,
--                AGAINSTLOANDATE, ACTUALLOANAMOUNT, LOANAMOUNTADJUSTED, INTERESTPERCENTAGE, LOANINTAMOUNTADJUSTED, MODULE,'ADD',NULL,
--                USERNAME, 1 SYSROWID  FROM GBL_PFLOANAPPLICATION; 
--            END IF;
            --ENDED ON 29/07/2020
            
       
            
           
    end if;
    
end;
/


