// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../core/providers/dependency_providers.dart';
import '../database/perfil_model.dart';
import '../repository/database.dart';
import '../widgets/appbar.dart';

// import 'package:image_picker/image_picker.dart';

class CadastroPerfilPage extends ConsumerStatefulWidget {
  const CadastroPerfilPage({super.key, this.perfil});
  final PerfilModel? perfil;

  @override
  ConsumerState<CadastroPerfilPage> createState() => _CadastroPerfilPageState();
}

class _CadastroPerfilPageState extends ConsumerState<CadastroPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  // final ImagePicker _picker = ImagePicker();

  late PerfilModel _localPerfil;

  @override
  initState() {
    super.initState();
    _initModel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initModel() {
    if (widget.perfil != null) {
      _localPerfil = widget.perfil!;
    } else {
      _localPerfil = PerfilModel(
        id: DatabaseRepository.generateIdReg(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        nome: '',
        datanascimento: DateTime.now(),
        altura: 0.0,
        peso: 0.0,
        genero: 0,
      );
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final repository = ref.read(perfilRepositoryProvider);
      if (widget.perfil != null) {
        repository.put(_localPerfil);
      } else {
        repository.post(_localPerfil);
      }

      Navigator.of(context).pop();
    }
  }

  Future<void> _pickImage() async {
    // final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    // if (pickedFile != null) {
    //   setState(() {
    //     _localPerfil.imagePath = pickedFile.path;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NutriAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _localPerfil.imagePath != null
                          ? FileImage(File(_localPerfil.imagePath!))
                          : null,
                      child: _localPerfil.imagePath == null
                          ? const Icon(Icons.add_a_photo, size: 30)
                          : null,
                    ),
                  ),
                  TextFormField(
                    initialValue: _localPerfil.nome,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _localPerfil = _localPerfil.copyWith(nome: value);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: DateFormat(
                      'dd/MM/yyyy',
                    ).format(_localPerfil.datanascimento),
                    decoration: const InputDecoration(
                      labelText: 'Data de Nascimento',
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _localPerfil = _localPerfil.copyWith(
                            datanascimento: pickedDate,
                          );
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a data de nascimento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: _localPerfil.altura.toString(),
                    decoration: const InputDecoration(labelText: 'Altura (m)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a altura';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _localPerfil = _localPerfil.copyWith(
                        altura: double.parse(value!),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: _localPerfil.peso.toString(),
                    decoration: const InputDecoration(labelText: 'Peso (kg)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o peso';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _localPerfil = _localPerfil.copyWith(
                        peso: double.parse(value!),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: _localPerfil.genero,
                    decoration: const InputDecoration(labelText: 'Gênero'),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Masculino')),
                      DropdownMenuItem(value: 1, child: Text('Feminino')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _localPerfil = _localPerfil.copyWith(genero: value);
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor, selecione o gênero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _save();

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Atualizar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
