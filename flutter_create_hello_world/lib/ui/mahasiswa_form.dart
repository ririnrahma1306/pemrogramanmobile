 import 'package:flutter/material.dart'; 

 class MahasiswaForm extends StatefulWidget { 
   const MahasiswaForm({Key? key}) : super(key: key); 
   
   @override 
   State<MahasiswaForm> createState() => _MahasiswaFormState(); 
 } 
   
 class _MahasiswaFormState extends State<MahasiswaForm> { 
   @override 
   Widget build(BuildContext context) { 
     return Scaffold( 
       appBar: AppBar( 
        backgroundColor: Colors.blue,
         title: const Text("Form Mahasiswa"), 
       ), 
       body: SingleChildScrollView(
        padding: const EdgeInsets.all(16), 
         child: Column( 
           children: [ 
             TextField( 
               decoration: const InputDecoration(labelText: "NIM"), 
             ), 
             TextField( 
               decoration: const InputDecoration(labelText: "Nama"), 
             ), 
             TextField( 
               decoration: const InputDecoration(labelText: "Alamat"), 
             ),
             const SizedBox(height: 20), 
             ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // warna tombol
                foregroundColor: Colors.white, 
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                  ),
                ),// warna teks
              onPressed: () {},
              child: const Text("Simpan"),
              ), 
           ], 
         ), 
       ), 
     ); 
   } 
 }