**free
ctl-opt dftactgrp(*no) actgrp(*caller)
        option(*srcstmt:*nodebugio)
        bnddir('QC2LE');

//
// Programa: whtspapi
// Tipo    : SQLRPGLE
// Objetivo: Enviar mensaje WhatsApp usando CallMeBot API
//
// Parámetros:
//   1. Teléfono destino  Ej: +34123123123
//   2. Mensaje           Ej: This is a test from IBM i
//   3. API Key           Ej: 1234567890
//   4. Código retorno    0=OK / 1=Error
//   5. Respuesta API
//

exec sql
  set option commit = *none,
             closqlcsr = *endmod,
             datfmt = *iso;

dcl-pi *n;
   pPhone     varchar(20)   const;
   pText      varchar(1000) const;
   pApiKey    varchar(50)   const;
   pRetCode   int(10);
   pResponse  varchar(5000);
end-pi;

dcl-s url        varchar(4000);
dcl-s encPhone   varchar(500);
dcl-s encText    varchar(3000);
dcl-s encKey     varchar(500);
dcl-s apiBase    varchar(200);
dcl-s sqlState   char(5);
dcl-s sqlMsg     varchar(1000);

pRetCode = 1;
pResponse = '';

apiBase = 'https://api.callmebot.com/whatsapp.php';

//
// Validaciones básicas
//
if %trim(pPhone) = '';
   pResponse = 'ERROR: teléfono vacío';
   return;
endif;

if %trim(pText) = '';
   pResponse = 'ERROR: mensaje vacío';
   return;
endif;

if %trim(pApiKey) = '';
   pResponse = 'ERROR: API key vacía';
   return;
endif;

//
// Codificar parámetros URL.
// Muy importante: el texto puede contener espacios, tildes, &, ?, etc.
//
exec sql
   values QSYS2.URL_ENCODE(:pPhone)
   into :encPhone;

exec sql
   values QSYS2.URL_ENCODE(:pText)
   into :encText;

exec sql
   values QSYS2.URL_ENCODE(:pApiKey)
   into :encKey;

url = %trim(apiBase)
    + '?phone='  + %trim(encPhone)
    + '&text='   + %trim(encText)
    + '&apikey=' + %trim(encKey);

//
// Invocar API por HTTP GET
//
exec sql
   values QSYS2.HTTP_GET(
      :url,
      '{"headers":{"Accept":"text/plain"}}'
   )
   into :pResponse;

if sqlcode = 0;
   pRetCode = 0;
else;
   sqlState = sqlstate;
   sqlMsg = 'SQLCODE=' + %char(sqlcode)
          + ' SQLSTATE=' + sqlState;
   pResponse = 'ERROR llamando CallMeBot. ' + sqlMsg;
   pRetCode = 1;
endif;

return;