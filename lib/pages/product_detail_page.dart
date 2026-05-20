import 'package:flutter/material.dart';
import 'package:rental_marketplace/models/product_detail.dart';
import 'package:rental_marketplace/services/app_services.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final int productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<ProductDetail> _future;

  final TextEditingController _startDate = TextEditingController();
  final TextEditingController _endDate = TextEditingController();
  bool _ordering = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ProductDetail> _load() async {
    final token = await AppServices.sessionStore.getLoginToken();
    if (token == null || token.isEmpty) {
      throw Exception('No login token');
    }
    return AppServices.productService.getProductById(
      loginToken: token,
      id: widget.productId,
    );
  }

  Future<void> _createOrder() async {
    if (_ordering) return;
    final s = _startDate.text.trim();
    final e = _endDate.text.trim();
    if (s.isEmpty || e.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date dan end date wajib diisi.')),
      );
      return;
    }

    final token = await AppServices.sessionStore.getLoginToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamu belum login.')),
      );
      return;
    }

    setState(() => _ordering = true);
    try {
      final order = await AppServices.orderService.createOrder(
        loginToken: token,
        productId: widget.productId,
        startDate: s,
        endDate: e,
      );
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Order dibuat'),
          content: Text(
            'order_id: ${order.orderId}\n'
            'status: ${order.status}\n'
            'total_price: ${order.totalPrice}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (ex) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat order: $ex')),
      );
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

  @override
  void dispose() {
    _startDate.dispose();
    _endDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: FutureBuilder<ProductDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat detail: ${snapshot.error}'));
          }
          final p = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text(
                p.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Owner: ${p.ownerUsername}'),
              const SizedBox(height: 8),
              Text(p.description),
              const SizedBox(height: 12),
              Text('Category: ${p.category}'),
              const SizedBox(height: 8),
              Text('Rp ${p.pricePerDay}/hari'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              TextField(
                controller: _startDate,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'start_date (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _endDate,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'end_date (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _ordering ? null : _createOrder,
                  child: Text(_ordering ? 'Loading...' : 'Rent / Create Order'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

