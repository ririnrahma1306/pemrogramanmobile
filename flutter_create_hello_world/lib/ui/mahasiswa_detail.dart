 import 'package:flutter/material.dart'; 
 import '../model/mahasiswa.dart'; 
   
 class MahasiswaDetail extends StatefulWidget { 
   final Mahasiswa? mahasiswa; 
   
   const MahasiswaDetail({Key? key, this.mahasiswa}) : super(key: key); 
   
   @override 
   State<MahasiswaDetail> createState() => _MahasiswaDetailState(); 
 } 
   
 class _MahasiswaDetailState extends State<MahasiswaDetail> { 
   @override 
   Widget build(BuildContext context) { 
     return Scaffold( 
       appBar: AppBar( 
         title: const Text("Mahasiswa"), 
       ), 
       body: Column( 
         children: [ 
           Text("NIM : " + widget.mahasiswa!.nim.toString()), 
           Text("Nama : ${widget.mahasiswa!.nama}"), 
           Text("Alamat : ${widget.mahasiswa!.alamat}"), 
           _tombolEditHapus() 
         ], 
       ), 
     ); 
   } 
   
   Widget _tombolEditHapus() { 
     return Row( 
       mainAxisSize: MainAxisSize.min, 
       children: [ 
         ElevatedButton( 
           onPressed: () {}, 
           child: const Text("Ubah"), 
           style: ElevatedButton.styleFrom(backgroundColor: Colors.green), 
         ), 
         const SizedBox( 
           width: 10.0, 
         ), 
         ElevatedButton( 
           onPressed: () {}, 
           child: const Text("Hapus"),  
           style: ElevatedButton.styleFrom(backgroundColor: Colors.red), 
         ) 
       ], 
     ); 
   } 
 } 