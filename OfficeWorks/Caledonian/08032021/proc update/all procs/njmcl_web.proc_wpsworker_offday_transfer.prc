DROP PROCEDURE NJMCL_WEB.PROC_WPSWORKER_OFFDAY_TRANSFER;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSWORKER_OFFDAY_TRANSFER (P_COMPCODE VARCHAR2, P_DIVCODE VARCHAR2, P_YEARCODE VARCHAR2, P_ATTNDATE VARCHAR2, P_USER VARCHAR2 DEFAULT 'SWT')
AS
lv_ProcName varchar2(30) := 'PROC_WPSWORKER_OFFDAY_TRANSFER';
lv_SqlErrm  varchar2(500) := '';
lv_WeekDays varchar2(20);
lv_attn_dt  date := to_date(P_ATTNDATE,'DD/MM/YYYY');
begin
    
    --SELECT LTRIM(RTRIM(TO_CHAR(TO_DATE('11/08/2019','DD/MM/YYYY'),'DAY'))) FROM DUAL;
    
    ---- THIS PROCEDURE USER FOR WORKER DAILY DAY OFF TRANSFER IN ANOTHER TABLE  written by by amalesh on 17.08.2019 -------
    
    SELECT LTRIM(RTRIM(TO_CHAR(TO_DATE(P_ATTNDATE,'DD/MM/YYYY'),'DAY'))) INTO lv_WeekDays FROM DUAL;
    
    DELETE FROM WPSWORKERDAILYSTATUS WHERE COMPANYCODE=P_COMPCODE AND DIVISIONCODE = P_DIVCODE
    AND DATEOFATTENDANCE = TO_DATE(P_ATTNDATE,'DD/MM/YYYY') AND WORKERSTATUS = 'W';
    
    INSERT INTO WPSWORKERDAILYSTATUS (
    COMPANYCODE, DIVISIONCODE, YEARCODE, PERIODFROM, PERIODTO, DATEOFATTENDANCE,  
    WORKERSERIAL, TOKENNO,WEEKDAY, WORKERSTATUS, REMARKS, USERNAME, LASTMODIFIED, SYSROWID) 
    SELECT A.COMPANYCODE, A.DIVISIONCODE, P_YEARCODE YEARCODE, NULL PERIODFROM, NULL PERIODTO, TO_DATE(P_ATTNDATE,'DD/MM/YYYY')DATEOFATTENDANCE, 
    A.WORKERSERIAL, A.TOKENNO, 'SUNDAY' WEEKDAY, 'W' WORKERSTATUS, 'DAY OFF' REMARKS, 'SWT' USERNAME, SYSDATE LASTMODIFIED, SYS_GUID() SYSROWID
    FROM WPSWORKERMAST A,
    (    
        SELECT WORKERSERIAL FROM WPSWORKERMAST 
        WHERE COMPANYCODE =P_COMPCODE AND DIVISIONCODE=P_DIVCODE 
          AND ACTIVE='Y' AND TAKEPARTINWAGES='Y' 
          AND DAYOFFDAY = lv_WeekDays
        MINUS
        SELECT WORKERSERIAL FROM WPSATTENDANCEDAYWISE
        WHERE COMPANYCODE =P_COMPCODE AND DIVISIONCODE = P_DIVCODE
          AND YEARCODE = P_YEARCODE
          AND DATEOFATTENDANCE = TO_DATE(P_ATTNDATE,'DD/MM/YYYY')
          AND ATTENDANCEHOURS > 0
    ) B
    WHERE A.COMPANYCODE = P_COMPCODE AND A.DIVISIONCODE =P_DIVCODE
      AND ACTIVE='Y' AND TAKEPARTINWAGES='Y'
      AND A.WORKERSERIAL = B.WORKERSERIAL;
             
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    lv_sqlerrm := sqlerrm ;
     insert into WPS_error_log(COMPANYCODE, DIVISIONCODE,PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
     values( P_COMPCODE, P_DIVCODE,lv_ProcName,lv_sqlerrm,'','',lv_attn_dt,lv_attn_dt, 'ERROR GENERATE IN DAYOFF DATA TRANSFER' );
     COMMIT;
            
end;
/

