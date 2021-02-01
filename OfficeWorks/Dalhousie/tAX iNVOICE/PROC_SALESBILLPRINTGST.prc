CREATE OR REPLACE PROCEDURE DALHOUSIE_WEB."PROC_SALESBILLPRINTGST" 
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_billfrom varchar2,
    p_billto varchar2,
    p_billno varchar2,
    p_logopath varchar2,
    p_logopath2 varchar2,
    p_logopath3 varchar2
)
as 
    lv_sqlstr           varchar2(30000);
    IRN_CNT             NUMBER := 0;
begin
    delete from gtt_salesbillprintgst;
    lv_sqlstr :=   'insert into gtt_salesbillprintgst'|| chr(10)
                || 'SELECT S.SALEBILLNO, S.SALEBILLDATE, S.EXCISEINVNO, S.EXCISEINVDATE, S.PROFORMAINVNO, S.PROFORMAINVDATE, S.SAUDANO, S.SAUDADATE, '|| chr(10)
                || '       /*S.BUYERORDERNO*/S.CONTRACTNO BUYERORDERNO, /*S.BUYERORDERDATE*/CONTRACTDATE BUYERORDERDATE, S.BROKERCODE,''[''|| S.BROKERCODE ||''] ''|| S.BROKERNAME, S.BUYERCODE, S.BUYERNAME, S.TRANSPORTERCODE, P.PARTYNAME, '|| chr(10)
                || '       ''[''|| P1.PARTYCODE ||''] ''||  P1.ADDRESSNAME  ADDRESSNAMEBILL, P1.ADDRESS ||'' Pin : ''||P1.PIN ADDRESSBILL, P1.PIN PINBILL, P1.GSTSTATECODE||'' ''||P1.STATE STATEBILL, P1.GSTNNO GSTNNOBILL, '|| chr(10)
                || '       ''[''|| P2.PARTYCODE ||''] ''|| P2.ADDRESSNAME  ADDRESSNAMESHIP, P2.ADDRESS ||'' Pin : ''||P2.PIN ADDRESSSHIP, P2.PIN PINSHIP, P2.GSTSTATECODE||'' ''||P2.STATE STATESHIP, P2.GSTNNO GSTNNOSHIP, '|| chr(10)
                || '       S.DESTINATION, S.VEHICLENO, S.VESSELORFLIGHT, S.VESSELFLIGHTNO, S.CNOTENO, S.CNOTEDATE, S.CHALLANNO, S.CHANNELCODE, '|| chr(10)
                || '       S.BILLSERIALNO, S.QUALITYCODE, H.HSNCODE,''[''|| S.QUALITYCODE ||''] ''||CHR(10)|| S.QUALITYMANUALDESC||CHR(10)||S.MARKS QUALITYMANUALDESC, S.PACKINGCODE, S.PACKINGNAME, S.NOOFPACKINGUNIT, S.UORCODE,  '|| chr(10)
                || '       S.UORNAME, S.MEASURECODE, S.TOTALQUANTITY, DECODE(S.MEASUREUNIT,''KGS'',S.TOTALWEIGHT,S.TOTALWEIGHT*1) TOTALWEIGHT, DECODE(S.MEASUREUNIT,''KGS'',S.PACKSHEETWEIGHT,S.PACKSHEETWEIGHT*1) PACKSHEETWEIGHT, DECODE(S.MEASUREUNIT,''KGS'',S.GROSSWEIGHT,S.GROSSWEIGHT*1) GROSSWEIGHT, /*S.RATE*/ S.INDIANRATE, /*S.TOTALAMOUNT*/ S.TOTALINDIANAMOUNT, '|| chr(10)
                || '       /*S.GROSSAMOUNT*/ S.GROSSAMOUNTINR, fn_num_to_words(ROUND(S.GROSSAMOUNTINR,2),''RS'') AMTINWORDS, CH.CHARGEDATA, T.SRL, T.TEXT, '|| chr(10)
                || '       C.BANKCODE, B.BANKNAME, B.BANKADDRESS, B.ACNO, C.IFSCCODE IFCSCODE, '|| chr(10)
                || '       C.COMPANYNAME,''Registered office : ''|| C.COMPANYADDRESS, C.COMPANYADDRESS1, C.COMPANYADDRESS2,''PAN : ''||  C.PANNO, C.COMPANYEMAIL, '|| chr(10)
                || '       D.DIVISIONNAME, D.GSTNNO, D.GSTSTATECODE, '''||p_logopath||''' LOGOPATH, C.CINNO EX1,  '|| chr(10)
                || '       CASE WHEN CHANNELTAG=''EXPORT'' AND CH.CHARGEDATA LIKE ''%GST%'' THEN ''SUPPLY MEANT FOR EXPORT ON PAYMENT OF INTEGRATED TAX'' WHEN CHANNELTAG=''EXPORT'' AND CH.CHARGEDATA NOT LIKE ''%GST%'' THEN ''SUPPLY MEANT FOR EXPORT UNDER BOND OR LETTER OF UNDERTAKING WITHOUT PAYMENT OF INTERGREATED TAX'' ELSE '''' END EX2, S.CURRENCYCODE EX3, S.PACKSTYLECODE EX4, '''||p_logopath2||''' EX5, '|| chr(10)
                || '       S.EWAYBILLNO, S.EWAYBILLDATE, S.TIME_STAMP, TO_CHAR(S.SALEBILLDATE,''DD/MM/YYYY'')||''  ''||S.TIMEOFPREPARATION EX6,S.PCONUMBER EX7, TO_CHAR(S.PCODATE,''DD/MM/YYYY'') EX8, REMARKSPRO EX9, S.CHANNELTAG EX10, '|| chr(10)
                ||'        '''||p_logopath3||''' EX11, NULL EX12, NULL EX13, NULL EX14, NULL EZ15 ,   '||CHR(10)
                ||'        ''FAX : ''||COMPANYFAX EX16, ''COUNTRY : ''|| C.COMPANYCOUNTRY EX17,''STATE : ''||C.COMPANYSTATE ||''   STATE CODE : ''||D.GSTSTATECODE EX18,''Registered office : ''|| C.COMPANYADDRESS1/*USED FOR FOOTER PART NOTE*/ EX19,C.COMPANYHOPHONE1 EX20,/*CASE WHEN S.DOCUMENTTYPE=''SALE MEMO'' AND CHANNELTAG=''EXPORT''  THEN ''DELIVERY CHALLAN'' ELSE ''TAX INVOICE'' END*/''TAX INVOICE''  EX21,NULL /*AmendmentNo. 1*/ EX22,NULL /*AmendmentNo. Date*/ EX23,NULL /*AmendmentNo. 2*/ EX24,NULL /*AmendmentNo. Date*/  EX25,S.SHIPPINGINSNO EX26,TO_CHAR(S.SHIPPINGINSDATE,''DD/MM/YYYY'') EX27,CASE WHEN CHANNELTAG=''EXPORT'' THEN S.PROFORMAINVNO ELSE NULL END EX28,CASE WHEN CHANNELTAG=''EXPORT'' THEN TO_CHAR(S.PROFORMAINVDATE,''DD/MM/YYYY'') ELSE NULL END EX29, '||CHR(10)
                ||'        RTRIM(LTRIM(P.PARTYADDRESS)) ||'' City : ''||P.PARTYCITY ||'' Pin : ''||P.PARTYPIN ||'' GSTIN : ''||P.GSTNNO EX30,S.CONTAINERNO EX31,S.SEALNO EX32,NULL /*E SEAL NO*/ EX33,S.BOOKING EX34,F.LUTNO /*LUT NO*/ EX35,TO_CHAR(F.LUTDATE,''DD/MM/YYYY'')/*LUT DATE*/ EX36,NULL EX37,''Registered office : ''|| C.COMPANYADDRESS1 ||'' ''||C.COMPANYADDRESS2 EX38,NULL EX39,NULL EX40,NULL EX41,NULL EX42,NULL EX43, '||CHR(10)
                ||'        NULL EX44,NULL EX45,NULL EX46,NULL EX47,NULL EX48,NULL EX49,NULL EX50,NULL EX51,NULL EX52,NULL EX53,NULL EX54,NULL EX55,NULL EX56, '||CHR(10)
                ||'        NULL EX57,NULL EX58,NULL EX59,NULL EX60'||CHR(10)
                || 'FROM SALESBILLVIEW S, COMPANYMAST C, DIVISIONMASTER D, PARTYADDRESS P1, PARTYADDRESS P2, PARTYMASTER P, GSTITEMVSHSNMAPPING H, SALESBANKMASTER B,FINANCIALYEAR F, '|| chr(10)
                || '     ( '|| chr(10)
                || '      SELECT DOCUMENTNO, rtrim(xmlagg(xmlelement(e, X.CHARGESHORTNAME || ''             ''|| X.CHARGEAMOUNT || ''~'')order by X.SERIALNO).extract (''//text()''),''~'') CHARGEDATA '|| chr(10)
                || '        FROM ( '|| chr(10)
                || '        SELECT D.DOCUMENTNO, M.CHARGESHORTNAME, TO_CHAR(CHARGEAMOUNT,''9999999990.99'') CHARGEAMOUNT, TO_NUMBER(SERIALNO) SERIALNO '|| chr(10)
                || '        FROM SALESCHARGEDETAILS D, CHARGEMASTER M '|| chr(10)
                || '        WHERE D.COMPANYCODE=M.COMPANYCODE '|| chr(10)
                || '        AND D.DIVISIONCODE=M.DIVISIONCODE '|| chr(10)
                || '        AND D.CHARGECODE=M.CHARGECODE '|| chr(10)
                || '        AND D.CHANNELCODE=M.CHANNELCODE '|| chr(10)
                || '        AND M.MODULE=''SALES'' '|| chr(10)
                || '        AND M.CHARGETYPE NOT LIKE ''GST_%'' '|| chr(10)
                || '        AND D.COMPANYCODE='''||p_companycode||''' '|| chr(10)
                || '        AND D.DIVISIONCODE='''||p_divisioncode||''' '|| chr(10)
                || '        AND D.DOCUMENTTYPE=''SALE BILL'' '|| chr(10)
                || '        UNION ALL '|| chr(10)
                || '        SELECT D.DOCUMENTNO, ''TAXABLE VALUE'' CHARGESHORTNAME, TO_CHAR(MAX(NVL(ASSESSABLEAMOUNT,0)),''9999999990.99'') CHARGEAMOUNT, MIN(TO_NUMBER(SERIALNO))-0.1 SERIALNO '|| chr(10)
                || '        FROM SALESCHARGEDETAILS D, CHARGEMASTER M '|| chr(10)
                || '        WHERE D.COMPANYCODE=M.COMPANYCODE '|| chr(10)
                || '        AND D.DIVISIONCODE=M.DIVISIONCODE '|| chr(10)
                || '        AND D.CHARGECODE=M.CHARGECODE '|| chr(10)
                || '        AND D.CHANNELCODE=M.CHANNELCODE '|| chr(10)
                || '        AND M.MODULE=''SALES'' '|| chr(10)
                || '        AND M.CHARGETYPE LIKE ''GST_%'' '|| chr(10)
                || '        AND D.COMPANYCODE='''||p_companycode||''' '|| chr(10)
                || '        AND D.DIVISIONCODE='''||p_divisioncode||''' '|| chr(10)
                || '        AND D.DOCUMENTTYPE=''SALE BILL'' '|| chr(10)
                || '        GROUP BY D.DOCUMENTNO '|| chr(10)
                || '        UNION ALL '|| chr(10)
                || '        SELECT D.DOCUMENTNO, M.CHARGESHORTNAME, TO_CHAR(CHARGEAMOUNT,''9999999990.99'') CHARGEAMOUNT, TO_NUMBER(SERIALNO) SERIALNO '|| chr(10)
                || '        FROM SALESCHARGEDETAILS D, CHARGEMASTER M '|| chr(10)
                || '        WHERE D.COMPANYCODE=M.COMPANYCODE '|| chr(10)
                || '        AND D.DIVISIONCODE=M.DIVISIONCODE '|| chr(10)
                || '        AND D.CHARGECODE=M.CHARGECODE '|| chr(10)
                || '        AND D.CHANNELCODE=M.CHANNELCODE '|| chr(10)
                || '        AND M.MODULE=''SALES'' '|| chr(10)
                || '        AND M.CHARGETYPE LIKE ''GST_%'' '|| chr(10)
                || '        AND D.COMPANYCODE='''||p_companycode||''' '|| chr(10)
                || '        AND D.DIVISIONCODE='''||p_divisioncode||''' '|| chr(10)
                || '        AND D.DOCUMENTTYPE=''SALE BILL'' '|| chr(10)
                || '        ORDER BY SERIALNO '|| chr(10)
                || '        ) X '|| chr(10)
                || '        GROUP BY DOCUMENTNO '|| chr(10)
                || '     ) CH, '|| chr(10)
                || '     ( '|| chr(10)
                || '        SELECT 1 SRL, ''Original Copy'' TEXT FROM DUAL '|| chr(10)
                || '        UNION ALL '|| chr(10)
                || '        SELECT 2 SRL, ''Duplicate For Transporter'' TEXT FROM DUAL '|| chr(10)
                || '        UNION ALL '|| chr(10)
                || '        SELECT 3 SRL, ''Mill Copy'' TEXT FROM DUAL '|| chr(10)
                || '        UNION ALL '|| chr(10)
                || '        SELECT 4 SRL, ''Extra Copy'' TEXT FROM DUAL '|| chr(10)
                || '     ) T '|| chr(10)
                || 'WHERE S.COMPANYCODE=C.COMPANYCODE '|| chr(10)
                || 'AND S.COMPANYCODE=D.COMPANYCODE '|| chr(10)
                || 'AND S.DIVISIONCODE=D.DIVISIONCODE '|| chr(10)
                || 'AND S.COMPANYCODE=H.COMPANYCODE '|| chr(10)
                || 'AND S.QUALITYCODE=H.ITEMCODE '|| chr(10)
                || 'AND H.MODULE=''SALES'' '|| chr(10)
                || 'AND C.COMPANYCODE=B.COMPANYCODE(+) '|| chr(10)
                || 'AND B.DIVISIONCODE(+)='''||p_divisioncode||''' '|| chr(10)
                || 'AND C.BANKCODE=B.BANKCODE(+) '|| chr(10)
                || 'AND C.IFSCCODE=B.IFSCCODE(+) '|| chr(10)
                || 'AND S.SALEBILLNO=CH.DOCUMENTNO(+) '|| chr(10)
                || 'AND S.COMPANYCODE=P1.COMPANYCODE(+) '|| chr(10)
                || 'AND S.BUYERCODE=P1.PARTYCODE(+) '|| chr(10)
                || 'AND S.ADDRESSCODEBILL=P1.ADDRESSCODE(+) '|| chr(10)
                || 'AND P1.MODULE(+)=''SALES'' '|| chr(10)
                || 'AND S.COMPANYCODE=P2.COMPANYCODE(+) '|| chr(10)
                || 'AND S.BUYERCODE=P2.PARTYCODE(+) '|| chr(10)
                || 'AND S.ADDRESSCODE=P2.ADDRESSCODE(+) '|| chr(10)
                || 'AND P2.MODULE(+)=''SALES'' '|| chr(10)
                || 'AND S.COMPANYCODE=P.COMPANYCODE(+) '|| chr(10)
                || 'AND S.TRANSPORTERCODE=P.PARTYCODE(+) '|| chr(10)
                || 'AND P.MODULE(+)=''SALES'' '|| chr(10)
                || 'AND P.PARTYTYPE(+)=''TRANSPORTER'' '|| chr(10)
                || 'AND S.COMPANYCODE='''||p_companycode||''' '|| chr(10)
                || 'AND S.DIVISIONCODE='''||p_divisioncode||''' '|| chr(10)
                || 'AND S.COMPANYCODE=F.COMPANYCODE'|| chr(10)
                || 'AND S.DIVISIONCODE=F.DIVISIONCODE'|| chr(10)
                || 'AND S.YEARCODE=F.YEARCODE'|| chr(10)
                || 'AND S.SALEBILLDATE>=TO_DATE('''||p_billfrom||''',''DD/MM/YYYY'') '|| chr(10)
                || 'AND S.SALEBILLDATE<=TO_DATE('''||p_billto||''',''DD/MM/YYYY'') '|| chr(10);
                if p_billno is not null then
                    lv_sqlstr := lv_sqlstr || ' AND S.SALEBILLNO IN ('||p_billno||') '|| chr(10);
                end if;
                lv_sqlstr := lv_sqlstr || 'ORDER BY S.SALEBILLNO, T.SRL, S.BILLSERIALNO '|| chr(10);
    
  -- DBMS_OUTPUT.PUT_LINE(lv_sqlstr);
    execute immediate lv_sqlstr;
    
    
         -----IRN DATA UPDATE -----------------------
    lv_sqlstr:=' SELECT COUNT(*)    '||CHR(10)
             ||'   FROM EINVOICE_MAIN   '||CHR(10)
             ||'  WHERE DOCNO IN ('||p_billno||')    '||CHR(10)
             ||'    AND SIGNEDQRCODE IS NOT NULL     '||CHR(10);

--DBMS_OUTPUT.PUT_LINE(lv_sqlstr);
    execute immediate lv_sqlstr INTO IRN_CNT;


    IF IRN_CNT > 0 THEN
        lv_sqlstr:='      UPDATE gtt_salesbillprintgst  '||CHR(10)
                 ||'         SET (EX12, EX13) = (SELECT IRN, SIGNEDQRCODE FROM EINVOICE_MAIN WHERE DOCNO IN ('||p_billno||'))  '||CHR(10); 
    
--     DBMS_OUTPUT.PUT_LINE(lv_sqlstr);
       execute immediate lv_sqlstr;
    END IF;
    
--    UPDATE GTT_SALESBILLPRINTGST SET EX13='DELIVERY CHALLAN' 
--    WHERE EX21='DELIVERY CHALLAN';
    
      
    UPDATE gtt_salesbillprintgst SET EX37=(
    SELECT  
    TEXT STATURITYTEXT 
    FROM STATURITYTEXT x
    WHERE X.COMPANYCODE = p_companycode
    AND X.DIVISIONCODE = p_divisioncode
    AND X.REPORTTAG='GST INVOICE PRINT'
    AND x.serialno='1' AND ROWNUM=1);
    
    
     UPDATE gtt_salesbillprintgst A SET (EX22,EX23)=
     (SELECT AMMENDMENTNO,TO_CHAR(AMMENDMENTDATE,'DD/MM/YYYY') FROM SALESPROFORMAADDINFODTL B
       WHERE B.COMPANYCODE=p_companycode
       AND B.DIVISIONCODE=p_divisioncode
         AND A.PROFORMAINVNO=B.PROFORMAINVNO
         AND A.PROFORMAINVDATE=B.PROFORMAINVDATE
         AND B.AMMENDMENTSRLNO=1 
      )
     WHERE SALEBILLNO IN
     (
     SELECT DISTINCT SALEBILLNO FROM gtt_salesbillprintgst
     ) ;
     
     UPDATE gtt_salesbillprintgst A SET (EX24,EX25)=
     (SELECT AMMENDMENTNO,TO_CHAR(AMMENDMENTDATE,'DD/MM/YYYY') FROM SALESPROFORMAADDINFODTL B
       WHERE B.COMPANYCODE=p_companycode
       AND B.DIVISIONCODE=p_divisioncode
         AND A.PROFORMAINVNO=B.PROFORMAINVNO
         AND A.PROFORMAINVDATE=B.PROFORMAINVDATE
         AND B.AMMENDMENTSRLNO=2 
      )
     WHERE SALEBILLNO IN
     (
     SELECT DISTINCT SALEBILLNO FROM gtt_salesbillprintgst
     ) ;
    
    
end;
/
