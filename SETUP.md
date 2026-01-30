# Guia de Configuração do Bytebank App

## 📱 Plataformas Suportadas

- ✅ **Android** (MinSdk 21 / Android 5.0+)
- ✅ **iOS** (iOS 12.0+)
- ✅ **Web** (navegadores modernos)

## ✅ Estrutura do Projeto

```
bytebank_app/
├── android/                            # Configuração Android
├── ios/                                # Configuração iOS
├── web/                                # Configuração Web
├── lib/
│   ├── main.dart                       # Ponto de entrada
│   ├── app.dart                        # Widget principal
│   ├── firebase_options.dart           # Credenciais Firebase
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Tema global
│   │   └── utils/
│   │       └── formatters.dart         # Utilitários
│   ├── models/
│   │   ├── transaction_model.dart      # Modelo de transação
│   │   └── user_model.dart             # Modelo de usuário
│   ├── providers/
│   │   ├── auth_provider.dart          # Provider de auth
│   │   └── transaction_provider.dart   # Provider de transações
│   ├── services/
│   │   ├── auth_service.dart           # Serviço de auth
│   │   ├── transaction_service.dart    # Serviço de transações
│   │   └── storage_service.dart        # Serviço de storage
│   ├── screens/
│   │   ├── login/
│   │   │   └── login_screen.dart       # Tela de login
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart   # Dashboard
│   │   └── transactions/
│   │       ├── transaction_list_screen.dart  # Lista
│   │       └── transaction_form_screen.dart  # Formulário
│   └── widgets/
│       ├── transaction_card.dart       # Card de transação
│       └── custom_input.dart           # Input customizado
├── firebase.json                       # Configuração Firebase
├── firestore.indexes.json              # Índices do Firestore
├── .firebaserc                         # Referência ao projeto
├── pubspec.yaml                        # Dependências
└── README.md                           # Documentação
```

## 📦 Dependências Instaladas

- ✅ **firebase_core**: ^3.8.1 - Core Firebase
- ✅ **firebase_auth**: ^5.3.4 - Autenticação
- ✅ **cloud_firestore**: ^5.5.2 - Banco de dados
- ✅ **firebase_storage**: ^12.3.7 - Armazenamento de arquivos
- ✅ **provider**: ^6.1.2 - Gerenciamento de estado
- ✅ **fl_chart**: ^0.70.2 - Gráficos
- ✅ **intl**: ^0.20.1 - Formatação i18n
- ✅ **image_picker**: ^1.1.2 - Seleção de imagens (multiplataforma)

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

## 🔥 Configuração Firebase

### ✅ Status Atual

O projeto já está **totalmente configurado** com Firebase:

- ✅ **Projeto**: `bytebank-2778e`
- ✅ **Credenciais**: `lib/firebase_options.dart`
- ✅ **Índices**: `firestore.indexes.json` (implantados)
- ✅ **Authentication**: Email/Password ativo
- ✅ **Firestore**: Database ativo com índices
- ✅ **Storage**: Bucket ativo

### Acesso ao Console

🔗 [Firebase Console - Bytebank](https://console.firebase.google.com/project/bytebank-2778e)

### Índices do Firestore

Os índices já estão implantados. Para verificar ou reimplantar:

```bash
# Ver status dos índices
firebase firestore:indexes

# Reimplantar índices
firebase deploy --only firestore:indexes
```

## 🔒 Regras de Segurança

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

## 🚀 Executar o Projeto

### Instalação Inicial

```bash
# 1. Instalar dependências
flutter pub get

# 2. Verificar configuração
flutter doctor

# 3. Analisar código
flutter analyze
```

### Executar em Diferentes Plataformas

```bash
# Android
flutter run

# iOS (apenas em macOS)
flutter run -d ios

# Web
flutter run -d chrome

# Dispositivo específico
flutter devices  # listar dispositivos
flutter run -d <device-id>
```

### Build para Produção

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Google Play)
flutter build appbundle --release

# iOS (apenas em macOS)
flutter build ios --release

