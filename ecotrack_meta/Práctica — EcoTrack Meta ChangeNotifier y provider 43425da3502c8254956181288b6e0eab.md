# Práctica — EcoTrack Meta: ChangeNotifier y provider desde cero

**Caso:** EcoTrack UTEZ

**Tiempo:** 60 min

**Equipos:** parejas. Una persona escribe (piloto) y otra lee el contrato y revisa (copiloto). **Cambian de rol en cada etapa.**

**Material:** carpeta `kit_alumno/` (pruebas y script de verificación).

---

## La misión

EcoTrack tiene una pantalla nueva: **Meta semanal**. Ahora son tres pestañas que dependen del mismo dato:

- **Registro** guarda un consumo.
- **Historial** lista los consumos y su total.
- **Meta** compara ese total con una meta que se sube y se baja con dos botones, y avisa si ya se rebasó.

Van a construir la app **desde un proyecto vacío**, en capas y con MVVM. El mismo ViewModel se va a cablear **dos veces**:

- **A:** `ChangeNotifier` puro, pasando el ViewModel por constructor.
- **B:** provider, colgando ese mismo ViewModel en el árbol de widgets.

Al final llenan `docs/estado.md` con evidencia sacada **de su propio código**, no de internet.

> El estado es lo que puede cambiar y decide lo que se ve. Gestionarlo es decidir quién es su dueño y cómo se enteran las pantallas cuando cambia.
> 

### Lo que van a aplicar

| Concepto | Dónde aparece en la práctica |
| --- | --- |
| Arquitectura en capas | `dominio/` y `datos/` no conocen Flutter. La vista no conoce `datos/`. |
| MVVM | Vistas tontas → `ConsumosViewModel` → reglas del dominio y repositorio. |
| Tipos de estado | Efímero (`setState`), compartido (ViewModel), derivado (getters), persistido (repositorio). |
| Observer | `notifyListeners()` avisa; `ListenableBuilder` o `context.watch` escuchan. |
| provider | `ChangeNotifierProvider`, `context.watch` y `context.read`. |
| Criterios de A02 | Dato compartido, Capas, Sustitución y Costo, comprobados con pruebas. |

---

## Reglas

