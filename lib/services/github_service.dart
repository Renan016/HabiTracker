import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  // Busca apenas a URL do avatar do usuário
  static Future<String?> fetchAvatarUrl(String username) async {
    final url = Uri.parse('https://api.github.com/users/$username');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['avatar_url'];
      }
    } catch (e) {
      print("Erro ao buscar avatar: $e");
    }
    return null;
  }

  // Busca os eventos públicos (Contribuições)
  static Future<Set<DateTime>> fetchContributions(String username) async {
    final Set<DateTime> contributionDates = {};

    // Busca até 3 páginas para garantir histórico suficiente
    for (int page = 1; page <= 3; page++) {
      final url = Uri.parse('https://api.github.com/users/$username/events?page=$page&per_page=100');

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final List<dynamic> events = jsonDecode(response.body);
          
          if (events.isEmpty) break; 

          for (var event in events) {
            // Lista expandida de eventos que contam como contribuição
            if (event['type'] == 'PushEvent' || 
                event['type'] == 'CreateEvent' || 
                event['type'] == 'PullRequestEvent' ||
                event['type'] == 'IssuesEvent' ||
                event['type'] == 'PullRequestReviewEvent') {
              
              final String createdAt = event['created_at'];
              
              // CORREÇÃO DE FUSO HORÁRIO: Converte UTC para o horário do celular
              final DateTime date = DateTime.parse(createdAt).toLocal();
              
              contributionDates.add(DateTime(date.year, date.month, date.day));
            }
          }
        } else {
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