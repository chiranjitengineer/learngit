CREATE OR REPLACE PROCEDURE PRC_REALIZEDUNREALDATA_INSERT 
( 
    P_COMPCODE VARCHAR2, 
    P_DIVCODE VARCHAR2, 
    P_YEARCODE VARCHAR2, 
    P_START_DT VARCHAR2, 
    P_END_DT VARCHAR2,
    P_MODULE VARCHAR2, 
    P_TABLENAME VARCHAR2, 
    P_COMPONENTCODE VARCHAR2, 
    P_TRANTYPE VARCHAR2, 
    P_WORKERSERIAL VARCHAR2 DEFAULT NULL
)
AS
lv_Sql varchar2(32767) := '';
lv_SqlLnBrkUp varchar2(2000) :='';
lv_fn_stdt DATE := TO_DATE(P_START_DT,'DD/MM/YYYY');
lv_fn_endt DATE := TO_DATE(P_END_DT,'DD/MM/YYYY');
lv_YYYYMM  VARCHAR2(10) := to_char(lv_fn_endt,'YYYYMM'); --substr(P_END_DT,5,4)||substr(P_END_DT,3,2);
lv_Remarks          varchar2(1000) := '';
lv_SqlStr           varchar2(10000) := '';
lv_parvalues        varchar2(500);
lv_sqlerrm          varchar2(500) := '';   
lv_ProcName         varchar2(30)   := 'PRC_REALIZEDUNREALDATA_INSERT'; 
lv_Component        varchar2(4000) := ''; 
lv_strWorkerSerial  varchar2(10) :='';
lv_TableName        varchar2(30) := '';
lv_MasterTable      varchar2(30) := '';
lv_ModuleTableNm    varchar2(30) := '';
lv_ColName          varchar2(500) := '';
lv_TableColName     varchar2(500) := '';
lv_InsertTable      varchar2(30) := '';
lv_Workerserial     varchar2(10) := '';
lv_UnrealizedTable  varchar2(30) := '';


