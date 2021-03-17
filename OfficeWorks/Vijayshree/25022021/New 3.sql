DELETE FROM WPSCASHOTPAYMENTDETAILS@WPS_2_KIOSK
WHERE PAYMENTFROMDATE = TO_DATE('24/02/2021','DD/MM/YYYY') 
AND PAYMENTTODATE = TO_DATE('24/02/2021','DD/MM/YYYY') 
AND COMPANYCODE='0003' 
AND DIVISIONCODE='0032' 

INSERT INTO WPSCASHOTPAYMENTDETAILS@WPS_2_KIOSK
(
    COMPANYCODE,DIVISIONCODE,PAYMENTFROMDATE, PAYMENTTODATE, 
    DEPARTMENTCODE, DEPARTMENTNAME, SHIFTCODE,
    TOKENNO,WORKERNAME, WORKERSERIAL, OTHOURS,OTAMOUNT,ESI_OT,  
    NETPAY,PAYMENTLOCK,ISTRANSFER
)

SELECT *
FROM WPSDAILYWAGESDETAILS


SELECT A.COMPANYCODE,A.DIVISIONCODE,A.FORTNIGHTSTARTDATE PAYMENTFROMDATE, A.FORTNIGHTENDDATE PAYMENTTODATE, 
A.DEPARTMENTCODE, B.DEPARTMENTNAME, DECODE(A.SHIFTCODE,'1','A','2','B','C') SHIFTCODE,
A.TOKENNO,C.WORKERNAME, A.WORKERSERIAL, A.OVERTIMEHOURS OTHOURS,A.CASHOT_AMOUNT OTAMOUNT,A.DAILY_ESI ESI_OT,  
ACTUALPAYBLEAMOUNT NETPAY,'N' PAYMENTLOCK,'N' ISTRANSFER  
FROM WPSDAILYWAGESDETAILS A, WPSDEPARTMENTMASTER B, WPSWORKERMAST C 
WHERE A.COMPANYCODE=B.COMPANYCODE
    AND A.DIVISIONCODE=B.DIVISIONCODE
    AND A.COMPANYCODE=C.COMPANYCODE
    AND A.DIVISIONCODE=C.DIVISIONCODE
    AND A.DEPARTMENTCODE=B.DEPARTMENTCODE
    AND A.WORKERSERIAL=C.WORKERSERIAL
    AND NVL(A.ACTUALPAYBLEAMOUNT,0) > 0
    AND  TRUNC(A.FORTNIGHTSTARTDATE) BETWEEN TO_DATE('24/02/2021','DD/MM/YYYY') AND  TO_DATE('24/02/2021','DD/MM/YYYY')

SELECT * FROM WPS_ERROR_LOG

proc_wps_update_NA_comp



SELECT * FROM WPSDAILYWAGESDETAILS


SELECT * FROM WPSCASHOTPAYMENTDETAILS@WPS_2_KIOSK
WHERE TOKENNO='MF0796B'

proc_wps_update_NA_comp

EXEC PROC_CASHOT_EXPORTTOKIOSK('0003','0032','24/02/2021','24/02/2021')


(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_FROMDATE VARCHAR2,
    P_TODATE VARCHAR2 
)

update WPSWAGESDETAILS_SWT a set (CASHOT_AMOUNT, WORKERCATEGORYCODE ) = ( select CASHOT_AMOUNT, WORKERCATEGORYCODE from WPSWAGESDETAILS_PHASE_11 b 
 where a.WORKERSERIAL = b.WORKERSERIAL 
--and NVL(a.DEPARTMENTCODE,'N') = NVL(b.DEPARTMENTCODE,'N') 
 AND A.WORKERCATEGORYCODE = B.WORKERCATEGORYCODE )
 
 
 
DELETE FROM WPS_ERROR_LOG

SELECT * FROM WPS_ERROR_LOG


SELECT * FROM WPSWORKERMAST
WHERE TOKENNO='MF0796B'

PROC_WPSWAGESPROCESS_UPDATE

CREATE TABLE WPSWAGESDETAILS_PHASE_11 AS 

SELECT WPSTEMPATTN.WORKERSERIAL,/* WPSTEMPATTN.DEPARTMENTCODE,*/ WPSTEMPMAST.WORKERCATEGORYCODE, 
WPSTEMPATTN.SHIFTCODE,WPSTEMPCOMPONENT.DEPARTMENTCODE,
 SUM(WPSTEMPATTN.ATTENDANCEHOURS) ATTENDANCEHOURS, SUM(WPSTEMPATTN.STLHOURS) STLHOURS /* STATUTORYHOURS */, SUM(WPSTEMPATTN.OVERTIMEHOURS) OVERTIMEHOURS, 
 SUM(WPSTEMPATTN.HOLIDAYHOURS) HOLIDAYHOURS 
 , SUM(ROUND((ROUND((NVL(WPSTEMPMAST.ADHOCRATE,0) + NVL(WPSTEMPMAST.ADDLBASIC_RATE,0) + NVL(WPSTEMPMAST.DARATE,0))/208,2) +NVL(WPSTEMPMAST.DAILYBASICRATE,0))*WPSTEMPATTN.OVERTIMEHOURS,0)) AS CASHOT_AMOUNT
 FROM WPSTEMPMAST, WPSTEMPATTN, WPSTEMPCOMPONENT /*, WPSTEMPFNPARAM */
 WHERE WPSTEMPATTN.WORKERSERIAL = WPSTEMPMAST.WORKERSERIAL 
   AND WPSTEMPATTN.WORKERSERIAL = WPSTEMPCOMPONENT.WORKERSERIAL  
 /*  AND WPSTEMPATTN.DEPARTMENTCODE = WPSTEMPCOMPONENT.DEPARTMENTCODE */
   AND WPSTEMPATTN.DEPARTMENTCODE = WPSTEMPCOMPONENT.DEPARTMENTCODE 
   AND WPSTEMPATTN.SHIFTCODE = WPSTEMPCOMPONENT.SHIFTCODE 
   AND WPSTEMPATTN.WORKERSERIAL='01430'
 GROUP BY WPSTEMPATTN.WORKERSERIAL,/* WPSTEMPATTN.DEPARTMENTCODE,*/ WPSTEMPMAST.WORKERCATEGORYCODE
 , WPSTEMPATTN.SHIFTCODE,WPSTEMPCOMPONENT.DEPARTMENTCODE 
 
