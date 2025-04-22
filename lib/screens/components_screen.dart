import 'package:flutter/material.dart';
import 'package:gstock/models/category.dart';
import '../models/component.dart';
import '../services/api_service.dart';
import '../widgets/component_card.dart';
import '../widgets/custom_text_field.dart';
import 'package:intl/intl.dart';

class ComponentsScreen extends StatefulWidget {
  const ComponentsScreen({super.key});

  @override
  State<ComponentsScreen> createState() => ComponentsScreenState();
}

class ComponentsScreenState extends State<ComponentsScreen> {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  List<Component> _components = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadComponents();
    _loadCategories();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load categories: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadComponents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final components = await _apiService.getComponents();
      setState(() {
        _components = components;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load components: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showAddComponent() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddComponentForm(categories: _categories),
    ).then((_) => _loadComponents());
  }

  void _showDeleteDialog(Component component) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Component'),
            content: Text('Are you sure you want to delete ${component.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _apiService.deleteComponent(component.id);
                    Navigator.pop(context);
                    _loadComponents();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Delete failed: $e')),
                    );
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(Component component) {
    final nameController = TextEditingController(text: component.name);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Component'),
            content: CustomTextField(controller: nameController, label: 'Name'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _apiService.updateComponent(component.id, {
                      'name': nameController.text,
                    });
                    Navigator.pop(context);
                    _loadComponents();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Update failed: $e')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showComponentDetails(Component component) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(component.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${component.id}'),
                const SizedBox(height: 8),
                Text('Category: ${component.categoryName}'),
                const SizedBox(height: 8),
                Text('Quantity: ${component.quantity}'),
                const SizedBox(height: 8),
                Text('Acquisition Date: ${component.acquisitionDate}'),
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
              onPressed: _loadComponents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_components.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No components found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAddComponent,
              child: const Text('Add Component'),
            ),
          ],
        ),
      );
    }

    final List<Component> filteredComponents =
        _components.where((component) {
          return component.name.toLowerCase().contains(_searchQuery);
        }).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadComponents,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Rechercher un composant',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredComponents.length,
                itemBuilder: (context, index) {
                  final component = filteredComponents[index];
                  return ComponentCard(
                    component: component,
                    onTap: () => _showComponentDetails(component),
                    // onBorrow: () {
                    //   // Navigate to borrow screen with this component
                    // },
                    onEdit: () {
                      _showEditDialog(component);
                    },
                    onDelete: () {
                      _showDeleteDialog(component);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddComponent,
        tooltip: 'Add Component',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddComponentForm extends StatefulWidget {
  final List<Category> categories;

  const AddComponentForm({super.key, required this.categories});

  @override
  State<AddComponentForm> createState() => _AddComponentFormState();
}

class _AddComponentFormState extends State<AddComponentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _acquisitionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  int? selectedCategoryId;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
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
        _acquisitionDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveComponent() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une catégorie')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await _apiService.createComponent({
          'name': _nameController.text,
          'quantity': int.parse(_quantityController.text),
          'category': selectedCategoryId, // 🔥 Use ID here
          'acquisition_date': _acquisitionDate,
        });

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save component: $e')));
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Component',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: _quantityController,
                label: 'Quantity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedCategoryId,
                decoration: const InputDecoration(labelText: "Catégorie"),
                items:
                    widget.categories
                        .map(
                          (category) => DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Veuillez choisir une catégorie' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text('Acquisition Date: $_acquisitionDate')),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveComponent,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save Component'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
