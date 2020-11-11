CREATE OR REPLACE PROCEDURE JIAJURI.prcGPSWAGESPROCESS_B4SAVE
is
lv_cnt                  number;
lv_cnt_data             number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_GPSWAGEPROCESS%rowtype;
lv_MaxDRCRdate          date;
lv_TransactionNo        varchar2(50);
lv_cntChkdup            number;
lv_ItemVSCharge         varchar2(4000);      
lv_WagesProcesTableCheck varchar2(30);
lv_sqlstr                varchar2(1000);
lv_CHK                NUMBER;

begin


 
 --dbms_output.put_line('ss');
    lv_result:='#SUCCESS#';
    
    if lv_Master.WAGES_TYPE = 'DAILY' THEN
        lv_WagesProcesTableCheck := 'GPSDAILYPAYSHEETDETAILS';
    ELSIF lv_Master.WAGES_TYPE = 'RATION' THEN
       lv_WagesProcesTableCheck := 'GPSRATIONDETAILS';
    ELSE
       lv_WagesProcesTableCheck := 'GPSPAYSHEETDETAILS';    
    end if;
    
    select *
    into lv_Master
    from GBL_GPSWAGEPROCESS
    WHERE ROWNUM<=1;

  
    select count(*)
    into lv_cnt
    from GBL_GPSWAGEPROCESS;
    
     
    --return;
        
     IF NVL(lv_cnt,0)=0 THEN
        lv_error_remark := 'Validation Failure : [Blank data not allowded to save!]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
    END IF;    
    
    IF lv_master.CATEGORYTYPE ='WORKER'  THEN
    PRCGPS_WAGES_PROCESS(lv_Master.WAGES_TYPE,lv_Master.COMPANYCODE,lv_Master.DIVISIONCODE,lv_Master.YEARCODE,lv_Master.USERNAME,
    TO_CHAR(lv_Master.FORTNIGHTSTARTDATE,'DD/MM/YYYY'),TO_CHAR(lv_Master.FORTNIGHTENDDATE,'DD/MM/YYYY'),UPPER(lv_Master.CATEGORYTYPE),lv_Master.CATEGORYCODE,NULL);                                   
    ELSE
    PRCGPS_WAGES_PROCESS(lv_Master.WAGES_TYPE,lv_Master.COMPANYCODE,lv_Master.DIVISIONCODE,lv_Master.YEARCODE,lv_Master.USERNAME,
    TO_CHAR(lv_Master.FORTNIGHTSTARTDATE,'DD/MM/YYYY'),TO_CHAR(lv_Master.FORTNIGHTENDDATE,'DD/MM/YYYY'),UPPER(lv_Master.CATEGORYTYPE),lv_Master.CATEGORYCODE,'','STAFF');                                   
    END IF;


--lv_sqlstr :=     ' SELECT COUNT(*)  FROM '||lv_WagesProcesTableCheck||''|| chr(10)
--               ||' WHERE COMPANYCODE = '''||lv_Master.COMPANYCODE||''''|| chr(10)              
--               ||' AND DIVISIONCODE = '''||lv_Master.DIVISIONCODE||''''|| chr(10)
--               ||' AND PERIODFROM = '''||lv_Master.FORTNIGHTSTARTDATE||''''|| chr(10)
--               ||' AND PERIODTO = '''||lv_Master.FORTNIGHTENDDATE||''''|| chr(10);
--               --||' AND CATEGORYTYPE = '''||lv_Master.CATEGORYTYPE||''''|| chr(10);

--   --dbms_output.put_line(lv_sqlstr);
--   execute immediate lv_sqlstr INTO lv_cnt_data;


--    IF NVL(lv_cnt_data,0)=0 THEN
--        lv_error_remark := 'Validation Failure : [No data inserted. There is some problem, Please try again!!]';
--        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',5,lv_error_remark));
--    END IF;    


end;
/