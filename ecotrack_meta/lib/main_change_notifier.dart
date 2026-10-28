import 'package:ecotrack_meta/datos/memoria_consumo_repository.dart';
import 'package:ecotrack_meta/variantes/a_change_notifier.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(AppChangeNotifier(repositorio: MemoriaConsumoRepository()));
}
