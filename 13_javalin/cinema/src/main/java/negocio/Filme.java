package negocio;

import java.util.List;

public class Filme {
    private int id;
    private String titulo;
    private String sinopse;
    private String classificacaoEtaria;
    private List<Genero> vetGenero;

    
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public String getTitulo() {
        return titulo;
    }
    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }
    public String getSinopse() {
        return sinopse;
    }
    public void setSinopse(String sinopse) {
        this.sinopse = sinopse;
    }
    public String getClassificacaoEtaria() {
        return classificacaoEtaria;
    }
    public void setClassificacaoEtaria(String classificacaoEtaria) {
        this.classificacaoEtaria = classificacaoEtaria;
    }
    
    public List<Genero> getVetGenero() {
        return this.vetGenero;
    }
    public void setVetGenero(List<Genero> vetGenero) {
        this.vetGenero = vetGenero;
    }

    
    

}
