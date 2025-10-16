import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luz_smart_ilumina/controller/luz_controller.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/luz_model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final LuzController c = Get.find<LuzController>();
  final TextEditingController txtNombreLuz = TextEditingController();
  bool _pushedSim = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    txtNombreLuz.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading / error
      if (c.loading.isTrue) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.amber.shade600),
                const SizedBox(height: 16),
                const Text('Cargando luz...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      }

      final err = c.error.value;
      if (err != null) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: $err', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => c.error.value = null,
                        child: const Text('Reintentar'),
                      ),
                      OutlinedButton(
                        onPressed: () => c.limpiarLuzPersistente(),
                        child: const Text('Nueva Luz'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final luz = c.luz.value;

      // Si no hay luz registrada, mostrar formulario para crearla
      if (luz == null) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text('Configurar Luz Smart'),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      size: 64,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Nombre de tu luz',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Elige un nombre identificativo para tu luz inteligente',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: txtNombreLuz,
                  decoration: InputDecoration(
                    hintText: 'Ej: Luz del Salón',
                    prefixIcon: const Icon(Icons.lightbulb),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.amber.shade600,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text(
                      'Crear y Generar QR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      final nombre = txtNombreLuz.text.trim();
                      if (nombre.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Por favor, ingresa un nombre para tu luz',
                            ),
                            backgroundColor: Colors.orange.shade600,
                          ),
                        );
                        return;
                      }
                      final nueva = Luces(
                        nombre: nombre,
                        encendida: false,
                        intensidad: 0.8,
                        color: Colors.amber,
                        idHabitacion: null,
                        vinculada: false,
                      );
                      await c.crearLuz(nueva);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Si la luz está vinculada, navegar al simulador
      if (luz.vinculada && !_pushedSim) {
        _pushedSim = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed('/simulador');
        });
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  luz.color.withOpacity(0.3),
                  luz.color.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: luz.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lightbulb, size: 64, color: luz.color),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Abriendo simulador...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: luz.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CircularProgressIndicator(color: luz.color),
                ],
              ),
            ),
          ),
        );
      }

      // Reset flag cuando vuelve de simulador
      if (_pushedSim && !luz.vinculada) {
        _pushedSim = false;
      }

      // Mostrar QR y datos de la luz
      final dataJson = jsonEncode(luz.toMap());
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Tu Luz Smart'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        // ... resto del código del QR y UI (igual que antes)
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Tarjeta principal con información de la luz
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      luz.color.withOpacity(0.1),
                      luz.color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: luz.color.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: luz.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            luz.encendida
                                ? Icons.lightbulb
                                : Icons.lightbulb_outline,
                            size: 32,
                            color: luz.color,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                luz.nombre.isEmpty ? 'Luz' : luz.nombre,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Estado: ${luz.encendida ? 'Encendida' : 'Apagada'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: luz.encendida
                                      ? Colors.green.shade600
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ID con botón para copiar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tag,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ID: ${luz.id}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Intensidad y estado de vinculación
                    Row(
                      children: [
                        Icon(
                          Icons.brightness_6,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text('Intensidad: ${(luz.intensidad * 100).round()}%'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: luz.vinculada
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            luz.vinculada ? 'Vinculada' : 'Sin vincular',
                            style: TextStyle(
                              fontSize: 12,
                              color: luz.vinculada
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Código QR
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Código QR para Vincular',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: QrImageView(
                        data: dataJson,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Escanea este código con la app de control remoto',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Botón para ver simulador manualmente
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('Ver Simulador'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: luz.color,
                    side: BorderSide(color: luz.color),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.toNamed('/simulador');
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Información adicional
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Información',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cuando la luz sea vinculada desde el control remoto, se abrirá automáticamente la simulación en tiempo real.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
