# Bytebank App

Aplicação mobile de gerenciamento financeiro desenvolvida com Flutter e Firebase, seguindo Clean Architecture.

## Descrição

O Bytebank App é uma aplicação acadêmica para controle financeiro pessoal, permitindo que usuários registrem transações (receitas e despesas), anexem recibos e visualizem estatísticas em um dashboard interativo com gráficos de evolução de saldo.

## Funcionalidades

- **Autenticação**: Login e cadastro com e-mail/senha e Google (OAuth)
- **Transações**: Criar, editar e excluir transações com upload de recibos
- **Dashboard interativo**: Saldo, receitas, despesas e gráfico de evolução (linha ou barras) com seletor de período
- **Filtros**: Buscar por título, categoria, tipo (receita/despesa), presença de recibo e período
- **Paginação**: Carregamento progressivo de transações (lazy loading com cursor-based pagination)
- **Cache offline**: Transações persistidas localmente com Hive para acesso sem conexão
- **Criptografia**: Campo `title` criptografado no Firestore com AES-256 CBC; chave por dispositivo armazenada com `flutter_secure_storage`
- **Animações**: Transições sequenciais no dashboard com um único `AnimationController` e `Interval`

## Tecnologias

- **Flutter** — Framework mobile
- **Firebase Auth** — Autenticação (e-mail/senha + Google OAuth)
- **Cloud Firestore** — Banco de dados NoSQL com aggregation queries (`sum`)
- **Firebase Storage** — Armazenamento de recibos
- **Firebase App Distribution** — Distribuição de builds para testers via CI/CD
- **BLoC / flutter_bloc** — Gerenciamento de estado
- **bloc_concurrency** — Controle de eventos concorrentes (`restartable`)
- **Equatable** — Comparação de estados e eventos
- **Google Sign-In** — Autenticação OAuth com Google
- **encrypt + flutter_secure_storage** — Criptografia AES-256 CBC
- **Hive + hive_flutter** — Cache local offline
- **get_it** — Injeção de dependências
- **FL Chart** — Gráficos de linha e barras

## Arquitetura

O projeto segue **Clean Architecture** com três camadas bem definidas:

```
Domain Layer
├── Entities (modelos puros sem dependências externas)
├── Repository interfaces (contratos abstratos)
└── Use Cases (regras de negócio isoladas)

Data Layer
├── Models (DTOs com serialização Firestore + criptografia)
└── Repository implementations (Firestore, Hive cache)

Presentation Layer
├── BLoC (estado + eventos + transições)
├── Screens
└── Widgets
```

O estado é gerenciado por dois BLoCs — `AuthBloc` e `TransactionBloc` — fornecidos via `MultiBlocProvider` na raiz do app. A injeção de dependências é centralizada em `core/di/injection_container.dart` usando `get_it`.

## Pré-requisitos

```bash
flutter doctor
```

**Documentação oficial:** https://docs.flutter.dev/get-started/install

## Instalação

```bash
git clone <url-do-repositorio>
cd bytebank_app
flutter pub get
flutter run
```

## Firebase

O projeto já está configurado com Firebase. Os arquivos de configuração estão incluídos:

- `lib/firebase_options.dart` — Credenciais por plataforma
- `android/app/google-services.json` — Configuração Android
- `ios/Runner/GoogleService-Info.plist` — Configuração iOS

**Console Firebase**: https://console.firebase.google.com/project/bytebank-2778e

### Security Rules

As regras de segurança do Firestore e Storage estão definidas nos arquivos `firestore.rules` e `storage.rules` na raiz do projeto. Para fazer deploy:

```bash
firebase deploy --only firestore:rules,storage
```

As regras garantem que cada usuário acesse apenas seus próprios dados, com validação de campos obrigatórios e limites de tamanho de arquivo no Storage.

### Índices Firestore

```bash
firebase deploy --only firestore:indexes
```

Enquanto o índice não estiver disponível, o app calcula os totais via fallback (scan completo da coleção).

### Google Sign-In

- O provedor Google deve estar ativado no Firebase Authentication
- A SHA-1 do certificado Android deve estar registrada no Firebase

## Estrutura

