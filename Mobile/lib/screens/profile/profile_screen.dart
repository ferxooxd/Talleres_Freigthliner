import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ui_components.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    const color = AppTheme.green;

    return Scaffold(
      backgroundColor: const Color(0xFF050607),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.text),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mi Cuenta',
          style: GoogleFonts.rajdhani(
            color: AppTheme.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Text(
                    provider.initials,
                    style: GoogleFonts.rajdhani(
                      color: color,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${provider.userName ?? ''} ${provider.userLastName ?? ''}'.trim(),
              style: GoogleFonts.rajdhani(
                color: AppTheme.text,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            StatusChip(
              text: provider.role?.toUpperCase() ?? 'USUARIO',
              color: color,
            ),
            const SizedBox(height: 40),
            DashboardCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _ProfileSetting(
                    icon: Icons.person_outline_rounded,
                    title: 'Datos Personales',
                    color: color,
                  ),
                  const Divider(color: Color(0xFF262626), height: 32),
                  _ProfileSetting(
                    icon: Icons.security_rounded,
                    title: 'Seguridad y Contraseña',
                    color: color,
                  ),
                  const Divider(color: Color(0xFF262626), height: 32),
                  _ProfileSetting(
                    icon: Icons.help_outline_rounded,
                    title: 'Centro de Ayuda',
                    color: color,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ActionButton(
                label: 'Cerrar Sesión',
                icon: Icons.logout_rounded,
                isDanger: true,
                onPressed: () async {
                  await provider.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ActionButton(
                label: 'Eliminar Cuenta',
                icon: Icons.person_remove_rounded,
                isDanger: true,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF171717),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        'Eliminar Cuenta',
                        style: GoogleFonts.rajdhani(
                          color: AppTheme.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        '¿Estás seguro de que deseas eliminar tu cuenta?\n\nEsta acción es irreversible y perderás todo tu historial de servicios.',
                        style: GoogleFonts.dmSans(
                          color: AppTheme.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.dmSans(color: AppTheme.textMuted),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            // Aquí se llamaría al AuthProvider para eliminar la cuenta en el backend.
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cuenta eliminada exitosamente'),
                                backgroundColor: AppTheme.green,
                              ),
                            );
                            await provider.logout();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          child: Text(
                            'Sí, Eliminar',
                            style: GoogleFonts.dmSans(
                              color: AppTheme.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileSetting extends StatelessWidget {
  const _ProfileSetting({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF262626)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              color: AppTheme.text,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.textDim,
        ),
      ],
    );
  }
}
