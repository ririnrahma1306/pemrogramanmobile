import 'package:flutter/material.dart';
import 'ui/mahasiswa_form.dart';
   
 void main() { 
   runApp(const MyApp()); 
 } 
   
 class MyApp extends StatelessWidget { 
   const MyApp({Key? key}) : super(key: key); 
   
   @override 
   Widget build(BuildContext context) { 
    return MaterialApp(
  title: 'Perpustakaan',
  theme: ThemeData(
    primarySwatch: Colors.blue,
    useMaterial3: false,
  ),
  home: const MahasiswaForm(),
);
   } 
} 