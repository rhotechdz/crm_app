import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talabati/core/constants/wilayas.dart';
import 'package:talabati/features/clients/data/models/client.dart';
import 'package:talabati/features/clients/presentation/providers/clients_provider.dart';

class AddEditClientScreen extends ConsumerStatefulWidget {
  final Client? client;

  const AddEditClientScreen({super.key, this.client});

  @override
  ConsumerState<AddEditClientScreen> createState() => _AddEditClientScreenState();
}

class _AddEditClientScreenState extends ConsumerState<AddEditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _instagramController;
  late TextEditingController _notesController;
  String? _selectedWilaya;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name);
    _phoneController = TextEditingController(text: widget.client?.phone);
    _instagramController =
        TextEditingController(text: widget.client?.instagramHandle);
    _notesController = TextEditingController(text: widget.client?.notes);
    _selectedWilaya = widget.client?.wilaya;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _instagramController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final phone = _phoneController.text.trim();
      
      // Check for duplicate phone
      final existingClient = await ref.read(clientsProvider.notifier).checkPhoneDuplicate(phone);
      
      if (existingClient != null && existingClient.id != widget.client?.id) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('A client with this number already exists — ${existingClient.name}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final client = Client(
        id: widget.client?.id,
        name: _nameController.text.trim(),
        phone: phone,
        instagramHandle: _instagramController.text.trim().isEmpty
            ? null
            : _instagramController.text.trim(),
        wilaya: _selectedWilaya!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        returnCount: widget.client?.returnCount ?? 0,
        createdAt: widget.client?.createdAt,
      );

      if (widget.client == null) {
        await ref.read(clientsProvider.notifier).addClient(client);
      } else {
        await ref.read(clientsProvider.notifier).updateClient(client);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.client != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Client' : 'Add Client'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number*',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instagramController,
                decoration: const InputDecoration(
                  labelText: 'Instagram Handle (optional)',
                  prefixText: '@',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedWilaya,
                decoration: const InputDecoration(
                  labelText: 'Wilaya*',
                  border: OutlineInputBorder(),
                ),
                items: wilayas.map((wilaya) {
                  return DropdownMenuItem(
                    value: wilaya,
                    child: Text(wilaya),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedWilaya = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator()
                  : Text(isEditing ? 'Update Client' : 'Save Client'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
