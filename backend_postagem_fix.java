// ENTIDADE POSTAGEM - Remover campo genero se existir

@Entity
@Table(name = "Postagem")
public class Postagem {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String legenda;
    private String descricao;
    
    @Lob
    private byte[] conteudo;
    
    private LocalDateTime dataCadastro;
    
    @ManyToOne
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;
    
    @ManyToOne
    @JoinColumn(name = "categoria_id")
    private Categoria categoria;
    
    private String statusPostagem;
    
    // REMOVER ESTE CAMPO SE EXISTIR:
    // @ManyToOne
    // @JoinColumn(name = "genero_id")
    // private Genero genero;
    
    // getters e setters...
}