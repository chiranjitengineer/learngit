DROP TRIGGER TRG_INSUPD_WPSWORKERMAST;

CREATE OR REPLACE TRIGGER TRG_INSUPD_WPSWORKERMAST 
   AFTER INSERT OR UPDATE
   ON WPSWORKERMAST    FOR EACH ROW
DECLARE
   lv_cnt              NUMBER;
   lv_pfjoindate       DATE;
   lv_SettlementDate   DATE;
BEGIN
   IF :new.PFNO IS NOT NULL
   THEN
      SELECT   COUNT ( * )
        INTO   lv_cnt
        FROM   PFEMPLOYEEMASTER
       WHERE   pfno = :new.PFNO;

      IF INSERTING
      THEN
         IF lv_cnt = 0
         THEN
            --insert into error_log(error_query) values(:new.EMPLOYEEFPFACCNUMBER||' - '||to_char(:new.EMPPFENTITLEDATE,'DD/MM/YYYY')||' - AYAN') ;
            INSERT INTO PFEMPLOYEEMASTER (
                                             MODULE,
                                             PFNO,
                                             PFJOINDATE,
                                             currentcompanycode,
                                             currentDIVISIONCODE,
                                             WORKERSERIAL,
                                             TOKENNO,
                                             EMPLOYEENAME,
                                             FATHERNAME,
                                             GUARDIANNAME,
                                             DEPARTMENTCODE,
                                             CATEGORYCODE,
                                             GRADECODE,
                                             DATEOFBIRTH,
                                             DATEOFJOINING,
                                             PENSIONNO,
                                             EMPLOYEEMARRIED,
                                             SEX,
                                             SPOUSENAME,
                                             EMPLOYEESTATUS,
                                             STATUSDATE,
                                             FORM3RECEIPTDATE,
                                             FORM3CEASEDATE,
                                             SEPARATIONADVICEDATE,
                                             PFSETTLEMENTDATE,
                                             SEPARATIONDATE,
                                             ADDRESS,
                                             PFCATEGORY,
                                             DESIGNATIONCODE,
                                             COMPANYCODE,
                                             DIVISIONCODE,
                                             PFTRUSTCODE,
                                             BASICRATEONHOURS,
                                             LASTMODIFIED,
                                             ENTERBY, 
                                             UANNO,
                                             AADHAARNO,
                                             IFSCCODE,
                                             BANKACCNO,
                                             EMPLOYEENAME_BANK,
                                             ESINO
                       )
              VALUES   (
                           'WPS',
                           :new.PFNO,
                           :new.PFMEMBERSHIPDATE,
                           :new.COMPANYCODE,
                           :new.DIVISIONCODE,
                           :new.WORKERSERIAL,
                           :new.TOKENNO,
                           :new.WORKERNAME,
                           :new.FATHERNAME,
                           :new.FATHERNAME,
                           :new.DEPARTMENTCODE,
                           :new.WORKERCATEGORYCODE,
                           :new.GRADECODE,
                           :new.DATEOFBIRTH,
                           :new.DATEOFJOINING,
                           :new.PENSIONNO,
                           :new.MARITALSTATUS,
                           :new.SEX,
                           :new.WORKERSOUSENAME,
                           :new.WORKERSTATUS,
                           :new.DATEOFTERMINATION,
                           :new.DATEOFTERMINATIONADVICE,
                           :new.DATEOFTERMINATIONADVICE,
                           :new.DATEOFTERMINATIONADVICE,
                           :new.PFSETTELMENTDATE,
                           :new.PFSETTELMENTDATE,
                              :new.ADDRESS1
                           || ' '
                           || :new.ADDRESS2
                           || ' '
                           || :new.ADDRESS3
                           || ' '
                           || :new.ADDRESS4,
--                           :new.PFCATEGORY,
                           CASE WHEN :new.PFAPPLICABLE='Y' AND :new.EPFAPPLICABLE='Y' THEN 2 WHEN :new.PFAPPLICABLE='Y' AND :new.EPFAPPLICABLE='N' THEN 1 WHEN :new.PFAPPLICABLE='N' AND :new.EPFAPPLICABLE='N' THEN 3 END,  
                           :new.OCCUPATIONCODE,
                           'NJ0002',
                           '0010',
                           'T001',
                           1,
                           SYSDATE,
                           USER,
                           :new.UANNO,
                           :new.ADHARCARDNO,
                           :NEW.BANKCODE,
                           :NEW.BANKACNO, 
                           :NEW.WORKERNAME_BANK,
                           :NEW.ESINO
                       );
         ELSE
            SELECT   PFJOINDATE
              INTO   lv_pfjoindate
              FROM   PFEMPLOYEEMASTER
             WHERE   pfno = :new.PFNO;

            IF lv_pfjoindate <> :new.PFMEMBERSHIPDATE
            THEN
               raise_application_error (
                  -20101,
                  'PF JOINING DATE IS DIFFERENT FROM THE ORIGINAL PFJOINDATE IN PFMASTER ..'
               );
            ELSE
               UPDATE   PFEMPLOYEEMASTER
                  SET   MODULE = 'WPS',
                        currentcompanycode = :new.COMPANYCODE,
                        currentDIVISIONCODE = :new.DIVISIONCODE,
                        WORKERSERIAL = :new.WORKERSERIAL,
                        TOKENNO = :new.TOKENNO,
                        EMPLOYEENAME = :new.WORKERNAME,
                        FATHERNAME = :new.FATHERNAME,
                        GUARDIANNAME = :new.FATHERNAME,
                        DEPARTMENTCODE = :new.DEPARTMENTCODE,
                        CATEGORYCODE = :new.WORKERCATEGORYCODE,
                        GRADECODE = :new.GRADECODE,
                        DATEOFBIRTH = :new.DATEOFBIRTH,
                        DATEOFJOINING = :new.DATEOFJOINING,
                        --  PFJOINDATE = :new.PFMEMBERSHIPDATE ,
                        --  PFNO = :new.PFNO  ,
                        PENSIONNO = :new.PENSIONNO,
                        EMPLOYEEMARRIED = :new.MARITALSTATUS,
                        SEX = :new.SEX,
                        SPOUSENAME = :new.WORKERSOUSENAME,
                        -- EMPLOYEESTATUS = :new.WORKERSTATUS ,
                        --  STATUSDATE = :new.DATEOFTERMINATION ,
                          FORM3RECEIPTDATE = :new.DATEOFTERMINATION ,
                          SEPARATIONADVICEDATE =  :new.DATEOFTERMINATION ,
                          FORM3CEASEDATE =  :new.DATEOFTERMINATIONADVICE ,
                          --PFSETTLEMENTDATE = :new.DATEOFTERMINATIONADVICE,
                          STATUSDATE = :new.DATEOFTERMINATIONADVICE,
                          SEPARATIONDATE  = :new.DATEOFTERMINATIONADVICE,
