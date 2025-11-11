package negocio;

public class Poltrona {
    private int id;
    private char fileira;
    private int posicao;
    private String tipo;
    private Sala sala;
    
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public char getFileira() {
        return fileira;
    }
    public void setFileira(char fileira) {
        this.fileira = fileira;
    }
    public int getPosicao() {
        return posicao;
    }
    public void setPosicao(int posicao) {
        this.posicao = posicao;
    }
    public String getTipo() {
        return tipo;
    }
    public void setTipo(String tipo) {
        this.tipo = tipo;
    }
    public Sala getSala() {
        return sala;
    }
    public void setSala(Sala sala) {
        this.sala = sala;
    }

    
}
