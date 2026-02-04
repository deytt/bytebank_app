# Bytebank App

Aplicação de gerenciamento financeiro desenvolvida com Flutter, Firebase e Provider.

## Descrição

O Bytebank App é uma aplicação acadêmica para controle financeiro pessoal, permitindo que usuários registrem suas transações financeiras (receitas e despesas), anexem recibos e visualizem estatísticas através de um dashboard intuitivo.

## Plataformas Suportadas

- ✅ Android
- ✅ iOS
- ✅ Web

## Funcionalidades

- **Autenticação**: Login e registro com email/senha via Firebase Authentication
- **Gerenciamento de Transações**:
  - Adicionar, editar e excluir transações
  - Categorização (Alimentação, Transporte, Saúde, Educação, Lazer, Salário, Investimento, Outros)
  - Upload de recibos (até 30 MB)
  - Filtros por categoria e período
  - Paginação ao rolar a lista
- **Dashboard**:
  - Visualização de saldo, receitas e despesas
  - Gráfico de pizza com distribuição financeira
  - Animações de entrada

## Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento mobile/web
- **Firebase Authentication**: Autenticação de usuários
- **Cloud Firestore**: Banco de dados NoSQL com índices
- **Firebase Storage**: Armazenamento de recibos (upload via bytes para compatibilidade multiplataforma)
- **Provider**: Gerenciamento de estado
- **FL Chart**: Gráficos financeiros
- **Image Picker**: Seleção de imagens (XFile para compatibilidade Web/Mobile)

## Pré-requisitos

- Flutter SDK (>=3.10.7)
- Dart SDK
- Android Studio / Xcode (para emuladores)
- Firebase CLI (opcional, para deploy de índices)
- Conta Firebase

## Configuração Firebase

✅ **Firebase já está configurado!**

**Projeto Firebase**: `bytebank-2778e`

O projeto já possui:
- ✅ `lib/firebase_options.dart` - Credenciais configuradas
- ✅ `firestore.indexes.json` - Índices do Firestore
- ✅ `firebase.json` - Configuração do projeto
- ✅ `.firebaserc` - Referência ao projeto

### Serviços Ativos

Os seguintes serviços já estão ativos no [Console Firebase](https://console.firebase.google.com/project/bytebank-2778e):
- ✅ **Authentication** (Email/Password)
- ✅ **Cloud Firestore** (com índices)
- ✅ **Firebase Storage**

## Instalação

1. Clone o repositório:
```bash
git clone <url-do-repositorio>
cd bytebankapp
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Configure o Firebase conforme instruções acima

4. Execute o aplicativo:
```bash
flutter run
```

## Dependências Principais

```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.5.2
  firebase_storage: ^12.3.7
  provider: ^6.1.2
  fl_chart: ^0.70.2
  intl: ^0.20.1
  image_picker: ^1.1.2
```

## Estrutura de Pastas

```
lib/
 ├── main.dart
 ├── app.dart
 ├── firebase_options.dart
 ├── core/
 │   ├── theme/
 │   │   └── app_theme.dart
 │   └── utils/
 │       └── formatters.dart
 ├── models/
 │   ├── transaction_model.dart
 │   └── user_model.dart
 ├── providers/
 │   ├── auth_provider.dart
 │   └── transaction_provider.dart
 ├── services/
 │   ├── auth_service.dart
 │   ├── transaction_service.dart
 │   └── storage_service.dart
 ├── screens/
 │   ├── login/
 │   │   └── login_screen.dart
 │   ├── dashboard/
 │   │   └── dashboard_screen.dart
 │   └── transactions/
 │       ├── transaction_list_screen.dart
 │       └── transaction_form_screen.dart
 └── widgets/
     ├── transaction_card.dart
     └── custom_input.dart
```

## Índices do Firestore

✅ **Índices já estão configurados e implantados!**

O arquivo `firestore.indexes.json` contém:
- Índice para query por `userId` + ordenação por `date`
- Índice para query por `userId` + `category` + ordenação por `date`

Para reimplantar os índices (se necessário):
```bash
firebase deploy --only firestore:indexes
```

## Regras de Segurança

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /transactions/{transaction} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null &&
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /receipts/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null &&
        request.auth.uid == userId;
    }
  }
}
```

## Como Usar

1. **Criar Conta**: Na tela inicial, clique em "Não tem uma conta? Criar" e preencha email e senha
2. **Login**: Entre com suas credenciais
3. **Dashboard**: Visualize seu saldo atual e estatísticas
4. **Adicionar Transação**:
   - Clique no botão "+"
   - Preencha título, valor, tipo, categoria e data
   - Opcionalmente, adicione um recibo
5. **Ver Transações**: Clique em "Ver Transações" ou no ícone de lista
6. **Filtrar**: Use o ícone de filtro para filtrar por categoria
7. **Editar/Excluir**: Toque em uma transação para editar ou use o ícone de lixeira para excluir

## Cores do Tema

- Primary: #4C1D95
- Primary Light: #6D28D9
- Background: #09090B
- Surface: #202024
- Text Primary: #E1E1E6
- Text Secondary: #C4C4CC
- White: #FFFFFF

## Comandos Úteis

```bash
# Limpar build
flutter clean && flutter pub get

# Análise de código
flutter analyze

# Executar app
flutter run

# Build APK (Android)
flutter build apk --release

# Build AAB (Google Play)
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Build Web
flutter build web --release

# Deploy índices Firestore
firebase deploy --only firestore:indexes
```

## Autor

Projeto acadêmico desenvolvido para demonstração de conceitos de desenvolvimento mobile com Flutter e Firebase.

## Licença

Este projeto é de uso acadêmico.
