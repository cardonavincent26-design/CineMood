/// Convierte minutos a "1h 45min".
String formatearDuracion(int minutos) {
  final h = minutos ~/ 60;
  final m = minutos % 60;
  if (h == 0) return '${m}min';
  if (m == 0) return '${h}h';
  return '${h}h ${m}min';
}

String formatearValoracion(double v) => '★ ${v.toStringAsFixed(1)}';
