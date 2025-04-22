import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/borrow.dart';
import '../services/api_service.dart';

class PendingReturnsScreen extends StatefulWidget {
  const PendingReturnsScreen({super.key});

  @override
  State<PendingReturnsScreen> createState() => _PendingReturnsScreenState();
}

class _PendingReturnsScreenState extends State<PendingReturnsScreen> {
  final ApiService _apiService = ApiService();
  List<Borrow> _pendingBorrows = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPendingBorrows();
  }

  Future<void> _loadPendingBorrows() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final borrows = await _apiService.getBorrows();
      setState(() {
        // Filter borrows where return_date is null (pending returns)
        _pendingBorrows = borrows.where((b) => b.returnDate == null).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load pending borrows: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _returnItem(Borrow borrow) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Return'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to return ${borrow.componentName}?'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Return Condition',
                border: OutlineInputBorder(),
              ),
              value: 'intact',
              items: const [
                DropdownMenuItem(value: 'intact', child: Text('Intact')),
                DropdownMenuItem(value: 'damaged', child: Text('Damaged')),
                DropdownMenuItem(value: 'heavily_damaged', child: Text('Heavily Damaged')),
              ],
              onChanged: (String? newValue) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final condition = 'intact'; // Get selected condition from dropdown
              Navigator.pop(context);
              
              try {
                await _apiService.returnBorrow(borrow.id, today, condition: condition);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item returned successfully')),
                );
                
                _loadPendingBorrows();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to return item: $e')),
                );
              }
            },
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }

  void _showBorrowDetails(Borrow borrow) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(borrow.componentName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${borrow.id}'),
            const SizedBox(height: 8),
            Text('Borrowed by: ${borrow.memberName}'),
            const SizedBox(height: 8),
            Text('Quantity: ${borrow.quantity}'),
            const SizedBox(height: 8),
            Text('Borrow Date: ${borrow.borrowDate}'),
            const SizedBox(height: 8),
            Text('Status: ${borrow.returnDate == null ? "Pending" : "Returned"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (borrow.returnDate == null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _returnItem(borrow);
              },
              child: const Text('Return Item'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPendingBorrows,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_pendingBorrows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'No pending returns',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPendingBorrows,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadPendingBorrows,
        child: ListView.builder(
          itemCount: _pendingBorrows.length,
          itemBuilder: (context, index) {
            final borrow = _pendingBorrows[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text(
                  borrow.componentName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity: ${borrow.quantity}'),
                    Text('Borrowed by: ${borrow.memberName}'),
                    Text('Borrow date: ${borrow.borrowDate}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () => _returnItem(borrow),
                  child: const Text('Return'),
                ),
                onTap: () => _showBorrowDetails(borrow),
              ),
            );
          },
        ),
      ),
    );
  }
}