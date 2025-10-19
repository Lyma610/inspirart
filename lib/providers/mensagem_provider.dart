import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

class Mensagem {
  final int id;
  final String nome;
  final String email;
  final String assunto;
  final String mensagem;
  final DateTime dataMensagem;
  final String statusMensagem;

  Mensagem({
    required this.id,
    required this.nome,
    required this.email,
    required this.assunto,
    required this.mensagem,
    required this.dataMensagem,
    required this.statusMensagem,
  });

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      assunto: json['assunto'] ?? '',
      mensagem: json['mensagem'] ?? '',
      dataMensagem: DateTime.tryParse(json['dataMensagem'] ?? '') ?? DateTime.now(),
      statusMensagem: json['statusMensagem'] ?? 'ATIVO',
    );
  }
}

class MensagemProvider extends ChangeNotifier {
  List<Mensagem> _mensagens = [];
  bool _isLoading = false;

  List<Mensagem> get mensagens => _mensagens;
  bool get isLoading => _isLoading;

  // Carregar todas as mensagens
  Future<void> loadMensagens() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService.getAllMessages();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _mensagens = data.map((json) => Mensagem.fromJson(json)).toList();
      }
    } catch (e) {
      print('Erro ao carregar mensagens: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar mensagens por email
  Future<void> loadMensagensByEmail(String email) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService.getMessagesByEmail(email);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _mensagens = data.map((json) => Mensagem.fromJson(json)).toList();
      }
    } catch (e) {
      print('Erro ao carregar mensagens por email: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enviar mensagem
  Future<bool> sendMensagem({
    required String nome,
    required String email,
    required String assunto,
    required String mensagem,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await ApiService.sendMessage(
        nome: nome,
        email: email,
        assunto: assunto,
        mensagem: mensagem,
      );
      
      if (response.statusCode == 200) {
        // Recarregar mensagens após envio
        await loadMensagens();
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Inativar mensagem
  Future<bool> deactivateMensagem(int id) async {
    try {
      final response = await ApiService.deactivateMessage(id);
      
      if (response.statusCode == 200) {
        // Recarregar mensagens após inativação
        await loadMensagens();
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao inativar mensagem: $e');
      return false;
    }
  }

  // Filtrar mensagens por status
  List<Mensagem> getMensagensByStatus(String status) {
    return _mensagens.where((msg) => msg.statusMensagem == status).toList();
  }

  // Contar mensagens não lidas
  int get unreadCount {
    return _mensagens.where((msg) => msg.statusMensagem == 'ATIVO').length;
  }
}
