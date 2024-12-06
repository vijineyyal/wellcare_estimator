import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/unit.dart';

class ManageUnitsScreen extends StatefulWidget {
  const ManageUnitsScreen({super.key});

  @override
  State<ManageUnitsScreen> createState() => _ManageUnitsScreenState();
}

class _ManageUnitsScreenState extends State<ManageUnitsScreen> {
  final List<String> categories = [
    'Weight',
    'Length',
    'Volume',
    'Area',
    'Time',
    'Quantity',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Units'),
          bottom: TabBar(
            isScrollable: true,
            tabs: categories.map((category) => Tab(text: category)).toList(),
          ),
        ),
        body: TabBarView(
          children: categories.map((category) => _buildUnitsList(category)).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddUnitDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildUnitsList(String category) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Unit>('units').listenable(),
      builder: (context, box, _) {
        final units = box.values
            .where((unit) => unit.category == category)
            .toList();

        return ListView.builder(
          itemCount: units.length,
          itemBuilder: (context, index) {
            final unit = units[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(unit.name),
                subtitle: Text(unit.category),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: unit.enabled,
                      onChanged: (value) {
                        unit.enabled = value;
                        unit.save();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditUnitDialog(context, unit),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteUnit(unit),
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

  Future<void> _showAddUnitDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String selectedCategory = categories.first;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Unit'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Unit Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
                onSaved: (value) => name = value!,
              ),
              const SizedBox(height: 16),
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
                  selectedCategory = value!;
                },
              ),
            ],
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
                _addUnit(name, selectedCategory);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addUnit(String name, String category) {
    final unit = Unit(
      id: DateTime.now().toString(),
      name: name,
      category: category,
    );
    
    final box = Hive.box<Unit>('units');
    box.add(unit);
  }

  Future<void> _showEditUnitDialog(BuildContext context, Unit unit) async {
    final formKey = GlobalKey<FormState>();
    String name = unit.name;
    String category = unit.category;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Unit'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(
                  labelText: 'Unit Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
                onSaved: (value) => name = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
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
                  category = value!;
                },
              ),
            ],
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
                unit.name = name;
                unit.category = category;
                unit.save();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteUnit(Unit unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Unit'),
        content: Text('Are you sure you want to delete ${unit.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              unit.delete();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 