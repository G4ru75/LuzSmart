import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luz_smart_ilumina/controller/luz_controller.dart';
import '../../models/luz_model.dart';

class luz_simulador extends StatelessWidget {
  const luz_simulador({super.key});

  @override
  Widget build(BuildContext context) {
    final LuzController c = Get.find();

    return Obx(() {
      final Luces? l = c.luz.value;

      if (l == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (!l.vinculada) {
        return Scaffold(
          appBar: AppBar(title: const Text('Luz no vinculada')),
          body: const Center(
            child: Text('Vincula la luz desde el control remoto.'),
          ),
        );
      }

      final encendida = l.encendida;
      final intensidad = l.intensidad.clamp(0.0, 1.0);
      final base = l.color;
      c.modificarBrilloApp(intensidad);

      final Widget background = encendida
          ? Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [
                    base.withOpacity(0.12 + intensidad * 0.18),
                    base.withOpacity(0.22 + intensidad * 0.48),
                    Colors.black.withOpacity(0.9 - intensidad * 0.6),
                  ],
                  stops: const [0.1, 0.45, 1.0],
                ),
              ),
            )
          : Container(color: Colors.black);

      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(l.nombre.isEmpty ? 'Luz' : l.nombre),
          backgroundColor: base,
          foregroundColor: Colors.black,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            background,
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Card(
                color: Colors.black.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: base, radius: 10),
                        const SizedBox(width: 12),
                        Text(encendida ? 'ON' : 'OFF'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: intensidad,
                            minHeight: 6,
                            color: base,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('${(intensidad * 100).round()}%'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
