CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_PISSALARY_DATA_IMPORT1
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_YEARMONTH VARCHAR2
)
AS
LV_SQLSTR VARCHAR2(1000);

LV_CNTCHKDUP            NUMBER;
LV_COMPCODE             VARCHAR2(10):='';
LV_DIVCODE             VARCHAR2(10):='';
LV_YEARCODE             VARCHAR2(10):='';
LV_YYYYMM               VARCHAR2(6):=''; 
LV_MODULE               VARCHAR2(10):='';    
BEGIN

    DELETE FROM PISPAYTRANSACTION 
    WHERE 1=1
--    AND COMPANYCODE=P_COMPANYCODE
--    AND DIVISIONCODE=P_DIVISIONCODE
    AND YEARMONTH=P_YEARMONTH;

    INSERT INTO PISPAYTRANSACTION
    (
        COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH,EFFECT_YEARMONTH, 
        UNITCODE, CATEGORYCODE, GRADECODE,DEPARTMENTCODE, TOKENNO, WORKERSERIAL, 
        ATTN_SALD, ATTN_WPAY,ATTN_WRKD, GROSSEARN, PF_GROSS, PEN_GROSS, ESI_GROSS, 
        PTAX_GROSS, PF_E, EPF, PF_C, PTAX, ESI_E, ESI_C, LOAN_MPL, LINT_MPL, TRANSACTIONTYPE
    )
    SELECT B.COMPANYCODE, B.DIVISIONCODE, B.YEARCODE, YEARMONTH,YEARMONTH EFFECT_YEARMONTH, 
    '01' UNITCODE, A.CATEGORYCODE, A.GRADECODE,    A.DEPARTMENTCODE,A.TOKENNO , A.WORKERSERIAL , 
    B.ATTN_SALD, B.NCP_DAYS,B.ATTN_SALD ATTN_WRKD, B.GROSSWAGES, B.PF_GROSS, B.PEN_GROSS, B.ESI_GROSS, 
    B.PTAX_GROSS, B.PF_E, B.EPF, B.PF_C, B.PTAX, B.ESI_E, B.ESI_C, B.LOAN_MPL, B.LINT_MPL, 'SALARY'  TRANSACTIONTYPE
    FROM PISEMPLOYEEMASTER A,
    (
        SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, UNITCODE, CATEGORYCODE, GRADECODE, LPAD(EMPLOYEECODE,5,'7') TOKENNO , 
        ATTN_SALD, NCP_DAYS, GROSSWAGES, PF_GROSS, PEN_GROSS, ESI_GROSS, PTAX_GROSS, PF_E, EPF, PF_C, PTAX, ESI_E, ESI_C, 
        LOAN_MPL, LINT_MPL FROM PISSALARYUPLOADRAWDATA
        WHERE 1=1
--        and COMPANYCODE=P_COMPANYCODE
--        AND DIVISIONCODE=P_DIVISIONCODE
        AND YEARMONTH=P_YEARMONTH
    ) B
    WHERE A.TOKENNO=B.TOKENNO;
    
    UPDATE PISPAYTRANSACTION SET FPF=EPF WHERE YEARMONTH=P_YEARMONTH;
    
    --ADDED ON 09/11/2020 BY CHIRANJIT GHOSH
    DELETE FROM GBL_STAFFPFDATAUPLOAD WHERE 1=1;
    
     INSERT INTO GBL_STAFFPFDATAUPLOAD   (
        OPERATIONMODE, SYSROWID, VPF, REMARKS, UPDATESTATUS, MODULE, LOAN_CAP, PF_E, PF_C, LOAN_INT, 
        USERNAME, COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, WORKERSERIAL, TOKENNO
     )
     
    SELECT 'A' OPERATIONMODE, SYS_guid() SYSROWID,0 VPF,'INSERT DATA FROM PROCEDURE' REMARKS,'Y' UPDATESTATUS,
    'PIS' MODULE, LOAN_CAP, PF_E, PF_C, LOAN_INT, 
    'MIGR' USERNAME, B.COMPANYCODE, B.DIVISIONCODE, A.YEARCODE, A.YEARMONTH, B.WORKERSERIAL, B.TOKENNO 
    FROM (
        SELECT 0 VPF, LOAN_MPL  LOAN_CAP,  PF_E,  PF_C, LINT_MPL LOAN_INT, 
        COMPANYCODE,  DIVISIONCODE, YEARCODE,  YEARMONTH,
        LPAD(EMPLOYEECODE,5,'7') TOKENNO
        FROM PISSALARYUPLOADRAWDATA 
        WHERE YEARMONTH=P_YEARMONTH
    ) A  , PFEMPLOYEEMASTER B
    WHERE A.TOKENNO=B.TOKENNO;
          
    
    
    --SELECT ALL VALUES AND ASSIGN TO VARIABLES 
