import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Base URL récupérée depuis le .env
  static String baseUrl =
      dotenv.env['FLUTTER_API_URL'] ?? 'http://localhost:8000/api';

  /// Récupérer la liste des événements
  static Future<List<dynamic>> fetchEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/events'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des événements');
    }
  }

  /// Créer un nouvel événement
  static Future<void> createEvent({
    required String title,
    required String description,
    required String date,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'date': date,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur API: ${response.body}');
    }
  }

  /// Supprimer un événement par ID
  static Future<void> deleteEvent(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/events/$id'));

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression : ${response.body}');
    }
  }



static Future<void> updateEvent({
  required int id,
  required String title,
  required String description,
  required String date,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/events/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'title': title,
      'description': description,
      'date': date,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Erreur API: ${response.body}');
  }
}



}

