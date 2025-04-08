import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final _firestore = FirebaseFirestore.instance;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Siparişlerim')),
        body: Center(child: Text('Giriş yapılmamış')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Siparişlerim')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(uid)
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return Center(child: Text('Henüz hiç siparişiniz yok.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;
              final items =
                  List<Map<String, dynamic>>.from(data['items'] ?? []);
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              final formattedDate = createdAt != null
                  ? DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(createdAt)
                  : 'Tarih yok';

              return Card(
                margin: EdgeInsets.all(12),
                child: ExpansionTile(
                  title: Text('Sipariş - $formattedDate'),
                  children: items.map((item) {
                    return ListTile(
                      leading: Image.network(item['imageUrl'], width: 40),
                      title: Text(item['name']),
                      subtitle: Text('Adet: ${item['quantity']}'),
                      trailing: Text(
                          '${(item['price'] * item['quantity']).toStringAsFixed(2)} ₺'),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
