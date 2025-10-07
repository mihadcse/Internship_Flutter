import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _newCategoryController = TextEditingController();
  final _detailsController = TextEditingController();
  File? _imageFile;
  Uint8List? _webImage;
  String? _fileName;
  bool _isLoading = false;

  final SupabaseClient supabase = Supabase.instance.client;

  List<String> _categories = [
    'Electronics',
    'Mobile Phones',
    'Laptops & Computers',
    'Clothing & Fashion',
    'Men\'s Wear',
    'Women\'s Wear',
    'Food & Beverages',
    'Books & Stationery',
    'Home & Furniture',
    'Kitchen Appliances',
    'Sports & Fitness',
    'Toys & Games',
    'Beauty & Personal Care',
    'Automotive',
    'Health & Wellness',
    'Jewelry & Accessories',
    'Pet Supplies',
    'Office Supplies',
    'Other',
  ];

  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  // Show dialog to add new category
  Future<void> _showAddCategoryDialog() async {
    _newCategoryController.clear();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: _newCategoryController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
              hintText: 'Enter category name',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newCategory = _newCategoryController.text.trim();
                if (newCategory.isNotEmpty &&
                    !_categories.contains(newCategory)) {
                  setState(() {
                    _categories.add(newCategory);
                    _categories.sort();
                    _selectedCategory = newCategory;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Category "$newCategory" added')),
                  );
                } else if (_categories.contains(newCategory)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category already exists')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (kIsWeb) {
          // ✅ FIX: Web image preview now works because we store image bytes here
          setState(() {
            _webImage = file.bytes;
            _fileName = file.name;
          });
        } else {
          if (file.path != null) {
            setState(() {
              _imageFile = File(file.path!);
              _fileName = file.name;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  // Upload product
  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_webImage == null && _imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception("You must be signed in to upload images");
      }

      // Prepare file bytes and filename
      Uint8List fileBytes;
      String fileName;
      String contentType = 'image/jpeg'; // default

      if (kIsWeb) {
        fileBytes = _webImage!;
        fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${Uri.encodeComponent(_fileName!)}';

        // Detect content type
        if (_fileName!.toLowerCase().endsWith('.png'))
          contentType = 'image/png';
        if (_fileName!.toLowerCase().endsWith('.gif'))
          contentType = 'image/gif';
      } else {
        fileBytes = await _imageFile!.readAsBytes();
        final fileExt = _imageFile!.path.split('.').last.toLowerCase();
        fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        if (fileExt == 'png') contentType = 'image/png';
        if (fileExt == 'gif') contentType = 'image/gif';
      }

      final filePath =
          'uploads/${DateTime.now().millisecondsSinceEpoch}_${_fileName!.replaceAll(RegExp(r"[^a-zA-Z0-9._-]"), "_")}';

      // Upload for Web
      if (kIsWeb) {
        await supabase.storage
            .from('products')
            .uploadBinary(
              filePath,
              fileBytes,
              fileOptions: FileOptions(upsert: true, contentType: contentType),
            );
      } else {
        // Upload for Mobile/Desktop
        await supabase.storage
            .from('products')
            .upload(
              filePath,
              _imageFile!,
              fileOptions: const FileOptions(upsert: true),
            );
      }

      final imageUrl = supabase.storage.from('products').getPublicUrl(filePath);

      await supabase.from('products').insert({
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'image_url': imageUrl,
        'product_category': _selectedCategory,
        'product_details': _detailsController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Product added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        _formKey.currentState!.reset();
        _nameController.clear();
        _priceController.clear();
        setState(() {
          _imageFile = null;
          _webImage = null;
          _fileName = null;
          _selectedCategory = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to add product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ... rest of your imports and class definition remain unchanged

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product'), elevation: 2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Price Field
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter price';
                    }
                    final price = double.tryParse(value.trim());
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ✅ ADDED: Product Details Field
                TextFormField(
                  controller: _detailsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Product Details',
                    border: OutlineInputBorder(),
                    hintText: 'Enter product description/details',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter product details';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category Dropdown (unchanged)
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _showAddCategoryDialog,
                      icon: const Icon(Icons.add),
                      tooltip: 'Add new category',
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Image Preview (unchanged)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _webImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(_webImage!, fit: BoxFit.cover),
                        )
                      : _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'No image selected',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Select Image Button (unchanged)
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Select Image'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),

                // Add Product Button (unchanged)
                ElevatedButton(
                  onPressed: _isLoading ? null : _addProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Add Product',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
