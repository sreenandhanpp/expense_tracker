import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';

class ApiService {
  /// Base API URL. For Android Emulator: 10.0.2.2:3000/api
  /// For Linux Desktop / iOS Simulator / Web: localhost:3000/api
  static String baseUrl = 'https://expense-tracker-dceb.onrender.com/api';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// GET /api/expenses with optional filters (search, category, payment, date)
  Future<List<Expense>> getExpenses({
    String? search,
    String? category,
    String? payment,
    String? date,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (payment != null && payment.isNotEmpty) queryParams['payment'] = payment;
    if (date != null && date.isNotEmpty) queryParams['date'] = date;

    final uri = Uri.parse('$baseUrl/expenses').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        final list = body['data'] as List? ?? [];
        return list.map((item) => Expense.fromJson(item as Map<String, dynamic>)).toList();
      }
    }
    throw Exception(_getErrorMessage(response, 'Failed to load expenses'));
  }

  /// GET /api/expenses/:id
  Future<Expense> getExpense(String id) async {
    final uri = Uri.parse('$baseUrl/expenses/$id');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return Expense.fromJson(body['data'] as Map<String, dynamic>);
      }
    }
    throw Exception(_getErrorMessage(response, 'Expense not found'));
  }

  /// POST /api/expenses
  Future<Expense> createExpense(Expense expense) async {
    final uri = Uri.parse('$baseUrl/expenses');
    final response = await http.post(
      uri,
      headers: _headers,
      body: json.encode(expense.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return Expense.fromJson(body['data'] as Map<String, dynamic>);
      }
    }
    throw Exception(_getErrorMessage(response, 'Failed to create expense'));
  }

  /// PUT /api/expenses/:id
  Future<Expense> updateExpense(String id, Expense expense) async {
    final uri = Uri.parse('$baseUrl/expenses/$id');
    final response = await http.put(
      uri,
      headers: _headers,
      body: json.encode(expense.toJson()),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return Expense.fromJson(body['data'] as Map<String, dynamic>);
      }
    }
    throw Exception(_getErrorMessage(response, 'Failed to update expense'));
  }

  /// DELETE /api/expenses/:id
  Future<void> deleteExpense(String id) async {
    final uri = Uri.parse('$baseUrl/expenses/$id');
    final response = await http.delete(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(response, 'Failed to delete expense'));
    }
  }

  /// GET /api/categories
  Future<List<String>> getCategories() async {
    final uri = Uri.parse('$baseUrl/categories');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return (body['data'] as List? ?? []).map((e) => e.toString()).toList();
      }
    }
    throw Exception(_getErrorMessage(response, 'Failed to load categories'));
  }

  /// GET /api/payment-methods
  Future<List<String>> getPaymentMethods() async {
    final uri = Uri.parse('$baseUrl/payment-methods');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return (body['data'] as List? ?? []).map((e) => e.toString()).toList();
      }
    }
    throw Exception(_getErrorMessage(response, 'Failed to load payment methods'));
  }

  /// GET /api/summary
  Future<Summary> getSummary() async {
    final uri = Uri.parse('$baseUrl/summary');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return Summary.fromJson(body['data'] as Map<String, dynamic>);
      }
    }
    throw Exception(_getErrorMessage(response, 'Failed to load summary'));
  }

  /// GET /api/summary/trends
  Future<SpendingTrend> getSpendingTrends() async {
    final uri = Uri.parse('$baseUrl/summary/trends');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return SpendingTrend.fromJson(body['data'] as Map<String, dynamic>);
      }
    }
    throw Exception(_getErrorMessage(response, 'Failed to load spending trends'));
  }

  /// GET /api/suggestions?query=...
  Future<List<ExpenseSuggestion>> getSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse('$baseUrl/suggestions').replace(queryParameters: {'query': query.trim()});
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        final list = body['data'] as List? ?? [];
        return list.map((item) => ExpenseSuggestion.fromJson(item as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  String _getErrorMessage(http.Response response, String defaultMsg) {
    try {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return body['message'] as String? ?? defaultMsg;
    } catch (_) {
      return defaultMsg;
    }
  }
}
