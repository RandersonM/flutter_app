# 🔧 Firestore Troubleshooting Guide

## Problema: Permissões Insuficientes

### Erro:
```
Permissões faltando: datastore.databases.list
```

### Solução:

#### 1. **Verificar Permissões no Google Cloud Console**
1. Acesse [console.cloud.google.com](https://console.cloud.google.com)
2. Selecione o projeto `opfan-dbl77`
3. Vá para **IAM & Admin** > **IAM**
4. Procure pelo seu email `m4yllon@gmail.com`
5. Verifique se você tem as seguintes roles:
   - `Firebase Admin`
   - `Cloud Datastore User`
   - `Firestore User`

#### 2. **Adicionar Permissões (se necessário)**
1. Clique no lápis (editar) ao lado do seu email
2. Clique em **"Adicionar outro papel"**
3. Adicione as seguintes roles:
   - `Firebase Admin`
   - `Cloud Datastore User`
   - `Firestore User`

#### 3. **Verificar Firebase Console**
1. Acesse [console.firebase.google.com](https://console.firebase.google.com)
2. Selecione o projeto `opfan-dbl77`
3. Vá para **Authentication** > **Users**
4. Verifique se seu email está listado

## Problema: Índice Composto Necessário

### Erro:
```
[cloud_firestore/failed-precondition] The query requires an index.
```

### Solução:

#### 1. **Criar Índice no Firebase Console**
1. Acesse [console.firebase.google.com](https://console.firebase.google.com)
2. Selecione o projeto `opfan-dbl77`
3. Vá para **Firestore Database**
4. Clique na aba **"Índices"**
5. Clique em **"Criar índice"**
6. Configure:
   - **Collection ID:** `custom_characters`
   - **Fields:**
     - `userId` (Ascending)
     - `createdAt` (Descending)
   - **Query scope:** Collection

#### 2. **Usar Link Direto do Erro**
Clique no link que apareceu no erro:
```
https://console.firebase.google.com/v1/r/project/opfan-dbl77/firestore/indexes?create_composite=CIVwcm9qZWN0cy9vcGZhbil1KyjE3Ny9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvY3VzdG9tZXNoY3RlcnMvaW5kZXhlcy9fEAEaCgoGdXNlcllkEAEaDQoJY3JlYXRlZEFOEAEaDAolX19uYW1lX18QAQ
```

## Solução Temporária Implementada

### O que foi feito:
1. **Removida ordenação do Firestore** - As consultas agora não usam `orderBy` no Firestore
2. **Ordenação local** - A ordenação é feita no cliente após receber os dados
3. **Fallback seguro** - Se a ordenação falhar, os dados ainda são retornados

### Vantagens:
- ✅ Funciona imediatamente sem configuração adicional
- ✅ Não requer permissões especiais
- ✅ Mantém funcionalidade de ordenação
- ✅ Compatível com todos os dispositivos

### Desvantagens:
- ⚠️ Ordenação feita no cliente (pode ser mais lenta para grandes listas)
- ⚠️ Não aproveita índices do Firestore para performance

## Próximos Passos

### 1. **Resolver Permissões**
- Siga os passos acima para adicionar permissões necessárias
- Teste se consegue acessar o Firebase Console

### 2. **Criar Índices (Opcional)**
- Se tiver permissões, crie os índices compostos
- Isso melhorará a performance para grandes listas

### 3. **Restaurar Ordenação no Firestore**
- Após resolver permissões e criar índices
- Remover os comentários `// TEMPORÁRIO` do código
- Restaurar `orderBy: orderBy ?? 'createdAt'` nas consultas

## Testando a Solução

### 1. **Teste Básico**
```dart
// A tela de personagens customizados deve carregar sem erro
Navigator.of(context).pushNamed('/customCharacterList');
```

### 2. **Teste de Funcionalidades**
- ✅ Listagem de personagens
- ✅ Busca por nome
- ✅ Filtros por fruta/equipe
- ✅ Criação de novo personagem
- ✅ Edição e exclusão

### 3. **Verificar Logs**
- Não deve aparecer erro de índice
- Não deve aparecer erro de permissões
- Os dados devem carregar normalmente

## Contato para Suporte

Se ainda tiver problemas:
1. Verifique se está logado com a conta correta
2. Confirme que o projeto `opfan-dbl77` está selecionado
3. Tente acessar diretamente o Firebase Console
4. Verifique se o Firestore está habilitado no projeto

## Comandos Úteis

### Verificar Status do Firebase
```bash
firebase projects:list
firebase use opfan-dbl77
firebase firestore:indexes
```

### Verificar Permissões via CLI
```bash
gcloud auth list
gcloud projects get-iam-policy opfan-dbl77
``` 