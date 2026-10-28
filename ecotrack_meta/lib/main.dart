import 'package:ecotrack_meta/datos/memoria_consumo_repository.dart';
import 'package:ecotrack_meta/variantes/b_provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(AppProvider(repositorio: MemoriaConsumoRepository()));
}
