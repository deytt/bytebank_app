# Documentação Técnica — Bytebank App

Detalhamento das decisões de implementação por área.

---

## Arquitetura

- **Clean Architecture** com separação estrita em três camadas: Domain, Data e Presentation
- **Domain Layer** — entidades puras (`User`, `Transaction`) sem dependências externas, interfaces de repositório e Use Cases com uma classe por operação de negócio
- **Data Layer** — implementações dos repositórios (`AuthRepositoryImpl`, `TransactionRepositoryImpl`), modelos de serialização (DTOs) e integração com Firestore e Hive
- **Presentation Layer** — BLoCs (`AuthBloc`, `TransactionBloc`), screens e widgets; nenhuma lógica de negócio reside aqui
- **Repository pattern** — o Domain define o contrato (`abstract class`); o Data implementa sem que a Presentation conheça a fonte de dados
- **UseCase pattern** — cada operação tem sua própria classe (`GetTransactionsUseCase`, `AddTransactionUseCase`, `SignInUseCase`, etc.), facilitando testes e substituição isolada
- **BLoC pattern** — gerenciamento de estado com `flutter_bloc`; eventos disparam transformações de estado; `restartable()` em `LoadTransactions` cancela requisições obsoletas
- **Injeção de dependências** com `get_it` centralizada em `core/di/injection_container.dart`; repositórios como `LazySingleton`, use cases como `Factory`

---

## Performance

- **Firestore aggregation queries** — uso de `sum('value')` para calcular totais de receita e despesa diretamente no servidor, sem transferir documentos para o cliente
- **Índice composto** (`type ASC`, `userId ASC`, `value ASC`) em `firestore.indexes.json` para habilitar as aggregation queries
- **Fallback automático** — enquanto o índice não está disponível (`FAILED_PRECONDITION`), o app computa os totais via scan completo da coleção no cliente, sem interromper o fluxo
- **Carregamento paralelo** — busca de agregados e transações executados simultaneamente, reduzindo o tempo total de resposta
- **`bloc_concurrency` com `restartable`** — eventos `LoadTransactions` subsequentes cancelam o processamento do anterior, evitando corridas e requisições obsoletas

---

## Segurança

- **Firebase Auth** — suporte a e-mail/senha e Google OAuth; erros mapeados para mensagens amigáveis ao usuário
- **Google Sign-In (OAuth)** — integração com `google_sign_in`; credencial repassada ao Firebase Auth via `GoogleAuthProvider.credential`
- **Criptografia AES-256 CBC** — o campo `title` de cada transação é criptografado antes de ser salvo no Firestore e decriptografado na leitura, via `EncryptionService` (pacote `encrypt`)
- **Chave de criptografia por dispositivo** — gerada aleatoriamente no primeiro uso e armazenada com `flutter_secure_storage`; nunca trafega pela rede
- **Fallback para dados legados** — `EncryptionService.decrypt()` retorna o valor original sem erro quando o `_encrypter` não está inicializado ou o texto não é um ciphertext válido
- **Firebase Security Rules** — regras de Firestore e Storage implantadas em `firestore.rules` e `storage.rules`:
  - Cada documento `transactions` só pode ser lido/escrito pelo usuário dono (`userId == request.auth.uid`)
  - Criação valida campos obrigatórios, `value > 0` e `type in ['income', 'expense']`
  - Update impede alteração do `userId`
  - Storage restringe uploads a `image/*` com limite de 30 MB por arquivo
  - Qualquer coleção ou caminho não mapeado é bloqueado por padrão (`allow read, write: if false`)
- **Comunicação** via HTTPS/TLS (Firebase SDK padrão)

---

## Lazy Loading e Cache

- **Cursor-based pagination** — paginação baseada em `DocumentSnapshot` (último documento retornado como cursor), evitando `offset` e garantindo consistência com inserções concorrentes
- **20 transações por página** — novas páginas disparadas por scroll ao atingir 80% da lista (`LoadMoreTransactions`)
- **Cache offline com Hive** — primeira página de transações, agregados e transações do gráfico persistidos em `Box` separadas por `userId` (`tx_$userId`)
- **Leitura offline** — se a consulta ao Firestore falhar sem conexão, o app exibe os dados em cache sem erro visível ao usuário
- **Invalidação de cache** — a `Box` é limpa sempre que uma transação é adicionada, atualizada ou excluída
- **Limitação com filtros locais** — filtros de `searchTitle`, `hasReceipt` e `type` não podem ser feitos diretamente no Firestore por limitações de índice; nesses casos o `effectiveLimit` sobe para 1000 e a filtragem é feita no cliente

---

## Testes

- **Escopo:** entidades, use cases e BLoCs — camadas que não dependem de plugins nativos (Firebase, Hive, FlutterSecureStorage)
- **Repositórios concretos** excluídos do escopo de testes unitários por dependerem de infraestrutura de plataforma
- **73 testes** organizados seguindo a pirâmide de testes:

