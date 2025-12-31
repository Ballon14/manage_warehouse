import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String sku;
  final String name;
  final String? barcode;
  final double reorderLevel;
  final String uom;
  final DateTime createdAt;

  ItemModel({
    required this.id,
    required this.sku,
    required this.name,
    this.barcode,
    required this.reorderLevel,
    required this.uom,
    required this.createdAt,
  });

  factory ItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ItemModel(
      id: id,
      sku: data['sku'] ?? '',
      name: data['name'] ?? '',
      barcode: data['barcode'],
      reorderLevel: (data['reorderLevel'] ?? 0).toDouble(),
      uom: data['uom'] ?? 'pcs',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sku': sku,
      'name': name,
      'barcode': barcode,
      'reorderLevel': reorderLevel,
      'uom': uom,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ItemModel copyWith({
    String? id,
    String? sku,
    String? name,
    String? barcode,
    double? reorderLevel,
    String? uom,
    DateTime? createdAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      uom: uom ?? this.uom,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
