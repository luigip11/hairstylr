import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_config.dart';
import 'bootstrap_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hairstylr Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D6F5F)),
      ),
      home: const AuthGate(),
    );
  }
}

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

        if (!AppConfig.hasConfiguredAdminEmails) {
          return const LoginScreen(
            initialError:
                'Configura prima ADMIN_EMAILS e poi accedi con un account admin.',
          );
        }

        final signedInEmail = user.email?.toLowerCase().trim();
        final adminEmails = AppConfig.adminEmails;

        if (signedInEmail == null || !adminEmails.contains(signedInEmail)) {
          return UnauthorizedScreen(user: user);
        }

        return AdminDashboard(user: user);
      },
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Accesso negato',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text('L utente ${user.email} non e autorizzato come admin.'),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text('Esci'),
                ),
              ],
            ),
          ),
        ),
      ),
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
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final signedInEmail = credential.user?.email?.toLowerCase().trim();
      final adminEmails = AppConfig.adminEmails;
      if (signedInEmail == null || !adminEmails.contains(signedInEmail)) {
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
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hairstylr Admin',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Accedi con l account amministratore Firebase.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                if (!AppConfig.hasConfiguredAdminEmails)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Configura le email admin con --dart-define=ADMIN_EMAILS=mail1@example.com,mail2@example.com prima del deploy.',
                    ),
                  ),
                if (!AppConfig.hasConfiguredAdminEmails)
                  const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _submitting ? null : _signIn,
                  child: Text(_submitting ? 'Accesso in corso...' : 'Accedi'),
                ),
              ],
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
            'Seed completato: services, availability e appointments ora hanno documenti iniziali.';
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
        title: const Text('Admin Console'),
        actions: [
          TextButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin autenticato: ${widget.user.email}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Firestore non supporta collezioni vuote: il bottone qui sotto crea i primi documenti nelle collezioni richieste.',
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed: _seeding ? null : _seedCollections,
                  child: Text(
                    _seeding
                        ? 'Inizializzazione in corso...'
                        : 'Crea collezioni iniziali',
                  ),
                ),
                OutlinedButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text('Esci'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Collezioni previste:'),
            const SizedBox(height: 8),
            const Text('- services/basic_cut'),
            const Text('- availability/default_week'),
            const Text('- appointments/example_appointment'),
            if (_message != null) ...[
              const SizedBox(height: 24),
              Text(_message!),
            ],
          ],
        ),
      ),
    );
  }
}
