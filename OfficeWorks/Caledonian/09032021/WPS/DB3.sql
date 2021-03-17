DROP TABLE PFEMPLOYEEMASTER CASCADE CONSTRAINTS;

CREATE TABLE PFEMPLOYEEMASTER
(
  COMPANYCODE           VARCHAR2(10 BYTE)       DEFAULT 'NJ0002',
  DIVISIONCODE          VARCHAR2(10 BYTE)       DEFAULT '0010',
  CURRENTCOMPANYCODE    VARCHAR2(10 BYTE),
  CURRENTDIVISIONCODE   VARCHAR2(10 BYTE),
  PFTRUSTCODE           VARCHAR2(10 BYTE),
  PFNO                  VARCHAR2(20 BYTE),
  PENSIONNO             VARCHAR2(20 BYTE),
  GRATUITYNO            VARCHAR2(20 BYTE),
  WORKERSERIAL          VARCHAR2(10 BYTE),
  TOKENNO               VARCHAR2(10 BYTE),
  EMPLOYEENAME          VARCHAR2(50 BYTE),
  FATHERNAME            VARCHAR2(50 BYTE),
  GUARDIANNAME          VARCHAR2(50 BYTE),
  EMPLOYEEMARRIED       VARCHAR2(10 BYTE),
  SEX                   VARCHAR2(10 BYTE),
  SPOUSENAME            VARCHAR2(50 BYTE),
  CATEGORYCODE          VARCHAR2(10 BYTE),
  GRADECODE             VARCHAR2(10 BYTE),
  DEPARTMENTCODE        VARCHAR2(10 BYTE),
  DESIGNATIONCODE       VARCHAR2(10 BYTE),
  DATEOFBIRTH           DATE,
  DATEOFJOINING         DATE,
  PFJOINDATE            DATE,
  PFSETTLEMENTDATE      DATE,
  SEPARATIONDATE        DATE,
  SEPARATIONADVICEDATE  DATE,
  FORM3CEASEDATE        DATE,
  FORM3RECEIPTDATE      DATE,
  STATUSDATE            DATE,
  PFCATEGORY            VARCHAR2(1 BYTE),
  BASIC                 NUMBER(18,4),
  DA                    NUMBER(18,4),
  ADHOC                 NUMBER(11,2),
  PFGROSS               NUMBER(11,2),
  BASICRATEONHOURS      NUMBER(18,2),
  EMPLOYEESTATUS        VARCHAR2(20 BYTE),
  ADDRESS               VARCHAR2(250 BYTE),
  MODULE                VARCHAR2(10 BYTE),
  ENTERBY               VARCHAR2(20 BYTE),
  REMARKS               VARCHAR2(100 BYTE),
  CONTRACTORNO          VARCHAR2(10 BYTE),
  CITY                  VARCHAR2(50 BYTE),
  RELIGION              VARCHAR2(20 BYTE),
  ESINO                 VARCHAR2(20 BYTE),
  PIN                   VARCHAR2(8 BYTE),
  BANKCODE              VARCHAR2(30 BYTE),
  IFSCCODE              VARCHAR2(30 BYTE),
  BANKACCNO             VARCHAR2(30 BYTE),
  MOBILENO              VARCHAR2(30 BYTE),
  WORKERCODE            VARCHAR2(10 BYTE),
  AADHAARNO             VARCHAR2(20 BYTE),
  UANNO                 VARCHAR2(20 BYTE),
  ISOPERATIVE           VARCHAR2(2 BYTE)        DEFAULT 'Y',
  EMPLOYEENAME_BANK     VARCHAR2(100 BYTE),
  LASTMODIFIED          DATE,
  USERNAME              VARCHAR2(50 BYTE),
  SYSROWID              VARCHAR2(50 BYTE)
)

TABLESPACE NJMCL_WEB
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


CREATE UNIQUE INDEX PFEMPLOYEEMASTER_U01 ON PFEMPLOYEEMASTER
(PFNO)
LOGGING

TABLESPACE NJMCL_WEB
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE UNIQUE INDEX PFEMPLOYEEMASTER_U02 ON PFEMPLOYEEMASTER
(TOKENNO)
LOGGING

TABLESPACE NJMCL_WEB
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


ALTER TABLE PFEMPLOYEEMASTER ADD (
  CONSTRAINT PFEMPLOYEEMASTER_U02
 UNIQUE (TOKENNO) 
    USING INDEX         
    TABLESPACE CJIL_WEB
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ),
  CONSTRAINT PFEMPLOYEEMASTER_U01
 UNIQUE (PFNO)
    USING INDEX 
    TABLESPACE CJIL_WEB
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));
