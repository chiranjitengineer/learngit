DROP VIEW NJMCL_WEB.VW_WPSOCCUPATIONMAST;

/* Formatted on 08/03/2021 6:33:02 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.VW_WPSOCCUPATIONMAST
(
   COMPANYCODE,
   DIVISIONCODE,
   DEPARTMENTCODE,
   SECTIONCODE,
   OCCUPATIONCODE,
   OCCUPATIONNAME,
   OCCUPATIONTYPE,
   WORKERTYPECODE,
   MACHINEMANDETORY,
   RATE,
   MAINSARDER,
   MAINSARDERVBRATE,
   PLWCALCULATIONBASEDON,
   ACTIVE,
   DEPTOCCPCODE,
   VB_PROCNAME,
   IB_PROCNAME,
   VB_PERCENTAGE,
   IB_PERCENTAGE,
   VB_DEPENDENT_DEPTOCCPCODE,
   IB_DEPENDENT_DEPTOCCPCODE,
   VBRATE,
   IBCALCULATIONINDEX,
   STANDARDHANDSHIFT1,
   STANDARDHANDSHIFT2,
   STANDARDHANDSHIFT3,
   DEFAULTOCCUPATION,
   FITMENTRATE,
   LINENOAPPLICABLE,
   ADDL_RATE,
   DEPTGROUP,
   EXTRA_RATE,
   FBK_RATE,
   PFLINK_RATE
)
AS
   SELECT   "COMPANYCODE",
            "DIVISIONCODE",
            "DEPARTMENTCODE",
            "SECTIONCODE",
            "OCCUPATIONCODE",
            "OCCUPATIONNAME",
            "OCCUPATIONTYPE",
            "WORKERTYPECODE",
            "MACHINEMANDETORY",
            "RATE",
            "MAINSARDER",
            "MAINSARDERVBRATE",
            "PLWCALCULATIONBASEDON",
            "ACTIVE",
            "DEPTOCCPCODE",
            "VB_PROCNAME",
            "IB_PROCNAME",
            "VB_PERCENTAGE",
            "IB_PERCENTAGE",
            "VB_DEPENDENT_DEPTOCCPCODE",
            "IB_DEPENDENT_DEPTOCCPCODE",
            "VBRATE",
            "IBCALCULATIONINDEX",
            "STANDARDHANDSHIFT1",
            "STANDARDHANDSHIFT2",
            "STANDARDHANDSHIFT3",
            "DEFAULTOCCUPATION",
            "FITMENTRATE",
            "LINENOAPPLICABLE",
            "ADDL_RATE",
            "DEPTGROUP",
            "EXTRA_RATE",
            "FBK_RATE",
            "PFLINK_RATE"
     FROM   VIEWTAB_WPSOCCUPATIONMAST;


DROP VIEW NJMCL_WEB.VW_WPSPAYSLIP;

/* Formatted on 08/03/2021 6:33:02 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.VW_WPSPAYSLIP
(
   SERIAL,
   SL,
   COMPANYCODE,
   DIVISIONCODE,
   COMPANYNAME,
   DIVISIONNAME,
   YEARCODE,
   FORTNIGHTSTARTDATE,
   FORTNIGHTENDDATE,
   DEPT,
   SRLNO,
   DEPARTMENTCODE,
   SECTIONCODE,
   DSGCD,
   OCCUPATIONNAME,
   WORKERTYPECODE,
   WORKERCATEGORYCODE,
   WORKERCATEGORYNAME,
   SHIFTCODE,
   RECORDNO,
   WORKERSERIAL,
   WORKERNAME,
   UNITCODE,
   SERIALNO,
   PAYMODE,
   HRS_RATE,
   ATNHRS,
   ATNDAY,
   OTHR,
   HOLHR,
   STLHOURS,
   NSHR,
   OTHERHOURS,
   BASIC,
   DA,
   ADHOC,
   HOLWG,
   OT_AMOUNT,
   ADJERNG,
   ADJDEDN,
   NPF_ADJ,
   OEPF,
   GROSS_FOR_HRA,
   HRA,
   GRERNG,
   PF_GROSS,
   PF,
   FPF,
   GROSS_PTAX,
   P_TAX,
   PENSION_GROSS,
   ESI_GROSS,
   ESI,
   GR_FOR_BONUS,
   TOT_EARN,
   LOWAGES,
   LOC,
   LWF,
   VPF,
   FBWG,
   FBWG1,
   CT,
   GRD,
   INST,
   SE,
   STLPERIOD,
   PBF,
   PCO,
   GRDEDN,
   INCENTIVE,
   WF_DEDN_C,
   GR_BONUS_TODATE,
   FBHR,
   LAYOFF,
   FIXER,
   NSA,
   YTDDAYS,
   HRENT,
   LOAN_DEDN,
   PF_LN_RCV,
   PL_INT_RCV,
   PL_INT_BAL,
   PF_LN_BAL,
   OENPF,
   EBDESIG,
   ESINO,
   STLHOURS_ENCASH,
   STATUTORYHOURS,
   STLDAYS,
   STL_ENCASH,
   PF_OWN_YTD,
   CUM_PF_C,
   CUM_VPF,
   STL_AMT,
   STL_BAL,
   CUM_PFGROSS,
   TSA,
   TSA_HEAD,
   ATREWARD,
   ATREWARD_HEAD,
   ELECTRIC,
   ELECTRIC_HEAD,
   NETPAY,
   ACTUALPAYBLEAMOUNT,
   NETPAY_HEAD,
   GROUPCODE,
   GRATUITYYEARS,
   PFCATEGORY,
   ENC,
   GRATUITY,
   COMNAME,
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
              A.FORTNIGHTSTARTDATE,
              A.FORTNIGHTENDDATE,
              A.DEPARTMENTCODE || '' || A.SECTIONCODE || ''
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
              A.OCCUPATIONCODE DSGCD,
              C.OCCUPATIONNAME,
              A.WORKERTYPECODE,
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
              A.WORKERSERIAL,
              B.WORKERNAME,
              A.UNITCODE,
              SERIALNO,
              A.PAYMODE,
              HRS_RATE,
              NVL (ATTENDANCEHOURS, 0) ATNHRS,
              --            NVL (ATTENDANCEHOURS, 0) / 8 ATNDAY,
              NVL (ATN_DAYS, 0) ATNDAY,
              NVL (OVERTIMEHOURS, 0) OTHR,
              NVL (HOLIDAYHOURS, 0) HOLHR,
              STLHOURS,
              NVL (NIGHTALLOWANCEHOURS, 0) NSHR,
              OTHERHOURS,
              NVL (FBASIC, 0) + NVL (VBASIC, 0) + NVL (ADHOC, 0) BASIC,
              NVL (A.DA, 0) DA,
              NVL (ADHOC, 0) ADHOC,
              NVL (H_WAGES, 0) HOLWG,
              (NVL (OT_AMOUNT, 0) + NVL (NS_ALLOW_OT, 0)) OT_AMOUNT,
              NVL (PF_ADJ, 0) + NVL (NPF_ADJ, 0) + NVL (OEPF, 0) ADJERNG,
              NVL (PF_ADJ_DEDN, 0) + NVL (NPF_ADJ_DEDN, 0) + NVL (OEPF_DEDN, 0)
                 ADJDEDN,
              NPF_ADJ,
              OEPF,
              GROSS_FOR_HRA,
              NVL (HRA, 0) HRA,
              --NVL (GROSS_WAGES, 0) GRERNG,
              NVL (TOT_EARN, 0) GRERNG,
              PF_GROSS,
              --            NVL (PF_CONT, 0) PF_CONT,
              NVL (PF_COM, 0) PF,
              NVL (FPF, 0) FPF,
              GROSS_PTAX,
              NVL (P_TAX, 0) P_TAX,
              PENSION_GROSS,
              ESI_GROSS,
              NVL (ESI_CONT, 0) ESI,
              NVL (GR_BONUS_TODATE, 0) GR_FOR_BONUS,
              TOT_EARN,
              LOWAGES,
              CASE
                 WHEN LOWAGES > 0 THEN LOWAGES
                 ELSE NVL (LNBL_FADV, 0) + NVL (LNBL_GADV, 0)
              END
                 LOC,                                         --GADV FADV BADV
              NVL (WF_DEDN, 0) LWF,
              VPF,
              NVL (FBK_WAGES, 0) FBWG,
              --            CASE
              --               WHEN NVL (FBK_WAGES, 0) > 0 THEN NVL (FBK_WAGES, 0)
              --               ELSE NVL (ELECTRICITY, 0)
              --            END
              --               FBWG,
              CASE
                 WHEN NVL (FBK_WAGES, 0) > 0 THEN NVL (FBK_WAGES, 0)
                 ELSE NVL (ELECTRICITY, 0)
              END
                 FBWG1,
              NVL (A.WORKERCATEGORYCODE, 0) CT,
              0 GRD,
              0 INST,
              0 SE,
              NVL (TOTALPRODUCTION, 0) STLPERIOD,
              NVL (COINBF, 0) PBF,
              NVL (COINCF, 0) PCO,
              NVL (TOT_DEDUCTION, 0) GRDEDN,
              NVL (INCENTIVE, 0) INCENTIVE,
              WF_DEDN_C,
              GR_BONUS_TODATE,
              NVL (FBKHOURS, 0) FBHR,
              NVL (LAYOFFHOURS, 0) LAYOFF,
              NVL (FBASIC_PEICERT, 0) FIXER,
              NVL (NS_ALLOW, 0) NSA,
              NVL (CALENDARWORKINGDAYS, 0) YTDDAYS,
              NVL (HR_DEDN, 0) HRENT,
              (  NVL (LOAN_GADV, 0)
               + NVL (LOAN_COLN, 0)
               + NVL (LOAN_FADV, 0)
               + NVL (LOAN_UPHD, 0)
               + NVL (LOAN_BADV, 0))
                 LOAN_DEDN,
              NVL (LOAN_PFL, 0) + NVL (LOAN_MPL, 0) PF_LN_RCV,
              NVL (LINT_PFL, 0) + NVL (LINT_MPL, 0) PL_INT_RCV,
              --            CASE
              --               WHEN NVL (LNBL_PFL, 0) + NVL (LNBL_MPL, 0) > 0 THEN 0
              --               ELSE NVL (LIBL_PFL, 0) + NVL (LIBL_MPL, 0)
              --            END
              --               PL_INT_BAL,
              NVL (LIBL_PFL, 0) + NVL (LIBL_MPL, 0) PL_INT_BAL,
              NVL (LNBL_PFL, 0) + NVL (LNBL_MPL, 0) PF_LN_BAL,
              NVL (OENPF, 0)                --            + NVL (EXT_OENPF, 0)
                             -- + NVL (FIX_OENPF, 0)
              + NVL (ATN_INCENTIVE, 0)                 -- + NVL (PRD_OENPF, 0)
                                      OENPF,
              NVL (B.PFNO, 0) EBDESIG,
              --B.ESINO,
              SUBSTR (B.ESINO, -8) ESINO,
              -- STLHOURS_ENCASH,
              CASE WHEN STL_ENCASH > 0 THEN STLHOURS_ENCASH ELSE STLHOURS END
                 AS STLHOURS_ENCASH,
              STLHOURS AS STATUTORYHOURS,
              STLHOURS / 8 AS STLDAYS,
              STL_ENCASH,
              --CUM_PF_E PF_OWN_YTD,
              NVL (YTD_PF_E, 0) PF_OWN_YTD,
              CUM_PF_C,
              CUM_VPF,
              STL_AMT,
              STL_BAL,
              CUM_PFGROSS,
              NVL (TSA, 0) TSA,
              CASE WHEN TSA > 0 THEN 'TSA' ELSE '' END TSA_HEAD,
              ATN_INCENTIVE ATREWARD,
              '[AttendanceRewardAmount =>' ATREWARD_HEAD,
              ELECTRIC,
              --'ELE.DED' ELECTRIC_HEAD,
              CASE
                 WHEN NVL (FBK_WAGES, 0) > 0 THEN ''
                 WHEN NVL (ELECTRICITY, 0) > 0 THEN 'ELE.DED'
              END
                 ELECTRIC_HEAD,
              NVL (ACTUALPAYBLEAMOUNT, 0) NETPAY,
              ACTUALPAYBLEAMOUNT,
              CASE
                 WHEN NVL (ACTUALPAYBLEAMOUNT, 0) > 0
                 THEN
                    CASE
                       WHEN NVL (B.BANKACNO, '~') <> '~' THEN '<=BANK=>'
                       ELSE '<=CASH=>'
                    END
                 ELSE
                    ''
              END
                 NETPAY_HEAD,
              DECODE (A.GROUPCODE,
                      'B',
                      'A',
                      'R',
                      'B',
                      'G',
                      'C')
                 GROUPCODE,
              A.GRATUITYYEARS,
              CASE
                 WHEN (PFAPPLICABLE = 'Y' AND EPFAPPLICABLE = 'Y') THEN '1'
                 WHEN (PFAPPLICABLE = 'Y' AND EPFAPPLICABLE = 'N') THEN '2'
                 WHEN (PFAPPLICABLE = 'N' AND EPFAPPLICABLE = 'N') THEN '3'
              END
                 AS PFCATEGORY,
              CASE WHEN STL_ENCASH > 0 THEN '(ENC)' ELSE '' END AS ENC,
              'GRTY-YRS' AS GRATUITY,
              'NJMCL*' AS COMNAME,
              UANNO
       FROM   WPSWAGESDETAILS_MV A,
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
   --            AND FORTNIGHTSTARTDATE = TO_DATE ('01/11/2019', 'DD/MM/YYYY')
   --            AND FORTNIGHTENDDATE = TO_DATE ('15/11/2019', 'DD/MM/YYYY')
   ORDER BY   A.DEPARTMENTCODE,
              A.SECTIONCODE,
              A.SHIFTCODE,
              A.TOKENNO;


DROP VIEW NJMCL_WEB.VW_WPSPAYSLIP_BONUS;

/* Formatted on 08/03/2021 6:33:02 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.VW_WPSPAYSLIP_BONUS
(
   SERIAL,
   SL,
   COMPANYCODE,
   DIVISIONCODE,
   COMPANYNAME,
   DIVISIONNAME,
   YEARCODE,
   YEARMONTH,
   DEPT,
   SRLNO,
   DEPARTMENTCODE,
   SECTIONCODE,
   SHIFTCODE,
   DSGCD,
   OCCUPATIONNAME,
   WORKERCATEGORYCODE,
   WORKERCATEGORYNAME,
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
   TRANSACTIONTYPE,
   UANNO
)
AS
     SELECT   ROW_NUMBER ()
                 OVER (ORDER BY A.DEPARTMENTCODE,
                                A.SECTIONCODE,
                                A.SHIFTCODE,
                                A.TOKENNO)
                 AS SERIAL,
              ROW_NUMBER ()
                 OVER (PARTITION BY A.DEPARTMENTCODE, A.SHIFTCODE
                       ORDER BY A.DEPARTMENTCODE, A.SECTIONCODE, A.TOKENNO)
                 AS SL,
              A.COMPANYCODE,
              A.DIVISIONCODE,
              CM.COMPANYNAME,
              DM.DIVISIONNAME,
              A.YEARCODE,
              YEARMONTH,
              '/' || A.DEPARTMENTCODE || '' || '' || ''
              || DECODE (A.SHIFTCODE,
                         '1', 'A',
                         'A', 'A',
                         '2', 'B',
                         'B', 'B',
                         '3', 'C',
                         'C', 'C',
                         'A')
                 DEPT,
              '' SRLNO,
              A.DEPARTMENTCODE,
              A.SECTIONCODE,
              A.SHIFTCODE,
              '' DSGCD,
              C.OCCUPATIONNAME,
              CATEGORYCODE WORKERCATEGORYCODE,
              D.WORKERCATEGORYNAME,
              A.TOKENNO RECORDNO,
              PAYMENTDATE,
              A.WORKERSERIAL,
              B.WORKERNAME,
              0 SERIALNO,
              0 HRS_RATE,
              NVL (ATTENDANCEHOURS, 0) ATNHRS,
              0 OTHR,
              STLHOURS,
              0 STLPERIOD,
              0 DA,
              0 ADHOC,
              0 HRA,
              NVL (PAIDBONUSAMOUNT, 0) GRERNG,
              0 GRDEDN,
              0 PF,
              0 PF_GROSS,
              0 FPF,
              0 GROSS_PTAX,
              0 P_TAX,
              0 PENSION_GROSS,
              0 ESI_GROSS,
              0 CT,
              NVL (COINBF, 0) PBF,
              NVL (COINCF, 0) PCO,
              NVL (B.PFNO, 0) EBDESIG,
              B.ESINO,
              0 ESI,
              0 STLHOURS_ENCASH,
              0 AS STATUTORYHOURS,
              0 STLDAYS,
              NVL (PAIDBONUSAMOUNT, 0) NETPAY,
              TRANSACTIONTYPE,
              UANNO
       FROM   BONUSDETAILS A,
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
              AND A.CATEGORYCODE = D.WORKERCATEGORYCODE(+)
              AND A.COMPANYCODE = CM.COMPANYCODE
              AND A.COMPANYCODE = DM.COMPANYCODE
              AND A.DIVISIONCODE = DM.DIVISIONCODE
              AND A.TRANSACTIONTYPE = 'BONUS PAYMENT'
   ORDER BY   A.DEPARTMENTCODE, A.TOKENNO;


DROP VIEW NJMCL_WEB.VW_WPSPAYSLIP_STL;

/* Formatted on 08/03/2021 6:33:02 PM (QP5 v5.115.810.9015) */
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


