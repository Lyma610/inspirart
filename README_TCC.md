# Inspirart - Aplicação Flutter com Backend Spring Boot

## 📋 Visão Geral

O Inspirart é uma aplicação de rede social focada em arte e criatividade, desenvolvida com Flutter para o frontend e Spring Boot para o backend.

## 🛠️ Tecnologias Utilizadas

### Frontend (Flutter)
- **Flutter** - Framework de desenvolvimento
- **Dart** - Linguagem de programação
- **Provider** - Gerenciamento de estado
- **Go Router** - Navegação entre telas
- **Shared Preferences** - Armazenamento local
- **Material Design 3** - Design system moderno
- **HTTP** - Comunicação com API

### Backend (Spring Boot)
- **Spring Boot 3.2.0** - Framework Java
- **Spring Data JPA** - Persistência de dados
- **MySQL** - Banco de dados
- **Spring Web** - API REST
- **Spring Validation** - Validação de dados

## 🚀 Como Executar o Projeto

### Pré-requisitos

#### Para o Frontend (Flutter)
- Flutter SDK (versão 3.8.1 ou superior)
- Dart SDK
- Android Studio / VS Code
- Emulador Android ou dispositivo físico

#### Para o Backend (Spring Boot)
- Java 17 ou superior
- Maven 3.6+
- MySQL 8.0+
- IDE (IntelliJ IDEA, Eclipse, VS Code)

### 1. Configuração do Backend

1. **Clone ou baixe o projeto Spring Boot**
2. **Configure o banco de dados MySQL:**
   ```sql
   CREATE DATABASE inspirart_db;
   CREATE USER 'inspirart_user'@'localhost' IDENTIFIED BY 'inspirart_password';
   GRANT ALL PRIVILEGES ON inspirart_db.* TO 'inspirart_user'@'localhost';
   FLUSH PRIVILEGES;
   ```

3. **Configure o arquivo `application.properties`:**
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/inspirart_db
   spring.datasource.username=inspirart_user
   spring.datasource.password=inspirart_password
   spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
   
   spring.jpa.hibernate.ddl-auto=update
   spring.jpa.show-sql=true
   spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
   
   server.port=8080
   ```

4. **Execute o backend:**
   ```bash
   cd backend
   mvn spring-boot:run
   ```

### 2. Configuração do Frontend

1. **Navegue até a pasta do projeto Flutter:**
   ```bash
   cd inspirart
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Configure a URL da API (se necessário):**
   - Edite o arquivo `lib/config/api_config.dart`
   - Altere a `baseUrl` se seu backend estiver rodando em outro endereço

4. **Execute o aplicativo:**
   ```bash
   flutter run
   ```

## 📱 Funcionalidades Implementadas

### ✅ Autenticação
- Login de usuário
- Registro de usuário
- Logout
- Persistência de sessão

### ✅ Postagens
- Visualizar todas as postagens
- Criar nova postagem com imagem
- Filtrar por categoria
- Buscar postagens
- Sistema de reações (likes)

### ✅ Usuários
- Perfil do usuário
- Edição de perfil
- Upload de foto de perfil
- Alteração de senha

### ✅ Categorias e Gêneros
- Listar categorias disponíveis
- Listar gêneros disponíveis
- Filtrar postagens por categoria

### ✅ Mensagens
- Envio de mensagens de contato
- Visualização de mensagens
- Gerenciamento de status das mensagens

## 🔧 Configurações Importantes

### URLs da API
- **Desenvolvimento:** `http://localhost:8080`
- **Produção:** Configure em `lib/config/api_config.dart`

### Portas
- **Backend:** 8080
- **MySQL:** 3306 (padrão)

### Banco de Dados
- **Nome:** inspirart_db
- **Usuário:** inspirart_user
- **Senha:** inspirart_password

## 🐛 Solução de Problemas

### Backend não conecta ao banco
1. Verifique se o MySQL está rodando
2. Confirme as credenciais no `application.properties`
3. Verifique se o banco de dados foi criado

### Frontend não conecta à API
1. Verifique se o backend está rodando na porta 8080
2. Confirme a URL em `lib/config/api_config.dart`
3. Teste a API diretamente no navegador: `http://localhost:8080/postagem/findAll`

### Erro de CORS
- O backend já está configurado para aceitar requisições do Flutter
- Se houver problemas, verifique as configurações de CORS no backend

## 📊 Estrutura do Projeto

```
inspirart/
├── lib/
│   ├── config/           # Configurações
│   ├── providers/        # Gerenciamento de estado
│   ├── screens/          # Telas da aplicação
│   ├── services/         # Serviços de API
│   ├── utils/            # Utilitários
│   └── widgets/           # Componentes reutilizáveis
├── assets/               # Recursos (imagens, etc.)
└── pubspec.yaml          # Dependências do Flutter
```

## 🎯 Próximas Funcionalidades

- [ ] Sistema de comentários
- [ ] Histórias (Stories)
- [ ] Chat entre usuários
- [ ] Sistema de hashtags
- [ ] Filtros avançados
- [ ] Modo offline
- [ ] Push notifications
- [ ] Integração com redes sociais

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique os logs do backend no console
2. Verifique os logs do Flutter no terminal
3. Teste os endpoints da API diretamente
4. Consulte a documentação do Spring Boot e Flutter

## 🏆 Apresentação TCC

Este projeto está pronto para apresentação de TCC com:
- ✅ Backend Spring Boot completo e funcional
- ✅ Frontend Flutter integrado com APIs
- ✅ Sistema de autenticação
- ✅ CRUD completo para todas as entidades
- ✅ Upload de imagens
- ✅ Interface moderna e responsiva
- ✅ Documentação completa

**Boa sorte na sua apresentação! 🎉**
