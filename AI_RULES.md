# FIMSS — Reglas para Inteligencia Artificial

## 1. Regla principal

### NO ROMPER LO QUE YA FUNCIONA.

Toda modificación realizada por una IA debe intentar conservar las funcionalidades existentes de FIMSS.

No se debe asumir que una parte del código puede eliminarse o reemplazarse simplemente porque existe una solución diferente.

---

## 2. Antes de modificar código

Antes de realizar cambios importantes, la IA debe:

1. Revisar el código existente.
2. Identificar qué archivo o archivos están involucrados.
3. Entender la función actual del código.
4. Identificar posibles dependencias con otras pantallas o servicios.
5. Proponer el cambio antes de realizar modificaciones grandes.

Cuando sea posible, se deben preferir cambios pequeños y controlados.

---

## 3. No reemplazar archivos completos innecesariamente

No se debe reemplazar un archivo completo cuando solamente es necesario modificar una pequeña sección.

Se debe conservar:

* código funcional;
* lógica existente;
* nombres de variables cuando no sea necesario cambiarlos;
* comportamiento comprobado;
* configuraciones existentes.

Si un archivo completo debe ser reemplazado, primero se debe explicar por qué.

---

## 4. Regla de cambios pequeños

Las modificaciones deben realizarse de forma incremental.

Preferencia:

```text
CAMBIO PEQUEÑO
      ↓
COMPILAR / PROBAR
      ↓
VERIFICAR RESULTADO
      ↓
SIGUIENTE CAMBIO
```

Evitar realizar muchos cambios simultáneos que dificulten identificar el origen de un problema.

---

## 5. Regla de Supabase

Antes de modificar consultas, tablas o lógica relacionada con Supabase:

1. Revisar el código que actualmente utiliza Supabase.
2. Identificar las tablas involucradas.
3. Identificar las columnas utilizadas.
4. Revisar las relaciones necesarias.
5. Evitar cambiar la estructura de la base de datos sin una razón clara.

Las tablas principales conocidas son:

* `unidades`
* `servicios`
* `colas`
* `turnos`

No se deben inventar columnas, tablas o relaciones.

Si falta información sobre la estructura real de Supabase, se debe solicitar o comprobar antes de realizar cambios importantes.

---

## 6. Regla crítica de turnos

### UN SOLO TURNO ACTIVO POR NSS

Esta regla es obligatoria.

Un NSS no debe obtener un segundo turno mientras tenga uno activo.

Antes de crear un turno nuevo:

1. Comprobar si existe un turno activo para el NSS.
2. Si existe, recuperar ese turno.
3. No crear un turno duplicado.
4. Mostrar al usuario la información del turno existente.

Nunca eliminar esta validación sin una decisión explícita del proyecto.

---

## 7. Identificación mediante NSS y CURP

FIMSS puede trabajar con:

* NSS
* CURP
* códigos QR

La lógica de identificación debe mantenerse separada de la lógica visual cuando sea posible.

No modificar el formato o validación del NSS sin comprobar primero dónde se utiliza.

---

## 8. Código QR

FIMSS utiliza `mobile_scanner`.

Los cambios relacionados con el lector QR deben realizarse con especial cuidado porque pueden afectar:

* permisos de cámara;
* Android;
* iOS;
* navegación;
* captura del NSS;
* captura de CURP.

No cambiar la configuración del escáner sin comprobar la versión del paquete instalada y la API compatible.

---

## 9. Almacenamiento local

FIMSS utiliza `shared_preferences`.

Se han utilizado datos como:

* `turno_id`
* `turno_nss`

No eliminar claves existentes de almacenamiento local sin comprobar primero si todavía son utilizadas.

Si una clave debe cambiarse, se debe considerar la compatibilidad con usuarios que ya tengan datos almacenados en sus dispositivos.

---

## 10. Compatibilidad multiplataforma

FIMSS debe mantenerse compatible, cuando sea técnicamente posible, con:

* Android
* iOS
* Web
* macOS
* Windows
* Linux

Cuando un cambio solamente sea necesario para una plataforma específica, se debe evitar afectar innecesariamente a las demás.

---

## 11. Interfaz de usuario

El idioma principal de FIMSS es:

**Español de México.**

Los textos deben ser:

* claros;
* sencillos;
* profesionales;
* fáciles de entender.

No cambiar textos funcionales sin comprobar si son utilizados en pruebas o documentación.

---

## 12. Seguridad

Nunca colocar en archivos de documentación:

* contraseñas;
* tokens privados;
* claves secretas;
* credenciales;
* información privada de usuarios.

Las claves públicas necesarias para el funcionamiento de una aplicación deben manejarse de acuerdo con las prácticas apropiadas para Flutter y Supabase.

