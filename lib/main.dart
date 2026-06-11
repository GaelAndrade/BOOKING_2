import 'package:flutter/material.dart';
import 'vistas/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() { //Se asegura de que Flutter esté inicializado antes de ejecutar la aplicación
  WidgetsFlutterBinding.ensureInitialized();
  runApp(HotelApp());
}

class HotelApp extends StatelessWidget {
  HotelApp({super.key});

  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //El widget principal de la aplicación, que se encarga de mostrar la pantalla de inicio de sesión después de inicializar Firebase
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Booking',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: FutureBuilder<FirebaseApp>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          //Como habiamos tenido errores con el api, 
          //pusimos un mensaje de error para mostar especificamente que estaba fallando
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Error initializing Firebase:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }
          //Si la inicialización es exitosa, se muestra la pantalla de inicio de sesión
          return const LoginPage();
        },
      ),
    );
  }
}
