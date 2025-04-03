import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/milk_record.dart';
import '../models/cattle.dart';
import '../services/storage_service.dart';

class AddMilkRecordScreen extends StatefulWidget {
  final StorageService storageService;
  
  const AddMilkRecordScreen({
    super.key, 
    required this.storageService,
  });

  @override
  State<AddMilkRecordScreen> createState() => _AddMilkRecordScreenState();
}

class _AddMilkRecordScreenState extends State<AddMilkRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _totalMilkController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _milkType = 'Whole Farm';
  String? _selectedCattleId;
  List<Cattle> _cattleList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _loadCattleData();
  }

  Future<void> _loadCattleData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final cattleList = await widget.storageService.getCattleList();
      setState(() {
        _cattleList = cattleList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error if needed
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _totalMilkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  void _saveMilkRecord() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Create a new milk record
      final milkRecord = MilkRecord(
        id: const Uuid().v4(),
        milkingDate: _selectedDate,
        milkType: _milkType,
        cattleId: _milkType == 'Individual Cow' ? _selectedCattleId : null,
        totalMilk: double.parse(_totalMilkController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      
      // Save milk record to storage
      await widget.storageService.addMilkRecord(milkRecord);
      
      // Return to previous screen
      if (mounted) {
        Navigator.pop(context, milkRecord);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Milk Record'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Date Field
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Milking Date',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Milk Type Selection
                    Text(
                      'Milk Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    RadioListTile<String>(
                      title: const Text('Whole Farm'),
                      value: 'Whole Farm',
                      groupValue: _milkType,
                      onChanged: (value) {
                        setState(() {
                          _milkType = value!;
                          _selectedCattleId = null;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Individual Cow'),
                      value: 'Individual Cow',
                      groupValue: _milkType,
                      onChanged: (value) {
                        setState(() {
                          _milkType = value!;
                        });
                      },
                    ),
                    
                    // Cattle Selection (only if Individual Cow is selected)
                    if (_milkType == 'Individual Cow')
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Cow',
                        ),
                        value: _selectedCattleId,
                        items: _cattleList.map((cattle) {
                          return DropdownMenuItem(
                            value: cattle.id,
                            child: Text('${cattle.tagNumber} - ${cattle.breed}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCattleId = value;
                          });
                        },
                        validator: (value) {
                          if (_milkType == 'Individual Cow' && (value == null || value.isEmpty)) {
                            return 'Please select a cow';
                          }
                          return null;
                        },
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Total Milk Field
                    TextFormField(
                      controller: _totalMilkController,
                      decoration: const InputDecoration(
                        labelText: 'Total Milk (liters)',
                        suffixText: 'liters',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the total milk produced';
                        }
                        try {
                          final milk = double.parse(value);
                          if (milk <= 0) {
                            return 'Milk amount must be greater than 0';
                          }
                        } catch (e) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Notes Field
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Save Button
                    ElevatedButton(
                      onPressed: _saveMilkRecord,
                      child: const Text('Save Milk Record'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 