import 'package:flutter/material.dart';

import '../controllers/admin_area_controller.dart';
import 'admin_panel_shell.dart';

class AdminUnauthorizedPanel extends StatelessWidget {
  const AdminUnauthorizedPanel({
    super.key,
    required this.controller,
    required this.email,
  });

  final AdminAreaController controller;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AdminPanelShell(
              title: 'Accesso negato',
              subtitle: 'L utente $email non e autorizzato come amministratore.',
              child: FilledButton(
                onPressed: controller.signOut,
                child: const Text('Esci'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
