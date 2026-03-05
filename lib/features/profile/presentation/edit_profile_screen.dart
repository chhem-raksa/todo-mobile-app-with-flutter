import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _aboutController;
  late TextEditingController _phoneController;

  bool _isLoading = false;
  String _selectedImageBase64 = '';
  ImageProvider<Object>? _selectedImageProvider;

  ImageProvider<Object>? _resolveImageProvider(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }
    try {
      return MemoryImage(base64Decode(value));
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _titleController = TextEditingController(text: user?.title ?? '');
    _aboutController = TextEditingController(text: user?.about ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _selectedImageBase64 = user?.imageUrl ?? '';
    _selectedImageProvider = _resolveImageProvider(_selectedImageBase64);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _aboutController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1024,
    );
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedImageBase64 = base64Encode(bytes);
      _selectedImageProvider = MemoryImage(bytes);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.user;
    if (currentUser == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

    var updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      about: _aboutController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      imageUrl: _selectedImageBase64,
    );

    try {
      final updatedJson = await _apiService.updateUserProfile(
        id: updatedUser.id,
        email: updatedUser.email,
        password: updatedUser.password,
        name: updatedUser.name,
        imageUrl: updatedUser.imageUrl,
        isDarkMode: updatedUser.isDarkMode,
        title: updatedUser.title,
        about: updatedUser.about,
        phoneNumber: updatedUser.phoneNumber,
      );
      updatedUser = updatedUser.copyWith(
        imageUrl: updatedJson['imageUrl']?.toString() ?? updatedUser.imageUrl,
      );
    } catch (e) {
      debugPrint('Profile API update failed. Saving locally only: $e');
    }

    await userProvider.updateUser(updatedUser);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.indigo[100],
                  backgroundImage: _selectedImageProvider,
                  child: _selectedImageProvider == null
                      ? const Icon(Icons.person, size: 50, color: Colors.indigo)
                      : null,
                ),
              ),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Change profile image'),
              ),
              const SizedBox(height: 20),
              // full name
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // phone number
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              // about
              _buildTextField(
                controller: _aboutController,
                label: 'About',
                icon: Icons.info_outline,
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
    );
  }
}
