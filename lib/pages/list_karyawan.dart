import 'package:flutter/material.dart';
import '../database/database.dart';
import '../models/karyawan.dart';
import 'form_karyawan.dart';

class KaryawanListPage extends StatefulWidget {
  @override
  State<KaryawanListPage> createState() => _KaryawanListPageState();
}

class _KaryawanListPageState extends State<KaryawanListPage> {
  late Future<List<Karyawan>> _karyawanFuture;

  @override
  void initState() {
    super.initState();
    _loadKaryawan();
  }

  void _loadKaryawan() {
    _karyawanFuture = DatabaseKaryawan.instance.readAllKaryawan();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadKaryawan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Gaji Karyawan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Karyawan>>(
        future: _karyawanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Text('Belum ada data karyawan. Tambah data baru.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final k = list[index];
              return ListTile(
                title: Text(k.name),
                subtitle: Text('${k.position} • Total: Rp ${k.totalSalary.toStringAsFixed(0)}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AddEditKaryawanPage(karyawan: k),
                      ));
                      _refresh();
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Konfirmasi'),
                          content: Text('Hapus data ${k.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await DatabaseKaryawan.instance.deleteKaryawan(k.id!);
                        _refresh();
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => AddEditKaryawanPage()));
          _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
