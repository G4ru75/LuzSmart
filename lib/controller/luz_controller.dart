import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../models/luz_model.dart';

class LuzController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String nombreColeccion = 'luces';

  // Estado
  final Rxn<Luces> luz = Rxn<Luces>();
  final RxBool loading = false.obs;
  final RxnString error = RxnString();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  /// Crea/actualiza la luz y comienza a escucharla en tiempo real
  Future<void> crearLuz(Luces nueva) async {
    try {
      loading.value = true;
      final ref = _firestore.collection(nombreColeccion).doc(nueva.id);
      await ref.set(nueva.toMap(), SetOptions(merge: true));
      luz.value = nueva; // estado inmediato
      await _startStream(nueva.id);
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      loading.value = false;
    }
  }

  /// Comienza a escuchar una luz existente por ID
  Future<void> escucharLuzPorId(String id) async {
    await _startStream(id);
  }

  /// Stream directo por si lo quieres usar en otro widget
  Stream<Luces> luzStream(String id) {
    return _firestore
        .collection(nombreColeccion)
        .doc(id)
        .snapshots()
        .where((s) => s.exists && s.data() != null)
        .map((s) => Luces.fromMap(s.data()!));
  }

  Future<void> _startStream(String id) async {
    await _sub?.cancel();
    _sub = _firestore.collection(nombreColeccion).doc(id).snapshots().listen((
      snap,
    ) {
      if (snap.exists && snap.data() != null) {
        luz.value = Luces.fromMap(snap.data()!);
      }
    }, onError: (e) => error.value = e.toString());
  }

  Future<void> modificarBrilloApp(double brillo) async {
    try {
      await ScreenBrightness.instance.setSystemScreenBrightness(brillo);
    } catch (e) {
      print(e.toString());
      throw 'Failed to set system brightness';
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
