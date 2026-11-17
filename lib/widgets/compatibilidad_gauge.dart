import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/colores.dart';

/// Medidor circular (270°) del porcentaje de compatibilidad.
/// Se "llena" con una animación cuando llega el valor. Sin librerías ni SVG.
class CompatibilidadGauge extends StatelessWidget {
  /// Porcentaje 0-100, o null mientras se calcula.
  final int? valor;
  final double tamano;

  const CompatibilidadGauge({super.key, required this.valor, this.tamano = 112});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: (valor ?? 0) / 100),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, progreso, _) => CustomPaint(
          painter: _GaugePainter(progreso),
          child: Center(
            child: Text(
              valor == null ? '…' : '${(progreso * 100).round()}%',
              style: TextStyle(fontSize: tamano * 0.26, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progreso; // 0.0 a 1.0
  const _GaugePainter(this.progreso);

  static const double _trazo = 10;
  static const double _inicio = 3 * math.pi / 4; // el arco empieza abajo a la izquierda
  static const double _barrido = 3 * math.pi / 2; // y recorre 270°

  @override
  void paint(Canvas canvas, Size size) {
    final area = (Offset.zero & size).deflate(_trazo / 2);

    final fondo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _trazo
      ..strokeCap = StrokeCap.round
      ..color = Colores.superficie;
    canvas.drawArc(area, _inicio, _barrido, false, fondo);

    if (progreso <= 0) return;
    final frente = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _trazo
      ..strokeCap = StrokeCap.round
      ..color = Color.lerp(Colors.deepOrangeAccent, Colors.greenAccent, progreso)!;
    canvas.drawArc(area, _inicio, _barrido * progreso, false, frente);
  }

  @override
  bool shouldRepaint(_GaugePainter anterior) => anterior.progreso != progreso;
}
