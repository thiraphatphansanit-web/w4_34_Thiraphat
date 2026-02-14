import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      // เปลี่ยนธีมเป็นสี Teal (เขียวอมฟ้า) ให้ดูมินิมอลขึ้น
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Music Library'),
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

  void addSong() async {
    String songName = _songNameCtrl.text.trim();
    String name = _nameCtrl.text.trim();
    String songType = _songTypeCtrl.text.trim();

    try {
      // แก้ไข 1: เปลี่ยนชื่อ collection ให้เป็น "songs" ให้ตรงกับ StreamBuilder
      await FirebaseFirestore.instance.collection("songs").add({
        "songName": songName,
        "artist": name, // ใช้คีย์คำว่า artist
        "songType": songType
      });
      _songNameCtrl.clear();
      _nameCtrl.clear();
      _songTypeCtrl.clear();

      FocusScope.of(context).unfocus(); // ปิดแป้นพิมพ์
    } catch (e) {
      print("Error : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // พื้นหลังแอปสีเทาอ่อน
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            // ส่วนกรอกข้อมูล ใช้ฟังก์ชันแยกเพื่อไม่ให้โค้ดรก
            _buildCustomTextField(_songNameCtrl, "ชื่อเพลง", Icons.music_note),
            const SizedBox(height: 12),
            _buildCustomTextField(_nameCtrl, "ชื่อศิลปิน", Icons.person),
            const SizedBox(height: 12),
            _buildCustomTextField(_songTypeCtrl, "แนวเพลง", Icons.album),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton( // ใช้ FilledButton แบบแบนราบ ขอบมน
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: addSong,
                child: const Text("บันทึกข้อมูล", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection("songs").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final docs = snapshot.data!.docs;

                  return GridView.builder(
                    itemCount: docs.length, // แก้ไข 2: เพิ่ม itemCount ป้องกัน Error
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final songDoc = docs[index];
                      final s = songDoc.data() as Map<String, dynamic>;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SongDetail(song: s)),
                          );
                        },
                        // ออกแบบ Grid ใหม่แบบไม่มีเงา ใช้กรอบเส้นแทน
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.teal.shade100, width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow, color: Colors.teal, size: 30),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                s["songName"] ?? "-",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s["artist"] ?? "-", // ให้ตรงกับตอนบันทึก
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันช่วยสร้าง TextField ให้โค้ดสั้นลง
  Widget _buildCustomTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal.shade300),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }
}

class SongDetail extends StatelessWidget {
  final Map<String, dynamic> song; // แก้ไข 3: ระบุ Type ให้ชัดเจน

  const SongDetail({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Song Detail"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ส่วนหัวแบบแบนราบ โชว์ไอคอนใหญ่ๆ
            Container(
              width: double.infinity,
              color: Colors.teal,
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              child: const Icon(Icons.headphones, size: 90, color: Colors.white),
            ),
            const SizedBox(height: 30),

            // แก้ไข 4: ใช้กล้ามปู [] ในการเรียก Map ไม่ใช่วงเล็บ () แบบที่คุณเขียนมา
            Text(
              song["songName"] ?? "ไม่ทราบชื่อเพลง",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              song["artist"] ?? "ไม่ทราบศิลปิน", // ให้ตรงกับตอนบันทึก
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 30),

            // แสดงแนวเพลงในกรอบแคปซูล
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                "ประเภท: ${song["songType"] ?? "-"}",
                style: const TextStyle(fontSize: 16, color: Colors.teal, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}