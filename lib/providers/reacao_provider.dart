import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/reacao.dart';
import 'post_provider.dart';

class ReacaoProvider extends ChangeNotifier {
  List<Reacao> _reacoes = [];
  bool _isLoading = false;
  PostProvider? _postProvider;

  List<Reacao> get reacoes => _reacoes;
  bool get isLoading => _isLoading;

  // Definir referência ao PostProvider
  void setPostProvider(PostProvider postProvider) {
    _postProvider = postProvider;
  }

  // Carregar todas as reações
  Future<void> loadReacoes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.getAllReactions();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        _reacoes = data.map((json) => Reacao.fromJson(json)).toList();
        print('Reações carregadas: ${_reacoes.length}');
        print('Dados das reações: ${_reacoes.map((r) => 'ID: ${r.id}, Post: ${r.postagemId}, Tipo: ${r.tipoReacao}, Comentário: ${r.comentario}').join(', ')}');
        
        // Notificar PostProvider para atualizar estados
        _postProvider?.updateReactions();
      } else {
        print('Erro ao carregar reações: ${response.statusCode}');
        _reacoes = [];
      }
    } catch (e) {
      print('Erro ao carregar reações: $e');
      _reacoes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Criar reação
  Future<bool> createReacao({
    required int usuarioId,
    required int postagemId,
    required String tipoReacao,
    String? comentario,
  }) async {
    try {
      final response = await ApiService.createReaction(
        usuarioId: usuarioId,
        postagemId: postagemId,
        tipoReacao: tipoReacao,
        comentario: comentario,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Recarregar reações após criação
        await loadReacoes();
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao criar reação: $e');
      return false;
    }
  }

  // Buscar reações de um post específico
  List<Reacao> getPostReacoes(int postagemId) {
    return _reacoes.where((reacao) => 
      reacao.postagemId == postagemId && reacao.isActive
    ).toList();
  }

  // Buscar likes de um post
  List<Reacao> getPostLikes(int postagemId) {
    return _reacoes.where((reacao) => 
      reacao.postagemId == postagemId && 
      reacao.isActive && 
      reacao.isLike
    ).toList();
  }

  // Buscar saves de um post
  List<Reacao> getPostSaves(int postagemId) {
    return _reacoes.where((reacao) => 
      reacao.postagemId == postagemId && 
      reacao.isActive && 
      reacao.isSave
    ).toList();
  }

  // Buscar comentários de um post
  List<Reacao> getPostComments(int postagemId) {
    final comments = _reacoes.where((reacao) => 
      reacao.postagemId == postagemId && 
      reacao.isActive && 
      reacao.isComment
    ).toList();
    print('Comentários encontrados para post $postagemId: ${comments.length}');
    return comments;
  }

  // Verificar se usuário curtiu um post
  bool hasUserLiked(int usuarioId, int postagemId) {
    return _reacoes.any((reacao) => 
      reacao.usuarioId == usuarioId && 
      reacao.postagemId == postagemId && 
      reacao.isActive && 
      reacao.isLike
    );
  }

  // Verificar se usuário salvou um post
  bool hasUserSaved(int usuarioId, int postagemId) {
    return _reacoes.any((reacao) => 
      reacao.usuarioId == usuarioId && 
      reacao.postagemId == postagemId && 
      reacao.isActive && 
      reacao.isSave
    );
  }

  // Contar likes de um post
  int getPostLikesCount(int postagemId) {
    return getPostLikes(postagemId).length;
  }

  // Contar saves de um post
  int getPostSavesCount(int postagemId) {
    return getPostSaves(postagemId).length;
  }

  // Contar comentários de um post
  int getPostCommentsCount(int postagemId) {
    return getPostComments(postagemId).length;
  }

  // Buscar reações de um usuário
  List<Reacao> getUserReacoes(int usuarioId) {
    return _reacoes.where((reacao) => 
      reacao.usuarioId == usuarioId && reacao.isActive
    ).toList();
  }

  // Buscar posts salvos por um usuário
  List<int> getSavedPostIds(int usuarioId) {
    return _reacoes
        .where((reacao) => 
          reacao.usuarioId == usuarioId && 
          reacao.isActive && 
          reacao.isSave
        )
        .map((reacao) => reacao.postagemId)
        .toList();
  }
}
