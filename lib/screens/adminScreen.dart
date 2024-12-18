import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';

class AdminMultimedia extends StatefulWidget {
  const AdminMultimedia({super.key});

  @override
  State<AdminMultimedia> createState() => _AdminMultimediaState();
}

class _AdminMultimediaState extends State<AdminMultimedia> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _elencoController = TextEditingController();
  final _generoController = TextEditingController();
  final _duracionController = TextEditingController();
  final _restriccionController = TextEditingController();

  String? _videoPath;
  String? _thumbnailPath;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  Future<void> _seleccionarVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _videoPath = result.files.single.path;
      });
    }
  }

  Future<void> _seleccionarMiniatura() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _thumbnailPath = result.files.single.path;
      });
    }
  }

  Future<void> _subirMultimedia() async {
    if (_formKey.currentState!.validate()) {
      if (_videoPath == null || _thumbnailPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona un video y una miniatura')),
        );
        return;
      }

      try {
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
        });

        final storageRef = FirebaseStorage.instance.ref();

        // Subir video
        final videoRef = storageRef.child('videos/${DateTime.now().millisecondsSinceEpoch}.mp4');
        final videoUploadTask = videoRef.putFile(File(_videoPath!), SettableMetadata(contentType: 'video/mp4'));

        // Subir miniatura
        final thumbnailRef = storageRef.child('thumbnails/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final thumbnailUploadTask = thumbnailRef.putFile(File(_thumbnailPath!), SettableMetadata(contentType: 'image/jpeg'));

        // Seguimiento del progreso de subida
        videoUploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          setState(() {
            _uploadProgress = progress;
          });
        });

        await Future.wait([videoUploadTask, thumbnailUploadTask]);

        final videoUrl = await videoRef.getDownloadURL();
        final thumbnailUrl = await thumbnailRef.getDownloadURL();

        // Guardar datos en Firebase Database
        final databaseRef = FirebaseDatabase.instance.ref().child('videos');
        await databaseRef.push().set({
          'titulo': _tituloController.text,
          'descripcion': _descripcionController.text,
          'elenco': _elencoController.text,
          'genero': _generoController.text,
          'duracion': _duracionController.text,
          'restriccion': _restriccionController.text,
          'videoUrl': videoUrl,
          'thumbnailUrl': thumbnailUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video y miniatura subidos con éxito')),
        );

        // Limpiar formulario
        _formKey.currentState!.reset();
        _tituloController.clear();
        _descripcionController.clear();
        _elencoController.clear();
        _generoController.clear();
        _duracionController.clear();
        _restriccionController.clear();
        setState(() {
          _videoPath = null;
          _thumbnailPath = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir los archivos: $e')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Multimedia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                controller: _elencoController,
                decoration: const InputDecoration(labelText: 'Elenco'),
                validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                controller: _generoController,
                decoration: const InputDecoration(labelText: 'Género'),
                validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                controller: _duracionController,
                decoration: const InputDecoration(labelText: 'Duración (en minutos)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                controller: _restriccionController,
                decoration: const InputDecoration(labelText: 'Restricción (edad mínima)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _seleccionarVideo,
                child: const Text('Seleccionar Video'),
              ),
              if (_videoPath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Video seleccionado: ${_videoPath!.split('/').last}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ElevatedButton(
                onPressed: _seleccionarMiniatura,
                child: const Text('Seleccionar Miniatura'),
              ),
              if (_thumbnailPath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Miniatura seleccionada: ${_thumbnailPath!.split('/').last}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              const SizedBox(height: 16),
              if (_isUploading)
                Column(
                  children: [
                    const Text('Subiendo multimedia...'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: _uploadProgress),
                    Text('${(_uploadProgress * 100).toStringAsFixed(2)}%'),
                  ],
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading ? null : _subirMultimedia,
                child: const Text('Subir Multimedia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
