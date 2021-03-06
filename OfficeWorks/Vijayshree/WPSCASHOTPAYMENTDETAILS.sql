DROP TABLE FORTWILLIAM_WPS.WPSCASHOTPAYMENTDETAILS CASCADE CONSTRAINTS;

CREATE TABLE FORTWILLIAM_WPS.WPSCASHOTPAYMENTDETAILS
(
  COMPANYCODE      VARCHAR2(10 BYTE)            NOT NULL,
  DIVISIONCODE     VARCHAR2(10 BYTE)            NOT NULL,
  PAYMENTFROMDATE  DATE                         NOT NULL,
  PAYMENTTODATE    DATE                         NOT NULL,
  DEPARTMENTCODE   VARCHAR2(10 BYTE),
  DEPARTMENTNAME   VARCHAR2(50 BYTE),
  SHIFTCODE        VARCHAR2(1 BYTE),
  TOKENNO          VARCHAR2(10 BYTE),
  WORKERNAME       VARCHAR2(100 BYTE),
  WORKERSERIAL     VARCHAR2(10 BYTE)            NOT NULL,
  OTHOURS          NUMBER(18,2),
  OTAMOUNT         NUMBER(18,2),
  ESI_OT           NUMBER(18,2),
  NETPAY           NUMBER(18,2),
  PAYMENTLOCK      VARCHAR2(1 BYTE),
  ISTRANSFER       VARCHAR2(1 BYTE)
)
