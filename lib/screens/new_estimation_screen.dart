import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cost_component.dart';
import '../models/estimation.dart';
import '../models/head.dart';
import '../models/setting_item.dart';
import '../models/unit.dart';
import '../models/company_settings.dart';

class NewEstimationScreen extends StatefulWidget {
  final Estimation? existingEstimation;
  final bool readOnly;
  final bool isRevision;
  final int revisionNumber;

  const NewEstimationScreen({
    super.key,
    this.existingEstimation,
    this.readOnly = false,
    this.isRevision = false,
    this.revisionNumber = 0,
  });

  @override
  State<NewEstimationScreen> createState() => _NewEstimationScreenState();
}

// Add this class to manage the state of each input card
class ItemInputCard {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String selectedUnit;
  final Function() onAmountChanged;
  final String headCategory;

  ItemInputCard(this.selectedUnit, this.onAmountChanged, this.headCategory) {
    // Add listeners to controllers
    nameController.addListener(() {
      onAmountChanged();
      // Calculate amount if unit price and quantity exist
      if (nameController.text.isNotEmpty) {
        final unitPrice = double.tryParse(unitPriceController.text);
        final qty = double.tryParse(qtyController.text);
        if (unitPrice != null && qty != null) {
          final calculatedAmount = (unitPrice * qty).toString();
          if (amountController.text != calculatedAmount) {
            amountController.text = calculatedAmount;
          }
        }
      }
    });

    amountController.addListener(() {
      onAmountChanged();
    });

    unitPriceController.addListener(_calculateAmount);
    qtyController.addListener(_calculateAmount);
  }

  void dispose() {
    nameController.dispose();
    unitPriceController.dispose();
    qtyController.dispose();
    amountController.dispose();
  }

  void _calculateAmount() {
    if (nameController.text.isEmpty) return;

    final qty = double.tryParse(qtyController.text) ?? 1.0;
    final unitPrice = double.tryParse(unitPriceController.text);

    if (unitPrice != null) {
      final newAmount = (qty * unitPrice).toString();
      if (amountController.text != newAmount) {
        amountController.text = newAmount;
      }
    }
  }

  void calculateAmount() => _calculateAmount();

  List<Unit> getUnits() {
    final unitsBox = Hive.box<Unit>('units');
    // Get all enabled units regardless of category
    return unitsBox.values
        .where((unit) => unit.enabled)
        .toList();
  }

  // Add helper method to get short form of unit name
  String getShortUnitName(String fullName) {
    // Extract text within parentheses if exists
    final regExp = RegExp(r'\((.*?)\)');
    final match = regExp.firstMatch(fullName);
    if (match != null) {
      return match.group(1) ?? fullName;
    }
    // If no parentheses, return first word
    return fullName.split(' ').first;
  }
}

