DROP PROCEDURE NJMCL_WEB.PRCWPS_GATEPASSDTLSB4SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRCWPS_GATEPASSDTLSB4SAVE
IS
LV_SQLSTR   VARCHAR2(1000)  :=  '';   
LV_MASTER   GBL_WPSWORKERGATEPASSDETAILS%ROWTYPE;
LV_CNT      NUMBER          :=  0;lv_error_remark         varchar2(4000) := '' ;

BEGIN
    SELECT COUNT(*)
      INTO LV_CNT
      FROM GBL_WPSWORKERGATEPASSDETAILS;
    IF LV_CNT>0 THEN
        SELECT *
          INTO LV_MASTER
          FROM GBL_WPSWORKERGATEPASSDETAILS
         WHERE ROWNUM<=1;
         
        IF NVL(LV_MASTER.OPERATIONMODE,'NA') = 'A' THEN
            LV_SQLSTR := 'UPDATE WPSATTENDANCEDAYWISE SET DEDUCTIONHOURS = NVL('||LV_MASTER.DEDUCTIONHOURS||',0), '||CHR(10)
                       ||'                                ATTENDANCEHOURS = ATTENDANCEHOURS - NVL('||LV_MASTER.DEDUCTIONHOURS||',0), '||CHR(10)
                       ||'                                REMARKS = ''MANUAL GATEPASS ENTRY'' '||CHR(10)
                       ||' WHERE COMPANYCODE = '''||LV_MASTER.COMPANYCODE||''' '||CHR(10)
                       ||'   AND DIVISIONCODE = '''||LV_MASTER.DIVISIONCODE||''' '||CHR(10)
                       ||'   AND DATEOFATTENDANCE = '''||LV_MASTER.DATEOFATTENDANCE||''' '||CHR(10)
                       ||'   AND WORKERSERIAL = '||LV_MASTER.WORKERSERIAL||' '||CHR(10)
                       ||'   AND SPELLTYPE = '''||LV_MASTER.SPELL||''' '||CHR(10)
                       ||'   AND SPELLHOURS = '||LV_MASTER.SPELLHOURS||' '||CHR(10);
                       
            EXECUTE IMMEDIATE LV_SQLSTR;
               
        END IF;
        IF NVL(LV_MASTER.OPERATIONMODE,'NA') = 'M' THEN
            LV_SQLSTR := 'UPDATE WPSATTENDANCEDAYWISE SET DEDUCTIONHOURS = NVL('||LV_MASTER.DEDUCTIONHOURS||',0), '||CHR(10)
                       ||'                                ATTENDANCEHOURS = ATTENDANCEHOURS + DEDUCTIONHOURS - NVL('||LV_MASTER.DEDUCTIONHOURS||',0), '||CHR(10)
                       ||'                                REMARKS = ''MANUAL GATEPASS ENTRY'' '||CHR(10)
                       ||' WHERE COMPANYCODE = '''||LV_MASTER.COMPANYCODE||''' '||CHR(10)
                       ||'   AND DIVISIONCODE = '''||LV_MASTER.DIVISIONCODE||''' '||CHR(10)
                       ||'   AND DATEOFATTENDANCE = '''||LV_MASTER.DATEOFATTENDANCE||''' '||CHR(10)
                       ||'   AND WORKERSERIAL = '||LV_MASTER.WORKERSERIAL||' '||CHR(10)
                       ||'   AND SPELLTYPE = '''||LV_MASTER.SPELL||''' '||CHR(10)
                       ||'   AND SPELLHOURS = '||LV_MASTER.SPELLHOURS||' '||CHR(10);
                       
            EXECUTE IMMEDIATE LV_SQLSTR;
               
        END IF;
        IF NVL(LV_MASTER.OPERATIONMODE,'NA') = 'D' THEN
            LV_SQLSTR := 'UPDATE WPSATTENDANCEDAYWISE SET DEDUCTIONHOURS = 0, '||CHR(10)
                       ||'                                ATTENDANCEHOURS = NVL(ATTENDANCEHOURS,0) + NVL(DEDUCTIONHOURS,0), '||CHR(10)
                       ||'                                REMARKS = '''' '||CHR(10)
                       ||' WHERE COMPANYCODE = '''||LV_MASTER.COMPANYCODE||''' '||CHR(10)
                       ||'   AND DIVISIONCODE = '''||LV_MASTER.DIVISIONCODE||''' '||CHR(10)
                       ||'   AND DATEOFATTENDANCE = '''||LV_MASTER.DATEOFATTENDANCE||''' '||CHR(10)
                       ||'   AND WORKERSERIAL = '||LV_MASTER.WORKERSERIAL||' '||CHR(10)
                       ||'   AND SPELLTYPE = '''||LV_MASTER.SPELL||''' '||CHR(10)
                       ||'   AND SPELLHOURS = '||LV_MASTER.SPELLHOURS||' '||CHR(10);
                       
            EXECUTE IMMEDIATE LV_SQLSTR;
               
        END IF;
    END IF;
    
    EXCEPTION
        WHEN OTHERS THEN 
             INSERT INTO WPS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) VALUES( 'PRCWPS_GATEPASSDTLSB4SAVE','',LV_SQLSTR,'','','', '');
    END;
/