--                        ADDRESS =
--                              :new.ADDRESS1
--                           || ' '
--                           || :new.ADDRESS2
--                           || ' '
--                           || :new.ADDRESS3
--                           || ' '
--                           || :new.ADDRESS4,
                         ADDRESS =
                        :new.ADDRESS1 ||''||
                        :new.ADDRESS2 ||''||                    
                        :new.ADDRESS3 ||''||                   
                        :new.ADDRESS4,
                        --  PFCATEGORY = :new.PFCATEGORY ,
                        PFCATEGORY =CASE WHEN :new.PFAPPLICABLE='Y' AND :new.EPFAPPLICABLE='Y' THEN 2 WHEN :new.PFAPPLICABLE='Y' AND :new.EPFAPPLICABLE='N' THEN 1 WHEN :new.PFAPPLICABLE='N' AND :new.EPFAPPLICABLE='N' THEN 3 END,
                        DESIGNATIONCODE = :new.OCCUPATIONCODE,
                        UANNO= :new.UANNO,
                        AADHAARNO= :new.ADHARCARDNO,
                        BANKACCNO = :NEW.BANKACNO, 
                        IFSCCODE =  :NEW.BANKCODE,
                        EMPLOYEENAME_BANK =:NEW.WORKERNAME_BANK,
                        ESINO =:NEW.ESINO
                        
                WHERE   pfno = :new.PFNO;
            END IF;
         END IF;
      ELSE
      
      
          if lv_cnt = 0 then
                
              INSERT INTO PFEMPLOYEEMASTER (
                                             MODULE,
                                             PFNO,
                                             PFJOINDATE,
                                             currentcompanycode,
                                             currentDIVISIONCODE,
                                             WORKERSERIAL,
                                             TOKENNO,
                                             EMPLOYEENAME,
                                             FATHERNAME,
                                             GUARDIANNAME,
                                             DEPARTMENTCODE,
                                             CATEGORYCODE,
                                             GRADECODE,
                                             DATEOFBIRTH,
                                             DATEOFJOINING,
                                             PENSIONNO,
                                             EMPLOYEEMARRIED,
                                             SEX,
                                             SPOUSENAME,
                                             EMPLOYEESTATUS,
                                             STATUSDATE,
                                             FORM3RECEIPTDATE,
                                             FORM3CEASEDATE,
                                             SEPARATIONADVICEDATE,
                                             PFSETTLEMENTDATE,
                                             SEPARATIONDATE,
                                             ADDRESS,
                                             PFCATEGORY,
                                             DESIGNATIONCODE,
                                             COMPANYCODE,
                                             DIVISIONCODE,
                                             PFTRUSTCODE,
                                             BASICRATEONHOURS,
                                             LASTMODIFIED,
                                             ENTERBY, 
                                             UANNO,
                                             AADHAARNO,
                                             IFSCCODE,
                                             BANKACCNO,
                                             EMPLOYEENAME_BANK,
                                             ESINO
                       )
              VALUES   (
                           'WPS',
                           :new.PFNO,
                           :new.PFMEMBERSHIPDATE,
                           :new.COMPANYCODE,
                           :new.DIVISIONCODE,
                           :new.WORKERSERIAL,
                           :new.TOKENNO,
                           :new.WORKERNAME,
                           :new.FATHERNAME,
                           :new.FATHERNAME,
                           :new.DEPARTMENTCODE,
                           :new.WORKERCATEGORYCODE,
                           :new.GRADECODE,
                           :new.DATEOFBIRTH,
                           :new.DATEOFJOINING,
                           :new.PENSIONNO,
                           :new.MARITALSTATUS,
                           :new.SEX,
                           :new.WORKERSOUSENAME,
                           :new.WORKERSTATUS,
                           :new.DATEOFTERMINATION,
                           :new.DATEOFTERMINATIONADVICE,
                           :new.DATEOFTERMINATIONADVICE,
                           :new.DATEOFTERMINATIONADVICE,
                           :new.PFSETTELMENTDATE,
                           :new.PFSETTELMENTDATE,
                              :new.ADDRESS1
                           || ' '
                           || :new.ADDRESS2
                           || ' '
                           || :new.ADDRESS3
                           || ' '
                           || :new.ADDRESS4,
--                           :new.PFCATEGORY,
                           CASE WHEN :new.PFAPPLICABLE='Y' AND :new.EPFAPPLICABLE='Y' THEN 2 WHEN :new.PFAPPLICABLE='Y' AND :new.EPFAPPLICABLE='N' THEN 1 WHEN :new.PFAPPLICABLE='N' AND :new.EPFAPPLICABLE='N' THEN 3 END,
                           :new.OCCUPATIONCODE,
                           'NJ0002',
                           '0010',
                           'T001',
                           1,
                           SYSDATE,
                           USER,
                           :new.UANNO,
                           :new.ADHARCARDNO,
                           :NEW.BANKCODE,
                           :NEW.BANKACNO, 
                           :NEW.WORKERNAME_BANK,
                           :NEW.ESINO
                       );  
          
          
          else
                --SELECT PFSETTLEMENTDATE INTO lv_SettlementDate FROM PFEMPLOYEEMASTER WHERE PFNO = :OLD.PFNO;
             ---IF  lv_SettlementDate IS NOT NULL THEN
             --  raise_application_error(-20101, 'EMPLOYEE ALREADY SETTLED IN PF ACCOUNTING SYSTEM ON DATED '||lv_SettlementDate);
             -- ELSE
            UPDATE   PFEMPLOYEEMASTER
            SET   MODULE = 'WPS',
                  currentcompanycode = :new.COMPANYCODE,
                  currentDIVISIONCODE = :new.DIVISIONCODE,
                  WORKERSERIAL = :new.WORKERSERIAL,
                  --EMPLOYEEID = :new.WORKERCODE,
                  TOKENNO = :new.TOKENNO,
                  EMPLOYEENAME = :new.WORKERNAME,
                  FATHERNAME = :new.FATHERNAME,
                  GUARDIANNAME = :new.FATHERNAME,
                  DEPARTMENTCODE = :new.DEPARTMENTCODE,
                  CATEGORYCODE = :new.WORKERCATEGORYCODE,
                  GRADECODE = :new.GRADECODE,
                  DATEOFBIRTH = :new.DATEOFBIRTH,
                  DATEOFJOINING = :new.DATEOFJOINING,
                  PFJOINDATE = :new.PFMEMBERSHIPDATE,
                  --   PFNO = :new.PFNO  ,
                  PENSIONNO = :new.PENSIONNO,
                  EMPLOYEEMARRIED = :new.MARITALSTATUS,
                  SEX = :new.SEX,
                  SPOUSENAME = :new.WORKERSOUSENAME,
                  --EMPLOYEESTATUS = :new.WORKERSTATUS ,
                  --STATUSDATE = :new.DATEOFTERMINATION ,
                  --FORM3RECEIPTDATE = :new.DATEOFTERMINATIONADVICE ,
                  --FORM3CEASEDATE =  :new.DATEOFTERMINATIONADVICE ,
                  --SEPARATIONADVICEDATE =  :new.DATEOFTERMINATIONADVICE ,
                  --PFSETTLEMENTDATE = :new.PFSETTELMENTDATE,
                  --SEPARATIONDATE  = :new.PFSETTELMENTDATE,
                    FORM3RECEIPTDATE = :new.DATEOFTERMINATION ,
                    SEPARATIONADVICEDATE =  :new.DATEOFTERMINATION ,
                    FORM3CEASEDATE =  :new.DATEOFTERMINATIONADVICE ,
                    STATUSDATE = :new.DATEOFTERMINATIONADVICE,
                    SEPARATIONDATE  = :new.DATEOFTERMINATIONADVICE,
