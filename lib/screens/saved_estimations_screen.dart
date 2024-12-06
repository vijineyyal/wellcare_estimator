import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/company_settings.dart';
import '../models/estimation.dart';
import 'package:intl/intl.dart';
import '../screens/estimation_details_screen.dart';
import '../screens/new_estimation_screen.dart';

class SavedEstimationsScreen extends StatelessWidget {
  const SavedEstimationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Estimations'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Estimation>('estimations').listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No saved estimations'),
            );
          }

          final estimations = box.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            itemCount: estimations.length,
            itemBuilder: (context, index) {
              final estimation = estimations[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text(estimation.name),
                  subtitle: Text(
                    'ID: ${estimation.getDisplayId()}\n'
                    'Created on: ${DateFormat('dd MMM yyyy, HH:mm').format(estimation.createdAt)}\n'
                    'Total: ₹${estimation.totalCost.toStringAsFixed(2)}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note),
                        onPressed: () => _reviseEstimation(context, estimation),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => _duplicateEstimation(context, estimation),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteEstimation(context, estimation),
                      ),
                    ],
                  ),
                  onTap: () => _viewEstimationDetails(context, estimation),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _duplicateEstimation(BuildContext context, Estimation estimation) {
    // Get company settings for new estimation ID
    final settingsBox = Hive.box<CompanySettings>('company_settings');
    final companySettings = settingsBox.isEmpty ? null : settingsBox.values.first;
    final newEstimationId = companySettings?.getEstimationId() ?? 'EST-0001';

    final newEstimation = Estimation(
      id: DateTime.now().toString(),
      name: '${estimation.name} (Copy)',
      createdAt: DateTime.now(),
      components: Map.from(estimation.components),
      taxRate: estimation.taxRate,
      profitMargin: estimation.profitMargin,
      overheads: Map.from(estimation.overheads),
      totalCost: estimation.totalCost,
      estimationId: newEstimationId,
      quantities: Map.from(estimation.quantities),
      productName: estimation.productName,
      componentDetails: Map.from(estimation.componentDetails),
      enabledTaxHeads: List.from(estimation.enabledTaxHeads),
      enabledProfitMargins: List.from(estimation.enabledProfitMargins),
    );

    final box = Hive.box<Estimation>('estimations');
    box.add(newEstimation);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Estimation duplicated'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteEstimation(BuildContext context, Estimation estimation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Estimation'),
        content: Text('Are you sure you want to delete "${estimation.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              estimation.delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Estimation deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _viewEstimationDetails(BuildContext context, Estimation estimation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewEstimationScreen(
          existingEstimation: estimation,
          readOnly: true,
        ),
      ),
    );
  }

  void _reviseEstimation(BuildContext context, Estimation estimation) {
    // Get the next revision number
    final box = Hive.box<Estimation>('estimations');
    final relatedEstimations = box.values.where(
      (e) => e.estimationId == estimation.estimationId
    ).toList();
    
    final nextRevisionNumber = relatedEstimations.fold<int>(
      0,
      (maxRev, e) => e.revisionNumber > maxRev ? e.revisionNumber : maxRev
    ) + 1;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewEstimationScreen(
          existingEstimation: estimation,
          isRevision: true,
          revisionNumber: nextRevisionNumber,
        ),
      ),
    );
  }
}
