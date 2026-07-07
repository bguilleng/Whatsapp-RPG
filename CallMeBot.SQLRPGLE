**free
ctl-opt dftactgrp(*no) actgrp(*caller)
        option(*srcstmt:*nodebugio);

exec sql
  set option commit = *none,
             closqlcsr = *endmod,
             datfmt = *iso;

dcl-pi *n;
end-pi;

dcl-s outId       int(20);
dcl-s phone       varchar(30);
dcl-s textMsg     varchar(2000);
dcl-s apiKey      varchar(100);
dcl-s url         varchar(5000);
dcl-s encPhone    varchar(500);
dcl-s encText     varchar(4000);
dcl-s encKey      varchar(500);
dcl-s response    varchar(5000);

dow '1' = '1';

   exec sql
      select OUT_ID, PHONE_NUMBER, MESSAGE_TEXT
        into :outId, :phone, :textMsg
        from BOTWA.BOT_OUTBOUND
       where SENT_STATUS = 'N'
       order by CREATED_AT
       fetch first 1 row only;

   if sqlcode <> 0;
      leave;
   endif;

   exec sql
      select API_KEY
        into :apiKey
        from BOTWA.BOT_CONFIG
       where ACTIVE = 'Y'
       fetch first 1 row only;

   exec sql
      values QSYS2.URL_ENCODE(:phone)
      into :encPhone;

   exec sql
      values QSYS2.URL_ENCODE(:textMsg)
      into :encText;

   exec sql
      values QSYS2.URL_ENCODE(:apiKey)
      into :encKey;

   url = 'https://api.callmebot.com/whatsapp.php'
       + '?phone='  + %trim(encPhone)
       + '&text='   + %trim(encText)
       + '&apikey=' + %trim(encKey);

   exec sql
      values QSYS2.HTTP_GET(:url)
      into :response;

   if sqlcode = 0;
      exec sql
         update BOTWA.BOT_OUTBOUND
            set SENT_STATUS = 'Y',
                API_RESPONSE = :response,
                SENT_AT = current_timestamp
          where OUT_ID = :outId;
   else;
      response = 'ERROR SQLCODE=' + %char(sqlcode) +
                 ' SQLSTATE=' + sqlstate;

      exec sql
         update BOTWA.BOT_OUTBOUND
            set SENT_STATUS = 'E',
                API_RESPONSE = :response,
                SENT_AT = current_timestamp
          where OUT_ID = :outId;
   endif;

enddo;

return;