import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/setting_item.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<SettingItem>('settings').listenable(),
        builder: (context, box, _) {
          final taxItems = box.values.where((item) => item.type == 'tax').toList();
          final profitItems = box.values.where((item) => item.type == 'profit').toList();
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Tax Heads'),
              ...taxItems.map((item) => _buildSettingCard(item)),
              _buildAddButton('tax'),
              const SizedBox(height: 24),
              _buildSectionHeader('Profit Margins'),
              ...profitItems.map((item) => _buildSettingCard(item)),
              _buildAddButton('profit'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingCard(SettingItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text(
          'Default: ${item.defaultValue}${item.isPercentage ? '%' : '₹'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: item.enabled,
              onChanged: (value) {
                setState(() {
                  item.enabled = value;
                  item.save();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context, item),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteItem(item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: OutlinedButton.icon(
        onPressed: () => _showAddDialog(context, type),
        icon: const Icon(Icons.add),
        label: Text('Add ${type == 'tax' ? 'Tax Head' : 'Profit Margin'}'),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, String type) async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    double defaultValue = 0.0;
    bool isPercentage = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add New ${type == 'tax' ? 'Tax Head' : 'Profit Margin'}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Default Value',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter a value';
                          if (double.tryParse(value!) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) => defaultValue = double.parse(value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<bool>(
                      value: isPercentage,
                      items: const [
                        DropdownMenuItem(
                          value: true,
                          child: Text('%'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('₹'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          isPercentage = value!;
                        });
                      },
                    ),
                  ],
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
                  _addItem(name, defaultValue, type, isPercentage);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem(String name, double value, String type, bool isPercentage) {
    final box = Hive.box<SettingItem>('settings');
    final item = SettingItem(
      id: DateTime.now().toString(),
      name: name,
      defaultValue: value,
      type: type,
      isPercentage: isPercentage,
    );
    box.add(item);
  }

  Future<void> _showEditDialog(BuildContext context, SettingItem item) async {
    final formKey = GlobalKey<FormState>();
    String name = item.name;
    double defaultValue = item.defaultValue;
    bool isPercentage = item.isPercentage;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${item.type == 'tax' ? 'Tax Head' : 'Profit Margin'}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: defaultValue.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Default Value',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter a value';
                          if (double.tryParse(value!) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) => defaultValue = double.parse(value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<bool>(
                      value: isPercentage,
                      items: const [
                        DropdownMenuItem(
                          value: true,
                          child: Text('%'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('₹'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          isPercentage = value!;
                        });
                      },
                    ),
                  ],
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
                  item.name = name;
                  item.defaultValue = defaultValue;
                  item.isPercentage = isPercentage;
                  item.save();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteItem(SettingItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${item.type == 'tax' ? 'Tax Head' : 'Profit Margin'}'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              item.delete();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 