--                  ADDRESS =
--                        :new.ADDRESS1
--                     || ' '
--                     || :new.ADDRESS2
--                     || ' '
--                     || :new.ADDRESS3
--                     || ' '
--                     || :new.ADDRESS4,
                    ADDRESS =
                        :new.ADDRESS1 ||''||
                        :new.ADDRESS2 ||''||                    
                        :new.ADDRESS3 ||''||                   
                        :new.ADDRESS4,
                  --PFCATEGORY = :new.PFCATEGORY ,
                  PFCATEGORY =CASE WHEN :new.PFAPPLICABLE='Y' AND :new.EPFAPPLICABLE='Y' THEN 2 WHEN :new.PFAPPLICABLE='Y' AND :new.EPFAPPLICABLE='N' THEN 1 WHEN :new.PFAPPLICABLE='N' AND :new.EPFAPPLICABLE='N' THEN 3 END,
                  DESIGNATIONCODE = :new.OCCUPATIONCODE,
                  UANNO= :new.UANNO,
                  AADHAARNO= :new.ADHARCARDNO,
                  BANKACCNO = :NEW.BANKACNO, 
                  IFSCCODE =  :NEW.BANKCODE,
                  EMPLOYEENAME_BANK =:NEW.WORKERNAME_BANK,
                  ESINO =:NEW.ESINO
          WHERE   pfno = :new.PFNO;
          end if;
                                                        -- update
         
      --END IF;
      END IF;
   END IF;                                                   -- not NULL CHECK
END;
/


