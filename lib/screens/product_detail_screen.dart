import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  void _checkIfFavorite() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final favDoc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(widget.productId)
        .get();

    setState(() {
      _isFavorite = favDoc.exists;
    });
  }

  void _toggleFavorite() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final favRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(widget.productId);

    if (_isFavorite) {
      await favRef.delete();
      setState(() => _isFavorite = false);
    } else {
      await favRef.set({'addedAt': FieldValue.serverTimestamp()});
      setState(() => _isFavorite = true);
    }
  }

  void _addToCart() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final cartRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(widget.productId);

    final product = widget.productData;

    final snapshot = await cartRef.get();
    if (snapshot.exists) {
      await cartRef.update({'quantity': FieldValue.increment(1)});
    } else {
      await cartRef.set({
        'name': product['name'],
        'price': product['price'],
        'imageUrl': product['imageUrl'],
        'quantity': 1,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sepete eklendi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.productData;

    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Image.network(
            product['imageUrl'],
            height: 200,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 16),
          Text(
            product['name'],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '${product['price']} ₺',
            style: TextStyle(fontSize: 18, color: Colors.green[700]),
          ),
          SizedBox(height: 16),
          Text(
            product['description'],
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _addToCart,
            child: Text('Sepete Ekle'),
          ),
        ],
      ),
    );
  }
}
