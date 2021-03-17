DROP PROCEDURE NJMCL_WEB.PROC_INS_WPSABSENT;

CREATE OR REPLACE PROCEDURE NJMCL_WEB.proc_ins_wpsabsent(p_companycode varchar,p_divisioncode varchar, p_From_Dt varchar2, p_absent_dt varchar) as
--,wrksrl varchar
--,wrksrl varchar
lv_shiftcode varchar2(10);
lv_lwd date ;
lv_lwd_letry date ;
lv_lwd_letry_Fr date ;
lv_lwd_temp_DOA date ;
lv_lwd_budli date ;
lv_leavefr date;
lv_cshift char(1);
lv_temp_workerserial varchar2(10);
lv_WorkerSerial     varchar2(10);
lv_WorkerSerial1     varchar2(10);
lv_TokenNo1          varchar2(10);
lv_DOA               date;
lv_temp1             varchar2(60);
lv_temp2             varchar2(60);
lv_temp3             varchar2(60);
lv_temp4             varchar2(60);
lv_DOA_PREV          date;
lv_DOA_PREV_W        date;
lv_DOA_PREV_U        date;
lv_DOA_PREV_Z        date;
lv_ShiftCode_PREV   varchar2(3);
lv_StatusCode       varchar2(3);
lv_Temp_StatusCode  varchar2(3);
lv_Temp_Status      varchar2(3);
lv_Prev_StatusCode  varchar2(3);
lv_LastShiftCode    varchar2(3);
lv_lastDOA          date;
lv_CheckDT          date;
lv_LastStausCode    varchar2(3);
lv_boolinsert         boolean;
lv_shiftcode_budli  varchar2(10);
--lv_WorkerSerial        varchar2(10);
lv_TokenNo            varchar2(10);
lv_SqlErrM            varchar2(500);

begin
  DBMS_OUTPUT.PUT_LINE(to_char(sysdate,'HH:MI:SS AM'));
  delete from WPSABSENT_JOINT  ;
  insert into WPSABSENT_JOINT
  ---------- INSERT STL AND LEAVE DATA IN WPSABSENT_JOINT REPORT --------
  SELECT 'XXXX' SECTIONCODE, A.WORKERSERIAL, A.TOKENNO, 'A' PSHIFT, 'A' CSHIFT,
  'STL' STATUSCODE, STLFROMDATE LEAVEFROM, STLTODATE LEAVETO
  FROM WPSSTLENTRY A
  WHERE COMPANYCODE =p_companycode AND DIVISIONCODE = p_divisioncode
  AND A.STLFROMDATE <= TO_DATE(p_absent_dt,'DD/MM/YYYY')
  AND A.STLTODATE >= TO_DATE(p_absent_dt,'DD/MM/YYYY');
