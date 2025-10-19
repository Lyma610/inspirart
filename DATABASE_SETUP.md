# Configuração do Banco de Dados MySQL para Inspirart

## 1. Instalação do MySQL

### Windows
1. Baixe o MySQL Installer do site oficial
2. Execute o instalador e siga as instruções
3. Configure uma senha para o usuário root

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install mysql-server
sudo mysql_secure_installation
```

### macOS
```bash
brew install mysql
brew services start mysql
```

## 2. Criação do Banco de Dados

Execute os seguintes comandos SQL no MySQL:

```sql
-- Criar o banco de dados
CREATE DATABASE inspirart_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Criar usuário específico para a aplicação
CREATE USER 'inspirart_user'@'localhost' IDENTIFIED BY 'inspirart_password';

-- Conceder todas as permissões ao usuário
GRANT ALL PRIVILEGES ON inspirart_db.* TO 'inspirart_user'@'localhost';

-- Aplicar as mudanças
FLUSH PRIVILEGES;

-- Verificar se foi criado corretamente
SHOW DATABASES;
```

## 3. Configuração do Spring Boot

Crie o arquivo `src/main/resources/application.properties` com o seguinte conteúdo:

```properties
# Configuração do Banco de Dados
spring.datasource.url=jdbc:mysql://localhost:3306/inspirart_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=inspirart_user
spring.datasource.password=inspirart_password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# Configuração do JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
spring.jpa.properties.hibernate.format_sql=true

# Configuração do Servidor
server.port=8080
server.servlet.context-path=/

# Configuração de Upload de Arquivos
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB

# Configuração de CORS (para comunicação com Flutter)
spring.web.cors.allowed-origins=http://localhost:3000,http://localhost:8080,http://127.0.0.1:3000
spring.web.cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS
spring.web.cors.allowed-headers=*
spring.web.cors.allow-credentials=true

# Logging
logging.level.org.springframework.web=DEBUG
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE
```

## 4. Scripts SQL para Criação das Tabelas

O Spring Boot com `spring.jpa.hibernate.ddl-auto=update` criará automaticamente as tabelas baseadas nas entidades JPA. Mas você pode executar estes scripts manualmente se necessário:

```sql
USE inspirart_db;

-- Tabela de Usuários
CREATE TABLE IF NOT EXISTS Usuario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    nivel_acesso VARCHAR(50) DEFAULT 'USUARIO',
    foto LONGBLOB,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    status_usuario VARCHAR(50) DEFAULT 'ATIVO'
);

-- Tabela de Categorias
CREATE TABLE IF NOT EXISTS Categoria (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    status_categoria VARCHAR(50) DEFAULT 'ATIVO'
);

-- Tabela de Gêneros
CREATE TABLE IF NOT EXISTS Genero (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    status_genero VARCHAR(50) DEFAULT 'ATIVO'
);

-- Tabela de Postagens
CREATE TABLE IF NOT EXISTS Postagem (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    legenda VARCHAR(500),
    descricao TEXT,
    conteudo LONGBLOB,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    status_postagem VARCHAR(50) DEFAULT 'ATIVO',
    usuario_id BIGINT,
    categoria_id BIGINT,
    FOREIGN KEY (usuario_id) REFERENCES Usuario(id),
    FOREIGN KEY (categoria_id) REFERENCES Categoria(id)
);

-- Tabela de Reações
CREATE TABLE IF NOT EXISTS Reacao (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tipo_reacao VARCHAR(50) NOT NULL,
    data_reacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    status_reacao VARCHAR(50) DEFAULT 'ATIVO',
    usuario_id BIGINT,
    postagem_id BIGINT,
    FOREIGN KEY (usuario_id) REFERENCES Usuario(id),
    FOREIGN KEY (postagem_id) REFERENCES Postagem(id)
);

-- Tabela de Mensagens
CREATE TABLE IF NOT EXISTS Mensagem (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    assunto VARCHAR(255) NOT NULL,
    mensagem TEXT NOT NULL,
    data_mensagem DATETIME DEFAULT CURRENT_TIMESTAMP,
    status_mensagem VARCHAR(50) DEFAULT 'ATIVO'
);

-- Inserir dados de exemplo
INSERT INTO Categoria (nome, descricao) VALUES 
('Arte Digital', 'Arte criada digitalmente'),
('Fotografia', 'Fotografias artísticas'),
('Ilustração', 'Ilustrações e desenhos'),
('Design', 'Design gráfico e visual'),
('Arquitetura', 'Design de espaços'),
('Moda', 'Estilo e tendências');

INSERT INTO Genero (nome, descricao) VALUES 
('Abstrato', 'Arte abstrata'),
('Realista', 'Arte realista'),
('Minimalista', 'Estilo minimalista'),
('Colorido', 'Arte com cores vibrantes'),
('Monocromático', 'Arte em tons de cinza'),
('Experimental', 'Arte experimental');

-- Inserir usuário administrador
INSERT INTO Usuario (nome, email, senha, nivel_acesso, status_usuario) VALUES 
('Administrador', 'admin@inspirart.com', 'MTIzNDU2Nzg=', 'ADMIN', 'ATIVO');
```

## 5. Verificação da Configuração

Para verificar se tudo está funcionando:

1. **Teste a conexão com o banco:**
   ```bash
   mysql -u inspirart_user -p inspirart_db
   ```

2. **Execute o Spring Boot e verifique os logs:**
   ```bash
   mvn spring-boot:run
   ```

3. **Teste um endpoint da API:**
   ```bash
   curl http://localhost:8080/categoria/findAll
   ```

## 6. Solução de Problemas Comuns

### Erro de Conexão
- Verifique se o MySQL está rodando
- Confirme as credenciais
- Verifique se a porta 3306 está aberta

### Erro de Timezone
- Adicione `?serverTimezone=UTC` na URL do banco
- Configure o timezone do MySQL

### Erro de SSL
- Adicione `?useSSL=false` na URL do banco
- Ou configure certificados SSL adequados

### Erro de Permissões
- Verifique se o usuário tem permissões adequadas
- Execute `FLUSH PRIVILEGES;` após criar o usuário

## 7. Backup e Restauração

### Backup
```bash
mysqldump -u inspirart_user -p inspirart_db > backup.sql
```

### Restauração
```bash
mysql -u inspirart_user -p inspirart_db < backup.sql
```

---

**Nota:** Este arquivo deve ser usado como referência para configurar o ambiente de desenvolvimento. Para produção, considere usar configurações mais seguras e robustas.
