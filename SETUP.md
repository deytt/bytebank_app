# Configuração do Projeto Bytebank App

## ✅ Estrutura Criada

```
lib/
├── main.dart                           # Ponto de entrada da aplicação
├── app.dart                            # Widget principal do app
├── core/
│   ├── firebase/
│   │   └── firebase_config.dart        # Configurações do Firebase
│   ├── theme/
│   │   └── app_theme.dart              # Tema global da aplicação
│   └── utils/
│       └── formatters.dart             # Utilitários de formatação
├── models/
│   ├── transaction_model.dart          # Modelo de transação
│   └── user_model.dart                 # Modelo de usuário
├── providers/
│   ├── auth_provider.dart              # Provider de autenticação
│   └── transaction_provider.dart       # Provider de transações
├── services/
│   ├── auth_service.dart               # Serviço de autenticação
│   ├── transaction_service.dart        # Serviço de transações
│   └── storage_service.dart            # Serviço de armazenamento
├── screens/
│   ├── login/
│   │   └── login_screen.dart           # Tela de login/cadastro
│   ├── dashboard/
│   │   └── dashboard_screen.dart       # Dashboard principal
│   └── transactions/
│       ├── transaction_list_screen.dart # Lista de transações
│       └── transaction_form_screen.dart # Formulário de transação
└── widgets/
    ├── transaction_card.dart           # Card de transação
    └── custom_input.dart               # Input customizado
```

## 📦 Dependências Instaladas

- ✅ firebase_core: ^3.8.1
- ✅ firebase_auth: ^5.3.4
- ✅ cloud_firestore: ^5.5.2
- ✅ firebase_storage: ^12.3.7
- ✅ provider: ^6.1.2
- ✅ fl_chart: ^0.70.2
- ✅ intl: ^0.20.1
- ✅ image_picker: ^1.1.2

## 🎨 Cores do Tema

```dart
Primary: #4C1D95 (roxo escuro)
Primary Light: #6D28D9 (roxo médio)
Background: #09090B (preto)
Surface: #202024 (cinza escuro)
Text Primary: #E1E1E6 (branco)
Text Secondary: #C4C4CC (cinza claro)
White: #FFFFFF
```

## 🔧 Próximos Passos

### 1. Configurar Firebase

Acesse: https://console.firebase.google.com/

1. Crie um novo projeto
2. Adicione um app Android com ID: `com.postech.bytebankapp`
3. Baixe o arquivo `google-services.json`
4. Coloque em: `android/app/google-services.json`
5. Para iOS, baixe `GoogleService-Info.plist` e adicione ao projeto

### 2. Ativar Serviços Firebase

No Console Firebase, ative:

- **Authentication** → Método: Email/Password
- **Firestore Database** → Criar banco em modo teste
- **Storage** → Criar bucket em modo teste

### 3. Configurar Credenciais

Edite o arquivo: `lib/core/firebase/firebase_config.dart`

Substitua os valores:
```dart
apiKey: 'SUA_API_KEY',
appId: 'SEU_APP_ID',
messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
projectId: 'SEU_PROJECT_ID',
storageBucket: 'SEU_STORAGE_BUCKET',
```

### 4. Regras de Segurança

#### Firestore Rules
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

#### Storage Rules
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

### 5. Executar o Projeto

```bash
# Instalar dependências (já feito)
flutter pub get

# Verificar código (análise passou sem erros)
flutter analyze

# Executar no emulador/dispositivo
flutter run
```

## 📱 Funcionalidades Implementadas

### ✅ Autenticação
- Login com email/senha
- Cadastro de novos usuários
- Validação de formulários
- Proteção de rotas

### ✅ Transações
- Adicionar transação (receita/despesa)
- Editar transação
- Excluir transação
- Upload de recibos (até 30 MB)
- Filtro por categoria
- Ordenação por data
- Paginação

### ✅ Dashboard
- Visualização de saldo
- Total de receitas/despesas
- Gráfico de pizza
- Animação de entrada

### ✅ UI/UX
- Tema dark personalizado
- Cards responsivos
- Inputs customizados
- Feedback visual
- Navegação fluida

## 🎯 Estrutura de Dados

### Transaction Model
```dart
{
  id: String
  userId: String
  title: String
  value: double
  category: String
  type: "income" | "expense"
  date: DateTime
  receiptUrl?: String
}
```

### User Model
```dart
{
  id: String
  email: String
}
```

## 🚀 Comandos Úteis

```bash
# Limpar build
flutter clean && flutter pub get

# Análise de código
flutter analyze

# Formatar código
flutter format lib/

# Verificar dependências desatualizadas
flutter pub outdated

# Build APK
flutter build apk --release

# Build AAB (para Play Store)
flutter build appbundle --release
```

## ⚠️ Observações Importantes

1. **Firebase Config**: Lembre-se de configurar suas credenciais antes de rodar
2. **Permissões**: AndroidManifest já configurado com permissões necessárias
3. **MinSdk**: Configurado para Android 21 (Lollipop) ou superior
4. **MultiDex**: Habilitado para suportar Firebase
5. **Análise**: Código passou sem erros ou warnings

## 📝 Application ID

```
Android: com.postech.bytebankapp
Namespace: com.postech.bytebankapp
```

## 📚 Documentação Adicional

- [Firebase Flutter](https://firebase.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [FL Chart](https://pub.dev/packages/fl_chart)
- [Image Picker](https://pub.dev/packages/image_picker)

---

Projeto acadêmico desenvolvido para demonstração de conceitos Flutter + Firebase.
