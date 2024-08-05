import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GetTask extends StatefulWidget {
  @override
  _GetTaskState createState() => _GetTaskState();
}

class _GetTaskState extends State<GetTask> with SingleTickerProviderStateMixin {
  List<dynamic> assignedParties = [];
  List<dynamic> weeklyLoans = [];
  List<dynamic> monthlyLoans = [];
  List<dynamic> vehicleLoans = [];
  AnimationController? _controller;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeIn,
    ));
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset(0, 0)).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeIn,
    ));
    _controller!.forward();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String apiUrl = "https://finance2024.ingenious-technologies.com/financeapp/public/api/executive/config";

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        assignedParties = data['data']['assigned_parties'] ?? [];
        weeklyLoans = data['data']['weekly_loans'] ?? [];
        monthlyLoans = data['data']['monthly_loans'] ?? [];
        vehicleLoans = data['data']['vehicle_loans'] ?? [];
      });
    } else {
      print("Failed to load tasks: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tasks. Please try again.')),
      );
    }
  }

  void _showLoanDetails(Map<String, dynamic> loan) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Loan Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _loanDetailRow('Loan ID', loan['loan_id'].toString()),
                _loanDetailRow('Loan Amount', loan['loan_amount'].toString()),
                _loanDetailRow('Loan Date', loan['loan_date'].toString()),
                _loanDetailRow('Rate of Interest', loan['interest_rate'].toString()),
                _loanDetailRow('No of Dues', loan['total_dues'].toString()),
                _loanDetailRow('Total Amount', loan['total_amt'].toString()),
                _loanDetailRow('Paid Dues', loan['paid_dues']?.toString() ?? 'N/A'),
                _loanDetailRow('Paid Amount', loan['paid_amount']?.toString() ?? 'N/A'),
                _loanDetailRow('Unpaid Dues', loan['unpaid_dues']?.toString() ?? 'N/A'),
                _loanDetailRow('Unpaid Amount', loan['unpaid_amount']?.toString() ?? 'N/A'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement the Pay functionality
                  },
                  child: Text('Pay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 100.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
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

  Widget _loanDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Get Task', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Lato')),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation!,
        child: SlideTransition(
          position: _slideAnimation!,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                _buildTaskSection('Assigned Parties', assignedParties),
                _buildTaskSection('Weekly Loans', weeklyLoans),
                _buildTaskSection('Monthly Loans', monthlyLoans),
                _buildTaskSection('Vehicle Loans', vehicleLoans),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskSection(String title, List<dynamic> items) {
    return items.isEmpty
        ? SizedBox()
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
            fontFamily: 'Lato',
          ),
        ),
        SizedBox(height: 8),
        ...items.map((item) => _buildTaskItem(item)).toList(),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> item) {
    String category;
    if (weeklyLoans.contains(item)) {
      category = 'Weekly Loan';
    } else if (monthlyLoans.contains(item)) {
      category = 'Monthly Loan';
    } else if (vehicleLoans.contains(item)) {
      category = 'Vehicle Loan';
    } else {
      category = 'Unknown Category';
    }

    return GestureDetector(
      onTap: () => _showLoanDetails(item),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Party ID: ${item['party_id']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Due Date: ${item['due_date'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
