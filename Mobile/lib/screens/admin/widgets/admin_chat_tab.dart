import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/admin_provider.dart';

class AdminChatTab extends StatefulWidget {
  const AdminChatTab({super.key});

  @override
  State<AdminChatTab> createState() => _AdminChatTabState();
}

class _AdminChatTabState extends State<AdminChatTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    if (adminProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filtrar administradores para no mostrarse a sí mismo
    final chatUsers = adminProvider.users.where((u) => u.rol != 'ADMINISTRADOR').toList();

    if (chatUsers.isEmpty) {
      return const Center(
        child: Text(
          'No hay usuarios disponibles',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: chatUsers.length,
      itemBuilder: (context, index) {
        final user = chatUsers[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            user.nombreCompleto,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            user.rol,
            style: const TextStyle(color: Colors.white54),
          ),
          onTap: () {
            context.push('/chat', extra: {
              'contactId': user.idUsuario,
              'contactName': user.nombreCompleto,
            });
          },
        );
      },
    );
  }
}
