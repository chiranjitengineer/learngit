CREATE OR REPLACE PROCEDURE PROC_CASHOT_EXPORTTOKIOSK
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_FROMDATE VARCHAR2,
    P_TODATE VARCHAR2 
)
AS
    LV_SQL VARCHAR2(10000);
BEGIN

--EXEC PROC_CASHOT_EXPORTTOKIOSK('0002','0022','16/12/2020','16/12/2020')

    LV_SQL := NULL;
    
    LV_SQL := LV_SQL || 'DELETE FROM WPSCASHOTPAYMENTDETAILS '||CHR(10);
    LV_SQL := LV_SQL || 'WHERE PAYMENTFROMDATE = TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'') '||CHR(10);
    LV_SQL := LV_SQL || 'AND PAYMENTTODATE = TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'') '||CHR(10);
    LV_SQL := LV_SQL || 'AND COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10);
    LV_SQL := LV_SQL || 'AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10);
    
    DBMS_OUTPUT.PUT_LINE(LV_SQL);
    
    
    EXECUTE IMMEDIATE LV_SQL;
    
    LV_SQL := NULL;
    LV_SQL := LV_SQL || 'INSERT INTO WPSCASHOTPAYMENTDETAILS '||CHR(10);
    LV_SQL := LV_SQL || 'SELECT COMPANYCODE,DIVISIONCODE,FORTNIGHTSTARTDATE PAYMENTFROMDATE, FORTNIGHTENDDATE PAYMENTTODATE, '||CHR(10);
    LV_SQL := LV_SQL || 'TOKENNO, WORKERSERIAL, OVERTIMEHOURS OTHOURS,CASHOT_AMOUNT OTAMOUNT,DAILY_ESI ESI_OT,  '||CHR(10);
    LV_SQL := LV_SQL || 'ACTUALPAYBLEAMOUNT NETPAY,''N'' PAYMENTLOCK,''N'' ISTRANSFER  '||CHR(10);
    LV_SQL := LV_SQL || 'FROM WPSDAILYWAGESDETAILS '||CHR(10);
    LV_SQL := LV_SQL || 'WHERE FORTNIGHTSTARTDATE = TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'') '||CHR(10);
    LV_SQL := LV_SQL || 'AND FORTNIGHTENDDATE = TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'') '||CHR(10);
    LV_SQL := LV_SQL || 'AND COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10);
    LV_SQL := LV_SQL || 'AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10);
    
    
    DBMS_OUTPUT.PUT_LINE(LV_SQL);
    
    EXECUTE IMMEDIATE LV_SQL;
    
    
END;