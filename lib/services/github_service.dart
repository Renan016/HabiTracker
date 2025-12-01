import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  // Busca os eventos públicos do usuário (PushEvents contam como contribuição)
  // Retorna um Set de datas onde houve atividade
  static Future<Set<DateTime>> fetchContributions(String username) async {
    final Set<DateTime> contributionDates = {};

    // A API pública limita a cerca de 300 eventos ou 90 dias.
    // Vamos tentar buscar até 5 páginas de 100 eventos cada para garantir o máximo histórico.
    for (int page = 1; page <= 5; page++) {
      final url = Uri.parse('https://api.github.com/users/$username/events?page=$page&per_page=100');

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final List<dynamic> events = jsonDecode(response.body);
          
          if (events.isEmpty) break; // Se a lista vier vazia, acabou o histórico

          for (var event in events) {
            // PushEvent = Commit
            // CreateEvent = Criou repositório/branch/tag
            // PullRequestEvent = Abriu PR (opcional, adicionei caso queira)
            if (event['type'] == 'PushEvent' || 
                event['type'] == 'CreateEvent' || 
                event['type'] == 'PullRequestEvent') {
              
              final String createdAt = event['created_at'];
              final DateTime date = DateTime.parse(createdAt);
              
              // Adiciona a data normalizada (apenas dia, mês, ano)
              contributionDates.add(DateTime(date.year, date.month, date.day));
            }
          }
        } else {
          // Se der erro (ex: limite de requisições), para de buscar
          print("Erro API GitHub na página $page: ${response.statusCode}");
          break;
        }
      } catch (e) {
        print("Erro ao buscar dados do GitHub: $e");
        break;
      }
    }

    return contributionDates;
  }
}