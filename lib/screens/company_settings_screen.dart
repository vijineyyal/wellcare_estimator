import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/company_settings.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyNameController;
  late TextEditingController _shortNameController;
  late TextEditingController _nextEstimationNumberController;
  bool _isEstimationSettingsExpanded = true;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController();
    _shortNameController = TextEditingController();
    _nextEstimationNumberController = TextEditingController();
    _loadSettings();
  }

  void _loadSettings() {
    final settingsBox = Hive.box<CompanySettings>('company_settings');
    if (settingsBox.isNotEmpty) {
      final settings = settingsBox.values.first;
      _companyNameController.text = settings.companyName;
      _shortNameController.text = settings.shortName;
      _nextEstimationNumberController.text = 
          (settings.lastEstimationNumber + 1).toString().padLeft(4, '0');
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _shortNameController.dispose();
    _nextEstimationNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Company Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _companyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Please enter company name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _shortNameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Short Name (max 4 characters)',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 4,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter short name';
                          }
                          if (value!.length > 4) {
                            return 'Maximum 4 characters allowed';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ExpansionTile(
                  title: const Text(
                    'Estimation Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  initiallyExpanded: _isEstimationSettingsExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _isEstimationSettingsExpanded = expanded;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _nextEstimationNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Next Estimation Number',
                          border: OutlineInputBorder(),
                          helperText: 'Enter a 4-digit number',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter estimation number';
                          }
                          final number = int.tryParse(value!);
                          if (number == null) {
                            return 'Please enter a valid number';
                          }
                          if (value.length != 4) {
                            return 'Please enter a 4-digit number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Save Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    if (_formKey.currentState?.validate() ?? false) {
      final settingsBox = Hive.box<CompanySettings>('company_settings');
      final nextNumber = int.parse(_nextEstimationNumberController.text);

      if (settingsBox.isEmpty) {
        // Create new settings
        final settings = CompanySettings(
          companyName: _companyNameController.text,
          shortName: _shortNameController.text.toUpperCase(),
          lastEstimationNumber: nextNumber - 1,  // Set directly instead of using setNextEstimationNumber
        );
        settingsBox.add(settings);
      } else {
        // Update existing settings
        final existingSettings = settingsBox.values.first;
        existingSettings.companyName = _companyNameController.text;
        existingSettings.shortName = _shortNameController.text.toUpperCase();
        existingSettings.lastEstimationNumber = nextNumber - 1;  // Set directly
        existingSettings.save();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    }
  }
} 