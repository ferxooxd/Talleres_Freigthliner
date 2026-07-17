import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/admin_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/user_role.dart';

class AdminChatTab extends StatefulWidget {
  const AdminChatTab({super.key});

  @override
  State<AdminChatTab> createState() => _AdminChatTabState();
}

class _AdminChatTabState extends State<AdminChatTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    if (adminProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filtrar administradores para no mostrarse a sí mismo y aplicar la búsqueda
    final chatUsers = adminProvider.users.where((u) {
      if (u.userRole == UserRole.admin) return false;
      if (_searchQuery.isEmpty) return true;
      return u.nombreCompleto.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                setState(() {
                  _searchQuery = value;
                });
              });
            },
            style: TextStyle(color: AppTheme.textColor(context), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar...',
              hintStyle: TextStyle(
                color: AppTheme.textMutedColor(context),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.textMutedColor(context),
                size: 20,
              ),
              filled: true,
              fillColor: AppTheme.inputColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.borderColor(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.borderColor(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.green),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: chatUsers.isEmpty
              ? Center(
                  child: Text(
                    'No hay usuarios disponibles',
                    style: TextStyle(color: AppTheme.textMutedColor(context)),
                  ),
                )
              : ListView.builder(
                  itemCount: chatUsers.length,
                  itemBuilder: (context, index) {
                    final user = chatUsers[index];
                    final isMechanic = user.userRole == UserRole.mechanic;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isMechanic
                            ? Colors.yellow[700]
                            : Theme.of(context).primaryColor,
                        child: Text(
                          user.nombre.isNotEmpty
                              ? user.nombre[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: isMechanic ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user.nombreCompleto,
                        style: TextStyle(
                          color: AppTheme.textColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        user.rol,
                        style: TextStyle(
                          color: AppTheme.textMutedColor(context),
                        ),
                      ),
                      onTap: () {
                        context.push(
                          '/chat',
                          extra: {
                            'contactId': user.idUsuario,
                            'contactName': user.nombreCompleto,
                          },
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
