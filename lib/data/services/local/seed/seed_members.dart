import '../../../../domain/models/member.dart';

/// Pessoas usadas nos dados de exemplo.
abstract final class SeedMembers {
  static const mariana = Member(
    id: 'u-mariana',
    name: 'Mariana Souza',
    role: 'Product Manager',
    email: 'mariana@taskflow.local',
    isAdmin: true,
  );
  static const lucasPeixoto = Member(
    id: 'u-lucas-p',
    name: 'Lucas Peixoto',
    role: 'Backend Engineer',
    email: 'lucas.peixoto@taskflow.local',
  );
  static const rodrigo = Member(
    id: 'u-rodrigo',
    name: 'Rodrigo Nogueira',
    role: 'Tech Lead',
    email: 'rodrigo@taskflow.local',
  );
  static const beatriz = Member(
    id: 'u-beatriz',
    name: 'Beatriz Ramos',
    role: 'Lead Product Designer',
    email: 'beatriz@taskflow.local',
  );
  static const lucasRibeiro = Member(
    id: 'u-lucas-r',
    name: 'Lucas Ribeiro',
    role: 'Backend Senior',
    email: 'lucas.ribeiro@taskflow.local',
  );
  static const camila = Member(
    id: 'u-camila',
    name: 'Camila Duarte',
    role: 'Frontend Dev',
    email: 'camila@taskflow.local',
  );
  static const rafael = Member(
    id: 'u-rafael',
    name: 'Rafael Costa',
    role: 'Backend Engineer',
    email: 'rafael@taskflow.local',
  );
  static const andre = Member(
    id: 'u-andre',
    name: 'André Lima',
    role: 'Designer',
    email: 'andre@taskflow.local',
  );
  static const gabriel = Member(
    id: 'u-gabriel',
    name: 'Gabriel Lopes',
    role: 'Mobile Dev',
    email: 'gabriel@taskflow.local',
  );
  static const carla = Member(
    id: 'u-carla',
    name: 'Carla Alves',
    role: 'QA Engineer',
    email: 'carla@taskflow.local',
  );

  /// Pessoas que podem ser atribuídas a tarefas.
  static const all = [
    mariana,
    lucasPeixoto,
    rodrigo,
    beatriz,
    lucasRibeiro,
    camila,
    rafael,
    andre,
    gabriel,
    carla,
  ];
}
