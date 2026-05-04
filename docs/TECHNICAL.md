# Tecnologias e Conceitos

Documentação técnica do Bytebank App — detalhamento das decisões de implementação por área.

---

## Arquitetura

- **Clean Architecture** com separação estrita em três camadas: Domain, Data e Presentation
- **Domain Layer** — contém entidades puras (`User`, `Transaction`) sem dependências externas, interfaces de repositório e Use Cases com uma classe por operação de negócio
- **Data Layer** — implementações dos repositórios (`AuthRepositoryImpl`, `TransactionRepositoryImpl`), modelos de serialização (DTOs) e integração com Firestore e Hive
- **Presentation Layer** — BLoCs (`AuthBloc`, `TransactionBloc`), screens e widgets; nenhuma lógica de negócio reside aqui
- **Repository pattern** — o Domain define o contrato (`abstract class`); o Data implementa sem que a Presentation conheça a fonte de dados
- **UseCase pattern** — cada operação tem sua própria classe (`GetTransactionsUseCase`, `AddTransactionUseCase`, `SignInUseCase`, etc.), facilitando testes e substituição isolada
- **BLoC pattern** — gerenciamento de estado com `flutter_bloc`; eventos disparam transformações de estado via `mapEventToState`
- **Injeção de dependências** com `get_it` centralizada em `core/di/injection_container.dart`; repositórios registrados como `LazySingleton` e use cases como `Factory`

---

## Performance

- **Firestore aggregation queries** — uso de `sum('value')` para calcular totais de receita e despesa diretamente no servidor, sem transferir documentos para o cliente
- **Índice composto** (`type ASC`, `userId ASC`, `value ASC`) em `firestore.indexes.json` para habilitar as aggregation queries
- **Fallback automático** — enquanto o índice não está disponível (`FAILED_PRECONDITION`), o app computa os totais via scan completo da coleção no cliente, sem interromper o fluxo
- **Carregamento paralelo** — `Future.wait` executa a busca de agregados e a busca de transações simultaneamente, reduzindo o tempo total de resposta do dashboard
- **`bloc_concurrency` com `restartable`** — eventos `LoadTransactions` subsequentes cancelam o processamento do anterior, evitando corridas e requisições obsoletas

---

## Segurança

- **Autenticação Firebase Auth** — suporte a e-mail/senha e Google OAuth; erros mapeados para mensagens amigáveis ao usuário
- **Google Sign-In (OAuth)** — integração com `google_sign_in`; credencial repassada ao Firebase Auth
- **Criptografia AES-256 CBC** — o campo `title` de cada transação é criptografado antes de ser salvo no Firestore e decriptografado na leitura, via `EncryptionService` (`encrypt` + `pointycastle`)
- **Chave de criptografia por dispositivo** — gerada aleatoriamente no primeiro uso e armazenada com `flutter_secure_storage`; nunca trafega pela rede
- **Fallback para dados legados** — o `EncryptionService.decrypt()` detecta texto plano e retorna o valor original sem erro, garantindo compatibilidade com registros anteriores à implementação da criptografia
- **Comunicação cifrada** — toda a troca de dados com Firebase ocorre via HTTPS/TLS (padrão do SDK)

---

## UI/UX

- **Refatoração do Dashboard** — arquivo reduzido de ~2100 para ~460 linhas com extração de 6 widgets reutilizáveis: `BalanceCard`, `ChartCard`, `ServicesSection`, `StoriesSection`, `CarouselSection` e `UserAccountModal`
- **Animações sequenciais consolidadas** — 8 `AnimationController`s foram substituídos por um único `_pageController` com `Interval`s nomeados (`_fadeInterval`, `_slideInterval`, etc.), usando `SingleTickerProviderStateMixin`
- **Tema centralizado** — todas as cores definidas em `AppTheme`; nenhum valor hexadecimal direto nos widgets. Constantes adicionadas: `black`, `white`, `googleBlue`, `gradientBlue`, `gradientGreen`, `gradientAmber`, `balanceSurface`, `chartBlue`, `chartAmber`
- **Gráfico interativo** — `FL Chart` com seletor de período (Total, Últimos 12 meses, Últimos 3 meses) e alternância entre gráfico de linha e barras
- **Filtros de transações** — busca por título, categoria, tipo (receita/despesa), presença de recibo e intervalo de datas (15, 30 ou 90 dias)

---

## Lazy Loading e Cache

- **Cursor-based pagination** — paginação baseada em `DocumentSnapshot` (último documento retornado como cursor), evitando o uso de `offset` e garantindo consistência mesmo com inserções concorrentes
- **Carregamento progressivo** — 20 transações por página; novas páginas são disparadas por scroll (`LoadTransactions` com `loadMore: true`)
- **Cache offline com Hive** — a primeira página de transações é persistida localmente em uma `Box` do Hive ao ser carregada do Firestore
- **Leitura offline** — se a consulta ao Firestore falhar (sem conexão), o app exibe os dados em cache sem erro visível ao usuário
- **Invalidação de cache** — a `Box` é limpa sempre que uma transação é adicionada, atualizada ou excluída, garantindo que o cache não sirva dados desatualizados

---

## Tecnologias e Conceitos

| Pacote | Versão | Finalidade |
|---|---|---|
| `flutter` | SDK | Framework mobile multiplataforma |
| `firebase_core` | ^3.8.1 | Inicialização do Firebase |
| `firebase_auth` | ^5.3.4 | Autenticação (e-mail/senha + Google OAuth) |
| `cloud_firestore` | ^5.5.2 | Banco de dados NoSQL + aggregation queries |
| `firebase_storage` | ^12.3.7 | Armazenamento de recibos (imagens) |
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
