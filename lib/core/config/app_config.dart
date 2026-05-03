class WorkspaceConfig {
  const WorkspaceConfig({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class AppConfig {
  static const adminEmailsRaw = String.fromEnvironment(
    'ADMIN_EMAILS',
    defaultValue: 'luigi.irons11@gmail.com,gnagna97@hotmail.com',
  );

  static const WorkspaceConfig luigiTestWorkspace = WorkspaceConfig(
    id: 'luigi-test',
    name: 'Luigi Test',
  );

  static const WorkspaceConfig hairstylrWorkspace = WorkspaceConfig(
    id: 'hairstylr',
    name: 'Hairstylr',
  );

  static List<String> get adminEmails => adminEmailsRaw
      .split(',')
      .map((email) => email.trim().toLowerCase())
      .where((email) => email.isNotEmpty)
      .toList(growable: false);

  static bool get hasConfiguredAdminEmails => adminEmails.isNotEmpty;

  static WorkspaceConfig? workspaceForEmail(String? email) {
    final normalizedEmail = email?.trim().toLowerCase();

    return switch (normalizedEmail) {
      'luigi.irons11@gmail.com' => luigiTestWorkspace,
      'gnagna97@hotmail.com' => hairstylrWorkspace,
      _ => null,
    };
  }
}
