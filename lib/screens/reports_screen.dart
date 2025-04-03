import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';
import '../services/storage_service.dart';
import 'generate_report_screen.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  final StorageService? providedStorageService;
  
  const ReportsScreen({super.key, this.providedStorageService});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final StorageService _storageService;
  List<Report> _reports = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _storageService = widget.providedStorageService ?? StorageService();
    _loadReports();
  }
  
  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reports = await _storageService.getReports();
      
      // Sort reports by date (newest first)
      reports.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));
      
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error if needed
    }
  }
  
  Future<void> _deleteReport(String id) async {
    await _storageService.deleteReport(id);
    await _loadReports();
  }
  
  // Get icon based on report type
  IconData _getReportIcon(String reportType) {
    switch (reportType) {
      case 'Cattle':
        return Icons.pets;
      case 'Milk':
        return Icons.water_drop;
      case 'Events':
        return Icons.event_note;
      default:
        return Icons.description;
    }
  }
  
  // Get color based on report type
  Color _getReportColor(String reportType) {
    switch (reportType) {
      case 'Cattle':
        return Colors.green;
      case 'Milk':
        return Colors.blue;
      case 'Events':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Available report types
    final reportTypes = [
      {'title': 'Cattle Report', 'icon': Icons.pets, 'type': 'Cattle'},
      {'title': 'Milk Production Report', 'icon': Icons.water_drop, 'type': 'Milk'},
      {'title': 'Events Report', 'icon': Icons.event_note, 'type': 'Events'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Farm Reports',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'View and generate reports about your farm',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Report types section
                  const Text(
                    'Generate New Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: reportTypes.length,
                      itemBuilder: (context, index) {
                        final type = reportTypes[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: InkWell(
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => GenerateReportScreen(
                                    storageService: _storageService,
                                  ),
                                ),
                              );
                              
                              if (result is Report) {
                                await _loadReports();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Report generated: ${result.title}'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              width: 140,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    type['icon'] as IconData,
                                    size: 32,
                                    color: _getReportColor(type['type'] as String),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    type['title'] as String,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Saved reports section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Saved Reports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_reports.isNotEmpty)
                        TextButton.icon(
                          onPressed: _loadReports,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Refresh'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Expanded(
                    child: _reports.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.description,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No reports yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Generate your first report',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _reports.length,
                            itemBuilder: (context, index) {
                              final report = _reports[index];
                              final dateFormat = DateFormat('MMM dd, yyyy');
                              final formattedDate = dateFormat.format(report.generatedDate);
                              
                              return Dismissible(
                                key: Key(report.id),
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
                                      title: const Text('Delete Report'),
                                      content: Text(
                                        'Are you sure you want to delete "${report.title}"?',
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
                                  _deleteReport(report.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Report deleted: ${report.title}'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getReportColor(report.reportType),
                                      child: Icon(
                                        _getReportIcon(report.reportType),
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      report.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('Generated on $formattedDate'),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (ctx) => ReportDetailScreen(
                                            report: report,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
} 