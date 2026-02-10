import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  // Controllers
  final productName = TextEditingController();
  final productDesc = TextEditingController();
  final productPrice = TextEditingController();

  List<Map<String, dynamic>> categories = [];
  int? selectedCategoryId;
  bool isCategoriesLoading = true;

  @override
  void initState() {
    super.initState();
    listenToCategories();
  }

  void listenToCategories() {
    supabase.from('categories').stream(primaryKey: ['id']).listen((data) {
      if (mounted) {
        setState(() {
          categories = data;
          isCategoriesLoading = false;
        });
      }
    });
  }


  // --- Logic: Add Product ---
  Future<void> addProduct() async {
    if (productName.text.isEmpty || selectedCategoryId == null) return;

    try {
      await supabase.from('products').insert({
        'name': productName.text.trim(),
        'description': productDesc.text.trim(),
        'price': double.parse(productPrice.text.trim()),
        'category_id': selectedCategoryId,
      });

      productName.clear();
      productDesc.clear();
      productPrice.clear();
      selectedCategoryId = null;

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // --- UI: Add Product Bottom Sheet ---
  void showAddProductSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Add New Product", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextField(controller: productName, decoration: const InputDecoration(labelText: "Product Name")),
                TextField(controller: productDesc, maxLines: 2, decoration: const InputDecoration(labelText: "Description")),
                TextField(controller: productPrice, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price")),

                const SizedBox(height: 20),

                // --- Global Dropdown (No StreamBuilder needed here) ---
                isCategoriesLoading
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  hint: const Text("Select Category"),
                  items: categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat['id'],
                      child: Text(cat['name']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setSheetState(() {
                      selectedCategoryId = val;
                    });
                  },
                ),

                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: addProduct,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text("ADD PRODUCT"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  String getCategoryName(int? categoryId) {
    final category = categories.firstWhere(
          (cat) => cat['id'] == categoryId,
      orElse: () => {'name': 'Unknown'}, // Agar na mile toh
    );
    return category['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Supabase Store")),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddProductSheet,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('products')
            .stream(primaryKey: ['id'])
            .order('created_at'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Products Found"));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              final catName = getCategoryName(item['category_id']);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['description']),
                      Text(catName),
                    ],
                  ),
                  leading : const Icon(Icons.shopping_bag_outlined),
                  trailing: Text("₹ ${item['price'].toStringAsFixed(2)}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
