# Configuração da API do Gemini AI (Google)

## Como configurar a API key do Gemini AI

### 1. Obter a API Key

1. Acesse [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Faça login com sua conta Google
3. Clique em **Create API Key**
4. Copie a API key gerada

### 2. Configurar no App

1. Crie um arquivo `.env` na raiz do projeto
2. Adicione a seguinte linha:

```env
GEMINI_API_KEY=sua_api_key_aqui
```

### 3. Exemplo completo do arquivo .env

```env
# Configurações da API do YouTube
YOUTUBE_API_KEY=your_youtube_api_key_here
YOUTUBE_BASE_URL=https://www.googleapis.com/youtube/v3

# Configurações da API do One Piece
ONEPIECE_API_URL=https://api.api-onepiece.com/v2/
DEVIL_FRUIT_API_URL=https://api.api-onepiece.com/v2/fruits/en

# Configurações da API do Hugging Face (Stability AI)
HUGGING_FACE_API_KEY=dev_mode
HUGGING_FACE_BASE_URL=https://api-inference.huggingface.co


# Configurações da API do Gemini AI (Google)
GEMINI_API_KEY=sua_api_key_aqui

# Configurações do App
APP_NAME=One Piece Simple App
APP_VERSION=1.0.1
DEBUG_MODE=true

# Configurações de Rede
NETWORK_TIMEOUT=30000
RETRY_COUNT=3
CACHE_EXPIRY_TIME=3600000
```

### 4. Vantagens do Gemini AI

- **Gratuito**: 15 requisições por hora (mais generoso que outras APIs)
- **Qualidade**: Modelo avançado da Google
- **Confiabilidade**: Infraestrutura robusta da Google
- **Suporte**: Documentação excelente e comunidade ativa

### 5. Limitações

- **Geração de Imagens**: O Gemini não gera imagens diretamente, mas pode ser usado para melhorar prompts
- **Fallback**: O sistema usa fallbacks inteligentes quando a API não está disponível
- **Cache**: Imagens são cacheadas para melhor performance

### 6. Funcionalidades

- **Geração de Prompts**: Melhora prompts para geração de imagens
- **Fallback Inteligente**: Cria imagens placeholder baseadas no prompt
- **Cache**: Evita requisições desnecessárias
- **Rate Limiting**: Controle automático de requisições

### 7. Como funciona

1. O usuário insere um prompt
2. O Gemini AI melhora o prompt
3. Se a API estiver disponível, usa o prompt melhorado
4. Se não, usa fallbacks inteligentes
5. Gera uma imagem baseada no prompt

### 8. Teste da API

Para testar se a API está funcionando:

```bash
curl -X POST https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Hello, how are you?"
      }]
    }]
  }'
```

### 9. Configuração de Desenvolvimento

Para desenvolvimento, você pode usar:

```env
# Desenvolvimento - sem API
GEMINI_API_KEY=dev_mode

# Produção - com API real
GEMINI_API_KEY=sua_api_key_aqui
```

### 10. Próximos Passos

1. Configure o arquivo `.env` com sua chave da API
2. Execute `flutter pub get` para instalar as dependências
3. Reinicie o aplicativo
4. Teste a geração de imagens

### 11. Solução de Problemas

#### "API Key not found"
- Verifique se o arquivo `.env` existe
- Confirme se a chave está corretamente formatada
- Reinicie o app após adicionar a chave

#### "Quota exceeded"
- Aguarde 1 hora para reset automático
- O sistema usará fallbacks automaticamente

#### "Network timeout"
- Verifique sua conexão com a internet
- A API pode estar temporariamente indisponível

### 12. Estrutura dos arquivos

- `lib/core/services/gemini_image_service.dart` - Serviço principal
- `lib/core/services/environment_service.dart` - Configurações
- `lib/core/services/service_locator.dart` - Injeção de dependência

### 13. Comparação com outras APIs

| API | Requisições/Hora | Custo | Qualidade |
|-----|------------------|-------|-----------|
| Gemini AI | 15 | Gratuito | Alta |
| Stability AI | 10 | Pago | Muito Alta |
| Hugging Face | 10 | Gratuito | Média |

### 14. ⚠️ Importante

- Mantenha sua API key segura
- Não commite a API key para o repositório
- Configure quotas apropriadas no Google AI Studio
- A API do Gemini tem limites de uso gratuito generosos 