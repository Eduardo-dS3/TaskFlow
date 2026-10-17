import '../../../../domain/models/member.dart';

/// Pessoas usadas nos dados de exemplo.
abstract final class SeedMembers {
  static const mariana = Member(
    id: 'u-mariana',
    name: 'Mariana Souza',
    role: 'Product Manager',
  );
  static const lucasPeixoto = Member(
    id: 'u-lucas-p',
    name: 'Lucas Peixoto',
    role: 'Backend Engineer',
  );
  static const rodrigo = Member(
    id: 'u-rodrigo',
    name: 'Rodrigo Nogueira',
    role: 'Tech Lead',
  );
  static const beatriz = Member(
    id: 'u-beatriz',
    name: 'Beatriz Ramos',
    role: 'Lead Product Designer',
  );
  static const lucasRibeiro = Member(
    id: 'u-lucas-r',
    name: 'Lucas Ribeiro',
    role: 'Backend Senior',
  );
  static const camila = Member(
    id: 'u-camila',
    name: 'Camila Duarte',
    role: 'Frontend Dev',
  );
  static const rafael = Member(
    id: 'u-rafael',
    name: 'Rafael Costa',
    role: 'Backend Engineer',
  );
  static const andre = Member(
    id: 'u-andre',
    name: 'André Lima',
    role: 'Designer',
  );
  static const gabriel = Member(
    id: 'u-gabriel',
    name: 'Gabriel Lopes',
    role: 'Mobile Dev',
  );
  static const carla = Member(
    id: 'u-carla',
    name: 'Carla Alves',
    role: 'QA Engineer',
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

  /// Integrante de squad sem perfil detalhado.
  static Member dev(String id, String name) =>
      Member(id: id, name: name, role: 'Dev');
}
