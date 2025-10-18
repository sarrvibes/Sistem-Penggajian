import 'package:flutter/material.dart';
import 'package:flutter_sistem_penggajian/database/database.dart';
import '../models/karyawan.dart';


class AddEditKaryawanPage extends StatefulWidget {
  final Karyawan? karyawan;
  AddEditKaryawanPage({this.karyawan});

  @override
  State<AddEditKaryawanPage> createState() => _AddEditKaryawanPageState();
}

class _AddEditKaryawanPageState extends State<AddEditKaryawanPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _baseController = TextEditingController();
  final _allowanceController = TextEditingController();
  final _deductionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.karyawan != null) {
      final e = widget.karyawan!;
      _nameController.text = e.name;
      _positionController.text = e.position;
      _baseController.text = e.baseSalary.toString();
      _allowanceController.text = e.allowance.toString();
      _deductionController.text = e.deduction.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _baseController.dispose();
    _allowanceController.dispose();
    _deductionController.dispose();
    super.dispose();
  }

  double _parse(String s) {
    if (s.trim().isEmpty) return 0.0;
    return double.tryParse(s.replaceAll(',', '')) ?? 0.0;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final pos = _positionController.text.trim();
    final base = _parse(_baseController.text);
    final allow = _parse(_allowanceController.text);
    final deduct = _parse(_deductionController.text);
    final total = Karyawan.computeTotal(base, allow, deduct);

    final emp = Karyawan(
      id: widget.karyawan?.id,
      name: name,
      position: pos,
      baseSalary: base,
      allowance: allow,
      deduction: deduct,
      totalSalary: total,
    );

    if (widget.karyawan == null) {
      await DatabaseKaryawan.instance.createKaryawan(emp);
    } else {
      await DatabaseKaryawan.instance.updateKaryawan(emp);
    }

    Navigator.of(context).pop();
  }

  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    return null;
  }

  String? _numValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    final parsed = double.tryParse(v.replaceAll(',', ''));
    if (parsed == null) return 'Masukkan angka valid';
    if (parsed < 0) return 'Tidak boleh negatif';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.karyawan != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Karyawan' : 'Tambah Karyawan')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Karyawan'),
                validator: _required,
              ),
              TextFormField(
                controller: _positionController,
                decoration: InputDecoration(labelText: 'Jabatan'),
                validator: _required,
              ),
              TextFormField(
                controller: _baseController,
                decoration: InputDecoration(labelText: 'Gaji Pokok'),
                keyboardType: TextInputType.number,
                validator: _numValidator,
              ),
              TextFormField(
                controller: _allowanceController,
                decoration: InputDecoration(labelText: 'Tunjangan'),
                keyboardType: TextInputType.number,
                validator: _numValidator,
              ),
              TextFormField(
                controller: _deductionController,
                decoration: InputDecoration(labelText: 'Potongan'),
                keyboardType: TextInputType.number,
                validator: _numValidator,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? 'Update' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
