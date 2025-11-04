package persistencia;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import negocio.Filme;

public class FilmeDAO {

    public List<Filme> listar() throws SQLException{
        String sql = "SELECT * FROM filme";
        List<Filme> vetFilme = new ArrayList<>();
        Connection conexao = new ConexaoPostgreSQL().getConexao();
        PreparedStatement instrucao = conexao.prepareStatement(sql);
        ResultSet rs = instrucao.executeQuery();
        while (rs.next()) {
            Filme filme = new Filme();
            filme.setId(rs.getInt("id"));
            filme.setTitulo(rs.getString("titulo"));
            filme.setSinopse(rs.getString("sinopse"));
            vetFilme.add(filme);
        }
        conexao.close();
        return vetFilme;
    }

    public void inserir(Filme filme) throws SQLException {
           Connection conexao = new ConexaoPostgreSQL().getConexao();
            PreparedStatement instrucao = conexao.prepareStatement("INSERT INTO filme (titulo, sinopse) values (?, ?);");
            instrucao.setString(1, filme.getTitulo());
            instrucao.setString(2, filme.getSinopse());
            instrucao.execute();
            conexao.close();
    }

    public void excluir(int id) throws SQLException {
        Connection conexao = new ConexaoPostgreSQL().getConexao();
        PreparedStatement instrucao = conexao.prepareStatement("SELECT excluir_filme(?);");
        instrucao.setInt(1, id);
        instrucao.execute();
        conexao.close();
    }

}
