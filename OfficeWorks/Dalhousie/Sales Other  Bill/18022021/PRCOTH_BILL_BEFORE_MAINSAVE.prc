CREATE OR REPLACE PROCEDURE DALHOUSIE_WEB."PRCOTH_BILL_BEFORE_MAINSAVE" 
is
lv_cnt                  number;
lv_result               varchar2(10);
lv_error_remark         varchar2(4000) := '' ;
lv_Master               GBL_SALESOTHERBILLMASTER%rowtype;
lv_BILLNO              varchar2(100) := '';
lv_MaxBILLDATE         date;
lv_ChannelMaster        CHANNELMASTER%rowtype;
lv_BILLTYPE              varchar2(16) :='';
lv_GovtRefNo            number(18,0);
LV_TCSONAMOUNT                   NUMBER(18,2);
LV_TCSAMOUNT                      NUMBER(18,2);
LV_TCSCHARGECODE                 VARCHAR2(50 BYTE);
LV_TCSRATE                       NUMBER(18,4);
LV_TCSROUNDOFF                   NUMBER(18,2);
LV_CNTSERVICEITEM                  number;
lv_PANNO                varchar2(50) := '' ;
lv_DIVISIONPANNO                varchar2(50) := '' ;

begin
    lv_result:='#SUCCESS#';
   
    --Master
    select count(*)
    into lv_cnt
    from GBL_SALESOTHERBILLMASTER;
   
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in Other Bill]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    select count(*)
    into lv_cnt
    from GBL_SALESOTHERBILLDETAIL;
   
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in Other Bill Details]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    select *
    into lv_Master
    from GBL_SALESOTHERBILLMASTER;

    if lv_Master.OperationMode is null then
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT / VIEW ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

    select *
    into lv_ChannelMaster
    from CHANNELMASTER
    where companycode = lv_Master.CompanyCode
      and divisioncode = lv_Master.Divisioncode
      and module = 'SALES'
      and ChannelCode = lv_Master.ChannelCode;

        UPDATE GBL_SALESOTHERBILLDETAIL SET SALESBILLDATE=lv_Master.SALESBILLDATE;

        UPDATE GBL_SALESCHARGEDETAILS SET DOCUMENTDATE=lv_Master.SALESBILLDATE;



     -------- added by Surojit Mondal 09_07_2019
                if lv_Master.OPERATIONMODE = 'D' or lv_Master.OPERATIONMODE = 'M' then
                    SELECT COUNT(*)
                    INTO lv_GovtRefNo
                    FROM SALESOTHERBILLMASTER
                    WHERE COMPANYCODE = LV_MASTER.COMPANYCODE
                      AND DIVISIONCODE = LV_MASTER.DIVISIONCODE
                      AND CHANNELCODE = LV_MASTER.CHANNELCODE 
                      AND SALESBILLNO=LV_MASTER.SALESBILLNO
                      AND GOVTREFNO IS NOT NULL;
                    
                    if LV_GOVTREFNO > 0 then
                        lv_error_remark := 'Validation Failure : [ Government Refrence Number already Generated. Modify or Delete not possible. ]';
                        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
                    end if;
                end if;
     -------End


