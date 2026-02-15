import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterView extends StatefulWidget {
  final VoidCallback onBack;

  const RegisterView({super.key, required this.onBack});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  String notification = "";

  Future<void> createUser() async {
    final username = usernameController.text;
    final password = passwordController.text;
    final confirmPassword = confirmController.text;

    if (password != confirmPassword) {
      setState(() {
        notification = "Las contraseñas no coinciden";
      });
      return;
    }

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        notification = "Rellene todos los campos";
      });
      return;
    }

    try {
      final res = await http.post(
        Uri.parse("http://10.0.2.2:5000/users"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombreCorreo": username,
          "password": password,
        }),
      );

      if (res.statusCode != 200) {
        final error = jsonDecode(res.body);
        setState(() {
          notification = error["error"] ?? "Error creando usuario";
        });
        return;
      }

      setState(() {
        notification = "Usuario creado correctamente";
        usernameController.clear();
        passwordController.clear();
        confirmController.clear();
      });
    } catch (e) {
      setState(() {
        notification = "Error conectando con servidor";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a1a), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 330,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),

                    Text(
                      "Crear Usuario",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Cree su nuevo usuario en CarMeet Club",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 10),

                    if (notification.isNotEmpty)
                      Text(
                        notification,
                        style: const TextStyle(color: Colors.red),
                      ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Nombre o correo..."),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Contraseña..."),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: confirmController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Vuelva a escribir su contraseña"),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: createUser,
                        child: const Text("Crear cuenta"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onBack,
                        child: const Text("Atrás"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
