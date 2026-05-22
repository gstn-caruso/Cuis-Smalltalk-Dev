# ADR-001: Simplificación del paquete Collections

**Estado:** Aceptado  
**Fecha:** 2026-05-22  
**Autor:** Gaston Caruso  

---

## Contexto

El paquete Collections de Cuis Smalltalk contiene 33 clases. Un análisis completo de callers, métodos propios y superposición semántica (ver `docs/collections-analysis.md`) identificó clases sin uso real, stubs incompletos, y al menos un caso de herencia que viola el Principio de Sustitución de Liskov.

El objetivo es simplificar sin perder semántica útil. Eliminar abstracciones que no aportan nada que otro mecanismo no cubra mejor o con el mismo esfuerzo.

---

## Decisión

### 1. Eliminar `Float32PointArray`

**Motivo:** 0 callers en toda la imagen. La clase existe pero nadie la usa.  
**Lo que se pierde:** Nada.  
**Acción:** Borrar el archivo de clase. Ningún caller que actualizar.

---

### 2. Eliminar `Int16PointArray`

**Motivo:** Stub incompleto — 0 métodos propios, hereda de `DoubleByteArray` sin agregar nada. 1 solo caller.  
**Lo que se pierde:** Nada semánticamente. El único caller puede usar `DoubleByteArray` directamente.  
**Acción:** Borrar el archivo. Actualizar el 1 caller.

---

### 3. Eliminar `RunNotArray`

**Motivo:** 1 solo caller en toda la imagen (`Text class >> fromString:style:`). Su única diferencia con `RunArray` es que no coalesce runs adyacentes con el mismo valor durante la construcción. Esa distinción no justifica una clase separada de ~120 líneas.  
**Lo que se pierde:** El comportamiento de no-coalescencia durante construcción. Pero en el contexto de `fromString:style:`, la coalescencia es inofensiva — si dos runs adyacentes tienen el mismo estilo, comprimirlos es correcto.  
**Acción:** Borrar la clase. Cambiar el único caller a `RunArray withAll: runs`.

---

### 4. Eliminar `IdentityBag`

**Motivo:** Subclase de `Bag` con exactamente 1 método propio: `contentsClass → IdentityDictionary`. 4 callers hacen `IdentityBag new` para contar objetos por identidad de objeto (`==`) en lugar de igualdad (`=`).  
**Lo que se pierde:** Nada. La semántica se preserva completamente agregando un factory method `Bag class >> identityBag` que retorna una instancia de `Bag` inicializada con `IdentityDictionary`.  
**Acción:** Borrar la clase. Agregar `Bag class >> identityBag`. Actualizar los 4 callers (`CPUWatcher`, `NodesInRangeFinder`, `EquivalentNodesFinder`, `ProcessorScheduler`).

---

### 5. Corregir herencia de `SortedCollection` (no eliminar)

**Motivo:** `SortedCollection` hereda de `OrderedCollection` pero bloquea tres de sus métodos con `shouldNotImplement`: `addFirst:`, `at:put:`, `insert:before:`. Esto viola el Principio de Sustitución de Liskov — un `SortedCollection` no puede usarse en cualquier lugar donde se espera un `OrderedCollection`.  
**Lo que se pierde:** Nada — la clase se mantiene con la misma API pública. Solo cambia el nodo de herencia.  
**Acción:** Cambiar la superclase de `SortedCollection` a `SequenceableCollection`. Copiar la implementación compartida que hoy viene de `OrderedCollection` (el backing array `firstIndex`/`lastIndex`/`array`) a una superclase común privada, o duplicar lo mínimo necesario.  
**Nota:** Este cambio es más invasivo que los anteriores. Se implementa en un step separado con su propio ciclo TDD.

---

## Alternativas consideradas

**No hacer nada.** Las clases no rompen nada. La penalidad es conceptual: más superficie de API, más lugares donde buscar cuando algo falla, más documentación que mantener. Descartado porque la complejidad innecesaria tiene costo real a largo plazo.

**Eliminar también `IdentityDictionary`.** Tiene solo 2 métodos propios y es conceptualmente similar a `Dictionary`. Descartado: 46 callers, usado por el sistema para `methodDictionary` y `Smalltalk globals`. El riesgo es alto y el beneficio bajo.

**Eliminar `Bag`.** Solo 11 callers. Pero tiene semántica genuinamente diferente de `Set` y `OrderedCollection` (multiset con conteos). Descartado: la semántica vale la pena mantener.

**Fusionar `SortedCollection` en `OrderedCollection`.** Agregarle un `sortBlock` ivar a todas las instancias de `OrderedCollection` y lógica condicional en `add:`. Descartado: infla la clase más usada con lógica condicional para el caso raro, y no resuelve el problema de fondo.

---

## Consecuencias

- La jerarquía de Collections se reduce de 33 a 29 clases (4 eliminadas).
- Ningún comportamiento observable se pierde.
- La API se simplifica: `Bag identityBag` es más descubrible que una subclase oscura.
- `SortedCollection` queda con herencia honesta (trabajo separado).
- El análisis completo de callers está en `docs/collections-analysis.md`.
