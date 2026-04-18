import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_routes.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_panel_shell.dart';

class AdminLoginPanel extends GetView<AdminAreaController> {
  const AdminLoginPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AdminPanelShell(
              title: 'Area admin',
              subtitle:
                  'Disponibilita, agenda e appuntamenti sono gestiti solo da voi due.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller.passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  Obx(() {
                    final error = controller.errorMessage.value;
                    if (error == null || error.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 18),
                  Obx(
                    () => FilledButton(
                      onPressed:
                          controller.isSubmitting.value ? null : controller.signIn,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                      ),
                      child: Text(
                        controller.isSubmitting.value ? 'Accesso...' : 'Accedi',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Get.offNamed(AppRoutes.home),
                    child: const Text('Torna alla prenotazione pubblica'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
