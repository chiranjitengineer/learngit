DROP PROCEDURE NJMCL_WEB.PROC_WPSWORKERMAST_ALL;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_WPSWORKERMAST_ALL
(
    P_COMPANYCODE VARCHAR2,
    P_DIVISIONCODE VARCHAR2,
    P_TOKENNO VARCHAR2,
    P_CONTRACTOR VARCHAR2,
    P_CATEGORYCODE VARCHAR2,
    P_UNITCODE VARCHAR2,
    P_DEPARTMENTCODE VARCHAR2,
    P_REPORTOPTION VARCHAR2 DEFAULT 'Y'
)
AS 
    LV_SQLSTR           VARCHAR2(20000);
    
    lv_strTable         VARCHAR2(10000);
    lv_strTable_vw      VARCHAR2(5000);
    
    lv_strInsert      VARCHAR2(10000);
    lv_strInsert_vw   VARCHAR2(5000);
    
BEGIN

    --change 20.11.2019 for adding extra component
      
    PROC_WPSVIEWCREATION ( P_COMPANYCODE, P_DIVISIONCODE,'MAST',0,TO_CHAR(SYSDATE,'DD/MM/YYYY'),TO_CHAR(SYSDATE,'DD/MM/YYYY'));
    
    --table
    SELECT WM_CONCAT('A.'||COLUMN_NAME) into lv_strTable
    FROM ( 
    SELECT COLUMN_NAME FROM COLS WHERE TABLE_NAME='GTT_WPSWORKERMAST_ALL' AND COLUMN_NAME <> 'COMPANYCODE'
    INTERSECT
    SELECT COLUMN_NAME FROM COLS WHERE TABLE_NAME='WPSWORKERMAST' AND COLUMN_NAME <> 'COMPANYCODE'
    );

    SELECT WM_CONCAT('E.'||COMPONENTSHORTNAME) into lv_strTable_vw FROM WPSCOMPONENTMASTER WHERE DIVISIONCODE = '0002' AND MASTERCOMPONENT='Y';

    --insert
    SELECT WM_CONCAT(COLUMN_NAME) into lv_strInsert
    FROM ( 
    SELECT COLUMN_NAME FROM COLS WHERE TABLE_NAME='GTT_WPSWORKERMAST_ALL' AND COLUMN_NAME <> 'COMPANYCODE'
    INTERSECT
    SELECT COLUMN_NAME FROM COLS WHERE TABLE_NAME='WPSWORKERMAST' AND COLUMN_NAME <> 'COMPANYCODE'
    );

    SELECT WM_CONCAT(COMPONENTSHORTNAME) into lv_strInsert_vw FROM WPSCOMPONENTMASTER WHERE DIVISIONCODE = '0002' AND MASTERCOMPONENT='Y';


    --DBMS_OUTPUT.PUT_LINE(lv_strcreation || '****************'|| lv_strcreation_vw);

    -- end change
    

    DELETE FROM GTT_WPSWORKERMAST_ALL;
    
    
--    LV_SQLSTR :=    'INSERT INTO GTT_WPSWORKERMAST_ALL '|| CHR(10)
--    ||' SELECT DISTINCT A.*,C.COMPANYNAME, C.COMPANYADDRESS , C.COMPANYADDRESS1, C.COMPANYADDRESS2,D.DIVISIONNAME '|| CHR(10)

    LV_SQLSTR :=    'INSERT INTO GTT_WPSWORKERMAST_ALL ('||lv_strInsert||','||lv_strInsert_vw||',COMPANYCODE, COMPANYNAME, COMPANYADDRESS , COMPANYADDRESS1, COMPANYADDRESS2,DIVISIONNAME )'|| CHR(10)
    ||' SELECT DISTINCT '||lv_strTable||','||lv_strTable_vw||',A.COMPANYCODE,C.COMPANYNAME, C.COMPANYADDRESS , C.COMPANYADDRESS1, C.COMPANYADDRESS2,D.DIVISIONNAME '|| CHR(10)
  ----  
    ||' FROM WPSWORKERMAST A ,COMPANYMAST C,DIVISIONMASTER D,MAST E '|| CHR(10)
    ||'  WHERE A.COMPANYCODE='''||P_COMPANYCODE||''' '||CHR(10)
    ||'   AND A.DIVISIONCODE='''||P_DIVISIONCODE||''' '||CHR(10)
    ||'   AND  A.COMPANYCODE=C.COMPANYCODE'|| CHR(10)
    ||'   AND  A.COMPANYCODE=D.COMPANYCODE'|| CHR(10)
    -- change
    ||'   AND  A.COMPANYCODE=E.COMPANYCODE'|| CHR(10)
    ||'   AND  A.COMPANYCODE=E.COMPANYCODE'|| CHR(10)
    ||'   AND  A.WORKERSERIAL=E.WORKERSERIAL'|| CHR(10)
    --
    ||'   AND  A.DIVISIONCODE=D.DIVISIONCODE'|| CHR(10);    
     IF P_TOKENNO IS NOT NULL THEN
                      LV_SQLSTR := LV_SQLSTR ||' AND A.TOKENNO IN ( '||P_TOKENNO||')  '||CHR(10);
      END IF;
     IF P_CATEGORYCODE IS NOT NULL THEN
                      LV_SQLSTR := LV_SQLSTR ||' AND A.WORKERCATEGORYCODE IN ( '||P_CATEGORYCODE||')  '||CHR(10);
     END IF;
     IF P_UNITCODE IS NOT NULL THEN
                      LV_SQLSTR := LV_SQLSTR ||' AND A.UNITCODE IN ( '||P_UNITCODE||')  '||CHR(10);
     END IF;
     IF P_DEPARTMENTCODE IS NOT NULL THEN
                      LV_SQLSTR := LV_SQLSTR ||' AND A.DEPARTMENTCODE IN ( '||P_DEPARTMENTCODE||')  '||CHR(10);
      END IF;  
     IF P_CONTRACTOR IS NOT NULL THEN
                      LV_SQLSTR := LV_SQLSTR ||' AND A.CONTRACTORCODE IN ( '||P_CONTRACTOR||')  '||CHR(10);
      END IF;  
       LV_SQLSTR := LV_SQLSTR ||' ORDER BY A.TOKENNO,A.WORKERNAME'||CHR(10);        
    
  --DBMS_OUTPUT.PUT_LINE(LV_SQLSTR);
  EXECUTE IMMEDIATE LV_SQLSTR;
END;
/

