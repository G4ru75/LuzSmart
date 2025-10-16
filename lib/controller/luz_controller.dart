import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/luz_model.dart';

class LuzController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String nombreColeccion = 'luces';

  // Persistencia local con GetStorage
  static const String _keyLuzID = 'current_luz_id';
  final GetStorage _box = GetStorage();

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
      final String? luzId = _box.read<String>(_keyLuzID);
      if (luzId != null && luzId.isNotEmpty) {
        final doc = await _firestore
            .collection(nombreColeccion)
            .doc(luzId)
            .get();
        if (doc.exists && doc.data() != null) {
          await _startStream(luzId);
        } else {
          await _box.remove(_keyLuzID); // limpiar si no existe en Firestore
        }
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  /// Crea o actualiza la luz y comienza a escucharla en tiempo real
  Future<void> crearLuz(Luces nueva) async {
    try {
      loading.value = true;
      final ref = _firestore.collection(nombreColeccion).doc(nueva.id);
      await ref.set(nueva.toMap(), SetOptions(merge: true));

      await _box.write(_keyLuzID, nueva.id); // persistir ID
      luz.value = nueva; // estado inmediato

      await _startStream(nueva.id);
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      loading.value = false;
    }
  }

  /// Empieza a escuchar una luz existente por ID y la persiste
  Future<void> escucharLuzID(String id) async {
    try {
      await _box.write(_keyLuzID, id);
      await _startStream(id);
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// Alias compatible con tu UI anterior
  Future<void> escucharLuzPorId(String id) => escucharLuzID(id);

  /// Limpia persistencia y estado
  Future<void> limpiarLuzPersistente() async {
    try {
      await _box.remove(_keyLuzID);
      await _sub?.cancel();
      luz.value = null;
    } catch (e) {
      error.value = e.toString();
    }
  }

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
      } else {
        // Si eliminaron el doc en Firestore, resetea local
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