--  UNION ALL
--  SELECT 'XXXX' SECTIONCODE, A.WORKERSERIAL, A.TOKENNO, 'A' PSHIFT, 'A' CSHIFT,
--  A.DOCUMENTTYPE STATUSCODE,A.LEAVEFROMDATE LEAVEFROM, A.LEAVETODATE LEAVETO
--  FROM WPSLEAVEENTRY A
--  WHERE COMPANYCODE = p_companycode AND DIVISIONCODE = p_divisioncode
--  AND LEAVEFROMDATE <= TO_DATE(p_absent_dt,'DD/MM/YYYY')
--  AND LEAVETODATE >= TO_DATE(p_absent_dt,'DD/MM/YYYY') ;

  FOR C1 IN (
  SELECT 'XXXX' SECTIONCODE, A.WORKERSERIAL, B.TOKENNO,B.GROUPCODE PSHIFT , --, DECODE(B.SHIFTCODE,'1','A',DECODE(B.SHIFTCODE,'2','B','C')) SHIFTCODE,
  A.STATUSCODE, A.LEAVETO
  FROM (
            SELECT A.WORKERSERIAL, /*A.TOKENNO, B.GROUPCODE,-*/  A.STATUSCODE, A.DATEOFATTENDANCE LEAVETO
            FROM WPSATTENDANCEDAYWISE A --,WPSWORKERMAST B
            WHERE A.COMPANYCODE = p_companycode
             AND A.DIVISIONCODE = p_divisioncode
             AND A.DATEOFATTENDANCE=TO_DATE(p_absent_dt,'DD/MM/YYYY')
             AND A.STATUSCODE='U'
             AND A.TOKENNO IS NOT NULL
            MINUS
            SELECT A.WORKERSERIAL, /*A.TOKENNO,  B.GROUPCODE,  */ 'U' STATUSCODE, A.DATEOFATTENDANCE LEAVETO
            FROM WPSATTENDANCEDAYWISE A
            WHERE A.COMPANYCODE = p_companycode 
              AND A.DIVISIONCODE = p_divisioncode
              AND A.DATEOFATTENDANCE=TO_DATE(p_absent_dt,'DD/MM/YYYY')
              AND A.STATUSCODE <>'U'
              AND A.TOKENNO IS NOT NULL
              -- NOT FOUND
--            MINUS
--            SELECT A.WORKERSERIAL, /*A.TOKENNO,  B.GROUPCODE, */'Z' STATUSCODE, A.DATEOFATTENDANCE LEAVETO
--            FROM WPSBUDLIATTENDANCE A
--            WHERE A.COMPANYCODE = p_companycode
--              AND A.DIVISIONCODE = p_divisioncode
--              AND A.DATEOFATTENDANCE=TO_DATE(p_absent_dt,'DD/MM/YYYY')
--              AND A.TOKENNO IS NOT NULL
              -- NOT FOUND
            MINUS
            SELECT A.WORKERSERIAL, /*A.TOKENNO, 'GR' GROUPCODE, */ 'U' STATUSCODE, TO_DATE(p_absent_dt,'DD/MM/YYYY') LEAVETO
            FROM WPSSTLENTRY A
            WHERE A.COMPANYCODE = p_companycode
              AND A.DIVISIONCODE = p_divisioncode
              AND A.STLFROMDATE <= TO_DATE(p_absent_dt,'DD/MM/YYYY')
              AND A.STLTODATE >= TO_DATE(p_absent_dt,'DD/MM/YYYY')
                            -- NOT FOUND
--            MINUS
--            SELECT A.WORKERSERIAL, /*A.TOKENNO, 'GR' GROUPCODE, */ 'U' STATUSCODE, TO_DATE(p_absent_dt,'DD/MM/YYYY') LEAVETO
--            FROM WPSLEAVEENTRY A
--            WHERE A.COMPANYCODE = p_companycode
--              AND A.DIVISIONCODE = p_divisioncode
--              AND A.LEAVEFROMDATE <= TO_DATE(p_absent_dt,'DD/MM/YYYY')
--              AND A.LEAVETODATE >= TO_DATE(p_absent_dt,'DD/MM/YYYY')
              -- NOT FOUND
            UNION
            SELECT A.WORKERSERIAL, /*A.TOKENNO, A.GROUPCODE, */ A.STATUSCODE, A.DATEOFATTENDANCE LEAVETO
            FROM WPSATTENDANCEDAYWISE A
            WHERE A.COMPANYCODE = p_companycode 
              AND A.DIVISIONCODE = p_divisioncode
              AND A.DATEOFATTENDANCE=TO_DATE(p_absent_dt,'DD/MM/YYYY')
              AND A.STATUSCODE='W'
              AND A.TOKENNO IS NOT NULL
        ) A, WPSWORKERMAST B 
        WHERE B.COMPANYCODE = p_companycode AND B.DIVISIONCODE = p_divisioncode
        AND A.WORKERSERIAL = B.WORKERSERIAL
        ----AND A.WORKERSERIAL ='01979'---lv_WorkerSerial1
        order by a.workerserial )
  LOOP
      begin
        lv_WorkerSerial    := c1.workerserial;
        lv_TokenNo        := c1.TokenNo;

        begin
            lv_Prev_StatusCode := null;
            lv_DOA_PREV := null;
            lv_DOA_PREV_U:=NULL;
            lv_ShiftCode_PREV := null;
            lv_lastDOA := null;
            lv_LastShiftCode := null;
            lv_lwd_budli := null;
            lv_lwd_letry := null;
            lv_lwd := null;
            lv_temp_workerserial :=null;
            lv_ShiftCode  := null;
            lv_temp1       :=null;
            lv_temp2       :=null;
            lv_temp3       :=null;
            lv_Temp_StatusCode:=NULL;
            lv_Temp_Status    :=NULL;
            lv_CheckDT := NULL;
           -- lv_DOA_PREV_W:=NULL;
            lv_lwd_temp_DOA:=null;
            BEGIN
             --IF c1.statuscode='W' then
              --lv_Temp_StatusCode:='U';
            --ELSE
                 lv_Temp_StatusCode:=C1.STATUSCODE;
            ----END IF;
            --NULL;
            END;


            For  c2 in (
            --select  /*+ INDEX(A.IDX_ATTN_ULREPORT ) */ workerserial, tokenno, dateofattendance, sectioncode,shiftcode, statuscode
            select  /*+ INDEX(A.IDX_ATTN_ULREPORT) */  workerserial, /*tokenno,*/ dateofattendance, sectioncode,shiftcode,
            DECODE(A.statuscode,'U',A.STATUSCODE,DECODE(A.STATUSCODE,'W',A.STATUSCODE,'Z'))STATUSCODE, A.STATUSCODE ORG_STATUSCODE
            from WPSATTENDANCEDAYWISE A
            WHERE A.COMPANYCODE =  p_companycode
              AND A.DIVISIONCODE = p_divisioncode
              AND A.WORKERSERIAL = C1.WORKERSERIAL
              AND A.WORKERSERIAL =lv_WorkerSerial
              AND A.TOKENNO IS NOT NULL
              AND A.DATEOFATTENDANCE >= TO_DATE(p_From_Dt,'dd/mm/yyyy')        ---- due to system start from 01.08.2011
              AND A.DATEOFATTENDANCE <= TO_DATE(p_absent_dt,'dd/mm/yyyy')
            --AND NVL(A.STATUSCODE,'ZZ') <> 'U'
            order by dateofattendance desc, shiftcode desc)   -- UNCOMMENTED BY PRASUN
            -- NOT FOUND
