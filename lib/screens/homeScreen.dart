import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _databaseRef = FirebaseDatabase.instance.ref().child('videos');
  List<Map<dynamic, dynamic>> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarVideos();
  }

  Future<void> _cargarVideos() async {
    try {
      final snapshot = await _databaseRef.get();
      final List<Map<dynamic, dynamic>> loadedVideos = [];
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          loadedVideos.add({'key': key, ...value});
        });
      }
      setState(() {
        _videos = loadedVideos;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar videos: $e')),
      );
    }
  }

  void _mostrarDetalles(BuildContext context, Map<dynamic, dynamic> video) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(video['titulo']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  video['thumbnailUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                ),
                const SizedBox(height: 8.0),
                Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(video['descripcion'] ?? 'Sin descripción'),
                const SizedBox(height: 8.0),
                Text('Género:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(video['genero'] ?? 'Desconocido'),
                const SizedBox(height: 8.0),
                Text('Elenco:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(video['elenco'] ?? 'Sin información'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navegarAReproductor(context, video['videoUrl'], video['titulo']);
              },
              child: const Text('Play'),
            ),
          ],
        );
      },
    );
  }

  void _navegarAReproductor(BuildContext context, String videoUrl, String titulo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl, titulo: titulo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<dynamic, dynamic>>> videosPorGenero = {};
    for (var video in _videos) {
      String genero = video['genero'] ?? 'Sin género';
      if (!videosPorGenero.containsKey(genero)) {
        videosPorGenero[genero] = [];
      }
      videosPorGenero[genero]!.add(video);
    }

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _videos.isEmpty
              ? const Center(child: Text('No hay contenido disponible'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/logo_taller.png',
                          height: 200,
                        ),
                      ),
                      for (var genero in videosPorGenero.keys) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            genero,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: videosPorGenero[genero]!.length,
                            itemBuilder: (context, index) {
                              final video = videosPorGenero[genero]![index];
                              return GestureDetector(
                                onTap: () => _mostrarDetalles(context, video),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                  width: 100,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 160,
                                        child: Image.network(
                                          video['thumbnailUrl'],
                                          fit: BoxFit.fitHeight,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image),
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        video['titulo'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String titulo;

  const VideoPlayerScreen({super.key, required this.videoUrl, required this.titulo});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}