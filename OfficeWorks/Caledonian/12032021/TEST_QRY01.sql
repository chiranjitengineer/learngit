DECLARE

LV_SQL VARCHAR2(10000);

BEGIN
    FOR C1 IN (
        SELECT DISTINCT TABLE_NAME FROM COLS
        WHERE COLUMN_NAME='COMPANYCODE'
        AND (TABLE_NAME LIKE '%WPS%'
        or TABLE_NAME LIKE '%PIS%')
        AND TABLE_NAME NOT LIKE 'GBL%'
        AND TABLE_NAME NOT LIKE 'GTT%'
    )
    LOOP
    
    
    DBMS_OUTPUT.PUT_LINE('------------------------');
    LV_SQL := CHR(10)||CHR(10);
    LV_SQL := LV_SQL 
        ||'UPDATE '|| C1.TABLE_NAME  
        ||' SET COMPANYCODE=''CJ0101''' 
        ||' WHERE COMPANYCODE=''CJ0001''' ;
        
    DBMS_OUTPUT.PUT_LINE(LV_SQL);    
    
        
    END LOOP;
END;