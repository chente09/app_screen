import 'package:app_streaming/screens/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PerfilUserScreen extends StatelessWidget {
  const PerfilUserScreen({super.key});

  Future<Map<String, dynamic>?> leer() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return null; 
    }
    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$uid');
    final snapshot = await userRef.get();
    final data = snapshot.value;
    if (data != null) {
      return Map<String, dynamic>.from(data as Map);
    } else {
      return null;
    }
  }

  Future<void> actualizar(Map<String, dynamic> nuevosDatos) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return; 
    }
    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$uid');
    await userRef.update(nuevosDatos);
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  data['name'] ?? 'Nombre no disponible',
                  style: const TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Datos del usuario con iconos y texto al lado
                _buildDetailRow('Correo', data['email'], Icons.email),
                const SizedBox(height: 10),
                _buildDetailRow('Teléfono', data['phone'], Icons.phone),
                const SizedBox(height: 10),
                _buildDetailRow('Username', data['username'], Icons.person),
                const SizedBox(height: 10),
                _buildDetailRow('Fecha de Nacimiento', data['dob'], Icons.calendar_today),
                const SizedBox(height: 30),
                // Botón de editar
                Center(
                  child: ElevatedButton(
                    onPressed: () => mostrarDialogoEdicion(context, data),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text(
                      'Editar Información',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildDetailRow(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                value ?? 'No disponible',
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: usuarioListView(context),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.logout),
        backgroundColor: Colors.redAccent,
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Loginscreen()));
        },
      ),
    );
  }
}
