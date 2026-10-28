import 'package:ecotrack_meta/dominio/consumo.dart';

abstract class ConsumoRepository {
  Future<void> guardar(Consumo consumo);
  Future<List<Consumo>> todos();
}
