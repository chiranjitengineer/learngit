DROP VIEW NJMCL_WEB.VW_WPSPAYSLIP_STL;

/* Formatted on 28/01/2021 1:17:32 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.VW_WPSPAYSLIP_STL
(
   SERIAL,
   SL,
   COMPANYCODE,
   DIVISIONCODE,
   COMPANYNAME,
   DIVISIONNAME,
   YEARCODE,
   DEPT,
   SRLNO,
   DEPARTMENTCODE,
   SECTIONCODE,
   DSGCD,
   OCCUPATIONNAME,
   WORKERCATEGORYCODE,
   WORKERCATEGORYNAME,
   SHIFTCODE,
   RECORDNO,
   PAYMENTDATE,
   WORKERSERIAL,
   WORKERNAME,
   SERIALNO,
   HRS_RATE,
   ATNHRS,
   OTHR,
   STLHOURS,
   STLPERIOD,
   DA,
   ADHOC,
   HRA,
   GRERNG,
   GRDEDN,
   PF,
   PF_GROSS,
   FPF,
   GROSS_PTAX,
   P_TAX,
   PENSION_GROSS,
   ESI_GROSS,
   CT,
   PBF,
   PCO,
   EBDESIG,
   ESINO,
   ESI,
   STLHOURS_ENCASH,
   STATUTORYHOURS,
   STLDAYS,
   NETPAY,
   UANNO
)
AS


     SELECT   ROW_NUMBER ()
                 OVER (ORDER BY A.DEPARTMENTCODE,
                                A.SHIFTCODE,
                                A.SECTIONCODE,
                                A.TOKENNO)
                 AS SERIAL,
              ROW_NUMBER ()
                 OVER (PARTITION BY A.DEPARTMENTCODE, A.SHIFTCODE
                       ORDER BY A.DEPARTMENTCODE,
                                A.SHIFTCODE,
                                A.SECTIONCODE,
                                A.TOKENNO)
                 AS SL,
              A.COMPANYCODE,
              A.DIVISIONCODE,
              CM.COMPANYNAME,
              DM.DIVISIONNAME,
              A.YEARCODE,
              '/' || A.DEPARTMENTCODE || '' || A.SECTIONCODE || ''
              || DECODE (A.SHIFTCODE,
                         '1', 'A',
                         'A', 'A',
                         '2', 'B',
                         'B', 'B',
                         '3', 'C',
                         'C', 'C',
                         'A')
                 DEPT,
              A.DEPTSERIAL SRLNO,
              A.DEPARTMENTCODE,
              A.SECTIONCODE,
              --A.OCCUPATIONCODE DSGCD,
              '' DSGCD,
              C.OCCUPATIONNAME,
              A.WORKERCATEGORYCODE,
              D.WORKERCATEGORYNAME,
              DECODE (A.SHIFTCODE,
                      '1', 'A',
                      'A', 'A',
                      '2', 'B',
                      'B', 'B',
                      '3', 'C',
                      'C', 'C',
                      'A')
                 AS SHIFTCODE,
              A.TOKENNO RECORDNO,
              PAYMENTDATE,
              A.WORKERSERIAL,
              B.WORKERNAME,
              SERIALNO,
              HRS_RATE,
              NVL (ATTENDANCEHOURS, 0) ATNHRS,
              NVL (OVERTIMEHOURS, 0) OTHR,
              STLHOURS,
              NVL (STLAMOUNT, 0) STLPERIOD,
              NVL (A.DA, 0) DA,
              NVL (ADHOC, 0) ADHOC,
              NVL (HRA, 0) HRA,
              NVL (GROSS_WAGES, 0) GRERNG,
              NVL (TOTAL_DEDN, 0) GRDEDN,
              NVL (PF_C, 0) PF,
              PF_GROSS,
              NVL (FPF, 0) FPF,
              GROSS_PTAX,
              NVL (P_TAX, 0) P_TAX,
              PENSION_GROSS,
              ESI_GROSS,
              NVL (A.WORKERCATEGORYCODE, 0) CT,
              NVL (COINBF, 0) PBF,
              NVL (COINCF, 0) PCO,
              NVL (B.PFNO, 0) EBDESIG,
              B.ESINO,
              --NVL (ESI_C, 0) ESI,
              NVL (ESI_E, 0) ESI,
              0 STLHOURS_ENCASH,
              STLHOURS AS STATUTORYHOURS,
              NVL (STLDAYS, 0) STLDAYS,
              NVL (GROSS_WAGES, 0) - NVL (TOTAL_DEDN, 0) NETPAY,
              UANNO
       FROM   WPSSTLWAGESDETAILS A,
              WPSWORKERMAST B,
              WPSOCCUPATIONMAST C,
              WPSWORKERCATEGORYMAST D,
              COMPANYMAST CM,
              DIVISIONMASTER DM
      WHERE       A.COMPANYCODE = B.COMPANYCODE(+)
              AND A.DIVISIONCODE = B.DIVISIONCODE(+)
              AND A.WORKERSERIAL = B.WORKERSERIAL(+)
              AND B.COMPANYCODE = C.COMPANYCODE(+)
              AND B.DIVISIONCODE = C.DIVISIONCODE(+)
              AND B.DEPARTMENTCODE = C.DEPARTMENTCODE(+)
              AND B.SECTIONCODE = C.SECTIONCODE(+)
              AND B.OCCUPATIONCODE = C.OCCUPATIONCODE(+)
              AND A.COMPANYCODE = D.COMPANYCODE(+)
              AND A.DIVISIONCODE = D.DIVISIONCODE(+)
              AND A.WORKERCATEGORYCODE = D.WORKERCATEGORYCODE(+)
              AND A.COMPANYCODE = CM.COMPANYCODE
              AND A.COMPANYCODE = DM.COMPANYCODE
              AND A.DIVISIONCODE = DM.DIVISIONCODE
              AND NVL (A.LEAVEENCASHMENT, 'N') <> 'Y'
   ORDER BY   A.DEPARTMENTCODE,
              A.SECTIONCODE,
              A.SHIFTCODE,
              A.TOKENNO;


