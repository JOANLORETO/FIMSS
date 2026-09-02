# FIMSS — CHANGELOG

Historial de cambios del proyecto FIMSS.

Este archivo registra cambios importantes en código, arquitectura, configuración, documentación y reglas de negocio.

---

# [Unreleased]

Cambios que todavía están en desarrollo y que aún no forman parte de una versión estable.

## Pendiente

* Revisión completa del código actual.
* Revisión de la estructura real de Supabase.
* Verificación del flujo completo de identificación y obtención de turno.
* Verificación de la regla de un solo turno activo por NSS.
* Pruebas completas en dispositivos físicos.
* Mejoras progresivas de interfaz y experiencia de usuario.

---

# [2026-09-02] — Preparación de memoria y control del proyecto

## Documentación creada

Se estableció una estructura de documentación para permitir que diferentes asistentes de IA puedan continuar el desarrollo de FIMSS sin perder el contexto del proyecto.

### AI_CONTEXT.md

Se creó `AI_CONTEXT.md` con información técnica y funcional del proyecto.

Incluye:

* Objetivo general de FIMSS.
* Arquitectura tecnológica.
* Flutter y Dart.
* Supabase y PostgreSQL.
* Plataformas objetivo.
* Paquetes principales.
* Tablas conocidas de Supabase.
* Funcionamiento de turnos.
* Identificación mediante NSS/CURP.
* Lectura de códigos QR.
* Almacenamiento local.
* Archivos principales.
* Problemas conocidos.
* Reglas de negocio importantes.
* GitHub como fuente principal del código.

### AI_RULES.md

Se creó `AI_RULES.md` con las reglas que deben seguir las IA que trabajen sobre FIMSS.

Principios principales:

* No romper lo que ya funciona.
* Revisar el código existente antes de modificarlo.
* Realizar cambios pequeños e incrementales.
* No inventar estructuras de Supabase.
* Respetar la regla de un solo turno activo por NSS.
* Mantener compatibilidad entre plataformas.
* Proteger información sensible.
* Probar los cambios antes de continuar.
* Mantener actualizada la documentación.
* Utilizar Git correctamente.

### AI_TASKS.md

Se creó `AI_TASKS.md` como lista maestra de tareas del proyecto.

Incluye:

* Estado actual.
* Funciones principales.
* Tareas de Supabase.
* Tareas de QR.
* Tareas de almacenamiento local.
* Tareas de Android.
* Tareas de iOS.
* Tareas de Web.
* Diseño y experiencia de usuario.
* Seguridad.
* Pruebas.
* Problemas conocidos.
* Prioridades.
* Metodología de trabajo.

## Control de versiones

Se estableció GitHub como fuente principal del código del proyecto.

Repositorio:

https://github.com/JOANLORETO/FIMSS

Rama principal:

`main`

## Commits realizados

### `a463daf`

Mensaje:

`docs: add FIMSS AI project context`

Se agregó `AI_CONTEXT.md`.

### `042eb2e`

Mensaje:

`docs: add AI development rules`

Se agregó `AI_RULES.md`.

### `60322bc`

Mensaje:

`docs: add FIMSS AI task tracker`

Se agregó `AI_TASKS.md`.

---

# Versiones

## 1.0.0

Estado inicial documentado del proyecto.

Esta versión corresponde al proyecto existente antes de iniciar la nueva etapa de organización y desarrollo incremental.

Las funcionalidades y el estado exacto del código deben verificarse directamente en el repositorio antes de considerar esta versión como una versión de producción.

---

# Formato para futuros cambios

Los cambios futuros deben registrarse utilizando una estructura similar a:

## [FECHA] — Descripción del cambio

### Agregado

* Nueva funcionalidad.

### Modificado

* Funcionalidad existente modificada.

### Corregido

* Error solucionado.

### Eliminado

* Funcionalidad o código eliminado.

### Seguridad

* Cambios relacionados con seguridad.

### Base de datos

* Cambios realizados en Supabase o PostgreSQL.

### Pruebas

* Pruebas realizadas.

### Commit

* Hash o identificador del commit correspondiente.

---

# Reglas para mantener este archivo

1. No registrar información confidencial.
2. No registrar contraseñas, tokens ni claves privadas.
3. No incluir datos reales de pacientes.
4. Registrar cambios importantes y no cada modificación mínima.
5. Mantener las fechas correctas.
6. Relacionar los cambios importantes con su commit cuando sea posible.
7. Mantener este archivo sincronizado con la evolución real del proyecto.
8. No modificar registros históricos para ocultar cambios.
9. Los cambios nuevos deben agregarse arriba de los cambios anteriores.
10. El historial debe permitir entender cómo evolucionó FIMSS.

---

# Principio del proyecto

FIMSS debe evolucionar, no reiniciarse.

Los cambios deben realizarse de manera controlada, incremental y documentada.

La prioridad siempre será conservar la funcionalidad existente mientras se mejora el sistema.
