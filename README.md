# Bytebank App

Aplicação mobile de gerenciamento financeiro desenvolvida com Flutter e Firebase, seguindo Clean Architecture.

## Descrição

O Bytebank App é uma aplicação acadêmica para controle financeiro pessoal, permitindo que usuários registrem transações (receitas e despesas), anexem recibos e visualizem estatísticas em um dashboard interativo com gráficos de evolução de saldo.

## Funcionalidades

- **Autenticação**: Login e cadastro com e-mail/senha e Google (OAuth)
- **Transações**: Criar, editar e excluir transações com upload de recibos
- **Dashboard interativo**: Saldo, receitas, despesas e gráfico de evolução (linha ou barras) com seletor de período (Total, Últimos 12 meses, Últimos 3 meses)
- **Área do usuário**: Modal com informações da conta (agência, conta, chave Pix e e-mail)
- **Filtros**: Buscar por título, categoria, tipo (receita/despesa), presença de recibo e período (15, 30 ou 90 dias)
- **Paginação**: Carregamento progressivo de transações (lazy loading com cursor-based pagination)
- **Cache offline**: Primeira página de transações persistida localmente com Hive para acesso sem conexão
- **Criptografia**: Campo `title` das transações criptografado no Firestore com AES-256 CBC; chave gerada por dispositivo e armazenada com `flutter_secure_storage`
- **Animações**: Transições sequenciais entre elementos do dashboard (FadeTransition, SlideTransition) com um único `AnimationController` e `Interval`

## Tecnologias

- **Flutter** — Framework mobile
- **Firebase Auth** — Autenticação (e-mail/senha + Google OAuth)
- **Cloud Firestore** — Banco de dados NoSQL com aggregation queries (`sum`)
- **Firebase Storage** — Armazenamento de recibos
- **BLoC / flutter_bloc** — Gerenciamento de estado
- **bloc_concurrency** — Controle de eventos concorrentes (`restartable`)
- **Equatable** — Comparação de estados e eventos
- **Google Sign-In** — Autenticação OAuth com Google
- **encrypt + flutter_secure_storage** — Criptografia AES-256 CBC
- **Hive + hive_flutter** — Cache local offline
- **get_it** — Injeção de dependências
- **FL Chart** — Gráficos de linha e barras
- **Dart Streams** — Programação reativa (streams do Firebase Auth e Firestore)

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

Antes de executar o projeto, certifique-se de ter o Flutter instalado e configurado:

**Documentação oficial:** https://docs.flutter.dev/get-started/install

```bash
flutter doctor
```

## Instalação

```bash
git clone <url-do-repositorio>
cd bytebank_app
flutter pub get
flutter run
```

## Firebase

O projeto já está configurado com Firebase. Os arquivos necessários estão incluídos:
- `lib/firebase_options.dart` — Credenciais
- `android/app/google-services.json` — Configuração Android
- `ios/Runner/GoogleService-Info.plist` — Configuração iOS

**Console Firebase**: https://console.firebase.google.com/project/bytebank-2778e

### Índices Firestore

Para habilitar as aggregation queries (`sum`) é necessário implantar o índice composto:

```bash
firebase deploy --only firestore:indexes
```

Enquanto o índice não estiver disponível, o app calcula os totais via fallback (scan completo da coleção).

### Google Sign-In

- O provedor Google deve estar ativado no Firebase Authentication
- A SHA-1 do certificado Android deve estar registrada no Firebase
- O `GoogleService-Info.plist` deve estar atualizado (iOS)

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
│   │   └── app_theme.dart                       # Tema global
│   └── utils/
│       ├── encryption_service.dart              # Serviço AES-256 CBC (chave por dispositivo)
│       └── formatters.dart                      # Formatadores de data e moeda
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
│   │       └── bloc/                            # auth_bloc, auth_event, auth_state
│   └── transactions/
│       ├── domain/
│       │   ├── entities/transaction.dart
│       │   ├── repositories/transaction_repository.dart
│       │   └── usecases/                        # get_transactions, get_aggregates, add, update, delete
│       ├── data/
│       │   ├── models/transaction_model.dart    # Serialização + criptografia do título
│       │   └── repositories/transaction_repository_impl.dart  # Firestore + Hive cache
│       └── presentation/
│           └── bloc/                            # transaction_bloc, transaction_event, transaction_state
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── login/
│   │   └── login_screen.dart                   # Login (e-mail + Google OAuth)
│   ├── dashboard/
│   │   ├── dashboard_screen.dart               # Dashboard principal
│   │   └── widgets/
│   │       ├── balance_card.dart               # Card de saldo/receitas/despesas
│   │       ├── chart_card.dart                 # Gráfico de evolução
│   │       ├── services_section.dart           # Seções de serviços
│   │       ├── stories_section.dart            # Stories de ofertas
│   │       ├── carousel_section.dart           # Carrossel promocional
│   │       └── user_account_modal.dart         # Modal de dados da conta
│   └── transactions/
│       ├── transaction_list_screen.dart        # Lista com filtros e paginação
│       └── transaction_form_screen.dart        # Formulário de transação
└── widgets/
    ├── transaction_card.dart                   # Card de transação reutilizável
    └── custom_input.dart                       # Input customizado
```

## Categorias

- Alimentação
- Transporte
- Saúde
- Educação
- Lazer
- Salário
- Investimento
- Outros

## Segurança

- **Autenticação** via Firebase Auth com suporte a e-mail/senha e Google OAuth
- **Criptografia AES-256 CBC** no campo `title` de cada transação armazenada no Firestore; dados legados (plaintext) são lidos sem erro via fallback no `EncryptionService`
- **Chave de criptografia** gerada aleatoriamente por dispositivo e armazenada com `flutter_secure_storage`
- **Comunicação** com Firebase sempre via HTTPS/TLS (Firebase SDK padrão)

## Comandos Úteis

```bash
# Limpar cache e reinstalar dependências
flutter clean && flutter pub get

# Análise estática de código
flutter analyze

# Implantar índices Firestore
firebase deploy --only firestore:indexes

# Build Android
flutter build apk --release

# Build iOS
flutter build ios --release
```

## Documentação Técnica

Para detalhes sobre as tecnologias, conceitos e decisões de implementação por área:
[docs/TECHNICAL.md](docs/TECHNICAL.md)

## Licença

Projeto acadêmico de código aberto.
