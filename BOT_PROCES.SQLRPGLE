**free
ctl-opt dftactgrp(*no) actgrp(*caller)
        option(*srcstmt:*nodebugio);

exec sql
  set option commit = *none,
             closqlcsr = *endmod,
             datfmt = *iso;

dcl-pi *n;
end-pi;

dcl-s inId        int(20);
dcl-s phone       varchar(30);
dcl-s msg         varchar(1000);
dcl-s state       varchar(30);
dcl-s sessionId   int(20);
dcl-s reply       varchar(2000);

dow '1' = '1';

   exec sql
      select IN_ID, PHONE_NUMBER, MESSAGE_TEXT
        into :inId, :phone, :msg
        from BOTWA.BOT_INBOUND
       where PROCESSED = 'N'
       order by CREATED_AT
       fetch first 1 row only;

   if sqlcode <> 0;
      leave;
   endif;

   exec sql
      select SESSION_ID, CURRENT_STATE
        into :sessionId, :state
        from BOTWA.BOT_SESSION
       where PHONE_NUMBER = :phone
         and STATUS = 'A'
       order by UPDATED_AT desc
       fetch first 1 row only;

   if sqlcode <> 0;
      exec sql
         insert into BOTWA.BOT_SESSION
            (PHONE_NUMBER, CURRENT_STATE)
         values
            (:phone, 'MENU');

      exec sql
         select identity_val_local()
           into :sessionId
           from sysibm.sysdummy1;

      state = 'MENU';
   endif;

   msg = %trim(msg);

   select;

   when %upper(msg) = 'HOLA'
     or %upper(msg) = 'MENU'
     or %trim(msg) = '0';

      reply =
         'Bienvenido al Bot IBM i' + x'25' +
         'Seleccione una opción:' + x'25' +
         '1. Consultar saldo' + x'25' +
         '2. Estado de solicitud' + x'25' +
         '3. Hablar con asesor' + x'25' +
         '0. Volver al menú';

      exec sql
         update BOTWA.BOT_SESSION
            set CURRENT_STATE = 'MENU',
                LAST_OPTION = null,
                UPDATED_AT = current_timestamp
          where SESSION_ID = :sessionId;

   when state = 'MENU' and msg = '1';

      reply = 'Ingrese el número de cuenta para consultar saldo:';

      exec sql
         update BOTWA.BOT_SESSION
            set CURRENT_STATE = 'WAIT_ACCOUNT',
                LAST_OPTION = '1',
                UPDATED_AT = current_timestamp
          where SESSION_ID = :sessionId;

   when state = 'WAIT_ACCOUNT';

      reply =
         'Cuenta recibida: ' + %trim(msg) + x'25' +
         'Saldo disponible: EUR 1.250,00' + x'25' +
         'Digite 0 para volver al menú.';

      exec sql
         update BOTWA.BOT_SESSION
            set CURRENT_STATE = 'MENU',
                UPDATED_AT = current_timestamp
          where SESSION_ID = :sessionId;

   when state = 'MENU' and msg = '2';

      reply = 'Ingrese el número de solicitud:';

      exec sql
         update BOTWA.BOT_SESSION
            set CURRENT_STATE = 'WAIT_REQUEST',
                LAST_OPTION = '2',
                UPDATED_AT = current_timestamp
          where SESSION_ID = :sessionId;

   when state = 'WAIT_REQUEST';

      reply =
         'Solicitud ' + %trim(msg) + ' se encuentra EN PROCESO.' + x'25' +
         'Digite 0 para volver al menú.';

      exec sql
         update BOTWA.BOT_SESSION
            set CURRENT_STATE = 'MENU',
                UPDATED_AT = current_timestamp
          where SESSION_ID = :sessionId;

   when state = 'MENU' and msg = '3';

      reply =
         'Su solicitud fue registrada.' + x'25' +
         'Un asesor lo contactará próximamente.' + x'25' +
         'Digite 0 para volver al menú.';

      exec sql
         insert into BOTWA.BOT_LOG
            (PHONE_NUMBER, EVENT_TYPE, EVENT_TEXT)
         values
            (:phone, 'ASESOR', 'Usuario solicita asesor');

      exec sql
         update BOTWA.BOT_SESSION
            set CURRENT_STATE = 'MENU',
                LAST_OPTION = '3',
                UPDATED_AT = current_timestamp
          where SESSION_ID = :sessionId;

   other;

      reply =
         'Opción no válida.' + x'25' +
         'Seleccione:' + x'25' +
         '1. Consultar saldo' + x'25' +
         '2. Estado de solicitud' + x'25' +
         '3. Hablar con asesor' + x'25' +
         '0. Volver al menú';

      exec sql
         update BOTWA.BOT_SESSION
            set CURRENT_STATE = 'MENU',
                UPDATED_AT = current_timestamp
          where SESSION_ID = :sessionId;

   endsl;

   exec sql
      insert into BOTWA.BOT_OUTBOUND
         (PHONE_NUMBER, MESSAGE_TEXT)
      values
         (:phone, :reply);

   exec sql
      update BOTWA.BOT_INBOUND
         set PROCESSED = 'Y'
       where IN_ID = :inId;

enddo;

return;