DROP VIEW NJMCL_WEB.VW_WPSPISMASTER;

/* Formatted on 08/03/2021 6:33:02 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.VW_WPSPISMASTER
(
   WORKERTYPE,
   COMPANYCODE,
   DIVISIONCODE,
   WORKERSERIAL,
   WORKERCODE,
   WORKERNAME,
   FATHERNAME,
   DEPARTMENTCODE,
   DEPARTMENTNAME,
   CATEGORYCODE,
   CATEGORYNAME,
   GRADECODE,
   GRADEDESC,
   DATEOFBIRTH,
   DATEOFJOINING,
   ESIJOININGDATE,
   PFJOINIGDATE,
   ESINO,
   PFNO,
   PENSIONNO,
   DATEOFRETIREMENT,
   EMPLOYEEMARRIED,
   SEX,
   SPOUSENAME,
   EMPLOYEESTATUS,
   STATUSDATE,
   FORM3CEASEDATE,
   PFSETTELMENTDATE,
   ADDRESS,
   INACTIVE,
   FORM3RECEIPTDATE,
   PFCATEGORY,
   ADHARCARDNO,
   UANNO,
   BANKACNO,
   BANKCODE,
   BANKACCHOLDINGNAME
)
AS
   SELECT   'WPS' WORKERTYPE,
            A.COMPANYCODE,
            A.DIVISIONCODE,
            A.WORKERSERIAL,
            A.TOKENNO AS WORKERCODE,
            A.WORKERNAME,
            A.FATHERNAME,
            A.DEPARTMENTCODE,
            D.DEPARTMENTNAME,
            A.WORKERCATEGORYCODE AS CATEGORYCODE,
            B.WORKERCATEGORYNAME AS CATEGORYNAME,
            GRADECODE,
            ' ' GRADEDESC,
            A.DATEOFBIRTH DATEOFBIRTH,
            A.DATEOFJOINING,
            A.ESIJOININGDATE,
            A.PFMEMBERSHIPDATE AS PFJOINIGDATE,
            A.ESINO,
            A.PFNO,
            A.PENSIONNO,
            A.DATEOFRETIREMENT,
            CASE WHEN A.MARITALSTATUS = 'M' THEN 'Y' ELSE 'N' END
               EMPLOYEEMARRIED,
            A.SEX,
            A.WORKERSOUSENAME SPOUSENAME,
            WORKERSTATUS EMPLOYEESTATUS,
            DATEOFTERMINATION STATUSDATE,
            DATEOFTERMINATIONADVICE FORM3CEASEDATE,
            PFSETTELMENTDATE,
            ADDRESS1 || ADDRESS2 || ADDRESS3 || ADDRESS4 || ADDRESS5 ADDRESS,
            CASE
               WHEN PFSETTELMENTDATE IS NULL
                    AND NVL (TAKEPARTINWAGES, 'N') = 'N'
               THEN
                  'Y'
               ELSE
                  'N'
            END
               INACTIVE,
            DATEOFTERMINATIONADVICE AS FORM3RECEIPTDATE,
            PFCATEGORY AS PFCATEGORY,
            A.ADHARCARDNO,
            A.UANNO,
            A.BANKACNO,
            A.BANKCODE,
            A.WORKERNAME_BANK BANKACCHOLDINGNAME
     FROM   WPSWORKERMAST A, WPSWORKERCATEGORYMAST B, DEPARTMENTMASTER D
    WHERE       A.DivisionCode = B.DivisionCode
            AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE
            AND A.DivisionCode = D.DivisionCode
            AND A.DEPARTMENTCODE = D.DEPARTMENTCODE
   UNION ALL
   SELECT   'PIS' WORKERTYPE,
            A.COMPANYCODE,
            A.DIVISIONCODE,
            A.WORKERSERIAL,
            A.TOKENNO AS WORKERCODE,
            A.EMPLOYEENAME AS WORKERNAME,
            A.FATHERNAME FATHERNAME,
            A.DEPARTMENTCODE,
            D.DEPARTMENTDESC,
            A.CATEGORYCODE AS CATEGORYCODE,
            B.CATEGORYDESC AS CATEGORYNAME,
            A.GRADECODE,
            C.GRADEDESC AS GRADEDESC,
            A.DATEOFBIRTH DATEOFBIRTH,
            A.DATEOFJOIN AS DATEOFJOINING,
            NULL AS ESIJOININGDATE,
            A.PFENTITLEDATE AS PFJOINIGDATE,
            A.ESINO,
            A.PFNO,
            TO_CHAR (A.PENSIONNO) PENSIONNO,
            CASE
               WHEN A.EXTENDEDRETIREDATE IS NULL THEN A.DATEOFRETIRE
               ELSE A.EXTENDEDRETIREDATE
            END
               DATEOFRETIREMENT,
            A.MARITIALSTATUS AS MARRIED,
            A.SEX,
            A.SPOUSENAME SPOUSENAME,
            A.EMPLOYEESTATUS,
            A.STATUSDATE,
            A.STATUSDATE FORM3CEASEDATE,
            PFSETTELMENTDATE,
            A.ADDRESS_PERMANENT ADDRESS,
            CASE
               WHEN A.PFSETTELMENTDATE IS NULL
                    AND A.EMPLOYEESTATUS <> 'ACTIVE'
               THEN
                  'Y'
               ELSE
                  'N'
            END
               INACTIVE,
            STATUSDATE AS FORM3RECEIPTDATE,
            'N' AS PFCATEGORY,
            A.AADHARNO,
            A.UANNO,
            A.BANKACCNUMBER BANKACNO,
            A.BANKCODE,
            A.BANKACCHOLDINGNAME
     FROM   PISEMPLOYEEMASTER A,
            PISCATEGORYMASTER B,
            PISGRADEMASTER C,
            PISDEPARTMENTMASTER D
    WHERE       A.DIVISIONCODE = B.DIVISIONCODE
            AND A.CATEGORYCODE = B.CATEGORYCODE
            AND A.DIVISIONCODE = C.DIVISIONCODE
            AND A.CATEGORYCODE = C.CATEGORYCODE
            AND A.GRADECODE = C.GRADECODE
            AND A.DIVISIONCODE = D.DIVISIONCODE
            AND A.DEPARTMENTCODE = D.DEPARTMENTCODE;


DROP VIEW NJMCL_WEB.VW_WPSSECTIONMAST;

/* Formatted on 08/03/2021 6:33:02 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.VW_WPSSECTIONMAST
(
   COMPANYCODE,
   DIVISIONCODE,
   DEPARTMENTCODE,
   SECTIONCODE,
   SECTIONNAME,
   GRADERATE,
   INCREMENTRATE,
   LISTINDEX,
   ATTN_GRID_TAG,
   VB_PROCNAME,
   IB_PROCNAME,
   WORKTYPECODE,
   VB_PERCENTAGE,
   IB_PERCENTAGE,
   DEPENDANTSECTIONCODE,
   DEFAULTSECTION,
   DEPTSECTIONCODE,
   APPLICABLE_ATN_INCT,
   FBK_RATE,
   MACHINEAPPLICABLE,
   NIGHTSHIFTATTENDANCEHOURS,
   NONPFLINKHOURS,
   NSAAPPLICABLEINOT,
   NSAPPLICABLE,
   PFLINKHOURS
)
AS
   SELECT   "COMPANYCODE",
            "DIVISIONCODE",
            "DEPARTMENTCODE",
            "SECTIONCODE",
            "SECTIONNAME",
            "GRADERATE",
            "INCREMENTRATE",
            "LISTINDEX",
            "ATTN_GRID_TAG",
            "VB_PROCNAME",
            "IB_PROCNAME",
            "WORKTYPECODE",
            "VB_PERCENTAGE",
            "IB_PERCENTAGE",
            "DEPENDANTSECTIONCODE",
            "DEFAULTSECTION",
            "DEPTSECTIONCODE",
            "APPLICABLE_ATN_INCT",
            "FBK_RATE",
            "MACHINEAPPLICABLE",
            "NIGHTSHIFTATTENDANCEHOURS",
            "NONPFLINKHOURS",
            "NSAAPPLICABLEINOT",
            "NSAPPLICABLE",
            "PFLINKHOURS"
     FROM   VIEWTAB_WPSSECTIONMAST;


DROP VIEW NJMCL_WEB.VW_WPSSTLWAGESDTLS_DEPSECWISE;

/* Formatted on 08/03/2021 6:33:02 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.VW_WPSSTLWAGESDTLS_DEPSECWISE
(
   COMPANYCODE,
   DIVISIONCODE,
   YEARCODE,
   PAYMENTDATE,
   DEPARTMENTCODE,
   SECTIONCODE,
   WORKERSERIAL,
   TOKENNO,
   STLAMOUNT
)
AS
     SELECT   COMPANYCODE,
              DIVISIONCODE,
              YEARCODE,
              PAYMENTDATE,
              DEPARTMENTCODE,
              SECTIONCODE,
              WORKERSERIAL,
              TOKENNO,
              SUM (NVL (STLAMOUNT, 0)) STLAMOUNT
       FROM   WPSSTLWAGESDETAILS
   GROUP BY   COMPANYCODE,
              DIVISIONCODE,
              YEARCODE,
              PAYMENTDATE,
              DEPARTMENTCODE,
              SECTIONCODE,
              WORKERSERIAL,
              TOKENNO;


DROP VIEW NJMCL_WEB.VW_WPS_VOUCHERTOTAL;

/* Formatted on 08/03/2021 6:33:02 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.VW_WPS_VOUCHERTOTAL
(
   COMPANYCODE,
   DIVISIONCODE,
   YEARCODE,
   FORTNIGHTSTARTDATE,
   FORTNIGHTENDDATE,
   HRS_RATE,
   ATTENDANCEHOURS,
   OVERTIMEHOURS,
   HOLIDAYHOURS,
   STLHOURS,
   NIGHTALLOWANCEHOURS,
   LAYOFFHOURS,
   FBKHOURS,
   OTHERHOURS,
   PFADJHOURS,
   NPFADJHOURS,
   ACTUALPAYBLEAMOUNT,
   VBASIC,
   FBASIC,
   DA,
   ADHOC,
   NS_ALLOW,
   H_WAGES,
   STL_AMT,
   LOWAGES,
   OT_AMOUNT,
   NPF_ADJ,
   PF_ADJ,
   GROSS_FOR_HRA,
   HRA,
   GROSS_WAGES,
   PF_GROSS,
   PF_CONT,
   FPF,
   PF_COM,
   GROSS_PTAX,
   P_TAX,
   PENSION_GROSS,
   ESI_GROSS,
   ESI_CONT,
   GR_FOR_BONUS,
   TOT_EARN,
   WF_DEDN,
   COINBF,
   COINCF,
   TOT_DEDUCTION,
   INCENTIVE,
   WF_DEDN_C,
   ESI_COMP_CONT,
   BONDAYS_TODATE,
   GR_BONUS_TODATE,
   NPF_ADJ_DEDN,
   STL_ENCASH,
   CALENDARWORKINGDAYS,
   LOW_RATE,
   STL_ADV,
   ELECTRIC,
   HR_DEDN,
   LOAN_PFL,
   LINT_PFL,
   LNBL_PFL,
   LIBL_PFL,
   ATN_INCENTIVE,
   FBASIC_PEICERT,
   FBASIC_RT,
   FBASIC_PEICERT_RT,
   DA_RT,
   ADHOC_RT,
   ATN_INCENTIVE_RT,
   OENPF,
   STLHOURS_ENCASH,
   CUM_PFGROSS,
   CUM_PF_E,
   CUM_PF_C,
   STL_BAL,
   OEPF,
   GRATUITYYEARS,
   TSA,
   NS_RT,
   OEPF_DEDN,
   TSA_RT,
   NS_RT_RT,
   NS_ALLOW_OT,
   FBK_WAGES,
   OT_NSHRS,
   FEWORKINGDAYS,
   ATN_DAYS,
   DAILY_WAGES,
   CALENDARWORKINGHRS,
   GROUPCODE,
   VPF,
   LOAN_COLN,
   LINT_COLN,
   LNBL_COLN,
   LIBL_COLN,
   LOAN_GADV,
   LINT_GADV,
   LNBL_GADV,
   LIBL_GADV,
   LOAN_FADV,
   LINT_FADV,
   LNBL_FADV,
   LIBL_FADV,
   LOAN_UPHD,
   LINT_UPHD,
   LNBL_UPHD,
   LIBL_UPHD,
   MNTH_PF_GROSS,
   MNTH_PTAX_GROSS,
   MNTH_ESI_GROSS,
   YTD_PF_E,
   YTD_FPF,
   YTD_PF_C
)
AS
     SELECT   COMPANYCODE,
              DIVISIONCODE,
              YEARCODE,
              FORTNIGHTSTARTDATE,
              FORTNIGHTENDDATE,
              AVG (HRS_RATE) HRS_RATE,
              SUM (ATTENDANCEHOURS) ATTENDANCEHOURS,
              SUM (OVERTIMEHOURS) OVERTIMEHOURS,
              SUM (HOLIDAYHOURS) HOLIDAYHOURS,
              SUM (STLHOURS) STLHOURS,
              SUM (NIGHTALLOWANCEHOURS) NIGHTALLOWANCEHOURS,
              SUM (LAYOFFHOURS) LAYOFFHOURS,
              SUM (FBKHOURS) FBKHOURS,
              SUM (OTHERHOURS) OTHERHOURS,
              SUM (PFADJHOURS) PFADJHOURS,
              SUM (NPFADJHOURS) NPFADJHOURS,
              SUM (ACTUALPAYBLEAMOUNT) ACTUALPAYBLEAMOUNT,
              SUM (VBASIC) VBASIC,
              SUM (FBASIC) FBASIC,
              SUM (DA) DA,
              SUM (ADHOC) ADHOC,
              SUM (NS_ALLOW) NS_ALLOW,
              SUM (H_WAGES) H_WAGES,
              SUM (STL_AMT) STL_AMT,
              SUM (LOWAGES) LOWAGES,
              SUM (OT_AMOUNT) OT_AMOUNT,
              SUM (NPF_ADJ) NPF_ADJ,
              SUM (PF_ADJ) PF_ADJ,
              SUM (GROSS_FOR_HRA) GROSS_FOR_HRA,
              SUM (HRA) HRA,
              SUM (GROSS_WAGES) GROSS_WAGES,
              SUM (PF_GROSS) PF_GROSS,
              SUM (PF_CONT) PF_CONT,
              SUM (FPF) FPF,
              SUM (PF_COM) PF_COM,
              SUM (GROSS_PTAX) GROSS_PTAX,
              SUM (P_TAX) P_TAX,
              SUM (PENSION_GROSS) PENSION_GROSS,
              SUM (ESI_GROSS) ESI_GROSS,
              SUM (ESI_CONT) ESI_CONT,
              SUM (GR_FOR_BONUS) GR_FOR_BONUS,
              SUM (TOT_EARN) TOT_EARN,
              SUM (WF_DEDN) WF_DEDN,
              SUM (COINBF) COINBF,
              SUM (COINCF) COINCF,
              SUM (TOT_DEDUCTION) TOT_DEDUCTION,
              SUM (INCENTIVE) INCENTIVE,
              SUM (WF_DEDN_C) WF_DEDN_C,
              SUM (ESI_COMP_CONT) ESI_COMP_CONT,
              SUM (BONDAYS_TODATE) BONDAYS_TODATE,
              SUM (GR_BONUS_TODATE) GR_BONUS_TODATE,
              SUM (NPF_ADJ_DEDN) NPF_ADJ_DEDN,
              SUM (STL_ENCASH) STL_ENCASH,
              SUM (CALENDARWORKINGDAYS) CALENDARWORKINGDAYS,
              SUM (LOW_RATE) LOW_RATE,
              SUM (STL_ADV) STL_ADV,
              SUM (ELECTRIC) ELECTRIC,
              SUM (HR_DEDN) HR_DEDN,
              SUM (LOAN_PFL) LOAN_PFL,
              SUM (LINT_PFL) LINT_PFL,
              SUM (LNBL_PFL) LNBL_PFL,
              SUM (LIBL_PFL) LIBL_PFL,
              SUM (ATN_INCENTIVE) ATN_INCENTIVE,
              AVG (FBASIC_PEICERT) FBASIC_PEICERT,
              AVG (FBASIC_RT) FBASIC_RT,
              AVG (FBASIC_PEICERT_RT) FBASIC_PEICERT_RT,
              AVG (DA_RT) DA_RT,
              SUM (ADHOC_RT) ADHOC_RT,
              SUM (ATN_INCENTIVE_RT) ATN_INCENTIVE_RT,
              SUM (OENPF) OENPF,
              SUM (STLHOURS_ENCASH) STLHOURS_ENCASH,
              SUM (CUM_PFGROSS) CUM_PFGROSS,
              SUM (CUM_PF_E) CUM_PF_E,
              SUM (CUM_PF_C) CUM_PF_C,
              SUM (STL_BAL) STL_BAL,
              SUM (OEPF) OEPF,
              SUM (GRATUITYYEARS) GRATUITYYEARS,
              SUM (TSA) TSA,
              SUM (NS_RT) NS_RT,
              SUM (OEPF_DEDN) OEPF_DEDN,
              SUM (TSA_RT) TSA_RT,
              SUM (NS_RT_RT) NS_RT_RT,
              SUM (NS_ALLOW_OT) NS_ALLOW_OT,
              SUM (FBK_WAGES) FBK_WAGES,
              SUM (OT_NSHRS) OT_NSHRS,
              SUM (FEWORKINGDAYS) FEWORKINGDAYS,
              SUM (ATN_DAYS) ATN_DAYS,
              SUM (DAILY_WAGES) DAILY_WAGES,
              SUM (CALENDARWORKINGHRS) CALENDARWORKINGHRS,
              SUM (GROUPCODE) GROUPCODE,
              SUM (VPF) VPF,
              SUM (LOAN_COLN) LOAN_COLN,
              SUM (LINT_COLN) LINT_COLN,
              SUM (LNBL_COLN) LNBL_COLN,
              SUM (LIBL_COLN) LIBL_COLN,
              SUM (LOAN_GADV) LOAN_GADV,
              SUM (LINT_GADV) LINT_GADV,
              SUM (LNBL_GADV) LNBL_GADV,
              SUM (LIBL_GADV) LIBL_GADV,
              SUM (LOAN_FADV) LOAN_FADV,
              SUM (LINT_FADV) LINT_FADV,
              SUM (LNBL_FADV) LNBL_FADV,
              SUM (LIBL_FADV) LIBL_FADV,
              SUM (LOAN_UPHD) LOAN_UPHD,
              SUM (LINT_UPHD) LINT_UPHD,
              SUM (LNBL_UPHD) LNBL_UPHD,
              SUM (LIBL_UPHD) LIBL_UPHD,
              SUM (MNTH_PF_GROSS) MNTH_PF_GROSS,
              SUM (MNTH_PTAX_GROSS) MNTH_PTAX_GROSS,
              SUM (MNTH_ESI_GROSS) MNTH_ESI_GROSS,
              SUM (YTD_PF_E) YTD_PF_E,
              SUM (YTD_FPF) YTD_FPF,
              SUM (YTD_PF_C) YTD_PF_C
       FROM   WPSVOUCHERDETAILS
   GROUP BY   COMPANYCODE,
              DIVISIONCODE,
              YEARCODE,
              FORTNIGHTSTARTDATE,
              FORTNIGHTENDDATE;


DROP VIEW NJMCL_WEB.WPSATTNTABDATE_VW;

/* Formatted on 08/03/2021 6:33:02 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.WPSATTNTABDATE_VW
(
   COMPANYCODE,
   DIVISIONCODE,
   DATEOFATTENDANCE,
   DEPARTMENTCODE,
   SECTIONCODE,
   SHIFTCODE,
   GROUPCODE,
   TOKENNO,
   OCCUPATIONCODE,
   MACHINECODE1,
   MACHINECODE2,
   SARDERNO,
   HELPERNO,
   SPELL1,
   SPELL2,
   ATTENDANCEHOURS,
   OVERTIMEHOURS,
   ADJHRS,
   OTHNPF,
   EXTHRS
)
AS
     SELECT   A.COMPANYCODE,
              A.DIVISIONCODE,
              A.DATEOFATTENDANCE,
              D.DEPARTMENTCODE,
              A.SECTIONCODE,
              SHIFTCODE,
              A.GROUPCODE,
              A.TOKENNO,                                    /*A.WORKERNAME, */
              A.OCCUPATIONCODE,
              A.MACHINECODE MACHINECODE1,
              NULL AS MACHINECODE2,
              MAX (A.SARDERNO) SARDERNO,
              NULL AS HELPERNO,
              SUM (SPELL1) SPELL1,
              SUM (SPELL2) SPELL2,
              SUM (NVL (A.ATTENDANCEHOURS, 0)) ATTENDANCEHOURS,
              SUM (NVL (A.OVERTIMEHOURS, 0)) OVERTIMEHOURS,
              0 ADJHRS,
              SUM (NVL (OTHNPF, 0)) OTHNPF,
              SUM (NVL (EXTHRS, 0)) EXTHRS
       FROM   (SELECT   COMPANYCODE,
                        DIVISIONCODE,
                        ATTNDATE DATEOFATTENDANCE,
                        SECTION AS SECTIONCODE,
                        CASE
                           WHEN SHIFT IN ('A1', 'A2') THEN '1'
                           WHEN SHIFT IN ('B1', 'B2') THEN '2'
                           ELSE '3'
                        END
                           SHIFTCODE,
                        PSHIFT GROUPCODE,
                        LBNO TOKENNO,
                        LBNAME WORKERNAME,
                        OCCCD AS OCCUPATIONCODE,
                        MCCD AS MACHINECODE,
                        NULL AS MACHINECODE2,
                        SARDERNO,
                        NULL AS HELPERNO,
                        CASE
                           WHEN SHIFT IN ('A1', 'B1', 'C')
                           THEN
                              NVL (WRKHRS, 0) - NVL (ADJHRS, 0)
                           ELSE
                              0
                        END
                           SPELL1,
                        CASE
                           WHEN SHIFT IN ('A2', 'B2')
                           THEN
                              NVL (WRKHRS, 0) - NVL (ADJHRS, 0)
                           ELSE
                              0
                        END
                           SPELL2,
                        NVL (WRKHRS, 0) - NVL (ADJHRS, 0) ATTENDANCEHOURS,
                        CASE
                           WHEN NVL (OTHRS, 0) > 0
                           THEN
                              NVL (OTHRS, 0) - NVL (ADJHRS, 0)
                           ELSE
                              NVL (OTHRS, 0)
                        END
                           OVERTIMEHOURS,
                        0 ADJHRS,
                        NVL (OTHNPF, 0) OTHNPF,
                        NVL (EXTRAHRS, 0) EXTHRS
                 FROM   WPSATTENDANCETABRAWDATA
                WHERE       COMPANYCODE = '0001'
                        AND DIVISIONCODE = '0002'
                        AND ATTNDATE = TO_DATE ('31/12/2019', 'DD/MM/YYYY')
                        AND SECTION = '0504') A,
              WPSSECTIONMAST D
      WHERE       A.COMPANYCODE = D.COMPANYCODE
              AND A.DIVISIONCODE = D.DIVISIONCODE
              AND A.SECTIONCODE = D.SECTIONCODE
   GROUP BY   A.COMPANYCODE,
              A.DIVISIONCODE,
              A.DATEOFATTENDANCE,
              D.DEPARTMENTCODE,
              A.SECTIONCODE,
              A.SHIFTCODE,
              A.GROUPCODE,
              A.TOKENNO,                                    /*A.WORKERNAME, */
              A.OCCUPATIONCODE,
              A.MACHINECODE                                    --, A.SARDERNO;


