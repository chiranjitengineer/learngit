SELECT * FROM EMAIL_PARAMETERS

SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%email%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE='01070309'

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''


SELECT EMAILID,EMPLOYEENAME FROM PISEMPLOYEEMASTER
where emailid is not null


GTT_EMAIL_DATA


 select * from dba_network_acls;
 
 GTT_EMAIL_DATA
 
 SELECT COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, DEPARTMENTCODE, 
 SECTIONCODE, OCCUPATIONCODE, WORKERTYPECODE, WORKERCATEGORYCODE, SHIFTCODE, WORKERSERIAL, TOKENNO, 
 UNITCODE, SERIALNO, PAYMODE, HRS_RATE, ATTENDANCEHOURS, OVERTIMEHOURS, HOLIDAYHOURS, STLHOURS, 
 NIGHTALLOWANCEHOURS, LAYOFFHOURS, FBKHOURS, OTHERHOURS, PFADJHOURS, NPFADJHOURS, ACTUALPAYBLEAMOUNT, VBASIC
 FROM WPSWAGESDETAILS A,
 (
    SELECT TOKENNO FROM WPSWORKERMAST
 ) B
 WHERE A.TOKENNO=B.TOKENNO 
 