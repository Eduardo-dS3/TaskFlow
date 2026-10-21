/// Configurações gerais compartilhadas por toda a equipe.
class AppSettings {
  const AppSettings({
    this.id = '',
    this.organization = '',
    this.activeSprint = '',
  });

  final String id;

  /// Nome da empresa ou equipe exibido no app.
  final String organization;

  /// Sprint em andamento, exibida no quadro.
  final String activeSprint;

  AppSettings copyWith({String? organization, String? activeSprint}) =>
      AppSettings(
        id: id,
        organization: organization ?? this.organization,
        activeSprint: activeSprint ?? this.activeSprint,
      );
}
