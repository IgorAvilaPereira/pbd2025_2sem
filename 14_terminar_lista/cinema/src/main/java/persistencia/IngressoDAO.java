package persistencia;

import java.lang.reflect.Array;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.jetty.util.ssl.SslContextFactory.Client;

import negocio.Cliente;
import negocio.Filme;
import negocio.Ingresso;
import negocio.Poltrona;
import negocio.Sessao;

public class IngressoDAO {

    public boolean salvar(Ingresso ingresso)  {
        try (Connection conexao = new ConexaoPostgreSQL().getConexao()) {
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
        } catch (SQLException e) {
            return false;
        }
        return ingresso.getId() != 0;

    }

    public List<Ingresso> listarUltimos10() throws SQLException {
        ArrayList<Ingresso> vetIngresso = new ArrayList<>();
        Connection conexao = new ConexaoPostgreSQL().getConexao();
        String sql = "SELECT ingresso.id, poltrona.id as poltrona_id, fileira, posicao, cliente.cpf, cliente.nome, sessao.id as sessao_id, sessao.data, sessao.hora_inicio, filme.titulo FROM ingresso inner join sessao on sessao.id = ingresso.sessao_id inner join cliente on ingresso.cpf = cliente.cpf inner join poltrona on ingresso.poltrona_id = poltrona.id inner join filme on sessao.filme_id = filme.id ORDER BY ingresso.id DESC LIMIT 10;";
        PreparedStatement instrucao = conexao.prepareStatement(sql);
        ResultSet rs = instrucao.executeQuery();
        while (rs.next()) {
            Ingresso ingresso = new Ingresso();
            ingresso.setId(rs.getInt("id"));
            Poltrona poltrona = new Poltrona();
            poltrona.setId(rs.getInt("poltrona_id"));
            poltrona.setFileira(rs.getString("fileira").charAt(0));
            poltrona.setPosicao(rs.getInt("posicao"));
            ingresso.setPoltrona(poltrona);
            Cliente cliente = new Cliente();
            cliente.setCpf(rs.getString("cpf"));
            cliente.setNome(rs.getString("nome"));
            ingresso.setCliente(cliente);
            Sessao sessao = new Sessao();
            sessao.setId(rs.getInt("sessao_id"));
            sessao.setData(rs.getDate("data").toLocalDate());
            sessao.setHoraInicio(rs.getTime("hora_inicio").toLocalTime());
            Filme filme = new Filme();
            filme.setTitulo(rs.getString("titulo"));
            sessao.setFilme(filme);
            ingresso.setSessao(sessao);
            vetIngresso.add(ingresso);
        }
        instrucao.close();
        conexao.close();
        return vetIngresso;
    }

}
