import 'package:pocketbase/pocketbase.dart';

import '../../../../domain/models/app_settings.dart';
import '../../../../domain/models/member.dart';
import 'record_utils.dart';

Member memberFromRecord(RecordModel record) {
  final name = record.getStringValue('name');
  final email = record.getStringValue('email');
  final capacity = record.getDoubleValue('weeklyCapacity');
  return Member(
    id: record.id,
    name: name.isEmpty ? email : name,
    role: record.getStringValue('role'),
    email: email,
    username: record.getStringValue('username'),
    isAdmin: record.getBoolValue('isAdmin'),
    active: record.getBoolValue('active'),
    weeklyCapacity: capacity > 0 ? capacity : 40,
    lastSeen: parseDate(record.getStringValue('lastSeen')),
  );
}

/// Pessoa referenciada que não está mais visível (ex.: conta removida).
Member unknownMember(String id) =>
    Member(id: id, name: 'Usuário removido', role: '');

/// Campos que um administrador pode alterar em outra pessoa.
Map<String, dynamic> memberToBody(Member member) => {
  'name': member.name.trim(),
  'email': member.email.trim(),
  'username': member.username.trim(),
  'role': member.role.trim(),
  'isAdmin': member.isAdmin,
  'active': member.active,
  'weeklyCapacity': member.weeklyCapacity,
};

AppSettings settingsFromRecord(RecordModel record) => AppSettings(
  id: record.id,
  organization: record.getStringValue('organization'),
  activeSprint: record.getStringValue('activeSprint'),
);

Map<String, dynamic> settingsToBody(AppSettings settings) => {
  'organization': settings.organization.trim(),
  'activeSprint': settings.activeSprint.trim(),
};
