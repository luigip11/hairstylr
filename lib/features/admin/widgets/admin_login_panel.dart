import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_theme.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_panel_shell.dart';

class AdminLoginPanel extends GetView<AdminAreaController> {
  const AdminLoginPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/hairstylr_logo.png',
                      width: 118,
                      height: 118,
                    ),
                  ),
                  const SizedBox(height: 18),
                  AdminPanelShell(
                    title: 'Area admin',
                    subtitle:
                        'Entra per visualizzare disponibilità, agenda e appuntamenti.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _adminFieldDecoration('Email'),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: controller.passwordController,
                          obscureText: true,
                          decoration: _adminFieldDecoration('Password'),
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
                            onPressed: controller.isSubmitting.value
                                ? null
                                : controller.signIn,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                            ),
                            child: Text(
                              controller.isSubmitting.value
                                  ? 'Accesso...'
                                  : 'Accedi',
                            ),
                          ),
                        ),
                      ],
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
}

InputDecoration _adminFieldDecoration(String label) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: const BorderSide(color: AppColors.borderNeutral, width: 1.2),
  );

  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    enabledBorder: border,
    border: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: AppTheme.accentBlue, width: 1.5),
    ),
  );
}
