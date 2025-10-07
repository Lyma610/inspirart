# Inspirart - App de Compartilhamento de Arte

## 📱 Sobre o Projeto

O **Inspirart** é um aplicativo móvel desenvolvido em Flutter que permite aos usuários compartilhar, descobrir e interagir com diferentes tipos de arte visual. Inspirado em plataformas como Instagram e Behance, o app é focado na comunidade artística.

## ✨ Funcionalidades Principais

### 🔐 Autenticação
- **Tela de Splash** - Apresentação inicial com logo animado
- **Login** - Acesso com email e senha
- **Cadastro** - Criação de nova conta
- **Recuperação de Senha** - Sistema de recuperação

### 🏠 Feed Principal
- **Timeline** - Posts de arte organizados cronologicamente
- **Filtros por Categoria** - Organização por tipo de arte
- **Interações** - Curtir, comentar e compartilhar posts
- **Navegação Inferior** - 5 abas principais

### 🔍 Descoberta
- **Busca** - Pesquisa por usuários, posts e categorias
- **Exploração** - Grade visual de conteúdo
- **Categorias** - Organização por tipo de arte

### 📸 Criação de Conteúdo
- **Seleção de Mídia** - Galeria de imagens
- **Criação de Post** - Editor com legenda e categorias
- **Escolha de Categoria** - Seleção de tipo de arte
- **Sequências** - Múltiplas imagens em um post

### 👥 Perfil e Social
- **Perfil do Usuário** - Informações pessoais e estatísticas
- **Seguidores/Seguindo** - Gestão de conexões
- **Menu Lateral** - Acesso rápido às funcionalidades
- **Notificações** - Interações e atividades

## 🎨 Categorias de Arte Suportadas

- **Fotografia** - Capturas únicas da vida
- **Ilustração** - Arte criativa e imaginativa
- **Design** - Soluções visuais criativas
- **Arte Digital** - Criações na era digital
- **Grafite** - Arte urbana e expressiva
- **Arte Urbana** - Arte nas ruas da cidade
- **Pintura** - Técnicas tradicionais
- **Escultura** - Formas tridimensionais
- **Arquitetura** - Design de espaços
- **Moda** - Estilo e tendências

## 🛠️ Tecnologias Utilizadas

- **Flutter** - Framework de desenvolvimento
- **Dart** - Linguagem de programação
- **Provider** - Gerenciamento de estado
- **Go Router** - Navegação entre telas
- **Shared Preferences** - Armazenamento local
- **Material Design 3** - Design system moderno

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── providers/               # Gerenciadores de estado
│   ├── auth_provider.dart   # Autenticação
│   ├── post_provider.dart   # Posts e conteúdo
│   └── user_provider.dart   # Usuários e perfis
├── screens/                 # Telas da aplicação
│   ├── auth/               # Autenticação
│   ├── main_screens/       # Telas principais
│   ├── post/               # Criação de posts
│   ├── followers/          # Seguidores
│   └── menu/               # Menu lateral
├── widgets/                 # Componentes reutilizáveis
│   ├── post_card.dart      # Card de post
│   └── bottom_navigation.dart # Navegação inferior
└── utils/                  # Utilitários
    └── app_theme.dart      # Tema da aplicação
```

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK (versão 3.8.1 ou superior)
- Dart SDK
- Android Studio / VS Code
- Emulador Android ou dispositivo físico

### Passos para Execução

1. **Clone o repositório**
   ```bash
   git clone [url-do-repositorio]
   cd inspirart
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo**
   ```bash
   flutter run
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
- [ ] Sistema de moderação
- [ ] Analytics e métricas

## 🤝 Contribuição

Contribuições são bem-vindas! Para contribuir:

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👨‍💻 Desenvolvedor

Desenvolvido com ❤️ para a comunidade artística.

---

**Inspirart** - Inspire-se, compartilhe sua arte! 🎨✨
