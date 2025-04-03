import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/cattle.dart';
import '../models/event.dart';
import '../services/storage_service.dart';

class AddEventScreen extends StatefulWidget {
  final StorageService storageService;
  
  const AddEventScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedCattleId;
  String _selectedEventType = 'Vaccination';
  List<Cattle> _cattleList = [];
  bool _isLoading = true;
  
  final List<String> _eventTypes = [
    'Vaccination',
    'Heat Cycle',
    'Pregnancy'
  ];

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
        
        // Set default cattle if available
        if (cattleList.isNotEmpty && _selectedCattleId == null) {
          _selectedCattleId = cattleList.first.id;
        }
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
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Allow future dates for planned events
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Create a new event
      final event = Event(
        id: const Uuid().v4(),
        cattleId: _selectedCattleId!,
        eventDate: _selectedDate,
        eventType: _selectedEventType,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      
      // Save event to storage
      await widget.storageService.addEvent(event);
      
      // Return to previous screen
      if (mounted) {
        Navigator.pop(context, event);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _cattleList.isEmpty
              ? _buildNoCattleMessage()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        // Cattle Selection
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Cattle',
                            border: OutlineInputBorder(),
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
                            if (value == null || value.isEmpty) {
                              return 'Please select a cattle';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Date Field
                        TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            labelText: 'Event Date',
                            border: const OutlineInputBorder(),
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
                        
                        // Event Type Selection
                        Text(
                          'Event Type',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(_eventTypes.length, (index) {
                          return RadioListTile<String>(
                            title: Text(_eventTypes[index]),
                            value: _eventTypes[index],
                            groupValue: _selectedEventType,
                            onChanged: (value) {
                              setState(() {
                                _selectedEventType = value!;
                              });
                            },
                          );
                        }),
                        const SizedBox(height: 16),
                        
                        // Notes Field
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Save Button
                        ElevatedButton(
                          onPressed: _saveEvent,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Save Event',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildNoCattleMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: Colors.amber.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Cattle Available',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'You need to add cattle before creating events',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
} 