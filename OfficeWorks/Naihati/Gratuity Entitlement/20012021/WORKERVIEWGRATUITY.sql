DROP VIEW NJMCL_WEB.WORKERVIEWGRATUITY;

/* Formatted on 20/01/2021 12:51:54 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW NJMCL_WEB.WORKERVIEWGRATUITY
(
COMPANYCODE,DIVISIONCODE,WORKERSERIAL,TOKENNO,WORKERNAME,UNITCODE,CATEGORYCODE,GRADECODE,DEPARTMENTCODE,DEPARTMENTNAME,DESIGNATION,
DATEOFJOINING,PFMEMBERSHIPDATE,LBNO,DATEOFCONFIRMATION,DATEOFRETIREMENT,REMARKS,DATEOFTERMINATION,REASONOFTERMINATION,ESINO,PFNO,ACTIVE,
MODULE,ATTENDENCETYPE,DATEOFBIRTH,LASTDATE,FBASIC,DA,LASTWAGESDRAWNDATE,DAILYAVERAGEWAGES,LASTWAGESDRAWN,SAL_15DAYS,TOTALSERVICEYEARS,
TOTALSERVICEMONTHS,TOTALSERVICEDAYS,TOTALNONQUALIFIEDYEAR,TOTALQUALIFIEDYEAR,WAGESPAIDCYCLE,GRATUITYAMOUNT,MAXPERMISSIBLEMOUNT,
GRATUITYYRROUNDLOGIC,GRATUITYJOINDATE,WORKERSTATUS,OCCUPATIONNAME
)
AS (
SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, WORKERNAME, UNITCODE, CATEGORYCODE, GRADECODE, DEPARTMENTCODE, DEPARTMENTNAME, DESIGNATION,
 DATEOFJOINING, PFMEMBERSHIPDATE, LBNO, DATEOFCONFIRMATION, DATEOFRETIREMENT, REMARKS, DATEOFTERMINATION, REASONOFTERMINATION, ESINO, PFNO, ACTIVE,
 MODULE, ATTENDENCETYPE, DATEOFBIRTH, LASTDATE, FBASIC, DA, LASTWAGESDRAWNDATE, DAILYAVERAGEWAGES, LASTWAGESDRAWN, SAL_15DAYS, TOTALSERVICEYEARS,
 TOTALSERVICEMONTHS, TOTALSERVICEDAYS,
 --             CASE
 --                WHEN ( (NVL (TOTALSERVICEMONTHS, 0) * 30)
 --                      + NVL (TOTALSERVICEDAYS, 0)) >= 180
 --                     AND NVL (TOTALNONQUALIFIEDYEAR, 0) > 0
 --                THEN
 --                   NVL (TOTALNONQUALIFIEDYEAR, 0) - 1
 --                ELSE
 --                   NVL (TOTALNONQUALIFIEDYEAR, 0)
 --             END
 NVL (TOTALNONQUALIFIEDYEAR, 0) TOTALNONQUALIFIEDYEAR,
 CASE
    WHEN ( (NVL (TOTALSERVICEMONTHS, 0) * 30)
          + NVL (TOTALSERVICEDAYS, 0)) >= 180
    THEN
       NVL (TOTALQUALIFIEDYEAR, 0) + 1
    ELSE
       NVL (TOTALQUALIFIEDYEAR, 0)
 END
    TOTALQUALIFIEDYEAR,
 WAGESPAIDCYCLE,
 CASE
    WHEN TOTALQUALIFIEDYEAR >= 5
         OR NVL (REASONOFTERMINATION, '~NA~') = 'DEATH'
    THEN
       GRATUITYAMOUNT
    ELSE
       0
 END
    GRATUITYAMOUNT,
 MAXPERMISSIBLEMOUNT,
 GRATUITYYRROUNDLOGIC GRATUITYYRROUNDLOGIC,
 GRATUITYJOINDATE,
 CASE WHEN WORKERSTATUS = 'RETIRED' THEN 'SUPERANNUATION' END
    WORKERSTATUS,
 OCCUPATIONNAME
FROM   (
SELECT   W.COMPANYCODE,W.DIVISIONCODE,W.WORKERSERIAL,W.TOKENNO,W.WORKERNAME,W.UNITCODE,W.WORKERCATEGORYCODE CATEGORYCODE,W.GRADECODE,W.DEPARTMENTCODE,
D.DEPARTMENTNAME,W.DESIGNATION,W.DATEOFJOINING,W.PFMEMBERSHIPDATE,W.WORKERCODE AS LBNO,W.PROMOTIONDATE DATEOFCONFIRMATION,W.DATEOFTERMINATION DATEOFRETIREMENT,
W.REMARKS,W.DATEOFTERMINATION,W.REASONOFTERMINATION,W.ESINO,W.PFNO,W.ACTIVE,'WPS' MODULE,P.ATTENDENCETYPE,W.DATEOFBIRTH,(W.DATEOFTERMINATION) - 1 LASTDATE,
C.FBASIC,C.DA,EE.FORTNIGHTENDDATE LASTWAGESDRAWNDATE,ROUND ( ( ( (C.FBASIC + C.DA) / 208) * 8), 2) /*as per gmcl calculation of wages rate*/
  DAILYAVERAGEWAGES,