| Camada | Arquivos | Casos cobertos |
|---|---|---|
| Entities | `user_test.dart`, `transaction_test.dart` | Getters `initials`, `firstName`, `copyWith` |
| Use Cases Auth | 5 arquivos | Caminho feliz, propagação de erros, retorno null |
| Use Cases Transactions | 5 arquivos | Com/sem receipt bytes, sequência de chamadas ao repositório |
| BLoC Auth | `auth_bloc_test.dart` | 11 cenários — todos os eventos e transições de estado |
| BLoC Transactions | `transaction_bloc_test.dart` | 11 cenários — Load, LoadMore, Add, Update, Delete, ClearFilters |

- **Mocks** via `mocktail` sem geração de código — `MockAuthRepository`, `MockTransactionRepository` e mocks de todos os use cases centralizados em `test/helpers/mocks.dart`
- **BLoC tests** via `bloc_test` — `blocTest` com `build`, `act`, `expect`, `seed`

---

## CI/CD

### Workflow CI — Pull Requests

Arquivo: `.github/workflows/ci.yml`
Trigger: pull request apontando para `master`

Etapas:
1. `actions/checkout@v4` — checkout do código
2. `subosito/flutter-action@v2` — Flutter 3.38.8 com cache de SDK
3. `flutter pub get`
4. `flutter analyze` — análise estática (falha em qualquer warning ou info)
5. `flutter test` — 73 testes unitários
6. `flutter build apk --debug` — verifica se o build compila

### Workflow CD — Deploy

Arquivo: `.github/workflows/cd.yml`
Trigger: push na branch `master` (merge de PR)

Etapas:
1. `actions/checkout@v4`
2. `subosito/flutter-action@v2` — Flutter 3.38.8 com cache de SDK
3. Restauração do keystore a partir do secret `KEYSTORE_BASE64`
4. Geração do `android/key.properties` a partir dos secrets
5. `flutter pub get`
6. `flutter build apk --release` — APK assinado com o keystore de release
7. `wzieba/Firebase-Distribution-Github-Action@v1` — upload para Firebase App Distribution com nota de release contendo SHA do commit

Secrets necessários no repositório GitHub:

| Secret | Descrição |
|---|---|
| `FIREBASE_APP_ID` | ID do app Android no Firebase |
| `FIREBASE_TOKEN` | Token gerado por `firebase login:ci` |
| `KEYSTORE_BASE64` | Arquivo `.jks` codificado em Base64 |
| `KEY_ALIAS` | Alias da chave de assinatura |
| `KEY_PASSWORD` | Senha da chave |
| `STORE_PASSWORD` | Senha do keystore |

---

## UI/UX

- **Dashboard componentizado** — extraídos 6 widgets reutilizáveis: `BalanceCard`, `ChartCard`, `ServicesSection`, `StoriesSection`, `CarouselSection` e `UserAccountModal`
- **Animações sequenciais consolidadas** — único `AnimationController` com `Interval`s nomeados (`_fadeInterval`, `_slideInterval`, etc.) via `SingleTickerProviderStateMixin`
- **Tema centralizado** — todas as cores definidas em `AppTheme` com `ThemeExtension<AppThemeTokens>`; nenhum valor hexadecimal direto nos widgets
- **Gráfico interativo** — `FL Chart` com seletor de período (Total, Últimos 12 meses, Últimos 3 meses) e alternância entre linha e barras

---

## Pacotes

| Pacote | Versão | Finalidade |
|---|---|---|
| `firebase_core` | ^3.8.1 | Inicialização do Firebase |
| `firebase_auth` | ^5.3.4 | Autenticação (e-mail/senha + Google OAuth) |
| `cloud_firestore` | ^5.5.2 | Banco de dados NoSQL + aggregation queries |
| `firebase_storage` | ^12.3.7 | Armazenamento de recibos |
| `flutter_bloc` | ^8.1.4 | Gerenciamento de estado com BLoC pattern |
| `bloc` | ^8.1.4 | Núcleo do BLoC |
| `bloc_concurrency` | ^0.2.5 | Controle de eventos concorrentes (`restartable`) |
| `equatable` | ^2.0.5 | Comparação de igualdade em estados e eventos |
| `get_it` | ^9.2.1 | Service locator para injeção de dependências |
| `google_sign_in` | ^6.2.1 | Autenticação OAuth com Google |
| `encrypt` | ^5.0.3 | Criptografia AES-256 CBC |
| `flutter_secure_storage` | ^9.2.2 | Armazenamento seguro da chave de criptografia |
| `hive_flutter` | ^1.1.0 | Cache local offline (key-value store) |
| `fl_chart` | ^0.70.2 | Gráficos de linha e barras |
| `image_picker` | ^1.1.2 | Seleção de imagem da galeria/câmera |
| `flutter_svg` | ^2.0.16 | Renderização de assets SVG |
| `intl` | ^0.20.1 | Formatação de moeda e datas |
| `cupertino_icons` | ^1.0.8 | Ícones estilo iOS |
| `bloc_test` | ^9.1.0 | Utilitários de teste para BLoC (`blocTest`) |
| `mocktail` | ^1.0.0 | Mocking sem geração de código |
| `flutter_lints` | ^6.0.0 | Regras de lint recomendadas |
