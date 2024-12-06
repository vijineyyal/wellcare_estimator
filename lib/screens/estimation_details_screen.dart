import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/estimation.dart';
import '../models/cost_component.dart';
import '../models/head.dart';
import '../models/setting_item.dart';

class EstimationDetailsScreen extends StatelessWidget {
  final Estimation estimation;

  const EstimationDetailsScreen({
    super.key,
    required this.estimation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(estimation.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicDetails(),
            const SizedBox(height: 16),
            _buildComponentsByHead(),
            const SizedBox(height: 16),
            if (estimation.profitMargin != null) _buildProfitSection(),
            if (estimation.taxRate != null) _buildTaxSection(),
            const SizedBox(height: 16),
            _buildTotalSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Name: ${estimation.name}'),
            Text('Created: ${estimation.createdAt.toString()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentsByHead() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Head>('heads').listenable(),
      builder: (context, headBox, _) {
        final heads = headBox.values.toList();
        
        return Column(
          children: heads.map((head) {
            final headComponents = _getComponentsForHead(head.id);
            if (headComponents.isEmpty) return const SizedBox.shrink();

            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      head.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: headComponents.length,
                    itemBuilder: (context, index) {
                      final component = headComponents[index];
                      final amount = estimation.components[component.id] ?? 0.0;
                      return ListTile(
                        title: Text(component.name),
                        subtitle: Text(
                          component.unitPrice != null
                              ? '₹${component.unitPrice} per ${component.unit}'
                              : component.unit,
                        ),
                        trailing: Text(
                          '₹${amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  List<CostComponent> _getComponentsForHead(String headId) {
    final componentsBox = Hive.box<CostComponent>('components');
    return componentsBox.values
        .where((component) => 
            component.headId == headId && 
            estimation.components.containsKey(component.id))
        .toList();
  }

  Widget _buildProfitSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profit Margins',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Amount: ₹${estimation.profitMargin?.toStringAsFixed(2) ?? "0.00"}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tax',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Amount: ₹${estimation.taxRate?.toStringAsFixed(2) ?? "0.00"}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total:'),
                Text(
                  '₹${estimation.totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 