-----------------------  Auto Number


    if nvl(lv_Master.OperationMode,'NA') = 'A' then
        select count(*)
        into lv_cnt
        from SALESOTHERBILLMASTER
        where companycode = lv_Master.CompanyCode
          and divisioncode = lv_Master.DivisionCode
          and YearCode = lv_Master.YearCode;

        if lv_cnt > 0 then
            select max(SALESBILLDATE)
            into lv_MaxBILLDATE
            from SALESOTHERBILLMASTER
            where companycode = lv_Master.CompanyCode
              and divisioncode = lv_Master.DivisionCode
              and YearCode = lv_Master.YearCode 
              and Billtype=lv_Master.Billtype;
              
           /* if lv_Master.SALESBILLDATE < lv_MaxBILLDATE then
                lv_error_remark := 'Validation Failure : [Last Other Bill Date was : ' || to_char(lv_MaxBILLDATE,'dd/mm/yyyy') || ' You can not save any Other Bill before this date.]';
                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            end if;  */   
        end if;

        if lv_ChannelMaster.ChannelTag = 'SCRAP' and (lv_Master.Billtype='WITH CHALLAN' OR lv_Master.Billtype='WITH DO') then
            select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'SCRAP_SALES_BILL_WC',to_char(lv_Master.SALESBILLDATE,'dd/mm/yyyy')) 
            into lv_BILLNO
            from dual;
        elsif lv_ChannelMaster.ChannelTag = 'SCRAP' and lv_Master.Billtype='WITHOUT CHALLAN' then
            select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'SCRAP_SALES_BILL_WOC',to_char(lv_Master.SALESBILLDATE,'dd/mm/yyyy')) 
            into lv_BILLNO
            from dual;

        end if;

        if lv_ChannelMaster.ChannelTag = 'OTHERS' and (lv_Master.Billtype='WITH CHALLAN' OR lv_Master.Billtype='WITH DO') then
            select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'OTHER_SALES_BILL_WC',to_char(lv_Master.SALESBILLDATE,'dd/mm/yyyy')) 
            into lv_BILLNO
            from dual;
            
        
--       elsif lv_ChannelMaster.ChannelTag = 'OTHERS' and lv_Master.Billtype='WITHOUT CHALLAN' then
----            select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'OTHER_SALES_BILL_WOC',to_char(lv_Master.SALESBILLDATE,'dd/mm/yyyy')) 
----            into lv_BILLNO
----            from dual;
--            select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'OTHER_SALES_BILL_WOC_'||lv_Master.ChannelCode,to_char(lv_Master.SALESBILLDATE,'dd/mm/yyyy')) 
--            into lv_BILLNO
--            from dual;
--       elsif lv_ChannelMaster.ChannelTag = 'GOVERNMENT' and lv_Master.Billtype='WITHOUT CHALLAN' then
--            select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'OTHER_SALES_BILL_GOV_WOC',to_char(lv_Master.SALESBILLDATE,'dd/mm/yyyy')) 
--            into lv_BILLNO
--            from dual;

            --if nvl(lv_Master.salesbillno,'~na~') = '~na~'then
                --lv_BILLNO := lv_master.MRNO;
--                lv_error_remark := 'Validation Failure : [In this case you have to provide the Sales Bill No manually]';
--                raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
            --end if;            
        end if;
        
         if lv_Master.Billtype='WITHOUT CHALLAN' then 
            select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'OTHER_SALES_BILL_WOC_'||lv_Master.ChannelCode,to_char(lv_Master.SALESBILLDATE,'dd/mm/yyyy')) 
            into lv_BILLNO
            from dual;
         end if;            

        update GBL_SALESOTHERBILLMASTER
        set SALESBILLNO = lv_BILLNO;
        
        update GBL_SALESOTHERBILLDETAIL
        set SALESBILLNO = lv_BILLNO;
       
        update GBL_SALESCHARGEDETAILS
        set DOCUMENTNO = lv_BILLNO;
        
           
         
        --added on 09/02/2021
        
        
        
        update GBL_SALESOTHERBILLREFDETAILS
        set SCRAPSALEBILLNO = lv_BILLNO;
        
        update GBL_SALESOTHERBILLREFDETAILS
        set SCRAPSALEBILLDATE = lv_Master.SALESBILLDATE;
        
        
--        select count(*) into lv_cnt from GBL_SALESOTHERBILLREFDETAILS where SCRAPSALESBILLNO = lv_BILLNO;
--        
--        
--        lv_error_remark := 'Validation Failure : [error***********]---------'||lv_BILLNO||'--------------  '||lv_cnt;
--        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
--        
        --ended on 09/02/2021
        
        
        select *
        into lv_Master
        from GBL_SALESOTHERBILLMASTER;
            
    end if;
    
    --TCS Auto Insert
  LV_CNTSERVICEITEM :=0; 
