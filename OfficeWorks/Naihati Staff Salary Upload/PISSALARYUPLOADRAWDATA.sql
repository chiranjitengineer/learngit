DROP TABLE NJMCL_WEB.PISSALARYUPLOADRAWDATA CASCADE CONSTRAINTS;

CREATE TABLE NJMCL_WEB.PISSALARYUPLOADRAWDATA
(
  COMPANYCODE   VARCHAR2(10 BYTE),
  DIVISIONCODE  VARCHAR2(10 BYTE),
  YEARCODE      VARCHAR2(10 BYTE),
  YEARMONTH     VARCHAR2(10 BYTE),
  UNITCODE      VARCHAR2(10 BYTE),
  CATEGORYCODE  VARCHAR2(10 BYTE),
  GRADECODE     VARCHAR2(10 BYTE),
  EMPLOYEECODE  VARCHAR2(10 BYTE),
  PFNO          VARCHAR2(30 BYTE),
  ATTN_SALD     NUMBER(10,2),
  NCP_DAYS      NUMBER(10,2),
  GROSSWAGES    NUMBER(15,2),
  PF_GROSS      NUMBER(15,2),
  PEN_GROSS     NUMBER(15,2),
  ESI_GROSS     NUMBER(15,2),
  PTAX_GROSS    NUMBER(15,2),
  PF_E          NUMBER(15,2),
  EPF           NUMBER(15,2),
  PF_C          NUMBER(15,2),
  PTAX          NUMBER(15,2),
  ESI_E         NUMBER(15,2),
  ESI_C         NUMBER(15,2),
  LOAN_MPL      NUMBER(15,2),
  LINT_MPL      NUMBER(15,2)
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
MONITORING;