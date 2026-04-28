import 'dart:convert';
import 'package:http/http.dart' as http;

/// 🌐 Web Search Engine — DuckDuckGo + Google
class WebSearchEngine {
  static Future<SearchResult> search(String query) async {
    try {
      final resp = await http.get(Uri.parse(
        'https://api.duckduckgo.com/?q=${Uri.encodeComponent(query)}&format=json&no_html=1&skip_disambig=1',
      ));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return SearchResult(
          query: query,
          abstract: data['Abstract'] ?? '',
          source: data['AbstractSource'] ?? '',
          sourceUrl: data['AbstractURL'] ?? '',
          definition: data['Definition'] ?? '',
          items: ((data['RelatedTopics'] as List?) ?? []).take(10).map((t) => SearchItem(
            title: (t['Text'] ?? '').toString().length > 100
                ? '${t['Text'].toString().substring(0, 100)}...'
                : t['Text'] ?? '',
            snippet: t['Text'] ?? '',
            url: t['FirstURL'] ?? '',
          )).toList(),
        );
      }
      return SearchResult(query: query, items: []);
    } catch (e) {
      return SearchResult(query: query, abstract: 'Search error: $e', items: []);
    }
  }
}

class SearchResult {
  final String query;
  final String abstract;
  final String source;
  final String sourceUrl;
  final String definition;
  final List<SearchItem> items;
  SearchResult({required this.query, this.abstract = '', this.source = '', this.sourceUrl = '', this.definition = '', required this.items});
}

class SearchItem {
  final String title;
  final String snippet;
  final String url;
  SearchItem({required this.title, required this.snippet, required this.url});
}
