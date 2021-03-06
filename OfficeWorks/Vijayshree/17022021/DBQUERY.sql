select * from WPSATTENDANCETABRAWDATA order by attndate desc

SELECT * FROM ROLEDETAILS

BioAttn.ReportMaster


SELECT * FROM WPSCASHOTPAYMENTDETAILS


BioAttn.LoadMenu

SELECT * FROM TAB
WHERE TNAME LIKE '%%'

SELECT WM_CONCAT(COLUMN_NAME) FROM COLS
WHERE TABLE_NAME = 'WPSCASHOTPAYMENTDETAILS'


SELECT  COLUMN_NAME  FROM COLS
WHERE TABLE_NAME = 'WPSCASHOTPAYMENTDETAILS'


COMPANYCODE,DIVISIONCODE,PAYMENTFROMDATE,PAYMENTTODATE,DEPARTMENTCODE,DEPARTMENTNAME,SHIFTCODE,

TOKENNO,WORKERNAME,WORKERSERIAL,OTHOURS,OTAMOUNT,ESI_OT,NETPAY,PAYMENTLOCK,ISTRANSFER,PAYABLEDATE


SELECT PAYMENTFROMDATE ATTN_DATE,TOKENNO, WORKERNAME,DEPARTMENTNAME,SHIFTCODE, NETPAY 
FROM WPSCASHOTPAYMENTDETAILS
WHERE PAYMENTFROMDATE BETWEEN ''


SET DEFINE OFF;
Insert into ROLEDETAILS
   (COMPANYCODE, DIVISIONCODE, ROLEID, BTNID, BTNNAME, SERIALNO, ACTIVE, PRINT, FORMTAG, FORMNAME)
 Values
   ('0003', '0032', '1', 'btnOTPaymentRpt', 'OT Payment', 
    1407, 'Y', NULL, 'OSW SUMMARY', 'BioAttn.OTPaymentRpt');
COMMIT;





--------------------------------------------------------------------------------


 SELECT PAYMENTFROMDATE ATTN_DATE,TOKENNO, WORKERNAME,DEPARTMENTNAME,SHIFTCODE, NETPAY  
 FROM WPSCASHOTPAYMENTDETAILS A 
 WHERE PAYMENTFROMDATE BETWEEN TO_DATE('16/12/2020','DD/MM/YYYY') AND  TO_DATE('18/12/2020','DD/MM/YYYY') 
 AND A.COMPANYCODE='0003'  AND A.DIVISIONCODE='0032'  
 
 AND  PAYMENTFROMDATE BETWEEN TO_DATE('16/12/2020','DD/MM/YYYY') AND TO_DATE('18/12/2020','DD/MM/YYYY')  
 
 
--------------------------------------------------------------------------------

 SELECT PAYMENTFROMDATE ATTN_DATE,TOKENNO TOKEN, WORKERNAME NAME,DEPARTMENTNAME DEPARTMENT,SHIFTCODE SHIFT, NETPAY ,SUBSTR(A.SHIFTCODE,1,1) 
 FROM WPSCASHOTPAYMENTDETAILS A WHERE 1=1 
 AND A.COMPANYCODE='0003'  
 AND A.DIVISIONCODE='0032'   
 
 AND SUBSTR(A.SHIFTCODE,1,1)='C' AND  PAYMENTFROMDATE BETWEEN TO_DATE('16/12/2020','DD/MM/YYYY') AND TO_DATE('17/12/2020','DD/MM/YYYY')   AND NVL(PAYMENTLOCK,'N')='Y'
 
 
SELECT TO_CHAR(PAYMENTFROMDATE,'DD/MM/YYYY') ATTN_DATE,TOKENNO TOKEN, WORKERNAME NAME,
  DEPARTMENTNAME DEPARTMENT,SHIFTCODE SHIFT, NETPAY , DECODE(NVL(PAYMENTLOCK,'N'),'Y','PAID','UNPAID') STATUS
  FROM WPSCASHOTPAYMENTDETAILS A 
  WHERE 1=1 AND A.COMPANYCODE='0003'  
  AND A.DIVISIONCODE='0032'   
  AND SUBSTR(A.SHIFTCODE,1,1)='C' 
  
  AND NVL(PAYMENTLOCK,'N')='Y'
  
  AND  PAYMENTFROMDATE BETWEEN TO_DATE('16/12/2020','DD/MM/YYYY') AND TO_DATE('17/12/2020','DD/MM/YYYY')   
  
  
  
