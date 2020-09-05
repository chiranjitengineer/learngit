CREATE OR REPLACE function BIRLANEW.fmtAlign
(
    p_text varchar2,
    p_lenth number,
    p_align varchar2,
    p_decimalplace number default null,
    p_paddinText varchar2 default ' '
)
return varchar2
as
    lv_strlen1 number;
    lv_len number;
    lv_number number;
    lv_retstr varchar2(1000);
begin

--    select fmtAlign('123456789.123456789',200,'C',1) from dual;

--    p_text := '123456789.123456789';
--    p_text := '0.789123454544454';
--    p_text := '0';
----    p_text := 'sdfsafsaf';
--    p_lenth := 200;
--    p_decimalplace := 3;
--    p_align := 'c';

    lv_strlen1 := 0;
    
 begin   
    lv_number := to_number(p_text);
    
    lv_strlen1:= instr(p_text,'.');
    
    
--    dbms_output.put_line(p_text||' dd '||lv_strlen1);
    
    
    
    if p_decimalplace is null then
        lv_retstr := p_text;
    else
        if lv_strlen1 = 1 then
            lv_strlen1:= lv_strlen1;
        elsif lv_strlen1 > 1 then
            lv_strlen1:= lv_strlen1-1;
        else
            lv_strlen1:= length(p_text);
        end if;
        
        if(p_decimalplace = 0) then
            lv_retstr := substr(p_text,1, lv_strlen1);
        else
            lv_retstr := to_char(lv_number,lpad('0',lv_strlen1,'0')||'.'||lpad('0',p_decimalplace,'9'));
        end if;
    end if;
 exception when others then
    lv_retstr := p_text;
 end;
 
 
 
 lv_retstr := nvl(trim(lv_retstr),p_paddinText);
 
 if upper(p_align) = 'R' then
    lv_retstr := lpad(lv_retstr,p_lenth,p_paddinText);
 elsif upper(p_align) = 'L' then
    lv_retstr := rpad(lv_retstr,p_lenth,p_paddinText);
else
    --lv_retstr := rpad(lv_retstr,p_lenth);
    
    lv_len := p_lenth - length(lv_retstr);
    
    if( lv_len > 0 ) then
        lv_len := round(lv_len/2,0);
--        dbms_output.put_line(lv_len||'  '||lv_retstr);

        if(length(lv_retstr)+2*lv_len)>p_lenth then
            lv_retstr := rpad(p_paddinText,lv_len,p_paddinText)||lv_retstr||lpad(p_paddinText,lv_len-1,p_paddinText);
        else
            lv_retstr := rpad(p_paddinText,lv_len,p_paddinText)||lv_retstr||lpad(p_paddinText,lv_len,p_paddinText);
        end if;
    end if;
    
end if;


return lv_retstr;
--    dbms_output.put_line(lv_strlen1||'  '||lv_retstr);
end;
/