DROP PROCEDURE NJMCL_WEB.PROC_RPT_ABSTRACTWPS;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.PROC_RPT_ABSTRACTWPS
(
  P_COMPCODE Varchar2, 
  P_DIVCODE Varchar2, 
  P_YEARCODE Varchar2, 
  P_FORTNIGHTSTARTDATE Varchar2,
  P_FORTNIGHTENDDATE  Varchar2,
  P_DEPARTMENTCODE Varchar2,
  P_WORKERCATEGORYCODE Varchar2 DEFAULT NULL
 )
as
/******************************************************************************
   NAME:      Prasun
   Date :     24.09.2019
   Implementing for Gloster Jute Mills 
******************************************************************************/
    LV_FORTNIGHTSTARTDATE      DATE := TO_DATE(P_FORTNIGHTSTARTDATE,'DD/MM/YYYY');
    LV_FORTNIGHTENDDATE      DATE := TO_DATE(P_FORTNIGHTENDDATE,'DD/MM/YYYY');
    LV_STRSQL           VARCHAR2(30000);
    LV_COL_HD  VARCHAR2(2000);
    LV_PIVOT  VARCHAR2(2000);
    LV_REPORTHEADER VARCHAR2(200) := 'WORKER`S FORTNIGHTLY PAY ABSTACT  FROM ' || P_FORTNIGHTSTARTDATE || ' TO ' || P_FORTNIGHTENDDATE;
    LV_COMPANYNAME  VARCHAR2(100);
    LV_DIVISIONNAME  VARCHAR2(100);
    LV_DEPARTMENTCODEALL VARCHAR2(1000);
    LV_DEPARTMENTCODE VARCHAR2(100);
