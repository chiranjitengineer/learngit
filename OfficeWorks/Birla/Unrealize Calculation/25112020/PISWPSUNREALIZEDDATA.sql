DROP TABLE BIRLANEW.PISWPSUNREALIZEDDATA CASCADE CONSTRAINTS;

CREATE TABLE BIRLANEW.PISWPSUNREALIZEDDATA
(
  COMPANYCODE         VARCHAR2(10 BYTE),
  DIVISIONCODE        VARCHAR2(10 BYTE),
  YEARCODE            VARCHAR2(10 BYTE),
  YEARMONTH           VARCHAR2(10),
  FORTNIGHTSTARTDATE  DATE,
  FORTNIGHTENDDATE    DATE,
  WORKERSERIAL        VARCHAR2(10 BYTE),
  TOKENNO             VARCHAR2(10 BYTE),
  COMPONENTCODE       VARCHAR2(10 BYTE),
  COMPONENTAMOUNT     NUMBER(11,2),
  ACTUALAMOUNT        NUMBER(11,2),
  REFERENCE_FNEDATE   DATE,
  PAIDON              DATE,
  TRANTYPE            VARCHAR2(10 BYTE),
  MODULE              VARCHAR2(10 BYTE),
  REMARKS             VARCHAR2(100 BYTE),
  USERNAME            VARCHAR2(50 BYTE),
  SYSROSWID           VARCHAR2(50 BYTE),
  LASTMODIFIED        DATE,
  DOCNO               VARCHAR2(20 BYTE),
  DOCDATE             DATE,
  TRAN_SOURCE         VARCHAR2(20 BYTE)
)