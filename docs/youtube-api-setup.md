# Configuração da API do YouTube

## Como configurar a API key do YouTube

### 1. Obter a API Key

1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Crie um novo projeto ou selecione um existente
3. Vá para **APIs & Services** > **Library**
4. Procure por **YouTube Data API v3** e ative-a
5. Vá para **APIs & Services** > **Credentials**
6. Clique em **Create Credentials** > **API key**
7. Copie a API key gerada

### 2. Configurar no App

A API key é lida via `flutter_dotenv` — **nunca hardcode a chave no código**. Adicione ao `.env`:

```env
YOUTUBE_API_KEY=sua_api_key_aqui
YOUTUBE_BASE_URL=https://www.googleapis.com/youtube/v3
```

O `YouTubeService` (`lib/core/services/youtube/youtube_service.dart`) lê esses valores através de `IEnvironmentService`, injetado via GetIt.

### 3. Funcionalidades

- **Busca automática**: Quando um personagem é carregado, o app busca automaticamente por vídeos AMV
- **Fallback**: Se não há API key configurada, usa dados simulados para desenvolvimento
- **Player integrado**: Clique no banner para assistir ao vídeo em fullscreen
- **Thumbnail**: Mostra a thumbnail do vídeo como banner

### 4. Exemplo de uso

```dart
final youtubeService = YouTubeService();
final video = await youtubeService.searchCharacterAMV('Monkey D. Luffy');
```

### 5. Dados simulados (Desenvolvimento)

Se você não configurar a API key, o app funcionará normalmente usando dados simulados com um vídeo de placeholder.

## ⚠️ Importante

- Mantenha sua API key segura
- Não commite a API key para o repositório
- Configure quotas apropriadas no Google Cloud Console
- A API do YouTube tem limites de uso gratuito

## Estrutura dos arquivos

- `lib/core/services/youtube/youtube_service.dart` — Serviço principal (implementa `IYouTubeService`)
- `lib/core/services/youtube/i_youtube_service.dart` — Interface do serviço
- `lib/features/youtube/data/models/youtube_video_model.dart` — Modelo de dados
- `lib/features/youtube/` — Tela e widgets do player (feature module) 