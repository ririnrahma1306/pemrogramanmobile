import 'package:flutter/material.dart'; 
 import '../model/mahasiswa.dart'; 
 import 'mahasiswa_detail.dart'; 
   
 class MahasiswaForm extends StatefulWidget { 
   const MahasiswaForm({Key? key}) : super(key: key); 
   
   @override 
   State<MahasiswaForm> createState() => _MahasiswaFormState(); 
 } 
   
 class _MahasiswaFormState extends State<MahasiswaForm> { 
   final _nimTxtCtrl = TextEditingController(); 
   final _namaTxtCtrl = TextEditingController(); 
   final _alamatTxtCtrl = TextEditingController(); 
   
   @override 
   Widget build(BuildContext context) { 
     return Scaffold( 
       appBar: AppBar( 
         title: const Text("Form Mahasiswa"), 
       ), 
       body: SingleChildScrollView( 
         child: Column( 
           children: [ 
             _txtFieldNim(), 
             _txtFieldNama(), 
             _txtFieldAlamat(), 
             _tombolSimpan() 
           ], 
         ), 
       ), 
     ); 
   } 
   
   _txtFieldNim() { 
     return TextField( 
       decoration: const InputDecoration(labelText: "NIM"), 
       controller: _nimTxtCtrl, 
     ); 
   } 
   
   _txtFieldNama() { 
     return TextField( 
       decoration: const InputDecoration(labelText: "Nama"), 
       controller: _namaTxtCtrl, 
     ); 
   } 
   
   _txtFieldAlamat() { 
     return TextField( 
       
decoration: const InputDecoration(labelText: "Alamat"), 
       
     
controller: _alamatTxtCtrl, 
); 
   } 
   
   _tombolSimpan() { 
     return ElevatedButton( 
         
onPressed: () { 
           
String nimMhs = _namaTxtCtrl.text; 
           
           
String namaMhs = _namaTxtCtrl.text; 
String alamatMhs = _alamatTxtCtrl.text; 
           
           
// membuat instance class Mahasiswa 
Mahasiswa mhs = 
               
           
Mahasiswa(nim: nimMhs, nama: namaMhs, alamat: alamatMhs); 
// pindah ke halaman Detail Mahasiswa dan mengirim data mahasiswa 
           
               
Navigator.of(context).push(MaterialPageRoute( 
builder: (context) => MahasiswaDetail( 
                     
                   
mahasiswa: mhs, 
))); 
         
         
}, 
child: const Text("Simpan")); 
   } 
 } 