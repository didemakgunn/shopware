import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? existingData;

  const ProductFormScreen({
    super.key,
    this.productId,
    this.existingData,
  });

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.existingData?['name'] ?? '');
    _descController =
        TextEditingController(text: widget.existingData?['description'] ?? '');
    _priceController = TextEditingController(
        text: widget.existingData?['price']?.toString() ?? '');
    _imageUrlController =
        TextEditingController(text: widget.existingData?['imageUrl'] ?? '');
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final productData = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0,
      'imageUrl': _imageUrlController.text.trim(),
    };

    if (widget.productId != null) {
      // güncelle
      await _firestore
          .collection('products')
          .doc(widget.productId)
          .update(productData);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ürün güncellendi')));
    } else {
      // yeni ürün ekle
      await _firestore.collection('products').add(productData);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ürün eklendi')));
    }

    Navigator.pop(context); // geri dön
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Ürün Düzenle' : 'Yeni Ürün Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Ürün Adı'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Gerekli' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Açıklama'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Gerekli' : null,
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Fiyat'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Gerekli' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Resim URL’si'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Gerekli' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(isEditing ? 'Güncelle' : 'Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
