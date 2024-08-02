import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehicleDueForm extends StatefulWidget {
  @override
  _VehicleDueFormState createState() => _VehicleDueFormState();
}

class _VehicleDueFormState extends State<VehicleDueForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loanIdController = TextEditingController();
  final TextEditingController _partyIdController = TextEditingController();
  final TextEditingController _paidDateController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  final TextEditingController _dueNoController = TextEditingController();
  final TextEditingController _dueStatusController = TextEditingController();
  final TextEditingController _transactionNoController = TextEditingController();
  String _paymentMode = 'cash';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _paidDateController.text = "${picked.toLocal().day}-${picked.toLocal().month}-${picked.toLocal().year}";
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String apiUrl = "https://finance2024.ingenious-technologies.com/financeapp/public/api/executive/vehicle-due-payment";
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "loan_id": int.parse(_loanIdController.text),
          "party_id": int.parse(_partyIdController.text),
          "paid_date": _paidDateController.text,
          "paid_amount": double.parse(_paidAmountController.text),
          "due_no": int.parse(_dueNoController.text),
          "due_status": _dueStatusController.text,
          "payment_mode": _paymentMode,
          "transaction_no": _transactionNoController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Payment successful: $data");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehicle Due Paid Successfully')),
        );
      } else {
        print("Payment failed: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Due Payment'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextField(_loanIdController, 'Loan ID'),
              _buildTextField(_partyIdController, 'Party ID'),
              _buildDateField(context, _paidDateController, 'Paid Date (dd-mm-yyyy)'),
              _buildTextField(_paidAmountController, 'Paid Amount'),
              _buildTextField(_dueNoController, 'Due No'),
              _buildTextField(_dueStatusController, 'Due Status'),
              _buildDropdownField('Payment Mode'),
              _buildTextField(_transactionNoController, 'Transaction No'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
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
        keyboardType: label == 'Paid Amount' ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(BuildContext context, TextEditingController controller, String label) {
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
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ),
        readOnly: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _paymentMode,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
        ),
        items: <String>['cash', 'online'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _paymentMode = newValue!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }
}
