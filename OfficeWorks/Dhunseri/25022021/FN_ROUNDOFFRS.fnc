CREATE OR REPLACE FUNCTION DHUNSERI.FN_ROUNDOFFRS(P_AMOUNT NUMBER, P_ROUNDOFTO NUMBER, P_ROUNDOFTYPE VARCHAR2 DEFAULT 'S') RETURN NUMBER
AS
LV_ROUNDOFTYPE  VARCHAR2(10) := '';
LV_ROUNDOFFRS  NUMBER:= 0;
BEGIN
    IF P_ROUNDOFTYPE = 'S' THEN
        SELECT ROUND(P_AMOUNT,0) INTO LV_ROUNDOFFRS FROM DUAL;
    ELSIF P_ROUNDOFTYPE = 'H' THEN
        IF TO_NUMBER(P_ROUNDOFTO) > 0 THEN
            SELECT CEIL(P_AMOUNT/P_ROUNDOFTO)*P_ROUNDOFTO INTO LV_ROUNDOFFRS FROM DUAL; 
        END IF;    
    ELSIF P_ROUNDOFTYPE = 'L' THEN
        IF TO_NUMBER(P_ROUNDOFTO) > 0 THEN
            SELECT FLOOR(P_AMOUNT/P_ROUNDOFTO)*P_ROUNDOFTO INTO LV_ROUNDOFFRS FROM DUAL;
        END IF;    
    ELSIF P_ROUNDOFTYPE = 'R' THEN
        IF TO_NUMBER(P_ROUNDOFTO) > 0 THEN
            SELECT ROUND(P_AMOUNT/P_ROUNDOFTO)*P_ROUNDOFTO INTO LV_ROUNDOFFRS FROM DUAL;
        END IF;    
    ELSE
        SELECT P_AMOUNT INTO LV_ROUNDOFFRS FROM DUAL;    
    END IF;
RETURN LV_ROUNDOFFRS;
END;
/
