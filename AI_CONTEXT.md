# FIMSS — Contexto del Proyecto

## 1. Identidad del proyecto

**Nombre:** FIMSS

**Significado:** Sistema de filas virtuales para servicios del IMSS.

**Tipo de proyecto:** Aplicación multiplataforma desarrollada con Flutter.

**Repositorio oficial:**
https://github.com/JOANLORETO/FIMSS

---

## 2. Objetivo de FIMSS

FIMSS busca permitir que los usuarios puedan obtener y consultar un turno para ser atendidos en una unidad del IMSS sin tener que permanecer físicamente en una fila.

La aplicación utiliza una lógica de filas virtuales para mostrar al usuario su turno y la cantidad de personas que están esperando.

El objetivo es crear una aplicación profesional, sencilla de utilizar y preparada para funcionar en dispositivos móviles, principalmente Android y iOS.

---

## 3. Tecnologías principales

FIMSS está desarrollado utilizando:

* Flutter
* Dart
* Supabase
* PostgreSQL mediante Supabase
* `supabase_flutter`
* `mobile_scanner`
* `shared_preferences`
* `http`

El proyecto debe mantenerse multiplataforma siempre que sea técnicamente posible.

Plataformas actualmente presentes en el proyecto:

* Android
* iOS
* macOS
* Web
* Windows
* Linux

---

## 4. Arquitectura general

La aplicación Flutter contiene la interfaz de usuario y la lógica de interacción con el usuario.

Supabase funciona como backend y base de datos.

La aplicación consulta y modifica información relacionada con:

* Unidades
* Servicios
* Colas
* Turnos

La comunicación con Supabase se realiza desde Flutter mediante `supabase_flutter`.

---

## 5. Base de datos

Las tablas principales utilizadas por FIMSS son:

### `unidades`

Contiene información de las unidades donde se prestan los servicios.

### `servicios`

Contiene los servicios disponibles.

### `colas`

Representa las filas virtuales asociadas a una unidad y servicio.

### `turnos`

Contiene los turnos obtenidos por los usuarios y la información necesaria para controlar la fila virtual.

---

## 6. Identificación del usuario

FIMSS contempla el uso de información como:

* NSS
* CURP

El NSS es especialmente importante para identificar al usuario y controlar sus turnos activos.

La aplicación también puede utilizar códigos QR para facilitar la captura de esta información.

---

## 7. Código QR

FIMSS utiliza el paquete `mobile_scanner`.

El objetivo del lector QR es permitir capturar rápidamente información del usuario, como NSS o CURP, cuando dicha información se encuentre codificada en un código QR.

El lector debe utilizar la cámara trasera del dispositivo cuando sea apropiado.

---

## 8. Regla fundamental de turnos

### UN SOLO TURNO ACTIVO POR NSS

Un NSS no debe poder obtener simultáneamente varios turnos activos.

Antes de crear un turno nuevo, FIMSS debe comprobar si ese NSS ya tiene un turno activo.

Si existe un turno activo:

* No se debe crear otro turno.
* Se debe mostrar al usuario su turno existente.
* Se debe conservar la información del turno existente.

Esta regla es crítica y no debe eliminarse accidentalmente durante futuras modificaciones.

---

## 9. Almacenamiento local

FIMSS utiliza `shared_preferences` para conservar información local relacionada con el turno.

Entre los datos utilizados anteriormente se encuentran identificadores relacionados con:

* `turno_id`
* `turno_nss`

El almacenamiento local permite que la aplicación pueda recuperar información del turno previamente obtenido en el dispositivo.

---

## 10. Comportamiento esperado del turno

El usuario debe poder:

1. Identificarse mediante NSS/CURP o QR.
2. Seleccionar o utilizar una unidad.
3. Seleccionar un servicio.
4. Consultar la fila correspondiente.
5. Obtener un turno.
6. Ver su número de turno.
7. Consultar cuántas personas están esperando.
8. Recuperar su turno existente cuando corresponda.

La aplicación debe evitar generar turnos duplicados para el mismo NSS cuando exista un turno activo.

