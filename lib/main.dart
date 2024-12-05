import 'package:app_streaming/screens/loginScreen.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(Pantalla01());
}
class Pantalla01 extends StatelessWidget {
  const Pantalla01({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Cuerpo(),
    );
  }
}

class Cuerpo extends StatelessWidget {
  const Cuerpo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pantalla 1"),
      ),
      body: Column(
        children: [
          Text("Pantalla 1"),
          login_btn(context),
        ],
      ),
    );
  }
}

Widget login_btn(context){
  return FilledButton(onPressed: ()=>login(context), child: Text("Login"),);
}

void login(context){
  Navigator.push(context, MaterialPageRoute(builder: (context)=>Loginscreen()));
}