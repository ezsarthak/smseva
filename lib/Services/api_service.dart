  import 'dart:convert';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:http/http.dart' as http;

import '../Model/Issues.dart';
import '../Model/Worker.dart';
import '../Model/assignments.dart';

  class ApiService {
    static const String baseUrl = 'https://suvidha-backend-gdf7.onrender.com';

    // ---------------- Issues ----------------
    static Future<List<Issue>> getIssues({String? category, int? limit}) async {
      String url = '$baseUrl/issues';
      List<String> queryParams = [];

      if (category != null && category.isNotEmpty) {
        queryParams.add('category=${Uri.encodeComponent(category)}');
      }
      if (limit != null) {
        queryParams.add('limit=$limit');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          return jsonData.map((json) => Issue.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load issues: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error fetching issues: $e');
      }
    }

    static Future<List<String>> getCategories() async {
      try {
        final response = await http.get(Uri.parse('$baseUrl/issues/categories'));
        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          return jsonData.cast<String>();
        } else {
          throw Exception('Failed to load categories: ${response.statusCode}');
        }
      } catch (e) {
        // fallback categories
        return [
          'Sanitation & Waste',
          'Water & Drainage',
          'Electricity & Streetlights',
          'Roads & Transport',
          'Public Health & Safety',
          'Environment & Parks',
          'Building & Infrastructure',
          'Taxes & Documentation',
          'Emergency Services',
          'Animal Care & Control',
          'Other',
        ];
      }
    }

    static Future<bool> updateIssueStatus(
        String ticketId,
        String newStatus,
        ) async {
      try {
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (newStatus == "completed") {
          final response = await http.post(
            Uri.parse('$baseUrl/issues/$ticketId/complete'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'completion_type': 'admin',
              'email': currentUser?.email ?? "admin@g.com",
            }),
          );
          return response.statusCode == 200;
        } else {
          final response = await http.put(
            Uri.parse('$baseUrl/issues/$ticketId/status'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'status': newStatus,
              'email': currentUser?.email ?? "admin@g.com",
            }),
          );
          return response.statusCode == 200;
        }
      } catch (e) {
        print('Error updating issue status: $e');
        return false;
      }
    }

    static Future<int> getIssueCount({String? category}) async {
      String url = '$baseUrl/issues/count';
      if (category != null && category.isNotEmpty) {
        url += '?category=${Uri.encodeComponent(category)}';
      }

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['count'] ?? 0;
        } else {
          throw Exception('Failed to load issue count: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error fetching issue count: $e');
      }
    }

    // ---------------- Worker Authentication ----------------
    static Future<bool> workerLogin(String email, String password) async {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/workers/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email, 'password': password}),
        );

        return response.statusCode == 200;
      } catch (e) {
        throw Exception('Login error: $e');
      }
    }

    static Future<bool> registerWorker(Map<String, dynamic> workerData) async {
      try {
        // ✅ ADD THESE PRINT STATEMENTS TO SEE EXACTLY WHAT IS BEING SENT
        print("ApiService: Preparing to send worker data: $workerData");
        final jsonBody = json.encode(workerData);
        print("ApiService: Sending encoded JSON body: $jsonBody");

        final response = await http.post(
          Uri.parse('$baseUrl/workers/register'),
          headers: {
            // This header tells the server you're sending JSON
            'Content-Type': 'application/json; charset=UTF-8',
          },
          // The body must be a JSON String, not a Map
          body: jsonBody,
        );

        print("ApiService: Received response with status code: ${response.statusCode}");
        print("ApiService: Response body: ${response.body}");

        // Your original backend API for worker registration does not return 201
        // It returns 200 OK on success. Let's check for that.
        if (response.statusCode == 200) {
          return true;
        } else {
          // If it fails, throw an exception with the server's error message
          final errorData = json.decode(response.body);
          throw Exception(errorData['detail'] ?? 'Failed to register.');
        }
      } catch (e) {
        print("ApiService: An error occurred in registerWorker: $e");
        // Re-throw the exception so the UI can catch it and display a message
        rethrow;
      }
    }

    // ---------------- Worker Management ----------------
    static Future<List<Worker>> getWorkers() async {
      try {
        final response = await http.get(Uri.parse('$baseUrl/workers'));

        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          return jsonData.map((json) => Worker.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load workers: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error fetching workers: $e');
      }
    }

    static Future<List<Worker>> getWorkersByDepartment(
        String departmentId,
        ) async {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/workers/department/$departmentId'),
        );

        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          return jsonData.map((json) => Worker.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load workers: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error fetching workers: $e');
      }
    }

    // ---------------- Department Management ----------------
    static Future<List<Department>> getDepartments() async {
      try {
        final response = await http.get(Uri.parse('$baseUrl/departments'));

        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          return jsonData.map((json) => Department.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load departments: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error fetching departments: $e');
      }
    }

    // ---------------- Assignment Management ----------------
    static Future<List<Assignment>> getAssignments() async {
      try {
        final response = await http.get(Uri.parse('$baseUrl/assignments'));

        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          return jsonData.map((json) => Assignment.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load assignments: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error fetching assignments: $e');
      }
    }


    static Future<bool> reassignWorker({
      required String assignmentId,
      required String newWorkerEmail,
    }) async {
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/assignments/$assignmentId/reassign'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'new_assigned_to': newWorkerEmail}),
        );

        return response.statusCode == 200;
      } catch (e) {
        throw Exception('Error reassigning worker: $e');
      }
    }

    static Future<bool> updateAssignmentStatus({
      required String ticketId,
      required String status,
      String notes = '',
    }) async {
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/assignments/$ticketId/status'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'status': status, 'notes': notes}),
        );

        return response.statusCode == 200;
      } catch (e) {
        throw Exception('Error updating assignment status: $e');
      }
    }

    // ---------------- Worker Dashboard ----------------
    static Future<List<Assignment>> getWorkerAssignments(
        String workerEmail,
        ) async {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/assignments/worker/$workerEmail'),
        );

        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body);
          return jsonData.map((json) => Assignment.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load assignments: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error fetching worker assignments: $e');
      }
    }

    static Future<Worker?> getWorkerProfile(String email) async {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/workers/profile/$email'),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          return Worker.fromJson(jsonData);
        }
        return null;
      } catch (e) {
        throw Exception('Error fetching worker profile: $e');
      }
    }
    // In ApiService.dart

    // In your lib/services/api_service.dart file

    static Future<bool> assignWorker({
      required String ticketId,
      required String workerEmail,
      String notes = '',
    }) async {
      try {
        // This is the data map that needs to be sent
        const String adminEmail = "admin@example.com";

        final assignmentData = {
          'ticket_id': ticketId,
          'assigned_to': workerEmail,
          'notes': notes,
          'assigned_by': adminEmail,
        };

        // These print statements will show in your debug console
        print("ApiService: Preparing to send assignment data: $assignmentData");
        final jsonBody = json.encode(assignmentData);
        print("ApiService: Sending encoded JSON body: $jsonBody");

        final response = await http.post(
          Uri.parse('$baseUrl/assignments'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonBody,
        );

        print("ApiService: Received assignment response code: ${response.statusCode}");
        print("ApiService: Response body: ${response.body}");

        // The /assignments endpoint you have returns a 200 OK on success
        if (response.statusCode == 200) {
          return true;
        } else {
          // Throw the server's error message so the UI can see it
          final errorData = json.decode(response.body);
          throw Exception(errorData['detail'] ?? 'Failed to assign worker.');
        }
      } catch (e) {
        print("ApiService: Error assigning worker: $e");
        // Re-throw the exception so the UI's catch block can handle it
        rethrow;
      }
    }
    static Future<bool> updateAssignmentStatusWorker({
      required String ticketId,
      required String status,
    }) async {
      try {
        final uri = Uri.parse('$baseUrl/assignments/$ticketId/status?status=$status');

        // ✅ THE FIX IS HERE: You must use http.put, not http.get
        final response = await http.put(uri);

        print("ApiService: Update status response code: ${response.statusCode}");
        print("ApiService: Response body: ${response.body}");

        return response.statusCode == 200;
      } catch (e) {
        print("ApiService: Error updating assignment status: $e");
        rethrow;
      }
    }
  }