1. **No editen** `test/` **ni** `verificar_estado.sh`**.** El docente corre una copia limpia al revisar.
2. **Respeten los contratos al pie de la letra:** nombres de archivos, clases, métodos, parámetros, textos y llaves. Las pruebas dependen de ellos. Lo de adentro lo escriben ustedes.
3. **Hagan las etapas en orden.** No pasen a la siguiente con pruebas en rojo.
4. **Un commit por etapa**, con el mensaje que se indica.
5. Pueden consultar la guía, sus apuntes y la [documentación de provider](https://pub.dev/packages/provider). No copien archivos de `ecotrack_estado/`: los contratos de esta práctica son distintos y tardarán más en adaptarlos que en escribirlos.

---

## Cronograma

| Etapa | Qué | Minutos | Acumulado |
| --- | --- | --- | --- |
| 0 | Arranque del proyecto y el kit | 5 | 5 |
| 1 | Dominio | 7 | 12 |
| 2 | Datos | 5 | 17 |
| 3 | ViewModel con `ChangeNotifier` | 13 | 30 |
| 4 | Vistas tontas y cableado A | 15 | 45 |
| 5 | Cableado B con provider | 10 | 55 |
| 6 | `docs/estado.md` | 5 | 60 |

---

## Etapa 0 — Arranque (5 min)

El proyecto **tiene que llamarse** `ecotrack_meta`: las pruebas importan `package:ecotrack_meta/...`.

```bash
flutter create --empty ecotrack_meta
cd ecotrack_meta
flutter pub add provider

# Copien el kit (ajusten la ruta a donde tengan kit_alumno/)
cp -R ../kit_alumno/test .
cp ../kit_alumno/verificar_estado.sh .

mkdir -p lib/dominio lib/datos lib/presentacion lib/variantes docs

git init && git add . && git commit -m "chore: proyecto base con kit de pruebas"

flutter test               # falla: todavía no existe nada
bash verificar_estado.sh   # casi todo en FALTA
```

En Windows usen **Git Bash** para `cp` y para el script.

**Checkpoint:** `pubspec.yaml` dice `name: ecotrack_meta` y tiene `provider` en `dependencies`.

---

## Estructura objetivo

```
lib/
├── dominio/
│   ├── consumo.dart                 Etapa 1
│   └── meta.dart                    Etapa 1
├── datos/
│   ├── consumo_repository.dart      Etapa 2
│   └── memoria_consumo_repository.dart
├── presentacion/
│   ├── consumos_view_model.dart     Etapa 3
│   └── vistas.dart                  Etapa 4
├── variantes/
│   ├── a_change_notifier.dart       Etapa 4
│   └── b_provider.dart              Etapa 5
├── main_change_notifier.dart        Etapa 4
└── main.dart                        Etapa 5
docs/
└── estado.md                        Etapa 6
```

### Flechas legales

```
vistas.dart        → dominio (solo para Consumo y laboratoriosUtez)
variantes/*        → ViewModel, vistas.dart, contrato del repositorio
ConsumosViewModel  → contrato ConsumoRepository, reglas del dominio
memoria_*          → contrato ConsumoRepository
main*.dart         → todo, solo para armarlo
```

Cualquier otra flecha es sospechosa. En especial: `vistas.dart` **no** importa el ViewModel, ni provider, ni `datos/`.

---

## Contratos fijos

Las firmas son obligatorias. Donde dice `{ ... }`, el cuerpo lo escriben ustedes.

```dart
// lib/dominio/consumo.dart
const laboratoriosUtez = ['Lab Química', 'Lab Redes', 'Lab Física'];

class Consumo {
  const Consumo({required this.laboratorio, required this.litros});
  final String laboratorio;
  final double litros;
}

String? validarLitros(double? litros) { ... }   // mensaje de error o null

// lib/dominio/meta.dart
const metaInicial = 100.0;
const pasoMeta = 10.0;
const metaMinima = 10.0;

double ajustarMeta(double actual, double cambio) { ... }
double avanceDeMeta({required double total, required double meta}) { ... }

// lib/datos/consumo_repository.dart
abstract class ConsumoRepository {
  Future<void> guardar(Consumo consumo);
  Future<List<Consumo>> todos();
}

// lib/datos/memoria_consumo_repository.dart
class MemoriaConsumoRepository implements ConsumoRepository { ... }

// lib/presentacion/consumos_view_model.dart
class ConsumosViewModel extends ChangeNotifier {
  ConsumosViewModel(ConsumoRepository repositorio);

  List<Consumo> consumos;    // empieza vacía
  String? error;             // empieza en null
  bool guardando;            // empieza en false
  double meta;               // empieza en metaInicial

  double get total;          // derivados: getters, NO campos
  double get avance;
  bool get metaSuperada;

  Future<void> cargar() { ... }
  Future<bool> guardar(String laboratorio, String litrosTexto) { ... }  // true si se guardó
  void subirMeta() { ... }
  void bajarMeta() { ... }
}

// lib/presentacion/vistas.dart — widgets tontos
class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({
    super.key,
    required this.alGuardar,   // Future<bool> Function(String laboratorio, String litros)
    required this.error,       // String?
    required this.guardando,   // bool
  });
}
class ListaHistorial extends StatelessWidget {
  const ListaHistorial({super.key, required this.consumos, required this.total});
}
class PanelMeta extends StatelessWidget {
  const PanelMeta({
    super.key,
    required this.usado,      // double
    required this.meta,       // double
    required this.avance,     // double
    required this.superada,   // bool
    required this.alSubir,    // VoidCallback
    required this.alBajar,    // VoidCallback
  });
}
class PantallasEcoTrack extends StatefulWidget {
  const PantallasEcoTrack({
    super.key,
    required this.titulo,
    required this.registro,
    required this.historial,
    required this.meta,
  });
}

// lib/variantes/a_change_notifier.dart
class AppChangeNotifier extends StatefulWidget {
  const AppChangeNotifier({super.key, required this.repositorio});
}
class RegistroCN extends StatelessWidget  { const RegistroCN({super.key, required this.vm}); }
class HistorialCN extends StatelessWidget { const HistorialCN({super.key, required this.vm}); }
class MetaCN extends StatelessWidget      { const MetaCN({super.key, required this.vm}); }

// lib/variantes/b_provider.dart
class AppProvider extends StatelessWidget {
  const AppProvider({super.key, required this.repositorio});
}
class RegistroProvider extends StatelessWidget  { const RegistroProvider({super.key}); }
class HistorialProvider extends StatelessWidget { const HistorialProvider({super.key}); }
class MetaProvider extends StatelessWidget      { const MetaProvider({super.key}); }
```

### Textos y llaves que buscan las pruebas

| Dónde | Texto o llave exacta |
| --- | --- |
| Barra inferior | `Registro`, `Historial`, `Meta` |
| Campo de litros | `Key('litros')` |
| Botón | `Guardar` |
| Aviso al guardar | `Consumo guardado` |
| Errores | `Escribe los litros con número` · `Los litros deben ser mayores que cero` · `Los litros superan el tope de 10000` |
| Historial vacío | `Sin consumos` |
| Total | `Total: 12.5 L` (un decimal) |
| Meta | `Usado: 12.5 de 100.0 L` (un decimal en los dos números) |
| Estado de la meta | `Dentro de la meta` · `Te pasaste de la meta` |
| Botones de la meta | `Key('bajarMeta')` · `Key('subirMeta')` |

Los títulos de la `AppBar` no deben ser exactamente `Meta` ni `Historial`, porque se confundirían con la barra inferior. Usen `A · ChangeNotifier` y `B · provider`.

---

## Etapa 1 — Dominio (7 min)

**Archivos:** `lib/dominio/consumo.dart` y `lib/dominio/meta.dart`.

1. Escriban la constante, la entidad y `validarLitros`. Las reglas van **en este orden**: no es número (`null`), menor o igual a cero, mayor a 10000. Si nada falla, regresa `null`.
2. Escriban las tres constantes de la meta.
3. `ajustarMeta` suma el cambio a la meta actual, pero **nunca** regresa menos que `metaMinima`.
4. `avanceDeMeta` regresa qué fracción de la meta ya se usó, entre 0 y 1. Si se rebasó la meta, regresa 1. Cuiden la división entre cero.

**Pistas:**

- Pregúntense: "si apago Flutter, ¿esto sigue teniendo sentido?". Si sí, no importa nada de `package:flutter`.
- `clamp` regresa `num`, no `double`. Si lo usan, conviertan el resultado.

**Pregunta de control (respóndanla en voz alta):** ¿`laboratoriosUtez` es estado? ¿Y `metaInicial`?

**Comprueben:**

```bash
flutter test test/etapa1_dominio_test.dart -r expanded   # 10 pruebas
bash verificar_estado.sh                                 # punto 2: dominio
```

`git commit -m "feat(dominio): consumo y reglas de meta"`

---

## Etapa 2 — Datos (5 min)

**Archivos:** `lib/datos/consumo_repository.dart` y `lib/datos/memoria_consumo_repository.dart`.

1. El contrato es una clase abstracta con los dos métodos de arriba.
2. La implementación en memoria cumple el contrato usando una lista privada.
3. `todos()` regresa una lista que **nadie** pueda modificar desde fuera.

**Pistas:**

- Los métodos son `async` aunque la lista responda al instante: una fuente real (red, disco) tardaría.
- El contrato habla como el dominio (`guardar`, `todos`). No dice "lista", "JSON" ni "HTTP".
- Busquen en la documentación de `List` un constructor que cree una copia no modificable.

**Pregunta de control:** ¿Quién es la fuente de verdad: el repositorio o el ViewModel?

**Comprueben:**

```bash
flutter test test/etapa2_datos_test.dart -r expanded   # 4 pruebas
```

`git commit -m "feat(datos): contrato y repositorio en memoria"`

---

## Etapa 3 — ViewModel con `ChangeNotifier` (13 min)

**Archivo:** `lib/presentacion/consumos_view_model.dart`.

Es el **único dueño** del estado compartido. Recibe el **contrato** del repositorio por constructor: nunca crea uno, ni sabe si es memoria o nube.

1. Extiendan `ChangeNotifier`, importado de `package:flutter/foundation.dart`. **No** de `material.dart`: el ViewModel no dibuja.
2. Declaren el estado compartido con sus valores iniciales.
3. Escriban los tres **derivados** como getters: `total` suma los litros, `avance` usa la regla del dominio y `metaSuperada` es verdadero cuando el total es **mayor** que la meta.
4. `cargar()` lee del repositorio y avisa.
5. `guardar(laboratorio, litrosTexto)`:
    1. Convierte el texto a número. Acepta coma decimal (`12,5`) y espacios.
    2. Le pregunta al dominio si es válido. Si no lo es: guarda el mensaje en `error`, avisa y regresa `false` **sin tocar el repositorio**.
    3. Si es válido: marca `guardando`, limpia el error y avisa.
    4. Guarda en el repositorio y vuelve a leer la lista completa de él.
    5. Desmarca `guardando`, avisa y regresa `true`.
6. `subirMeta()` y `bajarMeta()` cambian la meta **un paso** usando la regla del dominio, y avisan.

**Pistas:**

- Cada vez que cambie algo que la pantalla muestra, llamen `notifyListeners()`. Si no, el dato cambia y nadie se entera.
- El mínimo de la meta ya lo decide `ajustarMeta`. Si escriben `if (meta < 10)` en el ViewModel, la regla quedó duplicada.
- Después de guardar, **reasignen** `consumos` con lo que regresa `todos()`. No hagan `consumos.add(...)`.

**Preguntas de control:**

- ¿Qué pasa en la pantalla si olvidan el último `notifyListeners()` de `guardar`?
- ¿Por qué `total` es un getter y no un campo que se actualiza al guardar?

**Comprueben:**

```bash
flutter test test/etapa3_viewmodel_test.dart -r expanded   # 11 pruebas
bash verificar_estado.sh                                   # punto 3: ViewModel
```

`git commit -m "feat(presentacion): ConsumosViewModel con ChangeNotifier"`

---

## Etapa 4 — Vistas tontas y cableado A: `ChangeNotifier` puro (15 min)

### 4a. `lib/presentacion/vistas.dart` (8 min)

Cuatro widgets que **reciben datos y callbacks**. No saben qué gestor hay arriba.

1. `FormularioRegistro`: un desplegable de laboratorios, el campo de litros y el botón `Guardar`. El laboratorio elegido y el texto del campo son **estado efímero**: viven en su `State`. Al tocar `Guardar`, llama a `alGuardar` y espera la respuesta. Si se guardó, limpia el campo y muestra el `SnackBar`. El `error` se muestra en el campo y el botón se desactiva mientras `guardando` sea verdadero.
2. `ListaHistorial`: `Sin consumos` si la lista está vacía. Si no, una primera fila con el total y una fila por consumo.
3. `PanelMeta`: el texto `Usado: … de … L`, una barra de avance, el texto de estado y los dos botones con sus llaves.
4. `PantallasEcoTrack`: `Scaffold` con `AppBar`, una barra inferior de tres destinos y un cuerpo que muestre la pestaña elegida. La pestaña activa es estado efímero.

**Pistas:**

- Usen `IndexedStack` en el cuerpo: mantiene montadas las tres pestañas y solo enseña una.
- En `DropdownButtonFormField`, el valor inicial se pasa con `initialValue`.
- Liberen el `TextEditingController` en `dispose()`.
- Después de un `await`, revisen `mounted` antes de usar el `context`.
- Si `vistas.dart` necesita importar algo más que `material.dart` y `dominio/consumo.dart`, se están saltando una capa.

### 4b. `lib/variantes/a_change_notifier.dart` (5 min)

1. `AppChangeNotifier` es un `StatefulWidget`. Su `State` crea el ViewModel **una sola vez**, lo carga y lo **libera** en `dispose()`.
2. Su `build` arma un `MaterialApp` cuyo `home` es `PantallasEcoTrack`. Cada pestaña recibe **el mismo** ViewModel por constructor.
3. Cada adaptador (`RegistroCN`, `HistorialCN`, `MetaCN`) envuelve su vista tonta en un `ListenableBuilder` que escucha al ViewModel.

**Pistas:**

- Si crean el ViewModel dentro de `build`, se crea uno nuevo en cada redibujo y los datos "desaparecen". Por eso `AppChangeNotifier` es `StatefulWidget`.
- `late final` les permite crear un campo usando `widget.repositorio`.
- Quien crea el ViewModel es quien lo libera. Ningún adaptador llama a `dispose()`.

### 4c. `lib/main_change_notifier.dart` (2 min)

Arranca `AppChangeNotifier` con un `MemoriaConsumoRepository`. Es el único lugar, junto con `main.dart`, que conoce la implementación en memoria.

**Pregunta de control:** ¿Cuántos constructores reciben `vm`? Si Meta tuviera una subpantalla de detalle, ¿cuántos serían?

**Comprueben:**

```bash
flutter test test/etapa4_change_notifier_test.dart -r expanded   # 5 pruebas
bash verificar_estado.sh                                         # puntos 4 y 5
flutter run -t lib/main_change_notifier.dart
```

Prueben a mano: guarden 12.5 en Registro, vayan a Historial y luego a Meta. Guarden 120 y vean el aviso de la meta.

`git commit -m "feat(variante-a): vistas tontas y cableado con ChangeNotifier"`

---

## Etapa 5 — Cableado B: provider (10 min)

**Archivos:** `lib/variantes/b_provider.dart` y `lib/main.dart`.

**Regla de oro de esta etapa: no toquen** `consumos_view_model.dart` **ni** `vistas.dart`**.** Si sienten que hay que cambiarlos, algo está mal cableado.

1. `AppProvider` es un `StatelessWidget`. Cuelga **un** `ChangeNotifierProvider` **arriba** de `MaterialApp`, cuyo `create` construye y carga el ViewModel con el repositorio recibido.
2. Los tres adaptadores **no reciben nada** por constructor: piden el ViewModel al árbol.
3. Dentro de `build`, para **mostrar**, usen `context.watch<ConsumosViewModel>()`.
4. En los callbacks (`alGuardar`, `alSubir`, `alBajar`), para **actuar**, usen `context.read<ConsumosViewModel>()`.
5. Cambien `lib/main.dart` para que arranque `AppProvider` con el repositorio en memoria.

**Pistas:**

- `watch` para **mostrar**, `read` para **actuar**. Un `watch` dentro de `onPressed` lanza un error al tocar el botón.
- `ProviderNotFoundException` significa que el widget que pide el ViewModel no tiene un `ChangeNotifierProvider` de ese tipo arriba.
- Aquí no hay `dispose()` escrito por ustedes: ¿quién lo hace ahora?
- Como los adaptadores no tienen parámetros, pueden ser `const`.

**Preguntas de control:**

- Entre A y B, ¿qué archivos cambiaron? ¿Cambió una sola línea del ViewModel?
- ¿Cuántos constructores reciben `vm` ahora?

**Comprueben:**

```bash
flutter test test/etapa5_provider_test.dart -r expanded   # 5 pruebas
bash verificar_estado.sh                                  # todo en OK salvo docs/estado.md
flutter test                                              # 35 pruebas
flutter run
```

`git commit -m "feat(variante-b): cableado con provider sobre el mismo ViewModel"`

---

## Etapa 6 — `docs/estado.md` (5 min)

Cada celda se responde con **una frase y una evidencia** de su código: un nombre de clase, un archivo o una prueba. "Sí" solo no cuenta.

```markdown
# Gestión de estado — EcoTrack Meta

**Equipo:**
**Fecha:**

## Tipos de estado en nuestro código

| Dato | Tipo (efímero, compartido, derivado, persistido) | Dónde vive |
|---|---|---|
| Pestaña activa | | |
| Texto del campo de litros | | |
| consumos y meta | | |
| total y metaSuperada | | |
| Lo que regresa todos() | | |

## Criterios

| Criterio | A · ChangeNotifier puro | B · provider |
|---|---|---|
| Dato compartido | | |
| Capas | | |
| Encaje con el diagrama | | |
| Constructores que reciben vm | | |
| Quién libera el ViewModel | | |
| Costo de adoptarla ahora | | |
| Sustitución de la fuente de datos | | |

## Elección

Elegimos:
Se mantiene esta pieza del diagrama:
Esta pieza es la que podría sustituirse después:
```

**Comprueben:** `bash verificar_estado.sh` sale **todo en OK**.

`git commit -m "docs: comparación de gestores con evidencia"`

---

## Si algo falla

| Síntoma | Causa probable |
| --- | --- |
| Guardo y Historial no cambia | Falta un `notifyListeners()`, o el adaptador no escucha al ViewModel. |
| Los datos se borran al cambiar de pestaña | El ViewModel se crea dentro de un `build`. |
| `Cannot add to an unmodifiable list` | Están modificando la lista que regresa `todos()`. Reasignen en lugar de agregar. |
| `ProviderNotFoundException` | No hay `ChangeNotifierProvider<ConsumosViewModel>` arriba del widget que lo pide. |
| `Tried to listen to a value exposed with provider, from outside of the widget tree` | Usaron `watch` en un callback. Ahí va `read`. |
| `A ConsumosViewModel was used after being disposed` | Alguien además del dueño llamó `dispose()`. |
| La prueba no encuentra `Usado: 12.5 de 100.0 L` | Revisen el formato: un decimal en los **dos** números. |
| `Target of URI doesn't exist: package:ecotrack_meta/...` | El proyecto no se llama `ecotrack_meta` o falta un archivo del contrato. |

---

## Definición de terminado

- [ ]  
    
    `flutter test` pasa completo: 35 pruebas.
    
- [ ]  
    
    `bash verificar_estado.sh` sale todo en OK.
    
- [ ]  
    
    `flutter run` y `flutter run -t lib/main_change_notifier.dart` se ven y se comportan igual.
    
- [ ]  
    
    `consumos_view_model.dart` no cambió entre la etapa 4 y la etapa 5.
    
- [ ]  
    
    Ninguna regla del dominio está copiada en el ViewModel ni en las vistas.
    
- [ ]  
    
    Hay un commit por etapa y `docs/estado.md` está lleno con evidencia.
    

## Cómo se evalúa

| Concepto | Puntos |
| --- | --- |
| Etapa 1 en verde | 1 |
| Etapa 2 en verde | 1 |
| Etapa 3 en verde | 2 |
| Etapa 4 en verde | 2 |
| Etapa 5 en verde | 2 |
| `verificar_estado.sh` todo en OK | 1 |
| `docs/estado.md` con evidencia en cada celda | 1 |
| **Total** | **10** |

Una etapa cuenta solo si **todas** las pruebas de su archivo pasan con las pruebas originales.

---

## Retos extra (si les sobra tiempo)

No suman puntos, pero son buenas preguntas de examen.

1. `context.select`**:** en `MetaProvider`, hagan que el panel se redibuje solo cuando cambien `total` o `meta`, y no cuando cambie `guardando`.
2. **Sustitución en vivo:** creen `LentoConsumoRepository` en `datos/` con un `Future.delayed` de un segundo y úsenlo **solo desde** `main.dart`. ¿Se desactiva el botón mientras guarda? ¿Qué pantalla tuvieron que tocar?
3. **Cuarta pantalla:** agreguen "Resumen por laboratorio" en las dos variantes. Cuenten cuántas líneas cambiaron en `a_change_notifier.dart` y cuántas en `b_provider.dart`.