--   FOR C1 
--   IN
--   (SELECT DISTINCT HSNCODE,COMPANYCODE FROM GBL_SALESOTHERBILLDETAIL)
--   LOOP
--       SELECT 
--       COUNT(*) 
--       INTO lv_cnt 
--       FROM GSTHSNMASTER 
--       WHERE HSNCODE=C1.HSNCODE
--         AND TYPEOFITEM='S';
--       
--       IF lv_cnt>0 THEN
--       LV_CNTSERVICEITEM :=LV_CNTSERVICEITEM+1;
--       END IF;
--       
--   END LOOP;
   
 IF NVL(LV_CNTSERVICEITEM,0)=0 THEN 
  IF lv_ChannelMaster.channeltag not in('EXPORT','SCRAP') then
    SELECT NVL(FN_GET_TCSAPPLICABLEAMT(lv_Master.companycode,lv_Master.divisioncode,lv_Master.yearcode,lv_Master.PARTYCODE,lv_Master.GROSSAMT,lv_Master.SALESBILLNO,TO_CHAR(lv_Master.SALESBILLDATE,'DD/MM/YYYY'),lv_Master.OperationMode,NVL (lv_Master.ADDRESSCODEBILL, lv_Master.ADDRESSCODE)),0) 
    INTO lv_TCSONAMOUNT
    FROM DUAL;
  END IF;
 END IF;
 
 
  if lv_ChannelMaster.channeltag  in ('GOVERNMENT') AND lv_Master.SALESBILLDATE>=TO_DATE('01/10/2020','DD/MM/YYYY') then  
      lv_TCSONAMOUNT :=lv_Master.GROSSAMT;
  END IF;
 
    SELECT FN_GET_TCSPANNO(lv_Master.companycode,lv_Master.divisioncode,lv_Master.yearcode,lv_Master.PARTYCODE,NVL (lv_Master.ADDRESSCODEBILL, lv_Master.ADDRESSCODE)) 
         INTO lv_PANNO
         FROM DUAL;
         
     SELECT SUBSTR (GSTNNO, 3, 10) INTO lv_DIVISIONPANNO FROM DIVISIONMASTER
     WHERE COMPANYCODE=lv_Master.companycode
       AND DIVISIONCODE=lv_Master.divisioncode;
   
   IF lv_PANNO=lv_DIVISIONPANNO THEN
     lv_TCSONAMOUNT :=0;
   END IF;

   IF NVL(lv_TCSONAMOUNT,0)>0 THEN
   
      
   
     IF lv_PANNO IS NOT NULL THEN 
   
            SELECT count(*) 
                into lv_cnt FROM SYS_PARAMETER
                WHERE PARAMETER_NAME='TCS CHARGECODE WITH PAN'
                AND COMPANYCODE=lv_Master.companycode
                AND ROWNUM=1;
             if lv_cnt = 0 then
                 lv_error_remark := '[Charge Code Not Set in SYS_PARAMETER For TCS CHARGECODE WITH PAN... Report Softweb....]';
                raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark));
             END IF;
             
            SELECT PARAMETER_VALUE
                into lv_TCSCHARGECODE 
                FROM SYS_PARAMETER
                WHERE PARAMETER_NAME='TCS CHARGECODE WITH PAN'
                AND COMPANYCODE=lv_Master.companycode
                AND ROWNUM=1;
                
           SELECT COUNT(CHARGECODE)
                          INTO lv_cnt 
                           FROM CHARGEMASTER 
                             WHERE COMPANYCODE=lv_Master.companycode
                              AND DIVISIONCODE=lv_master.divisioncode
                              AND CHANNELCODE=lv_Master.channelcode
                              AND CHARGENATURE='TCS'
                              AND MODULE='SALES'
                              AND ACTIVE = 'Y'
                              AND CHARGECODE=lv_TCSCHARGECODE;
              if lv_cnt = 0 then
                 lv_error_remark := '[Charge Code Not Generate For TCS... Report Softweb....]';
                raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark));
              END IF;
          
            SELECT 
            CHARGECODE,RATEPERUNIT,NVL(ROUNDOFF,0) 
            INTO LV_TCSCHARGECODE,LV_TCSRATE,LV_TCSROUNDOFF 
            FROM CHARGEMASTER 
            WHERE COMPANYCODE=lv_Master.companycode
              AND DIVISIONCODE=lv_master.divisioncode
              AND CHANNELCODE=lv_Master.channelcode
              AND CHARGENATURE='TCS'
              AND MODULE='SALES'
              AND ACTIVE = 'Y'
              AND CHARGECODE=lv_TCSCHARGECODE;
     ELSE
   
           SELECT count(*) 
                into lv_cnt FROM SYS_PARAMETER
                WHERE PARAMETER_NAME='TCS CHARGECODE WITHOUT PAN'
                AND COMPANYCODE=lv_Master.companycode
                AND ROWNUM=1;
             if lv_cnt = 0 then
                 lv_error_remark := '[Charge Code Not Set in SYS_PARAMETER For TCS CHARGECODE WITHOUT PAN... Report Softweb....]';
                raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark));
             END IF;
             
            SELECT PARAMETER_VALUE
                into lv_TCSCHARGECODE 
                FROM SYS_PARAMETER
                WHERE PARAMETER_NAME='TCS CHARGECODE WITHOUT PAN'
                AND COMPANYCODE=lv_Master.companycode
                AND ROWNUM=1;
                
          SELECT COUNT(CHARGECODE)
                          INTO lv_cnt 
                           FROM CHARGEMASTER 
                             WHERE COMPANYCODE=lv_Master.companycode
                              AND DIVISIONCODE=lv_master.divisioncode
                              AND CHANNELCODE=lv_Master.channelcode
                              AND CHARGENATURE='TCS'
                              AND MODULE='SALES'
                              AND ACTIVE = 'Y'
                              AND CHARGECODE=lv_TCSCHARGECODE;
              if lv_cnt = 0 then
                 lv_error_remark := '[Charge Code Not Generate For TCS... Report Softweb....]';
                raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark));
              END IF;
          
            SELECT 
            CHARGECODE,RATEPERUNIT,NVL(ROUNDOFF,0) 
            INTO LV_TCSCHARGECODE,LV_TCSRATE,LV_TCSROUNDOFF 
            FROM CHARGEMASTER 
            WHERE COMPANYCODE=lv_Master.companycode
              AND DIVISIONCODE=lv_master.divisioncode
              AND CHANNELCODE=lv_Master.channelcode
              AND CHARGENATURE='TCS'
              AND MODULE='SALES'
              AND ACTIVE = 'Y'
              AND CHARGECODE=lv_TCSCHARGECODE;
   
     END IF;
   
