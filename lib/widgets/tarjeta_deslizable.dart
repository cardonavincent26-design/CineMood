import 'package:flutter/material.dart';

/// Hace que su contenido se pueda arrastrar como en Tinder:
/// derecha = guardar, izquierda = "ahora no". Sin librerías externas.
/// [id] identifica la tarjeta: si cambia, el estado del arrastre se reinicia.
class TarjetaDeslizable extends StatefulWidget {
  final int id;
  final Widget child;
  final VoidCallback onGuardar;
  final VoidCallback onDescartar;

  const TarjetaDeslizable({
    super.key,
    required this.id,
    required this.child,
    required this.onGuardar,
    required this.onDescartar,
  });

  @override
  State<TarjetaDeslizable> createState() => TarjetaDeslizableState();
}

class TarjetaDeslizableState extends State<TarjetaDeslizable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  Offset _arrastre = Offset.zero;
  Offset _origen = Offset.zero;
  Offset _destino = Offset.zero;
  bool _saliendo = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      setState(() {
        _arrastre = Offset.lerp(_origen, _destino, Curves.easeOut.transform(_ctrl.value))!;
      });
    });
  }

  @override
  void didUpdateWidget(TarjetaDeslizable anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.id != widget.id) {
      // Llegó otra tarjeta: empieza centrada y quieta.
      _ctrl.stop();
      _arrastre = Offset.zero;
      _saliendo = false;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _animarA(Offset destino, [VoidCallback? alTerminar]) {
    _origen = _arrastre;
    _destino = destino;
    _ctrl.forward(from: 0).whenComplete(() {
      if (alTerminar != null && mounted) alTerminar();
    });
  }

  /// También lo usan los botones de abajo (descartar / guardar).
  void salir({required bool derecha}) {
    if (_saliendo) return;
    _saliendo = true;
    final ancho = MediaQuery.of(context).size.width;
    _animarA(Offset(derecha ? ancho * 1.5 : -ancho * 1.5, _arrastre.dy), () {
      if (derecha) {
        widget.onGuardar();
      } else {
        widget.onDescartar();
      }
    });
  }

  void _alSoltar(DragEndDetails d, double ancho) {
    final velocidad = d.velocity.pixelsPerSecond.dx;
    if (_arrastre.dx > ancho * 0.28 || velocidad > 900) {
      salir(derecha: true);
    } else if (_arrastre.dx < -ancho * 0.28 || velocidad < -900) {
      salir(derecha: false);
    } else {
      _animarA(Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final ancho = restricciones.maxWidth;
        final progreso = (_arrastre.dx / (ancho * 0.35)).clamp(-1.0, 1.0).toDouble();

        return GestureDetector(
          onPanStart: (_) => _ctrl.stop(),
          onPanUpdate: (d) {
            if (_saliendo) return;
            setState(() => _arrastre += d.delta);
          },
          onPanEnd: (d) {
            if (!_saliendo) _alSoltar(d, ancho);
          },
          child: Transform.translate(
            offset: _arrastre,
            child: Transform.rotate(
              angle: progreso * 0.25,
              child: Stack(
                children: [
                  Positioned.fill(child: widget.child),
                  Positioned(
                    top: 26,
                    left: 20,
                    child: _Sello(
                      texto: 'GUARDAR',
                      color: Colors.greenAccent,
                      opacidad: progreso.clamp(0.0, 1.0).toDouble(),
                      angulo: -0.2,
                    ),
                  ),
                  Positioned(
                    top: 26,
                    right: 20,
                    child: _Sello(
                      texto: 'AHORA NO',
                      color: Colors.redAccent,
                      opacidad: (-progreso).clamp(0.0, 1.0).toDouble(),
                      angulo: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Sello extends StatelessWidget {
  final String texto;
  final Color color;
  final double opacidad;
  final double angulo;

  const _Sello({
    required this.texto,
    required this.color,
    required this.opacidad,
    required this.angulo,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacidad,
      child: Transform.rotate(
        angle: angulo,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(texto,
              style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}
