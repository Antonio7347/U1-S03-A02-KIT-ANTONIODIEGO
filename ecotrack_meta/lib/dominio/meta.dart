const metaInicial = 100.0;
const pasoMeta = 10.0;
const metaMinima = 10.0;

double ajustarMeta(double actual, double cambio) {
  final nueva = actual + cambio;
  return nueva < metaMinima ? metaMinima : nueva;
}

double avanceDeMeta({required double total, required double meta}) {
  if (meta <= 0) return 0.0;
  final avance = total / meta;
  if (avance < 0.0) return 0.0;
  if (avance > 1.0) return 1.0;
  return avance;
}
