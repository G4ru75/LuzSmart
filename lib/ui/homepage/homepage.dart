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
  final LuzController c = Get.find();
  final TextEditingController txtNombreLuz = TextEditingController();
  bool _pushedSim = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading / error
      if (c.loading.isTrue) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final err = c.error.value;
      if (err != null) {
        return Scaffold(body: Center(child: Text('Error: $err')));
      }

      final luz = c.luz.value;

      //Si no hay luz registrada pone el formulario para crearla
      if (luz == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Crear luz')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nombre de la luz'),
                const SizedBox(height: 8),
                TextField(
                  controller: txtNombreLuz,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Luz Sala',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar y generar QR'),
                    onPressed: () async {
                      final nombre = txtNombreLuz.text.trim();
                      if (nombre.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ingresa un nombre')),
                        );
                        return;
                      }
                      final nueva = Luces(
                        nombre: nombre,
                        encendida: false,
                        intensidad: 0.8,
                        color: Colors.amber,
                        idHabitacion: null, // lo define el control remoto
                        vinculada: false, // el control remoto la pondrá en true
                      );
                      await c.crearLuz(
                        nueva,
                      ); // crea en Firestore y empieza stream
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Si la luz está vinculada muestra el simulador sino muestra el QR
      if (luz.vinculada && !_pushedSim) {
        _pushedSim = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed('/simulador');
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final dataJson = jsonEncode(luz.toMap());
      return Scaffold(
        appBar: AppBar(title: const Text('QR de la luz')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: Text(luz.nombre.isEmpty ? 'Luz' : luz.nombre),
                  subtitle: Text(
                    'ID: ${luz.id}\n'
                    'Encendida: ${luz.encendida} • '
                    'Intensidad: ${(luz.intensidad * 100).round()}% • '
                    'Vinculada: ${luz.vinculada}',
                  ),
                  trailing: CircleAvatar(backgroundColor: luz.color),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: dataJson,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    dataJson,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cuando "vinculada" sea true desde el control remoto, se abrirá la simulación automáticamente.',
              ),
            ],
          ),
        ),
      );
    });
  }
}
