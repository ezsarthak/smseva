import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/Issues.dart';
import 'package:http/http.dart' as http;

class AnalyticsDataState {
  final bool isLoading;
  final String errorMessage;
  final List<Issue> issues;

  AnalyticsDataState({
    required this.isLoading,
    required this.errorMessage,
    required this.issues,
  });
}

class AnalyticsDataManager {
  final dataNotifier = ValueNotifier<AnalyticsDataState>(
    AnalyticsDataState(isLoading: true, errorMessage: '', issues: []),
  );

  List<Issue> get issues => dataNotifier.value.issues;

  Future<void> fetchIssues() async {
    dataNotifier.value = AnalyticsDataState(isLoading: true, errorMessage: '', issues: []);
    try {
      final response = await http.get(
        Uri.parse('https://suvidha-backend-gdf7.onrender.com/issues'),
        headers: {'Content-Type': 'application/json'},
      );
      // Replace with actual HTTP GET call
      final List<dynamic> jsonData = json.decode(response.body);
      final issues = jsonData.map((e) => Issue.fromJson(e)).toList();
      dataNotifier.value = AnalyticsDataState(isLoading: false, errorMessage: '', issues: issues);
    } catch (e) {
      dataNotifier.value = AnalyticsDataState(isLoading: false, errorMessage: e.toString(), issues: []);
    }
  }

  DateTime? parseDate(String date) {
    try {
      return DateFormat("HH:mm dd-MM-yyyy").parse(date);
    } catch (_) {
      return DateTime.tryParse(date);
    }
  }
}
