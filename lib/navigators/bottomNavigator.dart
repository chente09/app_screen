import 'package:app_streaming/screens/homeScreen.dart';
import 'package:app_streaming/screens/perfilUserScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  runApp(const BottomNavigator());
}

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({super.key});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
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

  List<String> titulos = ["Home", "Profile"];

  List<Widget> paginas = [HomeScreen(), PerfilUserScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulos[indice]),
        
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
      body: 
      paginas[indice],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indice,
        onTap: (value) {
          setState(() {
            indice = value;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}


