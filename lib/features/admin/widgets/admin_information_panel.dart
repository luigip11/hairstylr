import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../../../core/services/link_launcher.dart';
import '../controllers/admin_area_controller.dart';
import 'admin_panel_shell.dart';

class AdminInformationPanel extends StatefulWidget {
  const AdminInformationPanel({super.key});

  @override
  State<AdminInformationPanel> createState() => _AdminInformationPanelState();
}

class _AdminInformationPanelState extends State<AdminInformationPanel> {
  final _nameFieldKey = GlobalKey();
  final _messageFieldKey = GlobalKey();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _messageFocusNode = FocusNode();
  String? _feedbackMessage;
  bool _isSending = false;

  bool get _canSend =>
      !_isSending &&
      _nameController.text.trim().isNotEmpty &&
      _messageController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refresh);
    _messageController.addListener(_refresh);
    _nameFocusNode.addListener(() {
      if (_nameFocusNode.hasFocus) {
        _scrollFieldIntoView(_nameFieldKey);
      }
    });
    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus) {
        _scrollFieldIntoView(_messageFieldKey);
      }
    });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _messageFocusNode.dispose();
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPanelShell(
      title: 'Informazioni',
      subtitle: 'Dettagli app e contatto supporto.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.softBlueTint,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderBlueSoft),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/hairstylr_logo.png',
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hairstylr',
                        style: TextStyle(
                          color: AppColors.bookingDeepBlue,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _openDeveloperProfile,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: AppColors.textGreyBlue,
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(text: 'Developed by: '),
                                TextSpan(
                                  text: 'https://github.com/luigip11',
                                  style: TextStyle(
                                    color: AppColors.accentBlueDark,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderBlueSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Hai un problema? Invia un messaggio',
                  style: TextStyle(
                    color: AppColors.bookingDeepBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: _nameFieldKey,
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  onTap: () => _scrollFieldIntoView(_nameFieldKey),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  textCapitalization: TextCapitalization.words,
                  decoration: _informationInputDecoration('Nome e Cognome'),
                ),
                const SizedBox(height: 14),
                TextField(
                  key: _messageFieldKey,
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  onTap: () => _scrollFieldIntoView(_messageFieldKey),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  minLines: 4,
                  maxLines: 7,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _informationInputDecoration(
                    'Descrivi il problema',
                  ),
                ),
                if (_feedbackMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _feedbackMessage!,
                    style: const TextStyle(
                      color: AppColors.accentBlueDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    TextButton(
                      onPressed: _clearForm,
                      child: const Text('Annulla'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _canSend ? _sendMessage : null,
                      icon: Icon(
                        _isSending
                            ? Icons.hourglass_top_rounded
                            : Icons.send_rounded,
                      ),
                      label: Text(_isSending ? 'Invio...' : 'Invia'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _informationInputDecoration(String label) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.borderNeutral, width: 1.4),
    );

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.fieldSurface,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(
          color: AppColors.bookingDeepBlue,
          width: 1.7,
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    setState(() {
      _isSending = true;
      _feedbackMessage = null;
    });

    try {
      await Get.find<AdminAreaController>().submitSupportMessage(
        fullName: _nameController.text,
        message: _messageController.text,
      );

      _nameController.clear();
      _messageController.clear();

      if (!mounted) {
        return;
      }

      setState(() {
        _feedbackMessage =
            'Messaggio inviato automaticamente con la mail del tuo account admin.';
      });
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _feedbackMessage = error.code == 'permission-denied'
            ? 'Permessi Firestore insufficienti. Deploya le regole aggiornate prima di inviare.'
            : 'Invio non riuscito: ${error.message ?? error.code}';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _feedbackMessage = 'Invio non riuscito: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _messageController.clear();
    setState(() {
      _feedbackMessage = null;
    });
  }

  void _refresh() {
    setState(() {
      _feedbackMessage = null;
    });
  }

  void _scrollFieldIntoView(GlobalKey fieldKey) {
    _ensureFieldVisible(fieldKey);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _ensureFieldVisible(fieldKey);
      }
    });

    Timer(const Duration(milliseconds: 360), () {
      if (mounted) {
        _ensureFieldVisible(fieldKey);
      }
    });
  }

  void _ensureFieldVisible(GlobalKey fieldKey) {
    final fieldContext = fieldKey.currentContext;
    if (fieldContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      fieldContext,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0.16,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
  }

  Future<void> _openDeveloperProfile() async {
    final opened = await launchExternalLink('https://github.com/luigip11');
    if (!mounted || opened) {
      return;
    }

    setState(() {
      _feedbackMessage =
          'Non sono riuscito ad aprire il browser su questo dispositivo.';
    });
  }
}
