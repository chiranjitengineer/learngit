exec proc_salesOTHERSbillprintgst('DJ0107','0002', '01/04/2020', '31/03/2021', '''DJC/2021/R0108''', 'D:\SWT_ERP_ONLINE\SWT_Jute\swterp\swterp\\LOGO\LOGO_DJC.JPG', 'D:\SWT_ERP_ONLINE\SWT_Jute\swterp\swterp\\LOGO\LOGO.JPG','D:\SWT_ERP_ONLINE\SWT_Jute\swterp\swterp\\LOGO\DRAFT_WTR2.png')

SELECT * FROM GTT_SALESOTHERBILLPRINTGST

~SALES/Pages/Report/Transaction/rptSALESOTHERSBILLPRINTGST_LDW.rdlc~gtt_salesotherbillprintgst

="CIN NO : " & Fields!EX1.Value & vbcrlf &
Fields!COMPANYADDRESS.Value & vbcrlf &
"E-mail : " & Fields!COMPANYEMAIL.Value & vbcrlf &
"Phone : " & Fields!EX20.Value & vbcrlf &
Fields!EX16.Value & vbcrlf &
Fields!PANNO.Value & vbcrlf &
Fields!COMPANYADDRESS1.Value & vbcrlf &
"GSTIN : " & Fields!GSTNNO.Value & vbcrlf &
Fields!EX17.Value & vbcrlf &
Fields!EX18.Value


SALEBILLNO, SALEBILLDATE, EXCISEINVNO, EXCISEINVDATE, PROFORMAINVNO, PROFORMAINVDATE, SAUDANO, SAUDADATE, 
BUYERORDERNO, BUYERORDERDATE, BROKERCODE, BROKERNAME, BUYERCODE, BUYERNAME, TRANSPORTERCODE, PARTYNAME, 
ADDRESSNAMEBILL, ADDRESSBILL, PINBILL, STATEBILL, GSTNNOBILL, ADDRESSNAMESHIP, ADDRESSSHIP, PINSHIP, 
STATESHIP, GSTNNOSHIP, DESTINATION, VEHICLENO, VESSELORFLIGHT, VESSELFLIGHTNO, CNOTENO, CNOTEDATE, 
CHALLANNO, CHANNELCODE, BILLSERIALNO, QUALITYCODE, HSNCODE, QUALITYMANUALDESC, PACKINGCODE, PACKINGNAME, 
NOOFPACKINGUNIT, UORCODE, UORNAME, MEASURECODE, TOTALQUANTITY, TOTALWEIGHT, PACKSHEETWEIGHT, GROSSWEIGHT, 
INDIANRATE, TOTALINDIANAMOUNT, GROSSAMOUNTINR, AMTINWORDS, CHARGEDATA, SRL, TEXT, BANKCODE, BANKNAME, 
BANKADDRESS, ACNO, IFCSCODE, COMPANYNAME, COMPANYADDRESS, COMPANYADDRESS1, COMPANYADDRESS2, PANNO, 
COMPANYEMAIL, DIVISIONNAME, GSTNNO, GSTSTATECODE, LOGOPATH, EX1, EX2, EX3, EX4, EX5



------------------------------------------------------------------------------
----TAX INVOICE

EXEC proc_salesbillprintgst('DJ0107','0002','01/04/2020','31/03/2021','''DJC/2021/G1903''','D:\SWT_ERP_ONLINE\SWT_Jute\swterp\swterp\\LOGO\LOGO_DJC.JPG','D:\SWT_ERP_ONLINE\SWT_Jute\swterp\swterp\\LOGO\LOGO.JPG','D:\SWT_ERP_ONLINE\SWT_Jute\swterp\swterp\\LOGO\DRAFT_WTR2.png')

~SALES/Pages/Report/Transaction/rptSALESBILLPRINTGST_DJC_IRN.rdlc~GTT_SALESBILLPRINTGST




--------------------------------------------------------------------------------
----TAX INVOICE CANCEL

EXEC proc_salesbillprintgst_CAN('DJ0107','0002','01/04/2020','31/03/2021','''DJC/2021/G1903''','D:\SWT_ERP_ONLINE\SWT_Jute\swterp\swterp\\LOGO\LOGO_DJC.JPG','D:\SWT_ERP_ONLINE\SWT_Jute\swterp\swterp\\LOGO\LOGO.JPG','D:\SWT_ERP_ONLINE\SWT_Jute\swterp\swterp\\LOGO\DRAFT_WTR2.png')

~SALES/Pages/Report/Transaction/rptSALESBILLPRINTGST_DJC_IRN.rdlc~GTT_SALESBILLPRINTGST

SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%TAX INVOICE%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE=''

SELECT * FROM ROLEDETAILS
WHERE MENUCODE='GST INVOICE PRINT'

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG='GST INVOICE PRINT'

SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG='TAX INVOICE CANCEL'

TAX INVOICE CANCEL

GST INVOICE PRINT


SET DEFINE OFF;
Insert into REPORTPARAMETERMASTER
   (MODULENAME, REPORTTAG, REPORTTAG1, REPORTTAG2, REPORTTAG3, MAINTABLE, SUBREPORTTABLE, SUBREPORTTABLE1, SUBREPORTTABLE2, SUBREPORTTABLE3, SUBREPORTTABLE4, REPORTNAME)
 Values
   ('SALES', 'TAX INVOICE CANCEL', NULL, NULL, NULL, 
    'GTT_SALESBILLPRINTGST', NULL, NULL, NULL, NULL, 
    NULL, 'SALES/Pages/Report/Transaction/rptSALESBILLPRINTGST_DJC_IRN_CANCEL.rdlc');
COMMIT;



SELECT * FROM MODULEWISELOGO


SALES/Pages/Report/Transaction/rptSALESBILLPRINTGST_DJC_IRN.rdlc