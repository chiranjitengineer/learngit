select * from menumaster_rnd
where menudesc like 'Pay%Dhun%'

select * from menumaster_rnd
where menucode like '011004020301%'

PAY SLIP DETAILS(DHUNSERI)

WAGES REGISTER(TEXT REPORT) DHUNSERI

PROC_RPT_PAYSLIP_DHUNSERI

select * from gps_error_log


PROC_WAGES_REGISTER_STDFRMT


PROC_RPT_PAYSLIP_DHUNSERI('DT0079','0012','11/10/2020','24/24/2020','',

SELECT * FROM GPSPAYSHEETDETAILS
WHERE PERIODFROM BETWEEN '11-OCT-2020' AND '24-OCT-2020'
AND CLUSTERCODE='M01'
AND TOKENNO='A0026'

 SELECT TOKENNO, WORKERSERIAL, SUM(HAZIRA) PRESENTDAYS FROM GPSATTENDANCEDETAILS
    WHERE ATTENDANCEDATE BETWEEN '11-OCT-2020' AND '24-OCT-2020'
    AND CLUSTERCODE='M01'
    AND TOKENNO='A0026'
    AND OCCOUPATIONTYPE IN ('TUBE FILLING','PLUCKING','OTHERS')
    GROUP BY TOKENNO, WORKERSERIAL
    
    
UPDATE GTT_PAYSLIP_DHUNSERI A
SET PAYDAYS = NVL((
    SELECT SUM(HAZIRA) PRESENTDAYS FROM GPSATTENDANCEDETAILS
    WHERE ATTENDANCEDATE BETWEEN '11-OCT-2020' AND '24-OCT-2020'
    AND OCCOUPATIONTYPE IN ('TUBE FILLING','PLUCKING','OTHERS')
    AND WORKERSERIAL =  A.WORKERSERIAL
),0);




SELECT DISTINCT OCCUPATIONTYPE FROM GPSOCCUPATIONMAST 
WHERE COMPANYCODE = 'DT0079'
AND DIVISIONCODE = '0012'


GPSATTENDANCEDETAILS


(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_FROMDATE     VARCHAR2,
    P_TODATE       VARCHAR2,
    P_CATEGORY       VARCHAR2 DEFAULT NULL,
    P_CLUSTER       VARCHAR2 DEFAULT NULL,
    P_ATTNBOOK       VARCHAR2 DEFAULT NULL,
     
    
    GPSATTENDANCEDETAILS