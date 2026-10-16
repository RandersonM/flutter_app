# Gemini AI na Nuvem (Google) — Configuração

> **Este documento cobre o `google_generative_ai` (Gemini na nuvem)** — usado para geração de texto e imagem via API do Google. Para o LLM que roda **no dispositivo** (`flutter_gemma`, chat do Vegapunk), veja [`flutter-gemma-on-device.md`](./flutter-gemma-on-device.md). Os dois são tecnologias diferentes que coexistem no projeto.

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

Veja o `.env.example` na raiz do projeto para a lista completa e atualizada de variáveis (inclui também as chaves do `flutter_gemma`, YouTube, Tavily etc). O bloco relevante para o Gemini na nuvem é:

```env
GEMINI_API_KEY=sua_api_key_aqui
```

### 4. Modelos usados atualmente

| Uso | Modelo | Via |
|---|---|---|
| Geração de texto | `gemini-2.5-flash-lite` | SDK `google_generative_ai` (`GenerativeModel`) |
| Geração de imagem | `gemini-2.5-flash-image` | REST direto (`Dio` + header `x-goog-api-key`) |

O texto usa o SDK oficial (`GenerativeModel.generateContent`). A imagem usa a API REST diretamente porque o SDK `google_generative_ai: ^0.3.0` não expõe geração de imagem — a resposta vem em `candidates[0].content.parts[].inlineData` (base64 PNG), que é decodificada e enviada para o Imgur para obter uma URL pública.

### 5. Limitações e comportamento de fallback

- **Rate limit**: 15 requisições/hora (`_maxRequestsPerHour` em `gemini_service.dart`)
- **Cooldown de quota**: ao detectar `RESOURCE_EXHAUSTED`/429, o serviço entra em cooldown de **2 minutos** (não 1 hora) antes de tentar novamente
- **Modo dev**: se `GEMINI_API_KEY=dev_mode` ou vazio, `generateText` retorna uma resposta de fallback genérica (texto fixo) sem chamar a API; `generateImage` retorna `null`
- **Upload de imagem**: a imagem gerada é enviada ao Imgur com um Client-ID **hardcoded** em `gemini_service.dart` (`_uploadImageToServer`) — candidato a mover para `.env` numa limpeza futura
- **Cache**: imagens geradas são cacheadas em memória por hash do prompt (`_imageCache`), não persistido entre sessões do app

### 6. Como funciona

1. O caller (repository/service de uma feature) monta o prompt
2. `GeminiService.generateText`/`generateImage` verifica quota e rate limit
3. Se disponível, chama a API do Gemini
4. Para imagem: decodifica o base64 retornado e faz upload ao Imgur, devolvendo uma URL
5. Se a quota/API falhar, texto usa fallback genérico; imagem retorna `null` e a UI decide o que exibir

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
- O serviço entra em cooldown automático de 2 minutos e depois volta a tentar
- Durante o cooldown, `generateText`/`generateImage` retornam sem chamar a API

#### "Network timeout"
- Verifique sua conexão com a internet
- A API pode estar temporariamente indisponível
- O `Dio` interceptor já faz 1 retry automático em erros de conexão/timeout

### 12. Estrutura dos arquivos (atual)

- `lib/core/services/gemini/gemini_service.dart` — Serviço principal (implementa `IGeminiService`)
- `lib/core/services/gemini/i_gemini_service.dart` — Interface
- `lib/core/services/environment_service.dart` — Leitura de variáveis de ambiente
- `lib/app/di/core_module.dart` — Registro no GetIt

### 13. ⚠️ Importante

- Mantenha sua API key segura
- Não commite a API key para o repositório
- Configure quotas apropriadas no Google AI Studio
- A API do Gemini tem limites de uso gratuito generosos 