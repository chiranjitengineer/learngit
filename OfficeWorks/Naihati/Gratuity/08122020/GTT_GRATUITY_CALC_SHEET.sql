DROP TABLE GTT_GRATUITY_CALC_SHEET CASCADE CONSTRAINTS;

CREATE TABLE NJMCL_WEB.GTT_GRATUITY_CALC_SHEET
(
    WORKERNAME            VARCHAR2(150 BYTE),
    EBNO                  VARCHAR2(30 BYTE),
    PFNO                  VARCHAR2(20 BYTE),
    TOKENNO               VARCHAR2(10 BYTE),
    ESINO                 VARCHAR2(20 BYTE),
    OCCUPATIONNAME        VARCHAR2(100 BYTE),
    DEPARTMENTNAME        VARCHAR2(50 BYTE),
    EMPLOYEE_NATURE       VARCHAR2(30 BYTE),
    SUPPERANNUATION_TYPE  VARCHAR2(30 BYTE),
    DATEOFJOINING         DATE,
    SUPPERANNUATION_DATE  DATE,
    LASTPAYMENTDATE       DATE,
    SERVICEPERIOD         VARCHAR2(4000 BYTE),
    PAY_DATE              DATE,
    TOTAL_DAYS            NUMBER,
    TOTAL_HRS             NUMBER,
    BASIC                 NUMBER,
    A_BASIC               NUMBER,
    FE                    NUMBER,
    DA                    NUMBER,
    NS_ALLOW              NUMBER,
    ADHOC                 NUMBER,
    TSA                   NUMBER,
    GROSS_EARN            NUMBER,
    PERDAY_EARN           NUMBER,
    COMPANYCODE           VARCHAR2(10 BYTE),
    DIVISIONCODE          VARCHAR2(10 BYTE),
    COMPANYNAME           CHAR(36 BYTE),
    DIVISIONNAME          CHAR(4 BYTE),
    REPORTTYPE            CHAR(8 BYTE),
    DAILY_EARNING          NUMBER(18,2),
    SAL_15DAYS            NUMBER(18,2),
    SERVICEYEAR          NUMBER(18,2),
    NONCONT_YEAR          NUMBER(18,2),
    GRAYUITY_YEAR          NUMBER(18,2),
    GRATUITYAMOUNT        NUMBER(15,2),
    AMOUNT_INWORDS               VARCHAR2(4000 BYTE),
    REPORTNAME            CHAR(27 BYTE)
)


DAILY_EARNING, SAL_15DAYS, SERVICEYEAR, NONCONT_YEAR, GRAYUITY_YEAR, GRATUITY_AMT,AMOUNT_INWORDS