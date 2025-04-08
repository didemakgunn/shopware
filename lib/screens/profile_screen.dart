import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  File? _imageFile;
  String? _profileImageUrl;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      _nameController.text = data?['name'] ?? '';
      _phoneController.text = data?['phone'] ?? '';
      _addressController.text = data?['address'] ?? '';
      setState(() {
        _profileImageUrl = data?['profilePicUrl'];
      });
    }
  }

  void _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        print('📸 Fotoğraf seçildi: ${picked.path}');
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (e) {
      print('❌ Galeri hatası: $e');
    }
  }

  Future<String?> _uploadImage(String uid) async {
    if (_imageFile == null) return null;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$uid.jpg');

      final uploadTask = await ref.putFile(_imageFile!);
      final url = await ref.getDownloadURL();
      print('✅ Yükleme başarılı. URL: $url');
      return url;
    } catch (e) {
      print('❌ Yükleme hatası: $e');
      return null;
    }
  }

  void _saveUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final imageUrl = await _uploadImage(uid);

    await _firestore.collection('users').doc(uid).set({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'email': _auth.currentUser?.email,
      'profilePicUrl': imageUrl ?? _profileImageUrl,
    });

    setState(() {
      _profileImageUrl = imageUrl ?? _profileImageUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profil güncellendi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = _imageFile != null
        ? Image.file(_imageFile!, fit: BoxFit.cover)
        : (_profileImageUrl != null
            ? Image.network(_profileImageUrl!, fit: BoxFit.cover)
            : Icon(Icons.account_circle, size: 100));

    return Scaffold(
      appBar: AppBar(title: Text('Profil Bilgileri')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  ClipOval(
                    child:
                        SizedBox(width: 120, height: 120, child: imageWidget),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Ad Soyad'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Telefon'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Adres'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUserData,
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
