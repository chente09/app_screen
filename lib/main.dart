import 'package:app_streaming/screens/loginScreen.dart';
import 'package:flutter/material.dart';

//Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      body: Container(
        color: Colors.black,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo_taller.png',
                height: 300,
              ),
              login_btn(context)
            ],
          ),
        ),
      ),
    );
  }
}

Widget login_btn(context) {
  return FilledButton(
    onPressed: () => login(context),
    child: Text("Login"),
    style: TextButton.styleFrom(
      backgroundColor: Color(0xFF537EB8),
    ),
  );
}

void login(context) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => Loginscreen()));
}
