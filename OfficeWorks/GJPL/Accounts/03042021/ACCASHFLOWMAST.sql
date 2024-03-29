CREATE TABLE ACCASHFLOWMAST
(
  SYSROWID               VARCHAR2(50 BYTE),
  COMPANYCODE            VARCHAR2(50 BYTE),
  LOCATIONCODE           VARCHAR2(50 BYTE),
  CASHFLOWCODE           VARCHAR2(50 BYTE),
  CASHFLOWDESC           VARCHAR2(50 BYTE),
  CASHFLOWGROUPCODE      VARCHAR2(50 BYTE),
  ISDEFAULTCASHFLOWCODE  VARCHAR2(50 BYTE),
  CASHFLOWNAME           VARCHAR2(100 BYTE),
  LASTMODIFIED           DATE                   DEFAULT SYSDATE,
  SYNCHRONIZED           VARCHAR2(50 BYTE)      DEFAULT 'N',
  USERNAME               VARCHAR2(50 BYTE)
)