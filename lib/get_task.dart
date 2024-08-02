import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Add this import for json decoding

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
    final String apiUrl = "https://finance2024.ingenious-technologies.com/financeapp/public/api/executive/config";
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer 5|cg6UIwNWuES60zqlxgl6jE9QtnQSsvaggr3OGhQna5d23440"
      },
    );

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
              children: <Widget>[
                _buildTaskSection('Assigned Parties', assignedParties.map((party) => _partyDetails(party)).toList()),
                _buildTaskSection('Weekly Loans', weeklyLoans.map((loan) => _loanDetails(loan)).toList()),
                _buildTaskSection('Monthly Loans', monthlyLoans.map((loan) => _loanDetails(loan)).toList()),
                _buildTaskSection('Vehicle Loans', vehicleLoans.map((loan) => _loanDetails(loan)).toList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskSection(String title, List<Widget> items) {
    return items.isEmpty
        ? SizedBox()
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
            fontFamily: 'Lato',
          ),
        ),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: item,
            ),
          ),
        )),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _partyDetails(Map<String, dynamic> party) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ID: ${party['id']}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Lato'),
        ),
        Text(
          'Name: ${party['party_name']}',
          style: TextStyle(fontSize: 16, fontFamily: 'Lato'),
        ),
      ],
    );
  }

  Widget _loanDetails(Map<String, dynamic> loan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loan ID: ${loan['loan_id']}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Lato'),
        ),
        Text(
          'Loan Amount: ${loan['loan_amount']}',
          style: TextStyle(fontSize: 16, fontFamily: 'Lato'),
        ),
        Text(
          'Loan Date: ${loan['loan_date']}',
          style: TextStyle(fontSize: 16, fontFamily: 'Lato'),
        ),
        Text(
          'Rate of Interest: ${loan['rate_of_interest']}',
          style: TextStyle(fontSize: 16, fontFamily: 'Lato'),
        ),
        Text(
          'No of Dues: ${loan['no_of_dues']}',
          style: TextStyle(fontSize: 16, fontFamily: 'Lato'),
        ),
        Text(
          'Total Amount: ${loan['total_amount']}',
          style: TextStyle(fontSize: 16, fontFamily: 'Lato'),
        ),
        Text(
          'Paid Dues: ${loan['paid_dues']}',
          style: TextStyle(fontSize: 16, fontFamily: 'Lato'),
        ),
        Text(
          'Paid Amount: ${loan['paid_amount']}',
          style: TextStyle(fontSize: 16, fontFamily: 'Lato'),
        ),
        Text(
          'Unpaid Dues: ${loan['unpaid_dues']}',
          style: TextStyle(fontSize: 16, fontFamily: 'Lato'),
        ),
        Text(
          'Unpaid Amount: ${loan['unpaid_amount']}',
          style: TextStyle(fontSize: 16, fontFamily: 'Lato'),
        ),
      ],
    );
  }
}
