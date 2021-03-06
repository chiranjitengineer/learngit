CREATE OR REPLACE PROCEDURE PROC_GPSLVAPPLICATION_UPDATE
as
lv_date  date;
lv_date_from date ;
lv_date_to   date ;
lv_LEAVESANCTIONEDON date;
lv_SqlErr  varchar2(4000);
lv_StrSql varchar2(4000);
begin
for c1 in ( select A.COMPANYCODE, B.DIVISIONCODE, A.YEARCODE, A.CLUSTERCODE, A.CATEGORYCODE, A.ATTNBOOKCODE, A.LEAVECODE, A.TOKENNO, A.WORKERSERIAL, A.BALANCENO, A.DAYOFFDAYS, A.FROMDATE, A.TODATE,B.GRADECODE , A.USERNAME , A.MODETYPE,A.OPERATIONMODE from GBL_GPSLVAPPLICATION  A, GPSEMPLOYEEMAST B WHERE A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE AND A.WORKERSERIAL = B.WORKERSERIAL ) loop
  delete GPSLEAVEAPPLICATION 
  where 1=1
  AND  COMPANYCODE = c1.COMPANYCODE 
  AND  DIVISIONCODE = c1.DIVISIONCODE 
  AND  WORKERSERIAL = c1.WORKERSERIAL
  AND LEAVEAPPLIEDON = c1.FROMDATE
  AND LEAVEDATE between LEAVEAPPLIEDON and c1.todate 
  AND MODETYPE='BULK';
  delete GBL_GPSLEAVEAPPLICATION_CLONE 
  where 1=1
  AND  COMPANYCODE = c1.COMPANYCODE 
  AND  DIVISIONCODE = c1.DIVISIONCODE 
  AND  WORKERSERIAL = c1.WORKERSERIAL
  AND LEAVEAPPLIEDON = c1.FROMDATE
  AND LEAVEDATE between LEAVEAPPLIEDON and c1.todate ;
 -- AND OPERATIONMODE IS NULL;    
  lv_date := c1.FROMDATE ;  
  while lv_date <=  c1.TODATE loop
   if ltrim(trim(to_char(lv_date,'DAY'))) = ltrim(trim(upper(c1.DAYOFFDAYS))) then
    lv_LEAVESANCTIONEDON := nULL;    
   else
    lv_LEAVESANCTIONEDON := c1.FROMDATE ; 
   end if;
   insert into GPSLEAVEAPPLICATION(COMPANYCODE, DIVISIONCODE, YEARCODE, CATEGORYCODE, GRADECODE, WORKERSERIAL, TOKENNO, LEAVECODE, LEAVEAPPLIEDON, LEAVESANCTIONEDON, LEAVEDATE, LEAVEENCASHED, CALENDARYEAR, USERNAME, SYSROWID,  LEAVEDAYS,MODETYPE)
   values(c1.COMPANYCODE, c1.DIVISIONCODE, c1.YEARCODE,c1.CATEGORYCODE,c1.GRADECODE, c1.WORKERSERIAL,c1.TOKENNO, c1.LEAVECODE , c1.FROMDATE , lv_LEAVESANCTIONEDON ,lv_date,'N',to_char(c1.FROMDATE,'YYYY'),c1.USERNAME,FN_GENERATE_SYSROWID,NVL2(lv_LEAVESANCTIONEDON,  1  ,0),c1.MODETYPE);
--   INSERT INTO GBL_GPSLEAVEAPPLICATION
--    (
--        OPERATIONMODE,
--        ADJUSTMENTTAG,
--        CALENDARYEAR,
--        CATEGORYCODE,
--        COMPANYCODE,
--        DIVISIONCODE,
--        DOCUMENTNO,
--        FINALSETTLEMENTTAG,
--        GRADECODE,
--        LEAVEAPPLICATIONREMARKS,
--        LEAVEAPPLIEDON,
--        LEAVECODE,
--        LEAVEDATE,        
--        LEAVEDAYS,
--        LEAVEENCASHED,
--        LEAVESANCTIONEDON,
--        LEAVESANCTIONREMARKS,        
--        TAXABLE,
--        TOKENNO,
--        UNITCODE,
--        USERNAME,
--        WAGERATE,
--        WORKERSERIAL,
--        YEARCODE
--    )
--    VALUES
--    (
--        c1.OPERATIONMODE,
--        NULL,
--        to_char(c1.FROMDATE,'YYYY'),
--        c1.CATEGORYCODE,
--        c1.COMPANYCODE,
--        c1.DIVISIONCODE,
--        NULL,
--        NULL,
--        c1.GRADECODE,
--        NULL,
--        c1.FROMDATE,
--        c1.LEAVECODE,
--        lv_date,
--        1,
--        'N',
--        lv_LEAVESANCTIONEDON,
--        NULL,        
--        NULL,
--        c1.TOKENNO,
--        NULL,
--        c1.USERNAME,
--        NULL,
--        c1.WORKERSERIAL,
--        c1.YEARCODE
--    );    
   lv_date := lv_date + 1;
  end loop;
