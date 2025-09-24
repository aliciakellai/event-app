import 'package:flutter/material.dart';
import 'api_service.dart';
import 'edit_event_page.dart';

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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        Navigator.pop(context, true); // Retour à la liste avec refresh
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event["title"] ?? "Sans titre",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(event["description"] ?? "",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.event, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(event["date"] ?? "",
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 🔹 Boutons visibles seulement pour ADMIN
                  if (ApiService.hasRole("ROLE_ADMIN")) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () => _confirmDelete(context),
                      label: const Text("Supprimer cet événement"),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditEventPage(event: event)),
                        ).then((updated) {
                          if (updated == true) {
                            Navigator.pop(context, true);
                          }
                        });
                      },
                      label: const Text("Modifier cet événement"),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

