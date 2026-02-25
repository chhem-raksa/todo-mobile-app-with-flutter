import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../widgets/profile_widgets.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});
  ImageProvider<Object>? _resolveImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    }

    try {
      return MemoryImage(base64Decode(imageUrl));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final isDarkMode = user?.isDarkMode ?? false;
    final themeColor = isDarkMode ? Colors.white : const Color(0xFF2D3748);
    final theme = Theme.of(context);
    void handleLogout() {
      context.read<UserProvider>().logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }

    return Scaffold(
      backgroundColor: isDarkMode
          ? theme.colorScheme.surfaceContainer
          : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(color: themeColor, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // dart mode
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),

            // dart mode and setting icons
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.settings, color: themeColor, size: 24),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  tooltip: "Settings",
                ),
              ],
            ),
          ),
        ],
        iconTheme: IconThemeData(color: themeColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar & Name
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.indigo, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.indigo,
                          backgroundImage: _resolveImageProvider(
                            user?.imageUrl,
                          ),
                          child: user == null || user.imageUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/edit_profile');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.indigo,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? "Guest User",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  if (user?.title != null && user!.title!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.title!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Details
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ProfileInfoTile(
              label: 'Email Address',
              value: user?.email ?? '',
              icon: Icons.email_outlined,
            ),
            ProfileInfoTile(
              label: 'Phone Number',
              value: user?.phoneNumber ?? '',
              icon: Icons.phone_outlined,
            ),
            ProfileInfoTile(
              label: 'About Me',
              value: user?.about ?? '',
              icon: Icons.info_outline,
            ),
            const SizedBox(height: 24),
            // logout button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: handleLogout,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.withAlpha(20)),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
