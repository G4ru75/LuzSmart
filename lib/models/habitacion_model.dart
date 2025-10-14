import 'dart:convert';

/// Modelo que representa una habitación
class Habitacion {
  final String id;
  final String nombre;
  final String icono; // nombre del icono de Material Icons
  final DateTime? fechaCreacion;
  final Map<String, dynamic>? metadatos; // datos adicionales opcionales

  const Habitacion({
    required this.id,
    required this.nombre,
    required this.icono,
    this.fechaCreacion,
    this.metadatos,
  });

  Habitacion copyWith({
    String? id,
    String? nombre,
    String? icono,
    DateTime? fechaCreacion,
    Map<String, dynamic>? metadatos,
  }) => Habitacion(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    icono: icono ?? this.icono,
    fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    metadatos: metadatos ?? this.metadatos,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'icono': icono,
    'fechaCreacion': fechaCreacion?.millisecondsSinceEpoch,
    if (metadatos != null) 'metadatos': metadatos,
  };

  factory Habitacion.fromMap(Map<String, dynamic> map, [String? docId]) =>
      Habitacion(
        id: docId ?? map['id'] ?? '',
        nombre: map['nombre'] ?? '',
        icono: map['icono'] ?? 'room',
        fechaCreacion: map['fechaCreacion'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['fechaCreacion'] as int)
            : null,
        metadatos: map['metadatos'] as Map<String, dynamic>?,
      );

  String toJson() => jsonEncode(toMap());

  factory Habitacion.fromJson(String source) =>
      Habitacion.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
