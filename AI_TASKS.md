# FIMSS — AI TASKS

## 1. OBJETIVO

Este archivo contiene la lista maestra de tareas pendientes, problemas conocidos, pruebas y mejoras del proyecto FIMSS.

FIMSS es un sistema de filas virtuales para servicios médicos del IMSS.

La prioridad es avanzar de forma incremental, conservando todo lo que ya funciona.

---

# 2. ESTADO ACTUAL DEL PROYECTO

## Arquitectura

* [x] Proyecto Flutter creado.
* [x] Aplicación configurada para múltiples plataformas.
* [x] Supabase integrado.
* [x] PostgreSQL mediante Supabase.
* [x] Lectura de códigos QR mediante `mobile_scanner`.
* [x] Almacenamiento local mediante `shared_preferences`.
* [x] Comunicación HTTP disponible mediante `http`.
* [x] Proyecto almacenado en GitHub.
* [x] `AI_CONTEXT.md` creado.
* [x] `AI_RULES.md` creado.
* [x] Crear y mantener `CHANGELOG.md`.
* [x] Crear posteriormente `AGENTS.md`.

## Repositorio

Repositorio oficial:

https://github.com/JOANLORETO/FIMSS

Rama principal:

`main`

GitHub debe considerarse la fuente principal del código del proyecto.

---

# 3. FUNCIONES PRINCIPALES

## Identificación del usuario

* [x] Permitir identificación mediante NSS.
* [x] Permitir identificación mediante CURP cuando corresponda.
* [x] Permitir lectura mediante código QR.
* [ ] Validar completamente los diferentes formatos de QR que pueda utilizar FIMSS.
* [ ] Definir claramente qué información debe contener un QR.
* [ ] Evitar aceptar códigos inválidos como identificadores válidos.
* [ ] Revisar manejo de errores cuando no se recibe un NSS válido.

## Turnos

* [x] Obtener turno.
* [x] Consultar turno existente.
* [x] Mostrar número de turno.
* [x] Mostrar personas esperando.
* [x] Guardar información del turno localmente.
* [x] Recuperar información del turno almacenada localmente.
* [ ] Verificar completamente el flujo de turno de principio a fin.
* [ ] Confirmar que el turno mostrado corresponde al usuario correcto.
* [ ] Confirmar actualización correcta de personas esperando.
* [ ] Definir correctamente cuándo un turno deja de estar activo.
* [ ] Probar recuperación del turno después de cerrar y abrir la aplicación.

## Regla crítica: un turno por NSS

* [x] Existe la regla de negocio: UN SOLO TURNO ACTIVO POR NSS.
* [ ] Verificar que la regla se cumpla siempre en Supabase.
* [ ] Evitar creación de turnos duplicados.
* [ ] Si existe un turno activo, recuperar y mostrar ese turno.
* [ ] Probar múltiples intentos consecutivos con el mismo NSS.
* [ ] Probar el mismo NSS desde diferentes dispositivos.
* [ ] Revisar posibles condiciones de carrera al solicitar turno.

---

# 4. SUPABASE

Tablas principales conocidas:

* `unidades`
* `servicios`
* `colas`
* `turnos`

## Pendientes

* [ ] Revisar estructura real de todas las tablas.
* [ ] Revisar columnas reales.
* [ ] Revisar relaciones entre tablas.
* [ ] Revisar claves primarias.
* [ ] Revisar claves foráneas.
* [ ] Revisar índices.
* [ ] Revisar políticas RLS.
* [ ] Revisar permisos de lectura.
* [ ] Revisar permisos de inserción.
* [ ] Revisar permisos de actualización.
* [ ] Revisar permisos de eliminación.
* [ ] Confirmar cómo se determina un turno activo.
* [ ] Confirmar cómo se calcula `personas esperando`.
* [ ] Confirmar que las consultas utilizadas por Flutter coinciden con la estructura real de Supabase.
* [ ] Documentar la estructura de Supabase en la documentación del proyecto.

IMPORTANTE:

Nunca inventar nombres de columnas, relaciones o reglas de Supabase.

Antes de modificar consultas, revisar la estructura real de la base de datos.

---

# 5. PANTALLAS

## Pantallas conocidas

* `lib/main.dart`
* `lib/screens/manual_entry_screen.dart`
* `lib/screens/qr_scanner_screen.dart`
* `lib/screens/take_turn_screen.dart`
* `lib/screens/queue_status_screen.dart`

## Pendientes

