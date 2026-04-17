class AppConfig {
  static const adminEmailsRaw = String.fromEnvironment(
    'ADMIN_EMAILS',
    defaultValue: 'luigi.irons11@gmail.com,gnagna97@hotmail.com',
  );

  static List<String> get adminEmails => adminEmailsRaw
      .split(',')
      .map((email) => email.trim().toLowerCase())
      .where((email) => email.isNotEmpty)
      .toList(growable: false);

  static bool get hasConfiguredAdminEmails => adminEmails.isNotEmpty;
}
