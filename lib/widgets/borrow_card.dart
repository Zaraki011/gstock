import 'package:flutter/material.dart';
import '../models/borrow.dart';

class BorrowCard extends StatelessWidget {
  final Borrow borrow;
  final Function onTap;
  final Function? onReturn;

  const BorrowCard({
    super.key,
    required this.borrow,
    required this.onTap,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status from returnDate
    final bool isReturned = borrow.returnDate != null;
    final String status = isReturned ? 'returned' : 'pending';
    
    // Set color based on return status
    Color statusColor = isReturned ? Colors.green : Colors.orange;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${borrow.componentName} (${borrow.quantity})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isReturned && onReturn != null)
                    ElevatedButton(
                      onPressed: () => onReturn!(),
                      child: const Text('Return'),
                    ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text('Borrowed by: ${borrow.memberName}'),
              const SizedBox(height: 4.0),
              Text('Borrow Date: ${borrow.borrowDate}'),
              const SizedBox(height: 4.0),
              if (borrow.returnDate != null)
                Text('Return Date: ${borrow.returnDate}'),
              const SizedBox(height: 4.0),
              if (borrow.returnCondition != null)
                Text('Condition: ${borrow.returnCondition}'),
              const SizedBox(height: 4.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}