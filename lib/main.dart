import 'package:carmeet_flutter_application/maniMenuAdmin.dart';
import 'package:flutter/material.dart';
import 'login_view.dart';
import 'newUser.dart';
import 'mainMenu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic>? user;
  bool showRegister = false;
  @override
  Widget build(BuildContext context) {
    Widget currentView;
    if (user != null) {
      currentView = MainMenuView(
        user: user!,
        onLogout: () {
          setState(() => user = null);
        },
      );
    }
    if (user != null && user?["admin"] == "true") {
      currentView = MainMenuAdminView(
        onLogout: () => setState(() => user = null),
        onNewActivity: () {
          print("Crear actividad");
        },
        onEdit: (actividad) {
          print("Editar actividad");
        },
        onAttendance: (actividad) {
          print("Comprobar asistencia");
        },
      );
    } else if (user != null) {
      currentView = MainMenuView(
        user: user!,
        onLogout: () {
          setState(() => user = null);
        },
      );
    } else if (showRegister) {
      currentView = RegisterView(
        onBack: () {
          setState(() => showRegister = false);
        },
      );
    } else {
      currentView = LoginView(
        onLogin: (u) {
          setState(() => user = u);
        },
        onNewUser: () {
          setState(() => showRegister = true);
        },
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: currentView,
    );
  }
}
