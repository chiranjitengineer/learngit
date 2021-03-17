CREATE OR REPLACE procedure prcJutePODummy_Before_MainSave
is
lv_cnt      number;
lv_result   varchar2(10);
lv_error_remark varchar2(4000) := '' ;
lv_Master gbl_JutePurchaseOrderMaster%rowtype;
lv_RecCount number;
lv_TotalBales number;
lv_TotalWeight number;
lv_OrderValue number;
lv_OrderNo varchar2(100) := '';
lv_MaxOrderDate date;
lv_ChannelWiseOrderNo   varchar2(100) :='';

begin
    lv_result:='#SUCCESS#';
   
    --Master
    select count(*)
    into lv_cnt
    from gbl_JutePurchaseOrderMaster;
    
    if lv_cnt > 1 then
        lv_error_remark := 'Validation Failure : [More than rows found in Purchase Order Master]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    elsif lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in Purchase Order Master]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;
    
    select count(*)
    into lv_cnt
    from gbl_JutePurchaseOrderDetails;
    
    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [No row found in Purchase Order Details]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;

    
    select *
    into lv_Master
    from gbl_JutePurchaseOrderMaster;

   if lv_Master.OperationMode is null then
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish ADD / EDIT / VIEW ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

    select count(*)
    into lv_cnt
    from channelmaster
    where companycode = lv_Master.CompanyCode
      and divisioncode = lv_Master.DivisionCode
      and module = 'JUTE'
      and channelcode = lv_Master.channelcode;

    if lv_cnt = 0 then
        lv_error_remark := 'Validation Failure : [Please select the Purchase Channel]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if; 
----------------------
    if lv_Master.OperationMode = 'A' then
        
        select count(*)
        into lv_cnt
        from sys_parameter
        where parameter_name ='JUTE_CHANNELWISE_ORDERNO'
          and PARAMETER_VALUE ='YES';
        if lv_cnt =0 then
            select count(*)
            into lv_cnt
            from JutePurchaseOrderMaster
            where companycode = lv_Master.CompanyCode
              and divisioncode = lv_Master.DivisionCode
              and YearCode = lv_Master.YearCode;
            if lv_cnt > 0 then
                select max(orderdate)
                into lv_MaxOrderDate
                from JutePurchaseOrderMaster
                where companycode = lv_Master.CompanyCode
                  and divisioncode = lv_Master.DivisionCode
                  and YearCode = lv_Master.YearCode;
                if lv_Master.OrderDate < lv_MaxOrderDate then
                    lv_error_remark := 'Validation Failure : [Last Order Date was : ' || to_char(lv_MaxOrderDate,'dd/mm/yyyy') || ' You can not save any Order before this date.]';
                    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
                end if;     
            end if;
            
            --ADDED ON 06032021
