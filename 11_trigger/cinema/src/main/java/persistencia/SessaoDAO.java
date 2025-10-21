package persistencia;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import negocio.Filme;
import negocio.Sala;
import negocio.Sessao;

public class SessaoDAO {

    public List<Sessao> listarSessoesDisponiveis() throws SQLException {
        List<Sessao> vetSessao = new ArrayList<>();
        Connection conexao = new ConexaoPostgreSQL().getConexao();
        // --where data >= CURRENT_DATE and hora_inicio >= current_time;
        PreparedStatement instrucao = conexao.prepareStatement("select sessao.id, sessao.data, sessao.hora_inicio, sessao.hora_fim, filme.id as filme_id, filme.titulo as filme_titulo, sala.id as sala_id from sessao join filme on filme.id = sessao.filme_id join sala on sala.id = sessao.sala_id; ");
        ResultSet rs = instrucao.executeQuery();
        while (rs.next()) {
            Sessao sessao = new Sessao();
            sessao.setId(rs.getInt("id"));
            sessao.setData(rs.getTimestamp("data").toLocalDateTime().toLocalDate());
            sessao.setHoraInicio(rs.getTime("hora_inicio").toLocalTime());
            sessao.setHoraFim(rs.getTime("hora_fim").toLocalTime());            
            Filme filme = new Filme();
            filme.setId(rs.getInt("filme_id"));
            filme.setTitulo(rs.getString("filme_titulo"));
            sessao.setFilme(filme);
            Sala sala = new Sala();
            sala.setId(rs.getInt("sala_id"));
            sessao.setSala(sala);
            vetSessao.add(sessao);            
        }
        instrucao.close();
        conexao.close();
        // System.out.println(vetSessao.get(0).getId());
        return vetSessao;
    }

    public Sessao obter(int sessao_id) throws SQLException {
        Connection conexao = new ConexaoPostgreSQL().getConexao();
        PreparedStatement instrucao = conexao.prepareStatement("select sessao.id, sessao.data, sessao.hora_inicio, sessao.hora_fim, filme.id as filme_id, filme.titulo as filme_titulo, sala.id as sala_id from sessao join filme on filme.id = sessao.filme_id join sala on sala.id = sessao.sala_id; ");
        ResultSet rs = instrucao.executeQuery();
        Sessao sessao = null;
        if (rs.next()) {
            sessao = new Sessao();
            sessao.setId(rs.getInt("id"));
            sessao.setData(rs.getTimestamp("data").toLocalDateTime().toLocalDate());
            sessao.setHoraInicio(rs.getTime("hora_inicio").toLocalTime());
            sessao.setHoraFim(rs.getTime("hora_fim").toLocalTime());            
            Filme filme = new Filme();
            filme.setId(rs.getInt("filme_id"));
            filme.setTitulo(rs.getString("filme_titulo"));
            sessao.setFilme(filme);
            Sala sala = new Sala();
            sala.setId(rs.getInt("sala_id"));
            sessao.setSala(sala);            
        }
        instrucao.close();
        conexao.close();
        return sessao;
    }

}