--        SELECT DISTINCT COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, MODULE
--        INTO LV_COMPCODE, LV_DIVCODE, LV_YEARCODE, LV_YYYYMM, LV_MODULE
--        FROM GBL_STAFFPFDATAUPLOAD;
        
 
--COMMENTED ON 08/12/2020       
        --DELETE PREVIOUS RECORDS
--        DELETE FROM PFTRANSACTIONDETAILS
--        WHERE EMPLOYEECOMPANYCODE=lv_CompCode
--        AND EMPLOYEEDIVISIONCODE=lv_DivCode
--        AND YEARCODE=lv_YearCode
--        AND TRANSACTIONTYPE = 'SALARY'
--        AND YEARMONTH=lv_YYYYMM
--        AND MODULE =lv_Module 
--        AND WORKERSERIAL IN (
--                SELECT DISTINCT WORKERSERIAL FROM GBL_STAFFPFDATAUPLOAD
--            ) ;
--COMMENTED ON 08/12/2020

--ADDED ON 08/12/2020
        DELETE FROM PFTRANSACTIONDETAILS
        WHERE 1=1/*EMPLOYEECOMPANYCODE=lv_CompCode
        AND EMPLOYEEDIVISIONCODE=lv_DivCode
        AND YEARCODE=lv_YearCode*/
        AND TRANSACTIONTYPE = 'SALARY'
        AND YEARMONTH=P_YEARMONTH
--        AND MODULE =lv_Module 
        AND WORKERSERIAL IN 
        (
            SELECT DISTINCT WORKERSERIAL FROM GBL_STAFFPFDATAUPLOAD
        ) ;
--ENDED ON 08/12/2020


        --INSERT RECORDS TO PF TRANSACTION DETAILS
        INSERT INTO PFTRANSACTIONDETAILS(
        COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH, STARTDATE, ENDDATE, PFNO, WORKERSERIAL, TOKENNO, 
        COMPONENTCODE, COMPONENTAMOUNT, TRANSACTIONTYPE, POSTEDFROM, EMPLOYMENTTYPE, ADDLESS,PFTRUSTCODE,
        INT_PER, INT_AMT, TOTAL_AMT, PENSIONNO, AVERAGEBALANCE,EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, MODULE, REMARKS
        )
        SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, YEARMONTH,TO_DATE(YEARMONTH,'YYYYMM') STARTDATE, LAST_DAY(TO_DATE(YEARMONTH,'YYYYMM')) ENDDATE, PFNO, B.WORKERSERIAL, B.TOKENNO,
        COMP_CODE COMPONENTCODE,COMP_VAL COMPONENTAMOUNT,'SALARY' TRANSACTIONTYPE, A.MODULE POSTEDFROM, 'STAFF' EMPLOYMENTTYPE,'ADD' ADDLESS, 'T001' PFTRUSTCODE,
        0 INT_PER, 0 INT_AMT,COMP_VAL TOTAL_AMT, B.PENSIONNO,0 AVERAGEBALANCE,COMPANYCODE EMPLOYEECOMPANYCODE, DIVISIONCODE EMPLOYEEDIVISIONCODE,A.MODULE MODULE, 'DATA TRANSAFER FROM EXCEL' REMARKS
        FROM
        (
            SELECT WORKERSERIAL,TOKENNO,YEARCODE,YEARMONTH, 'PF_C' COMP_CODE, PF_C COMP_VAL, MODULE FROM GBL_STAFFPFDATAUPLOAD WHERE PF_C > 0
            UNION ALL
            SELECT WORKERSERIAL,TOKENNO,YEARCODE,YEARMONTH, 'PF_E' COMP_CODE, PF_E COMP_VAL, MODULE FROM GBL_STAFFPFDATAUPLOAD WHERE PF_E > 0
            UNION ALL
            SELECT WORKERSERIAL,TOKENNO,YEARCODE,YEARMONTH, 'VPF' COMP_CODE, VPF COMP_VAL, MODULE FROM GBL_STAFFPFDATAUPLOAD WHERE VPF > 0
        ) A, PFEMPLOYEEMASTER B
        WHERE A.WORKERSERIAL=B.WORKERSERIAL;

