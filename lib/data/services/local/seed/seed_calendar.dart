/// Gera datas relativas a "hoje" para os dados de exemplo, de modo que
/// prazos como "Hoje" e "Amanhã" façam sentido em qualquer dia.
class SeedCalendar {
  SeedCalendar(this.now);

  final DateTime now;

  /// Meia-noite de hoje deslocada em [days] dias, mais [hour] e [minute].
  DateTime days(int days, {int hour = 0, int minute = 0}) {
    final today = DateTime(now.year, now.month, now.day);
    return today.add(Duration(days: days, hours: hour, minutes: minute));
  }
}