DROP VIEW NJMCL_WEB.WPSDEPARTMENTMASTER;

/* Formatted on 08/03/2021 6:33:03 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.WPSDEPARTMENTMASTER
(
   COMPANYCODE,
   DIVISIONCODE,
   DEPARTMENTCODE,
   DEPARTMENTNAME,
   DEPARTMENTTYPE,
   NSAAPPLICABLE,
   ISMACHINEDEPENDENT,
   PRINTABLEDEPARTMENTCODE,
   DEPTGROUPCODE,
   FIXEDHANDS,
   USERNAME,
   LASTMODIFIED,
   SYSROWID
)
AS
   SELECT   "COMPANYCODE",
            "DIVISIONCODE",
            "DEPARTMENTCODE",
            "DEPARTMENTNAME",
            "DEPARTMENTTYPE",
            "NSAAPPLICABLE",
            "ISMACHINEDEPENDENT",
            "PRINTABLEDEPARTMENTCODE",
            "DEPTGROUPCODE",
            "FIXEDHANDS",
            "USERNAME",
            "LASTMODIFIED",
            "SYSROWID"
     FROM   DEPARTMENTMASTER;


DROP VIEW NJMCL_WEB.WPSGROUPCODE;

/* Formatted on 08/03/2021 6:33:03 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.WPSGROUPCODE (GROUPCODE)
AS
   SELECT   '1' AS GROUPCODE FROM DUAL
   UNION ALL
   SELECT   '2' AS GROUPCODE FROM DUAL
   UNION ALL
   SELECT   '3' AS GROUPCODE FROM DUAL;


DROP VIEW NJMCL_WEB.WPSMACHINEMASTER;

/* Formatted on 08/03/2021 6:33:03 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.WPSMACHINEMASTER
(
   COMPANYCODE,
   DIVISIONCODE,
   PRODUCTIONTYPE,
   DEPARTMENTCODE,
   MACHINECODE,
   MACHINENAME,
   LOOMYESNO,
   PARTNERLOOMCODE,
   PAIRLOOMCODE,
   MACHINETYPECODE,
   MACHINEGROUP,
   ACTUALRPM,
   MACHINEREEDSPACE,
   MAXWIDTH,
   DIVISIONFACTOR,
   MODULE,
   LASTMODIFIED,
   SYSROWID,
   USERNAME,
   PIC_A,
   PIC_B,
   PIC_C
)
AS
   SELECT   "COMPANYCODE",
            "DIVISIONCODE",
            "PRODUCTIONTYPE",
            "DEPARTMENTCODE",
            "MACHINECODE",
            "MACHINENAME",
            "LOOMYESNO",
            "PARTNERLOOMCODE",
            "PAIRLOOMCODE",
            "MACHINETYPECODE",
            "MACHINEGROUP",
            "ACTUALRPM",
            "MACHINEREEDSPACE",
            "MAXWIDTH",
            "DIVISIONFACTOR",
            "MODULE",
            "LASTMODIFIED",
            "SYSROWID",
            "USERNAME",
            "PIC_A",
            "PIC_B",
            "PIC_C"
     FROM   MACHINEMASTER;


DROP VIEW NJMCL_WEB.WPSQUALITYMASTER;

/* Formatted on 08/03/2021 6:33:03 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.WPSQUALITYMASTER
(
   COMPANYCODE,
   DIVISIONCODE,
   PRODUCTIONTYPE,
   QUALITYCODE,
   QUALITYNAME,
   QUALITYTYPECODE,
   QUALITYUOMCODE,
   QUALITYUOMCODE2,
   QUALITYUOMDESC,
   QUALITYUOMDESC2,
   CONVERSIONFACTOR,
   FINISHTYPE,
   PORTER,
   SHOTS,
   ACTUALSHOTS,
   SHORTNAME,
   OZ,
   BASEOZ,
   OZTYPE,
   WIDTH,
   FINISHEDLENGTH,
   LAIDLENGTH,
   SPEED,
   CHATTAK,
   YARDPRECUT,
   SELVEDGE,
   WARPMARK,
   WARPGRIST,
   WEFTMARK,
   WEFTGRIST,
   WEIGHTSPECIFICATION,
   TARGETPRODUCTION,
   TARGETEFFICIENCYPERCENT,
   ISTIMERATEQUALITY,
   GSM,
   MAXWIDTH,
   ACTPICMETER,
   LASTMODIFIED,
   USERNAME,
   SYSROWID,
   MODULE
)
AS
   SELECT   "COMPANYCODE",
            "DIVISIONCODE",
            "PRODUCTIONTYPE",
            "QUALITYCODE",
            "QUALITYNAME",
            "QUALITYTYPECODE",
            "QUALITYUOMCODE",
            "QUALITYUOMCODE2",
            "QUALITYUOMDESC",
            "QUALITYUOMDESC2",
            "CONVERSIONFACTOR",
            "FINISHTYPE",
            "PORTER",
            "SHOTS",
            "ACTUALSHOTS",
            "SHORTNAME",
            "OZ",
            "BASEOZ",
            "OZTYPE",
            "WIDTH",
            "FINISHEDLENGTH",
            "LAIDLENGTH",
            "SPEED",
            "CHATTAK",
            "YARDPRECUT",
            "SELVEDGE",
            "WARPMARK",
            "WARPGRIST",
            "WEFTMARK",
            "WEFTGRIST",
            "WEIGHTSPECIFICATION",
            "TARGETPRODUCTION",
            "TARGETEFFICIENCYPERCENT",
            "ISTIMERATEQUALITY",
            "GSM",
            "MAXWIDTH",
            "ACTPICMETER",
            "LASTMODIFIED",
            "USERNAME",
            "SYSROWID",
            "MODULE"
     FROM   QUALITYMASTER
    WHERE   MODULE LIKE '%WPS%';


DROP VIEW NJMCL_WEB.WPSQUALITYUOMMAST;

/* Formatted on 08/03/2021 6:33:03 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.WPSQUALITYUOMMAST
(
   COMPANYCODE,
   DIVISIONCODE,
   QUALITYUOMCODE,
   QUALITYUOMDESC,
   LASTMODIFIED
)
AS
   SELECT   COMPANYCODE,
            DIVISIONCODE,
            UOMDESC QUALITYUOMCODE,
            UOMLONGDESC QUALITYUOMDESC,
            LASTMODIFIED
     FROM   STORESUOMMASTER;


DROP VIEW NJMCL_WEB.WPSQUARTERSTATUS;

/* Formatted on 08/03/2021 6:33:03 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.WPSQUARTERSTATUS (QUARTERSTATUS)
AS
   SELECT   'VACANT' AS QUARTERSTATUS FROM DUAL
   UNION ALL
   SELECT   'ALLOCATED' AS QUARTERSTATUS FROM DUAL
   UNION ALL
   SELECT   'UNDER CONSTRUCTION' AS QUARTERSTATUS FROM DUAL;


DROP VIEW NJMCL_WEB.WPSQUARTERTYPE;

/* Formatted on 08/03/2021 6:33:03 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.WPSQUARTERTYPE (QUARTERTYPE)
AS
   SELECT   'STAFF' AS QUARTERTYPE FROM DUAL
   UNION ALL
   SELECT   'LINE' AS QUARTERTYPE FROM DUAL
   UNION ALL
   SELECT   'SHOP' AS QUARTERTYPE FROM DUAL
   UNION ALL
   SELECT   'UNION OFFICE' AS QUARTERTYPE FROM DUAL;


DROP VIEW NJMCL_WEB.WPSREPORTTYPE;

/* Formatted on 08/03/2021 6:33:03 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.WPSREPORTTYPE
(
   SLNO,
   REPORTTYPE,
   REPORTTAG
)
AS
   SELECT   1 AS SLNO, 'Details' AS REPORTTYPE, 'ED STATEMENT NJML' REPORTTAG
     FROM   DUAL
   UNION ALL
   SELECT   2 AS SLNO, 'Summary' AS REPORTTYPE, 'ED STATEMENT NJML' REPORTTAG
     FROM   DUAL;


DROP VIEW NJMCL_WEB.WPSWAGESDETAILS_VW;

/* Formatted on 08/03/2021 6:33:03 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.WPSWAGESDETAILS_VW
(
   WORKERTYPE,
   COMPANYCODE,
   DIVISIONCODE,
   YEARCODE,
   FORTNIGHTSTARTDATE,
   FORTNIGHTENDDATE,
   DEPARTMENTCODE,
   SECTIONCODE,
   OCCUPATIONCODE,
   WORKERTYPECODE,
   WORKERCATEGORYCODE,
   SHIFTCODE,
   WORKERSERIAL,
   TOKENNO,
   UNITCODE,
   SERIALNO,
   PAYMODE,
   HRS_RATE,
   ATTENDANCEHOURS,
   OVERTIMEHOURS,
   HOLIDAYHOURS,
   STLHOURS,
   NIGHTALLOWANCEHOURS,
   LAYOFFHOURS,
   FBKHOURS,
   OTHERHOURS,
   PFADJHOURS,
   NPFADJHOURS,
   ACTUALPAYBLEAMOUNT,
   VBASIC,
   FBASIC,
   DA,
   ADHOC,
   NS_ALLOW,
   H_WAGES,
   STL_AMT,
   LOWAGES,
   OT_AMOUNT,
   NPF_ADJ,
   PF_ADJ,
   GROSS_FOR_HRA,
   HRA,
   GROSS_WAGES,
   PF_GROSS,
   PF_CONT,
   FPF,
   PF_COM,
   GROSS_PTAX,
   P_TAX,
   PENSION_GROSS,
   ESI_GROSS,
   ESI_CONT,
   GR_FOR_BONUS,
   TOT_EARN,
   WF_DEDN,
   COINBF,
   COINCF,
   TOT_DEDUCTION,
   LASTMODIFIED,
   USERNAME,
   SYSROWID,
   INCENTIVE,
   WF_DEDN_C,
   ESI_COMP_CONT,
   BONDAYS_TODATE,
   GR_BONUS_TODATE,
   NPF_ADJ_DEDN,
   STL_ENCASH,
   CALENDARWORKINGDAYS,
   LOW_RATE,
   STL_ADV,
   ELECTRIC,
   HR_DEDN,
   LOAN_PFL,
   LINT_PFL,
   LNBL_PFL,
   LIBL_PFL,
   ATN_INCENTIVE,
   FBASIC_PEICERT,
   FBASIC_RT,
   FBASIC_PEICERT_RT,
   DA_RT,
   ADHOC_RT,
   ATN_INCENTIVE_RT,
   OENPF,
   STLHOURS_ENCASH,
   CUM_PFGROSS,
   CUM_PF_E,
   CUM_PF_C,
   STL_BAL,
   OEPF,
   GRATUITYYEARS,
   TSA,
   NS_RT,
   OEPF_DEDN,
   TSA_RT,
   NS_RT_RT,
   DEPTSERIAL,
   NS_ALLOW_OT,
   FBK_WAGES,
   OT_NSHRS,
   FEWORKINGDAYS,
   ATN_DAYS,
   DAILY_WAGES,
   GRADECODE,
   CALENDARWORKINGHRS,
   GROUPCODE,
   VPF,
   LOAN_COLN,
   LINT_COLN,
   LNBL_COLN,
   LIBL_COLN,
   LOAN_GADV,
   LINT_GADV,
   LNBL_GADV,
   LIBL_GADV,
   LOAN_FADV,
   LINT_FADV,
   LNBL_FADV,
   LIBL_FADV,
   LOAN_UPHD,
   LINT_UPHD,
   LNBL_UPHD,
   LIBL_UPHD,
   MNTH_PF_GROSS,
   MNTH_PTAX_GROSS,
   MNTH_ESI_GROSS,
   YTD_PF_E,
   YTD_FPF,
   YTD_PF_C,
   PF_ADJ_DEDN,
   OENPF_DEDN_GRS
)
AS
   SELECT   'REGULAR' WORKERTYPE,
            A."COMPANYCODE",
            A."DIVISIONCODE",
            A."YEARCODE",
            A."FORTNIGHTSTARTDATE",
            A."FORTNIGHTENDDATE",
            A."DEPARTMENTCODE",
            A."SECTIONCODE",
            A."OCCUPATIONCODE",
            A."WORKERTYPECODE",
            A."WORKERCATEGORYCODE",
            A."SHIFTCODE",
            A."WORKERSERIAL",
            A."TOKENNO",
            A."UNITCODE",
            A."SERIALNO",
            A."PAYMODE",
            A."HRS_RATE",
            A."ATTENDANCEHOURS",
            A."OVERTIMEHOURS",
            A."HOLIDAYHOURS",
            A."STLHOURS",
            A."NIGHTALLOWANCEHOURS",
            A."LAYOFFHOURS",
            A."FBKHOURS",
            A."OTHERHOURS",
            A."PFADJHOURS",
            A."NPFADJHOURS",
            A."ACTUALPAYBLEAMOUNT",
            A."VBASIC",
            A."FBASIC",
            A."DA",
            A."ADHOC",
            A."NS_ALLOW",
            A."H_WAGES",
            A."STL_AMT",
            A."LOWAGES",
            A."OT_AMOUNT",
            A."NPF_ADJ",
            A."PF_ADJ",
            A."GROSS_FOR_HRA",
            A."HRA",
            A."GROSS_WAGES",
            A."PF_GROSS",
            A."PF_CONT",
            A."FPF",
            A."PF_COM",
            A."GROSS_PTAX",
            A."P_TAX",
            A."PENSION_GROSS",
            A."ESI_GROSS",
            A."ESI_CONT",
            A."GR_FOR_BONUS",
            A."TOT_EARN",
            A."WF_DEDN",
            A."COINBF",
            A."COINCF",
            A."TOT_DEDUCTION",
            A."LASTMODIFIED",
            A."USERNAME",
            A."SYSROWID",
            A."INCENTIVE",
            A."WF_DEDN_C",
            A."ESI_COMP_CONT",
            A."BONDAYS_TODATE",
            A."GR_BONUS_TODATE",
            A."NPF_ADJ_DEDN",
            A."STL_ENCASH",
            A."CALENDARWORKINGDAYS",
            A."LOW_RATE",
            A."STL_ADV",
            A."ELECTRIC",
            A."HR_DEDN",
            A."LOAN_PFL",
            A."LINT_PFL",
            A."LNBL_PFL",
            A."LIBL_PFL",
            A."ATN_INCENTIVE",
            A."FBASIC_PEICERT",
            A."FBASIC_RT",
            A."FBASIC_PEICERT_RT",
            A."DA_RT",
            A."ADHOC_RT",
            A."ATN_INCENTIVE_RT",
            A."OENPF",
            A."STLHOURS_ENCASH",
            A."CUM_PFGROSS",
            A."CUM_PF_E",
            A."CUM_PF_C",
            A."STL_BAL",
            A."OEPF",
            A."GRATUITYYEARS",
            A."TSA",
            A."NS_RT",
            A."OEPF_DEDN",
            A."TSA_RT",
            A."NS_RT_RT",
            A."DEPTSERIAL",
            A."NS_ALLOW_OT",
            A."FBK_WAGES",
            A."OT_NSHRS",
            A."FEWORKINGDAYS",
            A."ATN_DAYS",
            A."DAILY_WAGES",
            A."GRADECODE",
            A."CALENDARWORKINGHRS",
            A."GROUPCODE",
            A."VPF",
            A."LOAN_COLN",
            A."LINT_COLN",
            A."LNBL_COLN",
            A."LIBL_COLN",
            A."LOAN_GADV",
            A."LINT_GADV",
            A."LNBL_GADV",
            A."LIBL_GADV",
            A."LOAN_FADV",
            A."LINT_FADV",
            A."LNBL_FADV",
            A."LIBL_FADV",
            A."LOAN_UPHD",
            A."LINT_UPHD",
            A."LNBL_UPHD",
            A."LIBL_UPHD",
            A."MNTH_PF_GROSS",
            A."MNTH_PTAX_GROSS",
            A."MNTH_ESI_GROSS",
            A."YTD_PF_E",
            A."YTD_FPF",
            A."YTD_PF_C",
            A."PF_ADJ_DEDN",
            A."OENPF_DEDN_GRS"
     FROM   WPSWAGESDETAILS A
   UNION ALL
   SELECT   'NON-REGULAR' WORKERTYPE,
            B."COMPANYCODE",
            B."DIVISIONCODE",
            B."YEARCODE",
            B."FORTNIGHTSTARTDATE",
            B."FORTNIGHTENDDATE",
            B."DEPARTMENTCODE",
            B."SECTIONCODE",
            B."OCCUPATIONCODE",
            B."WORKERTYPECODE",
            B."WORKERCATEGORYCODE",
            B."SHIFTCODE",
            B."WORKERSERIAL",
            B."TOKENNO",
            B."UNITCODE",
            B."SERIALNO",
            B."PAYMODE",
            B."HRS_RATE",
            B."ATTENDANCEHOURS",
            B."OVERTIMEHOURS",
            B."HOLIDAYHOURS",
            B."STLHOURS",
            B."NIGHTALLOWANCEHOURS",
            B."LAYOFFHOURS",
            B."FBKHOURS",
            B."OTHERHOURS",
            B."PFADJHOURS",
            B."NPFADJHOURS",
            B."ACTUALPAYBLEAMOUNT",
            B."VBASIC",
            B."FBASIC",
            B."DA",
            B."ADHOC",
            B."NS_ALLOW",
            B."H_WAGES",
            B."STL_AMT",
            B."LOWAGES",
            B."OT_AMOUNT",
            B."NPF_ADJ",
            B."PF_ADJ",
            B."GROSS_FOR_HRA",
            B."HRA",
            B."GROSS_WAGES",
            B."PF_GROSS",
            B."PF_CONT",
            B."FPF",
            B."PF_COM",
            B."GROSS_PTAX",
            B."P_TAX",
            B."PENSION_GROSS",
            B."ESI_GROSS",
            B."ESI_CONT",
            B."GR_FOR_BONUS",
            B."TOT_EARN",
            B."WF_DEDN",
            B."COINBF",
            B."COINCF",
            B."TOT_DEDUCTION",
            B."LASTMODIFIED",
            B."USERNAME",
            B."SYSROWID",
            B."INCENTIVE",
            B."WF_DEDN_C",
            B."ESI_COMP_CONT",
            B."BONDAYS_TODATE",
            B."GR_BONUS_TODATE",
            B."NPF_ADJ_DEDN",
            B."STL_ENCASH",
            B."CALENDARWORKINGDAYS",
            B."LOW_RATE",
            B."STL_ADV",
            B."ELECTRIC",
            B."HR_DEDN",
            B."LOAN_PFL",
            B."LINT_PFL",
            B."LNBL_PFL",
            B."LIBL_PFL",
            B."ATN_INCENTIVE",
            B."FBASIC_PEICERT",
            B."FBASIC_RT",
            B."FBASIC_PEICERT_RT",
            B."DA_RT",
            B."ADHOC_RT",
            B."ATN_INCENTIVE_RT",
            B."OENPF",
            B."STLHOURS_ENCASH",
            B."CUM_PFGROSS",
            B."CUM_PF_E",
            B."CUM_PF_C",
            B."STL_BAL",
            B."OEPF",
            B."GRATUITYYEARS",
            B."TSA",
            B."NS_RT",
            B."OEPF_DEDN",
            B."TSA_RT",
            B."NS_RT_RT",
            B."DEPTSERIAL",
            B."NS_ALLOW_OT",
            B."FBK_WAGES",
            B."OT_NSHRS",
            B."FEWORKINGDAYS",
            B."ATN_DAYS",
            B."DAILY_WAGES",
            B."GRADECODE",
            B."CALENDARWORKINGHRS",
            B."GROUPCODE",
            B."VPF",
            B."LOAN_COLN",
            B."LINT_COLN",
            B."LNBL_COLN",
            B."LIBL_COLN",
            B."LOAN_GADV",
            B."LINT_GADV",
            B."LNBL_GADV",
            B."LIBL_GADV",
            B."LOAN_FADV",
            B."LINT_FADV",
            B."LNBL_FADV",
            B."LIBL_FADV",
            B."LOAN_UPHD",
            B."LINT_UPHD",
            B."LNBL_UPHD",
            B."LIBL_UPHD",
            B."MNTH_PF_GROSS",
            B."MNTH_PTAX_GROSS",
            B."MNTH_ESI_GROSS",
            B."YTD_PF_E",
            B."YTD_FPF",
            B."YTD_PF_C",
            B."PF_ADJ_DEDN",
            B."OENPF_DEDN_GRS"
     FROM   WPSVOUCHERDETAILS B;


DROP VIEW NJMCL_WEB.VW_WPSWAGESDETAILS_DEPSECWISE;

/* Formatted on 08/03/2021 6:33:03 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.VW_WPSWAGESDETAILS_DEPSECWISE
(
   WORKERTYPE,
   COMPANYCODE,
   DIVISIONCODE,
   YEARCODE,
   FORTNIGHTSTARTDATE,
   FORTNIGHTENDDATE,
   DEPARTMENTCODE,
   SECTIONCODE,
   WORKERSERIAL,
   TOKENNO,
   ATTENDANCEHOURS,
   NIGHTALLOWANCEHOURS,
   OVERTIMEHOURS,
   FBASIC,
   VBASIC,
   FBASIC_PEICERT,
   DA,
   NS_ALLOW,
   INCENTIVE,
   ADHOC,
   TSA,
   HRA,
   H_WAGES,
   LOWAGES,
   PF_ADJ,
   NPF_ADJ,
   OT_AMOUNT,
   NS_ALLOW_OT,
   TOT_EARN,
   GROSS_WAGES
)
AS
     SELECT   WORKERTYPE,
              COMPANYCODE,
              DIVISIONCODE,
              YEARCODE,
              FORTNIGHTSTARTDATE,
              FORTNIGHTENDDATE,
              DEPARTMENTCODE,
              SECTIONCODE,
              WORKERSERIAL,
              TOKENNO,
              SUM (NVL (ATTENDANCEHOURS, 0)) ATTENDANCEHOURS,
              SUM (NVL (NIGHTALLOWANCEHOURS, 0)) NIGHTALLOWANCEHOURS,
              SUM (NVL (OVERTIMEHOURS, 0)) OVERTIMEHOURS,
              SUM (NVL (FBASIC, 0)) FBASIC,
              SUM (NVL (VBASIC, 0)) VBASIC,
              SUM (NVL (FBASIC_PEICERT, 0)) FBASIC_PEICERT,
              SUM (NVL (DA, 0)) DA,
              SUM (NVL (NS_ALLOW, 0)) NS_ALLOW,
              SUM (NVL (INCENTIVE, 0)) INCENTIVE,
              SUM (NVL (ADHOC, 0)) ADHOC,
              SUM (NVL (TSA, 0)) TSA,
              SUM (NVL (HRA, 0)) HRA,
              SUM (NVL (H_WAGES, 0)) H_WAGES,
              SUM (NVL (LOWAGES, 0)) LOWAGES,
              SUM (NVL (PF_ADJ, 0)) PF_ADJ,
              SUM (NVL (NPF_ADJ, 0)) NPF_ADJ,
              SUM (NVL (OT_AMOUNT, 0)) OT_AMOUNT,
              SUM (NVL (NS_ALLOW_OT, 0)) NS_ALLOW_OT,
              SUM (NVL (TOT_EARN, 0)) TOT_EARN,
              SUM (NVL (GROSS_WAGES, 0))
       FROM   WPSWAGESDETAILS_VW
   GROUP BY   WORKERTYPE,
              COMPANYCODE,
              DIVISIONCODE,
              YEARCODE,
              FORTNIGHTSTARTDATE,
              FORTNIGHTENDDATE,
              DEPARTMENTCODE,
              SECTIONCODE,
              WORKERSERIAL,
              TOKENNO;