Nunca solicitar al usuario que comparta contraseñas o tokens privados en el chat.

---

## 13. Datos de usuarios

FIMSS puede manejar información relacionada con usuarios, incluyendo NSS o CURP.

Los datos reales de pacientes no deben utilizarse en pruebas ni incluirse en:

* código fuente;
* documentación;
* commits;
* capturas públicas;
* ejemplos públicos.

Para pruebas se deben utilizar datos ficticios.

---

## 14. Diagnóstico de errores

Cuando aparezca un error:

1. Leer el mensaje completo.
2. Identificar el archivo.
3. Identificar la línea.
4. Determinar si el problema es de Dart, Flutter, paquete, configuración, Supabase o plataforma.
5. Hacer el cambio mínimo necesario.
6. Volver a probar.

No realizar cambios aleatorios hasta que desaparezca el error.

---

## 15. Paquetes Flutter

Antes de actualizar una dependencia:

1. Revisar la versión actual en `pubspec.yaml`.
2. Comprobar si el código utiliza APIs específicas de esa versión.
3. Considerar compatibilidad con Android e iOS.
4. Ejecutar las pruebas necesarias después de actualizar.

No actualizar múltiples paquetes importantes simultáneamente sin necesidad.

---

## 16. Git

GitHub es la fuente principal del código de FIMSS.

Antes de comenzar una sesión importante:

```bash
git status
```

Antes de realizar cambios grandes se recomienda asegurarse de que el árbol de trabajo esté limpio.

Los commits deben representar cambios concretos y comprensibles.

Ejemplos:

```text
docs: add AI project context
feat: improve queue status
fix: prevent duplicate active turns
fix: repair QR scanner
refactor: simplify queue logic
```

Evitar commits con mensajes genéricos como:

```text
cambios
arreglos
prueba
final
```

---

## 17. Commit y Push

La secuencia recomendada es:

```text
modificar
   ↓
probar
   ↓
git status
   ↓
git add
   ↓
git commit
   ↓
git push
```

No hacer `git push` de cambios que no hayan sido revisados.

---

## 18. No borrar archivos sin comprobar

Antes de eliminar un archivo:

1. Buscar si es utilizado.
2. Revisar imports.
3. Revisar referencias.
4. Comprobar si contiene lógica necesaria.
5. Confirmar que existe una alternativa.

Los archivos de respaldo tampoco deben eliminarse automáticamente.

---

## 19. Mantener documentación actualizada

Si una modificación cambia:

* arquitectura;
* base de datos;
* reglas de negocio;
* flujo de usuarios;
* nombres importantes;
* dependencias principales;
* estructura del proyecto;

se debe actualizar la documentación `AI_*.md` correspondiente.

---

## 20. Comunicación con el desarrollador

Cuando una modificación pueda afectar significativamente FIMSS, la IA debe explicar:

* qué va a cambiar;
* por qué;
* qué archivos serán afectados;
* qué riesgo existe;
* cómo se comprobará que funciona.

No asumir decisiones importantes del producto sin consultarlas cuando existan varias alternativas razonables.

---

## 21. Prioridad de decisiones

Cuando existan varias soluciones posibles, utilizar este orden:

1. Mantener la funcionalidad existente.
2. Evitar romper otras plataformas.
3. Utilizar la solución más sencilla.
4. Reducir cambios innecesarios.
5. Mantener el código comprensible.
6. Facilitar futuras modificaciones.
7. Mejorar rendimiento cuando exista una necesidad real.

---

## 22. Regla para IA que retome el proyecto

Una IA nueva que trabaje sobre FIMSS debe leer primero:

```text
AI_CONTEXT.md
AI_RULES.md
AI_TASKS.md
CHANGELOG.md
```

si estos archivos existen.

Después debe revisar el código relacionado con la tarea antes de modificarlo.

La IA no debe asumir que el contenido de una conversación anterior es más importante que el estado actual del repositorio.

El código actual y la documentación del repositorio son la referencia principal.

---

## 23. Regla de continuidad

FIMSS es un proyecto en evolución.

Las decisiones nuevas deben documentarse cuando sean importantes para el futuro del proyecto.

El objetivo es que cualquier desarrollador o IA pueda incorporarse al proyecto y comprender rápidamente:

* dónde está el código;
* cómo funciona;
* qué reglas existen;
* qué problemas están pendientes;
* qué decisiones ya fueron tomadas.

---

# PRINCIPIO FINAL

## FIMSS debe evolucionar, no reiniciarse.

Cada nueva sesión de desarrollo debe partir del trabajo existente y mejorarlo de forma controlada.
