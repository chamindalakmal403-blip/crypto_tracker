import 'package:flutter/material.dart';

void main() {
  runApp(const BuySellApp());
}

class BuySellApp extends StatelessWidget {
  const BuySellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'අපේ කඩේ - Buy & Sell',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  
  // සාම්පල් විකුණන බඩු ලැයිස්තුවක්
  final List<Map<String, String>> _products = [
    {
      'title': 'iPhone 13 Pro Max',
      'price': 'රු. 215,000',
      'location': 'කොළඹ',
      'phone': '0771234567',
      'desc': 'හොඳම තත්වයේ පවතී. කිසිදු දෝෂයක් නොමැත. බැටරි හෙල්ත් 85%.'
    },
    {
      'title': 'Bajaj Pulsar 150cc',
      'price': 'රු. 480,000',
      'location': 'කුරුණෑගල',
      'phone': '0719876543',
      'desc': '2018 වර්ෂය, පළමු අයිතිකරු, ලියකියවිලි සියල්ල සම්පූර්ණයි.'
    },
  ];

  void _addNewProduct(Map<String, String> newProduct) {
    setState(() {
      _products.insert(0, newProduct);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(products: _products),
      AddPostScreen(onAdd: _addNewProduct),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ප්‍රධාන පිටුව'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'දැන්වීමක් දාන්න'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'ගิණුම'),
        ],
      ),
    );
  }
}

// 1. ප්‍රධාන පිටුව (Home Screen)
class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> products;
  const HomeScreen({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('අපේ කඩේ - බඩු විකුණමු', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: products.isEmpty
          ? const Center(child: Text('තවම කිසිදු දැන්වීමක් නොමැත.'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      color: Colors.teal.shade100,
                      child: const Icon(Icons.image, color: Colors.teal),
                    ),
                    title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('${item['price']} | ${item['location']}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(product: item),
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

// 2. විස්තර පෙනෙන පිටුව (Details Screen)
class ProductDetailsScreen extends StatelessWidget {
  final Map<String, String> product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['title']!), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.teal.shade50,
              child: const Icon(Icons.image, size: 100, color: Colors.teal),
            ),
            const SizedBox(height: 16),
            Text(product['price']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 18),
                const SizedBox(width: 4),
                Text(product['location']!, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
            const Divider(height: 30),
            const Text('විස්තරය:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(product['desc']!, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('දුරකථන අංකය: ${product['phone']} වෙත ඇමතුමක් ලබා ගනී...')),
                  );
                },
                icon: const Icon(Icons.phone),
                label: const Text('විකුණන්නා අමතන්න', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. දැන්වීමක් එකතු කරන පිටුව (Add Post Screen)
class AddPostScreen extends StatefulWidget {
  final Function(Map<String, String>) onAdd;
  const AddPostScreen({super.key, required this.onAdd});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('දැන්වීමක් ඇතුළත් කරන්න'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'භාණ්ඩයේ නම (Title)')),
              TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'මිල (Price) (උදා: රු. 500)')),
              TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'නගරය (Location)')),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'දුරකථන අංකය (Phone)')),
              TextField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: 'භාණ්ඩය පිළිබඳ විස්තරය (Description)')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isEmpty || _priceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('කරුණාකර නම සහ මිල ඇතුළත් කරන්න!')),
                      );
                      return;
                    }
                    
                    widget.onAdd({
                      'title': _titleController.text,
                      'price': _priceController.text,
                      'location': _locationController.text.isEmpty ? 'ලංකාව' : _locationController.text,
                      'phone': _phoneController.text,
                      'desc': _descController.text,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('දැන්වීම සාර්ථකව එකතු කරන ලදී!')),
                    );

                    _titleController.clear();
                    _priceController.clear();
                    _locationController.clear();
                    _phoneController.clear();
                    _descController.clear();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  child: const Text('දැන්වීම පළ කරන්න', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 4. ප්‍රොෆයිල් පිටුව (Profile Screen)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('මගේ ගිණුම'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 100, color: Colors.teal),
            SizedBox(height: 10),
            Text('ඔබේ නම මෙතනට පෙනේ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('user@email.com', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
