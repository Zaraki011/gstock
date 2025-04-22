import 'package:flutter/material.dart';
import '../models/component.dart';

class ComponentCard extends StatelessWidget {
  final Component component;
  final Function onTap;
  final Function? onBorrow;
  final Function? onEdit;
  final Function? onDelete;

  const ComponentCard({
    super.key,
    required this.component,
    required this.onTap,
    this.onBorrow,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                      component.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onBorrow != null)
                    ElevatedButton(
                      onPressed: () => onBorrow!(),
                      child: const Text('Borrow'),
                    ),
                  if (onEdit != null)
                    ElevatedButton(
                      onPressed: () => onEdit!(),
                      child: const Text('Edit'),
                    ),
                  if (onDelete != null)
                    ElevatedButton(
                      onPressed: () => onDelete!(),
                      child: const Text('Delete'),
                    ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text('Category: ${component.categoryName}'),
              const SizedBox(height: 4.0),
              Text(
                'Quantity: ${component.quantity}',
                style: TextStyle(
                  color: component.quantity <= 5 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text('Acquisition Date: ${component.acquisitionDate}'),
            ],
          ),
        ),
      ),
    );
  }
}
