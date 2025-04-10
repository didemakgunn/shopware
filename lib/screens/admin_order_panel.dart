import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminOrderPanel extends StatefulWidget {
  const AdminOrderPanel({super.key});

  @override
  State<AdminOrderPanel> createState() => _AdminOrderPanelState();
}

class _AdminOrderPanelState extends State<AdminOrderPanel> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin - Sipariş Paneli')),
      body: FutureBuilder<QuerySnapshot>(
        future: _firestore.collection('users').get(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final userDocs = userSnapshot.data!.docs;

          return ListView.builder(
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              final userDoc = userDocs[index];
              final uid = userDoc.id;
              final userEmail = userDoc.data() is Map<String, dynamic>
                  ? (userDoc.data() as Map<String, dynamic>)['email'] ?? uid
                  : uid;

              return FutureBuilder<QuerySnapshot>(
                future: _firestore
                    .collection('users')
                    .doc(uid)
                    .collection('orders')
                    .orderBy('createdAt', descending: true)
                    .get(),
                builder: (context, orderSnapshot) {
                  if (!orderSnapshot.hasData) return SizedBox.shrink();

                  final orders = orderSnapshot.data!.docs;

                  if (orders.isEmpty) return SizedBox.shrink();

                  return ExpansionTile(
                    title: Text('🧑 $userEmail'),
                    subtitle: Text('Toplam ${orders.length} sipariş'),
                    children: orders.map((order) {
                      final data = order.data() as Map<String, dynamic>;
                      final items =
                          List<Map<String, dynamic>>.from(data['items'] ?? []);
                      final createdAt =
                          (data['createdAt'] as Timestamp?)?.toDate();
                      final formattedDate = createdAt != null
                          ? DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR')
                              .format(createdAt)
                          : 'Tarih yok';

                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ExpansionTile(
                          title: Text('🧾 Sipariş - $formattedDate'),
                          children: items.map((item) {
                            return ListTile(
                              leading:
                                  Image.network(item['imageUrl'], width: 40),
                              title: Text(item['name']),
                              subtitle: Text('Adet: ${item['quantity']}'),
                              trailing: Text(
                                '${(item['price'] * item['quantity']).toStringAsFixed(2)} ₺',
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
