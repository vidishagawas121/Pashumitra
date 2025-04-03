import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cattle.dart';
import '../services/storage_service.dart';
import 'add_cattle_screen.dart';

class CattleListScreen extends StatefulWidget {
  final List<Cattle> cattleList;
  final Function(Cattle) onAddCattle;
  final StorageService storageService;

  const CattleListScreen({
    super.key,
    required this.cattleList,
    required this.onAddCattle,
    required this.storageService,
  });

  @override
  State<CattleListScreen> createState() => _CattleListScreenState();
}

class _CattleListScreenState extends State<CattleListScreen> {
  late List<Cattle> _cattleList;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cattleList = List.from(widget.cattleList);
  }
  
  Future<void> _refreshCattleList() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final cattleList = await widget.storageService.getCattleList();
      setState(() {
        _cattleList = cattleList;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCattle(String id) async {
    await widget.storageService.deleteCattle(id);
    await _refreshCattleList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cattle List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshCattleList,
              child: _cattleList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pets,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No cattle added yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Tap the + button to add one',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _cattleList.length,
                      itemBuilder: (ctx, index) {
                        final cattle = _cattleList[index];
                        return Dismissible(
                          key: Key(cattle.id),
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
                                title: const Text('Delete Cattle'),
                                content: Text(
                                  'Are you sure you want to delete ${cattle.tagNumber}?',
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
                            _deleteCattle(cattle.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${cattle.tagNumber} deleted'),
                                duration: const Duration(seconds: 2),
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
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Text(
                                  cattle.tagNumber.substring(0, 1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                '${cattle.tagNumber} - ${cattle.breed}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gender: ${cattle.gender} | Weight: ${cattle.weight} kg',
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'DOB: ${DateFormat('dd MMM yyyy').format(cattle.dateOfBirth)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  // TODO: Implement options menu
                                },
                              ),
                              onTap: () {
                                // TODO: Navigate to cattle details screen
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => AddCattleScreen(onAddCattle: widget.onAddCattle),
            ),
          );
          
          if (result == true) {
            await _refreshCattleList();
            Navigator.of(context).pop(true); // Return true to indicate data changed
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 