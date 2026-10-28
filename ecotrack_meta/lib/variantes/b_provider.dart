import 'package:ecotrack_meta/datos/consumo_repository.dart';
import 'package:ecotrack_meta/presentacion/consumos_view_model.dart';
import 'package:ecotrack_meta/presentacion/vistas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppProvider extends StatelessWidget {
  const AppProvider({super.key, required this.repositorio});

  final ConsumoRepository repositorio;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConsumosViewModel>(
      create: (_) => ConsumosViewModel(repositorio)..cargar(),
      child: const MaterialApp(
        home: PantallasEcoTrack(
          titulo: 'B · provider',
          registro: RegistroProvider(),
          historial: HistorialProvider(),
          meta: MetaProvider(),
        ),
      ),
    );
  }
}

class RegistroProvider extends StatelessWidget {
  const RegistroProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final vmWatch = context.watch<ConsumosViewModel>();
    final vmRead = context.read<ConsumosViewModel>();

    return FormularioRegistro(
      alGuardar: vmRead.guardar,
      error: vmWatch.error,
      guardando: vmWatch.guardando,
    );
  }
}

class HistorialProvider extends StatelessWidget {
  const HistorialProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConsumosViewModel>();

    return ListaHistorial(
      consumos: vm.consumos,
      total: vm.total,
    );
  }
}

class MetaProvider extends StatelessWidget {
  const MetaProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final vmWatch = context.watch<ConsumosViewModel>();
    final vmRead = context.read<ConsumosViewModel>();

    return PanelMeta(
      usado: vmWatch.total,
      meta: vmWatch.meta,
      avance: vmWatch.avance,
      superada: vmWatch.metaSuperada,
      alSubir: vmRead.subirMeta,
      alBajar: vmRead.bajarMeta,
    );
  }
}
