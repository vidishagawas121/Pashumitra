import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/cattle.dart';
import '../models/milk_record.dart';
import '../models/event.dart';
import '../models/feed_cost.dart';
import '../models/report.dart';

class StorageService {
  static const String _cattleKey = 'cattle_data';
  static const String _milkRecordKey = 'milk_record_data';
  static const String _eventKey = 'event_data';
  static const String _feedCostKey = 'feed_cost_data';
  static const String _reportKey = 'report_data';

  // Save list of cattle to SharedPreferences
  Future<void> saveCattleList(List<Cattle> cattleList) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = cattleList.map((cattle) => 
      jsonEncode(cattle.toJson())
    ).toList();
    
    await prefs.setStringList(_cattleKey, jsonList);
  }

  // Retrieve list of cattle from SharedPreferences
  Future<List<Cattle>> getCattleList() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_cattleKey);
    
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }
    
    return jsonList.map((jsonString) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return Cattle.fromJson(json);
    }).toList();
  }

  // Add a new cattle to the existing list
  Future<void> addCattle(Cattle cattle) async {
    final cattleList = await getCattleList();
    cattleList.add(cattle);
    await saveCattleList(cattleList);
  }

  // Delete a cattle by ID
  Future<void> deleteCattle(String id) async {
    final cattleList = await getCattleList();
    cattleList.removeWhere((cattle) => cattle.id == id);
    await saveCattleList(cattleList);
  }

  // Update an existing cattle
  Future<void> updateCattle(Cattle updatedCattle) async {
    final cattleList = await getCattleList();
    final index = cattleList.indexWhere((cattle) => cattle.id == updatedCattle.id);
    
    if (index != -1) {
      cattleList[index] = updatedCattle;
      await saveCattleList(cattleList);
    }
  }

  // Save list of milk records to SharedPreferences
  Future<void> saveMilkRecords(List<MilkRecord> milkRecords) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = milkRecords.map((record) => 
      jsonEncode(record.toJson())
    ).toList();
    
    await prefs.setStringList(_milkRecordKey, jsonList);
  }

  // Retrieve list of milk records from SharedPreferences
  Future<List<MilkRecord>> getMilkRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_milkRecordKey);
    
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }
    
    return jsonList.map((jsonString) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return MilkRecord.fromJson(json);
    }).toList();
  }

  // Add a new milk record
  Future<void> addMilkRecord(MilkRecord milkRecord) async {
    final milkRecords = await getMilkRecords();
    milkRecords.add(milkRecord);
    await saveMilkRecords(milkRecords);
  }

  // Delete a milk record by ID
  Future<void> deleteMilkRecord(String id) async {
    final milkRecords = await getMilkRecords();
    milkRecords.removeWhere((record) => record.id == id);
    await saveMilkRecords(milkRecords);
  }

  // Save list of events to SharedPreferences
  Future<void> saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = events.map((event) => 
      jsonEncode(event.toJson())
    ).toList();
    
    await prefs.setStringList(_eventKey, jsonList);
  }

  // Retrieve list of events from SharedPreferences
  Future<List<Event>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_eventKey);
    
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }
    
    return jsonList.map((jsonString) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return Event.fromJson(json);
    }).toList();
  }

  // Add a new event
  Future<void> addEvent(Event event) async {
    final events = await getEvents();
    events.add(event);
    await saveEvents(events);
  }

  // Delete an event by ID
  Future<void> deleteEvent(String id) async {
    final events = await getEvents();
    events.removeWhere((event) => event.id == id);
    await saveEvents(events);
  }

  // Get events for a specific cattle
  Future<List<Event>> getEventsForCattle(String cattleId) async {
    final allEvents = await getEvents();
    return allEvents.where((event) => event.cattleId == cattleId).toList();
  }

  // Save list of feed costs to SharedPreferences
  Future<void> saveFeedCosts(List<FeedCost> feedCosts) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = feedCosts.map((cost) => 
      jsonEncode(cost.toJson())
    ).toList();
    
    await prefs.setStringList(_feedCostKey, jsonList);
  }

  // Retrieve list of feed costs from SharedPreferences
  Future<List<FeedCost>> getFeedCosts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_feedCostKey);
    
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }
    
    return jsonList.map((jsonString) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return FeedCost.fromJson(json);
    }).toList();
  }

  // Add a new feed cost
  Future<void> addFeedCost(FeedCost feedCost) async {
    final feedCosts = await getFeedCosts();
    feedCosts.add(feedCost);
    await saveFeedCosts(feedCosts);
  }

  // Delete a feed cost by ID
  Future<void> deleteFeedCost(String id) async {
    final feedCosts = await getFeedCosts();
    feedCosts.removeWhere((cost) => cost.id == id);
    await saveFeedCosts(feedCosts);
  }

  // Calculate total feed cost for a specific time period
  Future<double> calculateTotalFeedCost(DateTime startDate, DateTime endDate) async {
    final feedCosts = await getFeedCosts();
    
    // Filter feed costs within date range
    final filteredCosts = feedCosts.where((cost) {
      return cost.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
             cost.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
    
    // Sum up total costs
    double totalCost = 0;
    for (var cost in filteredCosts) {
      totalCost += cost.totalCost;
    }
    
    return totalCost;
  }

  // Get feed costs grouped by feed type
  Future<Map<String, double>> getFeedCostsByType(DateTime startDate, DateTime endDate) async {
    final feedCosts = await getFeedCosts();
    
    // Filter feed costs within date range
    final filteredCosts = feedCosts.where((cost) {
      return cost.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
             cost.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
    
    // Group by feed type
    final Map<String, double> costsByType = {};
    for (var cost in filteredCosts) {
      if (costsByType.containsKey(cost.feedType)) {
        costsByType[cost.feedType] = costsByType[cost.feedType]! + cost.totalCost;
      } else {
        costsByType[cost.feedType] = cost.totalCost;
      }
    }
    
    return costsByType;
  }

  // Save list of reports to SharedPreferences
  Future<void> saveReports(List<Report> reports) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = reports.map((report) => 
      jsonEncode(report.toJson())
    ).toList();
    
    await prefs.setStringList(_reportKey, jsonList);
  }

  // Retrieve list of reports from SharedPreferences
  Future<List<Report>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_reportKey);
    
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }
    
    return jsonList.map((jsonString) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return Report.fromJson(json);
    }).toList();
  }

  // Delete a report by ID
  Future<void> deleteReport(String id) async {
    final reports = await getReports();
    reports.removeWhere((report) => report.id == id);
    await saveReports(reports);
  }

  // Generate a cattle report
  Future<Report> generateCattleReport() async {
    final cattle = await getCattleList();
    
    // Calculate breed distribution
    final Map<String, int> breedDistribution = {};
    for (var cow in cattle) {
      if (breedDistribution.containsKey(cow.breed)) {
        breedDistribution[cow.breed] = breedDistribution[cow.breed]! + 1;
      } else {
        breedDistribution[cow.breed] = 1;
      }
    }
    
    // Calculate gender distribution
    final Map<String, int> genderDistribution = {};
    for (var cow in cattle) {
      if (genderDistribution.containsKey(cow.gender)) {
        genderDistribution[cow.gender] = genderDistribution[cow.gender]! + 1;
      } else {
        genderDistribution[cow.gender] = 1;
      }
    }
    
    // Create report data
    final reportData = CattleReportData(
      totalCattle: cattle.length,
      breedDistribution: breedDistribution,
      genderDistribution: genderDistribution,
      cattleList: cattle,
    );
    
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final report = Report(
      id: const Uuid().v4(),
      title: 'Cattle Inventory Report - $dateStr',
      generatedDate: DateTime.now(),
      reportType: 'Cattle',
      data: reportData,
    );
    
    // Save report
    final reports = await getReports();
    reports.add(report);
    await saveReports(reports);
    
    return report;
  }

  // Generate a milk production report
  Future<Report> generateMilkReport(DateTime startDate, DateTime endDate) async {
    final records = await getMilkRecords();
    final cattle = await getCattleList();
    
    // Filter records within date range
    final filteredRecords = records.where((record) {
      return record.milkingDate.isAfter(startDate) && 
             record.milkingDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
    
    // Calculate total milk production
    double totalMilk = 0;
    for (var record in filteredRecords) {
      totalMilk += record.totalMilk;
    }
    
    // Calculate daily production
    final Map<String, double> dailyProduction = {};
    for (var record in filteredRecords) {
      final dateStr = DateFormat('yyyy-MM-dd').format(record.milkingDate);
      if (dailyProduction.containsKey(dateStr)) {
        dailyProduction[dateStr] = dailyProduction[dateStr]! + record.totalMilk;
      } else {
        dailyProduction[dateStr] = record.totalMilk;
      }
    }
    
    // Calculate cow-wise production
    final Map<String, double> cowWiseProduction = {};
    for (var record in filteredRecords) {
      if (record.milkType == 'Individual Cow' && record.cattleId != null) {
        final cow = cattle.firstWhere(
          (cow) => cow.id == record.cattleId,
          orElse: () => Cattle(
            id: 'unknown',
            tagNumber: 'Unknown',
            breed: 'Unknown',
            dateOfBirth: DateTime.now(),
            gender: 'Unknown',
            weight: 0,
          ),
        );
        
        final cowKey = '${cow.tagNumber} - ${cow.breed}';
        if (cowWiseProduction.containsKey(cowKey)) {
          cowWiseProduction[cowKey] = cowWiseProduction[cowKey]! + record.totalMilk;
        } else {
          cowWiseProduction[cowKey] = record.totalMilk;
        }
      }
    }
    
    // Create report data
    final reportData = MilkReportData(
      totalMilkProduction: totalMilk,
      dailyProduction: dailyProduction,
      cowWiseProduction: cowWiseProduction,
      milkRecordList: filteredRecords,
    );
    
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
    final report = Report(
      id: const Uuid().v4(),
      title: 'Milk Production Report ($startDateStr to $endDateStr)',
      generatedDate: DateTime.now(),
      reportType: 'Milk',
      data: reportData,
    );
    
    // Save report
    final reports = await getReports();
    reports.add(report);
    await saveReports(reports);
    
    return report;
  }

  // Generate an events report
  Future<Report> generateEventsReport(DateTime startDate, DateTime endDate) async {
    final events = await getEvents();
    final cattle = await getCattleList();
    
    // Filter events within date range
    final filteredEvents = events.where((event) {
      return event.eventDate.isAfter(startDate) && 
             event.eventDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
    
    // Calculate event type distribution
    final Map<String, int> eventTypeDistribution = {};
    for (var event in filteredEvents) {
      if (eventTypeDistribution.containsKey(event.eventType)) {
        eventTypeDistribution[event.eventType] = eventTypeDistribution[event.eventType]! + 1;
      } else {
        eventTypeDistribution[event.eventType] = 1;
      }
    }
    
    // Calculate cattle event distribution
    final Map<String, int> cattleEventDistribution = {};
    for (var event in filteredEvents) {
      final cow = cattle.firstWhere(
        (cow) => cow.id == event.cattleId,
        orElse: () => Cattle(
          id: 'unknown',
          tagNumber: 'Unknown',
          breed: 'Unknown',
          dateOfBirth: DateTime.now(),
          gender: 'Unknown',
          weight: 0,
        ),
      );
      
      final cowKey = '${cow.tagNumber} - ${cow.breed}';
      if (cattleEventDistribution.containsKey(cowKey)) {
        cattleEventDistribution[cowKey] = cattleEventDistribution[cowKey]! + 1;
      } else {
        cattleEventDistribution[cowKey] = 1;
      }
    }
    
    // Create report data
    final reportData = EventsReportData(
      totalEvents: filteredEvents.length,
      eventTypeDistribution: eventTypeDistribution,
      cattleEventDistribution: cattleEventDistribution,
      eventList: filteredEvents,
    );
    
    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
    final report = Report(
      id: const Uuid().v4(),
      title: 'Events Report ($startDateStr to $endDateStr)',
      generatedDate: DateTime.now(),
      reportType: 'Events',
      data: reportData,
    );
    
    // Save report
    final reports = await getReports();
    reports.add(report);
    await saveReports(reports);
    
    return report;
  }
} 