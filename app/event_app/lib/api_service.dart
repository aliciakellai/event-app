import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ApiService {
  // --- Gestion de la configuration ---
  static String get baseUrl =>
      (dotenv.env['FLUTTER_API_URL'] ?? 'http://127.0.0.1:8000/api')
          .replaceAll(RegExp(r'/+$'), '');

  // --- Gestion du token JWT ---
  static String? _token;

  static bool get isLoggedIn => _token != null;

  static void logout() {
    _token = null;
  }

  // --- Authentification ---
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      _token = body['token'];
    } else {
      try {
        final body = jsonDecode(response.body);
        final msg = body['message'] ?? 'Erreur inconnue';
        throw Exception(msg);
      } catch (_) {
        throw Exception('Erreur login: ${response.body}');
      }
    }
  }

  static Map<String, String> _authHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // --- Récupérer la liste des événements ---
  static Future<List<dynamic>> fetchEvents() async {
    final url = Uri.parse('$baseUrl/events');
    final response = await http.get(url, headers: _authHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return data;
      throw Exception('Réponse inattendue: ${response.body}');
    } else {
      throw Exception('Erreur API: ${response.body}');
    }
  }

  // --- Créer un nouvel événement ---
  static Future<void> createEvent({
    required String title,
    required String description,
    required String date,
  }) async {
    final url = Uri.parse('$baseUrl/events');
    final response = await http.post(
      url,
      headers: _authHeaders(),
      body: jsonEncode({'title': title, 'description': description, 'date': date}),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur API: ${response.body}');
    }
  }

  // --- Modifier un événement ---
  static Future<void> updateEvent({
    required int id,
    required String title,
    required String description,
    required String date,
  }) async {
    final url = Uri.parse('$baseUrl/events/$id');
    final response = await http.put(
      url,
      headers: _authHeaders(),
      body: jsonEncode({'title': title, 'description': description, 'date': date}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur API: ${response.body}');
    }
  }

  // --- Supprimer un événement ---
  static Future<void> deleteEvent(int id) async {
    final url = Uri.parse('$baseUrl/events/$id');
    final response = await http.delete(url, headers: _authHeaders());

    if (response.statusCode != 200) {
      throw Exception('Erreur API: ${response.body}');
    }
  }

static List<String> get roles {
    if (_token == null) return [];
    final decoded = JwtDecoder.decode(_token!);
    final List<dynamic> r = decoded['roles'] ?? [];
    return r.map((e) => e.toString()).toList();
  }

  static bool hasRole(String role) => roles.contains(role);


}
