CREATE OR REPLACE FUNCTION FN_DATEDIFF
(
    P_FROMDATE VARCHAR2,
    P_TODATE VARCHAR2
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
            SELECT TO_DATE(P_FROMDATE,'DD/MM/YYYY') DATEFROM, TO_DATE(P_TODATE,'DD/MM/YYYY') DATETO FROM DUAL
        )
    );
    
    RETURN LV_RESULT;
END;