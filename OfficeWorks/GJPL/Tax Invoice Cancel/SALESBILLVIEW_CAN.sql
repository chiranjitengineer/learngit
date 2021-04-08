
CREATE OR REPLACE FORCE VIEW SALESBILLVIEW_CAN
(
   CHANNELCODE,
   SALEBILLNO,
   SALEBILLDATE,
   BROKERCODE,
   BUYERCODE,
   NETAMOUNT,
   NETINDIANAMOUNT,
   GROSSAMOUNT,
   YEARCODE,
   COMPANYCODE,
   DIVISIONCODE,
   EXCISEINVNO,
   EXCISEINVDATE,
   PROFORMAINVNO,
   PROFORMAINVDATE,
   SHIPPINGINSNO,
   SHIPPINGINSDATE,
   SAUDANO,
   SAUDADATE,
   NOOFPACKINGUNIT,
   TOTALQUANTITY,
   TOTALWEIGHT,
   PACKSHEETWEIGHT,
   GROSSWEIGHT,
   EXPORTWEIGHT,
   CONTAINERSIZE,
   TOTALAMOUNT,
   TOTALINDIANAMOUNT,
   NOFROM,
   NOTO,
   SAUDASERIALNO,
   SHIPPINGSERIALNO,
   PROFORMASERIALNO,
   EXCISESERIALNO,
   BILLSERIALNO,
   TRANSPORTERCODE,
   VESSELFLIGHTNO,
   DESTINATION,
   BOOKING,
   CONTAINERNO,
   CNOTENO,
   CNOTEDATE,
   SEALNO,
   FORM1NO,
   RENO,
   REMOVALDATE,
   TIMEOFPREPARATION,
   EXAPPLICABLE,
   EXFROM,
   EXTO,
   REMARKSPRO,
   ADDRESSCODE,
   COUNTRYOFFINALDESTINATION,
   PRECARRIAGE,
   VESSELORFLIGHT,
   PORTOFDISCHARGE,
   PAYMENTCONDITION,
   PLACEOFRECEIPT,
   PORTOFLOADING,
   FINALDESTINATION,
   COUNTRYOFORIGIN,
   QUALITYCODE,
   DELIVERYQUALITYDESC,
   PACKINGCODE,
   PACKINGNAME,
   PACKINGSHORTNAME,
   PACKINGWEIGHT,
   PACKSTYLECODE,
   PACKSTYLENAME,
   UORCODE,
   UORNAME,
   NOCALCULATION,
   RATE,
   INDIANRATE,
   BUYERNAME,
   BROKERNAME,
   QUALITYTYPE,
   PACKINGQUANTITY,
   MEASURECODE,
   MEASURENAME,
   CURRENCYCODE,
   CURRENCYDESC,
   CURRENCYSYMBOL,
   CONTRACTNO,
   CONTRACTDATE,
   REMARKS,
   UNITQUANTITY,
   BROKERAGEPER,
   TDSPER,
   INSPECTIONNO,
   INSPECTIONDATE,
   CHALLANNO,
   SONO,
   CHANNELTAG,
   DESTINATIONFROMTO,
   BANKCODE,
   BANKNAME,
   BANKADDRESS,
   ACNO,
   DEFAULTBANK,
   EXCHANGERATE,
   BILLOFLOADINGNO,
   MATERECEIPTNO,
   SHIPPINGBILLNO,
   SHIPPINGBILLDATE,
   MATERECEIPTDATE,
   BILLOFLOADINGDATE,
   CUSTOMINVNO,
   CUSTOMINVDATE,
   CUSTOMSERIALNO,
   GROSSAMOUNTINR,
   BILLTYPE,
   GOVTQUALITYDESC,
   VEHICLENO,
   OLDREFERENCENOGP,
   ENTEREDBY,
   ENTEREDON,
   AMMENDMENTNO,
   FREIGHTPAIDAT,
   QUALITYMANUALDESC,
   TOTALQUANTITYYDS,
   MARKS,
   CONSIGNEECODE,
   CONSIGNEEADDRESSCODE,
   SYSROWID,
   CIPAYMENTTERMS,
   PRICETYPE,
   RRIWB,
   MEASUREUNIT,
   WHICHFIELD,
   EXCHANGERATEBL,
   QUALITYGROUPCODE,
   SUPPLYORDERNO,
   SUPPORDERDATE,
   HEADACCNTNAME,
   ISFCIPARTY,
   LCNO,
   LCDATE,
   VOYNO,
   INDENTORNAME,
   INDENTORADDRESS,
   HEADACCNTADDRESS,
   IFSCCODE,
   LETTERNOANDDATE,
   BROKERAGECOMM,
   BUYERORDERNO,
   BUYERORDERDATE,
   SUBMISSIONDATE,
   REFEXCISEINVNO,
   REFEXCISEINVDATE,
   EXCISEGROUPCODE,
   EXCISEREMARKS,
   SHIPSTATECODE,
   ADDRESSCODEBILL,
   BILLSTATECODE,
   BILLEXCHANGERATE,
   DOCUMENTTYPE,
   AGAINSTINVNO,
   AGAINSTINVDATE,
   EXCHANGERATESB,
   FOBVALUE_FC_CM,
   BENEFITTYPE,
   EWAYBILLNO,
   EWAYBILLDATE,
   TIME_STAMP,
   LOCATOR,
   EPCGLICENSENO,
   EPCGLICENSEDATE,
   FREIGHTPAYMENT,
   INSURANCETYPE
)
AS
   SELECT                                                       /*+ ORDERED */
         M  .CHANNELCODE,
            M.SALEBILLNO,
            M.SALEBILLDATE,
            M.BROKERCODE,
            M.BUYERCODE,
            M.NETAMOUNT,
            M.NETINDIANAMOUNT,
            M.GROSSAMOUNT,
            M.YEARCODE,
            M.COMPANYCODE,
            M.DIVISIONCODE,
            D.EXCISEINVNO,
            D.EXCISEINVDATE,
            D.PROFORMAINVNO,
            D.PROFORMAINVDATE,
            D.SHIPPINGINSNO,
            D.SHIPPINGINSDATE,
            D.SAUDANO,
            D.SAUDADATE,
            D.NOOFPACKINGUNIT,
            D.TOTALQUANTITY,
            D.TOTALWEIGHT,
            D.PACKSHEETWEIGHT,
            D.GROSSWEIGHT,
            D.EXPORTWEIGHT,
            D.CONTAINERSIZE,
            D.TOTALAMOUNT,
            D.TOTALINDIANAMOUNT,
            D.NOFROM,
            D.NOTO,
            D.SAUDASERIALNO,
            D.SHIPPINGSERIALNO,
            D.PROFORMASERIALNO,
            D.EXCISESERIALNO,
            D.BILLSERIALNO,
            PV.TRANSPORTERCODE,
            M.VESSELFLIGHTNO,
            PV.DESTINATION,
            PV.BOOKING,
            PV.CONTAINERNO,
            PV.CNOTENO,
            PV.CNOTEDATE,
            PV.SEALNO,
            PV.FORM1NO,
            PV.RENO,
            PV.REMOVALDATE,
            PV.TIMEOFPREPARATION,
            PV.EXAPPLICABLE,
            PV.EXFROM,
            PV.EXTO,
            PV.REMARKSPRO,
            M.ADDRESSCODE,
            PV.COUNTRYOFFINALDESTINATION,
            PV.PRECARRIAGE,
            PV.VESSELORFLIGHT,
            PV.PORTOFDISCHARGE,
            PV.PAYMENTCONDITION,
            PV.PLACEOFRECEIPT,
            PV.PORTOFLOADING,
            PV.FINALDESTINATION,
            PV.COUNTRYOFORIGIN,
            PV.QUALITYCODE,
            PV.QUALITYMANUALDESC DELIVERYQUALITYDESC,
            PV.PACKINGCODE,
            PV.PACKINGNAME,
            PV.PACKINGSHORTNAME,
            PV.PACKINGWEIGHT,
            PV.PACKSTYLECODE,
            PV.PACKSTYLENAME,
            PV.UORCODE,
            PV.UORNAME,
            PV.NOCALCULATION,
            D.RATE,
            D.INDIANRATE,
            PV.BUYERNAME,
            PV.BROKERNAME,
            PV.QUALITYTYPE,
            PV.PACKINGQUANTITY,
            PV.MEASURECODE,
            PV.MEASURENAME,
            PV.CURRENCYCODE,
            PV.CURRENCYDESC,
            PV.CURRENCYSYMBOL,
            PV.CONTRACTNO,
            PV.CONTRACTDATE,
            M.REMARKS,
            PV.UNITQUANTITY,
            M.BROKERAGEPER,
            M.TDSPER,
            M.INSPECTIONNO,
            M.INSPECTIONDATE,
            PV.CHALLANNO,
            PV.SONO,
            PV.CHANNELTAG,
            M.DESTINATIONFROMTO,
            B.BANKCODE,
            B.BANKNAME,
            B.BANKADDRESS,
            B.ACNO,
            B.DEFAULTBANK,
            M.EXCHANGERATE,
            M.BILLOFLOADINGNO,
            M.MATERECEIPTNO,
            M.SHIPPINGBILLNO,
            M.SHIPPINGBILLDATE,
            M.MATERECEIPTDATE,
            M.BILLOFLOADINGDATE,
            D.CUSTOMINVNO,
            D.CUSTOMINVDATE,
            D.CUSTOMSERIALNO,
            M.GROSSAMOUNTINR,
            M.BILLTYPE,
            M.GOVTQUALITYDESC,
            PV.VEHICLENO,
            NULL OLDREFERENCENOGP,
            M.ENTEREDBY,
            M.ENTEREDON,
            M.AMMENDMENTNO,
            M.FREIGHTPAIDAT,
            D.QUALITYMANUALDESC,
            D.TOTALQUANTITYYDS,
            PV.MARKS,
            M.CONSIGNEECODE,
            M.CONSIGNEEADDRESSCODE,
            D.SYSROWID,
            M.CIPAYMENTTERMS,
            PV.PRICETYPE,
            M.RRIWB,
            PV.MEASUREUNIT,
            PV.WHICHFIELD,
            M.EXCHANGERATEBL,
            PV.QUALITYGROUPCODE,
            PV.SUPPLYORDERNO,
            PV.SUPPORDERDATE,
            PV.HEADACCNTNAME,
            PV.ISFCIPARTY,
            M.LCNO,
            M.LCDATE,
            M.VOYNO,
            PV.INDENTORNAME,
            PV.INDENTORADDRESS,
            PV.HEADACCNTADDRESS,
            B.IFSCCODE,
            M.LETTERNOANDDATE,
            PV.BROKERAGECOMM,
            PV.BUYERORDERNO,
            PV.BUYERORDERDATE,
            M.SUBMISSIONDATE,
            PV.REFEXCISEINVNO,
            PV.REFEXCISEINVDATE,
            PV.EXCISEGROUPCODE,
            PV.REMARKS EXCISEREMARKS,
            PV.SHIPSTATECODE,
            PV.ADDRESSCODEBILL,
            PV.BILLSTATECODE,
            PV.BILLEXCHANGERATE,
            M.DOCUMENTTYPE,
            AGAINSTEXCISEINVNO AGAINSTINVNO,
            AGAINSTEXCISEINVDATE AGAINSTINVDATE,
            M.EXCHANGERATESB,
            CD.FOBVALUE FOBVALUE_FC_CM,
            CM.BENEFITTYPE,
            M.EWAYBILLNO,
            M.EWAYBILLDATE,
            M.TIME_STAMP,
            CM.LOCATOR,
            CM.EPCGLICENSENO,
            CM.EPCGLICENSEDATE,
            PV.FREIGHTPAYMENT,
            PV.INSURANCETYPE
     FROM   SALESBILLMASTER_CAN M,
            SALESBILLDETAILS_CAN D,
            SALESEXCISEINVOICEVIEW_CAN PV,
            SALESBANKMASTER B,
            SALESCUSTOMINVOICEMASTER CM,
            SALESCUSTOMINVOICEDETAILS CD
    WHERE       M.COMPANYCODE = D.COMPANYCODE
            AND M.DIVISIONCODE = D.DIVISIONCODE
            AND M.YEARCODE = D.YEARCODE
            AND M.CHANNELCODE = D.CHANNELCODE
            AND M.SALEBILLNO = D.SALEBILLNO
            AND M.SALEBILLDATE = D.SALEBILLDATE
            AND M.COMPANYCODE = PV.COMPANYCODE
            AND M.DIVISIONCODE = PV.DIVISIONCODE
            /*            AND M.BUYERCODE = PV.BUYERCODE*/
            AND M.BROKERCODE = PV.BROKERCODE
            AND D.COMPANYCODE = PV.COMPANYCODE
            AND D.CHANNELCODE = PV.CHANNELCODE
            AND D.EXCISEINVNO = PV.EXCISEINVNO
            AND D.EXCISEINVDATE = PV.EXCISEINVDATE
            AND D.PROFORMAINVNO = PV.PROFORMAINVNO
            AND D.PROFORMAINVDATE = PV.PROFORMAINVDATE
            AND D.SHIPPINGINSNO = PV.SHIPPINGINSNO
            AND D.SHIPPINGINSDATE = PV.SHIPPINGINSDATE
            AND D.SAUDANO = PV.SAUDANO
            AND D.SAUDADATE = PV.SAUDADATE
            AND D.EXCISESERIALNO = PV.EXCISESERIALNO
            AND D.PROFORMASERIALNO = PV.PROFORMASERIALNO
            AND D.SHIPPINGSERIALNO = PV.SHIPPINGSERIALNO
            AND D.SAUDASERIALNO = PV.SAUDASERIALNO
            AND M.COMPANYCODE = B.COMPANYCODE(+)
            /*AND M.DIVISIONCODE = B.DIVISIONCODE(+)*/
            AND M.BANKCODE = B.BANKCODE(+)
            AND M.IFSCCODE = B.IFSCCODE(+)
            AND PV.COMPANYCODE = CM.COMPANYCODE(+)
            AND PV.DIVISIONCODE = CM.DIVISIONCODE(+)
            AND PV.PROFORMAINVNO = CM.CUSTOMINVNO(+)
            AND PV.PROFORMAINVDATE = CM.CUSTOMINVDATE(+)
            AND PV.COMPANYCODE = CD.COMPANYCODE(+)
            AND PV.DIVISIONCODE = CD.DIVISIONCODE(+)
            AND PV.PROFORMAINVNO = CD.CUSTOMINVNO(+)
            AND PV.PROFORMAINVDATE = CD.CUSTOMINVDATE(+)
            AND PV.PROFORMASERIALNO = CD.SERIALNO(+)
   UNION
   SELECT   "CHANNELCODE",
            "SALEBILLNO",
            "SALEBILLDATE",
            "BROKERCODE",
            "BUYERCODE",
            "NETAMOUNT",
            "NETINDIANAMOUNT",
            "GROSSAMOUNT",
            "YEARCODE",
            "COMPANYCODE",
            "DIVISIONCODE",
            "EXCISEINVNO",
            "EXCISEINVDATE",
            "PROFORMAINVNO",
            "PROFORMAINVDATE",
            "SHIPPINGINSNO",
            "SHIPPINGINSDATE",
            "SAUDANO",
            "SAUDADATE",
            "NOOFPACKINGUNIT",
            "TOTALQUANTITY",
            "TOTALWEIGHT",
            "PACKSHEETWEIGHT",
            "GROSSWEIGHT",
            "EXPORTWEIGHT",
            "CONTAINERSIZE",
            "TOTALAMOUNT",
            "TOTALINDIANAMOUNT",
            "NOFROM",
            "NOTO",
            "SAUDASERIALNO",
            "SHIPPINGSERIALNO",
            "PROFORMASERIALNO",
            "EXCISESERIALNO",
            "BILLSERIALNO",
            "TRANSPORTERCODE",
            "VESSELFLIGHTNO",
            "DESTINATION",
            "BOOKING",
            "CONTAINERNO",
            "CNOTENO",
            "CNOTEDATE",
            "SEALNO",
            "FORM1NO",
            "RENO",
            "REMOVALDATE",
            "TIMEOFPREPARATION",
            "EXAPPLICABLE",
            "EXFROM",
            "EXTO",
            "REMARKSPRO",
            "ADDRESSCODE",
            "COUNTRYOFFINALDESTINATION",
            "PRECARRIAGE",
            "VESSELORFLIGHT",
            "PORTOFDISCHARGE",
            "PAYMENTCONDITION",
            "PLACEOFRECEIPT",
            "PORTOFLOADING",
            "FINALDESTINATION",
            "COUNTRYOFORIGIN",
            "QUALITYCODE",
            "DELIVERYQUALITYDESC",
            "PACKINGCODE",
            "PACKINGNAME",
            "PACKINGSHORTNAME",
            "PACKINGWEIGHT",
            "PACKSTYLECODE",
            "PACKSTYLENAME",
            "UORCODE",
            "UORNAME",
            "NOCALCULATION",
            "RATE",
            "INDIANRATE",
            "BUYERNAME",
            "BROKERNAME",
            "QUALITYTYPE",
            "PACKINGQUANTITY",
            "MEASURECODE",
            "MEASURENAME",
            "CURRENCYCODE",
            "CURRENCYDESC",
            "CURRENCYSYMBOL",
            "CONTRACTNO",
            "CONTRACTDATE",
            "REMARKS",
            "UNITQUANTITY",
            "BROKERAGEPER",
            "TDSPER",
            "INSPECTIONNO",
            "INSPECTIONDATE",
            "CHALLANNO",
            "SONO",
            "CHANNELTAG",
            "DESTINATIONFROMTO",
            "BANKCODE",
            "BANKNAME",
            "BANKADDRESS",
            "ACNO",
            "DEFAULTBANK",
            "EXCHANGERATE",
            "BILLOFLOADINGNO",
            "MATERECEIPTNO",
            "SHIPPINGBILLNO",
            "SHIPPINGBILLDATE",
            "MATERECEIPTDATE",
            "BILLOFLOADINGDATE",
            "CUSTOMINVNO",
            "CUSTOMINVDATE",
            "CUSTOMSERIALNO",
            "GROSSAMOUNTINR",
            "BILLTYPE",
            "GOVTQUALITYDESC",
            "VEHICLENO",
            "OLDREFERENCENOGP",
            "ENTEREDBY",
            "ENTEREDON",
            "AMMENDMENTNO",
            "FREIGHTPAIDAT",
            "QUALITYMANUALDESC",
            "TOTALQUANTITYYDS",
            "MARKS",
            "CONSIGNEECODE",
            "CONSIGNEEADDRESSCODE",
            "SYSROWID",
            "CIPAYMENTTERMS",
            "PRICETYPE",
            "RRIWB",
            "MEASUREUNIT",
            "WHICHFIELD",
            "EXCHANGERATEBL",
            "QUALITYGROUPCODE",
            "SUPPLYORDERNO",
            "SUPPORDERDATE",
            "HEADACCNTNAME",
            "ISFCIPARTY",
            "LCNO",
            "LCDATE",
            "VOYNO",
            "INDENTORNAME",
            "INDENTORADDRESS",
            "HEADACCNTADDRESS",
            "IFSCCODE",
            "LETTERNOANDDATE",
            "BROKERAGECOMM",
            "BUYERORDERNO",
            "BUYERORDERDATE",
            "SUBMISSIONDATE",
            "REFEXCISEINVNO",
            "REFEXCISEINVDATE",
            "EXCISEGROUPCODE",
            "EXCISEREMARKS",
            "SHIPSTATECODE",
            "ADDRESSCODEBILL",
            "BILLSTATECODE",
            "BILLEXCHANGERATE",
            "DOCUMENTTYPE",
            NULL "AGAINSTINVNO",
            NULL "AGAINSTINVDATE",
            NULL "EXCHANGERATESB",
            NULL "FOBVALUE_FC_CM",
            NULL "BENEFITTYPE",
            NULL "EWAYBILLNO",
            NULL "EWAYBILLDATE",
            NULL "TIME_STAMP",
            NULL "LOCATOR",
            NULL "EPCGLICENSENO",
            NULL "EPCGLICENSEDATE",
            NULL "FREIGHTPAYMENT",
            NULL "INSURANCETYPE"
     FROM   VW_SALEBILLVIEW_PART;


