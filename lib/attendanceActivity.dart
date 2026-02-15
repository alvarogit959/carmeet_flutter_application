import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class attendanceActivity extends StatelessWidget {
  final String msg;
  final Map<String, dynamic>? actividad;
  final VoidCallback onBack;

  const attendanceActivity({
    super.key,
    required this.msg,
    required this.actividad,
    required this.onBack,
  });

  List<Map<String, String>> getUsuariosConAsistencia() {
    if (actividad == null || actividad!["usuarios"] == null) return [];

    return List<Map<String, String>>.from(
      (actividad!["usuarios"] as List).map((u) {
        final user = u["user"];
        return {
          "nombre": user?["nombreCorreo"] ?? user?["_id"] ?? "Usuario",
          "estado": u["estado"] ?? "desconocido",
        };
      }),
    );
  }

  String formatDate(String? dateString) {
    if (dateString == null) return "";
    final date = DateTime.tryParse(dateString);
    if (date == null) return "";
    return DateFormat("dd/MM/yyyy HH:mm", "es_ES").format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (actividad == null) {
      return const Scaffold(
        body: Center(child: Text("Actividad no disponible")),
      );
    }

    final usuarios = getUsuariosConAsistencia();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 480,
          height: 640,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                msg,
                style: const TextStyle(fontSize: 22, color: Colors.white),
              ),

              const SizedBox(height: 10),

              Image.asset(
                "assets/transport.png",
                height: 80,
              ),

              const SizedBox(height: 10),

              const Text(
                "Comprobar asistencia",
                style: TextStyle(fontSize: 26, color: Colors.white),
              ),

              const SizedBox(height: 15),

              Text(
                "Nombre: ${actividad!["nombre"]}",
                style: const TextStyle(color: Colors.white),
              ),

              Text(
                "Descripción: ${actividad!["descripcion"] ?? "Sin descripción"}",
                style: const TextStyle(color: Colors.white),
              ),

              Text(
                "Duración: ${actividad!["duracion"]} min",
                style: const TextStyle(color: Colors.white),
              ),

              Text(
                "Plazas máximas: ${actividad!["plazasMaximas"]}",
                style: const TextStyle(color: Colors.white),
              ),

              Text(
                "Fecha: ${formatDate(actividad!["fecha"])}",
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              const Text(
                "Usuarios inscritos:",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];

                    return ListTile(
                      title: Text(
                        usuario["nombre"]!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        usuario["estado"]!,
                        style: TextStyle(
                          color: usuario["estado"] == "asistio"
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: onBack,
                child: const Text("Atrás"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