```
lib/
├── main.dart                                     # Inicialização (Firebase, Hive, DI, BlocProviders)
├── app.dart                                      # Widget raiz (BlocConsumer de auth + navegação)
├── firebase_options.dart                         # Configurações Firebase por plataforma
├── core/
│   ├── di/
│   │   └── injection_container.dart             # Registro get_it (repositórios + use cases)
│   ├── theme/
│   │   └── app_theme.dart                       # Tema global e tokens de design
│   ├── utils/
│   │   ├── encryption_service.dart              # Serviço AES-256 CBC (chave por dispositivo)
│   │   └── formatters.dart                      # Formatadores de data e moeda
│   └── widgets/
│       └── custom_input.dart                    # Input compartilhado entre features
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/user.dart
│   │   │   ├── repositories/auth_repository.dart
│   │   │   └── usecases/                        # watch_auth_state, sign_in, sign_up, sign_in_with_google, sign_out
│   │   ├── data/
│   │   │   ├── models/user_model.dart
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/                            # auth_bloc, auth_event, auth_state
│   │       └── pages/login_screen.dart
│   ├── transactions/
│   │   ├── domain/
│   │   │   ├── entities/transaction.dart
│   │   │   ├── repositories/transaction_repository.dart
│   │   │   └── usecases/                        # get_transactions, get_aggregates, add, update, delete
│   │   ├── data/
│   │   │   ├── models/transaction_model.dart    # Serialização + criptografia do título
│   │   │   └── repositories/transaction_repository_impl.dart  # Firestore + Hive cache
│   │   └── presentation/
│   │       ├── bloc/                            # transaction_bloc, transaction_event, transaction_state
│   │       ├── pages/
│   │       │   ├── transaction_list_screen.dart # Lista com filtros e paginação
│   │       │   └── transaction_form_screen.dart # Formulário de transação
│   │       └── widgets/
│   ├── dashboard/
│   │   └── presentation/
│   │       ├── pages/dashboard_screen.dart
│   │       └── widgets/                         # balance_card, chart_card, services_section, user_account_modal
│   └── splash/
│       └── presentation/pages/splash_screen.dart

test/
├── helpers/
│   └── mocks.dart                               # MockAuthRepository, MockTransactionRepository e mocks de use cases
└── features/
    ├── auth/
    │   ├── domain/
    │   │   ├── entities/user_test.dart
    │   │   └── usecases/                        # sign_in, sign_up, sign_out, google, watch_auth_state
    │   └── presentation/bloc/auth_bloc_test.dart
    └── transactions/
        ├── domain/
        │   ├── entities/transaction_test.dart
        │   └── usecases/                        # get, add, update, delete, aggregates
        └── presentation/bloc/transaction_bloc_test.dart

.github/
└── workflows/
    ├── ci.yml                                   # CI: analyze + test + build (pull requests → master)
    └── cd.yml                                   # CD: build release + Firebase App Distribution (push → master)
```

## Testes

O projeto possui suite de testes unitários cobrindo entidades, use cases e BLoCs:

```bash
flutter test
```

73 testes unitários organizados em:
- **Entidades** — getters e `copyWith`
- **Use Cases** — caminho feliz, propagação de erros, cenários com/sem recibo
- **BLoCs** — todos os eventos de `AuthBloc` e `TransactionBloc` com mocks via `mocktail`

## CI/CD

| Trigger | Workflow | Etapas |
|---|---|---|
| Pull Request → `master` | `ci.yml` | `flutter analyze` → `flutter test` → `flutter build apk --debug` |
| Push em `master` | `cd.yml` | `flutter build apk --release` → upload Firebase App Distribution |

## Segurança

- **Firebase Auth** com e-mail/senha e Google OAuth
- **Criptografia AES-256 CBC** no campo `title` das transações (Firestore)
- **Chave de criptografia** gerada por dispositivo e armazenada com `flutter_secure_storage`
- **Firebase Security Rules** — Firestore e Storage protegidos por regras de ownership (`userId == request.auth.uid`)
- **Comunicação** via HTTPS/TLS (Firebase SDK padrão)

## Comandos Úteis

```bash
# Análise estática
flutter analyze

# Testes unitários
flutter test

# Build Android release
flutter build apk --release

# Deploy Firebase Rules + Indexes
firebase deploy --only firestore:rules,storage
firebase deploy --only firestore:indexes
```

## Documentação Técnica

[docs/TECHNICAL.md](docs/TECHNICAL.md)

## Licença

Projeto acadêmico de código aberto.
