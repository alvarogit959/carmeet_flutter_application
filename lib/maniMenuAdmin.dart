import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//IMPORTAR ACTIVIDADES
import 'editActivity.dart';
import 'attendanceActivity.dart';
import 'newActivity.dart';

DateTime? parseMongoDate(dynamic fecha) {
  if (fecha == null) return null;

  if (fecha is String) return DateTime.tryParse(fecha);

  if (fecha is Map && fecha["\$date"] != null) {
    return DateTime.tryParse(fecha["\$date"]);
  }

  return null;
}

class MainMenuAdminView extends StatefulWidget {
  final VoidCallback onLogout;
  final Function(Map actividad) onEdit;
  final Function() onNewActivity;
  final Function(Map actividad) onAttendance;

  const MainMenuAdminView({
    super.key,
    required this.onLogout,
    required this.onEdit,
    required this.onNewActivity,
    required this.onAttendance,
  });

  @override
  State<MainMenuAdminView> createState() => _MainMenuAdminViewState();
}

class _MainMenuAdminViewState extends State<MainMenuAdminView> {
  List<Map<String, dynamic>> actividades = [];
  bool loading = false;
  String? error;

  String sortBy = "recent";
  String sortDirection = "desc";

  @override
  void initState() {
    super.initState();
    loadActividades();
  }

  /* ---------------- LOAD ---------------- */

  Future<void> loadActividades() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await http.get(Uri.parse("http://10.0.2.2:5000/actividades"));

      if (!mounted) return;

      if (res.statusCode != 200) {
        throw Exception("Error cargando actividades");
      }

      setState(() {
        actividades = List<Map<String, dynamic>>.from(jsonDecode(res.body));
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = "No se pudieron cargar las actividades";
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  /* ---------------- SORT ---------------- */

  List sortedActividades() {
    final list = [...actividades];

    if (sortBy == "reserves") {
      list.sort((a, b) {
        final diff = a["usuarios"].length.compareTo(b["usuarios"].length);

        return sortDirection == "desc" ? -diff : diff;
      });
    } else {
      list.sort(
        (a, b) => DateTime.parse(
          b["createdAt"],
        ).compareTo(DateTime.parse(a["createdAt"])),
      );
    }

    return list;
  }

  void sortByReserves() {
    setState(() {
      if (sortBy == "reserves") {
        sortDirection = sortDirection == "desc" ? "asc" : "desc";
      } else {
        sortBy = "reserves";
        sortDirection = "desc";
      }
    });
  }

  /* ---------------- DELETE ---------------- */

  Future<void> deleteActivity(String id) async {
    try {
      await http.delete(Uri.parse("http://10.0.2.2:5000/actividades/$id"));

      await loadActividades();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error eliminando actividad")),
      );
    }
  }

  /* ---------------- DATE ---------------- */

  String formatDate(dynamic fecha) {
    final date = parseMongoDate(fecha);

    if (date == null) return "";

    return "${date.day.toString().padLeft(2, "0")}/"
        "${date.month.toString().padLeft(2, "0")}/"
        "${date.year}";
  }

  String extractId(dynamic id) {
    if (id is String) return id;

    if (id is Map && id["\$oid"] != null) {
      return id["\$oid"];
    }

    return "";
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a1a), Color(0xFF000000)],
          ),
        ),
        child: Column(
          children: [
            _topBar(),
            Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
      child: Column(
        children: [
          const Text(
            "Bienvenido usuario Admin",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: widget.onLogout,
                child: const Text("Cerrar sesión"),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                onPressed: sortByReserves,
                child: const Text("Ordenar reservas"),
              ),

              const SizedBox(width: 10),

              
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,children: [
            ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NewActivityScreen(),
                    ),
                  );

                  loadActividades();
                },
                child: const Text("Crear actividad"),
              ),]),
        ],
      ),
    );
  }

  Widget _content() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: Colors.red)),
      );
    }

    final list = sortedActividades();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (_, i) => _activityCard(list[i]),
    );
  }

  Widget _activityCard(Map actividad) {
    final full = actividad["usuarios"].length >= actividad["plazasMaximas"];

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actividad["nombre"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  formatDate(actividad["createdAt"]),
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 8),

                Text(
                  actividad["descripcion"] ?? "Sin descripción",
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 10),

                Text(
                  "Duración: ${actividad["duracion"]} min",
                  style: const TextStyle(color: Colors.white),
                ),

                Text(
                  "Plazas: ${actividad["usuarios"].length}/${actividad["plazasMaximas"]}",
                  style: const TextStyle(color: Colors.white),
                ),

                if (full)
                  const Text("LLENO", style: TextStyle(color: Colors.red)),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditActivityView(actividad: actividad),
                          ),
                        );

                        loadActividades();
                      },
                      child: const Text("Modificar"),
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttendanceActivity(
                              actividad: Map<String, dynamic>.from(actividad),
                            ),
                          ),
                        );
                        loadActividades();
                      },
                      child: const Text("Asistencia"),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () =>
                          deleteActivity(extractId(actividad["_id"])),
                      child: const Text("Eliminar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
