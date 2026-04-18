import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/bootstrap_service.dart';

class AdminAreaController extends GetxController {
  AdminAreaController()
    : _bootstrapService = BootstrapService(FirebaseFirestore.instance);

  final BootstrapService _bootstrapService;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final currentUser = Rxn<User>();
  final isSubmitting = false.obs;
  final isSeeding = false.obs;
  final errorMessage = RxnString();
  final infoMessage = RxnString();
  final appointments = <Map<String, dynamic>>[].obs;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _appointmentsSubscription;

  bool get isAuthorizedAdmin {
    final email = currentUser.value?.email?.toLowerCase().trim();
    return email != null && AppConfig.adminEmails.contains(email);
  }

  @override
  void onInit() {
    super.onInit();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      currentUser.value = user;
      _bindAppointments();
    });
  }

  void _bindAppointments() {
    _appointmentsSubscription?.cancel();
    appointments.clear();

    if (!isAuthorizedAdmin) {
      return;
    }

    _appointmentsSubscription = FirebaseFirestore.instance
        .collection('appointments')
        .orderBy('scheduledFor')
        .snapshots()
        .listen((snapshot) {
          final docs = snapshot.docs
              .map((doc) => doc.data())
              .where((data) => data['isSeed'] != true)
              .toList(growable: false);
          appointments.assignAll(docs);
        });
  }

  Future<void> signIn() async {
    isSubmitting.value = true;
    errorMessage.value = null;

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final email = credential.user?.email?.toLowerCase().trim();
      if (email == null || !AppConfig.adminEmails.contains(email)) {
        await FirebaseAuth.instance.signOut();
        throw FirebaseAuthException(
          code: 'not-admin',
          message: 'Questo account non e autorizzato come amministratore.',
        );
      }
    } on FirebaseAuthException catch (error) {
      errorMessage.value = switch (error.code) {
        'invalid-email' => 'Email non valida.',
        'invalid-credential' => 'Credenziali non valide.',
        'wrong-password' => 'Password non corretta.',
        'user-not-found' => 'Utente non trovato.',
        'not-admin' => error.message,
        _ => error.message ?? 'Accesso non riuscito.',
      };
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> seedCollections() async {
    isSeeding.value = true;
    infoMessage.value = null;

    try {
      await _bootstrapService.seedInitialData();
      infoMessage.value =
          'Servizi e disponibilita iniziali aggiornati. Puoi tornare alla home pubblica e iniziare a raccogliere prenotazioni.';
    } catch (error) {
      infoMessage.value = 'Seed non riuscito: $error';
    } finally {
      isSeeding.value = false;
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _appointmentsSubscription?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
