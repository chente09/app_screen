import 'package:app_streaming/screens/adminCrudScreen.dart';
import 'package:app_streaming/screens/adminScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MultimediaCrudNavigator());
}

class MultimediaCrudNavigator extends StatefulWidget {
  const MultimediaCrudNavigator({super.key});

  @override
  State<MultimediaCrudNavigator> createState() => _MultimediaCrudNavigatorState();
}

class _MultimediaCrudNavigatorState extends State<MultimediaCrudNavigator> {
  bool _modoOscuro = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _modoOscuro ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: Cuerpo(
        modoOscuro: (value) {
          setState(() {
            _modoOscuro = value;
          });
        },
      ),
    );
  }
}

class Cuerpo extends StatefulWidget {
  final ValueChanged<bool>? modoOscuro;
  const Cuerpo({super.key, required this.modoOscuro});

  @override
  State<Cuerpo> createState() => _CuerpoState();
}

class _CuerpoState extends State<Cuerpo> {

  int indice = 0;
  List<Widget> paginas = [AdminMultimedia(), AdminMultimediaCRUD()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        actions: [
          IconButton(
            onPressed: () {
              // Invertir el valor actual del modo oscuro
              widget.modoOscuro!(
                  !(Theme.of(context).brightness == Brightness.dark));
            },
            icon: Icon(Icons.dark_mode),
          ),
        ],
      ),
      body: paginas[indice],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indice,
        onTap: (value) {
          setState(() {
            indice = value;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.personal_video_outlined), label: ""),
        ],
      ),
    );
  }
}

class Peliculas extends StatelessWidget {
  const Peliculas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("data"),
      ),
    );
  }
}
