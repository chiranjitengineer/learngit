DROP VIEW ACACLEDGER_VW_ALL;

/* Formatted on 03/04/2021 1:40:22 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW ACACLEDGER_VW_ALL
(
   COMPANYCODE,
   DIVISIONCODE,
   ACCODE,
   ACHEAD,
   ACSHORTDESCRIPTION,
   ACTYPE,
   MAINGROUPCODE,
   GROUPTYPE,
   ADDRESS1,
   ADDRESS2,
   ADDRESS3,
   CITY,
   STATE,
   COUNTRY,
   PIN,
   PHONEMOBILE,
   PHONEOFFICE,
   PHONERESIDENCE,
   FAX,
   EMAIL,
   PANGIR2,
   MARK,
   OPENINGBALANCE,
   DRCR,
   LASTMODIFIED,
   PANGIR1,
   COSTCENTREALLOWED,
   EFFECTIVECOSTCENTRES,
   TDSNATURE,
   ISTDSAPPLICABLE,
   ISSERVICETAXAPPLICABLE,
   VATNUMBER,
   SALESTAXNUMBER,
   ISCOMPANY,
   BANKACCOUNTNO,
   SHOWINTRANSACTIONS,
   ACCOUNTTYPE,
   BANKNAME,
   CONTINUOUSCHEQUESTATIONARY,
   CONTRAVOUCHERPREFIX,
   ISSURCHARGEAPPLICABLE,
   PAYMENTVOUCHERPREFIX,
   PROJECTNAME,
   PROJECTNAMESOE,
   RECEIPTVOUCHERPREFIX,
   SHOWINBANKBALANCE,
   SOECODE,
   SOEGROUPCODE,
   SOEGROUPCODE_ADVANCE,
   SOEGROUPCODE_LIABILITY,
   SYNCHRONIZED,
   SYSROWID,
   SUPERKEYCODE,
   SUPERKEYNAME,
   PARTYTYPE,
   VOUCHERPAYMENTRECEIPTTYPE,
   USERNAME,
   BSRCODE,
   BRANCHCODE,
   IFSC,
   ADCODE,
   CURRENCY,
   BANKTYPE,
   FORADVANCEBOOKING,
   PAYMENTLIMIT,
   GSTAPPLICABLE,
   GST_I_O_TYPE,
   IS_REGISTERED,
   GST_STATECODE,
   GSTN,
   GSTNATURE
)
AS
   SELECT   COMPANYCODE,
            DIVISIONCODE,
            ACCODE,
            ACHEAD,
            ACSHORTDESCRIPTION,
            ACTYPE,
            MAINGROUPCODE,
            GROUPTYPE,
            ADDRESS1,
            ADDRESS2,
            ADDRESS3,
            CITY,
            STATE,
            COUNTRY,
            PIN,
            PHONEMOBILE,
            PHONEOFFICE,
            PHONERESIDENCE,
            FAX,
            EMAIL,
            PANGIR2,
            MARK,
            OPENINGBALANCE,
            DRCR,
            LASTMODIFIED,
            PANGIR1,
            COSTCENTREALLOWED,
            EFFECTIVECOSTCENTRES,
            TDSNATURE,
            ISTDSAPPLICABLE,
            ISSERVICETAXAPPLICABLE,
            VATNUMBER,
            SALESTAXNUMBER,
            ISCOMPANY,
            BANKACCOUNTNO,
            SHOWINTRANSACTIONS,
            ACCOUNTTYPE,
            BANKNAME,
            CONTINUOUSCHEQUESTATIONARY,
            CONTRAVOUCHERPREFIX,
            ISSURCHARGEAPPLICABLE,
            PAYMENTVOUCHERPREFIX,
            PROJECTNAME,
            PROJECTNAMESOE,
            RECEIPTVOUCHERPREFIX,
            SHOWINBANKBALANCE,
            SOECODE,
            SOEGROUPCODE,
            SOEGROUPCODE_ADVANCE,
            SOEGROUPCODE_LIABILITY,
            SYNCHRONIZED,
            SYSROWID,
            SUPERKEYCODE,
            SUPERKEYNAME,
            PARTYTYPE,
            VOUCHERPAYMENTRECEIPTTYPE,
            USERNAME,
            BSRCODE,
            BRANCHCODE,
            IFSC,
            ADCODE,
            CURRENCY,
            BANKTYPE,
            FORADVANCEBOOKING,
            PAYMENTLIMIT,
            GSTAPPLICABLE,
            GST_I_O_TYPE,
            IS_REGISTERED,
            GST_STATECODE,
            GSTN,
            GSTNATURE
     FROM   ACACLEDGER;
