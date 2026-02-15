import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainMenuView extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  const MainMenuView({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<MainMenuView> createState() => _MainMenuViewState();
}

class _MainMenuViewState extends State<MainMenuView> {
  List actividades = [];
  bool loading = false;
  String? error;

  String sortBy = "recent";
  String sortDirection = "desc";

  @override
  void initState() {
    super.initState();
    loadActividades();
  }

  bool alreadyIn(Map actividad) {
    return actividad["usuarios"].any((u) =>
        u["user"]?["_id"]?.toString() == widget.user["id"]);
  }

  Future<void> toggleJoin(Map actividad) async {
    final id = actividad["_id"];

    if (alreadyIn(actividad)) {
      await http.post(
        Uri.parse("http://10.0.2.2:5000/actividades/$id/desinscribir"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": widget.user["id"]}),
      );
    } else {
      await http.post(
        Uri.parse("http://10.0.2.2:5000/actividades/$id/inscribir"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": widget.user["id"]}),
      );
    }

    await loadActividades();
  }

  Future<void> loadActividades() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response =
          await http.get(Uri.parse("http://10.0.2.2:5000/actividades"));

      if (response.statusCode != 200) {
        throw Exception("Error cargando actividades");
      }

      final data = jsonDecode(response.body);

      setState(() {
        actividades = data;
      });
    } catch (e) {
      setState(() {
        error = "No se pudieron cargar las actividades";
      });
    } finally {
      setState(() => loading = false);
    }
  }

  List sortedActividades() {
    final list = [...actividades];

    if (sortBy == "reserves") {
      list.sort((a, b) {
        final diff =
            a["usuarios"].length.compareTo(b["usuarios"].length);

        return sortDirection == "desc" ? -diff : diff;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a1a), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _topBar(),
            Expanded(child: _content())
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "CarMeet Club",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: sortByReserves,
                child: const Text("Ordenar reservas"),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: widget.onLogout,
                child: const Text("Cerrar sesión"),
              ),
            ],
          )
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
      itemBuilder: (context, index) {
        final actividad = list[index];

        final full = actividad["usuarios"].length >=
            actividad["plazasMaximas"];

        return _activityCard(actividad, full);
      },
    );
  }

  Widget _activityCard(Map actividad, bool full) {
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
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(
                  actividad["descripcion"] ?? "Sin descripción",
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 10),

                Text(
                  "Duración: ${actividad["duracion"]} minutos",
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Plazas: ${actividad["usuarios"].length}/${actividad["plazasMaximas"]}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (full)
                      const Text(
                        "LLENO",
                        style: TextStyle(color: Colors.red),
                      )
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: full && !alreadyIn(actividad)
                        ? null
                        : () => toggleJoin(actividad),
                    child: Text(
                        alreadyIn(actividad) ? "Salir" : "Apuntarse"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
