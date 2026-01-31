import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //ใช้ไว้ติดตั้งตัว firebase in app
  await Firebase.initializeApp(
    //ไปเรียก firebase core
    options: DefaultFirebaseOptions
        .currentPlatform, //ไปเรียกfire base optiont ที่importมา
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _songNameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _songTypeCtrl = TextEditingController();

  void addSong() async{
    String _songName = _songNameCtrl.text;
    String _name = _nameCtrl.text;
    String _songType = _songTypeCtrl.text;

    print("ค่าที่เก็บ $_songName | $_name | $_songType");

    try{
      await FirebaseFirestore.instance.collection("song").add({
        "songName": _songName,
        "artis" : _name,
        "songType" : _songType

      });
      _songNameCtrl.clear();
      _nameCtrl.clear();
      _songTypeCtrl.clear();

    }catch(e){
      print("Eror : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(child: Column(children: [
        TextField(decoration: InputDecoration(labelText: "ชื่อเพลง"),
        controller: _songNameCtrl,
        ),
        TextField(decoration: InputDecoration(labelText: "ชื่อศิลปิน"),
        controller: _nameCtrl,
        ),
        TextField(decoration: InputDecoration(labelText: "แนวเพลง"),
        controller: _songTypeCtrl,
        ),
        ElevatedButton(onPressed: addSong, child: Text("บันทึก"))

        Expanded(child: child)
      ])),
    );
  }
}