* [ ] Revisar navegación completa entre pantallas.
* [ ] Revisar flujo de inicio.
* [ ] Revisar pantalla de captura manual.
* [ ] Revisar pantalla de escaneo QR.
* [ ] Revisar pantalla para tomar turno.
* [ ] Revisar pantalla de estado del turno.
* [ ] Revisar botones y estados de carga.
* [ ] Revisar mensajes de error.
* [ ] Revisar mensajes de éxito.
* [ ] Revisar comportamiento cuando no existe información.
* [ ] Revisar comportamiento cuando Supabase no está disponible.
* [ ] Mejorar consistencia visual.
* [ ] Mantener interfaz en español de México.

---

# 6. CÓDIGO QR

Paquete utilizado:

`mobile_scanner`

## Pendientes

* [ ] Revisar compatibilidad actual de `mobile_scanner`.
* [ ] Revisar permisos de cámara en Android.
* [ ] Revisar permisos de cámara en iOS.
* [ ] Probar lectura de QR en dispositivo físico.
* [ ] Probar códigos QR válidos.
* [ ] Probar códigos QR inválidos.
* [ ] Probar QR vacío o incompleto.
* [ ] Evitar lecturas repetidas accidentales.
* [ ] Revisar correctamente el cierre del escáner.
* [ ] Revisar uso de `MobileScannerController`.
* [ ] Revisar compatibilidad de `CameraFacing.back`.

No actualizar `mobile_scanner` sin revisar primero el impacto sobre el código existente.

---

# 7. ALMACENAMIENTO LOCAL

Paquete:

`shared_preferences`

Datos conocidos:

* `turno_id`
* `turno_nss`

## Pendientes

* [ ] Revisar todas las claves utilizadas.
* [ ] Documentar qué información se guarda localmente.
* [ ] Verificar recuperación después de reiniciar la aplicación.
* [ ] Verificar comportamiento cuando los datos locales están incompletos.
* [ ] Evitar información innecesaria almacenada localmente.
* [ ] Definir cuándo deben eliminarse los datos del turno.

---

# 8. ANDROID

## Pendientes

* [ ] Ejecutar FIMSS en Android físico.
* [ ] Probar cámara.
* [ ] Probar QR.
* [ ] Probar NSS.
* [ ] Probar obtención de turno.
* [ ] Probar recuperación de turno.
* [ ] Probar cierre y reapertura de aplicación.
* [ ] Revisar permisos.
* [ ] Revisar compilación de release.
* [ ] Revisar configuración de firma cuando corresponda.

---

# 9. iOS

## Pendientes

* [ ] Ejecutar FIMSS en iPhone físico.
* [ ] Revisar configuración de cámara.
* [ ] Probar lectura QR.
* [ ] Probar NSS.
* [ ] Probar obtención de turno.
* [ ] Probar recuperación de turno.
* [ ] Probar cierre y reapertura.
* [ ] Revisar permisos.
* [ ] Revisar firma de código.
* [ ] Revisar certificados.
* [ ] Revisar configuración de provisioning.
* [ ] Preparar posteriormente versión para App Store.

---

# 10. WEB

## Pendientes

* [ ] Ejecutar FIMSS en navegador.
* [ ] Revisar compatibilidad de funcionalidades.
* [ ] Revisar comportamiento de cámara/QR.
* [ ] Revisar diseño responsive.
* [ ] Revisar navegación.
* [ ] Revisar errores.
* [ ] Definir qué funciones estarán disponibles en Web.

---

# 11. DISEÑO Y EXPERIENCIA DE USUARIO

## Objetivo

La aplicación debe sentirse profesional, clara, sencilla y confiable.

## Pendientes

* [ ] Revisar pantalla inicial.
* [ ] Revisar identidad visual de FIMSS.
* [ ] Definir colores oficiales.
* [ ] Definir tipografía.
* [ ] Revisar tamaños de botones.
* [ ] Revisar mensajes al usuario.
* [ ] Revisar indicadores de carga.
* [ ] Revisar estados de error.
* [ ] Revisar accesibilidad.
* [ ] Revisar experiencia para usuarios con poca experiencia tecnológica.
* [ ] Evitar pantallas innecesariamente complicadas.

---

# 12. SEGURIDAD

## Pendientes

* [ ] Revisar configuración de Supabase.
* [ ] Revisar RLS.
* [ ] Revisar exposición de información.
* [ ] Evitar datos personales reales en código.
* [ ] Evitar datos reales de pacientes en pruebas.
* [ ] No guardar contraseñas en el repositorio.
* [ ] No guardar tokens privados en el repositorio.
* [ ] No guardar claves secretas en documentación pública.
* [ ] Revisar configuración de producción antes de publicar.

