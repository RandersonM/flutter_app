// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_app/core/services/characters_backend_service.dart';
import 'package:simple_app/l10n/app_localizations.dart';
import 'package:simple_app/widgets/molecules/default_app_bar.dart';
import 'package:simple_app/widgets/organisms/bottom_navigation.dart';
import 'package:simple_app/screens/home/widgets/simple_video_banner.dart';
import 'package:simple_app/screens/home/widgets/character_info_card.dart';
import 'package:simple_app/screens/home/blocs/home_bloc.dart';
import 'package:simple_app/screens/home/blocs/home_event.dart';
import 'package:simple_app/screens/home/blocs/home_state.dart';
import 'package:simple_app/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _bannerContent = [
    {
      'url': 'https://media.giphy.com/media/G3Va9lGnlLCdq/giphy.gif',
      'type': SimpleBannerType.gif,
      'title': 'Monkey D. Luffy',
      'subtitle': 'Gear Second Technique',
    },
    {
      'url': 'https://media.giphy.com/media/JTzPTCLKs6nlS/giphy.gif',
      'type': SimpleBannerType.gif,
      'title': 'Roronoa Zoro',
      'subtitle': 'Three Sword Style',
    },
    {
      'url':
          'https://i.pinimg.com/564x/8e/74/3d/8e743de0b6c03e5825efb7be83e11c9f.jpg',
      'type': SimpleBannerType.image,
      'title': 'One Piece',
      'subtitle': 'Grand Line Adventure',
    },
  ];

  int _currentBannerIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        charactersService: CharactersBackendService(),
      )..add(const LoadFeaturedCharacter()),
      child: Scaffold(
        appBar: DefaultAppBar(
          title: Text(AppLocalizations.of(context)!.home),
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(Constants.margin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner de vídeo
                  SimpleVideoBanner(
                    url: _bannerContent[_currentBannerIndex]['url'] as String,
                    bannerType: _bannerContent[_currentBannerIndex]['type']
                        as SimpleBannerType,
                    height: 200,
                    title:
                        _bannerContent[_currentBannerIndex]['title'] as String?,
                    subtitle: _bannerContent[_currentBannerIndex]['subtitle']
                        as String?,
                  ),

                  const SizedBox(height: Constants.margin),

                  // Indicadores de banner (se houver múltiplos)
                  if (_bannerContent.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _bannerContent.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentBannerIndex == index
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: Constants.margin * 2),

                  // Título da seção
                  Text(
                    'Personagem em Destaque',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: Constants.margin),

                  // Card de informações do personagem - Dinâmico baseado no estado
                  _buildCharacterCard(context, state),

                  const SizedBox(height: Constants.margin),

                  // Botões de ação rápida
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _currentBannerIndex = (_currentBannerIndex + 1) %
                                  _bannerContent.length;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Trocar Banner'),
                        ),
                      ),
                      const SizedBox(width: Constants.margin),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: state is HomeLoading
                              ? null
                              : () {
                                  // Implementado: busca de personagem aleatório
                                  context
                                      .read<HomeBloc>()
                                      .add(const LoadRandomCharacter());
                                },
                          icon: state is HomeLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.shuffle),
                          label: const Text('Personagem Aleatório'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Constants.margin * 2),

                  // Seção de estatísticas ou informações extras
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Constants.margin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estatísticas',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: Constants.margin),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                context,
                                'Total de Personagens',
                                '51',
                                Icons.people,
                              ),
                              _buildStatItem(
                                context,
                                'Bounty Mais Alta',
                                '฿5.5B',
                                Icons.monetization_on,
                              ),
                              _buildStatItem(
                                context,
                                'Crews',
                                '15+',
                                Icons.sailing,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar:
            const BottomNavigation(BottomNavigationPages.counter),
      ),
    );
  }

  Widget _buildCharacterCard(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(Constants.margin * 2),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (state is HomeError) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(Constants.margin),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: Constants.margin),
              Text(
                'Erro ao carregar personagem',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.margin / 2),
              Text(
                state.message,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.margin),
              ElevatedButton(
                onPressed: () {
                  context.read<HomeBloc>().add(const LoadFeaturedCharacter());
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is HomeLoaded) {
      final character = state.featuredCharacter;
      return CharacterInfoCard(
        characterName: character.name,
        characterBounty: character.bounty,
        characterImage: character.image,
        onTap: () {
          // TODO: Navegar para detalhes do personagem
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Navegação para ${character.name} será implementada!'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      );
    }

    // Estado inicial - mostra card padrão
    return CharacterInfoCard(
      characterName: "Carregando...",
      characterBounty: "...",
      characterImage: "https://via.placeholder.com/150",
      onTap: () {},
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
