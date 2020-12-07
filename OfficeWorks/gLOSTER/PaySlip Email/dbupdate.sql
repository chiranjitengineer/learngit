DROP TYPE LISTAGGIMPL1;

CREATE OR REPLACE TYPE "LISTAGGIMPL1"                                          as object
    (
      concatlist clob,
      static function ODCIAggregateInitialize(sctx IN OUT LISTAGGIMPL1) 
        return number,
      member function ODCIAggregateIterate(self IN OUT LISTAGGIMPL1, 
        value IN VARCHAR2  ) return number,
      member function ODCIAggregateTerminate(self IN LISTAGGIMPL1, 
        returnValue OUT CLOB, flags IN number) return number,
       member function ODCIAggregateMerge(self IN OUT LISTAGGIMPL1, 
        ctx2 IN LISTAGGIMPL1) return number
    );
/


DROP TYPE BODY LISTAGGIMPL1;

CREATE OR REPLACE TYPE BODY "LISTAGGIMPL1" is 
    static function ODCIAggregateInitialize(sctx IN OUT LISTAGGIMPL1) 
    return number is 
    begin
      --sctx := LISTAGGIMPL(0, 0);
      sctx := LISTAGGIMPL1('');
      return ODCIConst.Success;
    end;
    member function ODCIAggregateIterate(self IN OUT LISTAGGIMPL1, value IN VARCHAR2) 
    return number is
    begin
      if ( value <> chr(32) and value is not null ) then
       if length(to_char(value)) = 1 then
        self.concatlist := ltrim(trim(self.concatlist)) ;     
       else
        self.concatlist := ltrim(trim(self.concatlist))||value ;
       end if;  
      end if;
      return ODCIConst.Success;
    end;

    member function ODCIAggregateTerminate(self IN LISTAGGIMPL1, returnValue OUT 
    CLOB, flags IN number) return number is
    begin      
      returnValue := substr(self.concatlist,1,(length(self.concatlist)-1)) ;
      returnValue :=  fn_sort_list( returnValue,';' , substr(self.concatlist,-1)) ;
      return ODCIConst.Success;
    end;

   member function ODCIAggregateMerge(self IN OUT LISTAGGIMPL1, ctx2 IN 
    LISTAGGIMPL1) return number is
    begin     
      return ODCIConst.Success;
    end; 
end;
/

