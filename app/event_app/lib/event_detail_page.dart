import 'package:flutter/material.dart';
import 'api_service.dart';
import 'edit_event_page.dart'; // 👈 à importer

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailPage({super.key, required this.event});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Êtes-vous sûr de vouloir supprimer cet événement ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteEvent(event["id"]);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Événement supprimé avec succès")),
        );
        Navigator.pop(context, true); // Retour à la liste
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la suppression : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event["title"] ?? "Détails")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Titre : ${event["title"]}", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text("Description : ${event["description"] ?? ""}"),
            const SizedBox(height: 10),
            Text("Date : ${event["date"] ?? ""}"),
            const Spacer(),

            // 👇 Les deux boutons centrés
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditEventPage(event: event),
                      ),
                    ).then((updated) {
                      if (updated == true) {
                        Navigator.pop(context, true); // retour liste + refresh
                      }
                    });
                  },
                  child: const Text("Modifier cet événement"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => _confirmDelete(context),
                  child: const Text("Supprimer cet événement"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
