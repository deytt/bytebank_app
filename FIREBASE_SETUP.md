# Configuração de Arquivos Sensíveis do Firebase

Este documento explica como configurar os arquivos de credenciais do Firebase que **não estão** incluídos no repositório por segurança.

## ⚠️ Arquivos Ignorados pelo Git

Os seguintes arquivos não estão versionados no Git e devem ser obtidos do Firebase Console:

- `android/app/google-services.json` (Android)
- `ios/Runner/GoogleService-Info.plist` (iOS)
- `firepit-log.txt` (log local do Firebase CLI)

## 📱 Configurar Android (google-services.json)

### Passo 1: Baixar do Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/project/bytebank-2778e)
2. Vá em **Configurações do Projeto** (ícone de engrenagem)
3. Role até **Seus apps** → encontre o app Android
4. Clique em **google-services.json** para baixar

### Passo 2: Instalar o Arquivo

```bash
# Copie o arquivo baixado para:
android/app/google-services.json
```

### Estrutura Esperada

Um arquivo de exemplo está disponível em `android/app/google-services.json.example` para referência.

## 🍎 Configurar iOS (GoogleService-Info.plist)

### Passo 1: Baixar do Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/project/bytebank-2778e)
2. Vá em **Configurações do Projeto**
3. Role até **Seus apps** → encontre o app iOS
4. Clique em **GoogleService-Info.plist** para baixar

### Passo 2: Instalar o Arquivo

```bash
# Copie o arquivo baixado para:
ios/Runner/GoogleService-Info.plist
```

## ✅ Verificar Configuração

Após adicionar os arquivos, execute:

```bash
# Limpar cache
flutter clean

# Reinstalar dependências
flutter pub get

# Executar o app
flutter run
```

## 🔒 Segurança

**IMPORTANTE**: Esses arquivos contêm chaves de API e **não devem** ser commitados no Git!

- ✅ Já estão no `.gitignore`
- ✅ Use os arquivos `.example` como referência
- ❌ **NUNCA** faça commit dos arquivos reais

## 🆘 Obtendo Ajuda

Se você não tem acesso ao Firebase Console:
1. Peça ao administrador do projeto para adicionar você
2. Ou peça que o administrador compartilhe os arquivos por canal seguro

---

**Projeto**: bytebank-2778e
**Package Name**: com.postech.bytebankapp