( (ROUND ( ( ( (C.FBASIC + C.DA) / 208) * 8), 2) / 8)
* 96)
  LASTWAGESDRAWN,
( (ROUND ( ( ( (C.FBASIC + C.DA) / 208) * 8), 2) / 8)
* 120)
  SAL_15DAYS,
CASE
  WHEN W.PFMEMBERSHIPDATE IS NOT NULL
       AND W.DATEOFTERMINATION IS NOT NULL
  THEN
     TRUNC(MONTHS_BETWEEN (W.DATEOFTERMINATION - 1,
                           W.PFMEMBERSHIPDATE)
           / 12)
  ELSE
     0
END
  AS TOTALSERVICEYEARS,
CASE
  WHEN W.PFMEMBERSHIPDATE IS NOT NULL
       AND W.DATEOFTERMINATION IS NOT NULL
  THEN
     TRUNC(MONTHS_BETWEEN (W.DATEOFTERMINATION - 1,
                           W.PFMEMBERSHIPDATE)
           - (TRUNC(MONTHS_BETWEEN (
                       W.DATEOFTERMINATION - 1,
                       W.PFMEMBERSHIPDATE
                    )
                    / 12)
              * 12))
  ELSE
     0
END
  AS TOTALSERVICEMONTHS,
CASE
  WHEN W.PFMEMBERSHIPDATE IS NOT NULL
       AND W.DATEOFTERMINATION IS NOT NULL
  THEN
     TRUNC (W.DATEOFTERMINATION - 1)
     - ADD_MONTHS (
          W.PFMEMBERSHIPDATE,
          TRUNC(MONTHS_BETWEEN (
                   W.DATEOFTERMINATION - 1,
                   W.PFMEMBERSHIPDATE
                ))
       )
  ELSE
     0
END
  AS TOTALSERVICEDAYS,
NVL (DD.TOTALNONQUALIFIEDYEAR, 0)
  TOTALNONQUALIFIEDYEAR,
CASE
  WHEN (CASE
           WHEN W.PFMEMBERSHIPDATE IS NOT NULL
                AND W.DATEOFTERMINATION IS NOT NULL
           THEN
              TRUNC(MONTHS_BETWEEN (
                       W.DATEOFTERMINATION - 1,
                       W.PFMEMBERSHIPDATE
                    )
                    / 12)
           ELSE
              0
        END) > 0
  THEN
     (CASE
         WHEN W.PFMEMBERSHIPDATE IS NOT NULL
              AND W.DATEOFTERMINATION IS NOT NULL
         THEN
            TRUNC(MONTHS_BETWEEN (
                     W.DATEOFTERMINATION - 1,
                     W.PFMEMBERSHIPDATE
                  )
                  / 12)
         ELSE
            0
      END)
     - DD.TOTALNONQUALIFIEDYEAR
  ELSE
     0
END
  AS TOTALQUALIFIEDYEAR,
