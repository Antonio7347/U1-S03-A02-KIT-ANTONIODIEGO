import 'package:ecotrack_meta/datos/consumo_repository.dart';
import 'package:ecotrack_meta/presentacion/consumos_view_model.dart';
import 'package:ecotrack_meta/presentacion/vistas.dart';
import 'package:flutter/material.dart';

class AppChangeNotifier extends StatefulWidget {
  const AppChangeNotifier({super.key, required this.repositorio});

  final ConsumoRepository repositorio;

  @override
  State<AppChangeNotifier> createState() => _AppChangeNotifierState();
}

class _AppChangeNotifierState extends State<AppChangeNotifier> {
  late final ConsumosViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = ConsumosViewModel(widget.repositorio)..cargar();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PantallasEcoTrack(
        titulo: 'A · ChangeNotifier',
        registro: RegistroCN(vm: vm),
        historial: HistorialCN(vm: vm),
        meta: MetaCN(vm: vm),
      ),
    );
  }
}

class RegistroCN extends StatelessWidget {
  const RegistroCN({super.key, required this.vm});

  final ConsumosViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return FormularioRegistro(
          alGuardar: vm.guardar,
          error: vm.error,
          guardando: vm.guardando,
        );
      },
    );
  }
}

class HistorialCN extends StatelessWidget {
  const HistorialCN({super.key, required this.vm});

  final ConsumosViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return ListaHistorial(
          consumos: vm.consumos,
          total: vm.total,
        );
      },
    );
  }
}

class MetaCN extends StatelessWidget {
  const MetaCN({super.key, required this.vm});

  final ConsumosViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return PanelMeta(
          usado: vm.total,
          meta: vm.meta,
          avance: vm.avance,
          superada: vm.metaSuperada,
          alSubir: vm.subirMeta,
          alBajar: vm.bajarMeta,
        );
      },
    );
  }
}
