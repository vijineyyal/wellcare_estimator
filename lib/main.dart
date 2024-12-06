import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cost_component.dart';
import 'models/estimation.dart';
import 'models/head.dart';
import 'models/setting_item.dart';
import 'screens/manage_components_screen.dart';
import 'screens/new_estimation_screen.dart';
import 'screens/manage_heads_screen.dart';
import 'screens/inventory_items_screen.dart';
import 'screens/settings_screen.dart';
import 'models/unit.dart';
import 'screens/manage_units_screen.dart';
import 'screens/saved_estimations_screen.dart';
import 'models/company_settings.dart';
import 'screens/company_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(CostComponentAdapter());
  Hive.registerAdapter(EstimationAdapter());
  Hive.registerAdapter(HeadAdapter());
  Hive.registerAdapter(SettingItemAdapter());
  Hive.registerAdapter(UnitAdapter());
  Hive.registerAdapter(CompanySettingsAdapter());

  final unitsBox = await Hive.openBox<Unit>('units');

  if (unitsBox.isEmpty) {
    final defaultUnits = [
      Unit(id: '1', name: 'Kilogram (Kg)', category: 'Weight'),
      Unit(id: '2', name: 'Gram (g)', category: 'Weight'),
      Unit(id: '3', name: 'Pound (lb)', category: 'Weight'),
      
      Unit(id: '4', name: 'Meter (m)', category: 'Length'),
      Unit(id: '5', name: 'Centimeter (cm)', category: 'Length'),
      Unit(id: '6', name: 'Inch (in)', category: 'Length'),
      
      Unit(id: '7', name: 'Liter (L)', category: 'Volume'),
      Unit(id: '8', name: 'Milliliter (ml)', category: 'Volume'),
      Unit(id: '9', name: 'Gallon (gal)', category: 'Volume'),
      
      Unit(id: '10', name: 'Square Meter (m²)', category: 'Area'),
      Unit(id: '11', name: 'Square Foot (ft²)', category: 'Area'),
      
      Unit(id: '12', name: 'Hour (hr)', category: 'Time'),
      Unit(id: '13', name: 'Minute (min)', category: 'Time'),
      Unit(id: '14', name: 'Second (sec)', category: 'Time'),
      Unit(id: '15', name: 'Day', category: 'Time'),
      Unit(id: '16', name: 'Week', category: 'Time'),
      Unit(id: '17', name: 'Month', category: 'Time'),
      
      Unit(id: '18', name: 'Piece (Pc)', category: 'Quantity'),
      Unit(id: '19', name: 'Box', category: 'Quantity'),
      Unit(id: '20', name: 'Pack', category: 'Quantity'),
      Unit(id: '21', name: 'Dozen', category: 'Quantity'),
    ];

    for (var unit in defaultUnits) {
      unitsBox.add(unit);
    }
  }

  await Hive.openBox<CostComponent>('components');
  await Hive.openBox<Estimation>('estimations');
  await Hive.openBox<Head>('heads');
  await Hive.openBox<SettingItem>('settings');
  await Hive.openBox<CompanySettings>('company_settings');

  runApp(const ProductionEstimatorApp());
}

class ProductionEstimatorApp extends StatelessWidget {
  const ProductionEstimatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Production Estimator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Estimator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuCard(
            'New Estimation',
            'Create a new production cost estimation',
            Icons.add_chart,
            () => _navigateToNewEstimation(),
          ),
          _buildMenuCard(
            'Saved Estimations',
            'View and manage saved estimations',
            Icons.history,
            () => _navigateToSavedEstimations(),
          ),
          _buildMenuCard(
            'Manage Heads',
            'Manage cost heads like Raw Materials, Consumables, etc.',
            Icons.category,
            () => _navigateToManageHeads(),
          ),
          _buildMenuCard(
            'Inventory Items',
            'Manage inventory items under different heads',
            Icons.inventory,
            () => _navigateToInventoryItems(),
          ),
          _buildMenuCard(
            'Settings',
            'Configure tax rates and other settings',
            Icons.settings,
            () => _navigateToSettings(),
          ),
          _buildMenuCard(
            'Manage Units',
            'Configure measurement units',
            Icons.straighten,
            () => _navigateToManageUnits(),
          ),
          _buildMenuCard(
            'Company Settings',
            'Configure company details',
            Icons.business,
            () => _navigateToCompanySettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _navigateToNewEstimation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewEstimationScreen(),
      ),
    );
  }

  void _navigateToSavedEstimations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedEstimationsScreen(),
      ),
    );
  }

  void _navigateToManageComponents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManageComponentsScreen(),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _navigateToManageHeads() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManageHeadsScreen(),
      ),
    );
  }

  void _navigateToInventoryItems() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InventoryItemsScreen(),
      ),
    );
  }

  void _navigateToManageUnits() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManageUnitsScreen(),
      ),
    );
  }

  void _navigateToCompanySettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CompanySettingsScreen(),
      ),
    );
  }
}
