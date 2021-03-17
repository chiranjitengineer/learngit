DROP PROCEDURE NJMCL_WEB.PRCWPS_IMP_ATTNOTDATA_MANUAL1;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PRCWPS_IMP_ATTNOTDATA_MANUAL1 (P_COMPCODE VARCHAR2,
                                                       P_DIVCODE VARCHAR2,
                                                       P_DATEOFATTENDANCE VARCHAR2,
                                                       P_VALIDORUPDATE CHAR,
                                                       P_USER          VARCHAR2, 
                                                       P_UNITCODE VARCHAR2 DEFAULT NULL,
                                                       P_DEPCODE VARCHAR2 DEFAULT NULL)                                                       
AS
/* ----- SAMPLE PROCEDURE ----- */                                                       
LV_CNT              NUMBER := 0;
tmpVar              NUMBER := 0;
LV_SQLERRM          VARCHAR2(2000):='';
lv_SqlStr           VARCHAR2(4000) := '';
lv_error_remark     VARCHAR2(4000) := '' ;
lv_yearcode         VARCHAR2(20) :='';
lv_entryday         VARCHAR2(20) := LTRIM(RTRIM(TO_CHAR(TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY'),'DAY')));
lv_PROCNAME         varchar2(30) := 'PRCWPS_IMP_ATTNOTDATA_MANUAL';
lv_BookNoPrefix     varchar2(20) := '';
lv_Remarks          varchar2(100) := '';
lv_FnStDt           varchar2(10) := '';
lv_FnEnDt           varchar2(10) := '' ;
lv_MAXSPELLHOURS_SPELL1    NUMBER ;
lv_MAXSPELLHOURS_SPELL2    NUMBER ;
lv_upd              varchar2(1) ;
/* FOLLOWING CONDITION CHECKED IN THIS PROCEDURE BEFORE VERIFIED
    1. Checking whether Date of Attendance Parameter is Greater than the Current Date
    2. Normal and O.T. Hours in same shift in Raw data.   
    3. Spell Wise hours can't exceed the maximum hours
    4. ATTENDANCE DATE, TOKEN, SHIFT WISE DUPLICATE RECORD 
    5. INVALID DEPARTMENT AND OCCUPATION CODE , AND INVALID SHIFT
    6. INVALID TOKEN No.
    7. Checking Normal attendance in different shift 
    7. Norma attendance hours more than 8
    8. Normal attendance in Master Day Off
    9. Data already exist in in attendance table based on date, shift, occupation (CONSIDER BOTH VERIFIED AND APPROVED ) 
   10. Worker in STL but normal attendance found        (CONSIDER BOTH VERIFIED AND APPROVED )
   11. Worker in Leave (other than STL) but normal attendance found   (CONSIDER BOTH VERIFIED AND APPROVED )
*/
--EXEC PRCWPS_IMP_ATTNOTDATA_MANUAL ('0001','0002','01/06/2019','V','SWT')    
BEGIN   
  select count(*) into LV_CNT from WPSATTNCSVDATA_STAGE ;
  if LV_CNT > 0 then   
   BEGIN
        
--    delete from WPSATTENDANCECSVRAWDATA where (ATTENDATE, SHIFT, TOKENNO) 
--      in ( SELECT ATTENDATE, SHIFT, TOKENNO  FROM WPSATTNCSVDATA_STAGE );

    UPDATE WPSATTNCSVDATA_STAGE set SECTION = LPAD(LTRIM(RTRIM(SECTION)),4,'0'),OCCUPATION =LPAD(LTRIM(RTRIM(OCCUPATION)),3,'0') WHERE ATTENDATE = P_DATEOFATTENDANCE;
      
    FOR C1 IN ( SELECT DISTINCT SECTION, SHIFT FROM WPSATTNCSVDATA_STAGE)
    LOOP
        DELETE FROM WPSATTENDANCECSVRAWDATA WHERE ATTENDATE = P_DATEOFATTENDANCE
        AND SECTION = C1.SECTION AND SHIFT = C1.SHIFT;
    END LOOP;
                          
      
    insert into WPSATTENDANCECSVRAWDATA( ATTENDATE,DEPARTMENT, SECTION, SHIFT, OCCUPATION, TOKENNO, SPELLHRS_1, SPELLHRS_2, OTHOURS, APPROVED, VERIFIED ,USERNAME    )
    select ATTENDATE,DEPARTMENTCODE, SECTION, SHIFT, OCCUPATION, TOKENNO, SPELLHRS_1, SPELLHRS_2, OTHOURS, 'N', 'N',P_USER
    from WPSATTNCSVDATA_STAGE A,WPSSECTIONMAST B
    WHERE B.COMPANYCODE=P_COMPCODE
        AND B.DIVISIONCODE=P_DIVCODE
        AND B.SECTIONCODE=A.SECTION ;
        
    --delete from WPSATTNCSVDATA_STAGE;
    commit;  
   EXCEPTION
    WHEN OTHERS THEN
     ROLLBACK;
   END; 
  end if;
    tmpVar := 0;

    if substr(P_DATEOFATTENDANCE,1,2) <= 15 then
        lv_FnStDt   := '01'||substr(P_DATEOFATTENDANCE,3);
        lv_FnEnDt   := '15'||substr(P_DATEOFATTENDANCE,3);
    else
        lv_FnStDt   := '16'||substr(P_DATEOFATTENDANCE,3);
        lv_FnEnDt   := TO_CHAR(LAST_DAY(TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')),'DD/MM/YYYY');
    end if;
   -- dbms_output.put_line ('XXAXAXXAAX');
    DELETE FROM WPS_ERROR_LOG WHERE PROC_NAME = lv_PROCNAME;
    COMMIT;    
    
    SELECT LTRIM(RTRIM(YEARCODE)) INTO lv_yearcode FROM FINANCIALYEAR WHERE 1=1
    AND COMPANYCODE = P_COMPCODE
    AND DIVISIONCODE = P_DIVCODE 
    AND TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY') BETWEEN STARTDATE AND ENDDATE;
  -- dbms_output.put_line ('out '||lv_yearcode||'-'||P_DATEOFATTENDANCE);
   -- UPDATE WPSATTENDANCECSVRAWDATA SET SHIFTCODE=DECODE(SHIFT,'A1','1','A2','1','B1','2','B2','2','3'),
-- UPDATE WPSATTENDANCECSVRAWDATA  SET    SPELLTYPE=DECODE(SHIFT,'A1','SPELL 1','A2','SPELL 2','B1','SPELL 1','B2','SPELL 2','SPELL 1');
    UPDATE WPSATTENDANCECSVRAWDATA  SET  SPELLTYPE =  'SPELL 1' WHERE (SHIFT = '1' AND SPELLHRS_1 <= '5' ) OR (SHIFT = '2' AND SPELLHRS_2 <= '3');
    UPDATE WPSATTENDANCECSVRAWDATA  SET  SPELLTYPE =  'SPELL 2' WHERE (SHIFT = '2' AND SPELLHRS_1 <= '3' ) OR (SHIFT = '2' AND SPELLHRS_2 <= '5');
    UPDATE WPSATTENDANCECSVRAWDATA  SET  SPELLTYPE =  'SPELL 3' WHERE (SHIFT = '3' AND SPELLHRS_1 <= '8' ) ;  
    commit;
    --DBMS_OUTPUT.PUT_LINE ('0_0 DATA INSERT DONE');
    IF P_VALIDORUPDATE='V' THEN     
       /* Checking whether Date of Attendance Parameter is Greater than the Current Date */     
        IF TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY') > TRUNC(SYSDATE) THEN
            lv_error_remark := 'Validation Failure : [Date of Attendance cannot be greater than Current Date.]';
            --dbms_output.put_line (lv_error_remark); 
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
        END IF;   
        
        UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED='Y' 
           WHERE TO_DATE(ATTENDATE,'DD/MM/YYYY')=TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
           AND TOKENNO||SHIFT||SECTION IN ( SELECT TOKENNO||SHIFT||SECTION FROM WPSATTNCSVDATA_STAGE );
       --     WHERE ATTENDATE = P_DATEOFATTENDANCE;      
       --dbms_output.put_line (lv_yearcode||'-'||P_DATEOFATTENDANCE);

        /* 2. Checking Normal and O.T. Hours in same shift in Raw data. */
        lv_Remarks := 'Ckecking Normal attendance, O.T. hrs in Samae Shift';
        lv_SqlStr := ' UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED=''N'', REMARKS=''Normal attendance Hourns, O.T Hours both found.'' '||chr(10)
                   ||' WHERE ATTENDATE = '''||P_DATEOFATTENDANCE||''' AND VERIFIED=''Y'' '||CHR(10)
                   ||'   AND NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0) >0 '||CHR(10)
                   ||'   AND NVL(OTHOURS,0) > 0 '||CHR(10)
                   ||'   AND VERIFIED = ''Y'' '||CHR(10); 
        insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_COMPCODE, lv_Remarks);
        EXECUTE IMMEDIATE lv_SqlStr;
        commit;
      --  DBMS_OUTPUT.PUT_LINE ('1_0 CURRENT DATE CHECKING DONE');
        /* Checking Spell Wise hours can't exceed the maximum hours */
        lv_Remarks := 'Hours can not be more than Spell Hours 1';
        FOR cSpellHrs in ( /*SELECT A.ATTENDATE, A.SHIFT, A.TOKENNO,  A.OTHOURS, A.VERIFIED   
                            FROM WPSATTENDANCECSVRAWDATA A, WPSSPELLMASTER B
                            WHERE ATTENDATE = P_DATEOFATTENDANCE
                              AND VERIFIED = 'Y'
                              AND B.COMPANYCODE=P_COMPCODE AND B.DIVISIONCODE=P_DIVCODE
                              AND A.SHIFT = B.SHIFTCODE AND A.SPELLTYPE = B.SPELLTYPE
                              AND ( NVL(A.SPELLHRS_1,0)+NVL(A.SPELLHRS_2,0) >  NVL(MAXSPELLHOURS,0) OR  NVL(A.OTHOURS,0) >  NVL(MAXSPELLHOURS,0))*/
                         
                          SELECT A.ATTENDATE, A.SHIFT,A.TOKENNO , A.SPELLHRS_1, A.SPELLHRS_2, A.SPELLTYPE
                          FROM WPSATTENDANCECSVRAWDATA A 
                          WHERE A.ATTENDATE = P_DATEOFATTENDANCE
                          AND A.DEPARTMENT||A.SHIFT NOT IN (SELECT DEPARTMENTCODE||'C' FROM WPSDEPARTMENTMASTER WHERE NSAAPPLICABLE='Y')
                          AND A.VERIFIED = 'Y'
                          ORDER BY A.TOKENNO
                         )        
        loop   
           -- DBMS_OUTPUT.PUT_LINE ('1_1 INSIDE LOOP'||cSpellHrs.TOKENNO );      
            if  cSpellHrs.shift = 'A' then
               select MAXSPELLHOURS into lv_MAXSPELLHOURS_SPELL1 from WPSSPELLMASTER where shiftcode = '1' and SPELLTYPE = 'SPELL 1' ;
               select MAXSPELLHOURS into lv_MAXSPELLHOURS_SPELL2 from WPSSPELLMASTER where shiftcode = '1' and SPELLTYPE = 'SPELL 2' ;
           --    DBMS_OUTPUT.PUT_LINE ('1_2 INSIDE LOOP A'); 
            elsif  cSpellHrs.shift = 'B' then            
               select MAXSPELLHOURS into lv_MAXSPELLHOURS_SPELL1 from WPSSPELLMASTER where shiftcode = '2' and SPELLTYPE = 'SPELL 1' ;
               select MAXSPELLHOURS into lv_MAXSPELLHOURS_SPELL2 from WPSSPELLMASTER where shiftcode = '2' and SPELLTYPE = 'SPELL 2' ;
            --   DBMS_OUTPUT.PUT_LINE ('1_2 INSIDE LOOP B');
            else
               select MAXSPELLHOURS,0 into lv_MAXSPELLHOURS_SPELL1 , lv_MAXSPELLHOURS_SPELL2  from WPSSPELLMASTER  where shiftcode = '3' and SPELLTYPE = 'SPELL 1' ;
            --   DBMS_OUTPUT.PUT_LINE ('1_3 INSIDE LOOP C');
            end if;
                
            if cSpellHrs.SPELLHRS_1  > lv_MAXSPELLHOURS_SPELL1 or  cSpellHrs.SPELLHRS_2  > lv_MAXSPELLHOURS_SPELL2 then
            --  DBMS_OUTPUT.PUT_LINE ('1_4 INSIDE LOOP CHECK SPELL HOURS');  
              update WPSATTENDANCECSVRAWDATA set VERIFIED='N', REMARKS= lv_Remarks
              where ATTENDATE = cSpellHrs.ATTENDATE AND TOKENNO = cSpellHrs.TOKENNO 
                    AND SHIFT = cSpellHrs.SHIFT;
            end if;
            --DBMS_OUTPUT.PUT_LINE ('1_6 INSIDE LOOP OUTSIDE IF CONDITION');
        end loop;
        commit;
        --DBMS_OUTPUT.PUT_LINE ('2_0 Hours can not be more than Spell Hours  DONE');
        --dbms_output.put_line ('Hours can not be more than Spell Hours - COMPLETE');
        
             /* Checking Spell Wise hours can't exceed the maximum hours in night allowence department*/
        lv_Remarks := 'Hours can not be more than Spell Hours 2';
        FOR cSpellHrs in ( /*SELECT A.ATTENDATE, A.SHIFT, A.TOKENNO,  A.OTHOURS, A.VERIFIED   
                            FROM WPSATTENDANCECSVRAWDATA A, WPSSPELLMASTER B
                            WHERE ATTENDATE = P_DATEOFATTENDANCE
                              AND VERIFIED = 'Y'
                              AND B.COMPANYCODE=P_COMPCODE AND B.DIVISIONCODE=P_DIVCODE
                              AND A.SHIFT = B.SHIFTCODE AND A.SPELLTYPE = B.SPELLTYPE
                              AND ( NVL(A.SPELLHRS_1,0)+NVL(A.SPELLHRS_2,0) >  NVL(MAXSPELLHOURS,0) OR  NVL(A.OTHOURS,0) >  NVL(MAXSPELLHOURS,0))*/
                         
                          SELECT A.ATTENDATE, A.SHIFT,A.TOKENNO , A.SPELLHRS_1, A.SPELLHRS_2, A.SPELLTYPE
                          FROM WPSATTENDANCECSVRAWDATA A,(SELECT * FROM WPSDEPARTMENTMASTER WHERE NSAAPPLICABLE='Y') B 
                          WHERE A.ATTENDATE = P_DATEOFATTENDANCE
                          AND A.DEPARTMENT||A.SHIFT=B.DEPARTMENTCODE||'C'
                          AND A.VERIFIED = 'Y'
                          ORDER BY A.TOKENNO
                         )        
        loop   
               select (MAXSPELLHOURS+.5),0 into lv_MAXSPELLHOURS_SPELL1 , lv_MAXSPELLHOURS_SPELL2  from WPSSPELLMASTER  where shiftcode = '3' and SPELLTYPE = 'SPELL 1' ;
                
            if cSpellHrs.SPELLHRS_1  > lv_MAXSPELLHOURS_SPELL1 or  cSpellHrs.SPELLHRS_2  > lv_MAXSPELLHOURS_SPELL2 then
            --  DBMS_OUTPUT.PUT_LINE ('1_4 INSIDE LOOP CHECK SPELL HOURS');  
              update WPSATTENDANCECSVRAWDATA set VERIFIED='N', REMARKS= lv_Remarks
              where ATTENDATE = cSpellHrs.ATTENDATE AND TOKENNO = cSpellHrs.TOKENNO 
                    AND SHIFT = cSpellHrs.SHIFT;
            end if;
            --DBMS_OUTPUT.PUT_LINE ('1_6 INSIDE LOOP OUTSIDE IF CONDITION');
        end loop;
        commit;
                              
        /* Checking ATTENDANCE DATE, TOKEN, SHIFT WISE DUPLICATE RECORD */
               
        FOR cDupli IN (
                        SELECT A.ATTENDATE, A.TOKENNO, A.SHIFT, COUNT(*) CNT
                            FROM WPSATTENDANCECSVRAWDATA A                         
                                GROUP BY A.ATTENDATE, A.TOKENNO, A.SHIFT
                                HAVING COUNT(*)>1
                        )
        LOOP    
           UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED='N', REMARKS='Duplicate Entry Found.' 
                WHERE ATTENDATE=cDupli.ATTENDATE AND TOKENNO=cDupli.TOKENNO 
                    AND SHIFT=cDupli.SHIFT;
--                    AND VERIFIED='Y';
        END LOOP;
        COMMIT;
        --dbms_output.put_line ('3_0 Checking ATTENDANCE DATE, TOKEN, SHIFT WISE DUPLICATE RECORD - COMPLETE');
            
        /* Checking whether Invalid Department/Occupation Code exists or not */
        FOR cDepOcc IN (
                SELECT DISTINCT DEPARTMENT||SECTION||OCCUPATION DEPTOCC FROM WPSATTENDANCECSVRAWDATA
                    WHERE TO_DATE(ATTENDATE,'DD/MM/YYYY')=TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                    MINUS
                SELECT DISTINCT DEPARTMENTCODE||SECTIONCODE||OCCUPATIONCODE DEPTOCC FROM WPSOCCUPATIONMAST
                )
        LOOP    
            UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED ='N', REMARKS='Invalid Department/Occupation Code exists.' 
             WHERE  ATTENDATE = P_DATEOFATTENDANCE
               AND DEPARTMENT||OCCUPATION=cDepOcc.DEPTOCC
               AND VERIFIED='Y';
        END LOOP;
        COMMIT;
        --dbms_output.put_line ('4_0 Checking whether Invalid Department/Section/Occupation Code exists or not - COMPLETE');
        
        UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED='N', REMARKS='INVALID SHIFT, SHIFT SHOULD BE 1,2,3'
        WHERE  ATTENDATE = P_DATEOFATTENDANCE
          --AND SHIFT NOT IN ('1','2','3'); 
          AND SHIFT NOT IN ('A','B','C');
        COMMIT;       
        /* Checking Valid Token No. */
        lv_Remarks := 'CHECKING INVALID TOKEN';
        lv_SqlStr := ' UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED = ''N'', REMARKS=''Invalid Token'' '||chr(10)
                   ||' WHERE trim(TOKENNO) IN ( SELECT TRIM(TOKENNO) FROM WPSATTENDANCECSVRAWDATA  WHERE ATTENDATE = '''||P_DATEOFATTENDANCE||''' AND VERIFIED=''Y'' '||CHR(10)
                   ||'              MINUS '||CHR(10)
                   ||'              SELECT TOKENNO FROM WPSWORKERMAST '||CHR(10)
                   ||'              WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                   ||'            ) AND ATTENDATE = '''||P_DATEOFATTENDANCE||''' '||CHR(10);
        insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE, lv_Remarks);
        EXECUTE IMMEDIATE lv_SqlStr;
        commit;
        --dbms_output.put_line ('5_0 Checking Invalid Shift - COMPLETE');
        lv_SqlStr := '';
        /* Checking Valid occupation */
        lv_Remarks := 'CHECKING INVALID TOKEN';
        lv_SqlStr  :='UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED = ''N'', REMARKS=''Invalid Occupation'' '||CHR(10)
                    ||'WHERE SECTION||OCCUPATION IN('||CHR(10)
                    ||'                                 SELECT SECTION||OCCUPATION FROM WPSATTENDANCECSVRAWDATA  WHERE ATTENDATE = '''||P_DATEOFATTENDANCE||''' AND VERIFIED=''Y'' '||CHR(10)
                    ||'                                   MINUS '||CHR(10)
                    ||'                                 SELECT SECTIONCODE||OCCUPATIONCODE FROM WPSOCCUPATIONMAST '||CHR(10)
                    ||'                                   WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                    ||'                             )'
                    ||' AND ATTENDATE = '''||P_DATEOFATTENDANCE||''' '||CHR(10);
        insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE, lv_Remarks);
        EXECUTE IMMEDIATE lv_SqlStr;
        commit;
        
        /* Checking Normal attendance IN DIFFERENT SHIFT */ 
        lv_Remarks := 'NORMAL ATTENDANCE FOUND IN DIFFERENT SHIFT';
        for cNormalHrs in ( SELECT TOKENNO, COUNT(*) CNT
                            FROM ( SELECT DISTINCT TOKENNO, SHIFT 
                                   FROM WPSATTENDANCECSVRAWDATA
                                   WHERE ATTENDATE = P_DATEOFATTENDANCE
                                     AND ( NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0)  ) > 0
                                  )
                            GROUP BY TOKENNO
                            HAVING COUNT (*) >1 
                          )
         LOOP
            update WPSATTENDANCECSVRAWDATA set VERIFIED='N', REMARKS= lv_Remarks
            where ATTENDATE = P_DATEOFATTENDANCE
              and TOKENNO = cNormalHrs.TOKENNO
              and NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0) > 0;
         END LOOP;                   
         --dBms_output.put_line ('6_0 NORMAL ATTENDANCE FOUND IN DIFFERENT SHIFT - COMPLETE');      
          
        /* checking normal attendance in DAYOFF */ 
        lv_Remarks := 'CHECKING NORMAL ATTENDANCE IN DAYOFF ';

        IF TRIM(LTRIM(TO_CHAR(TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY'),'DAY'))) = 'MONDAY' THEN
        
            ----- ALL FACTORY SIDE DEPARMENT MONDAY WORKING GOES TO OVERTIME ---------
            lv_SqlStr:='UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED=''N'', REMARKS=''Normal Attendance transfer to O.T.'' , OTHOURS= (NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0)) '||CHR(10)
                      ||'WHERE ATTENDATE = '''||P_DATEOFATTENDANCE||''' '||CHR(10)
                      ||'   AND DEPARTMENT IN (SELECT DEPARTMENTCODE FROM WPSDEPARTMENTMASTER  WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' AND DEPARTMENTTYPE =''F'')'||CHR(10)
                      ||'   AND NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0) > 0;'||CHR(10);
                insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE, lv_Remarks);
                EXECUTE IMMEDIATE lv_SqlStr;
                commit;
--                dBms_output.put_line ('7_0 CHECKING NORMAL ATTENDANCE IN DAYOFF - COMPLETE');

            ----- MONDAY NIGHT SHIFT ALL WORKERS DAY OFF ------
            lv_SqlStr:='UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED=''Y'', REMARKS=''Normal Attendance transfer to O.T.'', OTHOURS= (NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0)) '||CHR(10)
                      ||'WHERE ATTENDATE = '''||P_DATEOFATTENDANCE||''''||CHR(10)
                      ||'   AND DEPARTMENT <>''3500'' '||CHR(10)
                      ||'   AND SHIFT =''C'' '||CHR(10)
                      ||'   AND NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0) > 0;'||CHR(10);
                insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE, lv_Remarks);
                EXECUTE IMMEDIATE lv_SqlStr;
                commit;
                
--            dBms_output.put_line ('8_0 CHECKING NORMAL ATTENDANCE IN FACTORY SIDE ON MONDAY - COMPLETE');

            ----- DEPARMENT 3500 AND SHIFT 3, MONDAY WORKING GOES TO OVERTIME ---------
            lv_SqlStr:='UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED=''N'', REMARKS=''Normal Attendance transfer to O.T.'', OTHOURS= (NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0))  '||CHR(10)
                      ||'WHERE ATTENDATE = '''||P_DATEOFATTENDANCE||''' '||CHR(10)
                      ||'  AND DEPARTMENT =''3300'''||CHR(10)
                      ||'  AND SHIFT =''C'' '||CHR(10)
                      ||'  AND NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0) > 0;'||CHR(10);
                insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE, lv_Remarks);
                EXECUTE IMMEDIATE lv_SqlStr;
                commit;
--            dBms_output.put_line ('9_0 CHECKING NIGHT SHIFT ON MONDAY - COMPLETE');    
           ----- FOR SECTION 0300,0400,0600 MONDAY WORKING GOES TO OVERTIME --------- 
           lv_SqlStr:='UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED=''Y'',  OTHOURS = (NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0)+NVL(OTHOURS,0)), SPELLHRS_1 = ''0'', SPELLHRS_2 = ''0'',   REMARKS=''Normal Attn Transfer to OT for DayOff'''||CHR(10)
                      ||'WHERE ATTENDATE = '''||P_DATEOFATTENDANCE||''' '||CHR(10)
                      ||'   AND DEPARTMENT = ''0600'''||CHR(10)
                      ||'   AND NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0) > 0;'||CHR(10);
                insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE, lv_Remarks);
                EXECUTE IMMEDIATE lv_SqlStr;
                commit;
            --- FOR WHOM DAYOFF MONDAY
            lv_SqlStr:='UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED=''Y'',  OTHOURS = (NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0)+NVL(OTHOURS,0)), SPELLHRS_1 = ''0'', SPELLHRS_2 = ''0'', REMARKS=''Normal Attn Transfer to OT for DayOff'''||CHR(10)
                        ||' WHERE ATTENDATE = '''||P_DATEOFATTENDANCE||'''  '||CHR(10)
                        ||'   AND TOKENNO IN (SELECT TOKENNO FROM WPSWORKERMAST '||CHR(10)
                        ||'                        WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                        ||'                          AND LTRIM(RTRIM(DAYOFFDAY)) =  TRIM(LTRIM(TO_CHAR(TO_DATE('''||P_DATEOFATTENDANCE||''',''DD/MM/YYYY''),''DAY'')))  ) '||CHR(10)
                        ||'   --AND SHIFT <>''C'''||CHR(10)
                        ||'   AND DEPARTMENT IN (SELECT DEPARTMENTCODE FROM WPSDEPARTMENTMASTER WHERE DIVISIONCODE = '''||P_DIVCODE||''' AND DEPARTMENTTYPE <> ''G'') '||CHR(10)
                        ||'   AND NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0)> 0 '||CHR(10);
            insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE, lv_Remarks);
                EXECUTE IMMEDIATE lv_SqlStr;
                commit;
           ---- ALL MILL SIDE DEPARTMENT OTHER THAN SECTION 300,400,600 AND SHIFT CODE 3 -------
--           lv_SqlStr:='UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED=''N'', REMARKS=''Wrong DayOff'''||CHR(10)
--                      ||'WHERE ATTENDATE = '''||P_DATEOFATTENDANCE||''' '||CHR(10)
--                      ||'   AND DEPARTMENT NOT IN (''0300'',''0400'',''0600'')'||CHR(10)
--                      ||'   AND SHIFT =''C'' '||CHR(10)
--                      ||'   AND NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0) > 0;'||CHR(10);
--                insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE, lv_Remarks);
--                EXECUTE IMMEDIATE lv_SqlStr;
--                commit;
--           dBms_output.put_line ('8_0 CHECKING NORMAL ATTENDANCE OTHER THAN SECTION 300,400,600 - COMPLETE');     
           ---- ALL MILL SIDE WORKER'S DAY OFF MONDAY  -------
--           lv_SqlStr:='UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED=''N'', REMARKS=''Wrong DayOff'''||CHR(10)
--                     ||'WHERE ATTENDATE = '''||P_DATEOFATTENDANCE||''' '||CHR(10)
--                     ||'    AND DEPARTMENT IN (SELECT DEPARTMENTCODE FROM WPSDEPARTMENTMASTER WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' AND DEPARTMENTTYPE <> ''F'')'||CHR(10)
--                     ||'    AND SECTION NOT IN (''0300'',''0400'',''0600'')'||CHR(10)
--                     ||'    AND SHIFT !=''C'''||CHR(10)
--                     ||'    AND TOKENNO IN (SELECT TOKENNO FROM WPSWORKERMAST WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' AND LTRIM(RTRIM(DAYOFFDAY))=TRIM(LTRIM(TO_CHAR(TO_DATE('''||P_DATEOFATTENDANCE||''',''DD/MM/YYYY''),''DAY''))))'||CHR(10)
--                     ||'    AND NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0) > 0'||CHR(10);
--                insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE, lv_Remarks);
--                EXECUTE IMMEDIATE lv_SqlStr;
--                commit;
--            dBms_output.put_line ('9_0 CHECKING NORMAL ATTENDANCE IN FACTORY SIDE ON MONDAY - COMPLETE');    
        ELSE
             lv_SqlStr:='UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED=''Y'',  OTHOURS = (NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0)+NVL(OTHOURS,0)), SPELLHRS_1 = ''0'', SPELLHRS_2 = ''0'', REMARKS=''Normal Attn Transfer to OT for DayOff'''||CHR(10)
                        ||' WHERE ATTENDATE = '''||P_DATEOFATTENDANCE||'''  '||CHR(10)
                        ||'   AND TOKENNO IN (SELECT TOKENNO FROM WPSWORKERMAST '||CHR(10)
                        ||'                        WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                        ||'                          AND LTRIM(RTRIM(DAYOFFDAY)) =  TRIM(LTRIM(TO_CHAR(TO_DATE('''||P_DATEOFATTENDANCE||''',''DD/MM/YYYY''),''DAY'')))  ) '||CHR(10)
                        ||'   AND SHIFT <>''C'''||CHR(10)
                        ||'   AND DEPARTMENT IN (SELECT DEPARTMENTCODE FROM WPSDEPARTMENTMASTER WHERE DIVISIONCODE = '''||P_DIVCODE||''' AND DEPARTMENTTYPE <> ''G'') '||CHR(10)
                        ||'   AND NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0)> 0 '||CHR(10);
            insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE, lv_Remarks);
                EXECUTE IMMEDIATE lv_SqlStr;
                commit;
            ----FOR GENERAL SHIFT NORMAL DAY OFF COMSIDER -----------
             lv_SqlStr:='UPDATE WPSATTENDANCECSVRAWDATA SET VERIFIED=''Y'',  OTHOURS = (NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0)+NVL(OTHOURS,0)), SPELLHRS_1 = ''0'', SPELLHRS_2 = ''0'', REMARKS=''Normal Attn Transfer to OT for DayOff'''||CHR(10)
                        ||' WHERE ATTENDATE = '''||P_DATEOFATTENDANCE||'''  '||CHR(10)
                        ||'   AND TOKENNO IN (SELECT TOKENNO FROM WPSWORKERMAST '||CHR(10)
                        ||'                        WHERE COMPANYCODE = '''||P_COMPCODE||''' AND DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                        ||'                          AND LTRIM(RTRIM(DAYOFFDAY)) =  TRIM(LTRIM(TO_CHAR(TO_DATE('''||P_DATEOFATTENDANCE||''',''DD/MM/YYYY''),''DAY'')))  ) '||CHR(10)
                        ||'   AND DEPARTMENT IN (SELECT DEPARTMENTCODE FROM WPSDEPARTMENTMASTER WHERE DIVISIONCODE = '''||P_DIVCODE||''' AND DEPARTMENTTYPE = ''G'') '||CHR(10)
                        ||'   AND NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0)> 0 '||CHR(10);
            insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE, lv_Remarks);
                EXECUTE IMMEDIATE lv_SqlStr;
                commit;

--            dBms_output.put_line ('10_0 C - COMPLETE');    
        END IF;  
    end if;
        /* Updatng Attendance related Data */
    IF (P_VALIDORUPDATE='V' or P_VALIDORUPDATE='A') THEN
        lv_Remarks := 'DATA ALREADY EXISTS IN ATTENDANCE';
        FOR C1 IN (
                    SELECT A.TOKENNO, A.SHIFTCODE, A.SPELLTYPE 
                    FROM WPSATTENDANCEDAYWISE A, WPSATTENDANCECSVRAWDATA B
                    WHERE A.COMPANYCODE=P_COMPCODE AND A.DIVISIONCODE=P_DIVCODE
                      AND A.YEARCODE=lv_yearcode                            
                      AND A.DATEOFATTENDANCE=TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                      AND trim(A.TOKENNO) = B.TOKENNO AND A.SHIFTCODE=B.SHIFT
                      AND A.SPELLTYPE=B.SPELLTYPE
                      AND B.VERIFIED='Y'
                      AND TO_DATE(B.ATTENDATE,'DD/MM/YYYY')=TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                  )
                LOOP                                         
--                    UPDATE WPSATTENDANCECSVRAWDATA SET REMARKS='Data already exists in Attendance', VERIFIED='N'
--                    WHERE ATTENDATE = P_DATEOFATTENDANCE
--                      AND TOKENNO=C1.TOKENNO AND SHIFTCODE=C1.SHIFTCODE
--                      AND SPELLTYPE = C1.SPELLTYPE;
                    
                    lv_SqlStr := ' UPDATE WPSATTENDANCECSVRAWDATA SET REMARKS=''Data already exists in Attendance'', VERIFIED=''N'' '||chr(10)
                                ||' WHERE ATTENDATE = '''||P_DATEOFATTENDANCE||''' '||chr(10)
                                ||' AND trim(TOKENNO)='''||C1.TOKENNO||''' AND SHIFT ='''||C1.SHIFTCODE||''' '||chr(10)
                                ||' AND SPELLTYPE = '''||C1.SPELLTYPE||''' '||chr(10);                        
                    
--                    insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE||' - '||c1.TOKENNO, lv_Remarks);
                    execute immediate lv_SqlStr;
--                    dBms_output.put_line ('11_0 DATA ALREADY EXISTS - COMPLETE');                    
                END LOOP;              
                COMMIT;
                --dBms_output.put_line ('Checking Data Already exists in attendance - COMPLETE');
        /* cHECKING STL related Data */
        
        lv_Remarks := 'STL Data Checking';
        FOR C2 IN (
                    SELECT A.TOKENNO
                        FROM WPSSTLENTRY A, WPSATTENDANCECSVRAWDATA B, WPSWORKERMAST C
                        WHERE A.COMPANYCODE=P_COMPCODE AND A.DIVISIONCODE=P_DIVCODE
                            --AND A.YEARCODE=lv_yearcode                            
                            AND TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY') BETWEEN A.STLFROMDATE AND A.STLTODATE
                            AND A.COMPANYCODE = C.COMPANYCODE AND A.DIVISIONCODE = C.DIVISIONCODE AND A.WORKERSERIAL = C.WORKERSERIAL 
                            AND C.TOKENNO = B.TOKENNO 
                            AND B.VERIFIED='Y' 
                            AND B.ATTENDATE = P_DATEOFATTENDANCE
                            AND (NVL(B.SPELLHRS_1,0)+NVL(B.SPELLHRS_2,0)) > 0
                            --AND TO_DATE(B.ATTENDATE,'DD/MM/YYYY')=TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                  )
                LOOP                                         
                    UPDATE WPSATTENDANCECSVRAWDATA SET  OTHOURS = (NVL(SPELLHRS_1,0)+NVL(SPELLHRS_2,0)), REMARKS='Data already exists in STL, Normal Attendance not possible', VERIFIED='Y'
                    --WHERE TO_DATE(ATTENDATE,'DD/MM/YYYY')=TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                    WHERE ATTENDATE = P_DATEOFATTENDANCE
                      AND TOKENNO=C2.TOKENNO;
                    -- dbms_output.put_line ('Others Found ROWS UPDATED - '||sql%rowcount);                                                     
                END LOOP;              
                COMMIT;  
                --dbms_output.put_line ('cHECKING STL related Data - COMPLETE');  
        /* cHECKING OTHER LEAVE  */        
        lv_Remarks := 'Other Leave Checking';        
        FOR C2 IN (
                    SELECT A.TOKENNO
                        FROM WPSLEAVEAPPLICATION A, WPSATTENDANCECSVRAWDATA B, WPSWORKERMAST C
                        WHERE A.COMPANYCODE=P_COMPCODE AND A.DIVISIONCODE=P_DIVCODE
                            AND A.LEAVESANCTIONEDON IS NOT NULL
                            AND A.LEAVEDATE = TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                            AND A.COMPANYCODE = C.COMPANYCODE AND A.DIVISIONCODE = C.DIVISIONCODE AND A.WORKERSERIAL = C.WORKERSERIAL 
                            AND C.TOKENNO = B.TOKENNO 
                            AND B.VERIFIED='Y' 
                            AND B.ATTENDATE = P_DATEOFATTENDANCE
                            AND (NVL(B.SPELLHRS_1,0)+NVL(B.SPELLHRS_2,0)) > 0
                  )
                LOOP                                         
                    UPDATE WPSATTENDANCECSVRAWDATA SET REMARKS='Data already exists in Leave, Normal Attendance not possible', VERIFIED='N'
                    --WHERE TO_DATE(ATTENDATE,'DD/MM/YYYY')=TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY')
                    WHERE ATTENDATE = P_DATEOFATTENDANCE
                      AND TOKENNO=C2.TOKENNO;
                    -- dbms_output.put_line ('Others Found ROWS UPDATED - '||sql%rowcount);                                                     
                END LOOP;              
                COMMIT;    
        --dbms_output.put_line ('Checking Other Leave - COMPLETE');     
        --dbms_output.put_line('process successfully completer');
    END IF;
    
    if P_VALIDORUPDATE='A' then         --- data insert into attendance table for approved ------
        lv_Remarks := 'Data Insert';
        lv_BookNoPrefix := 'ATTN/'||REPLACE(TO_DATE(P_DATEOFATTENDANCE,'DD/MM/YYYY'),'/','');
        lv_SqlStr := 'INSERT INTO WPSATTENDANCEDAYWISE (COMPANYCODE, DIVISIONCODE, YEARCODE, FORTNIGHTSTARTDATE, FORTNIGHTENDDATE,  '||CHR(10)
                ||' DATEOFATTENDANCE, DEPARTMENTCODE, SHIFTCODE, WORKERSERIAL, TOKENNO, WORKERCATEGORYCODE, OCCUPATIONCODE, WORKERTYPECODE, SPELLTYPE, '||CHR(10)
                ||' SPELLHOURS, DEDUCTIONHOURS, ATTENDANCEHOURS, MACHINECODE1, OVERTIMEHOURS, NIGHTALLOWANCEHOURS, '||CHR(10)
                ||' UNITCODE, MODULE, BOOKNO, ATTENDANCETAG, LASTMODIFIED, USERNAME, SYSROWID,SERIALNO ) '||CHR(10)
                ||' SELECT B.COMPANYCODE, B.DIVISIONCODE,'''||lv_YearCode||'''  YEARCODE, TO_DATE('''||lv_FnStDt||''',''DD/MM/YYYY'') FORTNIGHTSTARTDATE, TO_DATE('''||lv_FnEndt||''',''DD/MM/YYYY'') FORTNIGHTENDDATE, '||CHR(10)
                ||' TO_DATE('''||P_DATEOFATTENDANCE||''',''DD/MM/YYYY'') DATEOFATTENDANCE, A.DEPARTMENT DEPARTMENTCODE, A.SHIFT,  '||CHR(10)
                ||' B.WORKERSERIAL, B.TOKENNO, B.WORKERCATEGORYCODE, A.OCCUPATION OCCUPATIONCODE, C.WORKERTYPECODE,  A.SPELLTYPE,  '||CHR(10)
                ||' NVL(LTRIM(TRIM( NVL(A.SPELLHRS_1,0)+NVL(A.SPELLHRS_2,0))),0) SPELLHOURS, 0 DEDUCTIONHOURS,  NVL(LTRIM(TRIM(NVL(A.SPELLHRS_1,0)+NVL(A.SPELLHRS_2,0))),0) ATTNHOURS, NULL, NVL(LTRIM(TRIM(A.OTHOURS)),0) OTHOURS, 0 NIGHTALLOWANCEHOURS,  '||CHR(10)
                ||' NULL, ''WPS'' MODULE, '''||lv_BookNoPrefix||'''||''/''||B.TOKENNO BOOKNO, ''MANUAL UPLOAD'' ATTENDANCETAG, SYSDATE, '''||P_USER||''', ''1'' SYSROWID,ROWNUM   '||CHR(10)
                ||' FROM  WPSATTENDANCECSVRAWDATA A, WPSWORKERMAST B, WPSOCCUPATIONMAST C '||CHR(10)
                ||' WHERE A.ATTENDATE = '''||P_DATEOFATTENDANCE||'''  '||CHR(10)
                ||'   AND NVL(A.VERIFIED,''N'') = ''Y'' '||CHR(10)
                ||'   AND B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                ||'   AND A.TOKENNO = B.TOKENNO  '||CHR(10)
                ||'   AND C.COMPANYCODE = '''||P_COMPCODE||''' AND C.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                ||'   AND A.DEPARTMENT = C.DEPARTMENTCODE AND A.OCCUPATION = C.OCCUPATIONCODE '||CHR(10);
         
            insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE, lv_Remarks);
            commit; 
           EXECUTE IMMEDIATE lv_SqlStr;
           commit;
            
            lv_Remarks := 'Data Approved';
        lv_SqlStr := 'UPDATE WPSATTENDANCECSVRAWDATA SET APPROVED=''Y'' WHERE VERIFIED=''Y'' AND TO_DATE('''||P_DATEOFATTENDANCE||''',''DD/MM/YYYY'')||TRIM(TOKENNO)||SHIFT||SPELLTYPE IN ( '||CHR(10)
                ||' SELECT '||CHR(10)
                ||'  TO_DATE('''||P_DATEOFATTENDANCE||''',''DD/MM/YYYY'') ||TRIM(B.TOKENNO)||A.SHIFT||SPELLTYPE'||CHR(10)
                ||' FROM  WPSATTENDANCECSVRAWDATA A, WPSWORKERMAST B, WPSOCCUPATIONMAST C '||CHR(10)
                ||' WHERE A.ATTENDATE = '''||P_DATEOFATTENDANCE||'''  '||CHR(10)
                ||'   AND NVL(A.VERIFIED,''N'') = ''Y'' '||CHR(10)
                ||'   AND B.COMPANYCODE = '''||P_COMPCODE||''' AND B.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                ||'   AND A.TOKENNO = B.TOKENNO  '||CHR(10)
                ||'   AND C.COMPANYCODE = '''||P_COMPCODE||''' AND C.DIVISIONCODE = '''||P_DIVCODE||''' '||CHR(10)
                ||'   AND A.DEPARTMENT = C.DEPARTMENTCODE AND A.OCCUPATION = C.OCCUPATIONCODE )'||CHR(10)
                ||'   AND ATTENDATE = '''||P_DATEOFATTENDANCE||'''  '||CHR(10);  
           
            insert into WPS_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES, REMARKS ) values( lv_PROCNAME,lv_sqlerrm,lv_SqlStr,P_DATEOFATTENDANCE, lv_Remarks);
            commit; 
            EXECUTE IMMEDIATE lv_SqlStr;
            commit;      
    end if;
    delete from WPSATTNCSVDATA_STAGE;
    COMMIT; 
EXCEPTION  
    WHEN OTHERS THEN
    -- Consider logging the error and then re-raise
    LV_SQLERRM := SQLERRM ;
    delete from WPSATTNCSVDATA_STAGE;
    INSERT INTO WPS_ERROR_LOG(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY,PAR_VALUES,FORTNIGHTSTARTDATE, FORTNIGHTENDDATE, REMARKS ) 
    VALUES( lv_PROCNAME,LV_SQLERRM, lv_SqlStr, P_DATEOFATTENDANCE,NULL,NULL, 'ERROR in ATTENDANCE DATA IMPORT');
    COMMIT;
    --RAISE;
END;
/


