import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/user_model.dart';
import '../../../models/user_role.dart';
import 'package:flutter/services.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredUsers = provider.users.where((user) {
          final query = _searchQuery.toLowerCase();
          return user.nombreCompleto.toLowerCase().contains(query) ||
              user.correoElectronico.toLowerCase().contains(query) ||
              (user.cedula?.contains(query) ?? false);
        }).toList();

        return RefreshIndicator(
          onRefresh: provider.fetchUsers,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: AppTheme.textColor(context)),
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre, correo o cédula...',
                          hintStyle: TextStyle(
                            color: AppTheme.textMutedColor(context),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.textMutedColor(context),
                          ),
                          filled: true,
                          fillColor: AppTheme.inputColor(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add, color: Colors.black),
                      label: const Text(
                        'Añadir Personal',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onPressed: () => _showCreateStaffDialog(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isMechanic = user.userRole == UserRole.mechanic;
                    final isAdmin = user.userRole == UserRole.admin;
                    final isSecretary = user.userRole == UserRole.secretary;

                    return Card(
                      color: AppTheme.cardColor(context),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAdmin
                              ? Colors.red
                              : isMechanic
                                  ? Colors.orange
                                  : isSecretary
                                      ? Colors.purple
                                      : AppTheme.primaryColor,
                          child: Icon(
                            isAdmin
                                ? Icons.admin_panel_settings
                                : isMechanic
                                    ? Icons.build
                                    : isSecretary
                                        ? Icons.badge
                                        : Icons.person,
                            color: Colors.white,
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
                          '${user.correoElectronico}\nC.C: ${user.cedula} | Rol: ${user.rol}',
                          style: TextStyle(
                            color: AppTheme.textMutedColor(context),
                          ),
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () =>
                                  _showEditUserDialog(context, user),
                            ),
                            if (!isAdmin)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppTheme.errorColor,
                                ),
                                onPressed: () => _confirmDelete(
                                  context,
                                  user.idUsuario,
                                  user.nombreCompleto,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Diálogo Editar Usuario ────────────────────────────────────────────────

  void _showEditUserDialog(BuildContext context, UserModel user) {
    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController(
      text: user.nombreCompleto.split(' ').first,
    );
    final apellidoCtrl = TextEditingController(
      text: user.nombreCompleto.split(' ').skip(1).join(' '),
    );
    final telefonoCtrl = TextEditingController(text: user.telefono);
    final cedulaCtrl = TextEditingController(text: user.cedula);

    showDialog(
      context: context,
      builder: (dialogContext) => ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Builder(
            builder: (innerContext) => Center(
              child: AlertDialog(
                backgroundColor: AppTheme.cardColor(context),
                title: Text(
                  'Editar Usuario',
                  style: TextStyle(color: AppTheme.textColor(context)),
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFormField(context, nombreCtrl, 'Nombre',
                            required: true),
                        const SizedBox(height: 12),
                        _buildFormField(context, apellidoCtrl, 'Apellido',
                            required: true),
                        const SizedBox(height: 12),
                        _buildFormField(
                          context,
                          telefonoCtrl,
                          'Teléfono',
                          isNumeric: true,
                          maxLength: 10,
                          required: true,
                          extraValidator: (val) {
                            if (val != null && val.length != 10) {
                              return 'El teléfono debe tener exactamente 10 dígitos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildFormField(context, cedulaCtrl, 'Cédula',
                            isNumeric: true, required: true),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      'Cancelar',
                      style:
                          TextStyle(color: AppTheme.textMutedColor(context)),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final adminProvider = context.read<AdminProvider>();
                      final navigator = Navigator.of(dialogContext);
                      final scaffoldMessenger =
                          ScaffoldMessenger.of(innerContext);

                      try {
                        await adminProvider.updateUser(user.idUsuario, {
                          'nombre': nombreCtrl.text,
                          'apellido': apellidoCtrl.text,
                          'telefono': telefonoCtrl.text,
                          'cedula': cedulaCtrl.text,
                        });
                        navigator.pop();
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Usuario actualizado'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppTheme.errorColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Guardar',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Diálogo Añadir Personal ───────────────────────────────────────────────

  void _showCreateStaffDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController();
    final apellidoCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final cedulaCtrl = TextEditingController();
    final correoCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final espCtrl = TextEditingController();
    String selectedRole = 'Tecnico';

    showDialog(
      context: context,
      builder: (dialogContext) => ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: StatefulBuilder(
            builder: (innerContext, setStateSB) {
              return Center(
                child: AlertDialog(
                  backgroundColor: AppTheme.cardColor(context),
                  title: Text(
                    'Añadir Personal',
                    style: TextStyle(color: AppTheme.textColor(context)),
                  ),
                  content: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Nombre
                          _buildFormField(context, nombreCtrl, 'Nombre',
                              required: true),
                          const SizedBox(height: 12),
                          // Apellido
                          _buildFormField(context, apellidoCtrl, 'Apellido',
                              required: true),
                          const SizedBox(height: 12),
                          // Teléfono
                          _buildFormField(
                            context,
                            telefonoCtrl,
                            'Teléfono',
                            isNumeric: true,
                            maxLength: 10,
                            required: true,
                            extraValidator: (val) {
                              if (val != null && val.isNotEmpty && val.length != 10) {
                                return 'El teléfono debe tener exactamente 10 dígitos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          // Cédula (obligatorio)
                          _buildFormField(
                            context,
                            cedulaCtrl,
                            'Cédula',
                            isNumeric: true,
                            required: true,
                            extraValidator: (val) {
                              if (val != null && val.isNotEmpty && val.length < 6) {
                                return 'La cédula debe tener al menos 6 dígitos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          // Correo
                          _buildFormField(
                            context,
                            correoCtrl,
                            'Correo electrónico',
                            isEmail: true,
                            required: true,
                            extraValidator: (val) {
                              if (val != null && val.isNotEmpty) {
                                if (!val.contains('@')) {
                                  return 'El correo debe contener @';
                                }
                                if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$')
                                    .hasMatch(val)) {
                                  return 'Ingresa un correo válido (ej: nombre@gmail.com)';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          // Contraseña (obligatorio)
                          _buildFormField(
                            context,
                            passCtrl,
                            'Contraseña',
                            obscure: true,
                            required: true,
                            extraValidator: (val) {
                              if (val != null && val.isNotEmpty && val.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          // Rol
                          DropdownButtonFormField<String>(
                            initialValue: selectedRole,
                            dropdownColor: AppTheme.cardColor(context),
                            style:
                                TextStyle(color: AppTheme.textColor(context)),
                            decoration: InputDecoration(
                              labelText: 'Rol',
                              labelStyle: TextStyle(
                                color: AppTheme.textMutedColor(context),
                              ),
                              filled: true,
                              fillColor: AppTheme.inputColor(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Tecnico',
                                child: Text('Técnico'),
                              ),
                              DropdownMenuItem(
                                value: 'Secretario',
                                child: Text('Secretario'),
                              ),
                            ],
                            onChanged: (val) {
                              setStateSB(() {
                                selectedRole = val!;
                              });
                            },
                          ),
                          // Especialidad (solo para Técnico, opcional)
                          if (selectedRole == 'Tecnico') ...[
                            const SizedBox(height: 12),
                            _buildFormField(
                              context,
                              espCtrl,
                              'Especialidad (Opcional)',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: AppTheme.textMutedColor(context),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      onPressed: () async {
                        // Dispara validaciones inline en todos los campos
                        if (!formKey.currentState!.validate()) return;

                        final adminProvider = context.read<AdminProvider>();
                        final navigator = Navigator.of(dialogContext);
                        final scaffoldMessenger =
                            ScaffoldMessenger.of(innerContext);

                        try {
                          await adminProvider.createMechanic({
                            'nombre': nombreCtrl.text.trim(),
                            'apellido': apellidoCtrl.text.trim(),
                            'telefono': telefonoCtrl.text.trim(),
                            'cedula': cedulaCtrl.text.trim(),
                            'correo': correoCtrl.text.trim(),
                            'password': passCtrl.text,
                            'rol': selectedRole,
                            'especialidad':
                                selectedRole == 'Tecnico' &&
                                        espCtrl.text.isNotEmpty
                                    ? espCtrl.text.trim()
                                    : null,
                          });
                          navigator.pop();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content:
                                  Text('$selectedRole creado exitosamente'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          // Mensaje de error amigable para errores del servidor
                          String mensaje = e.toString();
                          if (mensaje.contains('correo') ||
                              mensaje.contains('email')) {
                            mensaje =
                                'El correo ingresado no es válido o ya está registrado.';
                          } else if (mensaje.contains('cedula')) {
                            mensaje = 'La cédula ingresada ya está registrada.';
                          } else if (mensaje.contains('telefono')) {
                            mensaje =
                                'El teléfono ingresado ya está registrado.';
                          }
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(mensaje),
                              backgroundColor: AppTheme.errorColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Crear',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Widget helper: TextFormField con validación inline ───────────────────

  Widget _buildFormField(
    BuildContext context,
    TextEditingController controller,
    String label, {
    bool obscure = false,
    bool isEmail = false,
    bool isNumeric = false,
    bool required = false,
    int? maxLength,
    String? Function(String?)? extraValidator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      maxLength: maxLength,
      keyboardType: isNumeric
          ? TextInputType.number
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      inputFormatters:
          isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: TextStyle(color: AppTheme.textColor(context)),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        labelStyle: TextStyle(color: AppTheme.textMutedColor(context)),
        filled: true,
        fillColor: AppTheme.inputColor(context),
        // Borde normal
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.borderColor(context)),
        ),
        // Borde al enfocar
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        // Borde rojo cuando hay error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
        ),
        errorStyle: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
      ),
      validator: (val) {
        if (required && (val == null || val.trim().isEmpty)) {
          return 'Este campo es obligatorio';
        }
        if (extraValidator != null) {
          return extraValidator(val);
        }
        return null;
      },
    );
  }

  // ─── Confirmar eliminación ────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, int id, String nombre) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor(context),
        title: Text(
          'Eliminar Usuario',
          style: TextStyle(color: AppTheme.textColor(context)),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar al usuario $nombre? Esta acción no se puede deshacer.',
          style: TextStyle(color: AppTheme.textMutedColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textMutedColor(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await context.read<AdminProvider>().deleteUser(id);
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Usuario eliminado exitosamente'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
