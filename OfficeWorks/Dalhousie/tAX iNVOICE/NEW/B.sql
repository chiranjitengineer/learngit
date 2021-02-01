SELECT * FROM GTT_SALESBILLPRINTGST



="Invoice No.    : " & Fields!SALEBILLNO.Value & vbcrlf &
"D.O. No.        : " & Fields!PROFORMAINVNO.Value & vbcrlf &
"Sales Order    : " & Fields!SAUDANO.Value & vbcrlf &
"Contract No. : " & Fields!BUYERORDERNO.Value & vbcrlf &
"Amnd.1 : " & Fields!EX22.Value  & vbcrlf &
"Amnd.2 : " & Fields!EX24.Value & vbcrlf &
"PCSO No.   :  " & Fields!EX7.Value



SELECT * FROM GTT_SALESDOPRINTGST




="D.O. No.        : " & Fields!PROFORMAINVNO.Value & vbcrlf &
"Sales Order    : " & Fields!SAUDANO.Value & vbcrlf &
"Buyer's order : " & Fields!BUYERORDERNO.Value


proc_salesdoprintgst

proc_salesbillprintgst


TRUNCATE TABLE GTT_SALESDOPRINTGST

DROP TABLE GTT_SALESDOPRINTGST CASCADE CONSTRAINTS;

