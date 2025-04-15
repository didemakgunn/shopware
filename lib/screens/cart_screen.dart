import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopware/snackbar_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? uid;

  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser?.uid;
  }

  void _updateQuantity(String productId, int delta) async {
    if (uid == null) return;

    final ref = _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(productId);

    final snapshot = await ref.get();
    if (!snapshot.exists) return;

    final currentQty = snapshot.data()?['quantity'] ?? 1;

    if (currentQty + delta <= 0) {
      await ref.delete();
    } else {
      await ref.update({'quantity': FieldValue.increment(delta)});
    }
  }

  Future<void> _placeOrder() async {
    if (uid == null) return;

    final cartRef = _firestore.collection('users').doc(uid).collection('cart');
    final orderRef =
        _firestore.collection('users').doc(uid).collection('orders');

    final cartItems = await cartRef.get();

    if (cartItems.docs.isEmpty) {
      showShortSnack(context, 'Sepetiniz boş, sipariş oluşturulamadı ❌');
      return;
    }

    List<Map<String, dynamic>> orderItems = [];

    for (var doc in cartItems.docs) {
      final data = doc.data();
      orderItems.add({
        'name': data['name'],
        'price': data['price'],
        'quantity': data['quantity'],
        'imageUrl': data['imageUrl'],
      });
    }

    try {
      await orderRef.add({
        'createdAt': FieldValue.serverTimestamp(),
        'items': orderItems,
      });

      for (var doc in cartItems.docs) {
        await doc.reference.delete();
      }

      showShortSnack(context, 'Sipariş kaydedildi ve sepet temizlendi ✅');
    } catch (e) {
      print('Sipariş oluşturma hatası: $e');
      showShortSnack(context, 'Sipariş oluşturulamadı ❌');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Sepetim')),
        body: Center(child: Text('Giriş yapılmamış')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Sepetim')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return Center(child: Text('Sepetiniz boş.'));

          final total = docs.fold<double>(
            0,
            (sum, doc) {
              final data = doc.data() as Map<String, dynamic>;
              final quantity = data['quantity'] ?? 1;
              final price = data['price'] ?? 0;
              return sum + (price * quantity);
            },
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return ListTile(
                      leading: Image.network(data['imageUrl'],
                          width: 50, height: 50),
                      title: Text(data['name']),
                      subtitle: Text('Adet: ${data['quantity']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () => _updateQuantity(doc.id, -1),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () => _updateQuantity(doc.id, 1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Toplam: ${total.toStringAsFixed(2)} ₺',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: _placeOrder,
                child: Text('Satın Al'),
              ),
              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
