import 'package:flutter/material.dart';

class TradeScreen extends StatelessWidget {
  const TradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tradeOptions = [
      {
        'title': 'Buy Cattle',
        'icon': Icons.add_shopping_cart,
        'color': Colors.green,
        'description': 'Record new cattle purchases'
      },
      {
        'title': 'Sell Cattle',
        'icon': Icons.sell,
        'color': Colors.orange,
        'description': 'Record cattle sales'
      },
      {
        'title': 'Trade History',
        'icon': Icons.history,
        'color': Colors.blue,
        'description': 'View all past transactions'
      },
      {
        'title': 'Market Prices',
        'icon': Icons.price_change,
        'color': Colors.purple,
        'description': 'Track market price trends'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cattle Trading',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage buying and selling of cattle',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: tradeOptions.length,
                itemBuilder: (context, index) {
                  final option = tradeOptions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: option['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          option['icon'],
                          color: option['color'],
                          size: 30,
                        ),
                      ),
                      title: Text(
                        option['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(option['description']),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Navigate to specific trade screens
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quick add new trade
          showModalBottomSheet(
            context: context,
            builder: (ctx) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Quick Trade',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement quick buy
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Buy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement quick sell
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.sell),
                        label: const Text('Sell'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 