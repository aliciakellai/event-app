import 'package:flutter/material.dart';
import 'api_service.dart';
import 'event_detail_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'create_event_page.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool get isLoggedIn => ApiService.isLoggedIn;

  void _handleLogout() {
    setState(() {
      ApiService.logout();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: isLoggedIn
          ? MyHomePage(onLogout: _handleLogout)
          : LoginPage(
              onLogin: () {
                setState(() {}); // Rafraîchit après connexion
              },
            ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback onLogout;

  const MyHomePage({super.key, required this.onLogout});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<dynamic>> events;

  @override
  void initState() {
    super.initState();
    events = ApiService.fetchEvents();
  }

  void _refreshEvents() {
    setState(() {
      events = ApiService.fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Liste des événements"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: events,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun événement disponible"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final event = snapshot.data![index];
                return ListTile(
                  title: Text(event["title"] ?? "Sans titre"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event["date"] ?? ""),
                      const Text(
                        "Appuyez pour plus d'informations",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(event: event),
                      ),
                    ).then((updated) {
                      if (updated == true) {
                        _refreshEvents();
                      }
                    });
                  },
                );
              },
            );
          }
        },
      ),

      // 🔹 Bouton d’ajout visible seulement pour ROLE_ADMIN
      floatingActionButton: ApiService.hasRole("ROLE_ADMIN")
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateEventPage()),
                ).then((_) => _refreshEvents());
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
