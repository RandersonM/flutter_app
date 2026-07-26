# Configuração do Firebase para Autenticação

> **Nota:** os passos no Firebase/Google Cloud Console abaixo continuam válidos. A seção "Estrutura do Projeto" reflete uma versão antiga do layout (`lib/screens/`); a estrutura atual usa `lib/features/auth/` — veja [`architecture-overview.md`](./architecture-overview.md).

Este guia te ajudará a configurar a autenticação Firebase com Google no seu app OpFan.

## Pré-requisitos

1. Conta do Firebase (https://firebase.google.com)
2. Conta do Google Cloud Console (https://console.cloud.google.com)
3. Flutter SDK configurado

## Passos para Configuração

### 1. Criar Projeto no Firebase

1. Acesse o [Console do Firebase](https://console.firebase.google.com)
2. Clique em "Criar projeto" ou "Adicionar projeto"
3. Digite o nome do seu projeto (ex: "opfan-app")
4. Aceite os termos e clique em "Continuar"
5. Desabilite o Google Analytics (opcional para este projeto)
6. Clique em "Criar projeto"

### 2. Configurar Aplicativo Android

1. No console do Firebase, clique em "Adicionar app" → ícone do Android
2. Preencha as informações:
   - **Package name**: `com.example.opfan` (ou seu package name)
   - **App nickname**: `OpFan Android`
   - **SHA-1**: Obtenha executando `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
3. Clique em "Registrar app"
4. Baixe o arquivo `google-services.json`
5. **IMPORTANTE**: Substitua o arquivo `android/app/google-services.json` do projeto pelo arquivo baixado
6. Clique em "Próxima" e siga as instruções até finalizar

### 3. Configurar Aplicativo iOS

1. No console do Firebase, clique em "Adicionar app" → ícone do iOS
2. Preencha as informações:
   - **Bundle ID**: `com.example.opfan` (ou seu bundle ID)
   - **App nickname**: `OpFan iOS`
3. Clique em "Registrar app"
4. Baixe o arquivo `GoogleService-Info.plist`
5. **IMPORTANTE**: Substitua o arquivo `ios/Runner/GoogleService-Info.plist` do projeto pelo arquivo baixado
6. Abra o projeto iOS no Xcode e arraste o arquivo `GoogleService-Info.plist` para a pasta `Runner`
7. Clique em "Próxima" e siga as instruções até finalizar

### 4. Configurar Autenticação

1. No console do Firebase, vá para "Authentication" → "Sign-in method"
2. Clique em "Google" e habilite
3. Preencha:
   - **Project public-facing name**: `OpFan`
   - **Project support email**: seu email
4. Clique em "Salvar"

### 5. Configurar Google Sign-In

#### Para Android:
1. Vá para [Google Cloud Console](https://console.cloud.google.com)
2. Selecione seu projeto Firebase
3. Vá para "APIs e Serviços" → "Credenciais"
4. Clique em "Criar credenciais" → "ID do cliente OAuth 2.0"
5. Selecione "Aplicativo Android"
6. Preencha:
   - **Nome**: `OpFan Android`
   - **Package name**: `com.example.opfan`
   - **Certificado SHA-1**: o mesmo usado no Firebase
7. Clique em "Criar"

#### Para iOS:
1. No Google Cloud Console, clique em "Criar credenciais" → "ID do cliente OAuth 2.0"
2. Selecione "Aplicativo iOS"
3. Preencha:
   - **Nome**: `OpFan iOS`
   - **Bundle ID**: `com.example.opfan`
4. Clique em "Criar"
5. Baixe o arquivo de configuração e substitua o `GoogleService-Info.plist`

### 6. Atualizar Configurações do Projeto

#### Android (`android/app/build.gradle`):
```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

#### iOS (`ios/Runner/Info.plist`):
Adicione antes do `</dict>` final:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

Substitua `YOUR_REVERSED_CLIENT_ID` pelo valor encontrado no arquivo `GoogleService-Info.plist`.

### 7. Testar a Configuração

1. Execute o app: `flutter run`
2. Toque no botão "Entrar com Google"
3. Faça login com sua conta Google
4. Verifique se o login foi bem-sucedido

## Estrutura do Projeto

A autenticação foi implementada seguindo os padrões do projeto:

```
lib/
├── core/
│   ├── auth/
│   │   ├── models/
│   │   │   └── user_model.dart          # Modelo do usuário
│   │   ├── blocs/
│   │   │   ├── auth_bloc.dart           # BLoC de autenticação
│   │   │   ├── auth_event.dart          # Eventos de autenticação
│   │   │   ├── auth_state.dart          # Estados de autenticação
│   │   │   └── index.dart               # Exports
│   │   └── app_wrapper.dart             # Wrapper principal do app
│   └── services/
│       └── auth_service.dart            # Serviço de autenticação
├── screens/
│   └── auth/
│       └── login_screen.dart            # Tela de login
```

## Funcionalidades Implementadas

- ✅ Login com Google
- ✅ Logout
- ✅ Persistência de sessão
- ✅ Verificação de status de autenticação
- ✅ Gerenciamento de estado com BLoC
- ✅ Cache local com Hive
- ✅ Navegação automática baseada no estado
- ✅ Tratamento de erros
- ✅ UI responsiva e moderna

## Uso no App

### Como usar o AuthBloc:

```dart
// Fazer login
context.read<AuthBloc>().add(const AuthSignInRequested());

// Fazer logout
context.read<AuthBloc>().add(const AuthSignOutRequested());

// Verificar status
context.read<AuthBloc>().add(const AuthCheckStatus());

// Escutar mudanças de estado
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      // Usuário logado
      final user = state.user;
      print('Usuário logado: ${user.email}');
    } else if (state is AuthUnauthenticated) {
      // Usuário não logado
      print('Usuário não logado');
    }
  },
  child: YourWidget(),
)
```

### Como acessar o usuário atual:

```dart
// Via service locator
final authService = getIt<AuthService>();
final user = authService.currentUser;

// Via BLoC
final state = context.read<AuthBloc>().state;
if (state is AuthAuthenticated) {
  final user = state.user;
}
```

## Troubleshooting

### Erro "API key not valid"
- Verifique se os arquivos `google-services.json` e `GoogleService-Info.plist` estão corretos
- Confirme se a API está habilitada no Google Cloud Console

### Erro "OAuth client ID not found"
- Verifique se o SHA-1 está correto no Firebase
- Confirme se o package name/bundle ID está correto

### Login não funciona
- Verifique se a autenticação Google está habilitada no Firebase
- Confirme se as credenciais OAuth estão configuradas corretamente

## Próximos Passos

- Adicionar mais provedores de autenticação (Facebook, Apple, etc.)
- Implementar recuperação de senha
- Adicionar verificação de email
- Implementar perfil do usuário
- Adicionar autenticação por telefone

## Suporte

Se você encontrar problemas, consulte:
- [Documentação do Firebase](https://firebase.google.com/docs/auth)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Google Sign-In Plugin](https://pub.dev/packages/google_sign_in) 