--COMMENTED ON 08/12/2020
        --DELETE 
--        DELETE FROM PFLOANBREAKUP
--        WHERE EMPLOYEECOMPANYCODE=lv_CompCode
--        AND EMPLOYEEDIVISIONCODE=lv_DivCode
--        AND YEARCODE=lv_YearCode
--        AND YEARMONTH=lv_YYYYMM
--        AND MODULE =lv_Module 
--        AND WORKERSERIAL IN (
--                SELECT DISTINCT WORKERSERIAL FROM GBL_STAFFPFDATAUPLOAD
--            ) ;
--COMMENTED ON 08/12/2020

        --DELETE 
        DELETE FROM PFLOANBREAKUP
        WHERE 1=1 /*EMPLOYEECOMPANYCODE=lv_CompCode
        AND EMPLOYEEDIVISIONCODE=lv_DivCode
        AND YEARCODE=lv_YearCode
        AND YEARMONTH=lv_YYYYMM
        AND MODULE =lv_Module */
        AND YEARMONTH=P_YEARMONTH
        AND WORKERSERIAL IN (
                SELECT DISTINCT WORKERSERIAL FROM GBL_STAFFPFDATAUPLOAD
            ) ;

                    
        INSERT INTO PFLOANBREAKUP
        (
            COMPANYCODE, DIVISIONCODE, EMPLOYEECOMPANYCODE, EMPLOYEEDIVISIONCODE, YEARCODE, YEARMONTH, CATEGORYCODE, 
                GRADECODE, PFNO, TOKENNO, WORKERSERIAL, LOANCODE, LOANDATE, EFFECTYEARMONTH,  AMOUNT, 
                TRANSACTIONTYPE, EFFECTFORTNIGHT, PAIDON, ISPAID, REMARKS, MODULE, SYSROWID, USERNAME, LASTMODIFIED
        )   
        SELECT  A.COMPANYCODE, A.DIVISIONCODE, A.COMPANYCODE EMPLOYEECOMPANYCODE, A.DIVISIONCODE EMPLOYEEDIVISIONCODE, YEARCODE, YEARMONTH, CATEGORYCODE,
         GRADECODE, B.PFNO, A.TOKENNO, A.WORKERSERIAL, C.LOANCODE, C.LOANDATE,YEARMONTH EFFECTYEARMONTH, AMOUNT,
         TRANSACTIONTYPE,PAIDON EFFECTFORTNIGHT, PAIDON,'Y' ISPAID, 'BULK TRANSFER FROM PF DATA UPLOAD' REMARKS, A.MODULE,
         A.TOKENNO||'-'||TRANSACTIONTYPE||'-'||C.LOANCODE||'-'||TO_CHAR(PAIDON,'DDMMYYYY') SYSROWID, A.USERNAME, SYSDATE LASTMODIFIED
        FROM
        (   
            SELECT COMPANYCODE, DIVISIONCODE,YEARCODE, YEARMONTH, WORKERSERIAL, TOKENNO, LOAN_CAP AMOUNT,'CAPITAL' TRANSACTIONTYPE, LAST_DAY(TO_DATE(YEARMONTH,'YYYYMM')) PAIDON, MODULE,USERNAME FROM GBL_STAFFPFDATAUPLOAD WHERE  LOAN_CAP > 0
            UNION ALL
            SELECT COMPANYCODE, DIVISIONCODE,YEARCODE, YEARMONTH, WORKERSERIAL, TOKENNO, LOAN_INT AMOUNT,'INTEREST' TRANSACTIONTYPE, LAST_DAY(TO_DATE(YEARMONTH,'YYYYMM')) PAIDON, MODULE,USERNAME  FROM GBL_STAFFPFDATAUPLOAD WHERE  LOAN_INT > 0
        ) A, PFEMPLOYEEMASTER B,
        (
            SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, LOANCODE, MAX(LOANDATE) LOANDATE FROM PFLOANTRANSACTION PFL
            WHERE WORKERSERIAL IN (
                SELECT DISTINCT WORKERSERIAL FROM GBL_STAFFPFDATAUPLOAD
            ) 
            AND LOANDATE = 
            (
                SELECT MAX(LOANDATE) FROM PFLOANTRANSACTION
                WHERE COMPANYCODE=PFL.COMPANYCODE
                AND DIVISIONCODE=PFL.DIVISIONCODE
                AND WORKERSERIAL=PFL.WORKERSERIAL
            )
            AND LOANTYPE ='REFUNDABLE'
            GROUP BY COMPANYCODE, DIVISIONCODE,WORKERSERIAL, LOANCODE
        ) C
        WHERE A.WORKERSERIAL=B.WORKERSERIAL
        AND     A.TOKENNO=B.TOKENNO
        AND     A.COMPANYCODE=B.COMPANYCODE
        AND     A.DIVISIONCODE=B.DIVISIONCODE
        AND     A.MODULE=B.MODULE
        AND     A.WORKERSERIAL=C.WORKERSERIAL
        AND     A.COMPANYCODE=C.COMPANYCODE
        AND     A.DIVISIONCODE=C.DIVISIONCODE;

                    
        DELETE FROM STAFFPFDATAUPLOAD
        WHERE WORKERSERIAL IN (SELECT DISTINCT WORKERSERIAL FROM GBL_STAFFPFDATAUPLOAD)
        AND YEARMONTH = lv_YYYYMM;
        
        INSERT INTO STAFFPFDATAUPLOAD 
        (
            COMPANYCODE, DIVISIONCODE, YEARMONTH, WORKERSERIAL, TOKENNO, PF_E, PF_C, VPF, 
            LOAN_CAP, LOAN_INT, REMARKS, UPDATESTATUS, MODULE, USERNAME, LASTMODIFIED, 
            SYSROWID, YEARCODE, GROSSEARN, PF_GROSS, PEN_GROSS, ESI_E, ATTN_SALD, ATTN_WPAY
        )        
        SELECT COMPANYCODE, DIVISIONCODE, YEARMONTH, WORKERSERIAL, TOKENNO, PF_E, PF_C, VPF, 
        LOAN_CAP, LOAN_INT, REMARKS, UPDATESTATUS, MODULE, USERNAME,SYSDATE LASTMODIFIED, 
        SYSROWID, YEARCODE,0 GROSSEARN,0 PF_GROSS,0 PEN_GROSS,0 ESI_E,0 ATTN_SALD,0 ATTN_WPAY
        FROM GBL_STAFFPFDATAUPLOAD; 
        
        
END;
/