import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/inventory_service.dart';

class ItemListWidget extends StatefulWidget {
  final InventoryService service;

  const ItemListWidget({required this.service, super.key});

  @override
  State<ItemListWidget> createState() => _ItemListWidgetState();
}

class _ItemListWidgetState extends State<ItemListWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
      stream: widget.service.getItemsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Center(
            child: Text('No items yet. Add one to get started!'),
          );
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ItemTile(
              item: item,
              service: widget.service,
              onDelete: () => _deleteItem(item.id),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteItem(String itemId) async {
    await widget.service.deleteItem(itemId);
  }
}

class ItemTile extends StatelessWidget {
  final Item item;
  final InventoryService service;
  final VoidCallback onDelete;

  const ItemTile({
    required this.item,
    required this.service,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final stockStatus = item.quantity > 0 ? 'In Stock' : 'Out of Stock';
    final stockColor = item.quantity > 0
        ? const Color(0xFF059669)
        : const Color(0xFFDC2626);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showItemDetails(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTapDown: (details) {
                        _showMenu(context, details.globalPosition);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          size: 20,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Qty: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: stockColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        stockStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: stockColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final items = <PopupMenuEntry<String>>[
      PopupMenuItem<String>(
        value: 'increment',
        child: Row(
          children: const [
            Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF059669)),
            SizedBox(width: 12),
            Text('Add'),
          ],
        ),
        onTap: () async {
          await service.incrementQuantity(item.id, 1);
        },
      ),
      PopupMenuItem<String>(
        value: 'decrement',
        enabled: item.quantity > 0,
        child: Row(
          children: const [
            Icon(
              Icons.remove_circle_outline,
              size: 20,
              color: Color(0xFFF59E0B),
            ),
            SizedBox(width: 12),
            Text('Remove'),
          ],
        ),
        onTap: () async {
          if (item.quantity > 0) {
            await service.decrementQuantity(item.id, 1);
          }
        },
      ),
      PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          children: const [
            Icon(Icons.edit_outlined, size: 20, color: Color(0xFF2563EB)),
            SizedBox(width: 12),
            Text('Edit'),
          ],
        ),
        onTap: () => _showEditDialog(context),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: const [
            Icon(Icons.delete_outline, size: 20, color: Color(0xFFDC2626)),
            SizedBox(width: 12),
            Text('Delete', style: TextStyle(color: Color(0xFFDC2626))),
          ],
        ),
        onTap: () {
          onDelete();
        },
      ),
    ];

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: items,
    );
  }

  void _showItemDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${item.description}'),
            const SizedBox(height: 8),
            Text('Quantity: ${item.quantity}'),
            const SizedBox(height: 8),
            Text('Price: \$${item.price.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text(
              'Total Value: \$${(item.quantity * item.price).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description);
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final priceController = TextEditingController(text: item.price.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedItem = item.copyWith(
                name: nameController.text,
                description: descriptionController.text,
                quantity:
                    int.tryParse(quantityController.text) ?? item.quantity,
                price: double.tryParse(priceController.text) ?? item.price,
              );
              await service.updateItem(updatedItem);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
