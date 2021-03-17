DROP PROCEDURE NJMCL_WEB.PRC_WPSATTENDANCECSVRAWDATA;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PRC_WPSATTENDANCECSVRAWDATA" 
(
    p_companycode varchar2,
    p_divisioncode varchar2,
    p_fromdt varchar2,
    p_todt varchar2,
    p_isverified char,
    p_isapproved char,
    p_dept      varchar2,
    p_sec       varchar2     
)
AS
    lv_sqlstr varchar2(2000);
BEGIN
    DELETE FROM GTT_WPSATTENDANCECSVRAWDATA;            
                lv_sqlstr :=' INSERT INTO GTT_WPSATTENDANCECSVRAWDATA ' ||CHR(10)
                  ||' SELECT '''||p_fromdt ||''' FROMDT,'''||p_todt||''' TODT,  '||CHR(10)
                  ||' '''||p_companycode||''' COMPANYCODE, '||CHR(10)
                  ||' (SELECT COMPANYNAME FROM COMPANYMAST D WHERE D.COMPANYCODE = '''||p_companycode||''') COMPANYNAME, '||CHR(10)
                  ||' '''||p_divisioncode||''' DIVISIONCODE, '||CHR(10);
                  IF p_isverified IS NULL AND p_isapproved IS NULL THEN
                    lv_sqlstr :=lv_sqlstr ||' ''Manual Import Data Status (All)'' PARAMNAME, '||CHR(10);
                  ELSIF NVL(p_isverified,'A')='N' AND p_isapproved IS NULL THEN
                    lv_sqlstr :=lv_sqlstr ||' ''Manual Import Data Status (Not Verified)'' PARAMNAME, '||CHR(10);
                  ELSIF p_isverified IS NULL AND NVL(p_isapproved,'B') ='Y' THEN
                    lv_sqlstr :=lv_sqlstr ||' ''Manual Import Data Status (Approved)'' PARAMNAME, '||CHR(10);
                  END IF;
                  lv_sqlstr :=lv_sqlstr ||' ''01'' UNITCODE, ATTENDATE, DEPARTMENT, OCCUPATION, A.SHIFT, A.TOKENNO||'' - ''||C.WORKERNAME TOKENNO, VERIFIED, A.REMARKS,NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0) ATTNHOURS, OTHOURS OTHOURS,A.SECTION'||CHR(10)
                  ||' FROM WPSATTENDANCECSVRAWDATA A,WPSWORKERMAST C'||CHR(10)
                  ||' WHERE ATTENDATE BETWEEN ''' || p_fromdt || ''' '|| CHR(10)
                  ||'                         AND ''' || p_todt || ''' '|| CHR(10)
                  ||'   AND A.TOKENNO=C.TOKENNO'||CHR(10);
                  IF p_dept IS NOT NULL THEN
                       lv_sqlstr :=lv_sqlstr ||'   AND A. DEPARTMENT IN ('||p_dept||') '||CHR(10);
                  END IF;
                  IF p_sec IS NOT NULL THEN
                       lv_sqlstr :=lv_sqlstr ||'   AND A. SECTION IN ('||p_sec||') '||CHR(10);
                  END IF;
                  IF NVL(p_isverified,'A')='N' AND p_isapproved IS NULL THEN
                    lv_sqlstr :=lv_sqlstr ||'   AND A.VERIFIED=''N'' '||CHR(10);                  
                  ELSIF p_isverified IS NULL AND NVL(p_isapproved,'B') ='Y' THEN
                    lv_sqlstr :=lv_sqlstr ||'   AND A.APPROVED=''Y'' '||CHR(10);
                  END IF;
                  lv_sqlstr :=lv_sqlstr ||'   ORDER BY A.TOKENNO '||CHR(10);
        dbms_output.put_line(lv_sqlstr);
        execute immediate lv_sqlstr;
END;
/


