class ApiConfig {
  static const baseUrl = 'http://mictcoserver2.mictco.com:3040/';

  static String urlFor(String path, {String? baseUrl}) {
    final raw = baseUrl ?? ApiConfig.baseUrl;
    final base = raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
    final suffix = path.startsWith('/') ? path : '/$path';
    return '$base$suffix';
  }

  static const clientId = 'dummy@service';
  static const secret = 'dummy@service';

  static const userName = 'admin';
  static const password = 'admin';
  static const location = '1';
  static const macId = 'string';
  static const area = 'string';
  static const routId = 'string';

  static const connectTimeout = Duration(minutes: 5);
  static const receiveTimeout = Duration(minutes: 5);
  static const sendTimeout = Duration(minutes: 5);
}

enum LoadTestEndpoint {
  serviceComplaint(
    path: '/get-service-complaint',
    label: 'Get service complaint',
  ),
  assignedTickets(
    path: '/get-tickets',
    label: 'Get tickets (Assigned)',
    query: {'status': 'Assigned'},
  ),
  qcCompleted(
    path: '/qc-completed-list',
    label: 'QC completed list',
  ),
  salesTypes(
    path: '/sales-types',
    label: 'Sales types',
    accept: 'text/plain',
  ),
  weatherForecast(
    path: '/WeatherForecast',
    label: 'Weather forecast',
    accept: 'text/plain',
    requiresAuth: false,
  ),
  userRoutes(
    path: '/user-routes',
    label: 'User routes',
  ),
  importAll(
    path: '/import-all',
    label: 'Import all',
  );

  const LoadTestEndpoint({
    required this.path,
    required this.label,
    this.query = const {},
    this.accept = '*/*',
    this.requiresAuth = true,
  });

  final String path;
  final String label;
  final Map<String, String> query;
  final String accept;
  final bool requiresAuth;
}