CREATE GLOBAL TEMPORARY TABLE DALHOUSIE_WEB.GTT_SALESDOPRINTGST
(
  SALEBILLNO         VARCHAR2(50 BYTE),
  SALEBILLDATE       DATE,
  EXCISEINVNO        VARCHAR2(50 BYTE),
  EXCISEINVDATE      DATE,
  PROFORMAINVNO      VARCHAR2(50 BYTE),
  PROFORMAINVDATE    DATE,
  SAUDANO            VARCHAR2(50 BYTE),
  SAUDADATE          DATE,
  BUYERORDERNO       VARCHAR2(30 BYTE),
  BUYERORDERDATE     DATE,
  BROKERCODE         VARCHAR2(10 BYTE),
  BROKERNAME         VARCHAR2(100 BYTE),
  BUYERCODE          VARCHAR2(10 BYTE),
  BUYERNAME          VARCHAR2(100 BYTE),
  TRANSPORTERCODE    VARCHAR2(10 BYTE),
  PARTYNAME          VARCHAR2(100 BYTE),
  ADDRESSNAMEBILL    VARCHAR2(100 BYTE),
  ADDRESSBILL        VARCHAR2(255 BYTE),
  PINBILL            VARCHAR2(50 BYTE),
  STATEBILL          VARCHAR2(30 BYTE),
  GSTNNOBILL         VARCHAR2(15 BYTE),
  ADDRESSNAMESHIP    VARCHAR2(100 BYTE),
  ADDRESSSHIP        VARCHAR2(255 BYTE),
  PINSHIP            VARCHAR2(50 BYTE),
  STATESHIP          VARCHAR2(30 BYTE),
  GSTNNOSHIP         VARCHAR2(15 BYTE),
  DESTINATION        VARCHAR2(50 BYTE),
  VEHICLENO          VARCHAR2(50 BYTE),
  VESSELORFLIGHT     VARCHAR2(20 BYTE),
  VESSELFLIGHTNO     VARCHAR2(100 BYTE),
  CNOTENO            VARCHAR2(50 BYTE),
  CNOTEDATE          DATE,
  CHALLANNO          VARCHAR2(20 BYTE),
  CHANNELCODE        VARCHAR2(100 BYTE),
  BILLSERIALNO       NUMBER(18),
  QUALITYCODE        VARCHAR2(10 BYTE),
  HSNCODE            VARCHAR2(10 BYTE),
  QUALITYMANUALDESC  VARCHAR2(500 BYTE),
  PACKINGCODE        VARCHAR2(10 BYTE),
  PACKINGNAME        VARCHAR2(500 BYTE),
  NOOFPACKINGUNIT    NUMBER,
  UORCODE            VARCHAR2(10 BYTE),
  UORNAME            VARCHAR2(100 BYTE),
  MEASURECODE        VARCHAR2(10 BYTE),
  TOTALQUANTITY      NUMBER,
  TOTALWEIGHT        NUMBER,
  PACKSHEETWEIGHT    NUMBER,
  GROSSWEIGHT        NUMBER,
  INDIANRATE         NUMBER(15,2),
  TOTALINDIANAMOUNT  NUMBER,
  GROSSAMOUNTINR     NUMBER,
  AMTINWORDS         VARCHAR2(4000 BYTE),
  CHARGEDATA         VARCHAR2(4000 BYTE),
  SRL                NUMBER,
  TEXT               VARCHAR2(25 BYTE),
  BANKCODE           VARCHAR2(10 BYTE),
  BANKNAME           VARCHAR2(100 BYTE),
  BANKADDRESS        VARCHAR2(250 BYTE),
  ACNO               VARCHAR2(20 BYTE),
  IFCSCODE           VARCHAR2(100 BYTE),
  COMPANYNAME        VARCHAR2(100 BYTE),
  COMPANYADDRESS     VARCHAR2(250 BYTE),
  COMPANYADDRESS1    VARCHAR2(150 BYTE),
  COMPANYADDRESS2    VARCHAR2(150 BYTE),
  PANNO              VARCHAR2(50 BYTE),
  COMPANYEMAIL       VARCHAR2(50 BYTE),
  DIVISIONNAME       VARCHAR2(100 BYTE),
  GSTNNO             VARCHAR2(15 BYTE),
  GSTSTATECODE       VARCHAR2(2 BYTE),
  LOGOPATH           VARCHAR2(100 BYTE),
  EX1                VARCHAR2(100 BYTE),
  EX2                VARCHAR2(100 BYTE),
  EX3                VARCHAR2(100 BYTE),
  EX4                VARCHAR2(100 BYTE),
  EX5                VARCHAR2(100 BYTE),
------------------------------------------
    EX6        VARCHAR2(100 BYTE),
    EX7        VARCHAR2(100 BYTE),
    EX8        VARCHAR2(100 BYTE),
    EX9        VARCHAR2(100 BYTE),
    EX10        VARCHAR2(1000 BYTE),
    EX11        VARCHAR2(100 BYTE),
    EX12        VARCHAR2(100 BYTE),
    EX13        VARCHAR2(100 BYTE),
    EX14        VARCHAR2(100 BYTE),
    EX15        VARCHAR2(100 BYTE),
    EX16        VARCHAR2(100 BYTE),
    EX17        VARCHAR2(100 BYTE),
    EX18        VARCHAR2(100 BYTE),
    EX19        VARCHAR2(100 BYTE),
    EX20        VARCHAR2(100 BYTE),
    EX21        VARCHAR2(100 BYTE),
    EX22        VARCHAR2(100 BYTE),
    EX23        VARCHAR2(100 BYTE),
    EX24        VARCHAR2(100 BYTE),
    EX25        VARCHAR2(100 BYTE),
    EX26        VARCHAR2(100 BYTE),
    EX27        VARCHAR2(100 BYTE),
    EX28        VARCHAR2(100 BYTE),
    EX29        VARCHAR2(100 BYTE),
    EX30        VARCHAR2(100 BYTE),
    EX31        VARCHAR2(100 BYTE),
    EX32        VARCHAR2(100 BYTE),
    EX33        VARCHAR2(100 BYTE),
    EX34        VARCHAR2(100 BYTE),
    EX35        VARCHAR2(100 BYTE),
    EX36        VARCHAR2(100 BYTE),
    EX37        VARCHAR2(100 BYTE),
    EX38        VARCHAR2(100 BYTE),
    EX39        VARCHAR2(100 BYTE),
    EX40        VARCHAR2(100 BYTE),
    EX41        VARCHAR2(100 BYTE),
    EX42        VARCHAR2(100 BYTE),
    EX43        VARCHAR2(100 BYTE),
    EX44        VARCHAR2(2000 BYTE) 
)
ON COMMIT PRESERVE ROWS
NOCACHE;


SELECT 'EX'||SLNO||'        VARCHAR2(100 BYTE),' FROM (
SELECT LEVEL+5 SLNO FROM DUAL
CONNECT BY LEVEL <40
)



EXEC proc_salesdoprintgst('DJ0107','0002','01/04/2020','31/03/2021','''2021/G8891''','','D:\SWT_ERP_ONLINE\SWT_Jute\swterp\swterp\\LOGO\LOGO_DJC.JPG','D:\SWT_ERP_ONLINE\SWT_Jute\swterp\swterp\\LOGO\LOGO.JPG')

