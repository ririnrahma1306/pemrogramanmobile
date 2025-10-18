import 'package:flutter/material.dart';

void main() {
  runApp(ProfilDosenApp());
}

class ProfilDosenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profil Dosen App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: DaftarDosenPage(),
    );
  }
}

class DaftarDosenPage extends StatefulWidget {
  @override
  _DaftarDosenPageState createState() => _DaftarDosenPageState();
}

class _DaftarDosenPageState extends State<DaftarDosenPage> {
  List<Map<String, String>> daftarDosen = [
    {
      'nama': 'Dr. Ahmad Setiawan',
      'nip': '19870123 201501 1 001',
      'bidang': 'Kecerdasan Buatan',
      'foto': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'
    },
    {
      'nama': 'Prof. Rina Kartika',
      'nip': '19790511 200601 2 002',
      'bidang': 'Sistem Informasi',
      'foto': 'https://cdn-icons-png.flaticon.com/512/201/201634.png'
    },
    {
      'nama': 'Ir. Bambang Widodo, M.Kom',
      'nip': '19830315 200901 1 003',
      'bidang': 'Jaringan Komputer',
      'foto': 'https://cdn-icons-png.flaticon.com/512/2922/2922510.png'
    },
    {
      'nama': 'Dr. Laila Sari',
      'nip': '19851119 200802 2 004',
      'bidang': 'Data Science',
      'foto': 'https://cdn-icons-png.flaticon.com/512/4140/4140047.png'
    },
  ];

  List<Map<String, String>> hasilPencarian = [];
  TextEditingController cariController = TextEditingController();
  String sortOrder = 'A-Z'; // default urutan

  @override
  void initState() {
    super.initState();
    hasilPencarian = List.from(daftarDosen);
    _sortDosen(); // sortir awal A-Z
    cariController.addListener(_filterDosen);
  }

  void _filterDosen() {
    String keyword = cariController.text.toLowerCase();
    setState(() {
      hasilPencarian = daftarDosen.where((dosen) {
        return dosen['nama']!.toLowerCase().contains(keyword);
      }).toList();
      _sortDosen();
    });
  }

  void _sortDosen() {
    hasilPencarian.sort((a, b) {
      int comparison = a['nama']!.compareTo(b['nama']!);
      return sortOrder == 'A-Z' ? comparison : -comparison;
    });
  }

  void _changeSortOrder(String newOrder) {
    setState(() {
      sortOrder = newOrder;
      _sortDosen();
    });
  }

  @override
  void dispose() {
    cariController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Daftar Dosen',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              // 🔍 Kolom pencarian
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: cariController,
                  decoration: InputDecoration(
                    hintText: 'Cari dosen...',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // 📊 Dropdown sortir
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Urutkan: ',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<String>(
                        value: sortOrder,
                        underline: SizedBox(),
                        items: ['A-Z', 'Z-A'].map((order) {
                          return DropdownMenuItem<String>(
                            value: order,
                            child: Text(order),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) _changeSortOrder(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: hasilPencarian.isEmpty
                    ? Center(
                        child: Text(
                          'Dosen tidak ditemukan 😢',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: hasilPencarian.length,
                        itemBuilder: (context, index) {
                          final dosen = hasilPencarian[index];
                          return Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(dosen['foto']!),
                                radius: 30,
                              ),
                              title: Text(
                                dosen['nama']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                dosen['bidang']!,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios_rounded,
                                  size: 18, color: Colors.blue),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailDosenPage(dosen: dosen),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailDosenPage extends StatelessWidget {
  final Map<String, String> dosen;

  DetailDosenPage({required this.dosen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Detail Dosen',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 12,
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(dosen['foto']!),
                            radius: 60,
                          ),
                          SizedBox(height: 20),
                          Text(
                            dosen['nama']!,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'NIP: ${dosen['nip']}',
                            style:
                                TextStyle(fontSize: 16, color: Colors.grey[800]),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Bidang Keahlian: ${dosen['bidang']}',
                            style:
                                TextStyle(fontSize: 16, color: Colors.grey[800]),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back),
                            label: Text('Kembali'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
