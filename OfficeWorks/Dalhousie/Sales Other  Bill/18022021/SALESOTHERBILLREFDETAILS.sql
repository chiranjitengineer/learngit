DROP TABLE SALESOTHERBILLREFDETAILS CASCADE CONSTRAINTS;

CREATE TABLE SALESOTHERBILLREFDETAILS
(
  CHANNELCODE        VARCHAR2(100 BYTE)         NOT NULL,
  SCRAPSALEBILLNO    VARCHAR2(30 BYTE),
  SCRAPSALEBILLDATE  DATE,
  SALEBILLNO         VARCHAR2(30 BYTE)          NOT NULL,
  SALEBILLDATE       DATE,
  PARTYCODE          VARCHAR2(10 BYTE),
  COMPANYCODE        VARCHAR2(10 BYTE)          NOT NULL,
  DIVISIONCODE       VARCHAR2(10 BYTE)          NOT NULL,
  YEARCODE           VARCHAR2(9 BYTE)           NOT NULL,
  USERNAME           VARCHAR2(100 BYTE)         NOT NULL,
  SYSROWID           VARCHAR2(50 BYTE)          NOT NULL,
  LASTMODIFIED       DATE                       DEFAULT SYSDATE
)