SELECT SALEBILLNO, SALEBILLDATE, EXCISEINVNO, EXCISEINVDATE, PROFORMAINVNO, PROFORMAINVDATE, SAUDANO, SAUDADATE, BUYERORDERNO, 
BUYERORDERDATE, BROKERCODE, BROKERNAME, BUYERCODE, BUYERNAME, TRANSPORTERCODE, PARTYNAME, ADDRESSNAMEBILL, ADDRESSBILL, 
PINBILL, STATEBILL, GSTNNOBILL, ADDRESSNAMESHIP, ADDRESSSHIP, PINSHIP, STATESHIP, GSTNNOSHIP, DESTINATION, 
VEHICLENO, VESSELORFLIGHT, VESSELFLIGHTNO, CNOTENO, CNOTEDATE, CHALLANNO, CHANNELCODE, BILLSERIALNO, QUALITYCODE, 
HSNCODE, QUALITYMANUALDESC, PACKINGCODE, PACKINGNAME, NOOFPACKINGUNIT, UORCODE, UORNAME, MEASURECODE, TOTALQUANTITY, 
TOTALWEIGHT, PACKSHEETWEIGHT, GROSSWEIGHT, INDIANRATE, TOTALINDIANAMOUNT, GROSSAMOUNTINR, AMTINWORDS, CHARGEDATA, SRL, 
TEXT, BANKCODE, BANKNAME, BANKADDRESS, ACNO, IFCSCODE, COMPANYNAME, COMPANYADDRESS, COMPANYADDRESS1, COMPANYADDRESS2, 
PANNO, COMPANYEMAIL, DIVISIONNAME, GSTNNO, GSTSTATECODE, LOGOPATH, EX1, EX2, EX3, EX4, EX5, EX6, EX7, EX8, EX9, EX10, 
EX11, EX12, EX13, EX14, EX15, EX16, EX17, EX18, EX19, EX20, EX21, EX22, EX23, EX24, EX25, EX26, EX27, EX28, EX29, EX30, 
EX31, EX32, EX33, EX34, EX35, EX36, EX37, EX38, EX39, EX40, EX41, EX42, EX43, EX44 FROM gtt_salesdoprintgst



proc_salesbillprintgst

proc_proformainvdocument_ldw

gtt_proformainvdocument_ldw

TRUNCATE TABLE GTT_PROFORMAINVDOCUMENT_LDW
 
DROP TABLE DALHOUSIE_WEB.GTT_PROFORMAINVDOCUMENT_LDW CASCADE CONSTRAINTS;

