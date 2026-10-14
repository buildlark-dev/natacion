# Lista de verificación de calidad: El nadador consume su plan

**Propósito**: validar que la especificación está completa antes de pasar a planificación
**Creada**: 2026-10-13
**Feature**: [spec.md](../spec.md)

## Calidad del contenido

- [x] Sin detalles de implementación (lenguajes, marcos de trabajo, APIs)
- [x] Centrada en el valor para el usuario y la necesidad de negocio
- [x] Escrita para alguien que no programa
- [x] Todas las secciones obligatorias completas

## Completitud de los requisitos

- [x] No quedan marcadores [NEEDS CLARIFICATION]
- [x] Los requisitos son comprobables y no ambiguos
- [x] Los criterios de éxito son medibles
- [x] Los criterios de éxito no mencionan tecnología
- [x] Los escenarios de aceptación están definidos
- [x] Los casos límite están identificados
- [x] El alcance está delimitado
- [x] Las dependencias y los supuestos están identificados

## Preparación de la feature

- [x] Todos los requisitos funcionales tienen criterios de aceptación claros
- [x] Las historias de usuario cubren los recorridos principales
- [x] La feature cumple los resultados medibles de los criterios de éxito
- [x] Ningún detalle de implementación se filtra a la especificación

## Revisión contra la constitución

Esta sección no está en la plantilla. Se añade porque la constitución exige verificar los
ocho principios y porque esta feature toca los dos más delicados: datos de menores y
control de carga interna.

- [x] **I. Metodología como norma.** Las series se muestran con la notación del entrenador
      y los nombres exactos de la Biblioteca (FR-004). El RPE usa Borg 0-10 (FR-007).
- [x] **II. Dominio en Dart puro.** Declarado en los supuestos; la prueba de frontera lo
      vigila.
- [x] **III. Pruebas de las reglas que llegan al nadador.** FR-025 exige denegar por
      omisión y probar los casos negativos; SC-008 lo hace medible.
- [x] **IV. El criterio del entrenador no se delega.** El reajuste automático queda fuera
      de alcance; un reporte de molestia no se resuelve solo (FR-009).
- [x] **V. Datos de deportistas.** El consentimiento es puerta de publicación y queda como
      supuesto bloqueante; sin nombres ni marcas en registros ni analítica (FR-023);
      exportable y borrable (FR-024).
- [x] **VI. Freemium honesto.** El acceso del nadador a lo que él mismo generó no queda
      tras el muro de pago (FR-026).
- [x] **VII. Rebanadas verticales.** Cuatro historias, cada una comprobable por separado;
      la primera entrega valor sola.
- [x] **VIII. Control de carga interna.** Es la razón de ser de la feature: registro por
      sesión (FR-006 a FR-008), llega al entrenador junto al plan que lo originó (FR-013),
      carga externa e interna separadas (FR-014), molestia aparte (FR-009, FR-015), y
      registrar no es obligatorio (FR-010).

## Notas

- El único [NEEDS CLARIFICATION] quedó resuelto el 2026-10-13: el entrenador eligió la
  opción B para «mi progreso» —historial de sesiones más adherencia como recuento, sin
  gráficas—. Queda en FR-005a, FR-005b y FR-005c, con SC-010 y SC-011 para medirlo.
- La opción C, graficar el RPE junto a los metros programados, se descartó a propósito: el
  principio VIII prohíbe combinar carga externa e interna en un mismo indicador, y
  superponerlas invita a leer una correlación que nadie ha probado. Es material para una
  feature de seguimiento posterior, no para esta.
- Las restricciones de uso a pie de piscina de la constitución están cubiertas por FR-016 a
  FR-021 y por SC-001 y SC-003, que las vuelven medibles.
