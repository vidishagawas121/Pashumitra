import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';
import '../models/cattle.dart';
import '../models/milk_record.dart';
import '../models/event.dart';

class ReportDetailScreen extends StatelessWidget {
  final Report report;

  const ReportDetailScreen({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportHeader(context),
            const SizedBox(height: 24),
            
            // Display different content based on report type
            if (report.reportType == 'Cattle')
              _buildCattleReport(context)
            else if (report.reportType == 'Milk')
              _buildMilkReport(context)
            else if (report.reportType == 'Events')
              _buildEventsReport(context)
            else
              const Text('Unknown report type'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getReportIcon(),
                  color: _getReportColor(),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${report.reportType} Report',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Generated on: ${dateFormat.format(report.generatedDate)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getReportIcon() {
    switch (report.reportType) {
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

  Color _getReportColor() {
    switch (report.reportType) {
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

  Widget _buildCattleReport(BuildContext context) {
    final cattleData = report.data as CattleReportData;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCard(
          title: 'Cattle Summary',
          items: [
            {'Total Cattle': '${cattleData.totalCattle}'},
          ],
        ),
        const SizedBox(height: 16),
        
        _buildDistributionSection(
          title: 'Breed Distribution',
          distribution: cattleData.breedDistribution,
        ),
        const SizedBox(height: 16),
        
        _buildDistributionSection(
          title: 'Gender Distribution',
          distribution: cattleData.genderDistribution,
        ),
        const SizedBox(height: 16),
        
        _buildCattleList(cattleData.cattleList),
      ],
    );
  }

  Widget _buildMilkReport(BuildContext context) {
    final milkData = report.data as MilkReportData;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCard(
          title: 'Milk Production Summary',
          items: [
            {'Total Production': '${milkData.totalMilkProduction.toStringAsFixed(2)} liters'},
            {'Records Analyzed': '${milkData.milkRecordList.length}'},
          ],
        ),
        const SizedBox(height: 16),
        
        _buildMapSection(
          title: 'Daily Production',
          data: milkData.dailyProduction,
          valueLabel: 'liters',
        ),
        const SizedBox(height: 16),
        
        if (milkData.cowWiseProduction.isNotEmpty) ...[
          _buildMapSection(
            title: 'Cow-wise Production',
            data: milkData.cowWiseProduction,
            valueLabel: 'liters',
          ),
          const SizedBox(height: 16),
        ],
        
        _buildMilkRecordsList(milkData.milkRecordList),
      ],
    );
  }

  Widget _buildEventsReport(BuildContext context) {
    final eventsData = report.data as EventsReportData;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCard(
          title: 'Events Summary',
          items: [
            {'Total Events': '${eventsData.totalEvents}'},
          ],
        ),
        const SizedBox(height: 16),
        
        _buildDistributionSection(
          title: 'Event Type Distribution',
          distribution: eventsData.eventTypeDistribution,
        ),
        const SizedBox(height: 16),
        
        if (eventsData.cattleEventDistribution.isNotEmpty) ...[
          _buildDistributionSection(
            title: 'Cattle Event Distribution',
            distribution: eventsData.cattleEventDistribution,
          ),
          const SizedBox(height: 16),
        ],
        
        _buildEventsList(eventsData.eventList),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            ...items.map((item) {
              final entry = item.entries.first;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(
                      entry.value,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionSection({
    required String title,
    required Map<String, int> distribution,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            ...distribution.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection<T>({
    required String title,
    required Map<String, T> data,
    String valueLabel = '',
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            ...data.entries.map((entry) {
              String valueText;
              if (T == double) {
                valueText = '${(entry.value as double).toStringAsFixed(2)} $valueLabel';
              } else {
                valueText = '$entry.value $valueLabel';
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      valueText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCattleList(List<Cattle> cattleList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cattle List',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...cattleList.map((cattle) => _buildCattleListItem(cattle)),
      ],
    );
  }

  Widget _buildCattleListItem(Cattle cattle) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('${cattle.tagNumber} - ${cattle.breed}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gender: ${cattle.gender}'),
            Text('DOB: ${dateFormat.format(cattle.dateOfBirth)}'),
            Text('Weight: ${cattle.weight} kg'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildMilkRecordsList(List<MilkRecord> records) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Milk Records',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...records.map((record) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text('${record.totalMilk.toStringAsFixed(1)} liters'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${dateFormat.format(record.milkingDate)}'),
                  Text('Type: ${record.milkType}'),
                  if (record.notes != null && record.notes!.isNotEmpty)
                    Text('Notes: ${record.notes}'),
                ],
              ),
              isThreeLine: true,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEventsList(List<Event> events) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Events List',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...events.map((event) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(event.eventType),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${dateFormat.format(event.eventDate)}'),
                  if (event.notes != null && event.notes!.isNotEmpty)
                    Text('Notes: ${event.notes}'),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
} 