--            UNION ALL
--            SELECT /*+ INDEX(A.IDX_BUDLI_ATTEND_DESC) */ A.WORKERSERIAL, /*A.TOKENNO,*/ A.DATEOFATTENDANCE, A.SECTIONCODE,A.SHIFTCODE, 'Z' STATUSCODE, 'Z' ORG_STATUSCODE
--                        from WPSBUDLIATTENDANCE A
--                        WHERE A.COMPANYCODE =  p_companycode 
--                          AND A.DIVISIONCODE = p_divisioncode
--                         AND A.WORKERSERIAL = C1.WORKERSERIAL
--                        AND A.WORKERSERIAL =lv_WorkerSerial
--                        --AND A.WORKERSERIAL = '12101'
--                        AND A.DATEOFATTENDANCE >= TO_DATE(p_From_Dt,'dd/mm/yyyy')        ---- due to system start from 01.08.2011
--                        AND A.DATEOFATTENDANCE <= TO_DATE(p_absent_dt,'dd/mm/yyyy')
--                        AND A.TOKENNO IS NOT NULL
--                        AND A.DATEOFATTENDANCE <= TO_DATE('15/12/2011','dd/mm/yyyy')
--            order by dateofattendance desc,STATUSCODE DESC, shiftcode desc)
            -- NOT FOUND
         --lv_CheckDT := NULL;
         loop


          ---lv_Temp_Status:=NULL;
          lv_boolinsert:=true;

          if c2.statuscode='W' AND C2.dateofattendance=TO_DATE(p_absent_dt,'dd/mm/yyyy') then  ----FOR RUNNING  ON THE WEEKOFDAY
            --DBMS_OUTPUT.PUT_LINE('INSIDE STATUS CODE - W AND  - ');
            lv_temp2:='W';
           lv_DOA_PREV_W:=C2.dateofattendance;
          end if;
          ------------
          if c2.statuscode='W' then
            lv_temp3:=C2.dateofattendance;
          end if;
          --DBMS_OUTPUT.PUT_LINE('MY-WPREVDATE'||lv_temp2||'-'||lv_DOA_PREV_W);
          
            --DBMS_OUTPUT.PUT_LINE('MY-WPREVDATE'||lv_temp2);

          if c2.StatusCode = 'W' then
              if lv_temp1 = 'U' then
                  lv_Prev_StatusCode := lv_temp1;
                  lv_ShiftCode_PREV := lv_ShiftCode_PREV;
                  lv_DOA_PREV := lv_DOA_PREV;
                  lv_DOA_PREV_U:=lv_DOA_PREV;
                  lv_temp1 := null;
              else
                  lv_Prev_StatusCode := c2.StatusCode;
                  lv_DOA_PREV := c2.dateofattendance;
                  lv_lwd_temp_DOA:=lv_DOA_PREV;--for running on dayoffday
                  lv_ShiftCode_PREV := c2.shiftcode;
                  --lv_temp1 := c2.StatusCode;
                  lv_temp1 := null;
              end if;

              lv_temp1 := null;

          elsif c2.StatusCode = 'U' then

            if c2.dateofattendance <> nvl(lv_checkDT,to_date('01/01/1975','dd/mm/yyyy')) then       --- null date not check the condition, so imaginary like '01/01/1975 replace with null date
                lv_DOA_PREV := c2.dateofattendance;
                lv_temp1 := c2.StatusCode;
                lv_Prev_StatusCode := c2.StatusCode;
                lv_WorkerSerial1:=c2.workerserial;
                lv_temp4:= c2.dateofattendance;  ---for use in case before weekoff is UL
                ----

               -- DBMS_OUTPUT.PUT_LINE ('lv_temp4'||lv_temp4||'doa_prev'||lv_DOA_PREV);
            end if;
                 

          elsif c2.StatusCode = 'Z' then
             if lv_Prev_StatusCode = 'U'   then  ---added on 0509 or lv_Prev_StatusCode = 'W
                    lv_Temp_Status:='U';
                    lv_lastDOA := lv_DOA_PREV;
                    EXIT;

             elsif  lv_Prev_StatusCode = 'W' then
                    IF LENGTH(lv_DOA_PREV_U)>0 THEN
                        lv_lastDOA := lv_DOA_PREV_U;------lv_DOA_PREV;
                    ELSE
                        lv_lastDOA := lv_DOA_PREV;
                    END IF;
            
                  EXIT;
             ELSE
                lv_boolinsert:=false;
                EXIT;
            end if;
            lv_CheckDT := c2.dateofattendance;

          end if;

          --DBMS_OUTPUT.PUT_LINE ('Check Date '||lv_CheckDT);

         --DBMS_OUTPUT.PUT_LINE ('Previous Status Code - '||lv_Prev_StatusCode);

          --------------FOR RUNNING the report ON THE WEEKOFDAY
          if c2.StatusCode = 'U' then
           if lv_temp2='W'  THEN
                --DBMS_OUTPUT.PUT_LINE ('before cond check INSID LV_TEMP2=W,TEMP STATUS CODE '||lv_Temp_Status);
                -- START ADD BY AMALESH ON 29.09.2012 -------
                IF lv_temp2='W' and lv_DOA_PREV = c2.dateofattendance  then
                    lv_Temp_Status:='W';
                    --lv_LastDOA:=lv_DOA_PREV;
                else
                    lv_Temp_Status:='U';
                end if;

                --DBMS_OUTPUT.PUT_LINE ('After cond. check  INSID LV_TEMP2=W,TEMP STATUS CODE '||lv_Temp_Status);
                --lv_Temp_Status:='U';----FOR RUNNING  ON THE WEEKOFDAY
                -- END ADD BY AMALESH ON 29.09.2012 -------
            end if;


            --DBMS_OUTPUT.PUT_LINE ('lv_temp2 '||lv_temp2||' lv_Temp_Status'||lv_Temp_Status);
          end if;
          --------------FOR RUNNING the report ON THE WEEKOF
          lv_checkDT := c2.dateofattendance;


         end loop;

         --DBMS_OUTPUT.PUT_LINE('exit loop :- lv_temp1 '||lv_temp1||' , Prev. status code '||lv_Prev_StatusCode||' , DOA Prev. '||lv_DOA_PREV||' last DOA '||lv_LASTDOA);
            lv_ShiftCode := lv_LastShiftCode;
            lv_lwd := lv_LastDOA;
