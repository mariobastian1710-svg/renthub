import 'package:flutter/material.dart';
import 'package:rental_marketplace/models/order_item.dart';
import 'package:rental_marketplace/services/app_services.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Future<List<OrderItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<OrderItem>> _load() async {
    final token = await AppServices.sessionStore.getLoginToken();
    if (token == null || token.isEmpty) return const [];
    return AppServices.orderService.getHistory(loginToken: token);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gagal memuat history:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada order.'));
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _load()),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemBuilder: (context, index) {
              final o = items[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.10),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(14)),
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o.productName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${o.startDate} → ${o.endDate}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.black.withValues(alpha: 0.62),
                                  ),
                            ),
                            const SizedBox(height: 10),
                            _StatusPill(status: o.status),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Rp ${o.totalPrice}',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: items.length,
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final Color bg = s.contains('complete')
        ? Colors.green.withValues(alpha: 0.12)
        : s.contains('cancel')
            ? Colors.red.withValues(alpha: 0.12)
            : Colors.orange.withValues(alpha: 0.14);
    final Color fg = s.contains('complete')
        ? Colors.green.shade800
        : s.contains('cancel')
            ? Colors.red.shade800
            : Colors.orange.shade900;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