--    SELECT COUNT(CHARGECODE)
--                  INTO lv_cnt 
--                   FROM CHARGEMASTER 
--                     WHERE COMPANYCODE=lv_Master.companycode
--                      AND DIVISIONCODE=lv_master.divisioncode
--                      AND CHANNELCODE=lv_Master.channelcode
--                      AND CHARGENATURE='TCS'
--                      AND MODULE='SALES'
--                      AND ACTIVE = 'Y';
--      if lv_cnt = 0 then
--         lv_error_remark := '[Charge Code Not Generate For TCS... Report Softweb....]';
--        raise_application_error(to_number(fn_display_error( 'COMMON')),fn_display_error( 'COMMON',6,lv_error_remark));
--      END IF;
--  
--    SELECT 
--    CHARGECODE,RATEPERUNIT,NVL(ROUNDOFF,0) 
--    INTO LV_TCSCHARGECODE,LV_TCSRATE,LV_TCSROUNDOFF 
--    FROM CHARGEMASTER 
--    WHERE COMPANYCODE=lv_Master.companycode
--      AND DIVISIONCODE=lv_master.divisioncode
--      AND CHANNELCODE=lv_Master.channelcode
--      AND CHARGENATURE='TCS'
--      AND MODULE='SALES'
--      AND ACTIVE = 'Y';
      
     LV_TCSAMOUNT :=ROUND(((NVL(lv_TCSONAMOUNT,0)*NVL(LV_TCSRATE,0))/100),NVL(LV_TCSROUNDOFF,0));
    
     UPDATE GBL_SALESOTHERBILLMASTER SET GROSSAMT =NVL(GROSSAMT,0)+NVL(LV_TCSAMOUNT,0);
     
     select *
     into lv_Master
     from GBL_SALESOTHERBILLMASTER;
    
   ELSE
   DELETE FROM SALESCHARGEDETAILS 
            WHERE COMPANYCODE=lv_Master.companycode
              AND divisioncode=lv_Master.divisioncode
              AND yearcode=lv_Master.yearcode
              AND channelcode=lv_Master.channelcode
              AND documenttype=CASE WHEN lv_ChannelMaster.channeltag='SCRAP' THEN 'SCRAP BILL' WHEN lv_ChannelMaster.channeltag='OTHERS' then 'OTHERS BILL' ELSE 'SALE BILL' END
              AND documentno=lv_Master.SALESBILLNO
              AND CHARGECODE  IN
                  (
                   SELECT DISTINCT CHARGECODE FROM CHARGEMASTER
                    WHERE COMPANYCODE=lv_Master.companycode
                      AND divisioncode=lv_Master.divisioncode
                      AND channelcode=lv_Master.channelcode
                      AND CHARGENATURE='TCS'
                      AND MODULE='SALES'
                      AND ACTIVE = 'Y'
                  );
   
   END IF;
   
   
          IF NVL(LV_TCSAMOUNT,0)>0 THEN
          
              select count(*)
              into lv_cnt
              FROM GBL_SALESCHARGEDETAILS;
              
            IF lv_cnt>0 THEN 
             
            DELETE FROM SALESCHARGEDETAILS 
            WHERE COMPANYCODE=lv_Master.companycode
              AND divisioncode=lv_Master.divisioncode
              AND yearcode=lv_Master.yearcode
              AND channelcode=lv_Master.channelcode
              AND documenttype=CASE WHEN lv_ChannelMaster.channeltag='SCRAP' THEN 'SCRAP BILL' WHEN lv_ChannelMaster.channeltag='OTHERS' then 'OTHERS BILL' ELSE 'SALE BILL' END
              AND documentno=lv_Master.SALESBILLNO
             AND CHARGECODE  IN
                  (
                   SELECT DISTINCT CHARGECODE FROM CHARGEMASTER
                    WHERE COMPANYCODE=lv_Master.companycode
                      AND divisioncode=lv_Master.divisioncode
                      AND channelcode=lv_Master.channelcode
                      AND CHARGENATURE='TCS'
                      AND MODULE='SALES'
                      AND ACTIVE = 'Y'
                  );
                  
             DELETE FROM GBL_SALESCHARGEDETAILS WHERE CHARGECODE =lv_TCSCHARGECODE;

             INSERT INTO GBL_SALESCHARGEDETAILS
             (
                companycode, divisioncode, divisioncodefor,
                yearcode, channelcode, documentno,
                documentdate, documenttype, chargecode,
                chargeamount, assessableamount,
                username
             )
             SELECT lv_Master.companycode,lv_Master.divisioncode,lv_Master.divisioncode,
             lv_Master.yearcode,lv_Master.channelcode,lv_Master.SALESBILLNO,
             lv_Master.SALESBILLDATE,CASE WHEN lv_ChannelMaster.channeltag='SCRAP' THEN 'SCRAP BILL' WHEN lv_ChannelMaster.channeltag='OTHERS' then 'OTHERS BILL' ELSE 'SALE BILL' END,lv_TCSCHARGECODE,
             NVL(LV_TCSAMOUNT,0),NVL(lv_TCSONAMOUNT,0),
             lv_Master.username
             FROM DUAL;
           
            ELSE
            DELETE FROM SALESCHARGEDETAILS 
            WHERE COMPANYCODE=lv_Master.companycode
              AND divisioncode=lv_Master.divisioncode
              AND yearcode=lv_Master.yearcode
              AND channelcode=lv_Master.channelcode
              AND documenttype=CASE WHEN lv_ChannelMaster.channeltag='SCRAP' THEN 'SCRAP BILL' WHEN lv_ChannelMaster.channeltag='OTHERS' then 'OTHERS BILL' ELSE 'SALE BILL' END
              AND documentno=lv_Master.SALESBILLNO
             AND CHARGECODE  IN
                  (
                   SELECT DISTINCT CHARGECODE FROM CHARGEMASTER
                    WHERE COMPANYCODE=lv_Master.companycode
                      AND divisioncode=lv_Master.divisioncode
                      AND channelcode=lv_Master.channelcode
                      AND CHARGENATURE='TCS'
                      AND MODULE='SALES'
                      AND ACTIVE = 'Y'
                  );
              
             INSERT INTO saleschargedetails
             (
                companycode, divisioncode, divisioncodefor,
                yearcode, channelcode, documentno,
                documentdate, documenttype, chargecode,
                chargeamount, assessableamount,
                username,sysrowid
             )
             SELECT lv_Master.companycode,lv_Master.divisioncode,lv_Master.divisioncode,
             lv_Master.yearcode,lv_Master.channelcode,lv_Master.SALESBILLNO,
             lv_Master.SALESBILLDATE,CASE WHEN lv_ChannelMaster.channeltag='SCRAP' THEN 'SCRAP BILL' WHEN lv_ChannelMaster.channeltag='OTHERS' then 'OTHERS BILL' ELSE 'SALE BILL' END,lv_TCSCHARGECODE,
             NVL(LV_TCSAMOUNT,0),NVL(lv_TCSONAMOUNT,0),
             lv_Master.username, lv_Master.sysrowid
             FROM DUAL;
             
            END IF;
          END IF;

  --End TCS Auto Insert
