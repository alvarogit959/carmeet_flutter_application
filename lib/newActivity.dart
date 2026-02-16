import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NewActivityScreen extends StatefulWidget {
  const NewActivityScreen({super.key});

  @override
  State<NewActivityScreen> createState() => _NewActivityScreenState();
}

class _NewActivityScreenState extends State<NewActivityScreen> {

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final durationController = TextEditingController();
  final maxUsersController = TextEditingController();

  DateTime? selectedDate;
  String notification = "";

  DateTime get minDate => DateTime.now();

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: minDate,
      lastDate: DateTime(2100),
      initialDate: minDate,
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  Future<void> createActivity() async {

    if (nameController.text.isEmpty ||
        durationController.text.isEmpty ||
        maxUsersController.text.isEmpty ||
        selectedDate == null) {

      setState(() => notification = "Completa todos los campos!");
      return;
    }

    try {

      final res = await http.post(
        Uri.parse("http://10.0.2.2:5000/actividades"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nameController.text,
          "descripcion": descController.text,
          "fecha": selectedDate!.toIso8601String(),
          "duracion": int.parse(durationController.text),
          "plazasMaximas": int.parse(maxUsersController.text),
        }),
      );

      if (res.statusCode != 201) {
        setState(() => notification = "Error, compruebe sus datos");
        return;
      }

      setState(() {
        notification = "Creada correctamente";
        nameController.clear();
        descController.clear();
        durationController.clear();
        maxUsersController.clear();
        selectedDate = null;
      });

    } catch (e) {
      setState(() => notification = "Error conectando con servidor");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white24),
          ),

          child: SingleChildScrollView(
            child: Column(
              children: [

                const Text(
                  "Crear nueva actividad",
                  style: TextStyle(fontSize: 26, color: Colors.white),
                ),

                const SizedBox(height: 10),

            //    Image.asset("assets/transport.png", height: 120),

                const SizedBox(height: 10),

                Text(
                  notification,
                  style: const TextStyle(color: Colors.redAccent),
                ),

                const SizedBox(height: 10),

                buildInput(nameController, "Nombre actividad"),
                buildInput(descController, "Descripción"),

                const SizedBox(height: 10),

                /// FECHA
                ElevatedButton(
                  onPressed: pickDateTime,
                  child: Text(
                    selectedDate == null
                        ? "Seleccionar fecha"
                        : DateFormat("dd/MM/yyyy HH:mm")
                            .format(selectedDate!),
                  ),
                ),

                const SizedBox(height: 10),

                buildInput(durationController, "Duración minutos",
                    isNumber: true),

                buildInput(maxUsersController, "Plazas máximas",
                    isNumber: true),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: createActivity,
                  child: const Text("Crear"),
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
      ),
    );
  }

  Widget buildInput(TextEditingController controller, String hint,
      {bool isNumber = false}) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType:
            isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
