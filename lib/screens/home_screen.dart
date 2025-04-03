import 'package:flutter/material.dart';
import '../models/cattle.dart';
import '../models/event.dart';
import '../models/feed_cost.dart';
import '../services/storage_service.dart';
import '../utils/app_localizations.dart';
import 'cattle_list_screen.dart';
import 'milk_screen.dart';
import 'events_screen.dart';
import 'reports_screen.dart';
import 'trade_screen.dart';
import 'feed_cost_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  
  const HomeScreen({
    super.key, 
    required this.storageService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Cattle> _cattleList = [];
  List<Event> _events = [];
  List<FeedCost> _feedCosts = [];
  int _milkRecordsCount = 0;
  int _reportsCount = 0;
  int _tradeCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cattleList = await widget.storageService.getCattleList();
      final events = await widget.storageService.getEvents();
      final feedCosts = await widget.storageService.getFeedCosts();
      final milkRecords = await widget.storageService.getMilkRecords();
      final reports = await widget.storageService.getReports();
      
      setState(() {
        _cattleList = cattleList;
        _events = events;
        _feedCosts = feedCosts;
        _milkRecordsCount = milkRecords.length;
        _reportsCount = reports.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error message if needed
    }
  }

  Future<void> _addNewCattle(Cattle cattle) async {
    await widget.storageService.addCattle(cattle);
    await _loadData(); // Reload the data
  }

  @override
  Widget build(BuildContext context) {
    String appTitle, farmManagement, selectCategory;
    String cattleTitle, milkTitle, eventsTitle, reportsTitle, tradeTitle, feedCostTitle;
    
    try {
      appTitle = context.tr('app_name');
      farmManagement = context.tr('farm_management');
      selectCategory = context.tr('select_category');
      cattleTitle = context.tr('cattle');
      milkTitle = context.tr('milk');
      eventsTitle = context.tr('events');
      reportsTitle = context.tr('reports');
      tradeTitle = context.tr('trade');
      feedCostTitle = context.tr('feed_cost');
    } catch (e) {
      // Fallback values if translation fails
      appTitle = 'Cattle Manager';
      farmManagement = 'Farm Management';
      selectCategory = 'Select a category to manage';
      cattleTitle = 'Cattle';
      milkTitle = 'Milk';
      eventsTitle = 'Events';
      reportsTitle = 'Reports';
      tradeTitle = 'Trade';
      feedCostTitle = 'Feed Cost';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmManagement,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectCategory,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        _buildCategoryTile(
                          context,
                          title: cattleTitle,
                          icon: Icons.pets,
                          color: Colors.green.shade700,
                          count: _cattleList.length,
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => CattleListScreen(
                                  cattleList: _cattleList,
                                  onAddCattle: _addNewCattle,
                                  storageService: widget.storageService,
                                ),
                              ),
                            );
                            
                            if (result == true) {
                              // If data was changed, reload
                              _loadData();
                            }
                          },
                        ),
                        _buildCategoryTile(
                          context,
                          title: milkTitle,
                          icon: Icons.water_drop,
                          color: Colors.blue.shade700,
                          count: _milkRecordsCount,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => MilkScreen(
                                  providedStorageService: widget.storageService,
                                ),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                        _buildCategoryTile(
                          context,
                          title: eventsTitle,
                          icon: Icons.event_note,
                          color: Colors.amber.shade700,
                          count: _events.length,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => EventsScreen(
                                  providedStorageService: widget.storageService,
                                ),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                        _buildCategoryTile(
                          context,
                          title: reportsTitle,
                          icon: Icons.bar_chart,
                          color: Colors.red.shade700,
                          count: _reportsCount,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => ReportsScreen(
                                  providedStorageService: widget.storageService,
                                ),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                        _buildCategoryTile(
                          context,
                          title: tradeTitle,
                          icon: Icons.currency_exchange,
                          color: Colors.purple.shade700,
                          count: _tradeCount,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => const TradeScreen(),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                        _buildCategoryTile(
                          context,
                          title: feedCostTitle,
                          icon: Icons.grass,
                          color: Colors.teal.shade700,
                          count: _feedCosts.length,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => FeedCostScreen(
                                  storageService: widget.storageService,
                                ),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onTap,
  }) {
    String itemText;
    try {
      itemText = '$count ${count == 1 ? context.tr('item') : context.tr('items')}';
    } catch (e) {
      // Fallback if translation fails
      itemText = '$count ${count == 1 ? 'item' : 'items'}';
    }
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              itemText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 