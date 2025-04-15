import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopware/screens/admin_order_panel.dart';
import 'package:shopware/screens/cart_screen.dart';
import 'package:shopware/screens/order_history_screen.dart';
import 'package:shopware/screens/product_screen.dart';
import 'package:shopware/screens/favorite_products_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'admin_product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  void _checkAdminRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data?['role'] == 'admin') {
        setState(() {
          _isAdmin = true;
        });
      }
    }
  }

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    final screens = [
      ProductScreen(),
      FavoriteProductsScreen(),
      CartScreen(),
      OrderHistoryScreen(),
      user == null ? LoginScreen() : ProfileScreen(),
    ];

    Widget _buildNavIcon(IconData icon, int index) {
      final isSelected = _selectedIndex == index;
      return Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: isSelected ? 28 : 24,
          color: isSelected ? Colors.blueAccent : Colors.grey,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _logout(context),
              tooltip: 'Çıkış Yap',
            ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.store, 0),
              label: 'Ürünler',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.favorite, 1),
              label: 'Favoriler',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.shopping_cart, 2),
              label: 'Sepet',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.receipt_long, 3),
              label: 'Sipariş',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(
                _auth.currentUser == null ? Icons.login : Icons.person,
                4,
              ),
              label: _auth.currentUser == null ? 'Giriş' : 'Profil',
            ),
          ],
        ),
      ),
      drawer: _isAdmin
          ? Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text('Admin Panel',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                  ListTile(
                    leading: Icon(Icons.inventory),
                    title: Text('Ürün Yönetimi'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminProductScreen()),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.assignment),
                    title: Text('Sipariş Yönetimi'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminOrderPanel()),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
