CREATE OR REPLACE FUNCTION fn_GET_LEAVEQUERRY(P_COMPANYCODE VARCHAR2,P_DIVISIONCODE VARCHAR2,P_LEAVECODE VARCHAR2,P_TABLENAME VARCHAR2)
RETURN VARCHAR2
IS
lv_Sql VARCHAR2(1000);
BEGIN
    lv_Sql:='SELECT COMPANYCODE,DIVISIONCODE,WORKERSERIAL';
    FOR C1 IN (SELECT LEAVECODE from PISLEAVEMASTER WHERE COMPANYCODE=P_COMPANYCODE AND DIVISIONCODE=P_DIVISIONCODE AND NVL(WITHOUTPAYLEAVE,'N')<>'Y' ORDER BY LEAVECODE)
    LOOP
        IF C1.LEAVECODE=P_LEAVECODE THEN
            lv_Sql:=lv_Sql||',AVAILED LDAY_'||C1.LEAVECODE||', BALANCE LVBL_'||C1.LEAVECODE;
        ELSE
            lv_Sql:=lv_Sql||',0 LDAY_'||C1.LEAVECODE||', 0 LVBL_'||C1.LEAVECODE;
        END IF;
    END LOOP;
    lv_Sql:=lv_Sql||CHR(10)
                  ||'FROM '||P_TABLENAME||CHR(10)
                  ||'WHERE COMPANYCODE='''||P_COMPANYCODE||''''||CHR(10)
                  ||'   AND DIVISIONCODE='''||P_DIVISIONCODE||''''||CHR(10)
                  ||'   AND LEAVECODE='''||P_LEAVECODE||''''||CHR(10);
   RETURN lv_Sql;
END;
/