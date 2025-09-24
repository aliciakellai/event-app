import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart'; // pour accéder à MyHomePage

class LoginPage extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginPage({super.key, required this.onLogin});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiService.login(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      );
      if (!mounted) return;

      widget.onLogin(); // ✅ notifie l’appli

      // ✅ redirige vers la liste d’événements
     Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => MyHomePage(onLogout: () {
      ApiService.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(onLogin: () {}),
        ),
      );
    }),
  ),
);

    } catch (e) {
      setState(() {
        _error = "Email ou mot de passe incorrect";
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Email requis' : null,
              ),
              TextFormField(
                controller: passwordCtrl,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  errorText: _error,
                ),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Mot de passe requis' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Se connecter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