---

## 11. Interfaz y lenguaje

La aplicación está orientada principalmente a usuarios de México.

El idioma principal de la interfaz es:

**Español (México).**

Algunos textos utilizados en la interfaz incluyen:

* `PERSONAS ESPERANDO`
* `TOMAR TURNO`
* `¡Turno obtenido!`
* `No se recibió un NSS válido.`

Los textos visibles al usuario deben mantenerse claros, sencillos y profesionales.

---

## 12. Pantallas conocidas

Durante el desarrollo se han utilizado o creado pantallas relacionadas con:

* Escaneo QR
* Captura manual
* Obtención de turno
* Estado de la cola
* Consulta del turno

Entre los archivos conocidos del proyecto se encuentran:

* `lib/main.dart`
* `lib/screens/manual_entry_screen.dart`
* `lib/screens/qr_scanner_screen.dart`
* `lib/screens/take_turn_screen.dart`
* `lib/screens/queue_status_screen.dart`

También ha existido una versión de respaldo:

* `lib/screens/queue_status_screen_backup.dart`

Antes de eliminar o reemplazar una pantalla existente se debe comprobar si contiene lógica que todavía sea necesaria.

---

## 13. Configuración de Supabase

Existe una configuración relacionada con Supabase dentro del proyecto.

Se ha utilizado:

`lib/config/supabase_config.dart`

La aplicación utiliza una instancia de:

`SupabaseClient`

mediante:

`Supabase.instance.client`

Las credenciales y claves privadas nunca deben escribirse en este archivo de memoria ni compartirse públicamente.

---

## 14. Estado del proyecto

El proyecto se encuentra en desarrollo.

FIMSS ya cuenta con una estructura Flutter funcional y conexión con Supabase.

Durante el desarrollo se han realizado pruebas en dispositivos Apple y se han presentado problemas relacionados con:

* compilación
* firma de código
* cámara/lector QR
* ejecución en dispositivos
* conexión del dispositivo durante `flutter run`
* compatibilidad de APIs de `mobile_scanner`

Los problemas deben solucionarse sin romper las funcionalidades que ya funcionan.

---

## 15. Regla para futuras modificaciones

Antes de modificar código importante:

1. Revisar primero el código existente.
2. Entender qué comportamiento actual funciona.
3. No reemplazar archivos completos innecesariamente.
4. Hacer cambios pequeños y controlados.
5. Probar después de cada cambio importante.
6. Mantener la compatibilidad con Android e iOS cuando sea posible.
7. No eliminar lógica existente sin comprobar para qué se utiliza.
8. Actualizar esta documentación cuando cambie la arquitectura o una regla importante de negocio.

---

## 16. Fuente oficial del código

El repositorio GitHub de FIMSS es la fuente principal del código del proyecto.

Repositorio:

https://github.com/JOANLORETO/FIMSS

La copia local de trabajo debe mantenerse sincronizada con GitHub.

Antes de comenzar una sesión importante de desarrollo se recomienda comprobar:

`git status`

y posteriormente sincronizar los cambios cuando corresponda.

---

## 17. Memoria de IA

Los archivos `AI_*.md` forman parte de la documentación permanente de FIMSS.

Su propósito es permitir que una IA pueda comprender rápidamente:

* qué es FIMSS;
* cómo está construido;
* qué reglas debe respetar;
* qué tareas están pendientes;
* qué cambios se han realizado.

La documentación debe mantenerse actualizada conforme evolucione el proyecto.

---

## 18. Principio fundamental

### NO ROMPER LO QUE YA FUNCIONA.

Cada modificación debe realizarse intentando conservar las funcionalidades existentes.

Cuando exista duda entre una modificación grande y una modificación pequeña, se debe preferir inicialmente la modificación pequeña, comprobable y reversible.

## Automatización GitHub

FIMSS cuenta con sincronización automática mediante `scripts/auto_sync.sh`.

Prueba de sincronización automática.

Prueba final del automatizador FIMSS.
