import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/luz_model.dart';

class LuzController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String nombreColeccion = 'luces';
  static const String _keyLuzID = 'current_luz_id';

  // Estado
  final Rxn<Luces> luz = Rxn<Luces>();
  final RxBool loading = false.obs;
  final RxnString error = RxnString();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _cargarLuzPersistente();
  }

  /// Carga la luz guardada localmente al iniciar
  Future<void> _cargarLuzPersistente() async {
    try {
      loading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final luzId = prefs.getString(_keyLuzID);

      if (luzId != null && luzId.isNotEmpty) {
        final doc = await _firestore
            .collection(nombreColeccion)
            .doc(luzId)
            .get();
        if (doc.exists && doc.data() != null) {
          await _startStream(luzId);
        } else {
          await prefs.remove(_keyLuzID); // Limpia si no hay ID válido
        }
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  /// Crea/actualiza la luz y comienza a escucharla en tiempo real
  Future<void> crearLuz(Luces nueva) async {
    try {
      loading.value = true;
      final ref = _firestore.collection(nombreColeccion).doc(nueva.id);
      await ref.set(nueva.toMap(), SetOptions(merge: true));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLuzID, nueva.id); // Guarda ID de la luz

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
  Future<void> escucharLuzID(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLuzID, id); // Guarda ID de la luz

      await _startStream(id);
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// Elimina la luz persistente (útil para reset)
  Future<void> limpiarLuzPersistente() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLuzID);
      luz.value = null;
      await _sub?.cancel();
    } catch (e) {
      error.value = e.toString();
    }
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
        final nuevaLuz = Luces.fromMap(snap.data()!);
        luz.value = nuevaLuz;
      } else {
        limpiarLuzPersistente();
      }
    }, onError: (e) => error.value = e.toString());
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
