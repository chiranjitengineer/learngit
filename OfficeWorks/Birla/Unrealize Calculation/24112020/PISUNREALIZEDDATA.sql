DROP TABLE PISUNREALIZEDDATA CASCADE CONSTRAINTS;

CREATE TABLE PISUNREALIZEDDATA
(
  COMPANYCODE         VARCHAR2(10 BYTE),
  DIVISIONCODE        VARCHAR2(10 BYTE),
  YEARCODE            VARCHAR2(10 BYTE),
  YEARMONTH           DATE,
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
  LASTMODIFIED        DATE                      DEFAULT SYSDATE,
  DOCNO               VARCHAR2(20 BYTE),
  DOCDATE             DATE,
  TRAN_SOURCE         VARCHAR2(20 BYTE)
) 