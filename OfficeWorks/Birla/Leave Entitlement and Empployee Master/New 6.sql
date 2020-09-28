DROP TABLE BIRLANEW.GBL_PISEMPLOYEEMASTER CASCADE CONSTRAINTS;

--CREATE GLOBAL TEMPORARY TABLE BIRLANEW.GBL_PISEMPLOYEEMASTER
CREATE  TABLE BIRLANEW.GBL_PISEMPLOYEEMASTER
(
  AADHARNO                 VARCHAR2(50 BYTE),
  ACADEMICQUALIFICATION    VARCHAR2(200 BYTE),
  ADDRESS_PERMANENT        VARCHAR2(200 BYTE),
  ADDRESS_PRESENT          VARCHAR2(200 BYTE),
  ATTNIDENTIFICATION       VARCHAR2(50 BYTE),
  BANKACCHOLDINGNAME       VARCHAR2(100 BYTE),
  BANKACCNUMBER            VARCHAR2(20 BYTE),
  BANKCODE                 VARCHAR2(10 BYTE),
  BONUSAPPLICABLE          VARCHAR2(1 BYTE),
  BOSSCODE                 VARCHAR2(10 BYTE),
  CATEGORYCODE             VARCHAR2(10 BYTE),
  CITY_PERMANENT           VARCHAR2(50 BYTE),
  CITY_PRESENT             VARCHAR2(50 BYTE),
  COMPANYCODE              VARCHAR2(10 BYTE),
  COSTCENTRECODE           VARCHAR2(10 BYTE),
  DATEOFBIRTH              DATE,
  DATEOFCONFIRMATION       DATE,
  DATEOFJOIN               DATE,
  DATEOFRETIRE             DATE,
  DATEOFTERMINATIONADVICE  DATE,
  DEPARTMENTCODE           VARCHAR2(10 BYTE),
  DESIGNATIONCODE          VARCHAR2(10 BYTE),
  DIVISIONCODE             VARCHAR2(10 BYTE),
  EMAILID                  VARCHAR2(50 BYTE),
  EMPLOYEENAME             VARCHAR2(50 BYTE),
  EMPLOYEESTATUS           VARCHAR2(20 BYTE),
  EPFAPPLICABLE            VARCHAR2(1 BYTE),
  ESINO                    VARCHAR2(20 BYTE),
  EXTENDEDRETIREDATE       DATE,
  FATHERNAME               VARCHAR2(40 BYTE),
  GRADECODE                VARCHAR2(10 BYTE),
  GRATUITYAPPLICABLE       VARCHAR2(1 BYTE),
  GRATUITYOPENINGYEARS     NUMBER(6,2),
  GRATUITYSETTELMENTDATE   DATE,
  GUARDIANNAME             VARCHAR2(40 BYTE),
  IFSCCODE                 VARCHAR2(20 BYTE),
  LEAVINGSERVICE           VARCHAR2(50 BYTE),
  MARITIALSTATUS           VARCHAR2(1 BYTE),
  MOBILENO                 VARCHAR2(20 BYTE),
  MODULE                   VARCHAR2(10 BYTE),
  OPERATIONMODE            VARCHAR2(1 BYTE),
  PANCARDNO                VARCHAR2(10 BYTE),
  PAYMENTSTATUS            VARCHAR2(40 BYTE),
  PAYMODE                  VARCHAR2(10 BYTE),
  PENSIONNO                VARCHAR2(20 BYTE),
  PFACCODE                 VARCHAR2(10 BYTE),
  PFAPPLICABLE             VARCHAR2(1 BYTE),
  PFCODE                   VARCHAR2(10 BYTE),
  PFENTITLEDATE            DATE,
  PFNO                     VARCHAR2(20 BYTE),
  PFSETTELMENTDATE         DATE,
  PHONE                    VARCHAR2(20 BYTE),
  PIN_PERMANENT            VARCHAR2(10 BYTE),
  PIN_PRESENT              VARCHAR2(10 BYTE),
  PROFESSIONQUALIFICATION  VARCHAR2(200 BYTE),
  PTAXAPPLICABLE           VARCHAR2(1 BYTE),
  QUARTERALLOTED           VARCHAR2(3 BYTE),
  QUARTERNO                VARCHAR2(50 BYTE),
  REMARKS                  VARCHAR2(100 BYTE),
  SEX                      VARCHAR2(10 BYTE),
  SNFACCODE                VARCHAR2(100 BYTE),
  SPOUSENAME               VARCHAR2(40 BYTE),
  STATE_PERMANENT          VARCHAR2(50 BYTE),
  STATE_PRESENT            VARCHAR2(50 BYTE),
  STATUSDATE               DATE,
  SYSROWID                 VARCHAR2(50 BYTE),
  TOKENNO                  VARCHAR2(10 BYTE),
  UANNO                    VARCHAR2(50 BYTE),
  UNITCODE                 VARCHAR2(10 BYTE),
  VOTERID                  VARCHAR2(20 BYTE),
  WORKERSERIAL             VARCHAR2(10 BYTE),
  USERNAME                 VARCHAR2(100 BYTE),
  PTAXSTATE                VARCHAR2(100 BYTE),
  GRATUITYNUMBER           VARCHAR2(30 BYTE),
  PRANNUMBER               VARCHAR2(30 BYTE),
  RELIGION                 VARCHAR2(30 BYTE),
  SUPERANUATIONDATE        DATE,
  SUPERANUATIONNUMBER      VARCHAR2(30 BYTE)
)

ON COMMIT DELETE ROWS
NOCACHE;


CREATE OR REPLACE TRIGGER BIRLANEW.TRG_SYSROWID_00000000000001682 
 before insert ON BIRLANEW.GBL_PISEMPLOYEEMASTER for each row
declare 
    wlastnumber  number(11); 
    wsysrowid    varchar2(30); 
 begin    
 if nvl(:new.sysrowid,'~N~') ='~N~' or upper(:new.sysrowid) = 'NULL' then 
    select seq_sysrowid.nextval 
    into wlastnumber 
    from dual;     
    wsysrowid := to_char(sysdate,'YYYYMMDDHH24MISS') || lpad(wlastnumber,10,'0');
   :new.sysrowid := wsysrowid;  
end if;
 end;
/
