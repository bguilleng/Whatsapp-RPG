# Whatsapp RPG
Ejemplo de programa SQLRPGLE que utiliza los servicios HTTP de SQL DB2 (QSYS2.HTTP) en IBM i(AS/400) para demostrar cómo desarrollar estos servicios en el desarrollo de bots sobre AS/400.

El modelo del ejemplo implementa un bot de WhatsApp desarrollado completamente en SQLRPGLE sobre IBM i (AS/400), utilizando Db2 for i como repositorio de datos y una API REST para enviar los mensajes.

El funcionamiento general es el siguiente:

1. Inicio de la conversación
El usuario inicia la interacción (por ejemplo, enviando un mensaje como "Hola").
El mensaje es recibido por un proveedor de WhatsApp (o, en el ejemplo, insertado en la tabla BOT_INBOUND).

3. Procesamiento del mensaje
Un programa SQLRPGLE lee los mensajes pendientes.
Busca si el usuario ya tiene una sesión activa.
Si es un usuario nuevo, crea una nueva sesión y la inicializa en el menú principal.

5. Motor de conversación
Según el estado actual de la conversación y el mensaje recibido, el programa determina la siguiente acción.
Cada opción del menú representa un estado diferente del flujo.
El estado se guarda en la base de datos para poder continuar la conversación posteriormente.

7. Generación de la respuesta
El motor construye dinámicamente el mensaje que debe enviarse al usuario.
La respuesta se registra en la tabla BOT_OUTBOUND.

9. Envío por WhatsApp
Un segundo programa SQLRPGLE toma los mensajes pendientes de envío.
Construye la URL de la API REST.
Codifica correctamente el texto y los parámetros.
Invoca la API mediante QSYS2.HTTP_GET.
WhatsApp entrega el mensaje al usuario.

11. Auditoría y trazabilidad
Todas las conversaciones quedan registradas.
Se almacena el historial de mensajes enviados y recibidos.
También se conserva la respuesta de la API y el estado de cada envío.

Ventajas del modelo
100 % desarrollado en IBM i.
No requiere servidores adicionales para el motor de conversación.
Basado en SQLRPGLE y Db2 for i.
Conversaciones persistentes y recuperables.
Arquitectura modular y desacoplada.
Fácil de extender con nuevas opciones y procesos.
Registro completo para auditoría.
Integración mediante APIs REST estándar.
Evolución hacia un asistente empresarial con IA

Este modelo también constituye una base sólida para evolucionar hacia un asistente inteligente corporativo. En lugar de responder únicamente con opciones fijas, el motor de estados puede integrarse con:

Un modelo de IA (local o en la nube) para interpretar preguntas en lenguaje natural. 
Servicios empresariales (ERP, CRM, Core Bancario, WMS, RR. HH., etc.).

De esta forma, el mismo diseño pasa de ser un simple menú conversacional a un asistente empresarial inteligente capaz de responder consultas técnicas y de negocio utilizando el conocimiento extraído de los sistemas legacy.
