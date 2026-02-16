import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditActivityView extends StatefulWidget {
  final Map actividad;

  const EditActivityView({
    super.key,
    required this.actividad,
  });

  @override
  State<EditActivityView> createState() => _EditActivityViewState();
}

class _EditActivityViewState extends State<EditActivityView> {

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final durationController = TextEditingController();
  final maxUsersController = TextEditingController();

  DateTime? selectedDate;

  String notification = "";

  @override
  void initState() {
    super.initState();

    final a = widget.actividad;

    nameController.text = a["nombre"] ?? "";
    descController.text = a["descripcion"] ?? "";
    durationController.text = a["duracion"].toString();
    maxUsersController.text = a["plazasMaximas"].toString();

    if (a["fecha"] != null) {
      selectedDate = DateTime.parse(a["fecha"]);
    }
  }

  /* ---------------- UPDATE ---------------- */

  Future<void> updateActivity() async {

    try {

      final res = await http.put(
        Uri.parse("http://10.0.2.2:5000/actividades/${widget.actividad["_id"]}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nameController.text,
          "descripcion": descController.text,
          "fecha": selectedDate?.toIso8601String() ??
              widget.actividad["fecha"],
          "duracion": int.tryParse(durationController.text) ?? 0,
          "plazasMaximas": int.tryParse(maxUsersController.text) ?? 0,
        }),
      );

      if (res.statusCode != 200) {
        throw Exception("Error actualizando actividad");
      }

      setState(() {
        notification = "Actividad actualizada correctamente";
      });

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) Navigator.pop(context);

    } catch (e) {
      setState(() {
        notification = "Error al actualizar";
      });
    }
  }

  /* ---------------- DATE PICKER ---------------- */

  Future<void> pickDate() async {

    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(2100),
      initialDate: selectedDate ?? now,
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate ?? now),
    );

    if (time == null) return;

    setState(() {
      selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String formatDate() {
    if (selectedDate == null) return "Seleccionar fecha";

    final d = selectedDate!;

    return "${d.day}/${d.month}/${d.year} "
        "${d.hour.toString().padLeft(2, "0")}:"
        "${d.minute.toString().padLeft(2, "0")}";
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a1a), Color(0xFF000000)],
          ),
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      const Text(
                        "Editar actividad",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (notification.isNotEmpty)
                        Text(
                          notification,
                          style: const TextStyle(color: Colors.green),
                        ),

                      const SizedBox(height: 20),

                      _input(nameController, "Nombre"),
                      const SizedBox(height: 12),

                      _input(descController, "Descripción"),
                      const SizedBox(height: 12),

                      _dateButton(),
                      const SizedBox(height: 12),

                      _input(durationController, "Duración (min)",
                          isNumber: true),

                      const SizedBox(height: 12),

                      _input(maxUsersController, "Plazas máximas",
                          isNumber: true),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: updateActivity,
                          child: const Text("Guardar cambios"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Atrás"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* ---------------- WIDGETS ---------------- */

  Widget _input(TextEditingController controller, String hint,
      {bool isNumber = false}) {

    return TextField(
      controller: controller,
      keyboardType:
          isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dateButton() {

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: pickDate,
        child: Text(formatDate()),
      ),
    );
  }
}
