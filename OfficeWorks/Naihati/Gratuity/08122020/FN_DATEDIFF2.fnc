CREATE OR REPLACE FUNCTION NJMCL_WEB.FN_DATEDIFF2
(
    P_FROMDATE date,
    P_TODATE date
) RETURN VARCHAR2
AS
LV_RESULT VARCHAR2(100);
BEGIN



--    SELECT SYSDATE, hiredate,
--    TRUNC(months_between(SYSDATE,hiredate)/12) years,
--    TRUNC(months_between(SYSDATE,hiredate)  -
--    (TRUNC(months_between(SYSDATE,hiredate)/12)*12)) months,
--    TRUNC((months_between(SYSDATE,hiredate) -
--    TRUNC(months_between(SYSDATE,hiredate)))*30) days
--    FROM (
--        SELECT 'KRISHNA' NAME, TO_DATE('29/12/2019','DD/MM/YYYY') hiredate FROM DUAL
--    );

    SELECT YEARS ||' Year(s) '||MONTHS||' Month(s) '||DAYS||' Days(s) ' INTO LV_RESULT FROM (
        SELECT 
        TRUNC(MONTHS_BETWEEN(DATETO,DATEFROM)/12) YEARS,
        TRUNC(MONTHS_BETWEEN(DATETO,DATEFROM)  -
        (TRUNC(MONTHS_BETWEEN(DATETO,DATEFROM)/12)*12)) MONTHS,
        TRUNC((MONTHS_BETWEEN(DATETO,DATEFROM) -
        TRUNC(MONTHS_BETWEEN(DATETO,DATEFROM)))*30) DAYS
        FROM (
            SELECT P_FROMDATE DATEFROM, P_TODATE DATETO FROM DUAL
        )
    );
    
    RETURN LV_RESULT;
END;
/