begin
        SELECT COMPANYNAME INTO LV_COMPANYNAME FROM COMPANYMAST
        WHERE COMPANYCODE = P_COMPCODE;
        
        SELECT DIVISIONNAME INTO LV_DIVISIONNAME FROM DIVISIONMASTER
        WHERE DIVISIONCODE = P_DIVCODE;

        --SELECT REPLACE(P_DEPARTMENTCODE,'''','')  INTO  LV_DEPARTMENTCODE FROM DUAL;
        
        DELETE FROM GTT_ABSTRACTWPS; 
   

        IF P_DEPARTMENTCODE IS NULL THEN
        
            SELECT WM_CONCAT(DEPARTMENTCODE) INTO LV_DEPARTMENTCODEALL  FROM WPSDEPARTMENTMASTER
            WHERE COMPANYCODE = P_COMPCODE
            AND DIVISIONCODE = P_DIVCODE;
            
        ELSE
        
            LV_DEPARTMENTCODEALL :=  P_DEPARTMENTCODE; 
              
        END IF;
        
        --dbms_output.put_line('LV_DEPARTMENTCODEALL ' || LV_DEPARTMENTCODEALL);

        for I in 1..FN_WORD_CNT(REPLACE(LV_DEPARTMENTCODEALL,'''',''),NULL,',') 
        loop

                    SELECT FN_WORD_CNT(REPLACE(LV_DEPARTMENTCODEALL,'''',''),I,',') INTO LV_DEPARTMENTCODE FROM DUAL;
                   
                    
                     SELECT WM_CONCAT(' SUM(NVL(' || CNAME || ',0))' || CNAME) INTO LV_COL_HD FROM
                     (
                        SELECT CNAME 
                        From COL
                        WHERE TNAME = 'WPSWAGESDETAILS_MV'
                        AND SUBSTR(CNAME,-5) = 'HOURS'
                        ORDER BY COLNO
                     );
                     
                     SELECT WM_CONCAT(CNAME) INTO LV_PIVOT  FROM
                     (
                        SELECT CNAME 
                        From COL
                        WHERE TNAME = 'WPSWAGESDETAILS_MV'
                        AND SUBSTR(CNAME,-5) = 'HOURS'
                        ORDER BY COLNO
                     );
                     
                    --   dbms_output.put_line('LV_DEPARTMENTCODE ' || LV_DEPARTMENTCODE);
        --               dbms_output.put_line('LV_PIVOT ' || LV_PIVOT);
                     
          
                BEGIN
                    EXECUTE IMMEDIATE 'DROP TABLE TBL_COMPHOURS';
                EXCEPTION
                    WHEN OTHERS THEN NULL;     
                END;     
            

            
                 LV_STRSQL := '    CREATE TABLE TBL_COMPHOURS AS   '|| CHR(10)     
                            ||'    SELECT ROWNUM  SRL,  DEPARTMENTCODE, COMPNAME, COMPVALUE FROM '|| CHR(10)
                            ||' (  '|| CHR(10)
                            ||'    SELECT DEPARTMENTCODE, COMPNAME, COMPVALUE FROM  '|| CHR(10)
                            ||' (     '|| CHR(10)
                            ||'    SELECT * FROM ( '|| CHR(10)
                            ||'      SELECT  COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, ' || LV_COL_HD || CHR(10)
                            ||'     FROM WPSWAGESDETAILS_MV '|| CHR(10)
                            ||'     WHERE COMPANYCODE = '''||P_COMPCODE||'''   '|| CHR(10)
                            ||'     AND   DIVISIONCODE = '''||P_DIVCODE||'''   '|| CHR(10)
                            ||'     AND   YEARCODE  = '''||P_YEARCODE||'''   '|| CHR(10)
                            ||'     AND   FORTNIGHTSTARTDATE = '''||LV_FORTNIGHTSTARTDATE||'''   '|| CHR(10)
                            ||'     AND   FORTNIGHTENDDATE   = '''||LV_FORTNIGHTENDDATE||'''   '|| CHR(10)
                            ||'     AND   DEPARTMENTCODE = '''||LV_DEPARTMENTCODE||'''   '|| CHR(10);
                            IF P_WORKERCATEGORYCODE IS NOT NULL THEN
                                LV_STRSQL := LV_STRSQL ||'     AND   WORKERCATEGORYCODE IN ( '||P_WORKERCATEGORYCODE||')   '|| CHR(10);
                            END IF;
                            LV_STRSQL := LV_STRSQL ||'     GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE '|| CHR(10)
                            ||'     )  '|| CHR(10)
                            ||'     UNPIVOT (COMPVALUE FOR COMPNAME IN ('||LV_PIVOT||'))  '|| CHR(10)
                            ||' ) A ,COL B  '|| CHR(10)
                            ||'   WHERE B.TNAME = ''WPSWAGESDETAILS_MV''  '|| CHR(10)
                            ||'     AND A.COMPNAME = B.CNAME  '|| CHR(10)
                            ||'     AND SUBSTR(CNAME,-5) = ''HOURS'' '|| CHR(10)
                            ||' ORDER BY A.DEPARTMENTCODE, B.COLNO )'|| CHR(10);

                            -- DBMS_OUTPUT.PUT_LINE(LV_STRSQL);
                             EXECUTE IMMEDIATE LV_STRSQL;   


        /****************************HOURS PART******************************************/


        /****************************EARNING PART******************************************/         
                    
                     SELECT WM_CONCAT(' SUM(NVL(' || COMP_EARN || ',0))' || COMP_EARN) INTO LV_COL_HD FROM
                     (
                       SELECT COMPONENTSHORTNAME COMP_EARN
                       From WPSCOMPONENTMASTER
                       WHERE COMPANYCODE = P_COMPCODE
                         AND DIVISIONCODE = P_DIVCODE
                         AND COMPONENTTYPE = 'EARNING' 
                         AND COMPONENTSHORTNAME <> ('GROSS_FOR_HRA') 
                         AND COMPONENTTAG = 'N' 
                      ORDER BY CALCULATIONINDEX                  
                     );
                     
                     SELECT WM_CONCAT(COMP_EARN) INTO LV_PIVOT  FROM
                     (
                        SELECT COMPONENTSHORTNAME COMP_EARN
                       From WPSCOMPONENTMASTER
                       WHERE COMPANYCODE = P_COMPCODE
                         AND DIVISIONCODE = P_DIVCODE
                         AND COMPONENTTYPE = 'EARNING' 
                         AND COMPONENTSHORTNAME <> ('GROSS_FOR_HRA') 
                         AND COMPONENTTAG = 'N' 
                      ORDER BY CALCULATIONINDEX           
                     );
                     
        --               dbms_output.put_line('LV_COL_HD ' || LV_COL_HD);
        --               dbms_output.put_line('LV_PIVOT ' || LV_PIVOT);
                     

                BEGIN
                    EXECUTE IMMEDIATE 'DROP TABLE TBL_COMPEARNING';
                EXCEPTION
                    WHEN OTHERS THEN NULL;     
                END;     
            

            
                 LV_STRSQL := '    CREATE TABLE TBL_COMPEARNING AS   '|| CHR(10)   
                            ||'    SELECT ROWNUM  SRL,  DEPARTMENTCODE, COMPNAME, COMPVALUE FROM '|| CHR(10)
                            ||' (  '|| CHR(10)           
                            ||'    SELECT DEPARTMENTCODE, COMPNAME, COMPVALUE FROM  '|| CHR(10)
                            ||' (     '|| CHR(10)
                            ||'    SELECT * FROM ( '|| CHR(10)
                            ||'      SELECT  COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, ' || LV_COL_HD || CHR(10)
                            ||'     FROM WPSWAGESDETAILS_MV '|| CHR(10)
                            ||'     WHERE COMPANYCODE = '''||P_COMPCODE||'''   '|| CHR(10)
                            ||'     AND   DIVISIONCODE = '''||P_DIVCODE||'''   '|| CHR(10)
                            ||'     AND   YEARCODE  = '''||P_YEARCODE||'''   '|| CHR(10)
                            ||'     AND   FORTNIGHTSTARTDATE = '''||LV_FORTNIGHTSTARTDATE||'''   '|| CHR(10)
                            ||'     AND   FORTNIGHTENDDATE   = '''||LV_FORTNIGHTENDDATE||'''   '|| CHR(10)
                            ||'     AND   DEPARTMENTCODE =  '''||LV_DEPARTMENTCODE||'''   '|| CHR(10); 
                            IF P_WORKERCATEGORYCODE IS NOT NULL THEN
                                LV_STRSQL := LV_STRSQL ||'     AND   WORKERCATEGORYCODE IN ( '||P_WORKERCATEGORYCODE||')   '|| CHR(10);
                            END IF;
                            LV_STRSQL := LV_STRSQL ||'     GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE '|| CHR(10)
                            ||'     )  '|| CHR(10)
                            ||'     UNPIVOT (COMPVALUE FOR COMPNAME IN ('||LV_PIVOT||'))  '|| CHR(10)
                            ||' ) A ,WPSCOMPONENTMASTER B  '|| CHR(10)
                            ||'   WHERE A.COMPANYCODE = B.COMPANYCODE  '|| CHR(10)
                            ||'     AND A.DIVISIONCODE = B.DIVISIONCODE '|| CHR(10)
                            ||'     AND B.COMPONENTTYPE = ''EARNING''  '|| CHR(10)
                            ||'     AND A.COMPNAME = B.COMPONENTSHORTNAME  '|| CHR(10)
                            ||'     AND B.COMPONENTSHORTNAME <> (''GROSS_FOR_HRA'') '|| CHR(10)
                            ||'     AND B.COMPONENTTAG = ''N''   '|| CHR(10)
                            ||' ORDER BY A.DEPARTMENTCODE, B.CALCULATIONINDEX ) '|| CHR(10);

                            -- DBMS_OUTPUT.PUT_LINE(LV_STRSQL);
                             EXECUTE IMMEDIATE LV_STRSQL;   


        /****************************EARNING PART******************************************/


        /****************************DEDUCTION PART******************************************/         
                    
                     SELECT WM_CONCAT(' SUM(NVL(' || COMP_DEDN || ',0))' || COMP_DEDN) INTO LV_COL_HD FROM
                     (
                       SELECT COMPONENTSHORTNAME COMP_DEDN
                       From WPSCOMPONENTMASTER
                       WHERE COMPANYCODE = P_COMPCODE
                         AND DIVISIONCODE = P_DIVCODE
                         AND COMPONENTTYPE = 'DEDUCTION' 
                         AND NVL(COMPANYCONTIBUTION,'No') = 'No' 
                         AND COMPONENTTAG = 'N'
                       ORDER BY CALCULATIONINDEX   
                     );
                     
                     SELECT WM_CONCAT(COMP_DEDN) INTO LV_PIVOT  FROM
                     (
                         SELECT COMPONENTSHORTNAME COMP_DEDN
                           From WPSCOMPONENTMASTER
                           WHERE COMPANYCODE = P_COMPCODE
                             AND DIVISIONCODE = P_DIVCODE
                             AND COMPONENTTYPE = 'DEDUCTION' 
                             AND NVL(COMPANYCONTIBUTION,'No') = 'No' 
                             AND COMPONENTTAG = 'N'
                           ORDER BY CALCULATIONINDEX
                     );
                     
        --               dbms_output.put_line('LV_COL_HD ' || LV_COL_HD);
        --               dbms_output.put_line('LV_PIVOT ' || LV_PIVOT);
                     
                BEGIN
                    EXECUTE IMMEDIATE 'DROP TABLE TBL_COMPDEDUCTION';
                EXCEPTION
                    WHEN OTHERS THEN NULL;     
                END;     
            

            
                 LV_STRSQL := '    CREATE TABLE TBL_COMPDEDUCTION AS   '|| CHR(10)     
                            ||'    SELECT ROWNUM  SRL,  DEPARTMENTCODE, COMPNAME, COMPVALUE FROM '|| CHR(10)
                            ||' (  '|| CHR(10)              
                            ||'    SELECT DEPARTMENTCODE, COMPNAME, COMPVALUE FROM  '|| CHR(10)
                            ||' (     '|| CHR(10)
                            ||'    SELECT * FROM ( '|| CHR(10)
                            ||'      SELECT  COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE, ' || LV_COL_HD || CHR(10)
                            ||'     FROM WPSWAGESDETAILS_MV '|| CHR(10)
                            ||'     WHERE COMPANYCODE = '''||P_COMPCODE||'''   '|| CHR(10)
                            ||'     AND   DIVISIONCODE = '''||P_DIVCODE||'''   '|| CHR(10)
                            ||'     AND   YEARCODE  = '''||P_YEARCODE||'''   '|| CHR(10)
                            ||'     AND   FORTNIGHTSTARTDATE = '''||LV_FORTNIGHTSTARTDATE||'''   '|| CHR(10)
                            ||'     AND   FORTNIGHTENDDATE   = '''||LV_FORTNIGHTENDDATE||'''   '|| CHR(10)
                            ||'     AND   DEPARTMENTCODE =  '''||LV_DEPARTMENTCODE||'''   '|| CHR(10);
                            IF P_WORKERCATEGORYCODE IS NOT NULL THEN
                                LV_STRSQL := LV_STRSQL ||'     AND   WORKERCATEGORYCODE IN ( '||P_WORKERCATEGORYCODE||')   '|| CHR(10);
                            END IF;
                            LV_STRSQL := LV_STRSQL ||'     GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE '|| CHR(10)
                            ||'     )  '|| CHR(10)
                            ||'     UNPIVOT (COMPVALUE FOR COMPNAME IN ('||LV_PIVOT||'))  '|| CHR(10)
                            ||' ) A ,WPSCOMPONENTMASTER B  '|| CHR(10)
                            ||'   WHERE A.COMPANYCODE = B.COMPANYCODE  '|| CHR(10)
                            ||'     AND A.DIVISIONCODE = B.DIVISIONCODE '|| CHR(10)
                            ||'     AND B.COMPONENTTYPE = ''DEDUCTION''  '|| CHR(10)
                            ||'     AND A.COMPNAME = B.COMPONENTSHORTNAME  '|| CHR(10)
                            ||'     AND NVL(B.COMPANYCONTIBUTION,''No'') = ''No''  '|| CHR(10)
                            ||'     AND B.COMPONENTTAG = ''N''   '|| CHR(10)
                            ||' ORDER BY A.DEPARTMENTCODE, B.CALCULATIONINDEX ) '|| CHR(10);

                             --DBMS_OUTPUT.PUT_LINE(LV_STRSQL);
                             EXECUTE IMMEDIATE LV_STRSQL;   

    /****************************DEDUCTION PART******************************************/

    /****************************COMMON PART******************************************/



                BEGIN
                    EXECUTE IMMEDIATE 'DROP TABLE TBL_COMPCOMMON';
                EXCEPTION
                    WHEN OTHERS THEN NULL;     
                END; 


               LV_STRSQL := '    CREATE TABLE TBL_COMPCOMMON AS   '|| CHR(10)   
                          ||'  SELECT DEPARTMENTCODE, COUNT(WORKERSERIAL) NOOFSLIPS, SUM(COINBF) COINBF, SUM(COINCF) COINCF, SUM(PF_COM) PF_COM FROM WPSWAGESDETAILS_MV '|| CHR(10)
                          ||'  WHERE COMPANYCODE = '''||P_COMPCODE||'''   '|| CHR(10)
                          ||'     AND   DIVISIONCODE = '''||P_DIVCODE||'''   '|| CHR(10)
                          ||'     AND   YEARCODE  = '''||P_YEARCODE||'''   '|| CHR(10)
                          ||'     AND   FORTNIGHTSTARTDATE = '''||LV_FORTNIGHTSTARTDATE||'''   '|| CHR(10)
                          ||'     AND   FORTNIGHTENDDATE   = '''||LV_FORTNIGHTENDDATE||'''   '|| CHR(10)
                          ||'     AND   DEPARTMENTCODE =  '''||LV_DEPARTMENTCODE||'''   '|| CHR(10);
                          IF P_WORKERCATEGORYCODE IS NOT NULL THEN
                                LV_STRSQL := LV_STRSQL ||'     AND   WORKERCATEGORYCODE IN ( '||P_WORKERCATEGORYCODE||')   '|| CHR(10);
                            END IF;
                          LV_STRSQL := LV_STRSQL ||'     GROUP BY COMPANYCODE, DIVISIONCODE, DEPARTMENTCODE '|| CHR(10);
                          
                          EXECUTE IMMEDIATE LV_STRSQL;
    /****************************COMMON PART******************************************/

                 
                 
                 LV_STRSQL := ' INSERT INTO GTT_ABSTRACTWPS '|| CHR(10)  
                           ||'  (SRL, COMPANYNAME, DIVISIONNAME, REPORTHEADER, DEPARTMENTCODE, COMPNAME_HOUR, COMPVALUE_HOUR,  '|| CHR(10)
                           ||'         COMPNAME_EARN, COMPVALUE_EARN, COMPNAME_DEDN, COMPVALUE_DEDN)   '|| CHR(10)
                           ||'     SELECT NVL(TT1.SRL,TT2.SRL) SRL,  '''|| LV_COMPANYNAME ||''' COMPANYNAME, '''|| LV_DIVISIONNAME ||''' DIVISIONNAME, '''|| LV_REPORTHEADER ||''' REPORTHEADER, '|| CHR(10) 
                           ||'     NVL(TT1.DEPARTMENTCODE,TT2.DEPARTMENTCODE) DEPARTMENTCODE, TT1.COMPNAME_HOUR,  TT1.COMPVALUE_HOUR, '|| CHR(10)
                           ||'     TT1.COMPNAME_EARN, TT1.COMPVALUE_EARN,TT2.COMPNAME COMPNAME_DEDN, TT2.COMPVALUE COMPVALUE_DEDN FROM   '|| CHR(10)
                           ||'     ( '|| CHR(10) 
                           ||'     SELECT NVL(T1.SRL,T2.SRL) SRL, NVL(T1.DEPARTMENTCODE,T2.DEPARTMENTCODE) DEPARTMENTCODE, T1.COMPNAME COMPNAME_HOUR, T1.COMPVALUE COMPVALUE_HOUR, '|| CHR(10)
                           ||'         T2.COMPNAME COMPNAME_EARN, T2.COMPVALUE COMPVALUE_EARN '|| CHR(10)
                           ||'     FROM  TBL_COMPHOURS T1 FULL OUTER JOIN TBL_COMPEARNING T2 '|| CHR(10)
                           ||'     ON T1.SRL = T2.SRL '|| CHR(10)
                           ||'     AND   T1.DEPARTMENTCODE = T2.DEPARTMENTCODE '|| CHR(10)
                           ||'     ) TT1 FULL OUTER JOIN  TBL_COMPDEDUCTION TT2 '|| CHR(10)
                           ||'     ON TT1.SRL = TT2.SRL '|| CHR(10)
                           ||'     AND   TT1.DEPARTMENTCODE = TT2.DEPARTMENTCODE '|| CHR(10)           
                           ||'     ORDER BY SRL   '|| CHR(10);  
                           
                       -- DBMS_OUTPUT.PUT_LINE(LV_STRSQL);
                         EXECUTE IMMEDIATE LV_STRSQL;   
                         
                         
                 LV_STRSQL := ' UPDATE GTT_ABSTRACTWPS '|| CHR(10)
                            ||' SET (NOOFSLIPS,COINBF,COINCF,PF_COM) = (SELECT NOOFSLIPS, COINBF, COINCF, PF_COM  FROM TBL_COMPCOMMON) '|| CHR(10)
                            ||' WHERE DEPARTMENTCODE = '''||LV_DEPARTMENTCODE||'''   '|| CHR(10);
                            
                EXECUTE IMMEDIATE LV_STRSQL;   
   /****************************COMMON PART******************************************/         
        end loop;
    
   /****************************All Division******************************************/
        LV_STRSQL := ' INSERT INTO GTT_ABSTRACTWPS '|| CHR(10)  
                   ||'  (SRL, COMPANYNAME, DIVISIONNAME, REPORTHEADER, DEPARTMENTCODE, COMPNAME_HOUR, COMPVALUE_HOUR,  '|| CHR(10)
                   ||'         COMPNAME_EARN, COMPVALUE_EARN, COMPNAME_DEDN, COMPVALUE_DEDN, NOOFSLIPS,COINBF,COINCF,PF_COM)   '|| CHR(10)
                   ||' SELECT SRL, COMPANYNAME, DIVISIONNAME, REPORTHEADER, ''ALL'' DEPARTMENTCODE, COMPNAME_HOUR, SUM(NVL(COMPVALUE_HOUR,0)) COMPVALUE_HOUR, '|| CHR(10)  
                   ||' COMPNAME_EARN,  SUM(NVL(COMPVALUE_EARN,0)) COMPVALUE_EARN, COMPNAME_DEDN, SUM(NVL(COMPVALUE_DEDN,0))  COMPVALUE_DEDN, '|| CHR(10)  
                   ||' SUM(NVL(NOOFSLIPS,0)) NOOFSLIPS, SUM(NVL(COINBF,0)) COINBF, SUM(NVL(COINCF,0)) COINCF, SUM(NVL(PF_COM,0)) PF_COM '|| CHR(10)  
                   ||' FROM GTT_ABSTRACTWPS   '|| CHR(10)  
                   ||' GROUP BY SRL, COMPANYNAME, DIVISIONNAME, REPORTHEADER, COMPNAME_HOUR, COMPNAME_EARN, COMPNAME_DEDN  '|| CHR(10)  
                   ||' ORDER BY SRL  '|| CHR(10);  
       -- DBMS_OUTPUT.PUT_LINE(LV_STRSQL);
         EXECUTE IMMEDIATE LV_STRSQL;   
/****************************All Division******************************************/

end;
/


