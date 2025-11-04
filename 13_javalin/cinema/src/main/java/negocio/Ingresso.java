package negocio;

public class Ingresso {
    private int id;
    private Poltrona poltrona;
    private Sessao sessao;
    private Cliente cliente;
    
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
   
    public Poltrona getPoltrona() {
        return poltrona;
    }
    public void setPoltrona(Poltrona poltrona) {
        this.poltrona = poltrona;
    }
    public Sessao getSessao() {
        return sessao;
    }
    public void setSessao(Sessao sessao) {
        this.sessao = sessao;
    }
    public void setCliente(Cliente cliente) {
        this.cliente = cliente;
    }
    public Cliente getCliente() {
        return cliente;
    }

    
    


}
