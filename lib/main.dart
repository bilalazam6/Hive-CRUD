import 'package:flutter/material.dart';
import 'package:hive_crud/hivedatabaseFfutter.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("MYBox");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const  MaterialApp(
    
      debugShowCheckedModeBanner: false,
      home: HiveDatabaseFlutter(),
    );
  }
}

