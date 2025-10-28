import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/Produit.dart';
import '../models/Service.dart';

class Api {
  Future<List<Produit>> getProduits() async {
    final String response = await rootBundle.loadString(
      'assets/data/produits.json',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Produit.fromJson(json)).toList();
  }

  Future<List<Service>> getServices() async {
  final String response = await rootBundle.loadString('assets/data/services.json');
  final List<dynamic> data = json.decode(response);
  return data.map((json) => Service.fromJson(json)).toList();
}

}
