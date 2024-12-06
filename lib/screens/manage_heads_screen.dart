import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/head.dart';

class ManageHeadsScreen extends StatefulWidget {
  const ManageHeadsScreen({super.key});

  @override
  State<ManageHeadsScreen> createState() => _ManageHeadsScreenState();
}

class _ManageHeadsScreenState extends State<ManageHeadsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Heads'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Head>('heads').listenable(),
        builder: (context, box, _) {
          final heads = box.values.toList();
          return ListView.builder(
            itemCount: heads.length,
            itemBuilder: (context, index) {
              final head = heads[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(head.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: head.enabled,
                        onChanged: (value) {
                          head.enabled = value;
                          head.save();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditHeadDialog(context, head),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteHead(head),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHeadDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddHeadDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String name = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Head'),
        content: Form(
          key: formKey,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Head Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a name' : null,
            onSaved: (value) => name = value!,
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
                _addHead(name);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addHead(String name) {
    final head = Head(
      id: DateTime.now().toString(),
      name: name,
    );
    
    final box = Hive.box<Head>('heads');
    box.add(head);
  }

  Future<void> _showEditHeadDialog(BuildContext context, Head head) async {
    final formKey = GlobalKey<FormState>();
    String name = head.name;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Head'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: name,
            decoration: const InputDecoration(
              labelText: 'Head Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a name' : null,
            onSaved: (value) => name = value!,
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
                head.name = name;
                head.save();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteHead(Head head) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Head'),
        content: Text('Are you sure you want to delete ${head.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              head.delete();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 