import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/feed_cost.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/app_localizations.dart';
import 'add_feed_cost_screen.dart';

class FeedCostScreen extends StatefulWidget {
  final StorageService storageService;
  
  const FeedCostScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<FeedCostScreen> createState() => _FeedCostScreenState();
}

class _FeedCostScreenState extends State<FeedCostScreen> {
  List<FeedCost> _feedCosts = [];
  List<FeedCost> _allFeedCosts = [];
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String? _selectedFeedType;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadFeedCosts();
  }
  
  Future<void> _loadFeedCosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var feedCosts = await widget.storageService.getFeedCosts();
      
      // If no feed costs exist, add dummy data
      if (feedCosts.isEmpty) {
        await _addDummyFeedCosts();
        feedCosts = await widget.storageService.getFeedCosts();
      }
      
      setState(() {
        _allFeedCosts = feedCosts;
        _isLoading = false;
      });
      
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }
  
  Future<void> _addDummyFeedCosts() async {
    final dummyFeedCosts = [
      FeedCost(
        id: const Uuid().v4(),
        date: DateTime.now().subtract(const Duration(days: 2)),
        feedType: 'Hay',
        quantity: 50,
        quantityUnit: 'kg',
        costPerUnit: 5.0,
        totalCost: 250.0,
        notes: 'Good quality hay from local supplier',
      ),
      FeedCost(
        id: const Uuid().v4(),
        date: DateTime.now().subtract(const Duration(days: 5)),
        feedType: 'Grain',
        quantity: 100,
        quantityUnit: 'kg',
        costPerUnit: 4.5,
        totalCost: 450.0,
        notes: null,
      ),
      FeedCost(
        id: const Uuid().v4(),
        date: DateTime.now().subtract(const Duration(days: 8)),
        feedType: 'Silage',
        quantity: 200,
        quantityUnit: 'kg',
        costPerUnit: 1.6,
        totalCost: 320.0,
        notes: 'Corn silage',
      ),
      FeedCost(
        id: const Uuid().v4(),
        date: DateTime.now().subtract(const Duration(days: 12)),
        feedType: 'Concentrate',
        quantity: 25,
        quantityUnit: 'bags',
        costPerUnit: 18.0,
        totalCost: 450.0,
        notes: 'Dairy concentrate mix',
      ),
      FeedCost(
        id: const Uuid().v4(),
        date: DateTime.now().subtract(const Duration(days: 15)),
        feedType: 'Mineral Mix',
        quantity: 5,
        quantityUnit: 'kg',
        costPerUnit: 22.0,
        totalCost: 110.0,
        notes: null,
      ),
    ];
    
    for (var feedCost in dummyFeedCosts) {
      await widget.storageService.addFeedCost(feedCost);
    }
  }
  
  void _applyFilters() {
    // Start with all feed costs and apply filters
    List<FeedCost> filteredCosts = List.from(_allFeedCosts);
    
    // Apply date filter
    filteredCosts = filteredCosts.where((cost) {
      return cost.date.isAfter(_startDate.subtract(const Duration(days: 1))) && 
             cost.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
    
    // Apply feed type filter if selected
    if (_selectedFeedType != null) {
      filteredCosts = filteredCosts.where((cost) => 
        cost.feedType == _selectedFeedType
      ).toList();
    }
    
    setState(() {
      _feedCosts = filteredCosts;
    });
  }
  
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _applyFilters();
      });
    }
  }
  
  void _selectFeedType(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('filter_by_feed_type')),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text(context.tr('all_types')),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: _selectedFeedType,
                    onChanged: (value) {
                      Navigator.pop(context);
                      setState(() {
                        _selectedFeedType = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                ...FeedConstants.feedTypes.map((type) => 
                  ListTile(
                    title: Text(type),
                    leading: Radio<String?>(
                      value: type,
                      groupValue: _selectedFeedType,
                      onChanged: (value) {
                        Navigator.pop(context);
                        setState(() {
                          _selectedFeedType = value;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _addFeedCost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFeedCostScreen(
          storageService: widget.storageService,
        ),
      ),
    );
    
    if (result != null) {
      _loadFeedCosts();
    }
  }
  
  void _showFeedCostOptions(FeedCost feedCost) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(context.tr('edit')),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement edit functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  context.tr('delete'),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteFeedCost(feedCost);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _deleteFeedCost(FeedCost feedCost) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final message = context.tr('confirm_delete_message').replaceAll('{feedType}', feedCost.feedType);
        
        return AlertDialog(
          title: Text(context.tr('confirm_delete')),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                context.tr('delete'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    
    if (confirmed == true) {
      await widget.storageService.deleteFeedCost(feedCost.id);
      _loadFeedCosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    // Calculate summary statistics
    final totalCost = _feedCosts.fold(0.0, (sum, item) => sum + item.totalCost);
    
    // Get total number of animals from the storage service (this would need to be implemented)
    final totalAnimals = 12; // This is just a placeholder
    final perAnimal = totalAnimals > 0 ? totalCost / totalAnimals : 0;
    
    // Calculate days in selected period
    final dayDifference = _endDate.difference(_startDate).inDays + 1;
    final perDay = dayDifference > 0 ? totalCost / dayDifference : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('feed_cost_management')),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Filter by date range',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _selectFeedType(context),
            tooltip: 'Filter by feed type',
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Date range indicator
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (_selectedFeedType != null) ...[
                        const SizedBox(width: 16),
                        const Icon(Icons.filter_list, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${context.tr('feed_type')}: $_selectedFeedType',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.teal.shade50,
                  child: Column(
                    children: [
                      Text(
                        context.tr('feed_cost_summary'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            context,
                            title: context.tr('total'),
                            amount: currencyFormat.format(totalCost),
                            icon: Icons.date_range,
                            color: Colors.teal,
                          ),
                          _buildSummaryItem(
                            context,
                            title: context.tr('per_animal'),
                            amount: currencyFormat.format(perAnimal),
                            icon: Icons.pets,
                            color: Colors.orange,
                          ),
                          _buildSummaryItem(
                            context,
                            title: context.tr('per_day'),
                            amount: currencyFormat.format(perDay),
                            icon: Icons.access_time,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _feedCosts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.no_food,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.tr('no_feed_costs_found'),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _addFeedCost,
                                icon: const Icon(Icons.add),
                                label: Text(context.tr('add_feed_cost')),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _feedCosts.length,
                          itemBuilder: (context, index) {
                            final feedCost = _feedCosts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getFeedIcon(feedCost.feedType),
                                      color: Colors.teal,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      feedCost.feedType,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${feedCost.quantity} ${feedCost.quantityUnit}'),
                                    Text(
                                      currencyFormat.format(feedCost.totalCost),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      '${context.tr('date')}: ${dateFormat.format(feedCost.date)}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (feedCost.notes != null && feedCost.notes!.isNotEmpty) 
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${context.tr('notes')}: ${feedCost.notes}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () => _showFeedCostOptions(feedCost),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFeedCost,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getFeedIcon(String feedType) {
    switch (feedType.toLowerCase()) {
      case 'hay':
        return Icons.grass;
      case 'grain mix':
      case 'grain':
        return Icons.grain;
      case 'silage':
        return Icons.agriculture;
      case 'concentrate':
        return Icons.science;
      case 'supplement':
        return Icons.medical_services;
      default:
        return Icons.fastfood;
    }
  }
} 