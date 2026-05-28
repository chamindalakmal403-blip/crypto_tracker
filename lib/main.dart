import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CryptoTrackerApp());
}

class CryptoTrackerApp extends StatelessWidget {
  const CryptoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainNavigationScreen(),
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

  static double liveBtcPrice = 0.0;
  static double liveEthPrice = 0.0;

  static double myBtcAmount = 0.0;
  static double myBtcBuyPrice = 0.0;
  
  static double myEthAmount = 0.0;
  static double myEthBuyPrice = 0.0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(
        onPricesUpdated: (btc, eth) {
          liveBtcPrice = btc;
          liveEthPrice = eth;
        },
      ),
      PortfolioScreen(
        btcAmount: myBtcAmount,
        btcBuyPrice: myBtcBuyPrice,
        ethAmount: myEthAmount,
        ethBuyPrice: myEthBuyPrice,
        liveBtcPrice: liveBtcPrice,
        liveEthPrice: liveEthPrice,
        onUpdate: (btcAmt, btcBuy, ethAmt, ethBuy) {
          setState(() {
            myBtcAmount = btcAmt;
            myBtcBuyPrice = btcBuy;
            myEthAmount = ethAmt;
            myEthBuyPrice = ethBuy;
          });
        },
      ),
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
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Portfolio'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final Function(double, double) onPricesUpdated;
  const DashboardScreen({super.key, required this.onPricesUpdated});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String btcPriceStr = "Loading...";
  String btcChange = "0.0%";
  bool btcPositive = true;

  String ethPriceStr = "Loading...";
  String ethChange = "0.0%";
  bool ethPositive = true;

  @override
  void initState() {
    super.initState();
    fetchCryptoPrices();
  }

  Future<void> fetchCryptoPrices() async {
    final url = Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=bitcoin,ethereum&price_change_percentage=24h');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        double btcPrice = 0.0;
        double ethPrice = 0.0;

        setState(() {
          for (var coin in data) {
            if (coin['id'] == 'bitcoin') {
              btcPrice = (coin['current_price'] as num).toDouble();
              btcPriceStr = "\$" + btcPrice.toStringAsFixed(2);
              double change = (coin['price_change_percentage_24h'] ?? 0.0 as num).toDouble();
              btcChange = change.toStringAsFixed(2) + "%";
              btcPositive = change >= 0;
            } else if (coin['id'] == 'ethereum') {
              ethPrice = (coin['current_price'] as num).toDouble();
              ethPriceStr = "\$" + ethPrice.toStringAsFixed(2);
              double change = (coin['price_change_percentage_24h'] ?? 0.0 as num).toDouble();
              ethChange = change.toStringAsFixed(2) + "%";
              ethPositive = change >= 0;
            }
          }
        });
        widget.onPricesUpdated(btcPrice, ethPrice);
      }
    } catch (e) {
      setState(() {
        btcPriceStr = "Error";
        ethPriceStr = "Error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Tracker Live', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: fetchCryptoPrices)],
      ),
      backgroundColor: const Color(0xFF111111),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Live Markets', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            cryptoCard('Bitcoin', 'BTC', btcPriceStr, btcChange, Colors.orange, btcPositive),
            const SizedBox(height: 12),
            cryptoCard('Ethereum', 'ETH', ethPriceStr, ethChange, Colors.purple, ethPositive),
          ],
        ),
      ),
    );
  }

  Widget cryptoCard(String name, String symbol, String price, String change, Color iconColor, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: iconColor, child: Text(symbol[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(symbol, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(change, style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class PortfolioScreen extends StatefulWidget {
  final double btcAmount;
  final double btcBuyPrice;
  final double ethAmount;
  final double ethBuyPrice;
  final double liveBtcPrice;
  final double liveEthPrice;
  final Function(double, double, double, double) onUpdate;

  const PortfolioScreen({
    super.key,
    required this.btcAmount,
    required this.btcBuyPrice,
    required this.ethAmount,
    required this.ethBuyPrice,
    required this.liveBtcPrice,
    required this.liveEthPrice,
    required this.onUpdate,
  });

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final _btcAmountController = TextEditingController();
  final _btcBuyPriceController = TextEditingController();
  final _ethAmountController = TextEditingController();
  final _ethBuyPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _btcAmountController.text = widget.btcAmount > 0 ? widget.btcAmount.toString() : '';
    _btcBuyPriceController.text = widget.btcBuyPrice > 0 ? widget.btcBuyPrice.toString() : '';
    _ethAmountController.text = widget.ethAmount > 0 ? widget.ethAmount.toString() : '';
    _ethBuyPriceController.text = widget.ethBuyPrice > 0 ? widget.ethBuyPrice.toString() : '';
  }

  void _saveData() {
    double btcAmt = double.tryParse(_btcAmountController.text) ?? 0.0;
    double btcBuy = double.tryParse(_btcBuyPriceController.text) ?? 0.0;
    double ethAmt = double.tryParse(_ethAmountController.text) ?? 0.0;
    double ethBuy = double.tryParse(_ethBuyPriceController.text) ?? 0.0;

    widget.onUpdate(btcAmt, btcBuy, ethAmt, ethBuy);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Portfolio Updated!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalInvestment = (widget.btcAmount * widget.btcBuyPrice) + (widget.ethAmount * widget.ethBuyPrice);
    double currentPortfolioValue = (widget.btcAmount * widget.liveBtcPrice) + (widget.ethAmount * widget.liveEthPrice);
    double profit = currentPortfolioValue - totalInvestment;
    double profitPercentage = totalInvestment > 0 ? (profit / totalInvestment) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF111111),
      // මෙතනට physics එකතු කරලා scroll ප්‍රශ්නය සම්පූර්ණයෙන්ම විසඳුවා
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Balance', style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('\$' + currentPortfolioValue.toStringAsFixed(2), style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Profit / Loss: ', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          (profit >= 0 ? '+' : '') + '\$' + profit.toStringAsFixed(2) + ' (${profitPercentage.toStringAsFixed(2)}%)',
                          style: TextStyle(color: profit >= 0 ? Colors.green[900] : Colors.red[900], fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text('Update Assets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _btcAmountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'BTC Amount', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _btcBuyPriceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'BTC Buy (\$)', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _ethAmountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ETH Amount', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _ethBuyPriceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ETH Buy (\$)', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.all(12)),
                child: const Text('Save Portfolio', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 15),
            const Text('Your Assets Current Value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            assetRow('Bitcoin', 'BTC', widget.btcAmount.toString(), '\$' + (widget.btcAmount * widget.liveBtcPrice).toStringAsFixed(2), Colors.orange),
            const SizedBox(height: 10),
            assetRow('Ethereum', 'ETH', widget.ethAmount.toString(), '\$' + (widget.ethAmount * widget.liveEthPrice).toStringAsFixed(2), Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget assetRow(String name, String symbol, String amount, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Text(symbol[0], style: TextStyle(color: color, fontWeight: FontWeight.bold))),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('$amount $symbol', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
