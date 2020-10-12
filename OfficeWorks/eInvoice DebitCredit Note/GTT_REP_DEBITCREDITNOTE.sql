DROP TABLE EINVOICE_INFRA.GTT_REP_DEBITCREDITNOTE CASCADE CONSTRAINTS;

CREATE GLOBAL TEMPORARY TABLE EINVOICE_INFRA.GTT_REP_DEBITCREDITNOTE
(
  SLNO                       NUMBER,
  BANKNAME                   VARCHAR2(100 BYTE),
  BRANCH                     VARCHAR2(50 BYTE),
  ACCOUNTNO                  VARCHAR2(50 BYTE),
  IFSC                       VARCHAR2(50 BYTE),
  HSNCODE                    VARCHAR2(10 BYTE),
  CHANNELCODE                VARCHAR2(100 BYTE),
  DOCUMENTTYPE               VARCHAR2(30 BYTE),
  DBCRNOTENO                 VARCHAR2(20 BYTE),
  DBCRNOTEDATE               DATE,
  GSTGPDBCRNO                VARCHAR2(20 BYTE),
  GSTGPDBCRDATE              DATE,
  AGAINSTTAXINVNO            VARCHAR2(20 BYTE),
  AGAINSTTAXINVDATE          DATE,
  AGAINSTEXCISEINVNO         VARCHAR2(20 BYTE),
  AGAINSTEXCISEINVDATE       DATE,
  BROKERCODE                 VARCHAR2(10 BYTE),
  BUYERCODE                  VARCHAR2(10 BYTE),
  TRANSPORTERCODE            VARCHAR2(10 BYTE),
  NETAMOUNT                  NUMBER(15,4),
  NETINDIANAMOUNT            NUMBER(15,4),
  GROSSAMOUNT                NUMBER(15,4),
  VESSELFLIGHTNO             VARCHAR2(100 BYTE),
  DESTINATION                VARCHAR2(100 BYTE),
  BOOKING                    VARCHAR2(100 BYTE),
  CONTAINERNO                VARCHAR2(50 BYTE),
  CNOTENO                    VARCHAR2(50 BYTE),
  CNOTEDATE                  DATE,
  SEALNO                     VARCHAR2(50 BYTE),
  FORM1NO                    VARCHAR2(50 BYTE),
  RENO                       VARCHAR2(50 BYTE),
  TIMEOFPREPARATION          VARCHAR2(20 BYTE),
  EXAPPLICABLE               VARCHAR2(10 BYTE),
  EXFROM                     VARCHAR2(10 BYTE),
  EXTO                       VARCHAR2(10 BYTE),
  YEARCODE                   VARCHAR2(9 BYTE),
  COMPANYCODE                VARCHAR2(20 BYTE),
  DIVISIONCODE               VARCHAR2(20 BYTE),
  STATIONTYPE                VARCHAR2(20 BYTE),
  PROFORMAINVNO              VARCHAR2(20 BYTE),
  PROFORMAINVDATE            DATE,
  SHIPPINGINSNO              VARCHAR2(20 BYTE),
  SHIPPINGINSDATE            DATE,
  SAUDANO                    VARCHAR2(20 BYTE),
  SAUDADATE                  DATE,
  NOOFPACKINGUNIT            NUMBER(15,6),
  TOTALQUANTITY              NUMBER(15,6),
  TOTALWEIGHT                NUMBER(15,6),
  PACKSHEETWEIGHT            NUMBER(15,6),
  GROSSWEIGHT                NUMBER(15,6),
  EXPORTWEIGHT               NUMBER(15,6),
  CONTAINERSIZE              VARCHAR2(50 BYTE),
  TOTALAMOUNT                NUMBER(15,4),
  TOTALINDIANAMOUNT          NUMBER(15,2),
  NOFROM                     NUMBER(18,6),
  NOTO                       NUMBER(18,6),
  SAUDASERIALNO              NUMBER(18,6),
  SHIPPINGSERIALNO           NUMBER(18,6),
  PROFORMASERIALNO           NUMBER(18,6),
  EXCISESERIALNO             NUMBER(18,6),
  BILLSERIALNO               NUMBER(18,6),
  FROMOWNMILL                VARCHAR2(3 BYTE),
  NOOFCONTAINERS             NUMBER(18,6),
  LSPPERCENTAGE              NUMBER(7,2),
  GRFROMNO                   VARCHAR2(30 BYTE),
  GRFROMDATE                 DATE,
  BUYERNAMEOTHER             VARCHAR2(50 BYTE),
  BUYERADDRESSOTHER          VARCHAR2(100 BYTE),
  FORMTYPE                   VARCHAR2(20 BYTE),
  FORMTAKE                   VARCHAR2(3 BYTE),
  REMARKSPRO                 VARCHAR2(255 BYTE),
  ADDRESSCODE                VARCHAR2(20 BYTE),
  ADDRESS                    VARCHAR2(255 BYTE),
  COUNTRYOFFINALDESTINATION  VARCHAR2(50 BYTE),
  PRECARRIAGE                VARCHAR2(50 BYTE),
  VESSELORFLIGHT             VARCHAR2(20 BYTE),
  PORTOFDISCHARGE            VARCHAR2(50 BYTE),
  PAYMENTCONDITION           VARCHAR2(50 BYTE),
  PLACEOFRECEIPT             VARCHAR2(50 BYTE),
  PORTOFLOADING              VARCHAR2(50 BYTE),
  FINALDESTINATION           VARCHAR2(50 BYTE),
  COUNTRYOFORIGIN            VARCHAR2(50 BYTE),
  FREIGHTAMOUNT              NUMBER(15,4),
  REQUISITIONNO              VARCHAR2(50 BYTE),
  SUPPLYORDERNO              VARCHAR2(50 BYTE),
  INDENTNO                   VARCHAR2(30 BYTE),
  INDENTORNAME               VARCHAR2(100 BYTE),
  INDENTORADDRESS            VARCHAR2(140 BYTE),
  ACCNTOFFICERNAME           VARCHAR2(300 BYTE),
  ACCNTOFFICERADDSRESS       VARCHAR2(200 BYTE),
  HEADACCNTADDSRESS          VARCHAR2(200 BYTE),
  QUALITYCODE                VARCHAR2(10 BYTE),
  QUALITYDESC                VARCHAR2(1000 BYTE),
  PACKINGCODE                VARCHAR2(10 BYTE),
  PACKINGNAME                VARCHAR2(500 BYTE),
  PACKINGWEIGHT              NUMBER(15,6),
  PACKSTYLECODE              VARCHAR2(10 BYTE),
  PACKSTYLENAME              VARCHAR2(20 BYTE),
  UORCODE                    VARCHAR2(10 BYTE),
  UORNAME                    VARCHAR2(100 BYTE),
  DUEDATEFROM                DATE,
  DUEDATETO                  DATE,
  NOCALCULATION              VARCHAR2(20 BYTE),
  RATE                       NUMBER(15,4),
  INDIANRATE                 NUMBER(15,2),
  BUYERNAME                  VARCHAR2(100 BYTE),
  BROKERNAME                 VARCHAR2(100 BYTE),
  QUALITYTYPE                VARCHAR2(50 BYTE),
  PACKINGQUANTITY            NUMBER(15,3),
  MEASURECODE                VARCHAR2(10 BYTE),
  MEASURENAME                VARCHAR2(20 BYTE),
  CURRENCYCODE               VARCHAR2(10 BYTE),
  CURRENCYDESC               VARCHAR2(100 BYTE),
  CURRENCYSYMBOL             VARCHAR2(10 BYTE),
  CONTRACTNO                 VARCHAR2(50 BYTE),
  CONTRACTDATE               DATE,
  INDENTDATE                 DATE,
  ISFCIPARTY                 VARCHAR2(10 BYTE),
  QUALITYGROUP               VARCHAR2(50 BYTE),
  GROUPNAME                  VARCHAR2(50 BYTE),
  UNITQUANTITY               NUMBER(18,6),
  SUPPORDERDATE              DATE,
  HEADACCNTNAME              VARCHAR2(200 BYTE),
  VEHICLENO                  VARCHAR2(50 BYTE),
  TIMEOFISSUE                VARCHAR2(50 BYTE),
  ISSUEDATE                  VARCHAR2(50 BYTE),
  REMOVALDATE                VARCHAR2(50 BYTE),
  EXCISEGROUPCODE            VARCHAR2(20 BYTE),
  CHALLANNO                  VARCHAR2(50 BYTE),
  MARKS                      VARCHAR2(200 BYTE),
  SUBHEADCODE                VARCHAR2(20 BYTE),
  SONO                       VARCHAR2(50 BYTE),
  TAREWEIGHT                 VARCHAR2(50 BYTE),
  CHANNELTAG                 VARCHAR2(30 BYTE),
  QUALITYDESCRIPTION         VARCHAR2(255 BYTE),
  DESTINATIONRLYSTN          VARCHAR2(50 BYTE),
  TRADINGGPNO                VARCHAR2(50 BYTE),
  TRADINGGPDATE              VARCHAR2(50 BYTE),
  TRADINGGPSERIALNO          VARCHAR2(50 BYTE),
  DIRECTTRADING              VARCHAR2(50 BYTE),
  PRICETYPE                  VARCHAR2(100 BYTE),
  TENURE                     VARCHAR2(10 BYTE),
  BUYERORDERDATE             DATE,
  BUYERORDERNO               VARCHAR2(30 BYTE),
  QUALITYBASETYPE            VARCHAR2(50 BYTE),
  INDENTORCODE               VARCHAR2(10 BYTE),
  GOVTACCCODE                VARCHAR2(10 BYTE),
  ACCOUNTOFFICERCODE         VARCHAR2(10 BYTE),
  BISSPECNO                  VARCHAR2(100 BYTE),
  OUTSIDEGODOWN              VARCHAR2(50 BYTE),
  RCNOVAT                    VARCHAR2(40 BYTE),
  RCNOW                      VARCHAR2(40 BYTE),
  RCNOC                      VARCHAR2(40 BYTE),
  ADDRESSCODEBILL            VARCHAR2(20 BYTE),
  BILLSTATECODE              VARCHAR2(2 BYTE),
  BONDLUTNO                  VARCHAR2(50 BYTE),
  REMARKSCUSTOM              VARCHAR2(255 BYTE),
  SUPPADDRESSNAME            VARCHAR2(50 BYTE),
  BILLADDRESSNAME            VARCHAR2(50 BYTE),
  SUPPLYADDRESS              VARCHAR2(255 BYTE),
  SUPPSTATENAME              VARCHAR2(50 BYTE),
  BILLSTATENAME              VARCHAR2(50 BYTE),
  SUPPGSTSTATECODE           VARCHAR2(2 BYTE),
  BILLGSTSTATECODE           VARCHAR2(2 BYTE),
  BILLINGADDRESS             VARCHAR2(255 BYTE),
  BILLCOUNTRY                VARCHAR2(50 BYTE),
  SUPPCOUNTRY                VARCHAR2(30 BYTE),
  TRANSPORTERNAME            VARCHAR2(100 BYTE),
  TRANSPORTERADDRESS         VARCHAR2(500 BYTE),
  TAG                        VARCHAR2(30 BYTE),
  SUPPLYGSNT                 VARCHAR2(15 BYTE),
  BILLINGGSNT                VARCHAR2(15 BYTE),
  COMPANYNAME                VARCHAR2(100 BYTE),
  COMPANYADDRESS             VARCHAR2(250 BYTE),
  COMPANYADDRESS1            VARCHAR2(150 BYTE),
  COMPANYADDRESS2            VARCHAR2(150 BYTE),
  COMPANYCITY                VARCHAR2(50 BYTE),
  COMPANYSTATE               VARCHAR2(50 BYTE),
  COMPANYCOUNTRY             VARCHAR2(50 BYTE),
  COMPANYPHONE               VARCHAR2(100 BYTE),
  COMPANYFAX                 VARCHAR2(50 BYTE),
  COMPANYEMAIL               VARCHAR2(50 BYTE),
  PANNO                      VARCHAR2(50 BYTE),
  WBSTNO                     VARCHAR2(50 BYTE),
  BANKCODE                   VARCHAR2(4 BYTE),
  MILLHO                     VARCHAR2(4 BYTE),
  DESIREGIONCODE             VARCHAR2(10 BYTE),
  CSTNO                      VARCHAR2(50 BYTE),
  CHNGPWDAFTERHMD            NUMBER(3),
  WEBSITE                    VARCHAR2(100 BYTE),
  ISODESC                    VARCHAR2(100 BYTE),
  COMPANYADDRESS3            VARCHAR2(150 BYTE),
  VATNO                      VARCHAR2(100 BYTE),
  PURCHASEORDERPREFIX        VARCHAR2(2 BYTE),
  WPSRETIREMENTAGE           NUMBER(3),
  PISESILIMIT                NUMBER(15,2),
  IECNO                      VARCHAR2(20 BYTE),
  ITEMCODELIMIT              NUMBER(2),
  POPREPINDENTWISE           VARCHAR2(5 BYTE),
  INDENTGRACEPERCENTAGE      NUMBER(10,2),
  ITEMMASKALLOW              VARCHAR2(3 BYTE),
  SPECIALREMARKS             VARCHAR2(3000 BYTE),
  CINNO                      VARCHAR2(50 BYTE),
  REGDADDRESS                VARCHAR2(150 BYTE),
  RUKA_VS_MR_QTL_FOR_CANC    NUMBER(13,2),
  GSTNO                      VARCHAR2(50 BYTE),
  COMPANYPINCODE                VARCHAR2(50 BYTE),
  CHARGEDATA                 VARCHAR2(500 BYTE),
  EX1                        VARCHAR2(50 BYTE),
  EX2                        VARCHAR2(50 BYTE),
  EX3                        VARCHAR2(500 BYTE),
  EX4                        VARCHAR2(500 BYTE),
  EX5                        VARCHAR2(50 BYTE),
  EX6                        VARCHAR2(50 BYTE),
  EX7                        VARCHAR2(50 BYTE),
  EX8                        VARCHAR2(50 BYTE)
)