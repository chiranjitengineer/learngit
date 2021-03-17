DROP PROCEDURE NJMCL_WEB.PROC_WPSQUALITYRATEONREEDSPACE;

CREATE OR REPLACE PROCEDURE NJMCL_WEB."PROC_WPSQUALITYRATEONREEDSPACE" (P_COMPCODE Varchar2, 
                                                                          P_DIVCODE Varchar2, 
                                                                          P_EFFECTIVEDATE Varchar2, 
                                                                          P_PRODUCTIONTYPE Varchar2,
                                                                          p_UNITQUANTITY Varchar2,
                                                                          p_PERCENTAGEOFRATE Varchar2,
                                                                          P_OPERATIONMODE Varchar2,
                                                                          P_USERNAME Varchar2,
                                                                          P_MODEOFEXECUTION Varchar2
                                                                          )
as
lv_Sql       varchar2(32767) := '';
lv_Pivot varchar2(1000) := '';
lv_ColumnName varchar2(1000) := '';
lv_sqlerrm varchar2(5000) := '';
lv_temp_table varchar2(30) := '';
LV_EFFECTIVEDATE varchar2(30) := '';

begin

    IF P_MODEOFEXECUTION = 'SELECT' THEN 


         IF  P_PRODUCTIONTYPE IN ('P0001','P0002') THEN
            SELECT LISTAGG_SWT1(ROWNUM||';'||REEDSPACE || ' AS RS' || REEDSPACEDESC ||',') INTO lv_Pivot  FROM 
              (
                  SELECT DISTINCT  REEDSPACE, REEDSPACEDESC FROM WPSREEDSPACEMAST 
                  WHERE COMPANYCODE = P_COMPCODE
                  AND DIVISIONCODE = P_DIVCODE
                  AND ACTIVE = 'Y'
                  ORDER BY REEDSPACE
              );
                 
                  
              SELECT LISTAGG_SWT1(ROWNUM||';'||'RS' || REEDSPACEDESC ||',') INTO lv_ColumnName  FROM 
              (
                  SELECT DISTINCT  REEDSPACE, REEDSPACEDESC FROM WPSREEDSPACEMAST 
                  WHERE COMPANYCODE = P_COMPCODE
                  AND DIVISIONCODE = P_DIVCODE
                  AND ACTIVE = 'Y'
                  ORDER BY REEDSPACE
              );
        ELSE
                lv_Pivot := '0 as RATE';
                lv_ColumnName := 'RATE';  
        END IF;
        
        
        -- dbms_output.put_line('lv_Pivot ' || lv_Pivot);
       --  dbms_output.put_line('lv_ColumnName ' || lv_ColumnName);
        
        lv_Sql := 'DROP TABLE TMP_WPSQUALITYRATEONREEDSPACE';
        BEGIN 
            EXECUTE IMMEDIATE lv_sql;
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
        
        

        SELECT TO_CHAR(MAX(EFFECTIVEDATE),'DD/MM/YYYY') INTO LV_EFFECTIVEDATE FROM WPSQUALITYRATE_ON_REEDSPACE
        WHERE COMPANYCODE = P_COMPCODE
        AND DIVISIONCODE = P_DIVCODE
        AND PRODUCTIONTYPE = P_PRODUCTIONTYPE;

        
        
        lv_Sql := 'CREATE  TABLE   TMP_WPSQUALITYRATEONREEDSPACE '|| CHR(10)
                 ||'AS '||CHR(10)
                 ||' SELECT  QUALITYCODE, QUALITYNAME,'|| CHR(10) 
                 || lv_ColumnName || ','  || CHR(10) 
                 ||' COMPANYCODE,DIVISIONCODE, EFFECTIVEDATE, PRODUCTIONTYPE, '  || CHR(10)
                 ||' ''' || P_USERNAME || '''USERNAME,''' || P_OPERATIONMODE || ''' OPERATIONMODE, '|| CHR(10)
                 ||' ''' || p_UNITQUANTITY || '''UNITQUANTITY,''' || p_PERCENTAGEOFRATE || ''' PERCENTAGEOFRATE '|| CHR(10)
                 ||'  FROM   (    '||CHR(10)
                 ||'    SELECT DISTINCT M.QUALITYCODE, M.QUALITYNAME, W.REEDSPACE, W.QUALITYRATE,'|| CHR(10) 
                 ||'      M.COMPANYCODE,M.DIVISIONCODE, ''' || P_EFFECTIVEDATE || ''' EFFECTIVEDATE, M.PRODUCTIONTYPE,W.UNITQUANTITY, W.PERCENTAGEOFRATE '|| CHR(10)
                 ||'          FROM  WPSQUALITYRATE_ON_REEDSPACE W, WPSQUALITYMASTER M   '|| CHR(10)
                 ||'           WHERE W.COMPANYCODE(+) = M.COMPANYCODE  '|| CHR(10)
                 ||'           AND W.DIVISIONCODE(+) = M.DIVISIONCODE '|| CHR(10)
                 ||'           AND W.PRODUCTIONTYPE(+) = M.PRODUCTIONTYPE '|| CHR(10)
                 ||'           AND W.QUALITYCODE(+) = M.QUALITYCODE '|| CHR(10)
                 ||'           AND M.COMPANYCODE = '''||P_COMPCODE||'''   '|| CHR(10)
                 ||'           AND M.DIVISIONCODE = '''||P_DIVCODE||'''   '|| CHR(10)
                 ||'           AND W.EFFECTIVEDATE(+) = TO_DATE('''||LV_EFFECTIVEDATE||''',''DD/MM/YYYY'')  '|| CHR(10)
                 ||'           AND M.PRODUCTIONTYPE = '''||P_PRODUCTIONTYPE||'''   '|| CHR(10)     
                 ||'  ) '||CHR(10)
                 ||'    PIVOT '||CHR(10)
                 ||'    ( MAX(QUALITYRATE) FOR '||CHR(10)
                 ||'       REEDSPACE IN ('||lv_Pivot||')   '|| CHR(10)
                 ||'    ) ';
        
         --   dbms_output.put_line(lv_Sql);
         execute immediate lv_Sql;            
         
        lv_temp_table :=   'TMP_WPSQUALITYRATEONREEDSPACE';
        
        lv_Sql := 'create or replace force view vw_auto_dynamicgrid_rs'|| chr(10);
        lv_Sql := lv_Sql || '('|| chr(10);
        lv_Sql := lv_Sql || '   companycode,'|| chr(10);
        lv_Sql := lv_Sql || '   column_name,'|| chr(10);
        lv_Sql := lv_Sql || '   column_header,'|| chr(10);
        lv_Sql := lv_Sql || '   column_length,'|| chr(10);
        lv_Sql := lv_Sql || '   column_data,'|| chr(10);
        lv_Sql := lv_Sql || '   qry_header'|| chr(10);
        lv_Sql := lv_Sql || ')'|| chr(10);
        lv_Sql := lv_Sql || 'as'|| chr(10);
        lv_Sql := lv_Sql || 'select  '''||P_COMPCODE||''' companycode,'|| chr(10);
        lv_Sql := lv_Sql || '    ( '|| chr(10);
        lv_Sql := lv_Sql || '     select rtrim(xmlagg(xmlelement(e, x.column_name || '','')order by x.serialno).extract (''//text()''),'','') column_name '|| chr(10);
        lv_Sql := lv_Sql || '       from (select ''^'' ||cname||''^'' column_name, colno serialno from col '|| chr(10);
        lv_Sql := lv_Sql || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
        lv_Sql := lv_Sql || '              order by colno) x ) column_name, '|| chr(10);
        lv_Sql := lv_Sql || '    ( '|| chr(10);
        lv_Sql := lv_Sql || '     select rtrim(xmlagg(xmlelement(e, x.column_header || '','')order by x.serialno).extract (''//text()''),'','') column_header '|| chr(10);
        lv_Sql := lv_Sql || '       from (select UPPER(cname) column_header, colno serialno from col '|| chr(10);
        lv_Sql := lv_Sql || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
        lv_Sql := lv_Sql || '              order by colno) x) column_header, '|| chr(10);
        lv_Sql := lv_Sql || '    ( '|| chr(10);
        lv_Sql := lv_Sql || '     select rtrim(xmlagg(xmlelement(e, x.column_length || '','')order by x.serialno).extract (''//text()''),'','') column_length '|| chr(10);
        lv_Sql := lv_Sql || '       from ( '|| chr(10);
        lv_Sql := lv_Sql || '       select case when upper(cname) in (''COMPANYCODE'',''DIVISIONCODE'', ''EFFECTIVEDATE'', ''PRODUCTIONTYPE'',''UNITQUANTITY'', ''PERCENTAGEOFRATE'',''FIXEDVALUE'', ''FROMVALUE'',''TOVALUE'',''USERNAME'',''OPERATIONMODE'', ''SYSROWID'', ''UNITQUANTITY'', ''PERCENTAGEOFRATE'' ) then 1 '|| chr(10); 
        lv_Sql := lv_Sql || '                    WHEN UPPER(CNAME) = ''QUALITYCODE'' THEN 95 '|| chr(10);
        lv_Sql := lv_Sql || '                    WHEN UPPER(CNAME) = ''QUALITYNAME'' THEN 200  '|| chr(10);
        lv_Sql := lv_Sql || '                    else '|| chr(10);
        lv_Sql := lv_Sql || '                    80  end column_length, colno serialno from col '|| chr(10); 
        lv_Sql := lv_Sql || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
        lv_Sql := lv_Sql || '              order by colno '|| chr(10);
        lv_Sql := lv_Sql || '              ) x) column_length, '|| chr(10);
        lv_Sql := lv_Sql || '    ''[''||( '|| chr(10);
        lv_Sql := lv_Sql || '     select rtrim(xmlagg(xmlelement(e, x.column_data || '','')order by x.serialno).extract (''//text()''),'','') column_data '|| chr(10);
        lv_Sql := lv_Sql || '       from (select trim(''{ data: ^''||cname|| ''^, type: $''|| '|| chr(10);
        lv_Sql := lv_Sql || '                         decode(coltype,''VARCHAR2'',''text'',''NUMBER'',''numeric$,format:$0.00000'',''text'')|| ''$''|| '|| chr(10);
        lv_Sql := lv_Sql || '                         case when upper(cname) in (''COMPANYCODE'',''DIVISIONCODE'', ''EFFECTIVEDATE'', ''PRODUCTIONTYPE'',''UNITQUANTITY'', ''PERCENTAGEOFRATE'',''FIXEDVALUE'', ''FROMVALUE'',''TOVALUE'',''USERNAME'',''OPERATIONMODE'', ''SYSROWID'', ''QUALITYCODE'', ''QUALITYNAME'') then '', readOnly: true, nedit'' '|| chr(10); 
        lv_Sql := lv_Sql || '                               else '', readOnly: false'' end || '|| chr(10);
        lv_Sql := lv_Sql || '                         '' }'') column_data, colno serialno from col '|| chr(10);
        lv_Sql := lv_Sql || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
        lv_Sql := lv_Sql || '              order by colno) x)||'']'' column_data, '|| chr(10);
        lv_Sql := lv_Sql || '    ( '|| chr(10);
        lv_Sql := lv_Sql || '     select rtrim(xmlagg(xmlelement(e, x.qry_header || '','')order by x.serialno).extract (''//text()''),'','') qry_header '|| chr(10);
        lv_Sql := lv_Sql || '       from (select case when coltype=''DATE'' then ''TO_CHAR(''||cname||'',$DD/MM/YYYY$) ''||cname else cname end qry_header, colno serialno from col '|| chr(10);
        lv_Sql := lv_Sql || '                  where tname = '''||lv_temp_table||''' '|| chr(10);
        lv_Sql := lv_Sql || '              order by colno) x) qry_header '|| chr(10);
        lv_Sql := lv_Sql || '            from dual ';
        
       -- dbms_output.put_line(lv_Sql);
        execute immediate lv_Sql;    

    ELSIF P_MODEOFEXECUTION = 'INSERT' THEN
    
            
        lv_Sql := 'DELETE FROM WPSQUALITYRATE_ON_REEDSPACE '|| CHR(10)
        || 'WHERE COMPANYCODE = '''||P_COMPCODE||'''   '|| CHR(10)
        || 'AND DIVISIONCODE = '''||P_DIVCODE||'''   '|| CHR(10)
        || 'AND EFFECTIVEDATE = TO_DATE('''||P_EFFECTIVEDATE||''',''DD/MM/YYYY'')  '|| CHR(10)
        || 'AND PRODUCTIONTYPE = '''||P_PRODUCTIONTYPE||'''   ';
        
       --- dbms_output.put_line(lv_Sql);
       execute immediate lv_Sql;
    
         IF  P_PRODUCTIONTYPE IN ('P0001','P0002') THEN
             SELECT LISTAGG_SWT1(ROWNUM||';'|| 'RS' || REEDSPACEDESC || ' AS ' || REEDSPACE ||',') INTO lv_Pivot  FROM 
              (
                  SELECT DISTINCT  REEDSPACE, REEDSPACEDESC FROM WPSREEDSPACEMAST 
                  WHERE COMPANYCODE = P_COMPCODE
                  AND DIVISIONCODE = P_DIVCODE
                  AND ACTIVE = 'Y'
                  ORDER BY REEDSPACE
              );
        
        ELSE
           lv_Pivot := 'RATE AS 0';         
        END IF;
        
--         dbms_output.put_line(lv_Pivot);
    
        lv_Sql := 'INSERT INTO WPSQUALITYRATE_ON_REEDSPACE(  '|| CHR(10)
                || 'COMPANYCODE, DIVISIONCODE, EFFECTIVEDATE, PRODUCTIONTYPE, QUALITYCODE, UNITQUANTITY, PERCENTAGEOFRATE,  '|| CHR(10)
                || 'REEDSPACE, QUALITYRATE, FIXEDVALUE, FROMVALUE, TOVALUE, USERNAME, LASTMODIFIED, SYSROWID) '|| CHR(10)
                || 'SELECT COMPANYCODE, DIVISIONCODE, TO_DATE(EFFECTIVEDATE,''DD/MM/YYYY''), PRODUCTIONTYPE, QUALITYCODE, UNITQUANTITY, PERCENTAGEOFRATE, '|| CHR(10)
                || 'REEDSPACE, QUALITYRATE, '''' FIXEDVALUE, '''' FROMVALUE, '''' TOVALUE,  ''' || P_USERNAME || '''USERNAME, SYSDATE LASTMODIFIED, '|| CHR(10)
                || 'SYS_GUID() SYSROWID '|| CHR(10)
                || 'FROM TMP_WPSQUALITYRATEONREEDSPACE '|| CHR(10)
                || 'UNPIVOT (QUALITYRATE FOR REEDSPACE IN ('||lv_Pivot||'))';
                
         --dbms_output.put_line(lv_Sql);    
         execute immediate lv_Sql;       
         
         UPDATE HN_WPS_PRODENTRYMASTER
         SET MAXQUALITYRATEEFFECTIVEDATE = TO_DATE(P_EFFECTIVEDATE,'DD/MM/YYYY')
         WHERE TAG = P_PRODUCTIONTYPE;
         
                

    END IF;
     
exception
    when others then
    lv_sqlerrm := sqlerrm ;
    raise_application_error(-20101, lv_sqlerrm);
end;
/


