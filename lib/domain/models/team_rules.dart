import 'member.dart';

/// Mensagem exibida quando uma alteração deixaria a equipe sem administrador.
const lastAdminMessage =
    'É preciso manter pelo menos um administrador ativo na equipe.';

/// Indica se, após trocar [updated] na equipe, ainda resta um administrador
/// ativo (regra também aplicada no servidor).
bool keepsActiveAdmin(List<Member> members, Member updated) => [
  for (final m in members) m.id == updated.id ? updated : m,
].any((m) => m.isAdmin && m.active);
