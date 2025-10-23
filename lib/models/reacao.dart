class Reacao {
  final int id;
  final String? comentario;
  final DateTime dataReacao;
  final int usuarioId;
  final int postagemId;
  final String tipoReacao; // CURTIR, SALVAR, COMENTAR
  final String statusReacao; // ATIVO, INATIVO

  const Reacao({
    required this.id,
    this.comentario,
    required this.dataReacao,
    required this.usuarioId,
    required this.postagemId,
    required this.tipoReacao,
    required this.statusReacao,
  });

  factory Reacao.fromJson(Map<String, dynamic> json) {
    return Reacao(
      id: json['id'] ?? 0,
      comentario: json['comentario'],
      dataReacao: DateTime.tryParse(json['dataReacao'] ?? '') ?? DateTime.now(),
      usuarioId: json['usuario_id'] ?? json['usuario']?['id'] ?? 0,
      postagemId: json['postagem_id'] ?? json['postagem']?['id'] ?? 0,
      tipoReacao: json['tipoReacao'] ?? '',
      statusReacao: json['statusReacao'] ?? 'ATIVO',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comentario': comentario,
      'dataReacao': dataReacao.toIso8601String(),
      'usuario_id': usuarioId,
      'postagem_id': postagemId,
      'tipoReacao': tipoReacao,
      'statusReacao': statusReacao,
    };
  }

  // Verificar se é uma reação ativa
  bool get isActive => statusReacao == 'ATIVO';
  
  // Verificar se é um like
  bool get isLike => tipoReacao == 'CURTIR';
  
  // Verificar se é um save
  bool get isSave => tipoReacao == 'SALVAR';
  
  // Verificar se é um comentário
  bool get isComment => tipoReacao == 'COMENTAR';
}