--            if length(lv_lwd_temp_DOA)>0 then
--                lv_lwd:=lv_lwd_temp_DOA;
--            ELSE
--                lv_lwd := lv_LastDOA;
--            end if;


--

            /*if c1.TokenNo='41280' then
                DBMS_OUTPUT.PUT_LINE(' Worker Serial - '||lv_WorkerSerial||' Token - '||lv_TokenNo||' last Date/shift :'||lv_lwd||'/'||lv_ShiftCode);
            end if; */

        exception
             when others then
                   lv_SqlErrM := sqlerrm;
--                  DBMS_OUTPUT.PUT_LINE(' Worker Serial - '||lv_WorkerSerial||' Token - '||lv_TokenNo||' Exception 1 :'||lv_SqlErrM );
                  null;

        end;
          --- max shift xx working date from  WPSBUDLIATTENDANCE --

-- NOT FOUND

--        begin
--            SELECT  MAX(A.SHIFTCODE) , MAX(A.DATEOFATTENDANCE)
--            into lv_shiftcode_budli , lv_lwd_budli
--            FROM WPSBUDLIATTENDANCE A
--            WHERE A.COMPANYCODE = p_companycode AND A.DIVISIONCODE = p_divisioncode
--            AND A.DATEOFATTENDANCE >= TO_DATE(p_From_Dt,'dd/mm/yyyy')
--            AND A.DATEOFATTENDANCE <= TO_DATE(p_absent_dt,'dd/mm/yyyy')
--            AND A.WORKERSERIAL = A.WORKERSERIAL
--            AND A.WORKERSERIAL = C1.WORKERSERIAL
--            AND A.TOKENNO IS NOT NULL
--            GROUP BY A.WORKERSERIAL, A.TOKENNO ;
--          exception
--             when others then
--               lv_SqlErrM := sqlerrm;
----               DBMS_OUTPUT.PUT_LINE(' Worker Serial - '||lv_WorkerSerial||' Token - '||lv_TokenNo||' Exception 2 :'||lv_SqlErrM );
--              null;
--         end;
--
--         --DBMS_OUTPUT.PUT_LINE('MY-LVBUDLI'||lv_lwd_budli);
--
--        if  NVL(lv_lwd_budli,TO_DATE(p_From_Dt,'DD/MM/YYYY')) >  lv_lwd then
--            /*if c1.TokenNo='41280' then
--                DBMS_OUTPUT.PUT_LINE(' Worker Serial - '||lv_WorkerSerial||' Token - '||lv_tokenno||' budli date greate than last attn date, Budli Date - '||lv_lwd_budli);
--            end if; */
--            lv_lwd := lv_lwd_budli ;
--        end if;
--        -----  to check whether leave from entry exists is WPSLEAVEENTRY if exists and gt attendaywise leavefrom date the it is considered as lesvre from data ---
        
