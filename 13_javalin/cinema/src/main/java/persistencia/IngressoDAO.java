package persistencia;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import negocio.Ingresso;

public class IngressoDAO {

    public boolean salvar(Ingresso ingresso) throws SQLException {
        Connection conexao = new ConexaoPostgreSQL().getConexao();
        String sql = "INSERT INTO ingresso(cpf, poltrona_id, sessao_id, valor) VALUES (?, ?, ?, 0) RETURNING id";
        PreparedStatement instrucao = conexao.prepareStatement(sql);
        instrucao.setString(1, ingresso.getCliente().getCpf());
        instrucao.setInt(2, ingresso.getPoltrona().getId());
        instrucao.setInt(3, ingresso.getSessao().getId());
        ResultSet retorno = instrucao.executeQuery();
        if (retorno.next()) {
            ingresso.setId(retorno.getInt("id"));
        }
        instrucao.close();
        conexao.close();
        return ingresso.getId() != 0;

    }

}