end loop ;

--PROC_GPSLEAVESANC_UPDATE ;

lv_StrSql := ' INSERT INTO GPSATTENDANCEDETAILS_STAGE (COMPANYCODE, DIVISIONCODE, YEARCODE, '||CHR(10) 
            ||' ATTENDANCEDATE, CLUSTERCODE, ATTN_TYPECODE, ATTNBOOKCODE, '||CHR(10) 
            ||' WORKERSERIAL, TOKENNO, EMPLOYEECODE, CATEGORYCODE, CATEGORYTYPE, OCCUPATIONCODE, OCCOUPATIONTYPE,  '||CHR(10) 
            ||' HAZIRA, EXTRAHAZIRA, ATTENDANCEHOURS, OVERTIMEHOURS, INCENTIVECODE,  '||CHR(10)
            ||' AREACLASSIFICATIONCODE1, UOM1, OUTPUTFORTHEDAY1, AREACLASSIFICATIONCODE2, UOM2, OUTPUTFORTHEDAY2,  '||CHR(10) 
            ||' AREACLASSIFICATIONCODE3, UOM3, OUTPUTFORTHEDAY3, ATTN_TAG, USERNAME, LASTMODIFIED, SYSROWID)  '||CHR(10)                 
            ||' SELECT A.COMPANYCODE, A.DIVISIONCODE, A.YEARCODE,  '||CHR(10) 
            ||' A.LEAVEDATE , B.CLUSTERCODE, NULL, B.ATTNBOOKCODE,  '||CHR(10)
            ||' B.WORKERSERIAL, A.TOKENNO, A.TOKENNO, B.CATEGORYCODE, C.CATEGORYTYPE, A.LEAVECODE, D.OCCUPATIONTYPE,  '||CHR(10)
            ||' A.LEAVEDAYS HAZIRA, 0 EXTRAHAZIRA, 0 ATTENDANCEHOURS, 0 OVERTIMEHOURS, NULL,  '||CHR(10) 
            ||' NULL, NULL, 0, NULL, NULL, 0,  '||CHR(10) 
            ||' NULL, NULL, 0, ''LEAVE'', '''', SYSDATE, ''LV/''||TO_CHAR(TO_DATE(A.LEAVEDATE,''DD/MM/YYYY''),''YYYYMMDD'')||A.TOKENNO AS SYSROWID  '||CHR(10)
            ||' FROM GPSLEAVEAPPLICATION A, GPSEMPLOYEEMAST B, GPSCATEGORYMAST C, GPSOCCUPATIONMAST D, GBL_GPSLVAPPLICATION E  '||CHR(10)
            ||' WHERE A.COMPANYCODE = B.COMPANYCODE AND A.DIVISIONCODE = B.DIVISIONCODE '||CHR(10)
            ||'   AND A.WORKERSERIAL = B.WORKERSERIAL '||CHR(10)
            ||'   AND B.COMPANYCODE = C.COMPANYCODE AND B.DIVISIONCODE = C.DIVISIONCODE AND B.CATEGORYCODE = C.CATEGORYCODE '||CHR(10)
            ||'   AND A.COMPANYCODE = D.COMPANYCODE AND A.DIVISIONCODE = D.DIVISIONCODE '||CHR(10)
            ||'   AND A.LEAVECODE = D.OCCUPATIONCODE '||CHR(10)
            ||'   AND A.COMPANYCODE = E.COMPANYCODE AND A.DIVISIONCODE = E.DIVISIONCODE '||CHR(10)
            ||'   AND A.WORKERSERIAL = E.WORKERSERIAL '||CHR(10)
            ||'   AND A.LEAVECODE = E.LEAVECODE '||CHR(10)
            ||'   AND A.LEAVEAPPLIEDON = E.FROMDATE '||CHR(10)
            ||'   AND A.MODETYPE = ''BULK'' '||CHR(10)
            ||'   AND A.LEAVESANCTIONEDON IS NOT NULL '||CHR(10);
            DELETE qrycheck ;
            insert into qrycheck values(lv_StrSql);
            EXECUTE IMMEDIATE lv_StrSql;

COMMIT;
exception
    when others then
        lv_SqlErr := SqlErrm;
       insert into gps_error_log(PROC_NAME,ORA_ERROR_MESSG,ERROR_QUERY) values( 'PROC_GPSLVAPPLICATION_UPDATE',lv_SqlErr,lv_StrSql);
    commit;     
end;
/
