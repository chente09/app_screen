import 'dart:io';

import 'package:app_streaming/screens/loginScreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminMultimediaCRUD extends StatefulWidget {
  const AdminMultimediaCRUD({super.key});

  @override
  State<AdminMultimediaCRUD> createState() => _AdminMultimediaCRUDState();
}

class _AdminMultimediaCRUDState extends State<AdminMultimediaCRUD> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child('videos');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Administrar Multimedia'),
        ),
        body: StreamBuilder(
          stream: _databaseRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error al cargar los datos'));
            }

            final data =
                snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

            if (data == null) {
              return const Center(child: Text('No hay videos disponibles'));
            }

            final items = data.entries.toList();

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final key = items[index].key;
                final value = items[index].value;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(value['titulo']),
                    subtitle: Text(value['descripcion']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editarMultimedia(key, value),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarMultimedia(key),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        // Cerrar sesión
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.logout),
          backgroundColor: Colors.red,
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Loginscreen()));
          },
        ));
  }

  void _editarMultimedia(String key, Map value) {
    showDialog(
      context: context,
      builder: (context) {
        final tituloController = TextEditingController(text: value['titulo']);
        final descripcionController =
            TextEditingController(text: value['descripcion']);
        final elencoController = TextEditingController(text: value['elenco']);
        final generoController = TextEditingController(text: value['genero']);
        final duracionController =
            TextEditingController(text: value['duracion']);
        final restriccionController =
            TextEditingController(text: value['restriccion']);

        String? newVideoPath;
        String? newThumbnailPath;

        Future<void> _seleccionarNuevoVideo() async {
          final result =
              await FilePicker.platform.pickFiles(type: FileType.video);
          if (result != null && result.files.single.path != null) {
            setState(() {
              newVideoPath = result.files.single.path;
            });
          }
        }

        Future<void> _seleccionarNuevaMiniatura() async {
          final result =
              await FilePicker.platform.pickFiles(type: FileType.image);
          if (result != null && result.files.single.path != null) {
            setState(() {
              newThumbnailPath = result.files.single.path;
            });
          }
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Multimedia'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: tituloController,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    TextFormField(
                      controller: descripcionController,
                      decoration:
                          const InputDecoration(labelText: 'Descripción'),
                    ),
                    TextFormField(
                      controller: elencoController,
                      decoration: const InputDecoration(labelText: 'Elenco'),
                    ),
                    TextFormField(
                      controller: generoController,
                      decoration: const InputDecoration(labelText: 'Género'),
                    ),
                    TextFormField(
                      controller: duracionController,
                      decoration: const InputDecoration(labelText: 'Duración'),
                    ),
                    TextFormField(
                      controller: restriccionController,
                      decoration:
                          const InputDecoration(labelText: 'Restricción'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _seleccionarNuevoVideo,
                      child: const Text('Seleccionar Nuevo Video'),
                    ),
                    if (newVideoPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Nuevo video seleccionado: ${newVideoPath!.split('/').last}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _seleccionarNuevaMiniatura,
                      child: const Text('Seleccionar Nueva Miniatura'),
                    ),
                    if (newThumbnailPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Nueva miniatura seleccionada: ${newThumbnailPath!.split('/').last}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      String? updatedVideoUrl = value['videoUrl'];
                      String? updatedThumbnailUrl = value['thumbnailUrl'];

                      if (newVideoPath != null) {
                        final videoRef = FirebaseStorage.instance.ref().child(
                            'videos/${DateTime.now().millisecondsSinceEpoch}.mp4');
                        await videoRef.putFile(File(newVideoPath!),
                            SettableMetadata(contentType: 'video/mp4'));
                        updatedVideoUrl = await videoRef.getDownloadURL();
                      }

                      if (newThumbnailPath != null) {
                        final thumbnailRef = FirebaseStorage.instance.ref().child(
                            'thumbnails/${DateTime.now().millisecondsSinceEpoch}.jpg');
                        await thumbnailRef.putFile(File(newThumbnailPath!),
                            SettableMetadata(contentType: 'image/jpeg'));
                        updatedThumbnailUrl =
                            await thumbnailRef.getDownloadURL();
                      }

                      await _databaseRef.child(key).update({
                        'titulo': tituloController.text,
                        'descripcion': descripcionController.text,
                        'elenco': elencoController.text,
                        'genero': generoController.text,
                        'duracion': duracionController.text,
                        'restriccion': restriccionController.text,
                        'videoUrl': updatedVideoUrl,
                        'thumbnailUrl': updatedThumbnailUrl,
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Multimedia actualizada con éxito')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Error al actualizar multimedia: $e')),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _eliminarMultimedia(String key) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Multimedia'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este video?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _databaseRef.child(key).remove();
                Navigator.pop(context);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
