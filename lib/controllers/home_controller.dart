import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class HomeController {
  final String _apiKey = 'AIzaSyBgmteWgH1aB5W_qE0ddGMp1vuTPKNxe5k';
  final String _pdfBackendUrl = 'http://192.168.0.16:8000/extract-text';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveSummary(String summary, String filename) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('summaries')
        .doc();

    await doc.set({
      'text': summary,
      'originalName': filename,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> onSelectPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return null;

      final file = File(result.files.single.path!);

      final uri = Uri.parse(_pdfBackendUrl);
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final data = jsonDecode(res.body);
        return data['text'];
      } else {
        print('Erro ao extrair texto do PDF: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao processar PDF: $e');
      return null;
    }
  }

  /// Envia o texto para o Gemini e retorna o resumo
  Future<String> summarizeWithGemini(String text) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey',
    );

    final body = {
      "contents": [
        {
          "parts": [
            {
              "text": '''
Resuma o seguinte conteúdo extraído de um PDF de forma clara, organizada e estruturada.

O resumo deve conter:
- Uma introdução curta
- Os principais tópicos em lista numerada ou com bullets
- Conclusão com observações finais

Texto original:
$text
              ''',
            },
          ],
        },
      ],
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final summary = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
      return summary ?? "Não foi possível gerar um resumo.";
    } else {
      print('Erro na API Gemini: ${response.body}');
      return "Erro ao gerar resumo: ${response.statusCode}";
    }
  }
}