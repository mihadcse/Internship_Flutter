import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  bool isLoading = true;
  bool isProductsLoading = true;
  List<Map<String, dynamic>> products = [];
  bool isLoggedIn = false; // ✅ track login state

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _fetchProducts();
  }

  // ✅ Check if user is logged in
  Future<void> _checkAuth() async {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      isLoggedIn = user != null;
    });

    if (user != null) {
      await _fetchUserProfile(user.id);
    } else {
      setState(() {
        userName = null;
        isLoading = false;
      });
    }
  }

  // ✅ Fetch logged-in user's profile
  Future<void> _fetchUserProfile(String userId) async {
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('name')
          .eq('id', userId)
          .maybeSingle();

      setState(() {
        userName = profile != null ? profile['name'] : 'User';
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() {
        userName = 'User';
        isLoading = false;
      });
    }
  }

  // ✅ Fetch all products (publicly visible)
  Future<void> _fetchProducts() async {
    setState(() {
      isProductsLoading = true;
    });

    try {
      final data =
          await Supabase.instance.client
                  .from('products')
                  .select()
                  .order('created_at', ascending: false)
              as List<dynamic>;

      setState(() {
        products = data.map((e) => e as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      setState(() {
        isProductsLoading = false;
      });
    }
  }

  // ✅ Logout
  void _logout() async {
    await Supabase.instance.client.auth.signOut();
    setState(() {
      isLoggedIn = false;
      userName = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        title: const Text('E-Commerce Platform'),
        backgroundColor: Colors.deepPurple.shade400,
        foregroundColor: Colors.white,
        actions: [
          if (isLoggedIn) ...[
            TextButton(
              onPressed: _logout,
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
            TextButton(
              onPressed: () async {
                await context.push('/add_product');
                _fetchProducts(); // refresh after adding
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Product'),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(
                right: 8.0,
              ), // reduce right spacing to move left
              child: TextButton(
                onPressed: () => context.go('/login'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Login'),
              ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const CircularProgressIndicator()
                : Text(
                    isLoggedIn
                        ? 'Welcome, ${userName ?? "User"}!'
                        : 'Welcome, Guest!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          Expanded(
            child: isProductsLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                ? const Center(child: Text('No products yet'))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // ✅ Responsive: 2 columns for small screens, 3 for larger
                      int crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return Card(
                            elevation: 4,
                            color: Colors.white,
                            shadowColor: Colors.deepPurple.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                // optional: open details page
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ✅ Full image
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: product['image_url'] != null
                                          ? Image.network(
                                              product['image_url'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    size: 50,
                                                  ),
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image,
                                                size: 50,
                                              ),
                                            ),
                                    ),
                                  ),
                                  // ✅ Text section
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            product['name'] ?? 'No Name',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '\$${(product['price'] is num) ? product['price'].toStringAsFixed(2) : '0.00'}',
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
