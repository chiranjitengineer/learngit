DROP PROCEDURE NJMCL_WEB.PRCWPS_IMP_GPPROCESS;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRCWPS_IMP_GPPROCESS(P_COMPCODE VARCHAR2, 
                                                          P_DIVCODE VARCHAR2,
                                                          P_DATEOFATTENDANCE VARCHAR2, 
                                                          P_YEARCODE VARCHAR2,
                                                          P_USERNAME VARCHAR2 
                                                        )
IS
LV_CNT NUMBER := 0;
LV_DATEOFATTENDANCE  DATE := TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY');
LV_SQLERRM VARCHAR2(2000):='';
LV_SQL        VARCHAR2(6000):='';
LV_TMFROM_A1    VARCHAR2(10):='';
LV_TMTO_A1      VARCHAR2(10):='';
LV_TMFROM_A2    VARCHAR2(10):='';
LV_TMTO_A2      VARCHAR2(10):='';
LV_TMFROM_B1    VARCHAR2(10):='';
LV_TMTO_B1      VARCHAR2(10):='';
LV_TMFROM_B2    VARCHAR2(10):='';
LV_TMTO_B2      VARCHAR2(10):='';
LV_TMFROM_C1    VARCHAR2(10):='';
LV_TMTO_C1      VARCHAR2(10):='';
LV_TMFROM_C2    VARCHAR2(10):='';
LV_TMTO_C2      VARCHAR2(10):='';
LV_GPB4SAVEPROCNAME VARCHAR2(30) := '';


