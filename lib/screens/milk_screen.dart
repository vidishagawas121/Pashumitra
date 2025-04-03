import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/milk_record.dart';
import '../models/cattle.dart';
import '../services/storage_service.dart';
import 'add_milk_record_screen.dart';

class MilkScreen extends StatefulWidget {
  final StorageService? providedStorageService;
  
  const MilkScreen({super.key, this.providedStorageService});

  @override
  State<MilkScreen> createState() => _MilkScreenState();
}

class _MilkScreenState extends State<MilkScreen> {
  late final StorageService _storageService;
  List<MilkRecord> _milkRecords = [];
  Map<String, Cattle> _cattleMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _storageService = widget.providedStorageService ?? StorageService();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load milk records
      final milkRecords = await _storageService.getMilkRecords();
      
      // Load cattle for reference
      final cattleList = await _storageService.getCattleList();
      final Map<String, Cattle> cattleMap = {};
      
      for (var cattle in cattleList) {
        cattleMap[cattle.id] = cattle;
      }
      
      setState(() {
        _milkRecords = milkRecords;
        _cattleMap = cattleMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error if needed
    }
  }

  Future<void> _deleteMilkRecord(String id) async {
    await _storageService.deleteMilkRecord(id);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Production'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _milkRecords.isEmpty
              ? _buildEmptyState(context)
              : _buildMilkRecordsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMilkRecordScreen(
                storageService: _storageService,
              ),
            ),
          );
          
          if (result is MilkRecord) {
            await _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Milk record added: ${result.totalMilk} liters'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop,
            size: 80,
            color: Colors.blue.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Milk Records',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add your first milk production record',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMilkRecordScreen(
                    storageService: _storageService,
                  ),
                ),
              );
              
              if (result is MilkRecord) {
                await _loadData();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Milk Record'),
          ),
        ],
      ),
    );
  }

  Widget _buildMilkRecordsList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _milkRecords.length,
        itemBuilder: (context, index) {
          final milkRecord = _milkRecords[index];
          final dateFormat = DateFormat('MMM dd, yyyy');
          
          String subtitle;
          if (milkRecord.milkType == 'Individual Cow' && milkRecord.cattleId != null) {
            final cattle = _cattleMap[milkRecord.cattleId];
            subtitle = cattle != null 
                ? 'Cow: ${cattle.tagNumber} - ${cattle.breed}'
                : 'Unknown Cow';
          } else {
            subtitle = 'Whole Farm Production';
          }

          return Dismissible(
            key: Key(milkRecord.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Milk Record'),
                  content: const Text(
                    'Are you sure you want to delete this milk record?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              _deleteMilkRecord(milkRecord.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Milk record deleted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.water_drop,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  '${milkRecord.totalMilk.toStringAsFixed(1)} liters',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${dateFormat.format(milkRecord.milkingDate)}'),
                    Text(subtitle),
                    if (milkRecord.notes != null && milkRecord.notes!.isNotEmpty)
                      Text(
                        'Notes: ${milkRecord.notes}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                isThreeLine: true,
              ),
            ),
          );
        },
      ),
    );
  }
} 