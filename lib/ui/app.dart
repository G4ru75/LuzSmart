import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luz_smart_ilumina/ui/homepage/homepage.dart';
import 'package:luz_smart_ilumina/ui/simuladorpage/luz_simulador.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Luz Smart Ilumina',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      defaultTransition: Transition.fade,
      getPages: [
        GetPage(
          name: '/home',
          page: () => Home(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 250),
        ),
        GetPage(
          name: '/simulador',
          page: () => luz_simulador(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 250),
        ),
      ],
      unknownRoute: GetPage(
        name: '/404',
        page: () => Scaffold(
          appBar: AppBar(title: const Text('Página no encontrada')),
          body: const Center(child: Text('La página solicitada no existe')),
        ),
      ),
    );
  }
}
