import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:message_app/auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD6hha9Aw-P7SmNSECdnj2uYFnOCAMPye8",
      appId: "1:808742797976:web:e338f4d8539dc29e0a06ed",
      messagingSenderId: "808742797976",
      projectId: "messageapp-443ec",
      storageBucket: "messageapp-443ec.appspot.com",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}
