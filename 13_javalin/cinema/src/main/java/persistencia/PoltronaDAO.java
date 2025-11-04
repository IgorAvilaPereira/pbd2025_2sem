package persistencia;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import negocio.Poltrona;

public class PoltronaDAO {

      public List<Poltrona> listarDisponiveis(int sessaoId) throws SQLException {
        List<Poltrona> vetPoltrona = new ArrayList<>();
        Connection conexao = new ConexaoPostgreSQL().getConexao();
        PreparedStatement instrucao = conexao.prepareStatement("SELECT poltrona.id, fileira, posicao, tipo FROM sala join poltrona on sala.id = poltrona.sala_id JOIN sessao on sessao.sala_id = sala.id where sessao.id = ? and poltrona.id not in(select poltrona_id from ingresso where sessao_id = ?);");
        instrucao.setInt(1, sessaoId);
        instrucao.setInt(2, sessaoId);
        ResultSet rs = instrucao.executeQuery();
        while(rs.next()){
            Poltrona poltrona = mapper(rs);         
            vetPoltrona.add(poltrona);
        }
        instrucao.close();
        conexao.close();
        // System.out.println("aqui:"+vetPoltrona.size());
        return vetPoltrona;
    }



    // public List<Poltrona> listar(int sessaoId) throws SQLException {
    //     List<Poltrona> vetPoltrona = new ArrayList<>();
    //     Connection conexao = new ConexaoPostgreSQL().getConexao();
    //     PreparedStatement instrucao = conexao.prepareStatement("SELECT * FROM poltrona JOIN sala on sala.id = poltrona.sala_id join sessao on sessao.sala_id = sala.id where sessao.id = ?;");
    //     instrucao.setInt(1, sessaoId);
    //     ResultSet rs = instrucao.executeQuery();
    //     while(rs.next()){
    //         Poltrona poltrona = mapper(rs);         
    //         vetPoltrona.add(poltrona);
    //     }
    //     instrucao.close();
    //     conexao.close();
    //     // System.out.println("aqui:"+vetPoltrona.size());
    //     return vetPoltrona;
    // }

    private Poltrona mapper(ResultSet rs) throws SQLException {
        Poltrona poltrona = new Poltrona();
        poltrona.setId(rs.getInt("id"));
        poltrona.setFileira(rs.getString("fileira").charAt(0));
        poltrona.setPosicao(rs.getInt("posicao"));
        poltrona.setTipo(rs.getString("tipo"));
        return poltrona;
    }

    public Poltrona obter(int id) throws SQLException {
         Connection conexao = new ConexaoPostgreSQL().getConexao();
        PreparedStatement instrucao = conexao.prepareStatement("SELECT * FROM poltrona where id = ?;");
        instrucao.setInt(1, id);
        ResultSet rs = instrucao.executeQuery();
        Poltrona poltrona = null;
        if(rs.next()){
            poltrona = mapper(rs); 
        }
        instrucao.close();
        conexao.close();
        if (poltrona != null) return poltrona;
        return null;
    }

}
