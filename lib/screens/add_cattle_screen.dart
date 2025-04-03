import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/cattle.dart';

class AddCattleScreen extends StatefulWidget {
  final Function(Cattle) onAddCattle;

  const AddCattleScreen({
    super.key,
    required this.onAddCattle,
  });

  @override
  State<AddCattleScreen> createState() => _AddCattleScreenState();
}

class _AddCattleScreenState extends State<AddCattleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedGender = 'Female';
  final List<String> _genderOptions = ['Female', 'Male'];
  final List<String> _breedOptions = [
    'Holstein',
    'Angus',
    'Hereford',
    'Jersey',
    'Brahman',
    'Simmental',
    'Charolais',
    'Limousin',
    'Other'
  ];

  @override
  void dispose() {
    _tagController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newCattle = Cattle(
        id: const Uuid().v4(),
        tagNumber: _tagController.text,
        breed: _breedController.text,
        dateOfBirth: _selectedDate,
        gender: _selectedGender,
        weight: double.parse(_weightController.text),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      
      widget.onAddCattle(newCattle);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Cattle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    labelText: 'Tag Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a tag number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: 'Breed',
                    border: OutlineInputBorder(),
                  ),
                  items: _breedOptions.map((breed) {
                    return DropdownMenuItem(
                      value: breed,
                      child: Text(breed),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _breedController.text = value;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a breed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date of Birth: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('Select Date'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    const Text('Gender: ', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    ...List.generate(_genderOptions.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: _genderOptions[index],
                              groupValue: _selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value!;
                                });
                              },
                            ),
                            Text(_genderOptions[index]),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter weight';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Add Cattle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 