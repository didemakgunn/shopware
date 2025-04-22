import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopware/screens/product/product_detail_screen.dart';
import 'package:shopware/helpers/snackbar_helper.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final favSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();

    setState(() {
      _favoriteIds = favSnap.docs.map((d) => d.id).toSet();
    });
  }

  Future<void> _toggleFavorite(String productId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      showShortSnack(context, '🔐 Önce giriş yapmalısınız');
      return;
    }
    final favRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId);

    final isFav = _favoriteIds.contains(productId);
    if (isFav) {
      await favRef.delete();
      setState(() => _favoriteIds.remove(productId));
      showShortSnack(context, '❌ Favorilerden çıkarıldı');
    } else {
      await favRef.set({'addedAt': FieldValue.serverTimestamp()});
      setState(() => _favoriteIds.add(productId));
      showShortSnack(context, '❤️ Favorilere eklendi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ürünler')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu.'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text('Henüz ürün yok.'));
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final productId = doc.id;
              final isFav = _favoriteIds.contains(productId);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(16)),
                          child: Image.network(
                            data['imageUrl'] ?? '',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200]),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'Ürün adı yok',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '${(data['price'] ?? 0).toStringAsFixed(2)} ₺',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  data['description'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => _toggleFavorite(productId),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