---               

       
--        begin
--            SELECT max(LEAVETODATE) into lv_lwd_letry
--                FROM WPSLEAVEENTRY A
--                WHERE A.COMPANYCODE = p_companycode AND A.DIVISIONCODE = p_divisioncode
--                AND A.LEAVEFROMDATE >= TO_DATE(p_From_Dt,'dd/mm/yyyy')
--                AND LEAVEFROMDATE <= TO_DATE(p_absent_dt,'dd/mm/yyyy')
--               --- AND LEAVETODATE >= TO_DATE(p_absent_dt,'DD/MM/YYYY')
--               and A.WORKERSERIAL = C1.WORKERSERIAL
--               group by workerserial,tokenno ;
--          exception
--             when others then
--               lv_SqlErrM := sqlerrm;
----               DBMS_OUTPUT.PUT_LINE(' Worker Serial - '||lv_WorkerSerial||' Token - '||lv_TokenNo||' Exception 3 :'||lv_SqlErrM );
--              null;
--
--         end;
--         --DBMS_OUTPUT.PUT_LINE(' CHECKING BUDLI :- lv_lwd_budli - '||lv_lwd_budli||', lv_lwd - '||lv_lwd);
--            --DBMS_OUTPUT.PUT_LINE('CHECKING LEAVE :- lv_lwd_letry - '||lv_lwd_letry||', lv_lwd - '||lv_lwd);
--            if NVL(lv_lwd_letry,TO_DATE(p_From_Dt,'DD/MM/YYYY')) > lv_lwd then
--               -----lv_lwd := lv_lwd_letry_Fr ;
--                --if c1.TokenNo='41481' then
--                  --DBMS_OUTPUT.PUT_LINE(' Worker Serial - '||lv_WorkerSerial||' Token - '||lv_tokenno||' leave date greate than last attn date, leave Date'||lv_lwd_letry);
--                --end if;
--              lv_lwd := lv_lwd_letry ;
--            end if;
--
--             IF lv_lwd IS NULL  THEN
--                lv_lwd:=TO_DATE(p_From_Dt,'DD/MM/YYYY');
--            END IF;
--
--           -- DBMS_OUTPUT.PUT_LINE(' CHECKING CASE :- lv_lwd - '||lv_lwd||', ABSENT DATE - '||p_absent_dt);
--            select CASE WHEN lv_lwd >= TO_DATE(p_absent_dt,'DD/MM/YYYY') THEN  lv_lwd   ELSE lv_lwd  END into lv_leavefr from dual;
--            ---DBMS_OUTPUT.PUT_LINE(' CHECKING CASE LEAVEFROM :- '||lv_leavefr);
--
----             IF lv_Temp_Status='W' THEN
----                 lv_leavefr:=TO_DATE(p_absent_dt,'DD/MM/YYYY');
----             END IF;
--
--
--             select DECODE(lv_shiftcode,'1','A',DECODE(lv_shiftcode,'2','B','C')) into lv_cshift from dual ;
--
--
--             --DBMS_OUTPUT.PUT_LINE('MYfinal-lengthLVTEMPSTSTUS - '||LENGTH(lv_Temp_Status)||' TEMPSTATUS - '||lv_Temp_Status||' Leave from '||lv_leavefr||' Shift Code '||lv_cshift);
--             --DBMS_OUTPUT.PUT_LINE('MYfinal-lengthLVTEMPSTSTUS - '||LENGTH(lv_Temp_Status)||' Leave from '||lv_leavefr||' Shift Code '||lv_cshift);
--             --DBMS_OUTPUT.PUT_LINE('BOOLVALUE'||lv_boolinsert);
--            if lv_boolinsert= true then
--                IF LENGTH(lv_Temp_Status)>0 THEN
--                    insert into WPSABSENT_JOINT values( c1.sectioncode , c1.workerserial,c1.tokenno, c1.pshift,lv_cshift,lv_Temp_Status,lv_leavefr ,c1.LEAVETO );
--                    --DBMS_OUTPUT.PUT_LINE('STATUS TEMP - '||lv_Temp_Status);
--                    lv_Temp_Status:=null;
--                ELSE
--                 insert into WPSABSENT_JOINT values( c1.sectioncode , c1.workerserial,c1.tokenno, c1.pshift,lv_cshift,C1.STATUSCODE,lv_leavefr ,c1.LEAVETO );
--                 --DBMS_OUTPUT.PUT_LINE('STATUS TABLE- '||C1.STATUSCODE);
--                END IF;
--
--           end if;

              -- DBMS_OUTPUT.PUT_LINE(' AFTERXFINEMPSTATUSWorker Serial - '||lv_Temp_Status);

---               -- NOT FOUND

      exception
         when others then
           lv_SqlErrM := sqlerrm;
           DBMS_OUTPUT.PUT_LINE(' Worker Serial - '||lv_WorkerSerial||' Token - '||lv_TokenNo||' Exception last :'||lv_SqlErrM );
          null;
      end;
END LOOP;
COMMIT;
DBMS_OUTPUT.PUT_LINE(to_char(sysdate,'HH:MI:SS AM'));
exception
when others then
   DBMS_OUTPUT.PUT_LINE(sqlerrm);
end;
/


