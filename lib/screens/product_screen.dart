import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Set<String> _favoriteProductIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();

    setState(() {
      _favoriteProductIds = snapshot.docs.map((doc) => doc.id).toSet();
    });
  }

  void _toggleFavorite(String productId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final favRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId);

    if (_favoriteProductIds.contains(productId)) {
      await favRef.delete();
      setState(() {
        _favoriteProductIds.remove(productId);
      });
    } else {
      await favRef.set({'addedAt': FieldValue.serverTimestamp()});
      setState(() {
        _favoriteProductIds.add(productId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ürünler')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final productId = doc.id;
              final isFav = _favoriteProductIds.contains(productId);

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading:
                      Image.network(data['imageUrl'], width: 50, height: 50),
                  title: Text(data['name']),
                  subtitle: Text('${data['price']} ₺'),
                  trailing: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : null,
                    ),
                    onPressed: () => _toggleFavorite(productId),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          productId: productId,
                          productData: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