'FORTNIGHLY' WAGESPAIDCYCLE,
CASE
  WHEN (CASE
           WHEN W.PFMEMBERSHIPDATE IS NOT NULL
                AND W.DATEOFTERMINATION IS NOT NULL
           THEN
              TRUNC(MONTHS_BETWEEN (
                       W.DATEOFTERMINATION - 1,
                       W.PFMEMBERSHIPDATE
                    )
                    / 12)
           ELSE
              0
        END) > 0
  THEN
     ( (CASE
           WHEN W.PFMEMBERSHIPDATE IS NOT NULL
                AND W.DATEOFTERMINATION IS NOT NULL
           THEN
              TRUNC(MONTHS_BETWEEN (
                       W.DATEOFTERMINATION - 1,
                       W.PFMEMBERSHIPDATE
                    )
                    / 12)
           ELSE
              0
        END)
      - DD.TOTALNONQUALIFIEDYEAR)
     * ( ( (ROUND (
               ( ( (C.FBASIC + C.DA) / 208) * 8),
               2
            )
            / 8)
          * 120))
  ELSE
     0
END
  GRATUITYAMOUNT,
Y.MAXPERMISSIBLEMOUNT,
Z.GRATUITYYRROUNDLOGIC,
W.GRATUITYJOINDATE,
W.WORKERSTATUS,
DG.OCCUPATIONNAME
        FROM   WPSWORKERMAST W,
               WPSOCCUPATIONMAST DG,
               WPSDEPARTMENTMASTER D,
               (SELECT   PARAMETER_VALUE AS ATTENDENCETYPE,
                         COMPANYCODE,
                         DIVISIONCODE
                  FROM   SYS_PARAMETER
                 WHERE   PARAMETER_NAME = 'GRATUITY  ATTENDENCETYPE'
                         AND PROJECTNAME = 'WPS'
                         AND ROWNUM = 1) P,
               (SELECT   NVL (PARAMETER_VALUE, 0) MAXPERMISSIBLEMOUNT,
                         COMPANYCODE,
                         DIVISIONCODE
                  FROM   SYS_PARAMETER
                 WHERE   PARAMETER_NAME =
                            'GRATUITY  MAXPERMISSIBLEMOUNT'
                         AND PROJECTNAME = 'WPS'
                         AND ROWNUM = 1) Y,
               (SELECT   PARAMETER_VALUE GRATUITYYRROUNDLOGIC,
                         COMPANYCODE,
                         DIVISIONCODE
                  FROM   SYS_PARAMETER
                 WHERE   PARAMETER_NAME =
                            'GRATUITY  YEAR ROUND LOGIC'
                         AND PROJECTNAME = 'WPS'
                         AND ROWNUM = 1) Z,
               (SELECT   *
                  FROM   (SELECT   COMPANYCODE,
                                   DIVISIONCODE,
                                   WORKERSERIAL,
                                   TOKENNO,
                                   EFFECTIVEDATE,
                                   NVL (FBASIC, 0) FBASIC,
                                   NVL (DA, 0) DA,
                                   ROW_NUMBER ()
                                      OVER (
                                         PARTITION BY WORKERSERIAL,
                                                      TOKENNO
                                         ORDER BY
                                            WORKERSERIAL,
                                            TOKENNO,
                                            EFFECTIVEDATE DESC
                                      )
                                      SRL
                            FROM   WPSWORKERWISERATEUPDATE)
                 WHERE   SRL = 1) C,
               (  SELECT   COMPANYCODE,
                           DIVISIONCODE,
                           WORKERSERIAL,
                           EMPLOYEECODE,
                           COUNT (GRATURITYENTILE)
                              TOTALNONQUALIFIEDYEAR
                    FROM   GRATUITYSETTLEMENTYEAR
                   WHERE   NVL (GRATURITYENTILE, 'N') = 'N'
                GROUP BY   COMPANYCODE,
                           DIVISIONCODE,
                           WORKERSERIAL,
                           EMPLOYEECODE) DD,
               (SELECT   *
                  FROM   (SELECT   COMPANYCODE,
                                   DIVISIONCODE,
                                   WORKERSERIAL,
                                   TOKENNO,
                                   FORTNIGHTENDDATE,
                                   ROW_NUMBER ()
                                      OVER (
                                         PARTITION BY WORKERSERIAL,
                                                      TOKENNO
                                         ORDER BY
                                            WORKERSERIAL,
                                            TOKENNO,
                                            FORTNIGHTENDDATE DESC
                                      )
                                      SRL
                            FROM   WPSWAGESDETAILS_MV
                           WHERE   (  NVL (ATTENDANCEHOURS, 0)
                                    + NVL (OVERTIMEHOURS, 0)
                                    + NVL (HOLIDAYHOURS, 0)) > 0)
                 WHERE   SRL = 1) EE
       WHERE       W.COMPANYCODE = D.COMPANYCODE(+)
               AND W.DIVISIONCODE = D.DIVISIONCODE(+)
               AND W.DEPARTMENTCODE = D.DEPARTMENTCODE(+)
               AND W.COMPANYCODE = P.COMPANYCODE(+)
               AND W.DIVISIONCODE = P.DIVISIONCODE(+)
               AND W.COMPANYCODE = Y.COMPANYCODE(+)
               AND W.DIVISIONCODE = Y.DIVISIONCODE(+)
               AND W.COMPANYCODE = Z.COMPANYCODE(+)
               AND W.DIVISIONCODE = Z.DIVISIONCODE(+)
               AND W.COMPANYCODE = C.COMPANYCODE(+)
               AND W.DIVISIONCODE = C.DIVISIONCODE(+)
               AND W.WORKERSERIAL = C.WORKERSERIAL(+)
               AND W.TOKENNO = C.TOKENNO(+)
               AND W.COMPANYCODE = DD.COMPANYCODE(+)
               AND W.DIVISIONCODE = DD.DIVISIONCODE(+)
               AND W.WORKERSERIAL = DD.WORKERSERIAL(+)
               AND W.TOKENNO = DD.EMPLOYEECODE(+)
               AND W.COMPANYCODE = EE.COMPANYCODE(+)
               AND W.DIVISIONCODE = EE.DIVISIONCODE(+)
               AND W.WORKERSERIAL = EE.WORKERSERIAL(+)
               AND W.TOKENNO = EE.TOKENNO(+)
               AND W.COMPANYCODE = DG.COMPANYCODE(+)
               AND W.DIVISIONCODE = DG.DIVISIONCODE(+)
               AND W.DEPARTMENTCODE = DG.DEPARTMENTCODE(+)
               AND W.SECTIONCODE = DG.SECTIONCODE(+)
               AND W.OCCUPATIONCODE = DG.OCCUPATIONCODE(+)
               AND NVL (W.WORKERCATEGORYCODE, 'NA') <> '4A'
               AND W.DATEOFTERMINATION <= SYSDATE
      --     WHERE   ACTIVE = 'Y'
      UNION ALL
      SELECT   P.COMPANYCODE,
               P.DIVISIONCODE,
               P.WORKERSERIAL,
               P.TOKENNO,
               P.EMPLOYEENAME,
               P.UNITCODE,
               P.CATEGORYCODE,
               P.GRADECODE,
               P.DEPARTMENTCODE,
               D.DEPARTMENTNAME,
               P.DESIGNATIONCODE DESIGNATION,
               P.DATEOFJOIN DATEOFJOINING,
               P.PFENTITLEDATE PFMEMBERSHIPDATE,
               P.TOKENNO AS LBNO,
               P.DATEOFCONFIRMATION DATEOFCONFIRMATION,
               --P.DATEOFRETIRE DATEOFRETIREMENT,
               P.DATEOFTERMINATIONADVICE DATEOFRETIREMENT,
               P.REMARKS,
               P.DATEOFTERMINATIONADVICE DATEOFTERMINATION,
               P.REMARKS REASONOFTERMINATION,
               P.ESINO,
               P.PFNO,
               DECODE (P.EMPLOYEESTATUS, 'ACTIVE', 'Y', 'N') ACTIVE,
               'PIS' MODULE,
               PAR.ATTENDENCETYPE,
               P.DATEOFBIRTH,
               (P.DATEOFTERMINATIONADVICE) - 1 LASTDATE,
               C.FBASIC,
               C.DA,
               C.EFFECTIVEDATE LASTWAGESDRAWNDATE,
               ROUND ( ( ( (C.FBASIC + C.DA) / 208) * 8), 2)
                  DAILYAVERAGEWAGES,
               ( (ROUND ( ( ( (C.FBASIC + C.DA) / 208) * 8), 2) / 8)
                * 96)
                  LASTWAGESDRAWN,
               ( (ROUND ( ( ( (C.FBASIC + C.DA) / 208) * 8), 2) / 8)
                * 120)
                  SAL_15DAYS,
               CASE
                  WHEN P.PFENTITLEDATE IS NOT NULL
                       AND P.DATEOFTERMINATIONADVICE IS NOT NULL
                  THEN
                     TRUNC(MONTHS_BETWEEN (
                              P.DATEOFTERMINATIONADVICE - 1,
                              P.PFENTITLEDATE
                           )
                           / 12)
                  ELSE
                     0
               END
                  AS TOTALSERVICEYEARS,
               CASE
                  WHEN P.PFENTITLEDATE IS NOT NULL
                       AND P.DATEOFTERMINATIONADVICE IS NOT NULL
                  THEN
                     TRUNC(MONTHS_BETWEEN (
                              P.DATEOFTERMINATIONADVICE - 1,
                              P.PFENTITLEDATE
                           )
                           - (TRUNC(MONTHS_BETWEEN (
                                       P.DATEOFTERMINATIONADVICE - 1,
                                       P.PFENTITLEDATE
                                    )
                                    / 12)
                              * 12))
                  ELSE
                     0
               END
                  AS TOTALSERVICEMONTHS,
               CASE
                  WHEN P.PFENTITLEDATE IS NOT NULL
                       AND P.DATEOFTERMINATIONADVICE IS NOT NULL
                  THEN
                     TRUNC (P.DATEOFTERMINATIONADVICE - 1)
                     - ADD_MONTHS (
                          P.PFENTITLEDATE,
                          TRUNC(MONTHS_BETWEEN (
                                   P.DATEOFTERMINATIONADVICE - 1,
                                   P.PFENTITLEDATE
                                ))
                       )
                  ELSE
                     0
               END
                  AS TOTALSERVICEDAYS,
               NVL (DD.TOTALNONQUALIFIEDYEAR, 0)
                  TOTALNONQUALIFIEDYEAR,
               CASE
                  WHEN (CASE
                           WHEN P.PFENTITLEDATE IS NOT NULL
                                AND P.DATEOFTERMINATIONADVICE IS NOT NULL
                           THEN
                              TRUNC(MONTHS_BETWEEN (
                                       P.DATEOFTERMINATIONADVICE - 1,
                                       P.PFENTITLEDATE
                                    )
                                    / 12)
                           ELSE
                              0
                        END) > 0
                  THEN
                     (CASE
                         WHEN P.PFENTITLEDATE IS NOT NULL
                              AND P.DATEOFTERMINATIONADVICE IS NOT NULL
                         THEN
                            TRUNC(MONTHS_BETWEEN (
                                     P.DATEOFTERMINATIONADVICE - 1,
                                     P.PFENTITLEDATE
                                  )
                                  / 12)
                         ELSE
                            0
                      END)
                     - DD.TOTALNONQUALIFIEDYEAR
                  ELSE
                     0
               END
                  TOTALQUALIFIEDYEAR,
               '' WAGESPAIDCYCLE,
               CASE
                  WHEN (CASE
                           WHEN P.PFENTITLEDATE IS NOT NULL
                                AND P.DATEOFTERMINATIONADVICE IS NOT NULL
                           THEN
                              TRUNC(MONTHS_BETWEEN (
                                       P.DATEOFTERMINATIONADVICE - 1,
                                       P.PFENTITLEDATE
                                    )
                                    / 12)
                           ELSE
                              0
                        END) > 0
                  THEN
                     ( (CASE
                           WHEN P.PFENTITLEDATE IS NOT NULL
                                AND P.DATEOFTERMINATIONADVICE IS NOT NULL
                           THEN
                              TRUNC(MONTHS_BETWEEN (
                                       P.DATEOFTERMINATIONADVICE - 1,
                                       P.PFENTITLEDATE
                                    )
                                    / 12)
                           ELSE
                              0
                        END)
                      - DD.TOTALNONQUALIFIEDYEAR)
                     * ( ( (ROUND (
                               ( ( (C.FBASIC + C.DA) / 208) * 8),
                               2
                            )
                            / 8)
                          * 120))
                  ELSE
                     0
               END
                  GRATUITYAMOUNT,
               Y.MAXPERMISSIBLEMOUNT,
               Z.GRATUITYYRROUNDLOGIC,
               P.GRATUITYJOINDATE,
               P.EMPLOYEESTATUS WORKERSTATUS,
               DG.DESIGNATIONDESC OCCUPATIONNAME
        FROM   PISEMPLOYEEMASTER P,
               PISDESIGNATIONMASTER DG,
               WPSDEPARTMENTMASTER D,
               (SELECT   PARAMETER_VALUE AS ATTENDENCETYPE,
                         COMPANYCODE,
                         DIVISIONCODE
                  FROM   SYS_PARAMETER
                 WHERE   PARAMETER_NAME = 'GRATUITY  ATTENDENCETYPE'
                         AND PROJECTNAME = 'WPS'
                         AND ROWNUM = 1) PAR,
               (SELECT   NVL (PARAMETER_VALUE, 0) MAXPERMISSIBLEMOUNT,
                         COMPANYCODE,
                         DIVISIONCODE
                  FROM   SYS_PARAMETER
                 WHERE   PARAMETER_NAME =
                            'GRATUITY  MAXPERMISSIBLEMOUNT'
                         AND PROJECTNAME = 'WPS'
                         AND ROWNUM = 1) Y,
               (SELECT   PARAMETER_VALUE GRATUITYYRROUNDLOGIC,
                         COMPANYCODE,
                         DIVISIONCODE
                  FROM   SYS_PARAMETER
                 WHERE   PARAMETER_NAME =
                            'GRATUITY  YEAR ROUND LOGIC'
                         AND PROJECTNAME = 'WPS'
                         AND ROWNUM = 1) Z,
               (SELECT   *
                  FROM   (SELECT   COMPANYCODE,
                                   DIVISIONCODE,
                                   WORKERSERIAL,
                                   TOKENNO,
                                   EFFECTIVEDATE,
                                   NVL (FBASIC, 0) FBASIC,
                                   NVL (DA, 0) DA,
                                   ROW_NUMBER ()
                                      OVER (
                                         PARTITION BY WORKERSERIAL,
                                                      TOKENNO
                                         ORDER BY
                                            WORKERSERIAL,
                                            TOKENNO,
                                            EFFECTIVEDATE DESC
                                      )
                                      SRL
                            FROM   WPSWORKERWISERATEUPDATE)
                 WHERE   SRL = 1) C,
               (  SELECT   COMPANYCODE,
                           DIVISIONCODE,
                           WORKERSERIAL,
                           EMPLOYEECODE,
                           COUNT (GRATURITYENTILE)
                              TOTALNONQUALIFIEDYEAR
                    FROM   GRATUITYSETTLEMENTYEAR
                   WHERE   NVL (GRATURITYENTILE, 'N') = 'N'
                GROUP BY   COMPANYCODE,
                           DIVISIONCODE,
                           WORKERSERIAL,
                           EMPLOYEECODE) DD
       WHERE       P.COMPANYCODE = D.COMPANYCODE(+)
               AND P.DIVISIONCODE = D.DIVISIONCODE(+)
               AND P.DEPARTMENTCODE = D.DEPARTMENTCODE(+)
               AND P.COMPANYCODE = PAR.COMPANYCODE(+)
               AND P.DIVISIONCODE = PAR.DIVISIONCODE(+)
               AND P.COMPANYCODE = Y.COMPANYCODE(+)
               AND P.DIVISIONCODE = Y.DIVISIONCODE(+)
               AND P.COMPANYCODE = Z.COMPANYCODE(+)
               AND P.DIVISIONCODE = Z.DIVISIONCODE(+)
               AND P.COMPANYCODE = C.COMPANYCODE(+)
               AND P.DIVISIONCODE = C.DIVISIONCODE(+)
               AND P.WORKERSERIAL = C.WORKERSERIAL(+)
               AND P.TOKENNO = C.TOKENNO(+)
               AND P.COMPANYCODE = DD.COMPANYCODE(+)
               AND P.DIVISIONCODE = DD.DIVISIONCODE(+)
               AND P.WORKERSERIAL = DD.WORKERSERIAL(+)
               AND P.TOKENNO = DD.EMPLOYEECODE(+)
               AND P.COMPANYCODE = DG.COMPANYCODE(+)
               AND P.DIVISIONCODE = DG.DIVISIONCODE(+)
               AND P.DESIGNATIONCODE = DG.DESIGNATIONCODE(+)
               AND NVL (P.CATEGORYCODE, 'NA') <> '4A'
               AND P.DATEOFTERMINATIONADVICE <= SYSDATE));

