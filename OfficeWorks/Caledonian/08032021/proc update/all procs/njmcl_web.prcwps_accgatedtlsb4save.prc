DROP PROCEDURE NJMCL_WEB.PRCWPS_ACCGATEDTLSB4SAVE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRCWPS_ACCGATEDTLSB4SAVE
IS
LV_SQLSTR           VARCHAR2(1000)  :=  '';   
LV_MASTER           GBL_WPSACCIDENTGATEPASSDETAILS%ROWTYPE;
LV_CNT              NUMBER          :=  0;lv_error_remark         varchar2(4000) := '' ;
LV_TRANSACTIONNO    VARCHAR2(30)    :=  '';

BEGIN
    SELECT COUNT(*)
      INTO LV_CNT
      FROM GBL_WPSACCIDENTGATEPASSDETAILS;
    IF LV_CNT>0 THEN
        SELECT *
          INTO LV_MASTER
          FROM GBL_WPSACCIDENTGATEPASSDETAILS
         WHERE ROWNUM<=1;
        IF NVL(LV_MASTER.TRANSACTIONTAG,'NA') = 'ACCIDENT' THEN
            IF NVL(LV_MASTER.TRANSACTIONNO,'NA') = 'NA' THEN
                    SELECT FN_AUTOGEN_PARAMS(LV_MASTER.COMPANYCODE,LV_MASTER.DIVISIONCODE,LV_MASTER.YEARCODE,'WPS ACCIDENT ENTRY',TO_CHAR(LV_MASTER.DATEOFATTENDANCE,'dd/mm/yyyy')) 
                      INTO LV_TRANSACTIONNO
                      FROM DUAL;
                    LV_SQLSTR := 'UPDATE GBL_WPSACCIDENTGATEPASSDETAILS '||CHR(10)
                               ||'   SET TRANSACTIONNO = '''||LV_TRANSACTIONNO||''' '||CHR(10);
                    EXECUTE IMMEDIATE LV_SQLSTR;
                ELSE
                    LV_SQLSTR := 'UPDATE GBL_WPSACCIDENTGATEPASSDETAILS '||CHR(10)
                               ||'   SET TRANSACTIONNO = '''||LV_MASTER.TRANSACTIONNO||''' '||CHR(10);
                    EXECUTE IMMEDIATE LV_SQLSTR;
                END IF;
            IF NVL(LV_MASTER.OPERATIONMODE,'NA') = 'M' OR NVL(LV_MASTER.OPERATIONMODE,'NA') = 'A' THEN
                FOR C2 IN (SELECT * FROM GBL_WPSACCIDENTGATEPASSDETAILS)
                LOOP
                    LV_SQLSTR := 'UPDATE WPSATTENDANCEDAYWISE SET DEDUCTIONHOURS = NVL(ATTENDANCEHOURS,0) + NVL(DEDUCTIONHOURS,0) - NVL('||C2.ATTENDANCEHOURS||',0), '||CHR(10)
                               ||'                                ATTENDANCEHOURS = NVL('||C2.ATTENDANCEHOURS||',0), '||CHR(10)
                               ||'                                REMARKS = ''MANUAL ACCIDENT ENTRY'' '||CHR(10)
                               ||' WHERE COMPANYCODE = '''||C2.COMPANYCODE||''' '||CHR(10)
                               ||'   AND DIVISIONCODE = '''||C2.DIVISIONCODE||''' '||CHR(10)
                               ||'   AND DATEOFATTENDANCE = '''||C2.DATEOFATTENDANCE||''' '||CHR(10)
                               ||'   AND WORKERSERIAL = '||C2.WORKERSERIAL||' '||CHR(10)
                               ||'   AND SHIFTCODE = '''||C2.SHIFTCODE||''' '||CHR(10)
                               ||'   AND SPELLTYPE = '''||C2.SPELL||''' '||CHR(10)
                               ||'   AND SPELLHOURS = '||C2.SPELLHOURS||' '||CHR(10);
                    EXECUTE IMMEDIATE LV_SQLSTR;
                END LOOP;
            END IF;
            IF NVL(LV_MASTER.OPERATIONMODE,'NA') = 'D' THEN
                FOR C2 IN (SELECT * FROM GBL_WPSACCIDENTGATEPASSDETAILS)
                LOOP
                    LV_SQLSTR := 'UPDATE WPSATTENDANCEDAYWISE SET DEDUCTIONHOURS = 0, '||CHR(10)
                               ||'                                ATTENDANCEHOURS = NVL(ATTENDANCEHOURS,0) + NVL(DEDUCTIONHOURS,0), '||CHR(10)
                               ||'                                REMARKS = '''' '||CHR(10)
                               ||' WHERE COMPANYCODE = '''||C2.COMPANYCODE||''' '||CHR(10)
                               ||'   AND DIVISIONCODE = '''||C2.DIVISIONCODE||''' '||CHR(10)
                               ||'   AND DATEOFATTENDANCE = '''||C2.DATEOFATTENDANCE||''' '||CHR(10)
                               ||'   AND WORKERSERIAL = '||C2.WORKERSERIAL||' '||CHR(10)
                               ||'   AND SHIFTCODE = '''||C2.SHIFTCODE||''' '||CHR(10)
                               ||'   AND SPELLTYPE = '''||C2.SPELL||''' '||CHR(10)
                               ||'   AND SPELLHOURS = '||C2.SPELLHOURS||' '||CHR(10);
                    EXECUTE IMMEDIATE LV_SQLSTR;
                END LOOP;
            END IF;
        END IF;
        IF NVL(LV_MASTER.TRANSACTIONTAG,'NA') = 'GATE PASS' THEN
            IF NVL(LV_MASTER.TRANSACTIONNO,'NA') = 'NA' THEN
                    SELECT FN_AUTOGEN_PARAMS(LV_MASTER.COMPANYCODE,LV_MASTER.DIVISIONCODE,LV_MASTER.YEARCODE,'WPS GATE PASS ENTRY',TO_CHAR(LV_MASTER.DATEOFATTENDANCE,'dd/mm/yyyy')) 
                      INTO LV_TRANSACTIONNO
                      FROM DUAL;
                    LV_SQLSTR := 'UPDATE GBL_WPSACCIDENTGATEPASSDETAILS '||CHR(10)
                               ||'   SET TRANSACTIONNO = '''||LV_TRANSACTIONNO||''' '||CHR(10);
                    EXECUTE IMMEDIATE LV_SQLSTR;
                ELSE
                    LV_SQLSTR := 'UPDATE GBL_WPSACCIDENTGATEPASSDETAILS '||CHR(10)
                               ||'   SET TRANSACTIONNO = '''||LV_MASTER.TRANSACTIONNO||''' '||CHR(10);
                    EXECUTE IMMEDIATE LV_SQLSTR;
                END IF;
            IF NVL(LV_MASTER.OPERATIONMODE,'NA') = 'M' OR NVL(LV_MASTER.OPERATIONMODE,'NA') = 'A' THEN
                FOR C2 IN (SELECT * FROM GBL_WPSACCIDENTGATEPASSDETAILS)
                LOOP
                    LV_SQLSTR := 'UPDATE WPSATTENDANCEDAYWISE  '||CHR(10)
                               ||'   SET DEDUCTIONHOURS = NVL('||C2.DEDUCTIONHOURS||',0), '||CHR(10)
                               ||'       ATTENDANCEHOURS = ATTENDANCEHOURS + DEDUCTIONHOURS - NVL('||C2.DEDUCTIONHOURS||',0), '||CHR(10)
                               ||'       REMARKS = ''MANUAL GATEPASS ENTRY'' '||CHR(10)
                               ||' WHERE COMPANYCODE = '''||C2.COMPANYCODE||''' '||CHR(10)
                               ||'   AND DIVISIONCODE = '''||C2.DIVISIONCODE||''' '||CHR(10)
                               ||'   AND DATEOFATTENDANCE = '''||C2.DATEOFATTENDANCE||''' '||CHR(10)
                               ||'   AND WORKERSERIAL = '||C2.WORKERSERIAL||' '||CHR(10)
                               ||'   AND SPELLTYPE = '''||C2.SPELL||''' '||CHR(10)
                               ||'   AND SPELLHOURS = '||C2.SPELLHOURS||' '||CHR(10);
                    EXECUTE IMMEDIATE LV_SQLSTR;
                END LOOP;
            END IF;
            IF NVL(LV_MASTER.OPERATIONMODE,'NA') = 'D' THEN
                FOR C2 IN (SELECT * FROM GBL_WPSACCIDENTGATEPASSDETAILS)
                LOOP
                    LV_SQLSTR := 'UPDATE WPSATTENDANCEDAYWISE  '||CHR(10)
                               ||'   SET DEDUCTIONHOURS = 0, '||CHR(10)
                               ||'       ATTENDANCEHOURS = NVL(ATTENDANCEHOURS,0) + NVL(DEDUCTIONHOURS,0), '||CHR(10)
                               ||'       REMARKS = '''' '||CHR(10)
                               ||' WHERE COMPANYCODE = '''||C2.COMPANYCODE||''' '||CHR(10)
                               ||'   AND DIVISIONCODE = '''||C2.DIVISIONCODE||''' '||CHR(10)
                               ||'   AND DATEOFATTENDANCE = '''||C2.DATEOFATTENDANCE||''' '||CHR(10)
                               ||'   AND WORKERSERIAL = '||C2.WORKERSERIAL||' '||CHR(10)
                               ||'   AND SPELLTYPE = '''||C2.SPELL||''' '||CHR(10)
                               ||'   AND SPELLHOURS = '||C2.SPELLHOURS||' '||CHR(10);
                    EXECUTE IMMEDIATE LV_SQLSTR;
                END LOOP;
            END IF;
        END IF;
    END IF;
    
    EXCEPTION
        WHEN OTHERS THEN 
             INSERT INTO WPS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) VALUES( 'PRCWPS_ACCIDENTDTLSB4SAVE','',LV_SQLSTR,'','','', '');
    END;
/


