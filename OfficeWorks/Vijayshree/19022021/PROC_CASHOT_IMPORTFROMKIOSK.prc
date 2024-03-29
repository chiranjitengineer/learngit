CREATE OR REPLACE PROCEDURE PROC_CASHOT_IMPORTFROMKIOSK
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_FROMDATE VARCHAR2,
    P_TODATE VARCHAR2 
)
AS
    LV_SQL VARCHAR2(10000);
    LV_CNT  NUMBER(10);
    LV_MSG  VARCHAR2(1000);
    LV_KIOSK_DBLINK  VARCHAR2(100);
BEGIN


    LV_KIOSK_DBLINK := NULL;



    SELECT COUNT(PARAMETER_VALUE) INTO LV_CNT  FROM SYS_PARAMETER
    WHERE PARAMETER_NAME='KIOSK DBLINK'
    AND COMPANYCODE=P_COMPANYCODE
    AND DIVISIONCODE=P_DIVISIONCODE;

    IF LV_CNT = 0 THEN
        LV_MSG := 'KIOSK DBLINK NOT FOUND, DATA EXPORT NOT POSSIBLE';
    ELSE
        SELECT PARAMETER_VALUE  INTO LV_KIOSK_DBLINK  FROM SYS_PARAMETER
        WHERE PARAMETER_NAME='KIOSK DBLINK'
        AND COMPANYCODE=P_COMPANYCODE
        AND DIVISIONCODE=P_DIVISIONCODE;
     
    END IF;


IF LV_KIOSK_DBLINK IS NOT NULL THEN
    --EXEC PROC_CASHOT_EXPORTTOKIOSK('0002','0022','16/12/2020','16/12/2020')
       
    LV_SQL := NULL;
    LV_SQL := LV_SQL || 'SELECT COUNT(*) FROM WPSCASHOTPAYMENTDETAILS@'||LV_KIOSK_DBLINK||CHR(10);
    LV_SQL := LV_SQL || 'WHERE 1=1 '||CHR(10);
    LV_SQL := LV_SQL || 'AND COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10);
    LV_SQL := LV_SQL || 'AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10);
    LV_SQL := LV_SQL || 'AND PAYMENTFROMDATE = TO_DATE('''||P_FROMDATE||''', ''DD/MM/YYYY'') '||CHR(10);
    LV_SQL := LV_SQL || 'AND PAYMENTTODATE = TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'') '||CHR(10);
    LV_SQL := LV_SQL || 'AND (NVL(PAYMENTLOCK,''N'') = ''Y'' OR  NVL(ISTRANSFER,''N'')=''N'') '||CHR(10);
    
    EXECUTE IMMEDIATE LV_SQL INTO LV_CNT;
    
    IF(LV_CNT = 0) THEN
        LV_MSG := 'NO RECORD FOUND';
        
    ELSE
        LV_SQL := NULL;
        LV_SQL := LV_SQL || 'DELETE FROM WPSCASHOTPAYMENTDETAILS@'||LV_KIOSK_DBLINK||CHR(10);
        LV_SQL := LV_SQL || 'WHERE PAYMENTFROMDATE = TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'') '||CHR(10);
        LV_SQL := LV_SQL || 'AND PAYMENTTODATE = TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'') '||CHR(10);
        LV_SQL := LV_SQL || 'AND COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10);
        LV_SQL := LV_SQL || 'AND DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10);
        
        DBMS_OUTPUT.PUT_LINE(LV_SQL);
        
        
        EXECUTE IMMEDIATE LV_SQL;
        
        LV_SQL := NULL;
        LV_SQL := LV_SQL || 'INSERT INTO WPSCASHOTPAYMENTDETAILS@'||LV_KIOSK_DBLINK||CHR(10);
        LV_SQL := LV_SQL || '('||CHR(10);
        LV_SQL := LV_SQL || '    COMPANYCODE,DIVISIONCODE,PAYMENTFROMDATE, PAYMENTTODATE, '||CHR(10);
        LV_SQL := LV_SQL || '    DEPARTMENTCODE, DEPARTMENTNAME, SHIFTCODE,'||CHR(10);
        LV_SQL := LV_SQL || '    TOKENNO,WORKERNAME, WORKERSERIAL, OTHOURS,OTAMOUNT,ESI_OT,  '||CHR(10);
        LV_SQL := LV_SQL || '    NETPAY,PAYMENTLOCK,ISTRANSFER'||CHR(10);
        LV_SQL := LV_SQL || ')'||CHR(10);
        LV_SQL := LV_SQL || 'SELECT A.COMPANYCODE,A.DIVISIONCODE,A.FORTNIGHTSTARTDATE PAYMENTFROMDATE, A.FORTNIGHTENDDATE PAYMENTTODATE, '||CHR(10);
        LV_SQL := LV_SQL || 'A.DEPARTMENTCODE, B.DEPARTMENTNAME, DECODE(A.SHIFTCODE,''1'',''A'',''2'',''B'',''C'') SHIFTCODE,'||CHR(10);
        LV_SQL := LV_SQL || 'A.TOKENNO,C.WORKERNAME, A.WORKERSERIAL, A.OVERTIMEHOURS OTHOURS,A.CASHOT_AMOUNT OTAMOUNT,A.DAILY_ESI ESI_OT,  '||CHR(10);
        LV_SQL := LV_SQL || 'ACTUALPAYBLEAMOUNT NETPAY,''N'' PAYMENTLOCK,''N'' ISTRANSFER  '||CHR(10);
        LV_SQL := LV_SQL || 'FROM WPSDAILYWAGESDETAILS A, WPSDEPARTMENTMASTER B, WPSWORKERMAST C '||CHR(10);
        LV_SQL := LV_SQL || 'WHERE A.COMPANYCODE=B.COMPANYCODE'||CHR(10);
        LV_SQL := LV_SQL || '    AND A.DIVISIONCODE=B.DIVISIONCODE'||CHR(10);
        LV_SQL := LV_SQL || '    AND A.COMPANYCODE=C.COMPANYCODE'||CHR(10);
        LV_SQL := LV_SQL || '    AND A.DIVISIONCODE=C.DIVISIONCODE'||CHR(10);
        LV_SQL := LV_SQL || '    AND A.DEPARTMENTCODE=B.DEPARTMENTCODE'||CHR(10);
        LV_SQL := LV_SQL || '    AND A.WORKERSERIAL=C.WORKERSERIAL'||CHR(10);
        LV_SQL := LV_SQL || '    AND NVL(A.ACTUALPAYBLEAMOUNT,0) > 0'||CHR(10);
        LV_SQL := LV_SQL || '    AND  A.FORTNIGHTSTARTDATE BETWEEN TO_DATE('''||P_FROMDATE||''',''DD/MM/YYYY'') AND  TO_DATE('''||P_TODATE||''',''DD/MM/YYYY'')'||CHR(10);
         
        
    
        DBMS_OUTPUT.PUT_LINE(LV_SQL);
        
        EXECUTE IMMEDIATE LV_SQL;
    
        LV_MSG := 'DATA SUCCESSFULLY EXPORTED TO KIOSK..';
    END IF;
END IF;
    
    DELETE FROM SYS_GBL_PROCOUTPUT_INFO;
    
    INSERT INTO SYS_GBL_PROCOUTPUT_INFO 
    SELECT LV_MSG FROM DUAL;
    
END;
/
