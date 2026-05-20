import 'package:flutter/material.dart';
import 'package:rental_marketplace/models/profile.dart';
import 'package:rental_marketplace/services/app_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Profile?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Profile?> _load() async {
    final token = await AppServices.sessionStore.getLoginToken();
    if (token == null || token.isEmpty) return null;
    return AppServices.profileService.getProfile(loginToken: token);
  }

  Future<void> _logout() async {
    final token = await AppServices.sessionStore.getLoginToken();
    if (token != null && token.isNotEmpty) {
      try {
        await AppServices.authService.logout(loginToken: token);
      } catch (_) {
        // Ignore logout errors; still clear local session.
      }
    }
    await AppServices.sessionStore.clear();
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void _openEdit(Profile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _EditProfilePage(profile: profile)),
    ).then((_) => setState(() => _future = _load()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Profile?>(
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
                'Gagal memuat profile:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final p = snapshot.data;
        if (p == null) {
          return const Center(child: Text('Belum login.'));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      child: Icon(
                        Icons.person_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.username,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.email,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.black.withValues(alpha: 0.62)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  _RowItem(label: 'User ID', value: '${p.id}'),
                  _RowItem(label: 'Role ID', value: '${p.roleId}'),
                  _RowItem(label: 'Created At', value: p.createdAt, last: true),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _openEdit(p),
              child: const Text('Update Profile'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _logout,
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({required this.label, required this.value, this.last = false});
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        if (!last) Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
      ],
    );
  }
}

class _EditProfilePage extends StatefulWidget {
  const _EditProfilePage({required this.profile});

  final Profile profile;

  @override
  State<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<_EditProfilePage> {
  late final TextEditingController _username =
      TextEditingController(text: widget.profile.username);
  late final TextEditingController _email =
      TextEditingController(text: widget.profile.email);
  final TextEditingController _password = TextEditingController();
  late final TextEditingController _picture =
      TextEditingController(text: widget.profile.profilePictureUrl);

  bool _loading = false;

  Future<void> _save() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final token = await AppServices.sessionStore.getLoginToken();
      if (token == null || token.isEmpty) throw Exception('No login token');

      await AppServices.profileService.updateProfile(
        loginToken: token,
        username: _username.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        profilePictureUrl: _picture.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _picture.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _username,
                    decoration: const InputDecoration(
                      labelText: 'Username (optional)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
          const SizedBox(height: 12),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(
                      labelText: 'Email (optional)',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password (optional)',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _picture,
                    decoration: const InputDecoration(
                      labelText: 'Profile picture URL (optional)',
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _save,
                      child: Text(_loading ? 'Loading...' : 'Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

