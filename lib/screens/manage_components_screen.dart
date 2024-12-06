import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cost_component.dart';

class ManageComponentsScreen extends StatefulWidget {
  const ManageComponentsScreen({super.key});

  @override
  State<ManageComponentsScreen> createState() => _ManageComponentsScreenState();
}

class _ManageComponentsScreenState extends State<ManageComponentsScreen> {
  final List<String> categories = [
    'Raw Materials',
    'Consumables',
    'Packaging',
    'Labor',
    'Overhead'
  ];

  final List<String> _units = ['Kg', 'g', 'L', 'ml', 'Pc', 'Box', 'Pack'];
  String selectedCategory = 'Raw Materials';
  String selectedUnit = 'Kg';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Components'),
          bottom: TabBar(
            isScrollable: true,
            tabs: categories.map((category) => Tab(text: category)).toList(),
          ),
        ),
        body: TabBarView(
          children: categories
              .map((category) => _buildComponentList(category))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddComponentDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildComponentList(String category) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<CostComponent>('components').listenable(),
      builder: (context, box, _) {
        final components = box.values
            .where((component) => component.headId == category)
            .toList();

        return ListView.builder(
          itemCount: components.length,
          itemBuilder: (context, index) {
            final component = components[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(component.name),
                subtitle: Text('₹${component.unitPrice} per ${component.unit}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showEditComponentDialog(context, component),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteComponent(component),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddComponentDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    double unitPrice = 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Component'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                      // Set default unit based on category
                      if (value == 'Raw Materials') {
                        selectedUnit = 'Kg';
                      } else if (value == 'Consumables') {
                        selectedUnit = 'Pc';
                      } else {
                        selectedUnit = _units.first;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
                  onSaved: (value) => name = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Unit Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter a price';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => unitPrice = double.parse(value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                  items: _units
                      .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUnit = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                _addComponent(name, selectedCategory, unitPrice, selectedUnit);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addComponent(
      String name, String category, double unitPrice, String unit) {
    final component = CostComponent(
      id: DateTime.now().toString(),
      name: name,
      headId: category,
      unitPrice: unitPrice,
      unit: unit,
    );

    final box = Hive.box<CostComponent>('components');
    box.add(component);
  }

  Future<void> _showEditComponentDialog(
      BuildContext context, CostComponent component) async {
    final formKey = GlobalKey<FormState>();
    String name = component.name;
    double? unitPrice = component.unitPrice;
    String selectedUnit = component.unit;
    String selectedCategory = component.headId;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Component'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
                  onSaved: (value) => name = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: unitPrice?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Unit Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return null;
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => unitPrice =
                      value?.isEmpty ?? true ? null : double.parse(value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                  items: _units
                      .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUnit = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                component.name = name;
                component.headId = selectedCategory;
                component.unitPrice = unitPrice;
                component.unit = selectedUnit;
                component.save();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteComponent(CostComponent component) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Component'),
        content: Text('Are you sure you want to delete ${component.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              component.delete();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
