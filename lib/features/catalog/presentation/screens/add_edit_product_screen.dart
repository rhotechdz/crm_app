import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:talabati/theme/talabati_theme.dart';
import 'package:talabati/features/catalog/data/models/product.dart';
import 'package:talabati/features/catalog/data/models/product_variant.dart';
import 'package:talabati/features/catalog/presentation/providers/products_provider.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _costPriceController;
  late TextEditingController _stockQuantityController;

  final List<VariantControllerGroup> _variantControllers = [];
  final List<String> _variantsToDelete = [];
  
  String? _imagePath;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _descriptionController = TextEditingController(text: widget.product?.description);
    _sellingPriceController =
        TextEditingController(text: widget.product?.sellingPrice.toString());
    _costPriceController =
        TextEditingController(text: widget.product?.costPrice.toString());
    _stockQuantityController =
        TextEditingController(text: widget.product?.stockQuantity?.toString());
    _imagePath = widget.product?.imageUrl;

    if (widget.product != null) {
      for (var variant in widget.product!.variants) {
        _variantControllers.add(VariantControllerGroup(
          id: variant.id,
          labelController: TextEditingController(text: variant.label),
          priceController:
              TextEditingController(text: variant.additionalPrice.toString()),
          stockController:
              TextEditingController(text: variant.stockQuantity?.toString()),
        ));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _stockQuantityController.dispose();
    for (var group in _variantControllers) {
      group.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _saveImageLocally(String tempPath) async {
    // If it's already in our documents directory, don't copy again
    final appDir = await getApplicationDocumentsDirectory();
    if (tempPath.startsWith(appDir.path)) {
      return tempPath;
    }

    final String extension = path.extension(tempPath);
    final String fileName = '${const Uuid().v4()}$extension';
    final String savedPath = path.join(appDir.path, fileName);

    final File tempFile = File(tempPath);
    await tempFile.copy(savedPath);
    return savedPath;
  }

  Future<void> _deleteOldImage(String? oldPath) async {
    if (oldPath != null) {
      final file = File(oldPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  void _addVariant() {
    setState(() {
      _variantControllers.add(VariantControllerGroup(
        id: const Uuid().v4(),
        labelController: TextEditingController(),
        priceController: TextEditingController(text: '0'),
        stockController: TextEditingController(),
      ));
    });
  }

  void _removeVariant(int index) {
    setState(() {
      final removed = _variantControllers.removeAt(index);
      if (widget.product != null) {
        _variantsToDelete.add(removed.id);
      }
      removed.dispose();
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      String? finalImagePath = _imagePath;
      
      // Handle image changes
      if (_imagePath != widget.product?.imageUrl) {
        // If image was removed or changed, delete the old one from disk
        if (widget.product?.imageUrl != null) {
          await _deleteOldImage(widget.product!.imageUrl);
        }
        
        // If a new image was picked, save it locally
        if (_imagePath != null) {
          finalImagePath = await _saveImageLocally(_imagePath!);
        }
      }

      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        sellingPrice: double.parse(_sellingPriceController.text),
        costPrice: double.parse(_costPriceController.text),
        stockQuantity: int.tryParse(_stockQuantityController.text),
        imageUrl: finalImagePath,
        variants: _variantControllers.map((group) {
          return ProductVariant(
            id: group.id,
            label: group.labelController.text.trim(),
            additionalPrice: double.tryParse(group.priceController.text) ?? 0,
            stockQuantity: int.tryParse(group.stockController.text),
          );
        }).toList(),
        createdAt: widget.product?.createdAt,
      );

      if (widget.product == null) {
        await ref.read(productsProvider.notifier).addProduct(product);
      } else {
        await ref
            .read(productsProvider.notifier)
            .updateProduct(product, _variantsToDelete);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker Widget
              GestureDetector(
                onTap: _showPickerOptions,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: _imagePath == null
                        ? Border.all(
                            color: Colors.grey[400]!,
                            style: BorderStyle.solid,
                          )
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _imagePath != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _imagePath = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: _showPickerOptions,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('Add Photo',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Selling Price*',
                        border: OutlineInputBorder(),
                        suffixText: 'DA',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          double.tryParse(value ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _costPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Cost Price*',
                        border: OutlineInputBorder(),
                        suffixText: 'DA',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          double.tryParse(value ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity (optional)',
                  hintText: 'Unlimited if empty',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Variants',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addVariant,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Variant'),
                  ),
                ],
              ),
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _variantControllers.length,
                itemBuilder: (context, index) {
                  final group = _variantControllers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: group.labelController,
                                  decoration: const InputDecoration(
                                    labelText: 'Label*',
                                    hintText: 'e.g. Red / XL',
                                  ),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'Required'
                                          : null,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _removeVariant(index),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: group.priceController,
                                  decoration: const InputDecoration(
                                    labelText: '+ Price',
                                    suffixText: 'DA',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: group.stockController,
                                  decoration: const InputDecoration(
                                    labelText: 'Stock',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TalabatiColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: TalabatiRadius.buttonRadius,
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(isEditing ? 'Update Product' : 'Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VariantControllerGroup {
  final String id;
  final TextEditingController labelController;
  final TextEditingController priceController;
  final TextEditingController stockController;

  VariantControllerGroup({
    required this.id,
    required this.labelController,
    required this.priceController,
    required this.stockController,
  });

  void dispose() {
    labelController.dispose();
    priceController.dispose();
    stockController.dispose();
  }
}
