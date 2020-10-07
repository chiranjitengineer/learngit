DROP VIEW BAGGAGE_WEB.ACTDSDETAILS;

/* Formatted on 10/6/2020 3:34:26 PM (QP5 v5.326) */
CREATE OR REPLACE FORCE VIEW BAGGAGE_WEB.ACTDSDETAILS
(
    SYSROWID,
    COMPANYCODE,
    DIVISIONCODE,
    DIVISIONCODEFOR,
    YEARCODE,
    SYSTEMVOUCHERNO,
    SYSTEMVOUCHERDATE,
    TRANSACTIONDATE,
    ACCODE,
    TDSTYPE,
    PERCENTAGE,
    BILLNO,
    BILLDATE,
    BILLAMOUNT,
    TOTALTDSAMOUNT,
    NETAMOUNT,
    SERVICETAXAMOUNT,
    EDUCATIONCESSAMOUNT,
    NETTDSAMOUNT,
    DRCR,
    TDSDEDUCTEDON,
    TRANSACTIONTYPE,
    MANUALAUTO,
    LASTMODIFIED,
    SYNCHRONIZED,
    CERTIFICATENO,
    CERTIFICATEDATE,
    WITHEFFECTFROM,
    PARTYCODE,
    HSEDUCATIONCESSAMOUNT,
    REFSYSTEMVOUCHERNO,
    NETPERCENTAGE,
    BSRCODE
)
AS
    SELECT SYSROWID,
           COMPANYCODE,
           DIVISIONCODE,
           DIVISIONCODEFOR,
           YEARCODE,
           SYSTEMVOUCHERNO,
           SYSTEMVOUCHERDATE,
           TRANSACTIONDATE,
           ACCODE,
           TDSTYPE,
           PERCENTAGE,
           BILLNO,
           BILLDATE,
           BILLAMOUNT,
           TOTALTDSAMOUNT,
           NETAMOUNT,
           NVL(SERVICETAXAMOUNT,0) SERVICETAXAMOUNT,
           NVL(EDUCATIONCESSAMOUNT,0) EDUCATIONCESSAMOUNT,
           NETTDSAMOUNT,
           DRCR,
           TDSDEDUCTEDON,
           TRANSACTIONTYPE,
           MANUALAUTO,
           LASTMODIFIED,
           SYNCHRONIZED,
           CERTIFICATENO,
           CERTIFICATEDATE,
           WITHEFFECTFROM,
           PARTYCODE,
           NVL(HSEDUCATIONCESSAMOUNT,0) HSEDUCATIONCESSAMOUNT,
           REFSYSTEMVOUCHERNO,
           NETPERCENTAGE,
           BSRCODE
      FROM ACTDSDETAILS_ENTRY
     WHERE DIVISIONCODE = DIVISIONCODEFOR;
