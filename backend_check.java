// Verifique se estes métodos existem no seu PostagemService:

public List<Genero> findGeneros() {
    List<Genero> generos = generoRepository.findAll();
    return generos;
}

public List<Categoria> findCategorias() {
    List<Categoria> categorias = categoriaRepository.findAll();
    return categorias;
}

// E se o GeneroRepository existe:
// @Repository
// public interface GeneroRepository extends JpaRepository<Genero, Long> {
// }