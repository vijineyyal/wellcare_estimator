import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cost_component.dart';
import '../models/head.dart';

class InventoryItemsScreen extends StatefulWidget {
  const InventoryItemsScreen({super.key});

  @override
  State<InventoryItemsScreen> createState() => _InventoryItemsScreenState();
}

class _InventoryItemsScreenState extends State<InventoryItemsScreen> {
  final List<String> _units = ['Kg', 'g', 'L', 'ml', 'Pc', 'Box', 'Pack'];
  String selectedUnit = 'Kg';
  String? selectedHeadId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Items'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Head>('heads').listenable(),
        builder: (context, headBox, _) {
          final heads = headBox.values.where((head) => head.enabled).toList();
          
          if (heads.isEmpty) {
            return const Center(
              child: Text('Please add some heads first'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: selectedHeadId ?? heads.first.id,
                  decoration: const InputDecoration(
                    labelText: 'Select Head',
                    border: OutlineInputBorder(),
                  ),
                  items: heads.map((head) => DropdownMenuItem(
                    value: head.id,
                    child: Text(head.name),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedHeadId = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<CostComponent>('components').listenable(),
                  builder: (context, componentBox, _) {
                    final components = componentBox.values
                        .where((component) => component.headId == (selectedHeadId ?? heads.first.id))
                        .toList();

                    return ListView.builder(
                      itemCount: components.length,
                      itemBuilder: (context, index) {
                        final component = components[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: ListTile(
                            title: Text(component.name),
                            subtitle: Text(
                              component.unitPrice != null
                                  ? '₹${component.unitPrice} per ${component.unit}'
                                  : component.unit,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showEditItemDialog(context, component),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteItem(component),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    double? unitPrice;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Item'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder(
                  valueListenable: Hive.box<Head>('heads').listenable(),
                  builder: (context, headBox, _) {
                    final heads = headBox.values.where((head) => head.enabled).toList();
                    
                    if (heads.isEmpty) {
                      return const Text('Please add some heads first');
                    }

                    return DropdownButtonFormField<String>(
                      value: selectedHeadId ?? heads.first.id,
                      decoration: const InputDecoration(
                        labelText: 'Head',
                        border: OutlineInputBorder(),
                      ),
                      items: heads.map((head) => DropdownMenuItem(
                        value: head.id,
                        child: Text(head.name),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedHeadId = value;
                          // Set default unit based on head
                          final head = heads.firstWhere((h) => h.id == value);
                          if (head.name == 'Raw Materials') {
                            selectedUnit = 'Kg';
                          } else if (head.name == 'Consumables') {
                            selectedUnit = 'Pc';
                          }
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a head' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
                  onSaved: (value) => name = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Unit Price (Optional)',
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
                  onSaved: (value) => unitPrice = value?.isEmpty ?? true
                      ? null
                      : double.parse(value!),
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
                _addItem(name, unitPrice);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addItem(String name, double? unitPrice) {
    final box = Hive.box<CostComponent>('components');
    final component = CostComponent(
      id: DateTime.now().toString(),
      name: name,
      headId: selectedHeadId ?? Hive.box<Head>('heads').values.first.id,
      unitPrice: unitPrice,
      unit: selectedUnit,
    );
    box.add(component);
  }

  Future<void> _showEditItemDialog(BuildContext context, CostComponent component) async {
    final formKey = GlobalKey<FormState>();
    String name = component.name;
    double? unitPrice = component.unitPrice;
    String unit = component.unit;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder(
                  valueListenable: Hive.box<Head>('heads').listenable(),
                  builder: (context, headBox, _) {
                    final heads = headBox.values.where((head) => head.enabled).toList();
                    
                    return DropdownButtonFormField<String>(
                      value: selectedHeadId ?? component.headId,
                      decoration: const InputDecoration(
                        labelText: 'Head',
                        border: OutlineInputBorder(),
                      ),
                      items: heads.map((head) => DropdownMenuItem(
                        value: head.id,
                        child: Text(head.name),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedHeadId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a head' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
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
                    labelText: 'Unit Price (Optional)',
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
                  onSaved: (value) => unitPrice = value?.isEmpty ?? true
                      ? null
                      : double.parse(value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: unit,
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
                      unit = value!;
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
                component.unitPrice = unitPrice;
                component.unit = unit;
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

  void _deleteItem(CostComponent component) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
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