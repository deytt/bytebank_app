# Bytebank App

Aplicação mobile de gerenciamento financeiro desenvolvida com Flutter, Firebase e Provider.

## Descrição

O Bytebank App é uma aplicação acadêmica para controle financeiro pessoal, permitindo que usuários registrem suas transações financeiras (receitas e despesas), anexem recibos e visualizem estatísticas através de um dashboard intuitivo.

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

- **Flutter**: Framework de desenvolvimento mobile
- **Firebase Authentication**: Autenticação de usuários
- **Cloud Firestore**: Banco de dados NoSQL
- **Firebase Storage**: Armazenamento de recibos
- **Provider**: Gerenciamento de estado
- **FL Chart**: Gráficos financeiros
- **Image Picker**: Seleção de imagens

## Pré-requisitos

- Flutter SDK (>=3.10.7)
- Dart SDK
- Android Studio / Xcode
- Conta Firebase

## Configuração Firebase

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicione um aplicativo Android com o ID: `com.postech.bytebankapp`
3. Baixe o arquivo `google-services.json` e coloque em `android/app/`
4. Para iOS, baixe o `GoogleService-Info.plist` e adicione ao projeto
5. Ative os seguintes serviços no Firebase:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Storage

6. Configure as credenciais no arquivo `lib/core/firebase/firebase_config.dart`:

```dart
static FirebaseOptions get firebaseOptions {
  return const FirebaseOptions(
    apiKey: 'SUA_API_KEY',
    appId: 'SEU_APP_ID',
    messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
    projectId: 'SEU_PROJECT_ID',
    storageBucket: 'SEU_STORAGE_BUCKET',
  );
}
```

## Instalação

1. Clone o repositório:
```bash
git clone <url-do-repositorio>
cd bytebank_app
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
 ├── core/
 │   ├── firebase/
 │   │   └── firebase_config.dart
 │   └── theme/
 │       └── app_theme.dart
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

## Regras de Firestore

Configure as seguintes regras no Firestore:

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

## Regras de Storage

Configure as seguintes regras no Storage:

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

## Autor

Projeto acadêmico desenvolvido para demonstração de conceitos de desenvolvimento mobile com Flutter e Firebase.

## Licença

Este projeto é de uso acadêmico.