SELECT PAYMENTFROMDATE ATTN_DATE, SUM(NETPAY) Outstanding  
FROM WPSCASHOTPAYMENTDETAILS A 
WHERE 1=1 AND A.COMPANYCODE='0003'  
AND A.DIVISIONCODE='0032'   
AND SUBSTR(A.SHIFTCODE,1,1)='C' 
GROUP BY PAYMENTFROMDATE
ORDER BY ATTN_DATE
  

---------------------------------------------------------------------------------


  SELECT TO_CHAR(PAYABLEDATE,'DD/MM/YYYY')  PYMT_DATE,TOKENNO TOKEN, WORKERNAME NAME,
  DEPARTMENTNAME DEPARTMENT,SHIFTCODE SHIFT, NETPAY , DECODE(NVL(PAYMENTLOCK,'N'),'Y','PAID','UNPAID') STATUS
  FROM WPSCASHOTPAYMENTDETAILS A 
  WHERE 1=1 AND A.COMPANYCODE='0003'  
  AND A.DIVISIONCODE='0032'   
  AND SUBSTR(A.SHIFTCODE,1,1)='C' 
  
  
  
   SELECT TO_CHAR(PAYABLEDATE,'DD/MM/YYYY') PYMT_DATE,TOKENNO TOKEN, WORKERNAME NAME,
   DEPARTMENTNAME DEPARTMENT,SHIFTCODE SHIFT, NETPAY AMOUNT 
   FROM WPSCASHOTPAYMENTDETAILS A 
   WHERE 1=1 
   AND A.COMPANYCODE='0003'  
   AND A.DIVISIONCODE='0032'  
   AND  PAYABLEDATE BETWEEN TO_DATE('16/12/2020','DD/MM/YYYY') AND TO_DATE('25/12/2021','DD/MM/YYYY')  
   
   
   SELECT CASE WHEN TO_DATE('12/12/2021','DD/MM/YYYY') > TO_DATE('12/12/2020','DD/MM/YYYY') THEN 0 ELSE 1 END STATUS FROM DUAL
   
   
   SELECT TO_CHAR(PAYABLEDATE,'DD/MM/YYYY')  PYMT_DATE, SUM(NETPAY) AMOUNT  FROM WPSCASHOTPAYMENTDETAILS A WHERE 1=1 AND A.COMPANYCODE='0003'  AND A.DIVISIONCODE='0032'  AND  PAYABLEDATE BETWEEN TO_DATE('12/01/2021','DD/MM/YYYY') AND TO_DATE('26/03/2021','DD/MM/YYYY')  
   
   
   
   SET DEFINE OFF;
Insert into ROLEDETAILS
   (COMPANYCODE, DIVISIONCODE, ROLEID, BTNID, BTNNAME, SERIALNO, ACTIVE, PRINT, FORMTAG, FORMNAME)
 Values
   ('0003', '0032', '1', 'btnOTPaymentRpt', 'OT Payment', 
    1407, 'Y', NULL, 'OSW SUMMARY', 'BioAttn.OTPaymentRpt');
COMMIT;


--------------------------------------------------------------------------------

