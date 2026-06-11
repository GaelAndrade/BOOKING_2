import 'package:flutter/material.dart';
import 'vistas/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/app_database.dart';

void main() async {
  // Se asegura de que Flutter esté inicializado antes de ejecutar la aplicación
  WidgetsFlutterBinding.ensureInitialized();
  runApp(HotelApp());
}

class HotelApp extends StatelessWidget {
  HotelApp({super.key});

  final Future<List<Object?>> _initialization = Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    AppDatabase.instance.database,
  ]);

  //El widget principal de la aplicación, que se encarga de mostrar la pantalla de inicio de sesión después de inicializar Firebase y SQLite.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Booking',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: FutureBuilder<List<Object?>>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Error initializing Firebase o SQLite:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }
          //Una vez que Firebase y SQLite estén listos, se muestra la pantalla de inicio de sesión.
          return const LoginPage();
        },
      ),
    );
  }
}
