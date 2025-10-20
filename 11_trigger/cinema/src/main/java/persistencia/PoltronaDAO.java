package persistencia;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import negocio.Poltrona;

public class PoltronaDAO {

    public List<Poltrona> listar(int sessaoId) throws SQLException {
        List<Poltrona> vetPoltrona = new ArrayList<>();
        Connection conexao = new ConexaoPostgreSQL().getConexao();
        PreparedStatement instrucao = conexao.prepareStatement("SELECT * FROM poltrona JOIN sala on sala.id = poltrona.sala_id join sessao on sessao.sala_id = sala.id where sessao.id = ?;");
        instrucao.setInt(1, sessaoId);
        ResultSet rs = instrucao.executeQuery();
        while(rs.next()){
            Poltrona poltrona = new Poltrona();
            poltrona.setId(rs.getInt("id"));
            poltrona.setFileira(rs.getString("fileira").charAt(0));
            poltrona.setPosicao(rs.getInt("posicao"));
            poltrona.setTipo(rs.getString("tipo"));
            vetPoltrona.add(poltrona);
        }
        instrucao.close();
        conexao.close();
        // System.out.println("aqui:"+vetPoltrona.size());
        return vetPoltrona;
    }

}
