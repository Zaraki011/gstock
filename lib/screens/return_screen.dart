import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/borrow.dart';
import '../services/api_service.dart';

class ReturnScreen extends StatefulWidget {
  final Borrow borrow;
  const ReturnScreen({super.key, required this.borrow});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  final ApiService _apiService = ApiService();
  String _returnDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _isSubmitting = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.parse(widget.borrow.borrowDate),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _returnDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitReturn() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _apiService.returnBorrow(widget.borrow.id, _returnDate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item returned successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to return item: $e')));
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Return Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.borrow.componentName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text('ID: ${widget.borrow.id}'),
                const SizedBox(height: 8),
                Text('Borrowed by: ${widget.borrow.memberName}'),
                const SizedBox(height: 8),
                Text('Quantity: ${widget.borrow.quantity}'),
                const SizedBox(height: 8),
                Text('Borrow Date: ${widget.borrow.borrowDate}'),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Return Date: $_returnDate',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReturn,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child:
                        _isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text('Confirm Return'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
