import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class EditEventPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const EditEventPage({super.key, required this.event});

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event["title"]);
    descriptionController = TextEditingController(text: widget.event["description"]);
    dateController = TextEditingController(text: widget.event["date"]);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final parsedDate = DateTime.tryParse(dateController.text);
        if (parsedDate == null) {
          // On force l'erreur du champ Date
          _formKey.currentState!.validate();
          return;
        }

        final formattedDate =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);

        await ApiService.updateEvent(
          id: widget.event["id"],
          title: titleController.text,
          description: descriptionController.text,
          date: formattedDate,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Événement modifié avec succès")),
        );

        Navigator.pop(context, true); // retour avec indicateur de mise à jour
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la modification : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier un événement")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Titre"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Titre requis" : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Description requise" : null,
              ),
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: "Date (format: YYYY-MM-DD HH:mm:ss)",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Date requise";
                  }
                  if (DateTime.tryParse(value) == null) {
                    return "Format de date invalide";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Enregistrer les modifications"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
