INSERT INTO WPSSTLENTITLEMENTCALCDETAILS
 ( 
 COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, CATEGORYCODE, FROMYEAR, YEARCODE,
 FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, SHIFTCODE,
 ATTNHOURS, FESTHOURS, HOLIDAYHOURS, TOTALHOURS, STLHRSTAKEN, STLDAYSTAKEN,
 STANDARDSTLHOURS, ADJUSTEDHOURS, APPLICABLESTANDHOURS, STLDAYS, STLHOURS, STLDAYS_BF,
 TRANSACTIONTYPE, ADDLESS, USERNAME, LASTMODIFIED, SYSROWID,GRACEDAYS, ATTNDAYS
 )

 SELECT COMPANYCODE, DIVISIONCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, '2020'  FROMYEAR, '2021' YEARCODE,
 '01-JAN-21' FORTNIGHTSTARTDATE, '15-JAN-21' FORTNIGHTENDDATE, DEPARTMENTCODE, '1' SHIFTCODE,
 ATTN_HRS ATTNHOURS, 0 FESTHOURS, HOL_HRS HOLIDAYHOURS, (ELIGIBLE_HRS) TOTALHOURS, STL_HRS, STL_DAYS STLDAYSTAKEN,
 STNDDAYS*8 STANDARDSTLHOURS, 0 ADJUSTEDHOURS, 1920 APPLICABLESTANDHOURS, ENT_DAYS STLDAYS, ENT_DAYS*8 STLHOURS, PREV_ENT_STLDAYS STLDAYS_BF,
 'ENTITLEMENT' TRANSACTIONTYPE, 'ADD' ADDLESS, 'SWT' USERNAME, SYSDATE LASTMODIFIED, WORKERSERIAL||'-'||TO_CHAR(SYSDATE,'YYYYMMDDHHMISS') SYSROWID,GRACEDAYS, ATTN_DAYS 
 FROM (
SELECT
 B.COMPANYCODE, B.DIVISIONCODE, A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE, B.TERMINATIONDATE,
 SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(PRV_STLHRS) PRV_STLHRS,
 SUM(ATTN_HRS) ATTN_HRS, SUM(HOL_HRS) HOL_HRS, CASE WHEN SUM(STL_HRS) > 0 THEN case when (SUM(STL_HRS) - SUM(PRV_STLHRS_CALC)) > 0 then SUM(STL_HRS) - SUM(PRV_STLHRS_CALC) else 0 end ELSE 0 END STL_HRS,
 SUM(ELIGIBLE_HRS) ELIGIBLE_HRS, SUM(ATTN_DAYS) ATTN_DAYS, SUM(STL_DAYS) STL_DAYS, SUM(HOL_DAYS) HOL_DAYS,
 SUM(ELIGIBLE_DAYS) ELIGIBLE_DAYS, SUM(GRACEDAYS)  GRACEDAYS,
 0 PREV_ENT_STLDAYS,
     CASE WHEN B.TERMINATIONDATE IS  NULL THEN
            CASE WHEN SUM(ELIGIBLE_DAYS+NVL(GRACEDAYS,0)) >= 240 THEN ROUND(SUM(FEWORKINGDAYS)/20,0) ELSE 0 END
          WHEN B.TERMINATIONDATE BETWEEN '01-JAN-20'  AND '31-DEC-20' AND SUM(ELIGIBLE_DAYS+NVL(GRACEDAYS,0)) >= 240-((TO_NUMBER(TO_CHAR(TERMINATIONDATE,'MM'))-TO_NUMBER(TO_CHAR(TO_DATE('01-JAN-20','DD/MM/YYYY'),'MM')-1))*20)  THEN
          ROUND(SUM(FEWORKINGDAYS)/20,0)
          ELSE 0
     END
     ENT_DAYS
 , CASE WHEN B.TERMINATIONDATE IS  NULL  THEN 240
        WHEN B.TERMINATIONDATE BETWEEN '01-JAN-20'  AND '31-DEC-20' THEN
        ((TO_NUMBER(TO_CHAR(TERMINATIONDATE,'MM'))-TO_NUMBER(TO_CHAR(TO_DATE('01-JAN-20','DD/MM/YYYY'),'MM')-1))*20)
        ELSE 0 END
        STNDDAYS
 FROM (
         select WORKERSERIAL, SUM(PREV_STLDAYS) PREV_STLDAYS, SUM(PRV_STLHRS) PRV_STLHRS,
         SUM(PRV_STLHRS_CALC) PRV_STLHRS_CALC,SUM(ATTN_HRS) ATTN_HRS, SUM(HOL_HRS) HOL_HRS,
         SUM(STL_HRS) STL_HRS, SUM(STLENCASH_HRS) STLENCASH_HRS,
         SUM(ELIGIBLE_HRS) ELIGIBLE_HRS,
         ROUND(SUM(NVL(ATTN_HRS,0))/8,2) ATTN_DAYS,
         ROUND(SUM(NVL(STL_HRS,0))/8,2) STL_DAYS,
         ROUND(SUM(NVL(HOL_HRS,0))/8,2) HOL_DAYS,
         SUM(ELIGIBLE_DAYS) ELIGIBLE_DAYS ,
         SUM(FEWORKINGDAYS)FEWORKINGDAYS
         FROM (
                 SELECT WORKERSERIAL,  0 PREV_STLDAYS,  0 PRV_STLHRS,
                 0 PRV_STLHRS_CALC,SUM(NVL(ATTENDANCEHOURS,0)) ATTN_HRS, SUM(NVL(HOLIDAYHOURS,0)) HOL_HRS,
                 0 STL_HRS, 0 STLENCASH_HRS,
                 SUM(NVL(FEWORKINGDAYS*8,0))  ELIGIBLE_HRS,
                 ROUND(SUM(NVL(ATTENDANCEHOURS,0))/8,2) ATTN_DAYS,
                 0 STL_DAYS,
                 ROUND(SUM(NVL(HOLIDAYHOURS,0))/8,2) HOL_DAYS,
                 SUM(NVL(FEWORKINGDAYS,0)) ELIGIBLE_DAYS,
                 SUM(NVL(ATN_DAYS,0)) FEWORKINGDAYS
                 FROM WPSWAGESDETAILS_MV A, WPSWORKERCATEGORYMAST B
                 WHERE A.COMPANYCODE = 'NJ0001' AND A.DIVISIONCODE = '0002'
                 AND A.FORTNIGHTSTARTDATE >= '01-JAN-20'
                 AND A.FORTNIGHTENDDATE <= '31-DEC-20'
                 AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE
                 AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE
                 AND NVL(B.STLAPPLICABLE,'N')='Y'
--                 AND WORKERSERIAL='005133'
                 GROUP BY A.WORKERSERIAL
                 UNION ALL
                 SELECT WORKERSERIAL, /*FORTNIGHTSTARTDATE, */ 0 PREV_STLDAYS,  0 PRV_STLHRS,
                 0 PRV_STLHRS_CALC,0 ATTN_HRS, 0 HOL_HRS,
                 SUM(NVL(STLHOURS,0)) STL_HRS, 0 STLENCASH_HRS,
                 SUM(NVL(STLHOURS,0)) ELIGIBLE_HRS,
                 0 ATTN_DAYS,
                  SUM(NVL(STLDAYS,0)) STL_DAYS,
                 0 HOL_DAYS,
                 SUM(NVL(STLDAYS,0)) ELIGIBLE_DAYS ,
                 0 FEWORKINGDAYS
                 FROM WPSSTLWAGESDETAILS A, WPSWORKERCATEGORYMAST B
                 WHERE A.COMPANYCODE = 'NJ0001' AND A.DIVISIONCODE = '0002'
                 AND A.PAYMENTDATE >= '01-JAN-20'
                 AND A.PAYMENTDATE <= '31-DEC-20'
                 AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE =  B.DIVISIONCODE
                 AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE
                 AND NVL(B.STLAPPLICABLE,'N')='Y'
--                 AND WORKERSERIAL='005133'
                 GROUP BY A.WORKERSERIAL
             )
            WHERE WORKERSERIAL='005133'   
           GROUP BY WORKERSERIAL
 ) A, WPSWORKERMAST B, WPSWORKERSTLGRACEPERIODDAYS C
 WHERE B.COMPANYCODE = 'NJ0001' AND B.DIVISIONCODE = '0002'
 AND B.WORKERSERIAL = A.WORKERSERIAL AND B.WORKERSERIAL = C.WORKERSERIAL(+)
 AND B.TOKENNO='50181'
 GROUP BY B.COMPANYCODE, B.DIVISIONCODE,A.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, B.DEPARTMENTCODE,B.TERMINATIONDATE
 )