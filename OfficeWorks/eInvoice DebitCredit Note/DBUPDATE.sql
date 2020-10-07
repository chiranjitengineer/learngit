DROP VIEW EINVOICE_INFRA.GTT_REP_DEBITCREDITNOTE;

/* Formatted on 08/10/2020 12:15:24 AM (QP5 v5.326) */
INSERT INTO GTT_REP_DEBITCREDITNOTE
    SELECT                                                          /* +RULE*/
           ROWNUM                SLNO,
           BANKNAME,
           BRANCH,
           ACCOUNTNO,
           IFSC,
           HSNCODE,
           --SEV
           SEV.CHANNELCODE,
           SEV.DOCUMENTTYPE,
           SEV.DBCRNOTENO,
           SEV.DBCRNOTEDATE,
           SEV.GSTGPDBCRNO,
           SEV.GSTGPDBCRDATE,
           SEV.AGAINSTTAXINVNO,
           SEV.AGAINSTTAXINVDATE,
           SEV.AGAINSTEXCISEINVNO,
           SEV.AGAINSTEXCISEINVDATE,
           SEV.BROKERCODE,
           SEV.BUYERCODE,
           SEV.TRANSPORTERCODE,
           SEV.NETAMOUNT,
           SEV.NETINDIANAMOUNT,
           SEV.GROSSAMOUNT,
           SEV.VESSELFLIGHTNO,
           SEV.DESTINATION,
           SEV.BOOKING,
           SEV.CONTAINERNO,
           SEV.CNOTENO,
           SEV.CNOTEDATE,
           SEV.SEALNO,
           SEV.FORM1NO,
           SEV.RENO,
           SEV.TIMEOFPREPARATION,
           SEV.EXAPPLICABLE,
           SEV.EXFROM,
           SEV.EXTO,
           SEV.YEARCODE,
           SEV.COMPANYCODE,
           SEV.DIVISIONCODE,
           SEV.STATIONTYPE,
           SEV.PROFORMAINVNO,
           SEV.PROFORMAINVDATE,
           SEV.SHIPPINGINSNO,
           SEV.SHIPPINGINSDATE,
           SEV.SAUDANO,
           SEV.SAUDADATE,
           SEV.NOOFPACKINGUNIT,
           SEV.TOTALQUANTITY,
           SEV.TOTALWEIGHT,
           SEV.PACKSHEETWEIGHT,
           SEV.GROSSWEIGHT,
           SEV.EXPORTWEIGHT,
           SEV.CONTAINERSIZE,
           SEV.TOTALAMOUNT,
           SEV.TOTALINDIANAMOUNT,
           SEV.NOFROM,
           SEV.NOTO,
           SEV.SAUDASERIALNO,
           SEV.SHIPPINGSERIALNO,
           SEV.PROFORMASERIALNO,
           SEV.EXCISESERIALNO,
           SEV.BILLSERIALNO,
           SEV.FROMOWNMILL,
           SEV.NOOFCONTAINERS,
           SEV.LSPPERCENTAGE,
           SEV.GRFROMNO,
           SEV.GRFROMDATE,
           SEV.BUYERNAMEOTHER,
           SEV.BUYERADDRESSOTHER,
           SEV.FORMTYPE,
           SEV.FORMTAKE,
           SEV.REMARKSPRO,
           SEV.ADDRESSCODE,
           SEV.ADDRESS,
           SEV.COUNTRYOFFINALDESTINATION,
           SEV.PRECARRIAGE,
           SEV.VESSELORFLIGHT,
           SEV.PORTOFDISCHARGE,
           SEV.PAYMENTCONDITION,
           SEV.PLACEOFRECEIPT,
           SEV.PORTOFLOADING,
           SEV.FINALDESTINATION,
           SEV.COUNTRYOFORIGIN,
           SEV.FREIGHTAMOUNT,
           SEV.REQUISITIONNO,
           SEV.SUPPLYORDERNO,
           SEV.INDENTNO,
           SEV.INDENTORNAME,
           SEV.INDENTORADDRESS,
           SEV.ACCNTOFFICERNAME,
           SEV.ACCNTOFFICERADDSRESS,
           SEV.HEADACCNTADDSRESS,
           SEV.QUALITYCODE,
           SEV.QUALITYDESC,
           SEV.PACKINGCODE,
           SEV.PACKINGNAME,
           SEV.PACKINGWEIGHT,
           SEV.PACKSTYLECODE,
           SEV.PACKSTYLENAME,
           SEV.UORCODE,
           SEV.UORNAME,
           SEV.DUEDATEFROM,
           SEV.DUEDATETO,
           SEV.NOCALCULATION,
           SEV.RATE,
           SEV.INDIANRATE,
           SEV.BUYERNAME,
           SEV.BROKERNAME,
           SEV.QUALITYTYPE,
           SEV.PACKINGQUANTITY,
           SEV.MEASURECODE,
           SEV.MEASURENAME,
           SEV.CURRENCYCODE,
           SEV.CURRENCYDESC,
           SEV.CURRENCYSYMBOL,
           SEV.CONTRACTNO,
           SEV.CONTRACTDATE,
           SEV.INDENTDATE,
           SEV.ISFCIPARTY,
           SEV.QUALITYGROUP,
           SEV.GROUPNAME,
           SEV.UNITQUANTITY,
           SEV.SUPPORDERDATE,
           SEV.HEADACCNTNAME,
           SEV.VEHICLENO,
           SEV.TIMEOFISSUE,
           SEV.ISSUEDATE,
           SEV.REMOVALDATE,
           SEV.EXCISEGROUPCODE,
           SEV.CHALLANNO,
           SEV.MARKS,
           SEV.SUBHEADCODE,
           SEV.SONO,
           SEV.TAREWEIGHT,
           SEV.CHANNELTAG,
           SEV.QUALITYDESCRIPTION,
           SEV.DESTINATIONRLYSTN,
           SEV.TRADINGGPNO,
           SEV.TRADINGGPDATE,
           SEV.TRADINGGPSERIALNO,
           SEV.DIRECTTRADING,
           SEV.PRICETYPE,
           SEV.TENURE,
           SEV.BUYERORDERDATE,
           SEV.BUYERORDERNO,
           SEV.QUALITYBASETYPE,
           SEV.INDENTORCODE,
           SEV.GOVTACCCODE,
           SEV.ACCOUNTOFFICERCODE,
           SEV.BISSPECNO,
           SEV.OUTSIDEGODOWN,
           SEV.RCNOVAT,
           SEV.RCNOW,
           SEV.RCNOC,
           SEV.ADDRESSCODEBILL,
           SEV.BILLSTATECODE,
           SEV.BONDLUTNO,
           SEV.REMARKSCUSTOM--SEV
                            ,
           SA.ADDRESSNAME        SUPPADDRESSNAME,
           BA.ADDRESSNAME        BILLADDRESSNAME,
           SA.ADDRESS            SUPPLYADDRESS,
           GSMS.STATENAME        SUPPSTATENAME,
           GSMB.STATENAME        BILLSTATENAME,
           SA.GSTSTATECODE       SUPPGSTSTATECODE,
           BA.GSTSTATECODE       BILLGSTSTATECODE,
           BA.ADDRESS            BILLINGADDRESS,
           GSMB.COUNTRY          BILLCOUNTRY,
           SA.COUNTRY            SUPPCOUNTRY,
           STM.TRANSPORTERNAME,
           STM.TRANSPORTERADDRESS,
           CHM.CHANNELTAG        AS TAG,
           SA.GSTNNO             SUPPLYGSNT,
           BA.GSTNNO             BILLINGGSNT,
           --MP.*,
           MP.COMPANYNAME,
           MP.COMPANYADDRESS,
           MP.COMPANYADDRESS1,
           MP.COMPANYADDRESS2,
           MP.COMPANYCITY,
           MP.COMPANYSTATE,
           MP.COMPANYCOUNTRY,
           MP.COMPANYPHONE,
           MP.COMPANYFAX,
           MP.COMPANYEMAIL,
           MP.PANNO,
           MP.WBSTNO,
           MP.BANKCODE,
           MP.MILLHO,
           MP.DESIREGIONCODE,
           MP.CSTNO,
           MP.CHNGPWDAFTERHMD,
           MP.WEBSITE,
           MP.ISODESC,
           MP.COMPANYADDRESS3,
           MP.VATNO,
           MP.PURCHASEORDERPREFIX,
           MP.WPSRETIREMENTAGE,
           MP.PISESILIMIT,
           MP.IECNO,
           MP.ITEMCODELIMIT,
           MP.POPREPINDENTWISE,
           MP.INDENTGRACEPERCENTAGE,
           MP.ITEMMASKALLOW,
           MP.SPECIALREMARKS,
           MP.CINNO,
           MP.REGDADDRESS,
           MP.RUKA_VS_MR_QTL_FOR_CANC,
           MP.GSTNO,
           MP.COMPANYPINCODE     --MP
                                 CHARGEDATA
      FROM SALESGSTDBCRNOTEVIEW    SEV,
           SALESPARTYADDRESS       SA,
           SALESPARTYADDRESS       BA,
           SALESTRANSPORTERMASTER  STM,
           SALESCHANNELMASTER      CHM,
           MAINPARAMETER           MP,
           GSTITEMVSHSNMAPPING     HSN,
           GSTSTATEMASTER          GSMB,
           GSTSTATEMASTER          GSMS,
           DIVISIONMASTER          DM,
           (  SELECT DOCUMENTNO,
                     DOCUMENTDATE,
                     RTRIM (
                         XMLAGG (XMLELEMENT (
                                     E,
                                     X.CHARGESHORTNAME || X.CHARGEAMOUNT || '~') ORDER BY
                         X.SERIALNO).EXTRACT ('//text()'),
                         '~')
                         CHARGEDATA
                FROM (SELECT D.DOCUMENTNO,
                             D.DOCUMENTDATE,
                             M.CHARGESHORTNAME,
                             TO_CHAR (CHARGEAMOUNT, '9999999990.99')
                                 CHARGEAMOUNT,
                             TO_NUMBER (NUM_GROUP_SERIAL)
                                 SERIALNO
                        FROM SALESCHARGEDETAILS   D,
                             SALESCHARGEMASTER    M,
                             SALES_CHARGE_GRP_MAST E
                       WHERE     D.COMPANYCODE = M.COMPANYCODE
                             AND D.CHARGECODE = M.CHARGECODE
                             AND D.CHANNELCODE = M.CHANNELCODE
                             AND M.COMPANYCODE = E.COMPANYCODE
                             AND M.CHARGECODE = E.CHR_GROUP_PARENT_CODE
                             AND M.CHARGETYPE NOT LIKE 'GST_%'
                             AND D.DOCUMENTTYPE = 'CREDIT NOTE'
                      UNION ALL
                        SELECT D.DOCUMENTNO,
                               D.DOCUMENTDATE,
                               'Taxable Value'
                                   CHARGESHORTNAME,
                               TO_CHAR (MAX (NVL (ASSESSABLEAMOUNT, 0)),
                                        '9999999990.99')
                                   CHARGEAMOUNT,
                               MIN (TO_NUMBER (NUM_GROUP_SERIAL)) - 0.1
                                   SERIALNO
                          FROM SALESCHARGEDETAILS D,
                               SALESCHARGEMASTER  M,
                               SALES_CHARGE_GRP_MAST E
                         WHERE     D.COMPANYCODE = M.COMPANYCODE
                               AND D.CHARGECODE = M.CHARGECODE
                               AND D.CHANNELCODE = M.CHANNELCODE
                               AND M.COMPANYCODE = E.COMPANYCODE
                               AND M.CHARGECODE = E.CHR_GROUP_PARENT_CODE
                               AND M.CHARGETYPE LIKE 'GST_%'
                               AND D.DOCUMENTTYPE = 'CREDIT NOTE'
                      GROUP BY D.DOCUMENTNO, D.DOCUMENTDATE
                      UNION ALL
                      SELECT D.DOCUMENTNO,
                             D.DOCUMENTDATE,
                             M.CHARGESHORTNAME,
                             TO_CHAR (CHARGEAMOUNT, '9999999990.99')
                                 CHARGEAMOUNT,
                             TO_NUMBER (NUM_GROUP_SERIAL)
                                 SERIALNO
                        FROM SALESCHARGEDETAILS   D,
                             SALESCHARGEMASTER    M,
                             SALES_CHARGE_GRP_MAST E
                       WHERE     D.COMPANYCODE = M.COMPANYCODE
                             AND D.CHARGECODE = M.CHARGECODE
                             AND D.CHANNELCODE = M.CHANNELCODE
                             AND M.COMPANYCODE = E.COMPANYCODE
                             AND M.CHARGECODE = E.CHR_GROUP_PARENT_CODE
                             AND M.CHARGETYPE LIKE 'GST_%'
                             AND D.DOCUMENTTYPE = 'CREDIT NOTE'
                      ORDER BY SERIALNO) X
            GROUP BY DOCUMENTNO, DOCUMENTDATE) CHG
     WHERE     1 = 1
           AND DM.COMPANYCODE = SEV.COMPANYCODE
           AND DM.DIVISIONCODE = SEV.DIVISIONCODE
           AND SA.COMPANYCODE = SEV.COMPANYCODE
           AND SA.PARTYCODE = SEV.BUYERCODE
           AND SA.RECORDNO = SEV.ADDRESSCODE
           AND SA.PARTYBROKERAGENT = 'PARTY'
           AND BA.COMPANYCODE = SEV.COMPANYCODE
           AND BA.PARTYCODE = SEV.BUYERCODE
           AND BA.RECORDNO(+) = SEV.ADDRESSCODEBILL
           AND BA.PARTYBROKERAGENT = 'PARTY'
           AND GSMS.GSTSTATECODE(+) = SA.GSTSTATECODE
           AND GSMB.GSTSTATECODE(+) = BA.GSTSTATECODE
           AND SEV.TRANSPORTERCODE = STM.TRANSPORTERCODE(+)
           AND SEV.COMPANYCODE = STM.COMPANYCODE(+)
           AND SEV.COMPANYCODE = CHM.COMPANYCODE
           AND SEV.CHANNELCODE = CHM.CHANNELCODE
           AND SEV.COMPANYCODE = MP.COMPANYCODE
           AND SEV.COMPANYCODE = HSN.COMPANYCODE
           AND SEV.QUALITYCODE = HSN.ITEMCODE
           AND SEV.DBCRNOTENO = CHG.DOCUMENTNO
           AND SEV.DBCRNOTEDATE = CHG.DOCUMENTDATE
           AND HSN.MODULE = 'SALES'
--           AND SEV.CHANNELCODE = 'DOMESTIC-WITHIN-WESTBENGAL'
--           AND DBCRNOTENO = 'B/2021/IWCN/0005'
--           AND DBCRNOTEDATE = TO_DATE ('10/08/2020', 'DD/MM/YYYY');
