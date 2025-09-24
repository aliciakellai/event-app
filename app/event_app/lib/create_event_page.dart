import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final parsedDate = DateTime.tryParse(dateController.text);
        if (parsedDate == null) {
          setState(() {});
          return;
        }

        final formattedDate =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);

        await ApiService.createEvent(
          title: titleController.text,
          description: descriptionController.text,
          date: formattedDate,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Événement créé avec succès")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la création : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un événement")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( 
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Titre"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Titre requis" : null,
              ),
              const SizedBox(height: 16), 

              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Description requise" : null,
              ),
              const SizedBox(height: 16), 

              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: "Date (format: YYYY-MM-DD HH:mm:ss)",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Date requise";
                  }
                  final parsed = DateTime.tryParse(value);
                  if (parsed == null) {
                    return "Format de date invalide (attendu : YYYY-MM-DD HH:mm:ss)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24), 

              ElevatedButton(
                onPressed: _submit,
                child: const Text("Créer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

