import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // L'URL de base vient d'une variable d'environnement passée au moment du run.
  // Si aucune variable n'est fournie, ça utilise "http://localhost:8000/api/events".
  static const String baseUrl = String.fromEnvironment(
    'FLUTTER_API_URL',
    defaultValue: 'http://localhost:8000/api/events',
  );

  static Future<List<dynamic>> fetchEvents() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des événements');
    }
  }
}

