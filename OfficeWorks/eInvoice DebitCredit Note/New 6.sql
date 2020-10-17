SELECT * FROM MENUMASTER_RND
WHERE UPPER(MENUDESC) LIKE UPPER('%irn%')

SELECT * FROM MENUMASTER_RND
WHERE MENUCODE=''


SELECT * FROM ROLEDETAILS
WHERE MENUCODE=''


SELECT * FROM REPORTPARAMETERMASTER
WHERE REPORTTAG = 'HOOGHLY GST INVOICE PRINT (IRN)'

SELECT * FROM SYS_TFMAP
WHERE SYS_TABLENAME_ACTUAL=''

HOOGHLY GST INVOICE PRINT (IRN)
HOOGHLY OTHER GST INVOICE PRINT (IRN)
HOOGHLY DR/CR NOTE GST PRINT (IRN)


delete from REPORTPARAMETERMASTER where REPORTTAG='HOOGHLY DR/CR NOTE GST PRINT (IRN)'

Insert into EINVOICE_INFRA.REPORTPARAMETERMASTER
(MODULENAME, REPORTTAG, MAINTABLE, REPORTNAME)
Values
('SALES', 'HOOGHLY DR/CR NOTE GST PRINT (IRN)', 'GTT_REP_DEBITCREDITNOTE', 'SALES/PAGES/Report/Transaction/rptDebitCreditNoteIRN_Hooghly.rdlc');

COMMIT;

F:\SWTERP\SWT_JUTE\swterp\SWTReport\rptDebitCreditNoteIRN_Hooghly.rdl


SELECT DBCRNOTENO SALEBILLNO, DBCRNOTENO || '   Dt. ' || TO_CHAR(DBCRNOTEDATE,'DD/MM/YYYY') SALEBILLDATE1  
FROM SALESGSTDBCRNOTEVIEW WHERE COMPANYCODE='0002'  AND DIVISIONCODE ='0021' 
AND DBCRNOTEDATE BETWEEN TO_DATE('01/04/2020','DD/MM/YYYY') 
AND  TO_DATE('31/03/2021','DD/MM/YYYY') 
ORDER BY DBCRNOTEDATE DESC,  DBCRNOTENO DESC 



exec PROC_RPT_DEBITCREDITNOTE_IRN('0002','0021','01/04/2020','31/03/2021','''H/2021/GC/0076''','DEBIT NOTE','','F:\\SWTERP\\SWT_JUTE\\swterp\\swterp\\\\LOGO\\','F:\\SWTERP\\SWT_JUTE\\swterp\\swterp\\\\LOGO\\','F:\\SWTERP\\SWT_JUTE\\swterp\\swterp\\\\LOGO\\')



~SALES/PAGES/Report/Transaction/rptDebitCreditNoteIRN_Hooghly.rdlc~GTT_REP_INVOICEPRINTGST