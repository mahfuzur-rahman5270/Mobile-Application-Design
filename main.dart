import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes debug banner
      title: 'Cart Page',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CartPage(initialCartItems: {}),
    );
  }
}

class CartPage extends StatefulWidget {
  final Map<int, int> initialCartItems; // productId: quantity
  const CartPage({super.key, required this.initialCartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Map<int, int> cartItems;

  final List<Map<String, dynamic>> productList = List.generate(
    20,
    (index) => {
      'name': 'Product ${index + 1}',
      'price': (index + 1) * 20,
      'imageColor': Colors.blue[(index + 1) * 100] ?? Colors.blue,
    },
  );

  @override
  void initState() {
    super.initState();
    cartItems = Map<int, int>.from(widget.initialCartItems);
  }

  @override
  Widget build(BuildContext context) {
    double total = cartItems.entries.fold(
      0,
      (sum, entry) =>
          sum + (productList[entry.key]['price'] as int) * entry.value,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Clear Cart"),
                      content: const Text(
                        "Are you sure you want to clear the cart?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => cartItems.clear());
                            Navigator.pop(context);
                          },
                          child: const Text("Clear"),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body:
          cartItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      size: 100,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Your cart is empty!",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => HomePage(
                                  onAddToCart: (index) {
                                    setState(() {
                                      cartItems.update(
                                        index,
                                        (q) => q + 1,
                                        ifAbsent: () => 1,
                                      );
                                    });
                                  },
                                ),
                          ),
                        );
                      },
                      child: const Text("Start Shopping"),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, i) {
                        final entry = cartItems.entries.toList()[i];
                        final productId = entry.key;
                        final quantity = entry.value;
                        final product = productList[productId];
                        final price = product['price'] as int;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          elevation: 4,
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: product['imageColor'] as Color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  (product['name'] as String).substring(0, 1),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(product['name'] as String),
                            subtitle: Text(
                              "Price: \$$price x $quantity = \$${price * quantity}",
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text("Remove Item"),
                                        content: const Text(
                                          "Are you sure you want to remove this item?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(
                                                () =>
                                                    cartItems.remove(productId),
                                              );
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Remove"),
                                          ),
                                        ],
                                      ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "Total: \$${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => CheckoutPage(
                                      total: total,
                                      cartItems: cartItems,
                                    ),
                              ),
                            );
                          },
                          child: const Text("Proceed to Checkout"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

class CheckoutPage extends StatelessWidget {
  final double total;
  final Map<int, int> cartItems;

  const CheckoutPage({super.key, required this.total, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Cart Items:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...cartItems.entries.map((entry) {
              final productId = entry.key;
              final quantity = entry.value;
              final product = {
                'name': 'Product ${productId + 1}',
                'price': (productId + 1) * 20,
                'imageColor': Colors.blue[(productId + 1) * 100] ?? Colors.blue,
              };
              final price = product['price'] as int;

              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: product['imageColor'] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      (product['name'] as String).substring(0, 1),
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                title: Text(product['name'] as String),
                subtitle: Text(
                  "Price: \$$price x $quantity = \$${price * quantity}",
                ),
              );
            }),
            const SizedBox(height: 20),
            Text(
              "Total: \$${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text("Order Completed"),
                        content: const Text("Thank you for your purchase!"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                );
              },
              child: const Text("Complete Purchase"),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final void Function(int) onAddToCart;
  const HomePage({super.key, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shop")),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          final productName = "Product ${index + 1}";
          final price = (index + 1) * 20;
          return ListTile(
            title: Text(productName),
            subtitle: Text("Price: \$$price"),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                onAddToCart(index);
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}
