import 'cattle.dart';
import 'milk_record.dart';
import 'event.dart';

class Report {
  final String id;
  final String title;
  final DateTime generatedDate;
  final String reportType; // 'Cattle', 'Milk', 'Events'
  final ReportData data;

  Report({
    required this.id,
    required this.title,
    required this.generatedDate,
    required this.reportType,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'generatedDate': generatedDate.toIso8601String(),
      'reportType': reportType,
      'data': data.toJson(),
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    ReportData reportData;
    
    switch (json['reportType']) {
      case 'Cattle':
        reportData = CattleReportData.fromJson(json['data']);
        break;
      case 'Milk':
        reportData = MilkReportData.fromJson(json['data']);
        break;
      case 'Events':
        reportData = EventsReportData.fromJson(json['data']);
        break;
      default:
        throw Exception('Unknown report type: ${json['reportType']}');
    }
    
    return Report(
      id: json['id'],
      title: json['title'],
      generatedDate: DateTime.parse(json['generatedDate']),
      reportType: json['reportType'],
      data: reportData,
    );
  }
}

abstract class ReportData {
  Map<String, dynamic> toJson();
}

class CattleReportData implements ReportData {
  final int totalCattle;
  final Map<String, int> breedDistribution;
  final Map<String, int> genderDistribution;
  final List<Cattle> cattleList;

  CattleReportData({
    required this.totalCattle,
    required this.breedDistribution,
    required this.genderDistribution,
    required this.cattleList,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'totalCattle': totalCattle,
      'breedDistribution': breedDistribution,
      'genderDistribution': genderDistribution,
      'cattleList': cattleList.map((cattle) => cattle.toJson()).toList(),
    };
  }

  factory CattleReportData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> cattleJsonList = json['cattleList'];
    final cattleList = cattleJsonList
        .map((cattleJson) => Cattle.fromJson(cattleJson))
        .toList();

    return CattleReportData(
      totalCattle: json['totalCattle'],
      breedDistribution: Map<String, int>.from(json['breedDistribution']),
      genderDistribution: Map<String, int>.from(json['genderDistribution']),
      cattleList: cattleList,
    );
  }
}

class MilkReportData implements ReportData {
  final double totalMilkProduction;
  final Map<String, double> dailyProduction;
  final Map<String, double> cowWiseProduction;
  final List<MilkRecord> milkRecordList;

  MilkReportData({
    required this.totalMilkProduction,
    required this.dailyProduction,
    required this.cowWiseProduction,
    required this.milkRecordList,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'totalMilkProduction': totalMilkProduction,
      'dailyProduction': dailyProduction,
      'cowWiseProduction': cowWiseProduction,
      'milkRecordList': milkRecordList.map((record) => record.toJson()).toList(),
    };
  }

  factory MilkReportData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> recordJsonList = json['milkRecordList'];
    final recordList = recordJsonList
        .map((recordJson) => MilkRecord.fromJson(recordJson))
        .toList();

    return MilkReportData(
      totalMilkProduction: json['totalMilkProduction'],
      dailyProduction: Map<String, double>.from(json['dailyProduction']),
      cowWiseProduction: Map<String, double>.from(json['cowWiseProduction']),
      milkRecordList: recordList,
    );
  }
}

class EventsReportData implements ReportData {
  final int totalEvents;
  final Map<String, int> eventTypeDistribution;
  final Map<String, int> cattleEventDistribution;
  final List<Event> eventList;

  EventsReportData({
    required this.totalEvents,
    required this.eventTypeDistribution,
    required this.cattleEventDistribution,
    required this.eventList,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'totalEvents': totalEvents,
      'eventTypeDistribution': eventTypeDistribution,
      'cattleEventDistribution': cattleEventDistribution,
      'eventList': eventList.map((event) => event.toJson()).toList(),
    };
  }

  factory EventsReportData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> eventJsonList = json['eventList'];
    final eventList = eventJsonList
        .map((eventJson) => Event.fromJson(eventJson))
        .toList();

    return EventsReportData(
      totalEvents: json['totalEvents'],
      eventTypeDistribution: Map<String, int>.from(json['eventTypeDistribution']),
      cattleEventDistribution: Map<String, int>.from(json['cattleEventDistribution']),
      eventList: eventList,
    );
  }
} 