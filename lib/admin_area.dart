import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_config.dart';
import 'bootstrap_service.dart';
import 'booking_support.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        final email = user.email?.toLowerCase().trim();
        if (email == null || !AppConfig.adminEmails.contains(email)) {
          return UnauthorizedScreen(user: user);
        }

        return AdminDashboard(user: user);
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialError});

  final String? initialError;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _error = widget.initialError;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
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
      setState(() {
        _error = switch (error.code) {
          'invalid-email' => 'Email non valida.',
          'invalid-credential' => 'Credenziali non valide.',
          'wrong-password' => 'Password non corretta.',
          'user-not-found' => 'Utente non trovato.',
          'not-admin' => error.message,
          _ => error.message ?? 'Accesso non riuscito.',
        };
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _PanelShell(
              title: 'Area admin',
              subtitle:
                  'Disponibilita, agenda e appuntamenti sono gestiti solo da voi due.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _submitting ? null : _signIn,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                    ),
                    child: Text(_submitting ? 'Accesso...' : 'Accedi'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed(
                      '/',
                    ),
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

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _PanelShell(
              title: 'Accesso negato',
              subtitle:
                  'L utente ${user.email} non e autorizzato come amministratore.',
              child: FilledButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text('Esci'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key, required this.user});

  final User user;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _bootstrapService = BootstrapService(FirebaseFirestore.instance);
  bool _seeding = false;
  String? _message;

  Future<void> _seedCollections() async {
    setState(() {
      _seeding = true;
      _message = null;
    });

    try {
      await _bootstrapService.seedInitialData();
      setState(() {
        _message =
            'Servizi e disponibilita iniziali aggiornati. Puoi tornare alla home pubblica e iniziare a raccogliere prenotazioni.';
      });
    } catch (error) {
      setState(() {
        _message = 'Seed non riuscito: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _seeding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda admin'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
            child: const Text('Vista cliente'),
          ),
          TextButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .orderBy('scheduledFor')
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? const [];
          final appointments = docs.where((doc) {
            final data = doc.data();
            return data['isSeed'] != true;
          }).toList(growable: false);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    SizedBox(
                      width: 320,
                      child: _KpiPanel(
                        label: 'Appuntamenti in agenda',
                        value: '${appointments.length}',
                        detail: 'Richieste e slot prenotati visibili solo admin',
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      child: _KpiPanel(
                        label: 'Admin attivo',
                        value: widget.user.email ?? 'admin',
                        detail: 'Accesso riservato a voi due',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    SizedBox(
                      width: 360,
                      child: _PanelShell(
                        title: 'Setup veloce',
                        subtitle:
                            'Inizializza servizi, disponibilita settimanale e documento placeholder.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FilledButton(
                              onPressed: _seeding ? null : _seedCollections,
                              child: Text(
                                _seeding
                                    ? 'Aggiornamento in corso...'
                                    : 'Aggiorna setup iniziale',
                              ),
                            ),
                            if (_message != null) ...[
                              const SizedBox(height: 14),
                              Text(_message!),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 520,
                      child: const _PanelShell(
                        title: 'Promemoria operativo',
                        subtitle:
                            'Per ora il flusso pubblico prenota direttamente uno slot e crea la richiesta in Firestore.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('1. Aggiorna services e availability da Firestore.'),
                            SizedBox(height: 8),
                            Text('2. Le clienti vedono solo la pagina pubblica e prenotano senza account.'),
                            SizedBox(height: 8),
                            Text('3. L area admin resta separata su /admin.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _PanelShell(
                  title: 'Appuntamenti',
                  subtitle:
                      'Vista agenda iniziale. Nel prossimo step possiamo aggiungere modifica, conferma e stato.',
                  child: appointments.isEmpty
                      ? const Text(
                          'Nessuna prenotazione ancora presente. Usa il seed o prova una prenotazione dalla vista cliente.',
                        )
                      : Column(
                          children: appointments
                              .map(
                                (doc) => _AppointmentRow(data: doc.data()),
                              )
                              .toList(growable: false),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PanelShell extends StatelessWidget {
  const _PanelShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _KpiPanel extends StatelessWidget {
  const _KpiPanel({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF18352E),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9EC3B9))),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(detail, style: const TextStyle(color: Color(0xFFE0F0EA))),
        ],
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final scheduledFor = (data['scheduledFor'] as Timestamp?)?.toDate();
    final customerName = (data['customerName'] as String?) ?? 'Cliente';
    final serviceName = (data['serviceName'] as String?) ?? 'Servizio';
    final notes = (data['notes'] as String?) ?? '';
    final status = (data['status'] as String?) ?? 'requested';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 74,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text(
                  scheduledFor == null ? '--' : '${scheduledFor.day}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                Text(
                  scheduledFor == null ? '--' : monthShort(scheduledFor),
                  style: const TextStyle(color: Color(0xFF5D6664)),
                ),
                const SizedBox(height: 6),
                Text(
                  scheduledFor == null ? '--:--' : formatTime(scheduledFor),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text('$serviceName - $status'),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    notes,
                    style: const TextStyle(color: Color(0xFF5E6966)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
