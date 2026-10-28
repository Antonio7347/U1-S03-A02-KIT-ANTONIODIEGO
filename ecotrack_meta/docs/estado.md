# Gestión de estado — EcoTrack Meta

**Equipo:** Antonio Diego
**Fecha:** 27/10/2026

## Tipos de estado en nuestro código

| Dato | Tipo (efímero, compartido, derivado, persistido) | Dónde vive |
|---|---|---|
| Pestaña activa | Efímero | En el estado local `_PantallasEcoTrackState` (`_indicePestana` en `lib/presentacion/vistas.dart`) |
| Texto del campo de litros | Efímero | En el `TextEditingController` de `_FormularioRegistroState` (`lib/presentacion/vistas.dart`) |
| consumos y meta | Compartido | En los campos `consumos` y `meta` de `ConsumosViewModel` (`lib/presentacion/consumos_view_model.dart`) |
| total y metaSuperada | Derivado | En los getters `get total` y `get metaSuperada` en `ConsumosViewModel` (`lib/presentacion/consumos_view_model.dart`) |
| Lo que regresa todos() | Persistido | En la lista interna `_consumos` de `MemoriaConsumoRepository` (`lib/datos/memoria_consumo_repository.dart`) |

## Criterios

| Criterio | A · ChangeNotifier puro | B · provider |
|---|---|---|
| Dato compartido | Se comparte pasando `ConsumosViewModel` por constructor a `RegistroCN`, `HistorialCN` y `MetaCN` | Se comparte exponiendo `ConsumosViewModel` con `ChangeNotifierProvider` en el árbol de widgets |
| Capas | `vistas.dart` solo recibe datos/callbacks y no conoce el ViewModel ni el repositorio | `vistas.dart` se mantiene intacto sin conocer provider ni el repositorio |
| Encaje con el diagrama | La vista tonta notifica eventos al callback y `ListenableBuilder` escucha los cambios del ViewModel | `RegistroProvider`, `HistorialProvider` y `MetaProvider` conectan la vista tonta con el árbol mediante `watch` y `read` |
| Constructores que reciben vm | 3 adaptadores (`RegistroCN`, `HistorialCN`, `MetaCN`) reciben `vm` por constructor | 0 adaptadores reciben `vm`; todos lo consultan al árbol mediante `BuildContext` |
| Quién libera el ViewModel | `_AppChangeNotifierState` en su método `dispose()` en `lib/variantes/a_change_notifier.dart` | `ChangeNotifierProvider` automáticamente al desmontar el widget del árbol |
| Costo de adoptarla ahora | Bajo sin dependencias externas, pero requiere propagación manual de `vm` por constructores | Mínimo en código al eliminar acoplamiento por constructor, requiriendo agregar la dependencia `provider` |
| Sustitución de la fuente de datos | Alta sustitución al inyectar cualquier `ConsumoRepository` en `AppChangeNotifier` como en `etapa4_change_notifier_test.dart` | Alta sustitución al inyectar cualquier `ConsumoRepository` en `AppProvider` como en `etapa5_provider_test.dart` |

## Elección

Elegimos: Variante B (provider) por evitar el acoplamiento de pasar el ViewModel por constructores y gestionar el ciclo de vida automáticamente.
Se mantiene esta pieza del diagrama: `ConsumosViewModel` como único dueño del estado compartido y derivado, además del contrato `ConsumoRepository`.
Esta pieza es la que podría sustituirse después: `MemoriaConsumoRepository` puede sustituirse por una implementación remota o de base de datos local como `SqliteConsumoRepository`.
