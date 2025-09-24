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
      title: 'Les Toiles de Minuit',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0D1B2A),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF0D1B2A),
          secondary: const Color(0xFFF4C430),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black87,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1B2A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFF4C430),
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D1B2A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: isLoggedIn
          ? MyHomePage(onLogout: _handleLogout)
          : LoginPage(
              onLogin: () {
                setState(() {});
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
        title: const Text("Liste des événements"),
        leading: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              widget.onLogout();
              Navigator.pushAndRemoveUntil(
                context,
                  MaterialPageRoute(
                    builder: (_) => LoginPage(onLogin: () {
                      setState(() {});
                    }),
                  ),
                  (route) => false,
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.black),
                  SizedBox(width: 8),
                  Text("Se déconnecter"),
                ],
              ),
            ),
          ],
        ),
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
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      event["title"] ?? "Sans titre",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          event["date"] ?? "",
                          style: const TextStyle(color: Colors.grey),
                        ),
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
                  ),
                );
              },
            );
          }
        },
      ),
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

