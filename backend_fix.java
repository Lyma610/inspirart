// CORREÇÃO PARA O ERRO DE genero_id

// 1. ATUALIZAR O CONTROLLER - PostagemController.java
// Remover qualquer referência a genero no método create:

@PostMapping("/create")
public ResponseEntity<?> create(
        @RequestParam(required = false) MultipartFile file,
        @ModelAttribute Postagem postagem) {

    postagemService.create(file, postagem);

    return ResponseEntity.ok()
            .body(new MessageResponse("Post cadastrado com sucesso!"));
}

// 2. ATUALIZAR O SERVICE - PostagemService.java
// O método create já está correto, não precisa de alteração

// 3. VERIFICAR A ENTIDADE POSTAGEM
// Certifique-se de que a entidade Postagem NÃO tenha o campo genero
// Se tiver, remova ou comente as linhas relacionadas a genero:

/*
@ManyToOne
@JoinColumn(name = "genero_id")
private Genero genero;
*/

// 4. ATUALIZAR O FLUTTER - ApiService.dart
// Remover o envio do genero_id na requisição:

static Future<http.Response> createPost({
  required String titulo,
  required String descricao,
  required int categoriaId,
  required int usuarioId,
  XFile? imageFile,
}) async {
  final url = Uri.parse('$baseUrl/postagem/create');
  
  var request = http.MultipartRequest('POST', url);
  
  // Remover a linha do genero.id
  request.fields['titulo'] = titulo;
  request.fields['descricao'] = descricao;
  request.fields['categoria.id'] = categoriaId.toString();
  request.fields['usuario.id'] = usuarioId.toString();
  // NÃO ENVIAR: request.fields['genero.id'] = generoId.toString();
  
  if (imageFile != null) {
    final bytes = await imageFile.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: imageFile.name,
    ));
  }
  
  final streamedResponse = await request.send();
  return await http.Response.fromStream(streamedResponse);
}