import 'package:ecotrack_meta/datos/consumo_repository.dart';
import 'package:ecotrack_meta/dominio/consumo.dart';

class MemoriaConsumoRepository implements ConsumoRepository {
  final List<Consumo> _consumos = [];

  @override
  Future<void> guardar(Consumo consumo) async {
    _consumos.add(consumo);
  }

  @override
  Future<List<Consumo>> todos() async {
    return List.unmodifiable(_consumos);
  }
}
