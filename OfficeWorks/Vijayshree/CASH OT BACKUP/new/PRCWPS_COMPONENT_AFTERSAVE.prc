CREATE OR REPLACE PROCEDURE FORTWILLIAM_WPS.PRCWPS_COMPONENT_AFTERSAVE
AS
LV_CNT                  NUMBER;
LV_SERIALNO               NUMBER;
LV_RESULT               VARCHAR2(10);
LV_ERROR_REMARK         VARCHAR2(4000) := '' ;
LV_MASTER               GBL_WPSCOMPONENTMASTER%ROWTYPE;
LV_TRANSACTIONNO        VARCHAR2(50);
LV_SQLSTR               VARCHAR2(4000) := '' ;        
      

BEGIN

    LV_RESULT:='#SUCCESS#';

        SELECT *
        INTO LV_MASTER
        FROM GBL_WPSCOMPONENTMASTER;
        --WHERE ROWNUM<=1;

        SELECT COUNT(*)
        INTO LV_CNT
        FROM GBL_WPSCOMPONENTMASTER;
        
         IF NVL(LV_CNT,0)=0 THEN
            LV_ERROR_REMARK := 'Validation Failure : [Blank data not allowded to save!]';
            RAISE_APPLICATION_ERROR(TO_NUMBER(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,LV_ERROR_REMARK));
        END IF;
  
        IF LV_MASTER.OPERATIONMODE IS NULL THEN
            LV_ERROR_REMARK := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT ? ]';
            RAISE_APPLICATION_ERROR(TO_NUMBER(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,LV_ERROR_REMARK));
        END IF;            
       
        IF (NVL(LV_MASTER.OPERATIONMODE,'NA') = 'A' OR NVL(LV_MASTER.OPERATIONMODE,'NA') = 'M') AND NVL(LV_MASTER.TAKEPARTINWAGES,'NA')= 'Y' THEN
              
           SELECT COUNT(*)
           INTO LV_CNT
           FROM COL
           WHERE TNAME ='WPSWAGESDETAILS'
             AND (CNAME=LV_MASTER.COMPONENTNAME OR CNAME=LV_MASTER.COMPONENTSHORTNAME); 
                     
           IF NVL(LV_CNT,0)=0 THEN
                IF UPPER(nvl(LV_MASTER.COMPONENTGROUP,'XX'))='LOAN' THEN    
                    LV_SQLSTR:= 'ALTER TABLE WPSWAGESDETAILS ADD ( ';
                    LV_SQLSTR:= LV_SQLSTR ||'LOAN_'|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2), ';
                    LV_SQLSTR:= LV_SQLSTR ||'LINT_'|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2), ';
                    LV_SQLSTR:= LV_SQLSTR ||'LNBL_'|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2), ';
                    LV_SQLSTR:= LV_SQLSTR ||'LIBL_'|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2) )';
                ELSE        
                    LV_SQLSTR:= 'ALTER TABLE WPSWAGESDETAILS ADD '|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2)';
               END IF;
                EXECUTE IMMEDIATE LV_SQLSTR;  
           END IF;
                   
           SELECT COUNT(*)
           INTO LV_CNT
           FROM COL
           WHERE TNAME ='WPSWAGESDETAILS_MV'
             AND (CNAME=LV_MASTER.COMPONENTNAME OR CNAME=LV_MASTER.COMPONENTSHORTNAME); 
                     
           IF NVL(LV_CNT,0)=0 THEN
                IF UPPER(nvl(LV_MASTER.COMPONENTGROUP,'XX'))='LOAN' THEN    
                    LV_SQLSTR:= 'ALTER TABLE WPSWAGESDETAILS_MV ADD ( ';
                    LV_SQLSTR:= LV_SQLSTR ||'LOAN_'|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2), ';
                    LV_SQLSTR:= LV_SQLSTR ||'LINT_'|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2), ';
                    LV_SQLSTR:= LV_SQLSTR ||'LNBL_'|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2), ';
                    LV_SQLSTR:= LV_SQLSTR ||'LIBL_'|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2) )';
                ELSE        
                    LV_SQLSTR:= 'ALTER TABLE WPSWAGESDETAILS_MV ADD '|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2)';
               END IF;
                EXECUTE IMMEDIATE LV_SQLSTR;  
           END IF;
           
          
           SELECT COUNT(*) 
           INTO LV_CNT
           FROM COL
           WHERE TNAME ='WPSATTENDANCEDAYWISE'
             AND (CNAME=LV_MASTER.COMPONENTNAME OR CNAME=LV_MASTER.COMPONENTSHORTNAME);

            IF NVL(LV_CNT,0)=0 THEN
                LV_SQLSTR:= 'ALTER TABLE WPSATTENDANCEDAYWISE ADD '|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2)';
                EXECUTE IMMEDIATE LV_SQLSTR;
            END IF;
            
            
        ----ADDED ON 08/02/2021
        
           SELECT COUNT(*) 
           INTO LV_CNT
           FROM COL
           WHERE TNAME ='WPSDAILYWAGESDETAILS';

            IF NVL(LV_CNT,0)>0 THEN
               SELECT COUNT(*) 
               INTO LV_CNT
               FROM COL
               WHERE TNAME ='WPSDAILYWAGESDETAILS'
                 AND (CNAME=LV_MASTER.COMPONENTNAME OR CNAME=LV_MASTER.COMPONENTSHORTNAME);

                IF NVL(LV_CNT,0)=0 THEN
                    LV_SQLSTR:= 'ALTER TABLE WPSDAILYWAGESDETAILS ADD '|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2)';
                    EXECUTE IMMEDIATE LV_SQLSTR;
                END IF;
            
            END IF;
            
           SELECT COUNT(*) 
           INTO LV_CNT
           FROM COL
           WHERE TNAME ='WPSDAILYWAGESDETAILS_MV';

            IF NVL(LV_CNT,0)>0 THEN
               SELECT COUNT(*) 
               INTO LV_CNT
               FROM COL
               WHERE TNAME ='WPSDAILYWAGESDETAILS_MV'
                 AND (CNAME=LV_MASTER.COMPONENTNAME OR CNAME=LV_MASTER.COMPONENTSHORTNAME);

                IF NVL(LV_CNT,0)=0 THEN
                    LV_SQLSTR:= 'ALTER TABLE WPSDAILYWAGESDETAILS_MV ADD '|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2)';
                    EXECUTE IMMEDIATE LV_SQLSTR;
                END IF;
            
            END IF;
            
            
           SELECT COUNT(*) 
           INTO LV_CNT
           FROM COL
           WHERE TNAME ='WPSWAGESDETAILS_SWT';

            IF NVL(LV_CNT,0)>0 THEN
               SELECT COUNT(*) 
               INTO LV_CNT
               FROM COL
               WHERE TNAME ='WPSWAGESDETAILS_SWT'
                 AND (CNAME=LV_MASTER.COMPONENTNAME OR CNAME=LV_MASTER.COMPONENTSHORTNAME);

                IF NVL(LV_CNT,0)=0 THEN
                    LV_SQLSTR:= 'ALTER TABLE WPSWAGESDETAILS_SWT ADD '|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2)';
                    EXECUTE IMMEDIATE LV_SQLSTR;
                END IF;
            
            END IF;

            
           SELECT COUNT(*) 
           INTO LV_CNT
           FROM COL
           WHERE TNAME ='WPSWAGESDETAILS_MV_SWT';


            IF NVL(LV_CNT,0)>0 THEN
               SELECT COUNT(*) 
               INTO LV_CNT
               FROM COL
               WHERE TNAME ='WPSWAGESDETAILS_MV_SWT'
                 AND (CNAME=LV_MASTER.COMPONENTNAME OR CNAME=LV_MASTER.COMPONENTSHORTNAME);

                IF NVL(LV_CNT,0)=0 THEN
                    LV_SQLSTR:= 'ALTER TABLE WPSWAGESDETAILS_MV_SWT ADD '|| LV_MASTER.COMPONENTSHORTNAME || ' NUMBER(18,2)';
                    EXECUTE IMMEDIATE LV_SQLSTR;
                END IF;
            
            END IF;

        ----ENDED ON 08/02/2021
        
        
        /*  
           SELECT COUNT(*) 
           INTO LV_CNT
           FROM DYNAMICGRIDDATA
           WHERE (COLUMN_NAME =LV_MASTER.COMPONENTNAME OR COLUMN_NAME=LV_MASTER.COMPONENTSHORTNAME)
             AND MODULE='WPS';
           
           IF NVL(LV_CNT,0)=0 THEN
                SELECT MAX(SERIALNO)+1
                  INTO LV_SERIALNO                 
                  FROM DYNAMICGRIDDATA
                 WHERE MODULE='WPS';
                   
                INSERT INTO DYNAMICGRIDDATA (COMPANYCODE, DIVISIONCODE,MODULE, MENUTAG, 
                                             SERIALNO,COLUMN_NAME, COLUMN_LENGTH, COLUMN_HEADER, 
                                             COLUMN_TYPE, COLUMN_READONLY, 
                                             SYSROWID,USERNAME)
                       VALUES  (LV_MASTER.COMPANYCODE,LV_MASTER.DIVISIONCODE,'WPS','ADJUSTMENT HOURS',
                                LV_SERIALNO,LV_MASTER.COMPONENTSHORTNAME,100,LV_MASTER.COMPONENTSHORTNAME,
                                'text' ,'false',LV_MASTER.SYSROWID,LV_MASTER.USERNAME);      
           END IF;
        */ 
           PROC_WPSVIEWCREATION(LV_MASTER.COMPANYCODE,LV_MASTER.DIVISIONCODE,'ALL',1,'16/03/2016','31/03/2016'); 
        END IF;

EXCEPTION WHEN OTHERS THEN
   LV_ERROR_REMARK:= LV_ERROR_REMARK || '#UNSUCC#ESSFULL# NOT ABLE TO CREATE COLUMN';
   RAISE_APPLICATION_ERROR(TO_NUMBER(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,LV_ERROR_REMARK));
END;
/
