import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MonthlyDueForm extends StatefulWidget {
  @override
  _MonthlyDueFormState createState() => _MonthlyDueFormState();
}

class _MonthlyDueFormState extends State<MonthlyDueForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _partyIdController = TextEditingController();
  final TextEditingController _loanIdController = TextEditingController();
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _paidDateController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  final TextEditingController _dueNoController = TextEditingController();
  final TextEditingController _transactionNoController = TextEditingController();
  String? _paymentMode = "cash";

  List<dynamic> monthlyLoans = [];
  String? selectedLoanId;

  @override
  void initState() {
    super.initState();
    _fetchMonthlyLoans();
  }

  Future<void> _fetchMonthlyLoans() async {
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

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        monthlyLoans = data['data']['monthly_loans'] ?? [];
      });
    } else {
      print("Failed to load monthly loans: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load monthly loans. Please try again.')),
      );
    }
  }

  void _onLoanIdChanged(String? loanId) {
    if (loanId == null) return;

    setState(() {
      selectedLoanId = loanId;
    });

    final selectedLoan = monthlyLoans.firstWhere((loan) => loan['loan_id'].toString() == loanId);
    _partyIdController.text = selectedLoan['party_id'].toString();
    _loanIdController.text = selectedLoan['loan_id'].toString();
    _loanAmountController.text = selectedLoan['loan_amount'].toString();
    _interestRateController.text = selectedLoan['interest_rate'].toString();
    _totalAmountController.text = selectedLoan['total_amt'].toString();
  }

  Future<void> _submitMonthlyDuePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String apiUrl = "https://finance2024.ingenious-technologies.com/financeapp/public/api/executive/monthly-due-payment";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "loan_id": int.parse(_loanIdController.text),
        "party_id": int.parse(_partyIdController.text),
        "paid_date": _paidDateController.text,
        "paid_amount": double.parse(_paidAmountController.text),
        "due_no": int.parse(_dueNoController.text),
        "due_status": "paid",
        "payment_mode": _paymentMode,
        "transaction_no": _transactionNoController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Monthly Due Paid Successfully')),
      );
    } else {
      print("Payment failed: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Due Payment'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: selectedLoanId,
                onChanged: _onLoanIdChanged,
                decoration: InputDecoration(
                  labelText: 'Select Loan ID',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: monthlyLoans.map<DropdownMenuItem<String>>((loan) {
                  return DropdownMenuItem<String>(
                    value: loan['loan_id'].toString(),
                    child: Text(loan['loan_id'].toString()),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              _buildTextField(_partyIdController, 'Party ID'),
              _buildTextField(_loanIdController, 'Loan ID'),
              _buildTextField(_loanAmountController, 'Loan Amount'),
              _buildTextField(_interestRateController, 'Interest Rate'),
              _buildTextField(_totalAmountController, 'Total Amount'),
              _buildTextField(_paidDateController, 'Paid Date (dd-mm-yyyy)'),
              _buildTextField(_paidAmountController, 'Paid Amount'),
              _buildTextField(_dueNoController, 'Due No'),
              _buildTextField(_transactionNoController, 'Transaction No'),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentMode,
                onChanged: (String? newValue) {
                  setState(() {
                    _paymentMode = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Payment Mode',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: <String>['cash', 'online'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitMonthlyDuePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 100.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
