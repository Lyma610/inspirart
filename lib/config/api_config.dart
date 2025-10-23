class ApiConfig {
  // URL base da API - altere aqui para apontar para seu servidor
  static const String baseUrl = 'https://tccbackend-completo.onrender.com';
  
  // URLs alternativas para diferentes ambientes
  static const String localUrl = 'http://localhost:8080';
  static const String productionUrl = 'https://tccbackend-completo.onrender.com';
  
  // Configurações de timeout
  static const int connectTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos
  
  // Configurações de retry
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1 segundo
  
  // Headers padrão
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Método para obter a URL base baseada no ambiente
  static String getBaseUrl() {
    // Aqui você pode implementar lógica para diferentes ambientes
    // Por exemplo, baseado em uma variável de ambiente ou configuração
    return baseUrl;
  }
}

