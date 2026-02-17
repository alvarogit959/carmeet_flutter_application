import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceActivity extends StatelessWidget {
  final Map<String, dynamic> actividad;

  const AttendanceActivity({super.key, required this.actividad});
List<Map<String, dynamic>> getUsuariosConAsistencia() {

  final lista = actividad["usuarios"];

  if (lista is! List) return [];

  return lista.map<Map<String, dynamic>>((u) {

    return {
      "nombre": extractUserName(u["user"]),
      "estado": u["estado"]?.toString() ?? "pendiente",
    };

  }).toList();
}


String extractUserName(dynamic user) {

  if (user is Map && user["nombreCorreo"] != null) {
    return user["nombreCorreo"].toString();
  }

  if (user is Map && user["\$oid"] != null) {
    return "Usuario ${user["\$oid"].toString().substring(0, 6)}";
  }

  return "Usuario";
}
DateTime? parseMongoDate(dynamic fecha) {

  if (fecha == null) return null;

  if (fecha is String) {
    return DateTime.tryParse(fecha);
  }

  if (fecha is Map && fecha["\$date"] != null) {
    return DateTime.tryParse(fecha["\$date"]);
  }

  return null;
}

String formatDate(dynamic fecha) {

  final date = parseMongoDate(fecha);

  if (date == null) return "";

  return DateFormat("dd/MM/yyyy HH:mm", "es_ES").format(date);
}



  @override
  Widget build(BuildContext context) {
print("Abriendo asistencia: $actividad");
    final usuarios = getUsuariosConAsistencia();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 350,
          height: 640,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white24),
          ),




child: Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const Text(
      "Gestión de asistencia",
      style: TextStyle(fontSize: 22, color: Colors.white),
    ),

    const SizedBox(height: 10),

    const Text(
      "Comprobar asistencia",
      style: TextStyle(fontSize: 26, color: Colors.white),
    ),

    const SizedBox(height: 15),

    Text(
      "Nombre: ${actividad["nombre"]}",
      style: const TextStyle(color: Colors.white),
    ),

    Text(
      "Descripción: ${actividad["descripcion"] ?? "Sin descripción"}",
      style: const TextStyle(color: Colors.white),
    ),

    Text(
      "Duración: ${actividad["duracion"]} min",
      style: const TextStyle(color: Colors.white),
    ),

    Text(
      "Plazas máximas: ${actividad["plazasMaximas"]}",
      style: const TextStyle(color: Colors.white),
    ),

    Text(
      "Fecha: ${formatDate(actividad["fecha"])}",
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
              usuario["nombre"]?.toString() ?? "Usuario",
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Text(
              (usuario["estado"]?.toString() ?? "desconocido"),
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
      onPressed: () => Navigator.pop(context),
      child: const Text("Atrás"),
    ),
  ],
),

        ),
      ),
    );
  }
}