BEGIN  

    SELECT ATTNFROM, ATTNTO, ATTNFROM1, ATTNTO1 INTO LV_TMFROM_A1, LV_TMTO_A1, LV_TMFROM_A2, LV_TMTO_A2
    FROM WPSSHIFTMAST WHERE SHIFTCODE = '1';

    SELECT ATTNFROM, ATTNTO, ATTNFROM1, ATTNTO1 INTO LV_TMFROM_B1, LV_TMTO_B1, LV_TMFROM_B2, LV_TMTO_B2
    FROM WPSSHIFTMAST WHERE SHIFTCODE = '2';

    SELECT ATTNFROM, ATTNTO, ATTNFROM1, ATTNTO1 INTO LV_TMFROM_C1, LV_TMTO_C1, LV_TMFROM_C2, LV_TMTO_C2
    FROM WPSSHIFTMAST WHERE SHIFTCODE = '3';
    
    LV_SQL := 'SELECT COUNT(*) '||CHR(10)
            ||'  FROM WPSGATEPASSRAWDATA_TEMP '||CHR(10);
            
    dbms_output.put_line ('Query : '||LV_SQL);     
    EXECUTE IMMEDIATE LV_SQL INTO LV_CNT;
    
    IF LV_CNT > 0 THEN
    
        LV_SQL := 'DELETE '||CHR(10)
                ||'  FROM WPSGATEPASSCSVRAWDATA '||CHR(10)
                ||' WHERE DATEOFATTENDANCE = '''||LV_DATEOFATTENDANCE||''' '||CHR(10);
                
        dbms_output.put_line ('Query : '||LV_SQL);     
        EXECUTE IMMEDIATE LV_SQL;
    
        LV_SQL := 'INSERT INTO WPSGATEPASSCSVRAWDATA '||CHR(10)
                ||'SELECT '''||P_COMPCODE||''', '''||P_DIVCODE||''', '''||LV_DATEOFATTENDANCE||''', '||CHR(10) 
                ||'       CASE WHEN SPELL = ''A1'' OR SPELL = ''B1'' OR SPELL = ''C'' THEN ''SPELL 1'' '||CHR(10) 
                ||'            WHEN SPELL = ''A2'' OR SPELL = ''B2'' THEN ''SPELL 2'' '||CHR(10)
                ||'        END SPELL, '''' SPELLHOURS, A.TOKENNO, A.WORKERSERIAL, TO_NUMBER(DEDUCTIONHOURS,2), '||CHR(10) 
                ||'       ''GATE PASS'' TRANSACTIONTAG, ''DATA MIGRATED ON 19/04/2018'' REMARKS, '''||P_YEARCODE||''' YEARCODE, '||CHR(10) 
                ||'       CASE WHEN SPELL = ''A1'' OR SPELL = ''A2'' THEN ''1'' '||CHR(10) 
                ||'            WHEN SPELL = ''B1'' OR SPELL = ''B2'' THEN ''2'' '||CHR(10)
                ||'        END SHIFTCODE '||CHR(10)
                ||'  FROM WPSGATEPASSRAWDATA_TEMP A, WPSWORKERMAST B '||CHR(10)
                ||' WHERE A.TOKENNO=B.TOKENNO '||CHR(10);
                
        dbms_output.put_line ('Query : '||LV_SQL);     
        EXECUTE IMMEDIATE LV_SQL;
        
    END IF;
    
    LV_SQL := 'SELECT COUNT(*) '||CHR(10)
            ||'  FROM WPSGATEPASSCSVRAWDATA '||CHR(10)
            ||' WHERE DATEOFATTENDANCE = '''||LV_DATEOFATTENDANCE||'''; '||CHR(10);
    dbms_output.put_line ('Query : '||LV_SQL);     
    EXECUTE IMMEDIATE LV_SQL INTO LV_CNT; 
             
        IF LV_CNT > 0 THEN       
             
            --- updatespell hours based on shiftcode and spell -----
             
            LV_SQL := ' UPDATE WPSGATEPASSCSVRAWDATA AA '||CHR(10)
                    ||'    SET DEDUCTIONHOURS = ( SELECT '||CHR(10)
                    ||'                             CASE WHEN SHIFTCODE = ''1'' AND SPELL = ''SPELL 1'' THEN TO_NUMBER('''||LV_TMTO_A1||''') - TO_NUMBER('''||LV_TMFROM_A1||''') '||CHR(10)
                    ||'                                  WHEN SHIFTCODE = ''1'' AND SPELL = ''SPELL 2'' THEN TO_NUMBER('''||LV_TMTO_A2||''') - TO_NUMBER('''||LV_TMFROM_A2||''') '||CHR(10)
                    ||'                                  WHEN SHIFTCODE = ''2'' AND SPELL = ''SPELL 2'' THEN TO_NUMBER('''||LV_TMTO_B1||''') - TO_NUMBER('''||LV_TMFROM_B1||''') '||CHR(10)
                    ||'                                  WHEN SHIFTCODE = ''2'' AND SPELL = ''SPELL 2'' THEN TO_NUMBER('''||LV_TMTO_B2||''') - TO_NUMBER('''||LV_TMFROM_B2||''') '||CHR(10)
                    ||'                                  ELSE 8 '||CHR(10)
                    ||'                              END DEDUCTIONHOURS '||CHR(10)
                    ||'                             FROM WPSGATEPASSCSVRAWDATA CC '||CHR(10)          
                    ||'                            WHERE AA.TOKENNO = CC.TOKENNO '||CHR(10)
                    ||'                              AND AA.ROWID = CC.ROWID '||CHR(10)
                    ||'                         ) '||CHR(10)
                    ||'  WHERE DEDUCTIONHOURS IS NULL '||CHR(10)
                    ||'    AND DATEOFATTENDANCE = '''||LV_DATEOFATTENDANCE||''' '||CHR(10); 
            DBMS_OUTPUT.PUT_LINE ('Query : '||LV_SQL);
            INSERT INTO WPS_ERROR_LOG (PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE,REMARKS ) 
            VALUES( 'PRCWPS_IMP_GPPROCESS',LV_SQLERRM,SYSDATE,LV_SQL,P_DATEOFATTENDANCE,TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY'),'GATE PASS DATA TRANSAFER');
            EXECUTE IMMEDIATE LV_SQL;    
            
        LV_SQL := ' INSERT INTO WPSACCIDENTGATEPASSDETAILS_TEMP ( COMPANYCODE, DATEOFATTENDANCE, DEDUCTIONHOURS, DIVISIONCODE, REMARKS, '||CHR(10)
                ||'             SHIFTCODE, SPELL, SPELLHOURS, TOKENNO, TRANSACTIONTAG, WORKERSERIAL, YEARCODE ), '||CHR(10) 
                ||' SELECT * '||CHR(10)
                ||'   FROM WPSGATEPASSCSVRAWDATA '||CHR(10)
                ||'  WHERE DATEOFATTENDANCE = '''||LV_DATEOFATTENDANCE||''' '||CHR(10);
                
        DBMS_OUTPUT.PUT_LINE ('Query : '||LV_SQL);
                
        INSERT INTO WPS_ERROR_LOG (PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE,REMARKS ) 
        VALUES( 'PRCWPS_IMP_GPPROCESS',LV_SQLERRM,SYSDATE,LV_SQL,P_DATEOFATTENDANCE,TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY'),'GATE PASS DATA TRANSAFER');
        EXECUTE IMMEDIATE LV_SQL;
                
        LV_SQL := ' SELECT FUNCTIONCALL_BEFORE '||CHR(10)
                ||'   FROM MENUMASTER_RND '||CHR(10)
                ||'  WHERE PROJECTNAME = ''WPS'' '||CHR(10)
                ||'    AND MENUTAG = ''GATE PASS ENTRY'' '||CHR(10);
                
        DBMS_OUTPUT.PUT_LINE ('Query : '||LV_SQL);
        
        INSERT INTO WPS_ERROR_LOG (PROC_NAME,ORA_ERROR_MESSG,ERROR_DATE,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE,REMARKS ) 
        VALUES( 'PRCWPS_IMP_GPPROCESS',LV_SQLERRM,SYSDATE,LV_SQL,P_DATEOFATTENDANCE,TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY'),'GATE PASS DATA TRANSAFER');
        EXECUTE IMMEDIATE LV_SQL INTO LV_GPB4SAVEPROCNAME;
        
        LV_SQL := 'BEGIN '||LV_GPB4SAVEPROCNAME||' END;'||CHR(10);
        DBMS_OUTPUT.PUT_LINE ('Query : '||LV_SQL);
                
    END IF;  
                                 
EXCEPTION
    WHEN OTHERS THEN
     --INSERT INTO ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,REMARKS ) VALUES( 'ERROR SQL',LV_SQLSTR,LV_SQLSTR,LV_PARVALUES,LV_REMARKS);
     LV_SQLERRM := SQLERRM ;
     INSERT INTO WPS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) VALUES( 'PRCWPS_IMP_GPPROCESS',LV_SQLERRM,NULL,NULL,TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY'),NULL, 'GATE PASS DATA TRANSAFER');
END;
/


