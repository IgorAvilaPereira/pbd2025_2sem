package persistencia;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import negocio.Genero;

public class GeneroDAO {

    public List<Genero> listar() throws SQLException {
        String sql = "SELECT * FROM genero";
        Connection conexao = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = conexao.prepareStatement(sql);
        ResultSet rs = preparedStatement.executeQuery();
        List<Genero> vetGenero = new ArrayList<>();
        while (rs.next()) {
            Genero genero = new Genero();
            genero.setNome(rs.getString("nome"));
            genero.setId(rs.getInt("id"));
            vetGenero.add(genero);            
        }
        return vetGenero;
    }

    public List<Genero> listar(List<String> vetGeneroID) throws SQLException {
        String sql = "SELECT * FROM genero where id in("+String.join(",", vetGeneroID)+");";
        Connection conexao = new ConexaoPostgreSQL().getConexao();
        PreparedStatement preparedStatement = conexao.prepareStatement(sql);
        ResultSet rs = preparedStatement.executeQuery();
        List<Genero> vetGenero = new ArrayList<>();
        while (rs.next()) {
            Genero genero = new Genero();
            genero.setId(rs.getInt("id"));
            genero.setNome(rs.getString("nome"));
            vetGenero.add(genero);            
        }
        return vetGenero;
    }

}