SELECT TO_CHAR(PAYABLEDATE,'DD/MM/YYYY')  PYMT_DATE, SUM(NETPAY) AMOUNT  
FROM WPSCASHOTPAYMENTDETAILS A WHERE 1=1 AND A.COMPANYCODE='0003'  
AND A.DIVISIONCODE='0032'  
AND  PAYABLEDATE BETWEEN TO_DATE('12/01/2021','DD/MM/YYYY') AND TO_DATE('26/03/2021','DD/MM/YYYY')   
AND NVL(PAYMENTLOCK,'N')='N'  
GROUP BY PAYABLEDATE  
ORDER BY PYMT_DATE


 SELECT TO_CHAR(PAYABLEDATE,'DD/MM/YYYY') PYMT_DATE,TOKENNO TOKEN, WORKERNAME NAME,
 DEPARTMENTNAME DEPARTMENT,SHIFTCODE SHIFT, SUM(NETPAY) AMOUNT 
 FROM WPSCASHOTPAYMENTDETAILS A WHERE 1=1 AND A.COMPANYCODE='0003'  
 AND A.DIVISIONCODE='0032'  
 AND  PAYABLEDATE BETWEEN TO_DATE('16/02/2020','DD/MM/YYYY') AND TO_DATE('16/05/2021','DD/MM/YYYY')    
 GROUP BY PAYABLEDATE,DEPARTMENTNAME,SHIFTCODE,TOKENNO,WORKERNAME  ORDER BY PYMT_DATE
 
 
  SELECT TO_CHAR(PAYABLEDATE,'DD/MM/YYYY') PYMT_DATE,TOKENNO TOKEN, WORKERNAME NAME,
  DEPARTMENTNAME DEPARTMENT,SHIFTCODE SHIFT, NETPAY AMOUNT 
  FROM WPSCASHOTPAYMENTDETAILS 
  A WHERE 1=1 
  AND A.COMPANYCODE='0003'  AND A.DIVISIONCODE='0032'  
  AND  PAYABLEDATE BETWEEN TO_DATE('16/02/2020','DD/MM/YYYY') AND TO_DATE('16/05/2021','DD/MM/YYYY')    
--  GROUP BY PAYABLEDATE,DEPARTMENTNAME,SHIFTCODE, TOKENNO,WORKERNAME  
  ORDER BY PYMT_DATE
  
  
   SELECT TO_CHAR(PAYABLEDATE,'DD/MM/YYYY') PYMT_DATE, DEPARTMENTNAME DEPARTMENT, 
   NETPAY AMOUNT FROM WPSCASHOTPAYMENTDETAILS A 
   WHERE 1=1 AND A.COMPANYCODE='0003'  
   AND A.DIVISIONCODE='0032'  
   AND  PAYABLEDATE BETWEEN TO_DATE('16/02/2020','DD/MM/YYYY') AND TO_DATE('16/05/2021','DD/MM/YYYY')    
   GROUP BY PAYABLEDATE,DEPARTMENTNAME  
   ORDER BY PYMT_DATE
   
   
    SELECT TO_CHAR(PAYABLEDATE,'DD/MM/YYYY') PYMT_DATE, DEPARTMENTNAME DEPARTMENT,SUM(NETPAY) AMOUNT 
    FROM WPSCASHOTPAYMENTDETAILS A WHERE 1=1 AND A.COMPANYCODE='0003'  
    AND A.DIVISIONCODE='0032'  
    AND  PAYABLEDATE BETWEEN TO_DATE('16/02/2020','DD/MM/YYYY') AND TO_DATE('16/05/2021','DD/MM/YYYY')    
    GROUP BY TO_CHAR(PAYABLEDATE,'DD/MM/YYYY'),DEPARTMENTNAME  
    ORDER BY PYMT_DATE
    
--------------------------------------------------------------------------------

SELECT 'NOT PAID', SUM(NVL(NETPAY,0)) NOTPAID FROM WPSCASHOTPAYMENTDETAILS WHERE PAYMENTFROMDATE='25-DEC-2020' AND PAYMENTDATE IS NULL
UNION ALL
SELECT 'PAID   ',SUM(NVL(NETPAY,0)) PAID FROM WPSCASHOTPAYMENTDETAILS WHERE PAYMENTFROMDATE='25-DEC-2020' AND PAYMENTDATE IS NOT NULL

PAYMENTDATE


 SELECT TO_CHAR(PAYMENTDATE,'DD/MM/YYYY') PYMT_DATE, DEPARTMENTNAME DEPARTMENT, NETPAY AMOUNT 
 FROM WPSCASHOTPAYMENTDETAILS A 
 WHERE 1=1 
 AND A.COMPANYCODE='0003'  
 AND A.DIVISIONCODE='0032'  
 --AND  TRUNC(PAYMENTDATE) BETWEEN TO_DATE('17/02/2021','DD/MM/YYYY') AND TO_DATE('17/02/2021','DD/MM/YYYY')    ORDER BY PYMT_DATE
 AND  TRUNC(PAYMENTDATE) >= TO_DATE('17/02/2021','DD/MM/YYYY') 
 AND TRUNC(PAYMENTDATE) <=  TO_DATE('17/02/2021','DD/MM/YYYY')    ORDER BY PYMT_DATE
 
 
 
 
 
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------