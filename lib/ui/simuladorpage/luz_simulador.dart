import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luz_smart_ilumina/controller/luz_controller.dart';
import '../../models/luz_model.dart';

/// Simulador de luz: pantalla completa sin posibilidad de regresar
/// El fondo completo toma el color de la luz cuando está encendida
class luz_simulador extends StatelessWidget {
  const luz_simulador({super.key});

  @override
  Widget build(BuildContext context) {
    final LuzController c = Get.find<LuzController>();

    return Obx(() {
      final Luces? l = c.luz.value;

      if (l == null) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }

      final baseColor = l.color;
      final isOn = l.encendida;
      final intensity = l.intensidad.clamp(0.0, 1.0);

      // Color de fondo: si está encendida usa el color de la luz, si no negro
      final backgroundColor = isOn ? baseColor : Colors.black;

      // Para el AppBar, si está encendida usar el color de la luz
      final appBarColor = isOn ? baseColor : Colors.grey.shade900;
      final appBarTextColor = isOn
          ? const Color.fromRGBO(0, 0, 0, 1)
          : Colors.white;

      return WillPopScope(
        onWillPop: () async => false, // Bloquea el botón físico de atrás
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false, // Sin botón de back
            title: Text(
              l.nombre.isEmpty ? 'Luz Smart' : l.nombre,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: appBarTextColor,
              ),
            ),
            centerTitle: true,
            backgroundColor: appBarColor,
            foregroundColor: appBarTextColor,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: 'Cerrar simulador',
                icon: Icon(Icons.close, color: appBarTextColor),
                onPressed: () {
                  Get.offAllNamed('/home');
                },
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              // Si está encendida, gradiente radial para efecto de luz
              gradient: isOn
                  ? RadialGradient(
                      center: const Alignment(0, -0.2),
                      radius: 1.5,
                      colors: [
                        baseColor.withOpacity(1.0),
                        baseColor.withOpacity(0.8 * intensity),
                        baseColor.withOpacity(0.6 * intensity),
                        baseColor.withOpacity(0.3 * intensity),
                        Colors.black.withOpacity(0.1),
                      ],
                      stops: const [0.0, 0.2, 0.4, 0.7, 1.0],
                    )
                  : null,
              color: isOn ? null : Colors.black,
            ),
            child: Stack(
              children: [
                // Efecto de parpadeo sutil cuando está encendida
                if (isOn)
                  AnimatedOpacity(
                    opacity: 0.1 + (intensity * 0.2),
                    duration: const Duration(seconds: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, 0),
                          radius: 2.0,
                          colors: [
                            baseColor.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                // Información central cuando está apagada
                if (!isOn)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 120,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Luz Apagada',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.nombre,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Barra de estado en la parte inferior
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 32,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            // Indicador de color
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: baseColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Estado ON/OFF
                            Text(
                              isOn ? 'ENCENDIDA' : 'APAGADA',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),

                            const Spacer(),

                            // Porcentaje de intensidad
                            Text(
                              '${(intensity * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Barra de progreso de intensidad
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: intensity,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: baseColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: baseColor.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Información adicional en la esquina superior
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi,
                          size: 16,
                          color: l.vinculada ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l.vinculada ? 'Conectada' : 'Desconectada',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