--                select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'RAW_JUTE_PURCHASE_ORDER',to_char(lv_Master.OrderDate,'dd/mm/yyyy')) 
--                into lv_OrderNo
--                from dual;
            
            IF nvl(lv_Master.ISDUMMY,'N') = 'Y' THEN
                select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'RAW_JUTE_PURCHASE_ORDER_DUMMY',to_char(lv_Master.OrderDate,'dd/mm/yyyy')) 
                into lv_OrderNo
                from dual; 
                    
            ELSE
                select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'RAW_JUTE_PURCHASE_ORDER',to_char(lv_Master.OrderDate,'dd/mm/yyyy')) 
                into lv_OrderNo
                from dual;
            END IF;
            
            --ENED ON 06032021
        else                       
            select NVL(CHANNELTAG,'~NA~')
            into lv_ChannelWiseOrderNo
            from channelmaster
            where companycode = lv_Master.CompanyCode
              and divisioncode = lv_Master.DivisionCode
              and module = 'JUTE'
              and channelcode = lv_Master.channelcode;
            IF NVL(lv_ChannelWiseOrderNo,'~NA~') ='PTF' THEN
                select count(*)
                into lv_cnt
                from JutePurchaseOrderMaster
                where companycode = lv_Master.CompanyCode
                  and divisioncode = lv_Master.DivisionCode
                  and YearCode = lv_Master.YearCode
                  and channelcode = lv_Master.channelcode;
                if lv_cnt > 0 then                    
                    select max(orderdate)
                    into lv_MaxOrderDate
                    from JutePurchaseOrderMaster
                    where companycode = lv_Master.CompanyCode
                      and divisioncode = lv_Master.DivisionCode
                      and YearCode = lv_Master.YearCode
                      and channelcode = lv_Master.channelcode;
                   
                    if lv_Master.OrderDate < lv_MaxOrderDate then
                        lv_error_remark := 'Validation Failure : [Last Order Date was : ' || to_char(lv_MaxOrderDate,'dd/mm/yyyy') || ' You can not save any Order before this date.]';
                        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
                    end if;     
                end if;
            ELSE
                select count(*)
                into lv_cnt
                from JutePurchaseOrderMaster
                where companycode = lv_Master.CompanyCode
                  and divisioncode = lv_Master.DivisionCode
                  and YearCode = lv_Master.YearCode;
                if lv_cnt > 0 then                 
                    select max(orderdate)
                    into lv_MaxOrderDate
                    from JutePurchaseOrderMaster
                    where companycode = lv_Master.CompanyCode
                      and divisioncode = lv_Master.DivisionCode
                      and YearCode = lv_Master.YearCode;                    
                    if lv_Master.OrderDate < lv_MaxOrderDate then
                        lv_error_remark := 'Validation Failure : [Last Order Date was : ' || to_char(lv_MaxOrderDate,'dd/mm/yyyy') || ' You can not save any Order before this date.]';
                        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
                    end if;     
                end if;
            END IF;
            
            IF nvl(lv_Master.ISDUMMY,'N') = 'Y' THEN
                select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'RAW_JUTE_PURCHASE_ORDER_DUMMY',to_char(lv_Master.OrderDate,'dd/mm/yyyy')) 
                into lv_OrderNo
                from dual;
            ELSE
                IF NVL(lv_ChannelWiseOrderNo,'~NA~') ='PTF' THEN
                    select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'RAW_JUTE_PURCHASE_ORDER_PTF',to_char(lv_Master.OrderDate,'dd/mm/yyyy')) 
                    into lv_OrderNo
                    from dual;
                ELSE
                    select fn_autogen_params(lv_Master.CompanyCode,lv_Master.DivisionCode,lv_Master.YearCode,'RAW_JUTE_PURCHASE_ORDER',to_char(lv_Master.OrderDate,'dd/mm/yyyy')) 
                    into lv_OrderNo
                    from dual;
                END IF;
            END IF;
                
        end if;
        
        update gbl_JutePurchaseOrderMaster
        set OrderNo = lv_OrderNo;
            
        update gbl_JutePurchaseOrderDetails
        set OrderNo = lv_OrderNo;

        select *
        into lv_Master
        from gbl_JutePurchaseOrderMaster;
    end if;        
