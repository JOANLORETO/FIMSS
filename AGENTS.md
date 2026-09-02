# AGENTS.md — Reglas para agentes de IA en FIMSS

## 1. Propósito

FIMSS es un sistema de filas virtuales desarrollado con Flutter y Supabase.

Este archivo establece las reglas que debe seguir cualquier agente de IA que trabaje en el proyecto.

El objetivo es que cualquier IA pueda continuar FIMSS desde su estado actual sin reiniciar el proyecto ni romper funcionalidades existentes.

---

## 2. Archivos que una IA debe leer primero

Antes de modificar código, leer en este orden:

1. AI_CONTEXT.md
2. AI_RULES.md
3. AI_TASKS.md
4. CHANGELOG.md
5. README.md

Después se debe revisar directamente el código relacionado con la tarea.

El código actual del repositorio y esta documentación son la fuente principal de información del proyecto.

---

## 3. Regla fundamental

FIMSS debe evolucionar, no reiniciarse.

Nunca reconstruir el proyecto desde cero cuando ya exista una implementación funcional.

Antes de modificar algo:

- inspeccionar el código existente;
- identificar los archivos involucrados;
- entender cómo funciona actualmente;
- conservar la lógica que ya funciona;
- realizar cambios pequeños y controlados.

---

## 4. No romper funcionalidades existentes

No eliminar ni reemplazar funcionalidades existentes sin comprobar primero su impacto.

Especial cuidado con:

- NSS;
- CURP;
- códigos QR;
- turnos;
- recuperación de turnos;
- personas esperando;
- Supabase;
- SharedPreferences;
- navegación;
- cámara;
- permisos;
- Android;
- iOS.

---

## 5. Regla crítica de turnos

FIMSS debe mantener la regla:

UN SOLO TURNO ACTIVO POR NSS

Antes de crear un turno nuevo:

1. comprobar si existe un turno activo para ese NSS;
2. si existe, recuperar ese turno;
3. mostrar o reutilizar el turno existente;
4. no crear un turno duplicado.

Esta regla no debe eliminarse ni modificarse sin una decisión explícita.

---

## 6. Base de datos

FIMSS utiliza Supabase y PostgreSQL.

Tablas conocidas:

- unidades
- servicios
- colas
- turnos

Nunca inventar columnas, relaciones o estados.

Antes de modificar consultas:

- revisar el código actual;
- comprobar los nombres reales;
- comprobar relaciones;
- comprobar cómo se determina un turno activo;
- comprobar cómo se calcula la cantidad de personas esperando.

---

## 7. Identificación

FIMSS puede utilizar:

- NSS;
- CURP;
- códigos QR.

No modificar las validaciones sin revisar primero dónde y cómo se utilizan.

Los códigos QR deben manejarse evitando:

- lecturas duplicadas;
- valores vacíos;
- valores inválidos;
- navegación duplicada;
- creación accidental de turnos.

---

## 8. Cámara y QR

El proyecto utiliza mobile_scanner.

Antes de modificar el escáner:

- revisar la versión instalada;
- revisar la API actualmente utilizada;
- revisar MobileScannerController;
- revisar permisos de cámara;
- comprobar Android;
- comprobar iOS.

No actualizar paquetes innecesariamente.

---

## 9. Almacenamiento local

El proyecto utiliza shared_preferences.

Claves conocidas:

- turno_id
- turno_nss

No cambiar ni eliminar estas claves sin revisar primero sus referencias.

Los cambios deben considerar:

- reinicio de la aplicación;
- recuperación del turno;
- datos incompletos;
- cambio de usuario;
- eliminación de información obsoleta.

---

## 10. Multiplataforma

El proyecto contiene soporte para:

- Android;
- iOS;
- Web;
- macOS;
- Windows;
- Linux.

Cuando una modificación afecte código común, comprobar que no rompa otras plataformas.

---

## 11. Proceso de cambios

Aplicar siempre este proceso:

1. inspeccionar;
2. modificar lo mínimo necesario;
3. ejecutar pruebas o análisis;
4. corregir errores;
5. comprobar regresiones;
6. actualizar documentación cuando corresponda;
7. revisar git diff;
8. crear un commit descriptivo;
9. sincronizar con GitHub.

No realizar múltiples cambios grandes simultáneamente cuando puedan dividirse.

---

## 12. Git y GitHub

GitHub es la fuente principal del código de FIMSS.

Repositorio:

https://github.com/JOANLORETO/FIMSS

Antes de trabajar:

git status

Después de cambios importantes:

git diff
git status

Los commits deben describir claramente el cambio.

Ejemplos:

feat: improve queue status
fix: prevent duplicate active turns
fix: recover existing turn
docs: update AI task tracker
docs: update changelog

Evitar mensajes genéricos como:

update
changes
fix
test

---

## 13. Seguridad

Nunca introducir en el repositorio:

- contraseñas;
- tokens privados;
- claves privadas;
- credenciales;
- secretos;
- datos reales de pacientes.

NSS y CURP no deben aparecer con datos reales en ejemplos, documentación, commits o capturas.

Utilizar datos ficticios para pruebas.

---

## 14. Documentación permanente

Cuando una modificación cambie:

- arquitectura;
- base de datos;
- reglas de negocio;
- flujo de usuario;
- dependencias importantes;
- estructura del proyecto;
- decisiones técnicas importantes;

actualizar los archivos correspondientes.

Principalmente:

- AI_CONTEXT.md
- AI_RULES.md
- AI_TASKS.md
- CHANGELOG.md

La documentación debe permitir que otra IA continúe el proyecto sin depender de conversaciones anteriores.

---

## 15. Diagnóstico de errores

Ante un error:

1. leer el mensaje completo;
2. identificar archivo y línea;
3. determinar la categoría del problema;
4. revisar el código relacionado;
5. realizar el cambio mínimo;
6. volver a probar.

No realizar cambios aleatorios solamente para intentar eliminar un error.

---

## 16. Dependencias

Antes de actualizar un paquete:

- comprobar la versión instalada;
- revisar dónde se utiliza;
- comprobar compatibilidad;
- evaluar impacto en las plataformas;
- evitar actualizar múltiples paquetes importantes al mismo tiempo.

---

## 17. Prioridades

Cuando existan varias soluciones, priorizar:

1. conservar funcionalidades existentes;
2. evitar regresiones;
3. solución sencilla;
4. cambios pequeños;
5. código claro;
6. compatibilidad multiplataforma;
7. facilidad de mantenimiento;
8. rendimiento cuando sea necesario.

---

## 18. Cómo debe trabajar una IA

Una IA que continúe FIMSS debe:

- leer primero la documentación;
- inspeccionar el código real;
- comprobar el estado actual del repositorio;
- no asumir que una funcionalidad existe solamente porque está documentada;
- modificar solamente lo necesario;
- probar sus cambios;
- documentar decisiones importantes;
- dejar el proyecto en un estado comprensible para la siguiente IA.

No depender de conversaciones anteriores como fuente principal de información.

---

## 19. No preguntar innecesariamente

Si la información necesaria puede obtenerse revisando:

- código;
- documentación;
- Git;
- configuración;
- dependencias;
- Supabase cuando corresponda;

la IA debe investigarla primero.

Solo debe solicitar información al usuario cuando realmente sea necesaria y no pueda obtenerse de forma segura desde el proyecto.

---

## 20. Principio final

El objetivo no es comenzar FIMSS nuevamente.

El objetivo es continuar exactamente desde el estado existente, mejorar progresivamente el sistema y dejar suficiente documentación para que cualquier desarrollador o IA pueda continuar después.

FIMSS debe evolucionar, no reiniciarse.
