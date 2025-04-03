import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cattle.dart';
import '../models/event.dart';
import '../services/storage_service.dart';
import 'add_event_screen.dart';

class EventsScreen extends StatefulWidget {
  final StorageService? providedStorageService;
  
  const EventsScreen({super.key, this.providedStorageService});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late final StorageService _storageService;
  List<Event> _events = [];
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
      // Load events
      final events = await _storageService.getEvents();
      
      // Load cattle for reference
      final cattleList = await _storageService.getCattleList();
      final Map<String, Cattle> cattleMap = {};
      
      for (var cattle in cattleList) {
        cattleMap[cattle.id] = cattle;
      }
      
      // Sort events by date (most recent first)
      events.sort((a, b) => b.eventDate.compareTo(a.eventDate));
      
      setState(() {
        _events = events;
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
  
  Future<void> _deleteEvent(String id) async {
    await _storageService.deleteEvent(id);
    await _loadData();
  }
  
  // Get icon based on event type
  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'Vaccination':
        return Icons.medical_services;
      case 'Heat Cycle':
        return Icons.replay;
      case 'Pregnancy':
        return Icons.pregnant_woman;
      default:
        return Icons.event_note;
    }
  }
  
  // Get color based on event type
  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'Vaccination':
        return Colors.blue;
      case 'Heat Cycle':
        return Colors.red;
      case 'Pregnancy':
        return Colors.purple;
      default:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? _buildEmptyState(context)
              : _buildEventsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventScreen(
                storageService: _storageService,
              ),
            ),
          );
          
          if (result is Event) {
            await _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Event added: ${result.eventType}'),
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
            Icons.event_note,
            size: 80,
            color: Colors.amber.shade700,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Events Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Track important events like vaccinations, treatments, and breeding.',
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
                  builder: (context) => AddEventScreen(
                    storageService: _storageService,
                  ),
                ),
              );
              
              if (result is Event) {
                await _loadData();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Event'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventsList() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final cattle = _cattleMap[event.cattleId];
          final eventDate = dateFormat.format(event.eventDate);
          
          return Dismissible(
            key: Key(event.id),
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
                  title: const Text('Delete Event'),
                  content: const Text(
                    'Are you sure you want to delete this event?',
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
              _deleteEvent(event.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event deleted'),
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
                  backgroundColor: _getEventColor(event.eventType),
                  child: Icon(
                    _getEventIcon(event.eventType),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  event.eventType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: $eventDate'),
                    Text('Cattle: ${cattle?.tagNumber ?? 'Unknown'} - ${cattle?.breed ?? ''}'),
                    if (event.notes != null && event.notes!.isNotEmpty)
                      Text(
                        'Notes: ${event.notes}',
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