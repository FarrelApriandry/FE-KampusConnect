import 'package:flutter/material.dart';
import 'pages/drama_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drakor Vault',
      theme: ThemeData.dark(),
      home: const DramaPage(),
    );
  }
}