class _NewEstimationScreenState extends State<NewEstimationScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, double> _selectedComponents = {};
  final Map<String, double> _quantities = {};
  final Map<String, double> _overheads = {};

  String _estimationName = '';
  double _taxRate = 0.0;
  double _profitMargin = 0.0;
  String _selectedUnit = 'Kg';

  final List<String> _units = ['Kg', 'g', 'L', 'ml', 'Pc', 'Box', 'Pack'];
  final List<String> categories = [
    'Raw Materials',
    'Consumables',
    'Packaging',
    'Labor',
    'Overhead',
  ];

  TextEditingController? _searchController;
  List<CostComponent> _suggestions = [];

  // Controllers for the search bar
  late TextEditingController _nameController;
  late TextEditingController _qtyController;
  late TextEditingController _unitPriceController;
  late TextEditingController _amountController;

  // Add this to store input cards for each head
  final Map<String, List<ItemInputCard>> _inputCards = {};

  late TextEditingController _productNameController;
  late TextEditingController _estimationNameController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.existingEstimation != null) {
      _prefillEstimation(widget.existingEstimation!);
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _qtyController = TextEditingController();
    _unitPriceController = TextEditingController();
    _amountController = TextEditingController();
    _productNameController = TextEditingController();
    _estimationNameController = TextEditingController();
  }

  void _prefillEstimation(Estimation estimation) {
    _estimationNameController.text = estimation.name;
    _productNameController.text = estimation.productName;
    
    // Prefill components from componentDetails
    estimation.componentDetails.forEach((componentId, details) {
      final headId = details['headId'] as String;
      _inputCards[headId] ??= [];
      
      final card = ItemInputCard(
        details['unit'] as String,
        () => setState(() {}),
        headId,
      );
      
      card.nameController.text = details['name'] as String;
      if (details['unitPrice'] != null) {
        card.unitPriceController.text = details['unitPrice'].toString();
      }
      card.qtyController.text = details['quantity'].toString();
      card.amountController.text = details['amount'].toString();
      
      _inputCards[headId]!.add(card);
    });

    // Prefill tax and profit settings
    final settingsBox = Hive.box<SettingItem>('settings');
    
    // Enable and set values for tax heads
    for (var taxHead in estimation.enabledTaxHeads) {
      final setting = settingsBox.values.firstWhere(
        (item) => item.id == taxHead['id'],
        orElse: () => SettingItem(
          id: taxHead['id'],
          name: taxHead['name'],
          defaultValue: taxHead['value'],
          type: 'tax',
          isPercentage: taxHead['isPercentage'],
        ),
      );
      setting.enabled = true;
      setting.defaultValue = taxHead['value'];
      setting.save();
    }

    // Enable and set values for profit margins
    for (var profitMargin in estimation.enabledProfitMargins) {
      final setting = settingsBox.values.firstWhere(
        (item) => item.id == profitMargin['id'],
        orElse: () => SettingItem(
          id: profitMargin['id'],
          name: profitMargin['name'],
          defaultValue: profitMargin['value'],
          type: 'profit',
          isPercentage: profitMargin['isPercentage'],
        ),
      );
      setting.enabled = true;
      setting.defaultValue = profitMargin['value'];
      setting.save();
    }

    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _unitPriceController.dispose();
    _amountController.dispose();
    _productNameController.dispose();
    _estimationNameController.dispose();
    // Dispose all input cards
    for (var cards in _inputCards.values) {
      for (var card in cards) {
        card.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingEstimation != null ? 
            (widget.readOnly ? 'View Estimation' : 'Revise Estimation') 
            : 'New Estimation'),
        actions: [
          if (!widget.readOnly)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveEstimation,
            ),
        ],
      ),
      body: Container(
        color: Colors.grey[100], // Light background color
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildBasicDetails(),
              const SizedBox(height: 16),
              _buildHeadSections(),
              const SizedBox(height: 16),
              _buildTaxAndProfitSection(),
              const SizedBox(height: 16),
              _buildTotalSection(),
              const SizedBox(height: 32), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: Hive.box<CompanySettings>('company_settings').listenable(),
              builder: (context, box, _) {
                final settings = box.isEmpty ? null : box.values.first;
                final estimationId = widget.existingEstimation?.estimationId ?? 
                    (settings?.getEstimationId() ?? 'EST-0001');
                
                return TextFormField(
                  initialValue: estimationId,
                  decoration: const InputDecoration(
                    labelText: 'Estimation ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  readOnly: true,
                  enabled: false,
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _estimationNameController,
              decoration: const InputDecoration(
                labelText: 'Estimation Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a name' : null,
              readOnly: widget.readOnly,
              enabled: !widget.readOnly,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
              ),
              readOnly: widget.readOnly,
              enabled: !widget.readOnly,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadSections() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Head>('heads').listenable(),
      builder: (context, headBox, _) {
        final heads = headBox.values.where((head) => head.enabled).toList();

        return Column(
          children: heads
              .map((head) => Column(
                    children: [
                      _buildHeadSection(head),
                      const SizedBox(height: 16),
                    ],
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildHeadSection(Head head) {
    // Initialize input cards list for this head if not exists
    _inputCards[head.id] ??= [
      ItemInputCard(
        _getDefaultUnit(),
        () => setState(() {}),
        head.name,
      )
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  head.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!widget.readOnly)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        _inputCards[head.id]!.add(ItemInputCard(
                          _getDefaultUnit(),
                          () => setState(() {}),
                          head.name,
                        ));
                      });
                    },
                  ),
              ],
            ),
          ),
          ..._inputCards[head.id]!
              .map((card) => _buildInputCard(head, card))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildInputCard(Head head, ItemInputCard card) {
    final units = card.getUnits();
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: card.nameController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Type ${head.name}*',
                        labelStyle: const TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      readOnly: widget.readOnly,
                      enabled: !widget.readOnly,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: card.selectedUnit,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        labelStyle: const TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        border: const OutlineInputBorder(),
                        enabled: !widget.readOnly,
                        fillColor: widget.readOnly ? Colors.grey[200] : Colors.white,
                        filled: true,
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                      ),
                      items: units.map((unit) => DropdownMenuItem(
                        value: unit.name,
                        child: Text(
                          card.getShortUnitName(unit.name),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      )).toList(),
                      onChanged: widget.readOnly ? null : (value) {
                        setState(() {
                          card.selectedUnit = value!;
                        });
                      },
                      dropdownColor: widget.readOnly ? Colors.grey[200] : Colors.white,
                      iconDisabledColor: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: card.unitPriceController,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Unit Price',
                        labelStyle: TextStyle(fontSize: 12),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        prefixText: '₹',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: widget.readOnly,
                      enabled: !widget.readOnly,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: card.qtyController,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Qty',
                        labelStyle: TextStyle(fontSize: 12),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: widget.readOnly,
                      enabled: !widget.readOnly,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: card.amountController,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        labelStyle: TextStyle(fontSize: 12),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        prefixText: '₹',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: widget.readOnly,
                      enabled: !widget.readOnly,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(Head head) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: _suggestions
            .map(
              (component) => ListTile(
                title: Text(component.name),
                subtitle: Text(
                  component.unitPrice != null
                      ? '₹${component.unitPrice} per ${component.unit}'
                      : component.unit,
                ),
                trailing: const Icon(Icons.add),
                onTap: () {
                  setState(() {
                    if (component.unitPrice != null) {
                      _selectedComponents[component.id] = component.unitPrice!;
                      _quantities[component.id] = 1.0;
                    }
                    _nameController.clear();
                    _suggestions.clear();
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }

  void _updateSuggestions(String query, String headId) {
    if (query.isEmpty) {
      setState(() {
        _suggestions.clear();
      });
      return;
    }

    final componentBox = Hive.box<CostComponent>('components');
    final suggestions = componentBox.values
        .where((component) =>
            component.headId == headId &&
            component.name.toLowerCase().contains(query.toLowerCase()) &&
            !_quantities.containsKey(component.id))
        .toList();

    setState(() {
      _suggestions = suggestions;
    });
  }

  Future<void> _showAddItemDialog(BuildContext context, Head head) async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    double? unitPrice;
    String selectedUnit = head.name == 'Raw Materials' ? 'Kg' : 'Pc';

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add New ${head.name} Item'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                            child: Text(
                              unit,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedUnit = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Add to Inventory'),
                  value: true,
                  onChanged: (bool? value) {
                    setDialogState(() {
                      // You can use this value to decide whether to save to inventory
                    });
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

                  // Create the component
                  final component = CostComponent(
                    id: DateTime.now().toString(),
                    name: name,
                    headId: head.id,
                    unitPrice: unitPrice,
                    unit: selectedUnit,
                  );

                  // Add to inventory if checkbox is checked
                  final box = Hive.box<CostComponent>('components');
                  box.add(component);

                  // Add to current estimation
                  setState(() {
                    if (unitPrice != null) {
                      _selectedComponents[component.id] = unitPrice ?? 0.0;
                      _quantities[component.id] = 1.0; // Default quantity
                    }
                  });

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

  Future<void> _showQuickAddWithQuantityDialog(
    BuildContext context,
    Head head,
    String itemName,
  ) async {
    final formKey = GlobalKey<FormState>();
    double? unitPrice;
    double quantity = 1.0;
    String selectedUnit = head.name == 'Raw Materials' ? 'Kg' : 'Pc';
    bool addToInventory = false;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add ${head.name} Item'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  itemName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: quantity.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (double.tryParse(value!) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                        onSaved: (value) => quantity = double.parse(value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
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
                          setDialogState(() {
                            selectedUnit = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Unit Price (Optional)',
                    border: OutlineInputBorder(),
                    prefixText: '₹',
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
                CheckboxListTile(
                  title: const Text('Add to Inventory'),
                  subtitle: const Text('Save for future use'),
                  value: addToInventory,
                  onChanged: (value) {
                    setDialogState(() {
                      addToInventory = value!;
                    });
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

                  final component = CostComponent(
                    id: DateTime.now().toString(),
                    name: itemName,
                    headId: head.id,
                    unitPrice: unitPrice,
                    unit: selectedUnit,
                  );

                  // Add to inventory if checkbox is checked
                  if (addToInventory) {
                    final box = Hive.box<CostComponent>('components');
                    box.add(component);
                  }

                  // Add to current estimation
                  setState(() {
                    if (unitPrice != null) {
                      _selectedComponents[component.id] = unitPrice ?? 0.0;
                      _quantities[component.id] = quantity;
                    }
                    _nameController.clear();
                    _suggestions.clear();
                  });

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

  Widget _buildTaxAndProfitSection() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<SettingItem>('settings').listenable(),
      builder: (context, box, _) {
        final profitItems =
            box.values.where((item) => item.type == 'profit').toList();
        final taxItems =
            box.values.where((item) => item.type == 'tax').toList();

        if (taxItems.isEmpty && profitItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (profitItems.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.trending_up),
                      SizedBox(width: 8),
                      Text(
                        'Profit Margins',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: profitItems
                        .map((item) => _buildSettingItem(item))
                        .toList(),
                  ),
                ),
              ],
              if (taxItems.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.receipt_long),
                      SizedBox(width: 8),
                      Text(
                        'Tax Heads',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: taxItems
                        .map((item) => _buildSettingItem(item))
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingItem(SettingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(item.name),
          ),
          Switch(
            value: item.enabled,
            onChanged: widget.readOnly ? null : (value) {
              setState(() {
                item.enabled = value;
                item.save();
              });
            },
          ),
          SizedBox(
            width: 100,
            child: TextFormField(
              initialValue: item.defaultValue.toString(),
              decoration: InputDecoration(
                labelText: item.isPercentage ? '%' : '₹',
                border: const OutlineInputBorder(),
                enabled: !widget.readOnly && item.enabled,  // Disable when read-only or item disabled
                fillColor: widget.readOnly ? Colors.grey[200] : Colors.white,  // Gray out when disabled
                filled: true,
              ),
              keyboardType: TextInputType.number,
              readOnly: widget.readOnly,
              onChanged: widget.readOnly ? null : (value) {
                final newValue = double.tryParse(value) ?? 0.0;
                if (item.type == 'tax') {
                  _taxRate = item.enabled ? newValue : 0.0;
                } else {
                  _profitMargin = item.enabled ? newValue : 0.0;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    final componentsTotal = _calculateComponentsTotal();
    final overheadsTotal = _calculateOverheadsTotal();
    final subtotal = componentsTotal + overheadsTotal;

    // Calculate profit first
    double profitAmount = 0.0;
    final settingsBox = Hive.box<SettingItem>('settings');
    final enabledProfitItems = settingsBox.values
        .where((item) => item.type == 'profit' && item.enabled)
        .toList();

    for (var item in enabledProfitItems) {
      if (item.isPercentage) {
        profitAmount += subtotal * (item.defaultValue / 100);
      } else {
        profitAmount += item.defaultValue;
      }
    }

    // Calculate tax on subtotal + profit
    final subtotalWithProfit = subtotal + profitAmount;
    double taxAmount = 0.0;
    final enabledTaxItems = settingsBox.values
        .where((item) => item.type == 'tax' && item.enabled)
        .toList();

    for (var item in enabledTaxItems) {
      if (item.isPercentage) {
        taxAmount += subtotalWithProfit * (item.defaultValue / 100);
      } else {
        taxAmount += item.defaultValue;
      }
    }

    final total = subtotalWithProfit + taxAmount;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Components Total:', componentsTotal),
            _buildSummaryRow('Overheads Total:', overheadsTotal),
            _buildSummaryRow('Subtotal:', subtotal),
            if (enabledProfitItems.isNotEmpty) ...[
              _buildSummaryRow('Profit Amount:', profitAmount),
              _buildSummaryRow('Subtotal with Profit:', subtotalWithProfit),
            ],
            if (enabledTaxItems.isNotEmpty)
              _buildSummaryRow('Tax Amount:', taxAmount),
            const Divider(thickness: 2),
            _buildSummaryRow(
              'Grand Total:',
              total,
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {TextStyle? textStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: textStyle,
          ),
        ],
      ),
    );
  }

  double _calculateComponentsTotal() {
    double total = 0.0;

    // Calculate total from existing components
    _selectedComponents.forEach((id, price) {
      total += price * (_quantities[id] ?? 0.0);
    });

    // Add totals from input cards
    for (var cardsList in _inputCards.values) {
      for (var card in cardsList) {
        // Only include items that have a name
        if (card.nameController.text.isNotEmpty) {
          // If amount is empty but unit price and quantity exist, calculate it
          if (card.amountController.text.isEmpty) {
            final unitPrice =
                double.tryParse(card.unitPriceController.text) ?? 0.0;
            final quantity = double.tryParse(card.qtyController.text) ?? 1.0;
            final calculatedAmount = unitPrice * quantity;

            // Update the amount controller
            if (calculatedAmount > 0) {
              card.amountController.text = calculatedAmount.toString();
            }
          }

          // Now get the amount (either entered or calculated)
          final amount = double.tryParse(card.amountController.text) ?? 0.0;
          total += amount;
        }
      }
    }

    return total;
  }

  double _calculateOverheadsTotal() {
    return _overheads.values.fold(0.0, (sum, amount) => sum + amount);
  }

  void _saveEstimation() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Get company settings and increment estimation number when saving
      final companySettingsBox = Hive.box<CompanySettings>('company_settings');
      final companySettings = companySettingsBox.isEmpty ? null : companySettingsBox.values.first;
      final estimationId = widget.existingEstimation?.estimationId ?? 
          (companySettings?.getEstimationId() ?? 'EST-0001');

      // Collect all component details
      final Map<String, Map<String, dynamic>> componentDetails = {};
      final Map<String, double> components = {};
      final Map<String, double> quantities = {};

      // Collect from input cards
      for (var entry in _inputCards.entries) {
        for (var card in entry.value) {
          if (card.nameController.text.isNotEmpty) {
            final componentId = DateTime.now().toString();
            
            // Save component details
            componentDetails[componentId] = {
              'name': card.nameController.text,
              'unit': card.selectedUnit,
              'unitPrice': double.tryParse(card.unitPriceController.text),
              'quantity': double.tryParse(card.qtyController.text) ?? 1.0,
              'amount': double.tryParse(card.amountController.text) ?? 0.0,
              'headId': entry.key,
            };

            // Save components and quantities
            components[componentId] = double.tryParse(card.amountController.text) ?? 0.0;
            quantities[componentId] = double.tryParse(card.qtyController.text) ?? 1.0;
          }
        }
      }

      // Calculate totals
      final componentsTotal = _calculateComponentsTotal();
      final overheadsTotal = _calculateOverheadsTotal();
      final subtotal = componentsTotal + overheadsTotal;

      // Collect enabled tax heads with their values
      final taxSettingsBox = Hive.box<SettingItem>('settings');
      final enabledTaxHeads = taxSettingsBox.values
          .where((item) => item.type == 'tax' && item.enabled)
          .map((item) => {
                'id': item.id,
                'name': item.name,
                'value': item.defaultValue,
                'isPercentage': item.isPercentage,
              })
          .toList();

      // Collect enabled profit margins with their values
      final enabledProfitMargins = taxSettingsBox.values
          .where((item) => item.type == 'profit' && item.enabled)
          .map((item) => {
                'id': item.id,
                'name': item.name,
                'value': item.defaultValue,
                'isPercentage': item.isPercentage,
              })
          .toList();

      // Calculate profit
      double profitAmount = 0.0;
      for (var item in enabledProfitMargins) {
        if (item['isPercentage'] as bool) {
          profitAmount += subtotal * ((item['value'] as num).toDouble() / 100);
        } else {
          profitAmount += (item['value'] as num).toDouble();
        }
      }

      // Calculate tax on subtotal + profit
      final subtotalWithProfit = subtotal + profitAmount;
      double taxAmount = 0.0;
      for (var item in enabledTaxHeads) {
        if (item['isPercentage'] as bool) {
          taxAmount += subtotalWithProfit * ((item['value'] as num).toDouble() / 100);
        } else {
          taxAmount += (item['value'] as num).toDouble();
        }
      }

      // Create and save estimation
      final estimation = Estimation(
        id: DateTime.now().toString(),
        name: _estimationNameController.text,
        productName: _productNameController.text,
        createdAt: DateTime.now(),
        components: components,
        quantities: quantities,
        componentDetails: componentDetails,
        enabledTaxHeads: enabledTaxHeads,
        enabledProfitMargins: enabledProfitMargins,
        taxRate: taxAmount > 0 ? taxAmount : null,
        profitMargin: profitAmount > 0 ? profitAmount : null,
        overheads: _overheads,
        totalCost: subtotalWithProfit + taxAmount,
        estimationId: widget.existingEstimation?.estimationId ?? estimationId,
        revisionNumber: widget.isRevision ? widget.revisionNumber : 0,
      );

      final box = Hive.box<Estimation>('estimations');
      box.add(estimation);

      // Increment estimation number
      companySettings?.incrementEstimationNumber();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estimation saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  Future<void> _showAddToInventoryDialog(
    BuildContext context,
    Head head,
    String itemName,
  ) async {
    final formKey = GlobalKey<FormState>();
    double? unitPrice;
    String selectedUnit = _selectedUnit;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add ${head.name} Item to Inventory'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  itemName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Unit Price (Optional)',
                    border: OutlineInputBorder(),
                    prefixText: '₹',
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
                    setDialogState(() {
                      selectedUnit = value!;
                    });
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

                  // Create and save the component
                  final component = CostComponent(
                    id: DateTime.now().toString(),
                    name: itemName,
                    headId: head.id,
                    unitPrice: unitPrice,
                    unit: selectedUnit,
                  );

                  final box = Hive.box<CostComponent>('components');
                  box.add(component);

                  // Clear search
                  _nameController.clear();
                  _suggestions.clear();

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

  void _addItemToEstimation(
    Head head,
    String name,
    double? unitPrice,
    double quantity,
    double amount,
  ) {
    final component = CostComponent(
      id: DateTime.now().toString(),
      name: name,
      headId: head.id,
      unitPrice: unitPrice,
      unit: _selectedUnit,
    );

    setState(() {
      _selectedComponents[component.id] = amount;
      _quantities[component.id] = quantity;
    });
  }

  // Add this method to save all input card values when saving the estimation
  void _collectInputCardValues() {
    for (var entry in _inputCards.entries) {
      for (var card in entry.value) {
        if (card.nameController.text.isNotEmpty &&
            card.amountController.text.isNotEmpty) {
          final component = CostComponent(
            id: DateTime.now().toString(),
            name: card.nameController.text,
            headId: entry.key,
            unitPrice: double.tryParse(card.unitPriceController.text),
            unit: card.selectedUnit,
          );

          final amount = double.tryParse(card.amountController.text) ?? 0.0;
          final quantity = double.tryParse(card.qtyController.text) ?? 1.0;

          _selectedComponents[component.id] = amount;
          _quantities[component.id] = quantity;
        }
      }
    }
  }

  String _getDefaultUnit() {
    final unitsBox = Hive.box<Unit>('units');
    final units = unitsBox.values
        .where((unit) => unit.enabled)
        .toList();
    
    return units.isNotEmpty ? units.first.name : 'Pc';
  }
}