---------------------------------------    Numbering    
    select count(*)
    into lv_cnt
    from GBL_SALESCHARGEDETAILS;
    
    if lv_cnt=0 then
        delete from saleschargedetails where companycode=lv_master.companycode 
        and divisioncode=lv_master.divisioncode and channelcode=lv_master.channelcode and documentno=lv_master.salesbillno and documenttype='OTHERS BILL'
        AND CHARGECODE NOT IN
                  (
                   SELECT DISTINCT CHARGECODE FROM CHARGEMASTER
                    WHERE COMPANYCODE=lv_Master.companycode
                      AND divisioncode=lv_Master.divisioncode
                      AND channelcode=lv_Master.channelcode
                      AND CHARGENATURE='TCS'
                      AND MODULE='SALES'
                      AND ACTIVE = 'Y'
                  );
    end if;
    
    if lv_Master.OperationMode = 'A' then
        select count(*)
        into lv_cnt
        from SYS_GBL_PROCOUTPUT_INFO;
        
        if lv_cnt = 0 then
            insert into SYS_GBL_PROCOUTPUT_INFO
            values ('[Other Bill NUMBER : ' || lv_Master.SALESBILLNO || ' Dated : ' || lv_Master.SALESBILLDATE || ']');
        else
            update SYS_GBL_PROCOUTPUT_INFO
            set SYS_SAVE_INFO = nvl(SYS_SAVE_INFO,'') || ('[Other Bill NUMBER : ' || lv_Master.SALESBILLNO || ' Dated : ' || lv_Master.SALESBILLDATE || ']');
        end if;

    end if;    
    
--exception when others then
--    lv_error_remark:= lv_error_remark || '#UNSUCC#ESSFULL#';
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
end;
/