CREATE TABLE WPSWAGESDETAILS_PHASE_12 AS 

SELECT WPSTEMPATTN.WORKERSERIAL,/* WPSTEMPATTN.DEPARTMENTCODE,*/ WPSTEMPMAST.WORKERCATEGORYCODE, 
 SUM(WPSTEMPATTN.ATTENDANCEHOURS) ATTENDANCEHOURS, SUM(WPSTEMPATTN.STLHOURS) STLHOURS /* STATUTORYHOURS */, SUM(WPSTEMPATTN.OVERTIMEHOURS) OVERTIMEHOURS, 
 SUM(WPSTEMPATTN.HOLIDAYHOURS) HOLIDAYHOURS 
 , SUM(CASE WHEN WPSTEMPMAST.ESIAPPLICABLE = 'Y' THEN  CEIL(TRUNC(WPSTEMPCOMPONENT.CASHOT_AMOUNT *0.0075,2)) ELSE 0 END) AS DAILY_ESI
 FROM WPSTEMPMAST, WPSTEMPATTN, WPSTEMPCOMPONENT /*, WPSTEMPFNPARAM */
 WHERE WPSTEMPATTN.WORKERSERIAL = WPSTEMPMAST.WORKERSERIAL 
   AND WPSTEMPATTN.WORKERSERIAL = WPSTEMPCOMPONENT.WORKERSERIAL  
 /*  AND WPSTEMPATTN.DEPARTMENTCODE = WPSTEMPCOMPONENT.DEPARTMENTCODE */
   AND WPSTEMPATTN.DEPARTMENTCODE = WPSTEMPCOMPONENT.DEPARTMENTCODE 
   AND WPSTEMPATTN.SHIFTCODE = WPSTEMPCOMPONENT.SHIFTCODE 
   AND WPSTEMPATTN.WORKERSERIAL='01430'
 GROUP BY WPSTEMPATTN.WORKERSERIAL,/* WPSTEMPATTN.DEPARTMENTCODE,*/ WPSTEMPMAST.WORKERCATEGORYCODE 
 , WPSTEMPATTN.SHIFTCODE,WPSTEMPCOMPONENT.DEPARTMENTCODE 


CREATE TABLE WPSWAGESDETAILS_PHASE_12 AS 

SELECT WPSTEMPATTN.WORKERSERIAL,/* WPSTEMPATTN.DEPARTMENTCODE,*/ WPSTEMPMAST.WORKERCATEGORYCODE, 
 , WPSTEMPATTN.SHIFTCODE,WPSTEMPCOMPONENT.DEPARTMENTCODE 
 SUM(WPSTEMPATTN.ATTENDANCEHOURS) ATTENDANCEHOURS, SUM(WPSTEMPATTN.STLHOURS) STLHOURS /* STATUTORYHOURS */, SUM(WPSTEMPATTN.OVERTIMEHOURS) OVERTIMEHOURS, 
 SUM(WPSTEMPATTN.HOLIDAYHOURS) HOLIDAYHOURS 
 , SUM(CASE WHEN WPSTEMPMAST.ESIAPPLICABLE = 'Y' THEN  CEIL(TRUNC(WPSTEMPCOMPONENT.CASHOT_AMOUNT *0.0075,2)) ELSE 0 END) AS DAILY_ESI
 FROM WPSTEMPMAST, WPSTEMPATTN, WPSTEMPCOMPONENT /*, WPSTEMPFNPARAM */
 WHERE WPSTEMPATTN.WORKERSERIAL = WPSTEMPMAST.WORKERSERIAL 
   AND WPSTEMPATTN.WORKERSERIAL = WPSTEMPCOMPONENT.WORKERSERIAL  
 /*  AND WPSTEMPATTN.DEPARTMENTCODE = WPSTEMPCOMPONENT.DEPARTMENTCODE */
   AND WPSTEMPATTN.DEPARTMENTCODE = WPSTEMPCOMPONENT.DEPARTMENTCODE 
   AND WPSTEMPATTN.SHIFTCODE = WPSTEMPCOMPONENT.SHIFTCODE 
 GROUP BY WPSTEMPATTN.WORKERSERIAL,/* WPSTEMPATTN.DEPARTMENTCODE,*/ WPSTEMPMAST.WORKERCATEGORYCODE 
, WPSTEMPATTN.SHIFTCODE,WPSTEMPCOMPONENT.DEPARTMENTCODE  