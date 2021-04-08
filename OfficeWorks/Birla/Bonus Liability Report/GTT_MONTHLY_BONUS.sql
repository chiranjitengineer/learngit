DROP TABLE GTT_MONTHLY_BONUS CASCADE CONSTRAINTS;

CREATE GLOBAL TEMPORARY TABLE GTT_MONTHLY_BONUS
(
  WORKERSERIAL  VARCHAR2(10 BYTE),
  TOKENNO       VARCHAR2(20 BYTE),
  APR_AMT           NUMBER(15,2),
  MAY_AMT           NUMBER(15,2),
  JUN_AMT           NUMBER(15,2),
  JUL_AMT           NUMBER(15,2),
  AUG_AMT           NUMBER(15,2),
  SEP_AMT           NUMBER(15,2),
  OCT_AMT           NUMBER(15,2),
  NOV_AMT           NUMBER(15,2),
  DEC_AMT           NUMBER(15,2),
  JAN_AMT           NUMBER(15,2),
  FEB_AMT           NUMBER(15,2),
  MAR_AMT           NUMBER(15,2),
  ---------------------------------
  APR_BONUS           NUMBER(15,2),
  MAY_BONUS           NUMBER(15,2),
  JUN_BONUS           NUMBER(15,2),
  JUL_BONUS           NUMBER(15,2),
  AUG_BONUS           NUMBER(15,2),
  SEP_BONUS           NUMBER(15,2),
  OCT_BONUS           NUMBER(15,2),
  NOV_BONUS           NUMBER(15,2),
  DEC_BONUS           NUMBER(15,2),
  JAN_BONUS           NUMBER(15,2),
  FEB_BONUS           NUMBER(15,2),
  MAR_BONUS           NUMBER(15,2)
)
