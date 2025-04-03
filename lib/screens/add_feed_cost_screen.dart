import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/feed_cost.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/app_localizations.dart';

class AddFeedCostScreen extends StatefulWidget {
  final StorageService storageService;
  
  const AddFeedCostScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<AddFeedCostScreen> createState() => _AddFeedCostScreenState();
}

class _AddFeedCostScreenState extends State<AddFeedCostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costPerUnitController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedFeedType = FeedConstants.feedTypes[0];
  String _selectedQuantityUnit = FeedConstants.quantityUnits[0];
  bool _isCalculatingTotal = true; // If true, total = quantity * costPerUnit
  
  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    // Add listeners to update calculations
    _quantityController.addListener(_updateCalculations);
    _costPerUnitController.addListener(_updateCalculations);
    _totalCostController.addListener(_handleTotalCostChange);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _quantityController.dispose();
    _costPerUnitController.dispose();
    _totalCostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    if (!_isCalculatingTotal) return;
    
    if (_quantityController.text.isNotEmpty && _costPerUnitController.text.isNotEmpty) {
      try {
        final quantity = double.parse(_quantityController.text);
        final costPerUnit = double.parse(_costPerUnitController.text);
        final total = quantity * costPerUnit;
        _totalCostController.text = total.toStringAsFixed(2);
      } catch (e) {
        // Handle parsing errors
      }
    }
  }

  void _handleTotalCostChange() {
    // When user manually edits the total cost, stop automatic calculation
    if (_totalCostController.text.isNotEmpty && 
        _quantityController.text.isNotEmpty && 
        _costPerUnitController.text.isNotEmpty) {
      try {
        final quantity = double.parse(_quantityController.text);
        final costPerUnit = double.parse(_costPerUnitController.text);
        final expectedTotal = quantity * costPerUnit;
        final actualTotal = double.parse(_totalCostController.text);
        
        if (expectedTotal != actualTotal) {
          setState(() {
            _isCalculatingTotal = false;
          });
        }
      } catch (e) {
        // Handle parsing errors
      }
    }
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

  void _saveFeedCost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final quantity = double.parse(_quantityController.text);
      final costPerUnit = double.parse(_costPerUnitController.text);
      final totalCost = double.parse(_totalCostController.text);
      
      // Create a new feed cost entry
      final feedCost = FeedCost(
        id: const Uuid().v4(),
        date: _selectedDate,
        feedType: _selectedFeedType,
        quantity: quantity,
        quantityUnit: _selectedQuantityUnit,
        costPerUnit: costPerUnit,
        totalCost: totalCost,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      
      // Save to storage
      await widget.storageService.addFeedCost(feedCost);
      
      // Return to previous screen
      if (mounted) {
        Navigator.pop(context, feedCost);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('add_feed_cost')),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Date Field
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: context.tr('date'),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('please_select_date');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Feed Type Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: context.tr('feed_type'),
                  border: const OutlineInputBorder(),
                ),
                value: _selectedFeedType,
                items: FeedConstants.feedTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFeedType = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('please_select_feed_type');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Quantity and Unit
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: context.tr('quantity'),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.tr('please_enter_quantity');
                        }
                        if (double.tryParse(value) == null) {
                          return context.tr('please_enter_valid_number');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: context.tr('unit'),
                        border: const OutlineInputBorder(),
                      ),
                      value: _selectedQuantityUnit,
                      items: FeedConstants.quantityUnits.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedQuantityUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Cost Per Unit
              TextFormField(
                controller: _costPerUnitController,
                decoration: InputDecoration(
                  labelText: context.tr('cost_per_unit'),
                  border: const OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('please_enter_cost_per_unit');
                  }
                  if (double.tryParse(value) == null) {
                    return context.tr('please_enter_valid_number');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Total Cost
              TextFormField(
                controller: _totalCostController,
                decoration: InputDecoration(
                  labelText: context.tr('total_cost'),
                  border: const OutlineInputBorder(),
                  prefixText: '\$',
                  suffixIcon: _isCalculatingTotal 
                      ? const Icon(Icons.calculate, color: Colors.grey)
                      : IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Recalculate from quantity and cost per unit',
                          onPressed: () {
                            setState(() {
                              _isCalculatingTotal = true;
                              _updateCalculations();
                            });
                          },
                        ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('please_enter_total_cost');
                  }
                  if (double.tryParse(value) == null) {
                    return context.tr('please_enter_valid_number');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: context.tr('notes_optional'),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              ElevatedButton(
                onPressed: _saveFeedCost,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  context.tr('save_feed_cost'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 