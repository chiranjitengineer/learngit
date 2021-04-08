CREATE OR REPLACE PROCEDURE DALHOUSIE_WEB."PROC_SALESBILLREGISTERALL" 
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_billfrom varchar2,
    p_billto varchar2,
    p_channel varchar2,
    p_buyer varchar2,
    p_type varchar2,
    p_option varchar2 DEFAULT NULL
)
as 
    lv_sqlstr               varchar2(30000);
    lv_cnt                  number;
    lv_percentage           NUMBER(18,6):=0;
    lv_assessableamt        NUMBER(18,6):=0;
    lv_sgstamount           NUMBER(18,6):=0;
    lv_cgstamount           NUMBER(18,6):=0;
    lv_igstamount           number(18,6):=0;
    lv_totassessableamt     NUMBER(18,6):=0;
    lv_totsgstamount        NUMBER(18,6):=0;
    lv_totcgstamount        NUMBER(18,6):=0;
    lv_totigstamount        number(18,6):=0;
    lv_rownum               number(5):=0;
begin
    delete from gtt_salesbillregisterall;
    lv_sqlstr :=   'insert into gtt_salesbillregisterall '|| chr(10)
                || 'SELECT A.CHANNELCODE,A.SALEBILLNO,A.SALEBILLDATE,A.BILLSERIALNO,A.BUYERCODE,A.ADDRESSCODE,A.ADDRESSCODEBILL,F.HSNCODE,A.QUALITYCODE,SUBSTR(REPLACE(REPLACE(A.QUALITYMANUALDESC,CHR(13),''''),CHR(10),''''),1,25) QUALITYMANUALDESC, '|| chr(10)
                || '       CASE WHEN MEASUREUNIT=''KGS'' THEN A.TOTALWEIGHT/1000 ELSE A.TOTALWEIGHT END WTINMT, '|| chr(10)
                || '       A.NOOFPACKINGUNIT, A.PACKSTYLENAME, A.TOTALINDIANAMOUNT, A.NETINDIANAMOUNT,0 ASSESSABLEAMOUNT, B.CHARGECODE, B.CHARGEAMOUNT,C.CHARGESHORTNAME,C.SERIALNO,C.CHARGETYPE , '|| chr(10)
                || '       D.ADDRESSNAME SHIPNAME,D.ADDRESS SHIPADDRESS,E.ADDRESSNAME BILLNAME,E.ADDRESS BILLADDRESS,A.SHIPSTATECODE, A.BILLSTATECODE, '|| chr(10)
                || '       G.COMPANYNAME, NULL EX1, NULL EX2, NULL EX3, NULL EX4, NULL EX5 '|| chr(10)
                || 'FROM SALESBILLVIEW A, SALESLINEWISECHARGEDETAILS B,CHARGEMASTER C,PARTYADDRESS D,PARTYADDRESS E, GSTITEMVSHSNMAPPING F, COMPANYMAST G '|| chr(10)
                || 'WHERE A.COMPANYCODE='''||p_companycode||''' '|| chr(10)
                || '  AND A.DIVISIONCODE='''||p_divisioncode||''' '|| chr(10)
                || '  AND A.SALEBILLDATE>=TO_DATE('''||p_billfrom||''',''DD/MM/YYYY'') '|| chr(10)
                || '  AND A.SALEBILLDATE<=TO_DATE('''||p_billto||''',''DD/MM/YYYY'') '|| chr(10);
                if p_channel is not null then
                    lv_sqlstr := lv_sqlstr || '  AND A.CHANNELCODE IN ('||p_channel||') '|| chr(10);
                end if;
                if p_buyer is not null then
                    lv_sqlstr := lv_sqlstr || '  AND A.BUYERCODE IN ('||p_buyer||') '|| chr(10);
                end if;
                if p_type = 'GST BILL' then
                    lv_sqlstr := lv_sqlstr || '  AND A.SALEBILLNO NOT LIKE ''%SEI%'' '|| chr(10);
                end if;
                if p_type = 'COMMERCIAL BILL' then
                    lv_sqlstr := lv_sqlstr || '  AND A.SALEBILLNO LIKE ''%SEI%'' '|| chr(10);
                end if;
                if p_option = 'BILL' then
                    lv_sqlstr := lv_sqlstr || '  AND A.AGAINSTINVNO IS NULL '|| chr(10);
                end if;
                if p_option = 'DR-CR NOTE' then
                    lv_sqlstr := lv_sqlstr || '  AND A.AGAINSTINVNO IS NOT NULL '|| chr(10);
                end if;
                lv_sqlstr := lv_sqlstr || '  AND A.COMPANYCODE=B.COMPANYCODE(+) '|| chr(10)
                || '  AND A.DIVISIONCODE=B.DIVISIONCODE(+) '|| chr(10)
                || '  AND A.SALEBILLNO=B.DOCUMENTNO(+) '|| chr(10)
                || '  AND A.SALEBILLDATE=B.DOCUMENTDATE(+) '|| chr(10)
                || '  AND A.BILLSERIALNO=B.SERIALNO(+) '|| chr(10)
                || '  /*AND B.DOCUMENTTYPE(+) IN (''SALE BILL'',''SALE BILL RETURN'',''CREDIT NOTE'',''DEBIT NOTE'')*/ '|| chr(10)
                || '  AND INSTR(''SALE BILL~,SALE BILL RETURN~,CREDIT NOTE~,DEBIT NOTE~'',  B.DOCUMENTTYPE(+) || ''~'')>0 '|| chr(10)
                || '  AND B.COMPANYCODE=C.COMPANYCODE(+) '|| chr(10)
                || '  AND B.DIVISIONCODE=C.DIVISIONCODE(+) '|| chr(10)
                || '  AND B.CHARGECODE=C.CHARGECODE(+) '|| chr(10)
                || '  AND C.MODULE(+)=''SALES'' '|| chr(10)
                || '  AND A.CHANNELCODE=B.CHANNELCODE(+) '|| chr(10)
                || '  AND B.CHANNELCODE=C.CHANNELCODE(+) '|| chr(10)
                || '  AND A.COMPANYCODE=D.COMPANYCODE '|| chr(10)
                || '  AND A.COMPANYCODE=E.COMPANYCODE '|| chr(10)
                || '  AND A.BUYERCODE=D.PARTYCODE '|| chr(10)
                || '  AND A.BUYERCODE=E.PARTYCODE '|| chr(10)
                || '  AND D.PARTYTYPE=''BUYER'' '|| chr(10)
                || '  AND E.PARTYTYPE=''BUYER''   '|| chr(10)
                || '  AND A.ADDRESSCODE=D.ADDRESSCODE '|| chr(10)
                || '  AND A.ADDRESSCODEBILL=E.ADDRESSCODE '|| chr(10)
                || '  AND A.COMPANYCODE=F.COMPANYCODE '|| chr(10)
                || '  AND A.QUALITYCODE=F.ITEMCODE '|| chr(10)
                || '  AND F.MODULE=''SALES'' '|| chr(10)
                || '  AND A.COMPANYCODE=G.COMPANYCODE '|| chr(10)
                || 'UNION ALL '|| chr(10)
                || 'SELECT A1.CHANNELCODE,A1.SALESBILLNO,A1.SALESBILLDATE,A2.SERIALNO,A1.PARTYCODE BUYERCODE,A1.ADDRESSCODE,A1.ADDRESSCODEBILL,A2.HSNCODE,NULL QUALITYCODE,A2.ITEMDESC QUALITYMANUALDESC, '|| chr(10)
                || '       CASE WHEN A2.UOMCODE=''KGS'' THEN A2.QUANTITY/1000 ELSE A2.QUANTITY END WTINMT, '|| chr(10)
                || '       A2.QUANTITY NOOFPACKINGUNIT, NULL PACKSTYLENAME, A2.AMOUNT TOTALINDIANAMOUNT, A1.GROSSAMT, 0 ASSESSABLEAMOUNT, B.CHARGECODE, B.CHARGEAMOUNT,C.CHARGESHORTNAME,C.SERIALNO,C.CHARGETYPE , '|| chr(10)
                || '       D.ADDRESSNAME SHIPNAME,D.ADDRESS SHIPADDRESS,E.ADDRESSNAME BILLNAME,E.ADDRESS BILLADDRESS,NULL SHIPSTATECODE, A1.BILLSTATECODE, '|| chr(10)
                || '       G.COMPANYNAME, NULL EX1, NULL EX2, NULL EX3, NULL EX4, NULL EX5 '|| chr(10)
                || ' FROM SALESOTHERBILLMASTER A1, SALESOTHERBILLDETAIL A2, SALESLINEWISECHARGEDETAILS B,CHARGEMASTER C,PARTYADDRESS D,PARTYADDRESS E, COMPANYMAST G '|| chr(10)
                || 'WHERE A1.COMPANYCODE='''||p_companycode||''' '|| chr(10)
                || '  AND A1.DIVISIONCODE='''||p_divisioncode||''' '|| chr(10)
                || '  AND A1.SALESBILLDATE>=TO_DATE('''||p_billfrom||''',''DD/MM/YYYY'') '|| chr(10)
                || '  AND A1.SALESBILLDATE<=TO_DATE('''||p_billto||''',''DD/MM/YYYY'') '|| chr(10);
                if p_channel is not null then
                    lv_sqlstr := lv_sqlstr || '  AND A1.CHANNELCODE IN ('||p_channel||') '|| chr(10);
                end if;
                if p_buyer is not null then
                    lv_sqlstr := lv_sqlstr || '  AND A1.PARTYCODE IN ('||p_buyer||') '|| chr(10);
                end if;
                if p_type = 'COMMERCIAL BILL' then
                    lv_sqlstr := lv_sqlstr || '  AND A1.SALESBILLNO LIKE ''%CE%'' '|| chr(10);
                end if;
                if p_option = 'DR-CR NOTE' then
                    lv_sqlstr := lv_sqlstr || '  AND 1=2 '|| chr(10);
                end if;
                lv_sqlstr := lv_sqlstr || '  AND A1.COMPANYCODE=A2.COMPANYCODE '|| chr(10)
                || '  AND A1.DIVISIONCODE=A2.DIVISIONCODE '|| chr(10)
                || '  AND A1.SALESBILLNO=A2.SALESBILLNO '|| chr(10)
                || '  AND A2.COMPANYCODE=B.COMPANYCODE(+) '|| chr(10)
                || '  AND A2.DIVISIONCODE=B.DIVISIONCODE(+) '|| chr(10)
                || '  AND A2.CHANNELCODE=B.CHANNELCODE(+) '|| chr(10)
                || '  AND A2.SALESBILLNO=B.DOCUMENTNO(+) '|| chr(10)
                || '  AND A2.SALESBILLDATE=B.DOCUMENTDATE(+) '|| chr(10)
                || '  AND A2.SERIALNO=B.SERIALNO(+) '|| chr(10)
                || '  /*AND B.DOCUMENTTYPE(+) IN(''SALE BILL'',''SALE BILL RETURN'',''OTHERS BILL'',''SCRAP BILL'')*/ '|| chr(10)
                || '  AND INSTR(''SALE BILL~,SALE BILL RETURN~,OTHERS BILL~,SCRAP BILL~'',  B.DOCUMENTTYPE(+) || ''~'')>0 '|| chr(10)
                || '  AND B.COMPANYCODE=C.COMPANYCODE(+) '|| chr(10)
                || '  AND B.DIVISIONCODE=C.DIVISIONCODE(+) '|| chr(10)
                || '  AND B.CHARGECODE=C.CHARGECODE(+) '|| chr(10)
                || '  AND C.MODULE(+)=''SALES'' '|| chr(10)
                || '  AND B.CHANNELCODE=C.CHANNELCODE(+) '|| chr(10)
                || '  AND A1.COMPANYCODE=D.COMPANYCODE '|| chr(10)
                || '  AND A1.COMPANYCODE=E.COMPANYCODE '|| chr(10)
                || '  AND A1.PARTYCODE=D.PARTYCODE '|| chr(10)
                || '  AND A1.PARTYCODE=E.PARTYCODE '|| chr(10)
                || '  AND D.PARTYTYPE=''BUYER'' '|| chr(10)
                || '  AND E.PARTYTYPE=''BUYER'' '|| chr(10)
                || '  AND A1.ADDRESSCODE=D.ADDRESSCODE '|| chr(10)
                || '  AND A1.ADDRESSCODEBILL=E.ADDRESSCODE '|| chr(10)
                || '  AND A1.COMPANYCODE=G.COMPANYCODE '|| chr(10);

    DBMS_OUTPUT.PUT_LINE(lv_sqlstr);
    --RETURN;
    execute immediate lv_sqlstr;
    
    insert into gtt_salesrowwisechrge(salebillno, billserialno, materialamt, totalmaterialamt, totalassessableamt, totalsgstamt, totalcgstamt, totaligstamt)
    select salebillno, billserialno,totalindianamount,netindianamount,
           nvl((
            select sum(assessableamount)
            from saleschargedetails d, chargemaster m
            where d.companycode=m.companycode
            and d.divisioncode=m.divisioncode
            and d.channelcode=m.channelcode
            and d.chargecode=m.chargecode
            and m.module='SALES'
            and m.chargetype like 'GST_WS_SGST_%'
            and d.companycode=p_companycode
            and d.documentno=a.salebillno
           ),0)+
           nvl((
            select sum(assessableamount)
            from saleschargedetails d, chargemaster m
            where d.companycode=m.companycode
            and d.divisioncode=m.divisioncode
            and d.channelcode=m.channelcode
            and d.chargecode=m.chargecode
            and m.module='SALES'
            and m.chargetype like 'GST_OS_IGST_%'
            and d.companycode=p_companycode
            and d.documentno=a.salebillno
           ),0) totalassessableamt,
           nvl((
            select sum(chargeamount)
            from saleschargedetails d, chargemaster m
            where d.companycode=m.companycode
            and d.divisioncode=m.divisioncode
            and d.channelcode=m.channelcode
            and d.chargecode=m.chargecode
            and m.module='SALES'
            and m.chargetype like 'GST_WS_SGST_%'
            and d.companycode=p_companycode
            and d.documentno=a.salebillno
           ),0) sgstamount,
           nvl((
            select sum(chargeamount)
            from saleschargedetails d, chargemaster m
            where d.companycode=m.companycode
            and d.divisioncode=m.divisioncode
            and d.channelcode=m.channelcode
            and d.chargecode=m.chargecode
            and m.module='SALES'
            and m.chargetype like 'GST_WS_CGST_%'
            and d.companycode=p_companycode
            and d.documentno=a.salebillno
           ),0) cgstamount,
           nvl((
            select sum(chargeamount)
            from saleschargedetails d, chargemaster m
            where d.companycode=m.companycode
            and d.divisioncode=m.divisioncode
            and d.channelcode=m.channelcode
            and d.chargecode=m.chargecode
            and m.module='SALES'
            and m.chargetype like 'GST_OS_IGST_%'
            and d.companycode=p_companycode
            and d.documentno=a.salebillno
           ),0) igstamount
    from (
        select salebillno,billserialno,totalindianamount,netindianamount
          from salesbillview
         where companycode = p_companycode
           and divisioncode = p_divisioncode
        union all
        select salesbillno,serialno,amount,amount
          from salesotherbilldetail
         where companycode = p_companycode
           and divisioncode = p_divisioncode
    ) a;
        
    for c2 in (select salebillno, billserialno, materialamt, totalmaterialamt, totalassessableamt, totalsgstamt, totalcgstamt, totaligstamt from gtt_salesrowwisechrge order by salebillno, billserialno)
    loop
        select count(*)
        into lv_cnt
        from gtt_salesrowwisechrge
        where salebillno=c2.salebillno;
    
        lv_rownum:=lv_rownum+1;
        if lv_cnt=lv_rownum then
            lv_percentage:=100-lv_percentage;
            lv_assessableamt:=c2.totalassessableamt-lv_totassessableamt;
            lv_sgstamount:=c2.totalsgstamt-lv_totsgstamount;
            lv_cgstamount:=c2.totalcgstamt-lv_totcgstamount;
            lv_igstamount:=c2.totaligstamt-lv_totigstamount;
            
            lv_rownum:=0;
            lv_totassessableamt:=0;
            lv_totsgstamount:=0;
            lv_totcgstamount:=0;
            lv_totigstamount:=0;
        else
            if c2.totalmaterialamt>0 then
                lv_percentage:=(c2.materialamt/c2.totalmaterialamt)*100;
            else
                lv_percentage:=1;
            end if;
                
            lv_assessableamt:=round((lv_percentage*c2.totalassessableamt)/100,2);
            lv_sgstamount:=round((lv_percentage*c2.totalsgstamt)/100,2);
            lv_cgstamount:=round((lv_percentage*c2.totalcgstamt)/100,2);
            lv_igstamount:=round((lv_percentage*c2.totaligstamt)/100,2);
               
            lv_totassessableamt:=lv_totassessableamt+round((lv_percentage*c2.totalassessableamt)/100,2);
            lv_totsgstamount:=lv_totsgstamount+round((lv_percentage*c2.totalsgstamt)/100,2);
            lv_totcgstamount:=lv_totcgstamount+round((lv_percentage*c2.totalcgstamt)/100,2);
            lv_totigstamount:=lv_totigstamount+round((lv_percentage*c2.totaligstamt)/100,2);
            
            ---payel 13072020
            lv_rownum:=0;
            lv_totassessableamt:=0;
            lv_totsgstamount:=0;
            lv_totcgstamount:=0;
            lv_totigstamount:=0;
             ---payel 13072020
        end if;
            
        update gtt_salesrowwisechrge set percentage=lv_percentage,
                                         hsnwiseassessable=lv_assessableamt,
                                         hsnwisesgstamt=lv_sgstamount,
                                         hsnwisecgstamt=lv_cgstamount,
                                         hsnwiseigstamt=lv_igstamount
        where salebillno=c2.salebillno
        and billserialno=c2.billserialno;
        
        update gtt_salesbillregisterall set assessableamount=(case when noofpackingunit<0 then -1*lv_assessableamt else lv_assessableamt end),
                                            chargeamount=(case when noofpackingunit<0 then -1*chargeamount else chargeamount end)
        where salebillno=c2.salebillno
        and billserialno=c2.billserialno;
        
    end loop;
    update gtt_salesbillregisterall set totalindianamount=0,
                                        assessableamount=0,
                                        wtinmt=0
    where salebillno||billserialno||serialno not in (select salebillno||billserialno||min(serialno)
                                             from gtt_salesbillregisterall
                                           group by salebillno,billserialno
                                          );
    commit;
end;
/
