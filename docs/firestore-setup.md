# Configuração do Firestore Database

Este guia explica como configurar o Firestore Database no Firebase Console para o projeto OpFan.

## 1. Acessar o Firebase Console

1. Vá para [Firebase Console](https://console.firebase.google.com)
2. Selecione seu projeto: **`opfan-db177`**

## 2. Habilitar o Firestore Database

1. No menu lateral, clique em **"Firestore Database"**
2. Clique em **"Criar banco de dados"**

## 3. Escolher o Modo de Segurança

### Opção A: Modo de Teste (Recomendado para Desenvolvimento)
- Selecione **"Iniciar no modo de teste"**
- Isso permite leitura/escrita para todos os usuários por 30 dias
- Clique em **"Próximo"**

### Opção B: Modo Bloqueado (Mais Seguro)
- Selecione **"Iniciar no modo bloqueado"**
- Você precisará configurar regras de segurança depois

## 4. Escolher Localização

- **Recomendado para Brasil**: `southamerica-east1 (São Paulo)`
- **Alternativa**: `us-east1 (South Carolina)`
- Clique em **"Concluir"**

## 5. Configurar Regras de Segurança (Opcional)

Se você escolheu o modo bloqueado, vá em **"Regras"** e configure:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir acesso apenas para usuários autenticados
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Para documentos específicos do usuário
    match /customCharacters/{document} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Para dados de formulário
    match /formData/{document} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

## 6. Testar a Configuração

### Usando o App
1. Execute o app: `flutter run`
2. Faça login com Google
3. Vá para a tela de criar personagem customizado
4. Clique no botão **"Testar Firestore"**
5. Verifique o console para ver os resultados

### Usando o Console
No terminal, execute:
```bash
flutter run
```

E observe os logs do console para ver os resultados dos testes.

## 7. Estrutura de Dados Esperada

### Coleção: `customCharacters`
```json
{
  "id": "auto-generated",
  "userId": "user-uid",
  "name": "Nome do Personagem",
  "nickname": "Apelido",
  "devilFruit": "Nome da Fruta",
  "haki": ["Observation", "Armament", "Conqueror"],
  "affiliations": ["Pirata", "Independente"],
  "image": "URL da imagem",
  "occupation": ["Pirata", "Capitão"],
  "bounty": "1,000,000,000",
  "status": "Vivo",
  "age": 25,
  "description": "Descrição do personagem",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Coleção: `formData`
```json
{
  "id": "auto-generated",
  "userId": "user-uid",
  "name": "Nome",
  "email": "email@example.com",
  "phone": "Telefone",
  "description": "Descrição",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## 8. Verificar se Está Funcionando

### Testes Automáticos
O app inclui testes automáticos que verificam:
- ✅ Conexão com o Firestore
- ✅ Autenticação do usuário
- ✅ Leitura e escrita de documentos

### Verificação Manual
1. No Firebase Console, vá para **"Firestore Database"**
2. Clique em **"Dados"**
3. Você deve ver as coleções criadas pelos testes

## 9. Troubleshooting

### Erro: "Permission denied"
- Verifique se as regras de segurança estão configuradas corretamente
- Certifique-se de que o usuário está autenticado

### Erro: "Network error"
- Verifique sua conexão com a internet
- Confirme se o Firebase está acessível

### Erro: "Project not found"
- Verifique se o `projectId` no `firebase_options.dart` está correto
- Confirme se os arquivos de configuração estão atualizados

### Erro: "API key not valid"
- Verifique se os arquivos `google-services.json` e `GoogleService-Info.plist` estão corretos
- Confirme se a API está habilitada no Google Cloud Console

## 10. Próximos Passos

Após configurar o Firestore:
1. Teste a criação de personagens customizados
2. Implemente a listagem de personagens
3. Adicione funcionalidades de edição e exclusão
4. Configure backup automático
5. Implemente cache offline

## 11. Recursos Úteis

- [Documentação do Firestore](https://firebase.google.com/docs/firestore)
- [Regras de Segurança](https://firebase.google.com/docs/firestore/security/get-started)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/firestore/usage/)
- [Firebase Console](https://console.firebase.google.com)

## 12. Suporte

Se você encontrar problemas:
1. Verifique os logs do console
2. Consulte a documentação oficial
3. Teste com o modo de teste habilitado
4. Verifique as regras de segurança 