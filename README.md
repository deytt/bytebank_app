# Bytebank App

Aplicação mobile de gerenciamento financeiro desenvolvida com Flutter e Firebase.

## 📱 Descrição

O Bytebank App é uma aplicação acadêmica para controle financeiro pessoal, permitindo que usuários registrem transações (receitas e despesas), anexem recibos e visualizem estatísticas em um dashboard.

## ✨ Funcionalidades

- **Autenticação**: Login e cadastro com email/senha
- **Transações**: Criar, editar e excluir transações com upload de recibos
- **Dashboard**: Visualização de saldo, receitas, despesas e gráfico
- **Filtros**: Buscar por título, categoria, tipo (receita/despesa), presença de recibo e período (15, 30 ou 90 dias)
- **Paginação**: Carregamento progressivo de transações

## 🛠️ Tecnologias

- **Flutter** - Framework mobile
- **Firebase Auth** - Autenticação
- **Cloud Firestore** - Banco de dados
- **Firebase Storage** - Armazenamento de recibos
- **Provider** - Gerenciamento de estado
- **FL Chart** - Gráficos

## 📋 Pré-requisitos

Antes de executar o projeto, certifique-se de ter o Flutter instalado e configurado em sua máquina.

### Instalação do Flutter

Para instalar o Flutter, siga o guia oficial para seu sistema operacional:

**📖 Documentação oficial:** https://docs.flutter.dev/get-started/install

**Verificar instalação:**
```bash
flutter doctor
```

Este comando verifica se todas as dependências necessárias estão instaladas (Flutter SDK, Android Studio, Xcode, etc.).

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
- `lib/firebase_options.dart` - Credenciais
- `android/app/google-services.json` - Configuração Android
- `ios/Runner/GoogleService-Info.plist` - Configuração iOS

**Console Firebase**: https://console.firebase.google.com/project/bytebank-2778e

## 📂 Estrutura

```
lib/
├── main.dart                      # Ponto de entrada
├── app.dart                       # Widget principal
├── core/
│   ├── theme/
│   │   └── app_theme.dart         # Tema
│   └── utils/
│       └── formatters.dart        # Formatadores
├── models/
│   ├── transaction_model.dart     # Modelo de transação
│   └── user_model.dart            # Modelo de usuário
├── providers/
│   ├── auth_provider.dart         # Provider de autenticação
│   └── transaction_provider.dart  # Provider de transações
├── services/
│   ├── auth_service.dart          # Serviço de autenticação
│   ├── transaction_service.dart   # Serviço de transações
│   └── storage_service.dart       # Serviço de storage
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart     # Splash screen
│   ├── login/
│   │   └── login_screen.dart      # Login
│   ├── dashboard/
│   │   └── dashboard_screen.dart  # Dashboard
│   └── transactions/
│       ├── transaction_list_screen.dart   # Lista
│       └── transaction_form_screen.dart   # Formulário
└── widgets/
    ├── transaction_card.dart      # Card de transação
    └── custom_input.dart          # Input customizado
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