---

# 13. PRUEBAS

## Pruebas funcionales

* [ ] Usuario nuevo obtiene turno.
* [ ] Usuario con turno activo intenta obtener otro.
* [ ] Usuario recupera turno existente.
* [ ] Usuario introduce NSS inválido.
* [ ] Usuario introduce NSS vacío.
* [ ] Usuario utiliza QR válido.
* [ ] Usuario utiliza QR inválido.
* [ ] Usuario pierde conexión a Internet.
* [ ] Supabase no responde.
* [ ] Aplicación se cierra inesperadamente.
* [ ] Usuario vuelve a abrir la aplicación.
* [ ] Dos dispositivos utilizan el mismo NSS.

## Pruebas de regresión

Cada cambio importante debe comprobar que continúan funcionando:

* [ ] QR.
* [ ] NSS.
* [ ] CURP.
* [ ] Obtención de turno.
* [ ] Consulta de turno.
* [ ] Personas esperando.
* [ ] Almacenamiento local.
* [ ] Navegación.

---

# 14. PROBLEMAS CONOCIDOS

## Problemas anteriores

* Se han presentado problemas de firma de código en iOS.
* Se han presentado problemas de conexión con dispositivos físicos.
* Se han presentado cambios de API relacionados con `mobile_scanner`.
* Se han presentado problemas relacionados con permisos de cámara.
* Se ha presentado comportamiento donde un turno existente debe recuperarse en lugar de crear uno nuevo.

Estos problemas deben investigarse antes de asumir que una función nueva está fallando.

---

# 15. PRIORIDAD ACTUAL

## 🔴 PRIORIDAD ALTA

* [ ] Revisar el estado real del código actual desde GitHub.
* [ ] Revisar la estructura real de Supabase.
* [ ] Ejecutar la aplicación actual antes de realizar cambios importantes.
* [ ] Verificar el flujo completo de identificación → turno → estado del turno.
* [ ] Verificar definitivamente la regla de UN SOLO TURNO ACTIVO POR NSS.
* [ ] Identificar cualquier error actual reproducible.

## 🟡 PRIORIDAD MEDIA

* [ ] Mejorar interfaz.
* [ ] Mejorar mensajes de error.
* [ ] Mejorar experiencia de usuario.
* [ ] Completar pruebas Android/iOS.
* [ ] Revisar compatibilidad Web.

## 🟢 PRIORIDAD BAJA

* [ ] Mejoras visuales avanzadas.
* [ ] Animaciones.
* [ ] Funciones adicionales.
* [ ] Preparación comercial.
* [ ] Publicación en tiendas.

---

# 16. METODOLOGÍA DE TRABAJO

Cada tarea debe seguir este proceso:

1. Identificar el problema.
2. Revisar el código existente.
3. Revisar dependencias relacionadas.
4. Revisar Supabase si la tarea lo requiere.
5. Explicar qué se va a modificar.
6. Hacer el cambio mínimo necesario.
7. Ejecutar pruebas.
8. Corregir errores.
9. Verificar que no se rompieron funciones existentes.
10. Actualizar este archivo si cambia el estado de la tarea.
11. Actualizar `CHANGELOG.md` cuando corresponda.
12. Hacer commit.
13. Hacer push a GitHub.

---

# 17. REGLA FUNDAMENTAL

FIMSS debe evolucionar, no reiniciarse.

No se debe reemplazar código funcional simplemente para implementar una solución diferente.

Primero se entiende lo que existe.

Después se modifica solamente lo necesario.

---

# 18. ESTADO DE LAS TAREAS

Leyenda:

* `[ ]` Pendiente.
* `[x]` Completado.
* `[~]` En progreso.
* `[!]` Bloqueado o requiere investigación.

Este archivo debe mantenerse actualizado durante el desarrollo.

---

# 19. INFRAESTRUCTURA DE DESARROLLO

* [x] GitHub establecido como fuente principal del código.

* [x] Documentación persistente para IA configurada.

* [x] `AGENTS.md` configurado.

* [x] `scripts/auto_sync.sh` implementado.

* [x] Validación mediante `flutter analyze` antes de sincronizar.

* [x] Protección contra divergencia entre el repositorio local y GitHub.

* [x] Archivos nuevos protegidos contra incorporación automática.

* [x] Commit y push automáticos configurados.

* [x] LaunchAgent de macOS configurado.

* [x] Sincronización automática verificada funcionando.

