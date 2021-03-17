DROP VIEW NJMCL_WEB.VW_PFSUMM_DATA_TEMP;

/* Formatted on 09/12/2020 5:44:06 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.VW_PFSUMM_DATA_TEMP
(
   COMPANYCODE,
   DIVISIONCODE,
   EMPLOYEECOMPANYCODE,
   EMPLOYEEDIVISIONCODE,
   PFNO,
   YEARCODE,
   YEARMONTH,
   FORTNIGHTSTARTDATE,
   FORTNIGHTENDDATE,
   PFGROSS,
   PEN_GROSS,
   PF_E,
   PF_C,
   PEN,
   VPF,
   LOAN_PFL,
   LINT_PFL,
   ATTENDANCEHOURS,
   WORKINGDAYS,
   WITHOUTPAYDAYS,
   BASIC,
   DA,
   ADHOC,
   TOTALEARNING,
   MODULE,
   TOTALDEDUCTION,
   NETSALARY,
   OVERTIMEHOURS,
   HOLIDAYHOURS,
   WORKERSERIAL,
   TOKENNO,
   ESI_GROSS,
   ESI_E,
   ESI_C,
   LEAVEENCASH,
   REMARKS,
   GROSSEARN
)
AS
     SELECT   COMPANYCODE,
              DIVISIONCODE,
              EMPLOYEECOMPANYCODE,
              EMPLOYEEDIVISIONCODE,
              PFNO,
              YEARCODE,
              YEARMONTH,
              FORTNIGHTSTARTDATE,
              FORTNIGHTENDDATE,
              SUM (NVL (PFGROSS, 0)) PFGROSS,
              CASE WHEN SUM (NVL (PEN_GROSS, 0)) > 15000 THEN 15000 ELSE SUM (NVL (PEN_GROSS, 0)) END   PEN_GROSS,
              SUM (NVL (PF_E, 0)) PF_E,
              SUM (NVL (PF_C, 0)) PF_C,
              SUM (NVL (PEN, 0)) PEN,
              SUM (NVL (VPF, 0)) VPF,
              SUM (NVL (LOAN_PFL, 0)) LOAN_PFL,
              SUM (NVL (LINT_PFL, 0)) LINT_PFL,
              SUM (NVL (ATTENDANCEHOURS, 0)) ATTENDANCEHOURS,
              SUM (NVL (WORKINGDAYS, 0)) WORKINGDAYS,
              SUM (NVL (WITHOUTPAYDAYS, 0)) WITHOUTPAYDAYS,
              SUM (NVL (BASIC, 0)) BASIC,
              SUM (NVL (DA, 0)) DA,
              SUM (NVL (ADHOC, 0)) ADHOC,
              SUM (NVL (TOTALEARNING, 0)) TOTALEARNING,
              MODULE,
              SUM (NVL (TOTALDEDUCTION, 0)) TOTALDEDUCTION,
              SUM (NVL (NETSALARY, 0)) NETSALARY,
              SUM (NVL (OVERTIMEHOURS, 0)) OVERTIMEHOURS,
              SUM (NVL (HOLIDAYHOURS, 0)) HOLIDAYHOURS,
              WORKERSERIAL,
              TOKENNO,
              SUM (NVL (ESI_GROSS, 0)) ESI_GROSS,
              SUM (NVL (ESI_E, 0)) ESI_E,
              SUM (NVL (ESI_C, 0)) ESI_C,
              SUM (NVL (LEAVEENCASH, 0)) LEAVEENCASH,
              REMARKS,
              SUM (NVL (GROSSEARN, 0)) GROSSEARN
       FROM   (SELECT   A.COMPANYCODE,
                        A.DIVISIONCODE,
                        '0002' EMPLOYEECOMPANYCODE,
                        '0010' EMPLOYEEDIVISIONCODE,
                        PFNO,
                        YEARCODE,
                        YEARMONTH,
                        YEARMONTH FORTNIGHTSTARTDATE,
                        YEARMONTH FORTNIGHTENDDATE,
                        PF_GROSS PFGROSS,
                        PEN_GROSS,
                        PF_E,
                        PF_C,
                        FPF PEN,
                        VPF,
                        LOAN_PFL,
                        LINT_PFL,
                        0 ATTENDANCEHOURS,
                        ATTN_WRKD WORKINGDAYS,
                        ATTN_WPAY WITHOUTPAYDAYS,
                        BASIC,
                        DA,
                        ADHOC,
                        TOTEARN TOTALEARNING,
                        'PIS' MODULE,
                        TOTDEDN TOTALDEDUCTION,
                        NETSALARY,
                        OT_HRS OVERTIMEHOURS,
                        0 HOLIDAYHOURS,
                        A.WORKERSERIAL,
                        A.TOKENNO,
                        ESI_GROSS,
                        ESI_E,
                        ESI_C,
                        LEAVE_ENC LEAVEENCASH,
                        '' REMARKS,
                        GROSSEARN
                 FROM   PISPAYTRANSACTION A, PISEMPLOYEEMASTER B
                WHERE       A.COMPANYCODE = A.COMPANYCODE
                        AND A.DIVISIONCODE = B.DIVISIONCODE
                        AND A.WORKERSERIAL = B.WORKERSERIAL
               UNION ALL
                 SELECT   COMPANYCODE,
                          DIVISIONCODE,
                          EMPLOYEECOMPANYCODE,
                          EMPLOYEEDIVISIONCODE,
                          PFNO,
                          YEARCODE,
                          YEARMONTH,
                          MAX (YEARMONTH) FORTNIGHTSTARTDATE,
                          MAX (YEARMONTH) FORTNIGHTENDDATE,
                          SUM (PF_GROSS) PFGROSS,
                          SUM (PENSION_GROSS)  PENSION_GROSS,
                          SUM (PF_CONT) PF_CONT,
                          SUM (PF_COM) PF_COM,
                          SUM (PEN) PEN,
                          SUM (VPF) VPF,
                          SUM (LOAN_PFL) LOAN_PFL,
                          SUM (LINT_PFL) LINT_PFL,
                          SUM (ATTENDANCEHOURS) ATTENDANCEHOURS,
                          SUM (WORKINGDAYS) WORKINGDAYS,
                          SUM (WITHOUTPAYDAYS) WITHOUTPAYDAYS,
                          SUM (BASIC) BASIC,
                          SUM (DA) DA,
                          SUM (ADHOC) ADHOC,
                          SUM (TOTALEARNING) TOTALEARNING,
                          MODULE,
                          SUM (TOTALDEDUCTION) TOTALDEDUCTION,
                          SUM (NETSALARY) NETSALARY,
                          SUM (OVERTIMEHOURS) OVERTIMEHOURS,
                          SUM (HOLIDAYHOURS) HOLIDAYHOURS,
                          WORKERSERIAL,
                          TOKENNO,
                          SUM (ESI_GROSS) ESI_GROSS,
                          SUM (ESI_E) ESI_E,
                          SUM (ESI_C) ESI_C,
                          SUM (LEAVEENCASH) LEAVEENCASH,
                          REMARKS,
                          SUM (GROSS_WAGES) GROSSEARN
                   FROM   (SELECT   A.COMPANYCODE,
                                    A.DIVISIONCODE,
                                    '0002' EMPLOYEECOMPANYCODE,
                                    '0010' EMPLOYEEDIVISIONCODE,
                                    PFNO,
                                    YEARCODE,
                                    TO_CHAR (FORTNIGHTSTARTDATE, 'YYYYMM')
                                       YEARMONTH,
                                    FORTNIGHTSTARTDATE,
                                    FORTNIGHTENDDATE,
                                    PF_GROSS,
                                    PENSION_GROSS,
                                    PF_CONT,
                                    PF_COM,
                                    FPF PEN,
                                    VPF,
                                    LOAN_PFL,
                                    LINT_PFL,
                                    ATTENDANCEHOURS ATTENDANCEHOURS,
                                    FEWORKINGDAYS WORKINGDAYS,
                                    CASE
                                       WHEN FEWORKINGDAYS >= 26 THEN 0
                                       ELSE (26 - FEWORKINGDAYS)
                                    END
                                       WITHOUTPAYDAYS,
                                    VBASIC BASIC,
                                    DA,
                                    ADHOC,
                                    TOT_EARN TOTALEARNING,
                                    'WPS' MODULE,
                                    TOT_DEDUCTION TOTALDEDUCTION,
                                    ACTUALPAYBLEAMOUNT NETSALARY,
                                    OVERTIMEHOURS,
                                    HOLIDAYHOURS,
                                    A.WORKERSERIAL,
                                    A.TOKENNO,
                                    ESI_GROSS,
                                    0 ESI_E,
                                    0 ESI_C,
                                    STL_ENCASH LEAVEENCASH,
                                    '' REMARKS,
                                    GROSS_WAGES
                             FROM   WPSWAGESDETAILS_MV A, WPSWORKERMAST B
                            WHERE       A.COMPANYCODE = A.COMPANYCODE
                                    AND A.DIVISIONCODE = B.DIVISIONCODE
                                    AND A.WORKERSERIAL = B.WORKERSERIAL)
               GROUP BY   COMPANYCODE,
                          DIVISIONCODE,
                          YEARMONTH,
                          EMPLOYEECOMPANYCODE,
                          EMPLOYEEDIVISIONCODE,
                          PFNO,
                          YEARCODE,
                          MODULE,
                          REMARKS,
                          WORKERSERIAL,
                          TOKENNO
               UNION ALL
               SELECT   A.COMPANYCODE,
                        A.DIVISIONCODE,
                        '0002' EMPLOYEECOMPANYCODE,
                        '0010' EMPLOYEEDIVISIONCODE,
                        PFNO,
                        YEARCODE,
                        TO_CHAR (PAYMENTDATE, 'YYYYMM') YEARMONTH,
                        TO_CHAR (PAYMENTDATE, 'YYYYMM') FORTNIGHTSTARTDATE,
                        TO_CHAR (PAYMENTDATE, 'YYYYMM') FORTNIGHTENDDATE,
                        PF_GROSS,
                        PF_GROSS PENSION_GROSS,
                        PF_E,
                        PF_C,
                        FPF PEN,
                        0 VPF,
                        0 LOAN_PFL,
                        0 LINT_PFL,
                        ATTENDANCEHOURS ATTENDANCEHOURS,
                        STLDAYS WORKINGDAYS,
                        0 WITHOUTPAYDAYS,
                        0 BASIC,
                        DA,
                        ADHOC,
                        STLAMOUNT TOTALEARNING,
                        'WPS' MODULE,
                        0 TOTALDEDUCTION,
                        STLAMOUNT NETSALARY,
                        OVERTIMEHOURS,
                        0 HOLIDAYHOURS,
                        A.WORKERSERIAL,
                        A.TOKENNO,
                        ESI_GROSS,
                        ESI_E,
                        ESI_C,
                        STLAMOUNT LEAVEENCASH,
                        '' REMARKS,
                        GROSS_WAGES
                 FROM   WPSSTLWAGESDETAILS A, WPSWORKERMAST B
                WHERE       A.COMPANYCODE = A.COMPANYCODE
                        AND A.DIVISIONCODE = B.DIVISIONCODE
                        AND A.WORKERSERIAL = B.WORKERSERIAL)
   --        WHERE TOKENNO='01508'
   --        AND YEARMONTH='202010'
   GROUP BY   COMPANYCODE,
              DIVISIONCODE,
              EMPLOYEECOMPANYCODE,
              EMPLOYEEDIVISIONCODE,
              PFNO,
              YEARCODE,
              YEARMONTH,
              FORTNIGHTSTARTDATE,
              FORTNIGHTENDDATE,
              MODULE,
              WORKERSERIAL,
              TOKENNO,
              REMARKS;

