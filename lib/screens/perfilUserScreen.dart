import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PerfilUserScreen extends StatelessWidget {
  const PerfilUserScreen({super.key});

  Future<Map<String, dynamic>?> leer() async {
    // Obtiene el UID del usuario autenticado
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return null; // Si no hay usuario autenticado, devuelve null
    }

    // Referencia a los datos del usuario en Firebase
    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$uid');
    final snapshot = await userRef.get();
    final data = snapshot.value;

    if (data != null) {
      // Si hay datos, los convierte en un mapa
      return Map<String, dynamic>.from(data as Map);
    } else {
      return null; // Si no hay datos, devuelve null
    }
  }

  Future<void> actualizar(Map<String, dynamic> nuevosDatos) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return; // No se puede actualizar si no hay usuario autenticado
    }

    // Referencia a los datos del usuario en Firebase
    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$uid');
    await userRef.update(nuevosDatos); // Actualiza los datos en Firebase
  }

  void mostrarDialogoEdicion(BuildContext context, Map<String, dynamic> datos) {
    final nombreController = TextEditingController(text: datos['name']);
    final usernameController = TextEditingController(text: datos['username']);
    final dobController = TextEditingController(text: datos['dob']);
    final phoneController = TextEditingController(text: datos['phone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar datos del usuario'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: dobController,
                decoration: const InputDecoration(labelText: 'Fecha de Nacimiento'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final nuevosDatos = {
                'name': nombreController.text,
                'username': usernameController.text,
                'dob': dobController.text,
                'phone': phoneController.text,
              };
              await actualizar(nuevosDatos);
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget usuarioListView(BuildContext context) {
    return FutureBuilder(
      future: leer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Error al cargar los datos.'));
        } else {
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? 'Nombre no disponible',
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Correo: ${data['email'] ?? 'No disponible'}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Teléfono: ${data['phone'] ?? 'No disponible'}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Username: ${data['username'] ?? 'No disponible'}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Fecha de Nacimiento: ${data['dob'] ?? 'No disponible'}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => mostrarDialogoEdicion(context, data),
                          child: const Text('Editar Información'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: usuarioListView(context),
    );
  }
}
