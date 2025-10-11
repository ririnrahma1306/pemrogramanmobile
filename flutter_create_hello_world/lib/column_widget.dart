 import 'package:flutter/material.dart'; 

 class ColumnWidget extends StatelessWidget { 
   const ColumnWidget({Key? key}) : super(key: key); 
   
   @override 
   Widget build(BuildContext context) { 
     return Scaffold( 
appBar: AppBar(        
title: const Text("Widget Column"),
backgroundColor: Colors.blue, 
foregroundColor: Colors.white,
), 
body: const Column(  
  crossAxisAlignment:
  CrossAxisAlignment.start,          
children: [ 
Text("Kolom 1"), 
Text("Kolom 2"), 
Text("Kolom 3"),          
Text("Kolom 4") 
],          
), 
); 
   } 
 }