CREATE GLOBAL TEMPORARY TABLE DALHOUSIE_WEB.GTT_PROFORMAINVDOCUMENT_LDW
(
  LORRYPASSNO        VARCHAR2(50 BYTE),
  LORRYPASSDATE      DATE,
  BUYERCODE          VARCHAR2(10 BYTE),
  BUYERNAME          VARCHAR2(100 BYTE),
  PARTYADDRESS       VARCHAR2(200 BYTE),
  PARTYVATNO         VARCHAR2(40 BYTE),
  PARTYTINNO         VARCHAR2(40 BYTE),
  PARTYCSTNO         VARCHAR2(40 BYTE),
  QUALITYCODE        VARCHAR2(10 BYTE),
  QUALITYMANUALDESC  VARCHAR2(500 BYTE),
  NOOFPACKINGUNIT    NUMBER(15,4),
  PACKSTYLENAME      VARCHAR2(20 BYTE),
  NETWEIGHT          VARCHAR2(43 BYTE),
  TOTALQUANTITY      NUMBER(15,6),
  MEASURENAME        VARCHAR2(20 BYTE),
  INVOICENO          VARCHAR2(20 BYTE),
  INVOICEDATE        DATE,
  SHIPPINGINSNO      VARCHAR2(53 BYTE),
  SHIPPINGINSDATE    DATE,
  SAUDANO            VARCHAR2(50 BYTE),
  SAUDADATE          DATE,
  CONTRACTNO         VARCHAR2(30 BYTE),
  CONTRACTDATE       DATE,
  DUEDATE            DATE,
  EX1                VARCHAR2(100 BYTE),
  EX2                VARCHAR2(100 BYTE),
  EX3                VARCHAR2(100 BYTE),
  EX4                VARCHAR2(100 BYTE),
  EX5                VARCHAR2(100 BYTE),
  EX6                VARCHAR2(100 BYTE),
  EX7                VARCHAR2(100 BYTE),
  EX8                VARCHAR2(100 BYTE),
  EX9                VARCHAR2(100 BYTE),
  EX10               VARCHAR2(1000 BYTE),
  LOGOPATH           VARCHAR2(100 BYTE),
  COMPANYNAME        VARCHAR2(100 BYTE),
  COMPANYADDRESS     VARCHAR2(250 BYTE),
  COMPANYADDRESS1    VARCHAR2(150 BYTE),
  COMPANYADDRESS2    VARCHAR2(150 BYTE),
  COMPANYADDRESS3    VARCHAR2(150 BYTE),
  COMPANYFAX         VARCHAR2(50 BYTE),
  COMPANYPHONE       VARCHAR2(20 BYTE),
  CINNO              VARCHAR2(50 BYTE),
  DIVISIONNAME       VARCHAR2(100 BYTE),
  DIVISIONADDRESS    VARCHAR2(250 BYTE),
  DIVISIONADDRESS1   VARCHAR2(150 BYTE),
  DIVISIONADDRESS2   VARCHAR2(150 BYTE),
  DIVISIONPHONE      VARCHAR2(100 BYTE),
  DIVISIONFAX        VARCHAR2(50 BYTE),
    EX11        VARCHAR2(100 BYTE),
    EX12        VARCHAR2(100 BYTE),
    EX13        VARCHAR2(100 BYTE),
    EX14        VARCHAR2(100 BYTE),
    EX15        VARCHAR2(100 BYTE),
    EX16        VARCHAR2(100 BYTE),
    EX17        VARCHAR2(100 BYTE),
    EX18        VARCHAR2(100 BYTE),
    EX19        VARCHAR2(100 BYTE),
    EX20        VARCHAR2(100 BYTE),
    EX21        VARCHAR2(100 BYTE),
    EX22        VARCHAR2(100 BYTE),
    EX23        VARCHAR2(100 BYTE),
    EX24        VARCHAR2(100 BYTE),
    EX25        VARCHAR2(100 BYTE),
    EX26        VARCHAR2(100 BYTE),
    EX27        VARCHAR2(100 BYTE),
    EX28        VARCHAR2(100 BYTE),
    EX29        VARCHAR2(100 BYTE),
    EX30        VARCHAR2(100 BYTE),
    EX31        VARCHAR2(100 BYTE),
    EX32        VARCHAR2(100 BYTE),
    EX33        VARCHAR2(100 BYTE),
    EX34        VARCHAR2(100 BYTE),
    EX35        VARCHAR2(100 BYTE),
    EX36        VARCHAR2(100 BYTE),
    EX37        VARCHAR2(100 BYTE),
    EX38        VARCHAR2(100 BYTE),
    EX39        VARCHAR2(100 BYTE),
    EX40        VARCHAR2(100 BYTE),
    EX41        VARCHAR2(100 BYTE),
    EX42        VARCHAR2(100 BYTE),
    EX43        VARCHAR2(100 BYTE),
    EX44        VARCHAR2(2000 BYTE)
)
ON COMMIT PRESERVE ROWS
NOCACHE;

EXEC proc_proformainvdocument_ldw('DJ0107','0002','''2021/G8891''', 'D:\swterp_cjil\\LOGO\LOGO_DJC.JPG')


EXEC proc_proformainvdocument_ldw('DJ0107','0002','''2021/G8891''', 'D:\SWT_ERP_ONLINE\SWT_Jute\swterp\swterp\\LOGO\LOGO_DJC.JPG')

SELECT MENUCODE FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%RJL%')




SELECT * FROM MENUMASTER_RND
WHERE MENUCODE=''

SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG=''


exec proc_salesdoprintgst('DJ0107','0002','01/04/2020','31/03/2021','''2021/G8891''','','D:\swterp_cjil\\LOGO\LOGO_DJC.JPG','D:\swterp_cjil\\LOGO\LOGO.JPG')


select replace(companyname,'Unit : ', chr(10)||'Unit : ') from companymast