P_YEARCODE VARCHAR2, 
Begin


    lv_TableName := P_TABLENAME;


    IF SUBSTR(P_START_DT,1,2) = '16'  THEN
        RETURN;
    END IF;


    if P_MODULE = 'PIS' then
            --lv_TableName := 'PISPAYTRANSACTION_SWT';
            lv_MasterTable := 'PISEMPLOYEEMASTER';
            lv_UnrealizedTable :='PISUNREALIZEDDATA';
        else
            --lv_TableName := 'WPSWAGESDETAILS_MV_SWT';
            lv_MasterTable := 'WPSWORKERMAST';
            lv_UnrealizedTable :='WPSUNREALIZEDDATA';
            
        end if; 

    if P_MODULE = 'WPS' THEN
    
        lv_sql := ' DELETE FROM ' || lv_UnrealizedTable ||' WHERE FORTNIGHTENDDATE = TO_DATE('''||P_END_DT||''',''DD/MM/YYYY'') '||CHR(10)
                ||' AND MODULE = '''|| P_MODULE||''' '||CHR(10)
                ||' AND COMPONENTCODE = '''||P_COMPONENTCODE || '''' ||CHR(10);
        
        IF P_TRANTYPE ='ALL' THEN
        
            lv_sql := lv_sql  ||' AND TRANTYPE IN (''REALIZED'',''UNREALIZED'')'||CHR(10);
            lv_Remarks := P_MODULE ||' REALIZED/UNREALIZED ' || P_COMPONENTCODE || ' DATA DELETE';
            
        ELSIF P_TRANTYPE ='REALIZED' THEN
        
            lv_sql := lv_sql  ||' AND TRANTYPE = ''REALIZED'' '||CHR(10);
            lv_Remarks := P_MODULE||' REALIZED ' || P_COMPONENTCODE || ' DATA DELETE';
            
        ELSIF P_TRANTYPE ='UNREALIZED' THEN
        
            lv_sql := lv_sql  ||' AND TRANTYPE =''UNREALIZED'' '||CHR(10);
            lv_Remarks := P_MODULE||' UNREALIZED ' || P_COMPONENTCODE || ' DATA DELETE';
            
        END IF;   
        
        
        if P_WORKERSERIAL IS NOT null or length(P_WORKERSERIAL) <> 0 then        
            lv_sql := lv_sql  ||' AND WORKERSERIAL IN (''' || P_WORKERSERIAL || ''') '||CHR(10);
        end if;        
                
        
        insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
        EXECUTE IMMEDIATE lv_sql;
        
        
    END IF; 
    
    if P_MODULE = 'WPS' THEN
    
        
        IF P_TRANTYPE ='REALIZED' THEN
            
            lv_sql := ' INSERT INTO ' || lv_UnrealizedTable || '( '||chr(10)
                    ||'        COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE , WORKERSERIAL, TOKENNO,  '||chr(10) 
                    ||'        COMPONENTCODE, COMPONENTAMOUNT, ACTUALAMOUNT, REFERENCE_FNEDATE, PAIDON, TRANTYPE, MODULE, REMARKS, '||chr(10)
                    ||'        SYSROSWID,USERNAME, LASTMODIFIED) '||chr(10)
                    ||' SELECT B.COMPANYCODE, B.DIVISIONCODE, B.YEARCODE, B.FORTNIGHTSTARTDATE, B.FORTNIGHTENDDATE , B.WORKERSERIAL, B.TOKENNO, '||chr(10);
                    
                    
                    if P_COMPONENTCODE = 'LIC' then        
                        lv_sql := lv_sql  ||'        '''|| P_COMPONENTCODE || ''' AS COMPONENTCODE , (NVL(LIC,0) - NVL(A.INSURANCEAMOUNT,0))*-1 COMPONENTAMOUNT,'||chr(10);
                    ELSIF P_COMPONENTCODE = 'SHOP_RENT' then
                        lv_sql := lv_sql  ||'        '''|| P_COMPONENTCODE || ''' AS COMPONENTCODE , (NVL(B..SHOP_RENT,0) - NVL(A.SHOP_RENT,0))*-1 COMPONENTAMOUNT,'||chr(10);
                    END IF;
                    
            lv_sql := lv_sql  ||'        NVL(A.INSURANCEAMOUNT,0) AS ACTUALAMOUNT , B.FORTNIGHTENDDATE AS REFERENCE_FNEDATE , B.FORTNIGHTENDDATE PAIDON, '||chr(10)
                    ||'        ''REALIZED'' AS TRANTYPE , ''' || P_MODULE || ''' AS MODULE ,''' || P_COMPONENTCODE|| ' REALIZED'' AS MODULE , '||chr(10)
                    ||'        TO_CHAR(SYSDATE,''DDMMYYYHHMISS'')||''-''||B.WORKERSERIAL SYSROWID, ''SWT'' USERNAME, SYSDATE LASTMODIFIED '||chr(10)
                    ||'  FROM ' || lv_MasterTable || ' A, '||P_TABLENAME||' B ' ||chr(10) 
                    ||' WHERE A.COMPANYCODE = '''||  P_COMPCODE || ''' AND A.DIVISIONCODE = '''|| P_DIVCODE || ''' '||chr(10)  
                    ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||chr(10)  
                    ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)  
                    ||'   AND B.FORTNIGHTENDDATE = TO_DATE(''' || P_END_DT ||''',''DD/MM/YYYY'')'||chr(10);
                    
                    if P_COMPONENTCODE = 'LIC' then           
                        lv_sql := lv_sql  ||'   AND NVL(LIC,0) -NVL(A.INSURANCEAMOUNT,0) > 0'||chr(10) ;
                    ELSIF P_COMPONENTCODE = 'SHOP_RENT' then
                        lv_sql := lv_sql  ||'   AND NVL(B.SHOP_RENT,0) - NVL(A.SHOP_RENT,0) > 0'||chr(10) ;
                    END IF;    
                    
                    
                     if P_WORKERSERIAL IS NOT null or length(P_WORKERSERIAL) <>0 then        
                        lv_sql := lv_sql  ||' AND WORKERSERIAL IN (''' || P_WORKERSERIAL || ''') '||CHR(10);
                     end if;        
       
            lv_Remarks := P_COMPONENTCODE || ' DATA TRANSFER TO ' || lv_UnrealizedTable;
            insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
            
            --DBMS_OUTPUT.PUT_LINE(lv_sql);
            EXECUTE IMMEDIATE lv_sql;
            
            lv_sql := '';
            COMMIT;
            
        ELSIF P_TRANTYPE ='UNREALIZED' THEN
        
            lv_sql := ' INSERT INTO ' || lv_UnrealizedTable || '( '||chr(10)
                    ||'        COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE , WORKERSERIAL, TOKENNO,  '||chr(10) 
                    ||'        COMPONENTCODE, COMPONENTAMOUNT, ACTUALAMOUNT, REFERENCE_FNEDATE, PAIDON, TRANTYPE, MODULE, REMARKS, '||chr(10)
                    ||'        SYSROSWID, USERNAME,  LASTMODIFIED) '||chr(10)
                    ||' SELECT B.COMPANYCODE, B.DIVISIONCODE, ''' || P_YEARCODE || ''' AS YEARCODE, TO_DATE(''' || P_START_DT || ''',''DD/MM/YYYY'') AS  FORTNIGHTSTARTDATE, TO_DATE(''' || P_END_DT || ''',''DD/MM/YYYY'') AS  FORTNIGHTENDDATE , A.WORKERSERIAL, A.TOKENNO, '||chr(10);
                    
                    if P_COMPONENTCODE = 'LIC' then         
                        lv_sql := lv_sql  ||'        '''|| P_COMPONENTCODE || ''' AS COMPONENTCODE , NVL(A.INSURANCEAMOUNT,0) COMPONENTAMOUNT,'||chr(10)
                                          ||'        NVL(A.INSURANCEAMOUNT,0) AS ACTUALAMOUNT , TO_DATE(''' || P_END_DT || ''',''DD/MM/YYYY'') AS REFERENCE_FNEDATE , TO_DATE(''' || P_END_DT || ''',''DD/MM/YYYY'') AS PAIDON, '||chr(10);
                    
                    ELSIF P_COMPONENTCODE = 'SHOP_RENT' then
                        lv_sql := lv_sql  ||'        '''|| P_COMPONENTCODE || ''' AS COMPONENTCODE , NVL(A.SHOP_RENT,0) COMPONENTAMOUNT,'||chr(10)
                                          ||'        NVL(A.SHOP_RENT,0) AS ACTUALAMOUNT , TO_DATE(''' || P_END_DT || ''',''DD/MM/YYYY'') AS REFERENCE_FNEDATE , TO_DATE(''' || P_END_DT || ''',''DD/MM/YYYY'') AS PAIDON, '||chr(10);
                    END IF;
                    
                    lv_sql := lv_sql||'        ''UNREALIZED'' AS TRANTYPE , ''' || P_MODULE || ''' AS MODULE ,''' || P_COMPONENTCODE|| ' UNREALIZED'' AS REMARKS, '||chr(10)
                    ||'        TO_CHAR(SYSDATE,''DDMMYYYHHMISS'')||''-''||B.WORKERSERIAL SYSROWID, ''SWT'' USERNAME, SYSDATE LASTMODIFIED '||chr(10)
                    ||' FROM ' || lv_MasterTable || ' A, (  SELECT COMPANYCODE, DIVISIONCODE , WORKERSERIAL  FROM '||lv_MasterTable|| chr(10);
                    
                    if P_COMPONENTCODE = 'LIC' then                          
                        lv_sql := lv_sql||'                                      WHERE NVL(INSURANCEAMOUNT,0) > 0'||chr(10)
                                    ||'                                        AND NVL(INSURANCEAPPLICABLE,''N'') =''Y'' '||chr(10);
                    ELSIF P_COMPONENTCODE = 'SHOP_RENT' then
                        lv_sql := lv_sql||'                                      WHERE NVL(SHOP_RENT,0) > 0'||chr(10);
                    END IF;
                    
                    
                    lv_sql := lv_sql||'                                        AND ACTIVE=''Y'' ' ||chr(10)
                    ||'                                      MINUS ' ||chr(10)
                    ||'                                     SELECT COMPANYCODE, DIVISIONCODE , WORKERSERIAL '||chr(10)
                    ||'                                       FROM ' || lv_TableName  ||chr(10)
                    ||'                                      WHERE FORTNIGHTENDDATE = TO_DATE(''' || P_END_DT || ''' ,''DD/MM/YYYY'') '||chr(10);
                    
                    if P_COMPONENTCODE = 'LIC' then             
                        lv_sql := lv_sql||'                                        AND NVL (LIC,0) > 0  '||chr(10);
                    ELSIF P_COMPONENTCODE = 'SHOP_RENT' then  
                        lv_sql := lv_sql||'                                        AND NVL (SHOP_RENT,0) > 0  '||chr(10);
                    END IF;
                    
                    
                    lv_sql := lv_sql||'                                  ) B' ||chr(10)
                    ||' WHERE A.COMPANYCODE = '''||  P_COMPCODE || ''' AND A.DIVISIONCODE = '''|| P_DIVCODE || ''' '||chr(10)  
                    ||'   AND A.COMPANYCODE = B.COMPANYCODE  AND A.DIVISIONCODE = B.DIVISIONCODE  '||chr(10)  
                    ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||chr(10) ; 
                    
                    
                    
                     if P_WORKERSERIAL IS NOT null or length(P_WORKERSERIAL) <>0 then        
                        lv_sql := lv_sql  ||' AND A.WORKERSERIAL IN (''' || P_WORKERSERIAL || ''') '||CHR(10);
                     end if;        
       
            lv_Remarks := P_COMPONENTCODE || ' DATA TRANSFER TO ' || lv_UnrealizedTable;
            insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
            
            --DBMS_OUTPUT.PUT_LINE(lv_sql);
            EXECUTE IMMEDIATE lv_sql;
            
            
            lv_sql := '';
            COMMIT;
            
        ELSE -- [IN CASE OF ALL]
            -- INSERT  Realized Data START
            
            
            lv_sql := ' INSERT INTO ' || lv_UnrealizedTable || '( '||chr(10)
                    ||'        COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE , WORKERSERIAL, TOKENNO,  '||chr(10) 
                    ||'        COMPONENTCODE, COMPONENTAMOUNT, ACTUALAMOUNT, REFERENCE_FNEDATE, PAIDON, TRANTYPE, MODULE, REMARKS, '||chr(10)
                    ||'        SYSROSWID,USERNAME, LASTMODIFIED) '||chr(10)
                    ||' SELECT B.COMPANYCODE, B.DIVISIONCODE, B.YEARCODE, B.FORTNIGHTSTARTDATE, B.FORTNIGHTENDDATE , B.WORKERSERIAL, B.TOKENNO, '||chr(10);
                    
                    
                    if P_COMPONENTCODE = 'LIC' then        
                        lv_sql := lv_sql  ||'        '''|| P_COMPONENTCODE || ''' AS COMPONENTCODE , (  NVL(LIC,0) - NVL(A.INSURANCEAMOUNT,0))*-1 COMPONENTAMOUNT,'||chr(10);
                    ELSIF P_COMPONENTCODE = 'SHOP_RENT' then
                        lv_sql := lv_sql  ||'        '''|| P_COMPONENTCODE || ''' AS COMPONENTCODE , (NVL(B.SHOP_RENT,0) - NVL(A.SHOP_RENT,0))*-1 COMPONENTAMOUNT,'||chr(10);
                    END IF;
                    
            lv_sql := lv_sql  ||'        NVL(A.INSURANCEAMOUNT,0) AS ACTUALAMOUNT , B.FORTNIGHTENDDATE AS REFERENCE_FNEDATE , B.FORTNIGHTENDDATE PAIDON, '||chr(10)
                    ||'        ''REALIZED'' AS TRANTYPE , ''' || P_MODULE || ''' AS MODULE ,''' || P_COMPONENTCODE|| ' REALIZED'' AS MODULE , '||chr(10)
                    ||'        TO_CHAR(SYSDATE,''DDMMYYYHHMISS'')||''-''||B.WORKERSERIAL SYSROWID, ''SWT'' USERNAME, SYSDATE LASTMODIFIED '||chr(10)
                    ||' FROM ' || lv_MasterTable || ' A, '||P_TABLENAME||' B ' ||chr(10) 
                    ||' WHERE A.COMPANYCODE = '''||  P_COMPCODE || ''' AND A.DIVISIONCODE = '''|| P_DIVCODE || ''' '||chr(10)  
                    ||'   AND A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||chr(10)  
                    ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||chr(10)  
                    ||'   AND B.FORTNIGHTENDDATE = TO_DATE(''' || P_END_DT ||''',''DD/MM/YYYY'')'||chr(10);
                    
                    if P_COMPONENTCODE = 'LIC' then           
                        lv_sql := lv_sql  ||'   AND  NVL(LIC,0) - NVL(A.INSURANCEAMOUNT,0)  > 0'||chr(10) ;
                    ELSIF P_COMPONENTCODE = 'SHOP_RENT' then
                        lv_sql := lv_sql  ||'   AND NVL(B.SHOP_RENT,0) - NVL(A.SHOP_RENT,0) > 0'||chr(10) ;
                    END IF;    
                    
                    
                     if P_WORKERSERIAL IS NOT null or length(P_WORKERSERIAL) <>0 then        
                        lv_sql := lv_sql  ||' AND WORKERSERIAL IN (''' || P_WORKERSERIAL || ''') '||CHR(10);
                     end if;        
       
            lv_Remarks := P_COMPONENTCODE || ' DATA TRANSFER TO ' || lv_UnrealizedTable;
            insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
            
            DBMS_OUTPUT.PUT_LINE(lv_sql);
            EXECUTE IMMEDIATE lv_sql;
            -- INSERT Realized Data END
            lv_sql := '';
            COMMIT;
            -- INSERT  UN Realized Data START
            
            lv_sql := ' INSERT INTO ' || lv_UnrealizedTable || '( '||chr(10)
                    ||'        COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE , WORKERSERIAL, TOKENNO,  '||chr(10) 
                    ||'        COMPONENTCODE, COMPONENTAMOUNT, ACTUALAMOUNT, REFERENCE_FNEDATE, PAIDON, TRANTYPE, MODULE, REMARKS, '||chr(10)
                    ||'        SYSROSWID,USERNAME, LASTMODIFIED) '||chr(10)
                    ||' SELECT B.COMPANYCODE, B.DIVISIONCODE, ''' || P_YEARCODE || ''' AS YEARCODE, TO_DATE(''' || P_START_DT || ''',''DD/MM/YYYY'') AS  FORTNIGHTSTARTDATE, TO_DATE(''' || P_END_DT || ''',''DD/MM/YYYY'') AS  FORTNIGHTENDDATE , A.WORKERSERIAL, A.TOKENNO, '||chr(10);
                    
                    if P_COMPONENTCODE = 'LIC' then         
                        lv_sql := lv_sql  ||'        '''|| P_COMPONENTCODE || ''' AS COMPONENTCODE , NVL(A.INSURANCEAMOUNT,0) COMPONENTAMOUNT,'||chr(10)
                                          ||'        NVL(A.INSURANCEAMOUNT,0) AS ACTUALAMOUNT , TO_DATE(''' || P_END_DT || ''',''DD/MM/YYYY'') AS REFERENCE_FNEDATE , TO_DATE(''' || P_END_DT || ''',''DD/MM/YYYY'') AS PAIDON, '||chr(10);
                    
                    ELSIF P_COMPONENTCODE = 'SHOP_RENT' then
                        lv_sql := lv_sql  ||'        '''|| P_COMPONENTCODE || ''' AS COMPONENTCODE , NVL(A.SHOP_RENT,0) COMPONENTAMOUNT,'||chr(10)
                                          ||'        NVL(A.SHOP_RENT,0) AS ACTUALAMOUNT , TO_DATE(''' || P_END_DT || ''',''DD/MM/YYYY'') AS REFERENCE_FNEDATE , TO_DATE(''' || P_END_DT || ''',''DD/MM/YYYY'') AS PAIDON, '||chr(10);
                    END IF;
                    
                    lv_sql := lv_sql||'        ''UNREALIZED'' AS TRANTYPE , ''' || P_MODULE || ''' AS MODULE ,''' || P_COMPONENTCODE|| ' UNREALIZED'' AS REMARKS, '||chr(10)
                    ||'        TO_CHAR(SYSDATE,''DDMMYYYHHMISS'')||''-''||B.WORKERSERIAL SYSROWID, ''SWT'' USERNAME, SYSDATE LASTMODIFIED '||chr(10)
                    ||' FROM ' || lv_MasterTable || ' A, (  SELECT COMPANYCODE, DIVISIONCODE , WORKERSERIAL  FROM '||lv_MasterTable|| chr(10);
                    
                    if P_COMPONENTCODE = 'LIC' then                          
                        lv_sql := lv_sql||'                                      WHERE NVL(INSURANCEAMOUNT,0) > 0'||chr(10)
                                    ||'                                        AND NVL(INSURANCEAPPLICABLE,''N'') =''Y'' '||chr(10);
                    ELSIF P_COMPONENTCODE = 'SHOP_RENT' then
                        lv_sql := lv_sql||'                                      WHERE NVL(SHOP_RENT,0) > 0'||chr(10);
                    END IF;
                    
                    
                    lv_sql := lv_sql||'                                        AND ACTIVE=''Y'' ' ||chr(10)
                    ||'                                      MINUS ' ||chr(10)
                    ||'                                     SELECT COMPANYCODE, DIVISIONCODE , WORKERSERIAL '||chr(10)
                    ||'                                       FROM ' || lv_TableName  ||chr(10)
                    ||'                                      WHERE FORTNIGHTENDDATE = TO_DATE(''' || P_END_DT || ''' ,''DD/MM/YYYY'') '||chr(10);
                    
                    if P_COMPONENTCODE = 'LIC' then             
                        lv_sql := lv_sql||'                                        AND NVL (LIC,0) > 0  '||chr(10);
                    ELSIF P_COMPONENTCODE = 'SHOP_RENT' then  
                        lv_sql := lv_sql||'                                        AND NVL (SHOP_RENT,0) > 0  '||chr(10);
                    END IF;
                    
                    
                    lv_sql := lv_sql||'                                  ) B' ||chr(10)
                    ||' WHERE A.COMPANYCODE = '''||  P_COMPCODE || ''' AND A.DIVISIONCODE = '''|| P_DIVCODE || ''' '||chr(10)  
                    ||'   AND A.COMPANYCODE = B.COMPANYCODE  AND A.DIVISIONCODE = B.DIVISIONCODE  '||chr(10)  
                    ||'   AND A.WORKERSERIAL = B.WORKERSERIAL  '||chr(10) ; 
                    
                    
                    
                     if P_WORKERSERIAL IS NOT null or length(P_WORKERSERIAL) <>0 then        
                        lv_sql := lv_sql  ||' AND A.WORKERSERIAL IN (''' || P_WORKERSERIAL || ''') '||CHR(10);
                     end if;     
       
            lv_Remarks := P_COMPONENTCODE || ' DATA TRANSFER TO ' || lv_UnrealizedTable;
            insert into wps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,'',lv_Sql,lv_parvalues, lv_fn_stdt, lv_fn_endt, lv_Remarks);
            
            DBMS_OUTPUT.PUT_LINE(lv_sql);
            EXECUTE IMMEDIATE lv_sql;
            -- INSERT  UN Realized Data END
            lv_sql := '';
            COMMIT;
        
        END IF;
                
    -- ELSE (FOR PIS)
    
    end if;           
           
return;
exception
    when others then
          lv_sqlerrm := sqlerrm ;
    insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) values( lv_ProcName,lv_sqlerrm,lv_sql,lv_parvalues,lv_fn_stdt,lv_fn_endt, lv_remarks);      
end;
/
