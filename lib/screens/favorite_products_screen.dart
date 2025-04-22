import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopware/helpers/snackbar_helper.dart';
import 'package:shopware/screens/product_detail_screen.dart';

class FavoriteProductsScreen extends StatefulWidget {
  const FavoriteProductsScreen({super.key});

  @override
  State<FavoriteProductsScreen> createState() => _FavoriteProductsScreenState();
}

class _FavoriteProductsScreenState extends State<FavoriteProductsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  List<String> _favoriteIds = [];
  List<Map<String, dynamic>> _favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final favSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();

    _favoriteIds = favSnapshot.docs.map((doc) => doc.id).toList();

    if (_favoriteIds.isEmpty) {
      setState(() {
        _favoriteProducts = [];
      });
      return;
    }

    final productSnapshot = await _firestore
        .collection('products')
        .where(FieldPath.documentId, whereIn: _favoriteIds)
        .get();

    setState(() {
      _favoriteProducts = productSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    });
  }

  Future<void> _removeFromFavorites(String productId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId)
        .delete();

    showShortSnack(context, '❌ Favorilerden çıkarıldı');

    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favori Ürünler')),
      body: _favoriteProducts.isEmpty
          ? Center(child: Text('Henüz favori ürün yok.'))
          : ListView.builder(
              itemCount: _favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = _favoriteProducts[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Image.network(product['imageUrl'],
                        width: 50, height: 50),
                    title: Text(product['name']),
                    subtitle: Text('${product['price']} ₺'),
                    trailing: IconButton(
                      icon: Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => _removeFromFavorites(product['id']),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(
                            productId: product['id'],
                            productData: product,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
