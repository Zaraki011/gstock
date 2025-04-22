import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/component.dart';
import '../models/member.dart';
import '../models/borrow.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_field.dart';

class BorrowScreen extends StatefulWidget {
  const BorrowScreen({super.key});

  @override
  State<BorrowScreen> createState() => _BorrowScreenState();
}

class _BorrowScreenState extends State<BorrowScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  // Form data
  List<Component> _components = [];
  List<Member> _members = [];
  Component? _selectedComponent;
  Member? _selectedMember;
  final _quantityController = TextEditingController();
  String _borrowDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _isSubmitting = false;

  // Borrow list data
  List<Borrow> _borrows = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _loadBorrows();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final componentsResult = await _apiService.getComponents();
      final membersResult = await _apiService.getMembers();

      setState(() {
        _components = componentsResult;
        _members = membersResult;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBorrows() async {
    try {
      final borrows = await _apiService.getBorrows();
      setState(() {
        _borrows = borrows;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load borrows: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _borrowDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitBorrow() async {
    if (_formKey.currentState!.validate() &&
        _selectedComponent != null &&
        _selectedMember != null) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await _apiService.createBorrow({
          'component': _selectedComponent!.id,
          'member': _selectedMember!.id,
          'quantity': int.parse(_quantityController.text),
          'borrow_date': _borrowDate,
          'status': 'pending',
        });

        if (mounted) {
          // Refresh borrows list
          _loadBorrows();
          
          // Switch to borrowed items tab
          _tabController.animateTo(1);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Component borrowed successfully')),
          );
          
          // Reset form
          setState(() {
            _selectedComponent = null;
            _selectedMember = null;
            _quantityController.clear();
            _borrowDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
            _isSubmitting = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to borrow component: $e')),
          );
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  void _returnItem(Borrow borrow) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Item'),
        content: Text('Return ${borrow.componentName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
              try {
                await _apiService.returnBorrow(borrow.id, today);
                Navigator.pop(context);
                _loadBorrows(); // Refresh the list
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to return: $e')),
                );
              }
            },
            child: const Text('Return'),
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
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_components.isEmpty || _members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Components or members are not available',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Borrow Components'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Borrow Form'),
            Tab(text: 'Borrowed Items'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // First tab - Borrow Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Borrow Component',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          DropdownButtonFormField<Component>(
                            decoration: const InputDecoration(
                              labelText: 'Component',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedComponent,
                            items: _components.map((Component component) {
                              return DropdownMenuItem<Component>(
                                value: component,
                                child: Text(
                                  '${component.name} (${component.quantity} available)',
                                ),
                              );
                            }).toList(),
                            onChanged: (Component? newValue) {
                              setState(() {
                                _selectedComponent = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a component';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<Member>(
                            decoration: const InputDecoration(
                              labelText: 'Member',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedMember,
                            items: _members.map((Member member) {
                              return DropdownMenuItem<Member>(
                                value: member,
                                child: Text('${member.firstName} ${member.lastName}'),
                              );
                            }).toList(),
                            onChanged: (Member? newValue) {
                              setState(() {
                                _selectedMember = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a member';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _quantityController,
                            label: 'Quantity',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a quantity';
                              }
                              if (int.tryParse(value) == null ||
                                  int.parse(value) <= 0) {
                                return 'Please enter a valid quantity';
                              }
                              if (_selectedComponent != null &&
                                  int.parse(value) > _selectedComponent!.quantity) {
                                return 'Not enough stock available';
                              }
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text('Borrow Date: $_borrowDate'),
                                ),
                                TextButton(
                                  onPressed: () => _selectDate(context),
                                  child: const Text('Select Date'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitBorrow,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                              ),
                              child: _isSubmitting
                                  ? const CircularProgressIndicator()
                                  : const Text('Borrow Component'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Second tab - Borrowed Items
          _borrows.isEmpty
              ? const Center(child: Text('No borrowed items found'))
              : RefreshIndicator(
                  onRefresh: _loadBorrows,
                  child: ListView.builder(
                    itemCount: _borrows.length,
                    itemBuilder: (context, index) {
                      final borrow = _borrows[index];
                      final isReturned = borrow.returnDate != null;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: ListTile(
                          title: Text(
                            borrow.componentName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Borrowed by: ${borrow.memberName}'),
                              Text('Quantity: ${borrow.quantity}'),
                              Text('Date: ${borrow.borrowDate}'),
                              if (isReturned) Text('Returned: ${borrow.returnDate}'),
                              Container(
                                margin: const EdgeInsets.only(top: 8.0),
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: isReturned ? Colors.green : Colors.orange,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  isReturned ? 'Returned' : 'Pending',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: !isReturned
                              ? ElevatedButton(
                                  onPressed: () => _returnItem(borrow),
                                  child: const Text('Return'),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}