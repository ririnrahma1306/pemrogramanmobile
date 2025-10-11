import 'package:flutter/material.dart'; 
   
 class HelloWorld extends StatelessWidget { 
   const HelloWorld({Key? key}) : super(key: key); 
   
   @override 
   Widget build(BuildContext context) { 
     return Scaffold( 
       appBar: AppBar( 
         title: const Text("Belajar Flutter"),
         backgroundColor: Colors.blue,  
         foregroundColor: Colors.white,
       ), 
       body: const Center( 
         child: Text("Hello World"), 
       ), 
     ); 
   } 
} 
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
      