--------------------------------

    if lv_Master.CompanyCode is null then
        lv_error_remark := 'Validation Failure : [Company Code is null in Purchase Order Master]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

    if lv_Master.DivisionCode is null then
        lv_error_remark := 'Validation Failure : [Division Code is null in Purchase Order Master]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

       


    if lv_Master.OrderNo is null then
        lv_error_remark := 'Validation Failure : [Order No is null in Purchase Order Master]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

    if lv_Master.UserName is null then
        lv_error_remark := 'Validation Failure : [User Name is null in Purchase Order Master]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

    if lv_Master.OperationMode is null then
        lv_error_remark := 'Validation Failure : [Which kind of Activity you want to accomplish [Master] ? ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

    if lv_Master.YearCode is null then
        lv_error_remark := 'Validation Failure : [Year Code is null in Purchase Order Master]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

    if lv_Master.RegionCode is null then
        lv_error_remark := 'Validation Failure : [Region Code is null in Purchase Order Master]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

    if lv_Master.bookingstation is null then
        lv_error_remark := 'Validation Failure : [Mukam is null in Purchase Order Master]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    


    if lv_Master.OperationMode ='A' then
        
        select count(*)
        into lv_RecCount
        from JutePurchaseOrderMaster
        where companycode = lv_Master.CompanyCode
          and DivisionCode = lv_Master.DivisionCode
          and OrderNo = lv_Master.OrderNo;
        
        if lv_RecCount > 0 then
            lv_error_remark := 'Validation Failure : [The Order No which you want to Add is already exist...]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;
    end if;    
        
    if lv_Master.OperationMode ='M' then
        select count(*)
        into lv_RecCount
        from JutePurchaseOrderMaster
        where companycode = lv_Master.CompanyCode
          and DivisionCode = lv_Master.DivisionCode
          and OrderNo = lv_Master.OrderNo;
        
        if lv_RecCount = 0 then
            lv_error_remark := 'Validation Failure : [The Order No which you want to Edit does not exists now...]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;

        select count(*)
        into lv_RecCount
        from JutePurchaseOrderMaster
        where companycode = lv_Master.CompanyCode
          and DivisionCode = lv_Master.DivisionCode
          and OrderNo = lv_Master.OrderNo
          and (nvl(Locked,'N') LIKE 'Y%' or nvl(cancelled,'N') like 'Y%');
        
        if lv_RecCount > 0 then
            lv_error_remark := 'Validation Failure : [The Order No is either Locked or Cancelled.. You can not change ...]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;
    end if;    
            
    if lv_Master.bookingstation is null then
        lv_error_remark := 'Validation Failure : [Booking Station should not be kept blank  ]';
        raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
    end if;    

    lv_TotalBales := 0;
    lv_TotalWeight := 0;

    for c1 in (select rownum,a.* from gbl_jutepurchaseorderdetails a) loop
       -- COMPANYCODE, DIVISIONCODE, DIVISIONCODEFOR, CHANNELCODE, YEARCODE, ORDERNO, ORDERDATE, ORDERSERIALNO, MKTGRDCODE, MILLGRDCODE, PRIVATEMARK, NOOFBALES, MOISTUREPERCENTAGE, BASISRATE, BASISVARIATION, GRADEVARIATION, DISCOUNT, RATEPERQUINTAL, WEIGHTINKG, WEIGHTINQT, GRADEAMOUNT, CANCELLED, CANCELLATIONDATE, LOCKED, PREMIUM, CROPYEAR, BALETYPE, USERNAME, LASTMODIFIED, SYSROWID        
        if c1.mktgrdcode is null then
            lv_error_remark := 'Validation Failure : [Market Grade should not be kept blank  ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;    
        
        if c1.millgrdcode is null then
            lv_error_remark := 'Validation Failure : [Mill Grade should not be kept blank  ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;    
        
        if c1.cropyear is null then
            lv_error_remark := 'Validation Failure : [Crop Year should not be kept blank  ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;    

        if c1.PrivateMark is null then
            lv_error_remark := 'Validation Failure : [Marka should not be kept blank  ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;    
        
        if c1.BaleType is null then
            lv_error_remark := 'Validation Failure : [Packing Type should not be kept blank  ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;    
        
        if nvl(lv_Master.NoOfBales,0) = 0 then
            lv_error_remark := 'Validation Failure : [No Of Bales should not be kept blank or Zero ]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;    

        select count(*)
        into lv_cnt
        from jutemillgrdregiondtl
        where companycode = c1.companycode
          and divisioncode = c1.divisioncode
          and regioncode = lv_Master.RegionCode
          and mktgrdcode = c1.mktgrdcode
          and millgrdcode = c1.millgrdcode;
        
        if lv_cnt = 0 then
            lv_error_remark := 'Validation Failure : [Mismatch found in Equivalent Grade Selection]';
            raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
        end if;    
        
        if c1.orderserialno is null then
            select round(max(nvl(orderserialno,0)),0)+1
            into lv_RecCount
            from gbl_JutePurchaseOrderDetails;
            
            Update gbl_JutePurchaseOrderdetails
            set orderserialno = lv_RecCount
            where rownum = c1.rownum;
        end if;
        
        if lv_Master.companycode is null then
            Update gbl_JutePurchaseOrderDetails
            set companycode = lv_Master.CompanyCode
            where rownum = c1.rownum;
        end if;    
        if lv_Master.DivisionCode is null then
            Update gbl_JutePurchaseOrderDetails
            set DivisionCode = lv_Master.DivisionCode
            where rownum = c1.rownum;
        end if;    
        
        lv_TotalBales := lv_TotalBales+nvl(c1.noofbales,0);
        lv_TotalWeight := lv_TotalWeight+nvl(c1.weightinkg,0);
        lv_OrderValue := lv_OrderValue+nvl(c1.GRADEAMOUNT,0);
    end loop;
    
    if NVL(lv_Master.Cancelled,'N') ='N' then        
        Update gbl_JutePurchaseOrdermaster
        set cancelled = 'N',
            CANCELLATIONDATE = NULL;    
        Update gbl_JutePurchaseOrderDetails
        set cancelled = 'N',
            CANCELLATIONDATE = NULL;    
    end if;    
    
    Update gbl_JutePurchaseOrdermaster
    set noofbales = nvl(lv_totalbales,0),
        OrderValue = lv_OrderValue,
        WeightInKg = lv_TotalWeight;

    IF nvl(lv_Master.ISDUMMY,'N') = 'Y' THEN 
                        
        Update gbl_JutePurchaseOrdermaster
        set LOCKED = 'YES' WHERE 1=1;
               
    END IF;
            
    if lv_Master.OperationMode = 'A' then
        insert into SYS_GBL_PROCOUTPUT_INFO
        values ('ORDER NUMBER : ' || lv_OrderNo || ' Dated : ' || lv_Master.OrderDate);
    end if;    
--    p_result:= lv_result;
    
--exception when others then
--    lv_error_remark:= lv_error_remark || '#UNSUCC#ESSFULL#';
--    raise_application_error(to_number(FN_DISPLAY_ERROR( 'COMMON')),FN_DISPLAY_ERROR( 'COMMON',6,lv_error_remark));
end;
/
