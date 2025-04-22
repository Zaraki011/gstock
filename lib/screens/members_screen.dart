import 'package:flutter/material.dart';
import '../models/member.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_field.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final ApiService _apiService = ApiService();
  List<Member> _members = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final members = await _apiService.getMembers();
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load members: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showAddMember() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddMemberForm(),
    ).then((_) => _loadMembers());
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
            ElevatedButton(onPressed: _loadMembers, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No members found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAddMember,
              child: const Text('Add Member'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadMembers,
        child: ListView.builder(
          itemCount: _members.length,
          itemBuilder: (context, index) {
            final member = _members[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(member.firstName[0].toUpperCase()),
                ),
                title: Text(
                  member.firstName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(member.lastName),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(member.firstName),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: ${member.id}'),
                              const SizedBox(height: 8),
                              Text('Name: ${member.firstName} ${member.lastName}'),
                              const SizedBox(height: 8),
                              Text('Phone1: ${member.phone1}'),
                              const SizedBox(height: 8),
                              Text('Phone2: ${member.phone2}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMember,
        tooltip: 'Add Member',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddMemberForm extends StatefulWidget {
  const AddMemberForm({super.key});

  @override
  State<AddMemberForm> createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<AddMemberForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Assuming there's a createMember method in ApiService
        await _apiService.createMember({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'phone1': _phone1Controller.text,
          'phone2': _phone2Controller.text,
        });

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save member: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Member',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _firstNameController,
              label: 'First Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            CustomTextField(
              controller: _lastNameController,
              label: 'Last Name',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                return null;
              },
            ),
            CustomTextField(
              controller: _phone1Controller,
              label: 'Phone1',
              keyboardType: TextInputType.phone,
            ),
            CustomTextField(
              controller: _phone2Controller,
              label: 'Phone2',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveMember,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Save Member'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