# Web
flutter build web --release
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

## 🛠️ Comandos Úteis

```bash
# Limpar cache e rebuild
flutter clean && flutter pub get

# Análise de código
flutter analyze

# Formatar código
flutter format lib/

# Verificar dependências
flutter pub outdated

# Hot reload (durante desenvolvimento)
r  # na linha de comando do Flutter

# Hot restart
R  # na linha de comando do Flutter

# Logs do dispositivo
flutter logs
```

## ⚠️ Informações Importantes

### Configuração Android
- **Application ID**: `com.postech.bytebankapp`
- **MinSdk**: 21 (Android 5.0 Lollipop+)
- **TargetSdk**: 36
- **MultiDex**: Habilitado
- **Permissões**: Internet, Câmera, Storage

### Configuração iOS
- **Bundle ID**: `com.postech.bytebankapp`
- **MinVersion**: 12.0
- **Arquiteturas**: arm64, x86_64

### Firebase
- ✅ **Authentication**: Email/Password
- ✅ **Firestore**: Índices implantados
- ✅ **Storage**: Bucket configurado (upload via bytes para compatibilidade Web)
- ⚠️ **App Check**: Não configurado (opcional)

### Implementação Multiplataforma
- ✅ **Upload de Imagens**: Usa `XFile` + bytes (funciona em Web/Mobile)
- ✅ **Preview de Imagens**: Usa `MemoryImage` (compatível com Web)
- ✅ **Sem dependências de `dart:io`**: Código 100% multiplataforma

## 🐛 Resolução de Problemas

### Erro: "The query requires an index"

**Solução**: Deploy dos índices do Firestore
```bash
firebase deploy --only firestore:indexes
```

### Erro: Layout overflow no TransactionCard

✅ **Já corrigido!** O widget usa `Flexible` para evitar overflow.

### Erro: "Unsupported operation: _Namespace" na Web

✅ **Já corrigido!** Implementação multiplataforma:
- Usa `XFile` do `image_picker` ao invés de `File` do `dart:io`
- Upload via `putData()` com bytes ao invés de `putFile()`
- Preview de imagem com `MemoryImage` ao invés de `FileImage`
- **Resultado**: Funciona perfeitamente em Android, iOS e Web

### Avisos do Google Play Services no emulador

⚠️ **Normal em emuladores sem Play Store**. Os avisos não impedem o funcionamento:
- `ProviderInstaller failed`
- `App Check token error`
- `GoogleApiManager failed`

### Build Android falha

```bash
# Limpar e rebuild
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

## 📊 Estrutura de Dados

### Collection: `transactions`
```json
{
  "id": "auto-generated",
  "userId": "string",
  "title": "string",
  "value": "number",
  "category": "string",
  "type": "income | expense",
  "date": "timestamp",
  "receiptUrl": "string | null"
}
```

### Categorias Disponíveis
- Alimentação
- Transporte
- Saúde
- Educação
- Lazer
- Salário
- Investimento
- Outros

## 📚 Recursos e Documentação

### Flutter & Dart
- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Language](https://dart.dev/guides)
- [Widget Catalog](https://docs.flutter.dev/ui/widgets)

### Firebase
- [Firebase Flutter](https://firebase.flutter.dev/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- [Firestore Docs](https://firebase.google.com/docs/firestore)

### Packages
- [Provider](https://pub.dev/packages/provider) - Gerenciamento de estado
- [FL Chart](https://pub.dev/packages/fl_chart) - Gráficos
- [Image Picker](https://pub.dev/packages/image_picker) - Seleção de imagens
- [Intl](https://pub.dev/packages/intl) - Formatação de data/moeda

## 👥 Suporte

Para dúvidas ou problemas:
1. Verifique a seção de Resolução de Problemas acima
2. Consulte o [README.md](./README.md)
3. Acesse o [Console Firebase](https://console.firebase.google.com/project/bytebank-2778e)

---

**Projeto acadêmico** desenvolvido para demonstração de conceitos Flutter + Firebase.
