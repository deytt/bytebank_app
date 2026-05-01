# Bytebank App

Aplicação mobile de gerenciamento financeiro desenvolvida com Flutter e Firebase.

## 📱 Descrição

O Bytebank App é uma aplicação acadêmica para controle financeiro pessoal, permitindo que usuários registrem transações (receitas e despesas), anexem recibos e visualizem estatísticas em um dashboard interativo com gráficos de evolução de saldo.

## ✨ Funcionalidades

- **Autenticação**: Login e cadastro com e-mail/senha e Google (OAuth)
- **Transações**: Criar, editar e excluir transações com upload de recibos
- **Dashboard interativo**: Saldo, receitas, despesas e gráfico de evolução (linha ou barras) com seletor de período (Total, Últimos 12 meses, Últimos 3 meses)
- **Área do usuário**: Modal com informações da conta (agência, conta, chave Pix e e-mail)
- **Filtros**: Buscar por título, categoria, tipo (receita/despesa), presença de recibo e período (15, 30 ou 90 dias)
- **Paginação**: Carregamento progressivo de transações (lazy loading)
- **Cache**: Aproveitamento do cache offline do Firestore para otimizar consultas repetidas
- **Criptografia**: Dados sensíveis protegidos com AES-256 no armazenamento local (`flutter_secure_storage`)
- **Animações**: Transições granulares entre elementos (FadeTransition, SlideTransition, AnimatedContainer, AnimatedSwitcher)

## 🛠️ Tecnologias

- **Flutter** — Framework mobile
- **Firebase Auth** — Autenticação (e-mail/senha + Google OAuth)
- **Cloud Firestore** — Banco de dados com cache offline
- **Firebase Storage** — Armazenamento de recibos
- **BLoC / flutter_bloc** — Gerenciamento de estado
- **Equatable** — Comparação de estados e eventos
- **Google Sign-In** — Autenticação OAuth com Google
- **encrypt + flutter_secure_storage** — Criptografia AES-256 local
- **FL Chart** — Gráficos de linha e barras
- **RxDart / Streams** — Programação reativa (streams do AuthService e Firestore)

## 📋 Pré-requisitos

Antes de executar o projeto, certifique-se de ter o Flutter instalado e configurado em sua máquina.

### Instalação do Flutter

Para instalar o Flutter, siga o guia oficial para seu sistema operacional:

**📖 Documentação oficial:** https://docs.flutter.dev/get-started/install

**Verificar instalação:**
```bash
flutter doctor
```

## 📦 Instalação

```bash
# Clone o repositório
git clone <url-do-repositorio>
cd bytebank_app

# Instale as dependências
flutter pub get

# Execute o app
flutter run
```

## 🔥 Firebase

O projeto já está configurado com Firebase. Os arquivos necessários estão incluídos:
- `lib/firebase_options.dart` — Credenciais
- `android/app/google-services.json` — Configuração Android
- `ios/Runner/GoogleService-Info.plist` — Configuração iOS

**Console Firebase**: https://console.firebase.google.com/project/bytebank-2778e

### Configuração do Google Sign-In

Para habilitar o login com Google, certifique-se de que:
- O provedor Google está ativado no Firebase Authentication
- A SHA-1 do certificado Android está registrada no Firebase (Android)
- O `GoogleService-Info.plist` está atualizado (iOS)

## 📂 Estrutura

```
lib/
├── main.dart                               # Ponto de entrada (BlocProviders + EncryptionService)
├── app.dart                                # Widget principal (BlocConsumer de auth)
├── core/
│   ├── theme/
│   │   └── app_theme.dart                  # Tema
│   └── utils/
│       ├── formatters.dart                 # Formatadores
│       └── encryption_service.dart         # Serviço de criptografia AES-256
├── models/
│   ├── transaction_model.dart              # Modelo de transação
│   └── user_model.dart                     # Modelo de usuário
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       └── bloc/
│   │           ├── auth_bloc.dart          # Auth BLoC
│   │           ├── auth_event.dart         # Eventos de autenticação
│   │           └── auth_state.dart         # Estados de autenticação
│   └── transactions/
│       └── presentation/
│           └── bloc/
│               ├── transaction_bloc.dart   # Transaction BLoC
│               ├── transaction_event.dart  # Eventos de transações
│               └── transaction_state.dart  # Estados de transações
├── services/
│   ├── auth_service.dart                   # Serviço de autenticação (e-mail + Google)
│   ├── transaction_service.dart            # Serviço de transações
│   └── storage_service.dart                # Serviço de storage
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart              # Splash screen
│   ├── login/
│   │   └── login_screen.dart               # Login (e-mail + Google OAuth)
│   ├── dashboard/
│   │   └── dashboard_screen.dart           # Dashboard (gráficos + modal usuário)
│   └── transactions/
│       ├── transaction_list_screen.dart    # Lista com filtros e paginação
│       └── transaction_form_screen.dart    # Formulário de transação
└── widgets/
    ├── transaction_card.dart               # Card de transação
    └── custom_input.dart                   # Input customizado
```

## 🎨 Categorias

- Alimentação
- Transporte
- Saúde
- Educação
- Lazer
- Salário
- Investimento
- Outros

## 🔐 Segurança

- **Autenticação** via Firebase Auth com suporte a e-mail/senha e Google OAuth
- **Criptografia AES-256** para dados sensíveis no armazenamento local (`flutter_secure_storage`)
- **Comunicação** com Firebase sempre via HTTPS/TLS (Firebase SDK padrão)
- Chave de criptografia gerada aleatoriamente por dispositivo e armazenada de forma segura

## 🚀 Comandos Úteis

```bash
# Limpar cache
flutter clean && flutter pub get

# Análise de código
flutter analyze

# Build Android
flutter build apk --release

# Build iOS
flutter build ios --release

# Build Web
flutter build web --release
```

## 📄 Licença

Projeto acadêmico de código aberto.
