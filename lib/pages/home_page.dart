import 'package:flutter/material.dart';
import 'package:rental_marketplace/OrderHistoryPage.dart';
import 'package:rental_marketplace/ProfilePage.dart';
import 'package:rental_marketplace/pages/market_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const MarketPage(),
      const OrderHistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: pages[currIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currIndex,
        onTap: (value) {
          setState(() {
            currIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Market",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.av_timer),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

