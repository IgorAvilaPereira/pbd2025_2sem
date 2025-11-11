package persistencia;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import kotlin.contracts.Returns;
import negocio.Cliente;

public class ClienteDAO {

    public List<Cliente> listar() {
        try (Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao()) {
            String sql = "SELECT * FROM cliente where status is true ORDER BY nome";
            List<Cliente> vetCliente = new ArrayList<Cliente>();
            PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
            ResultSet rs = preparedStatement.executeQuery();
            while (rs.next()) {
                Cliente cliente = new Cliente();
                cliente.setCpf(rs.getString("cpf"));
                cliente.setNome(rs.getString("nome"));
                vetCliente.add(cliente);
            }
            return vetCliente;
        } catch (SQLException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return null;
    }

    public boolean inserir(Cliente cliente) {
        String sql = "INSERT INTO cliente (nome, cpf) VALUES(?,?);";
        try (Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao()) {
            PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
            preparedStatement.setString(1, cliente.getNome());
            preparedStatement.setString(2, cliente.getCpf());
            int linhas = preparedStatement.executeUpdate();
            return linhas == 1;
        } catch (SQLException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return false;

    }

    public Cliente obter(String cpf) {

        try (Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao()) {
            String sql = "SELECT * FROM cliente where cpf = ?;";

            PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
            preparedStatement.setString(1, cpf);
            ResultSet rs = preparedStatement.executeQuery();
            Cliente cliente = new Cliente();

            while (rs.next()) {
                cliente.setCpf(rs.getString("cpf"));
                cliente.setNome(rs.getString("nome"));
            }
            return cliente;
        } catch (SQLException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return null;
    }

    public boolean excluir(String cpf) throws SQLException {
        int linhas = 0;
        try (Connection conexaoPostgreSQL = new ConexaoPostgreSQL().getConexao()) {
            // String sql = "BEGIN; DELETE FROM ingresso WHERE cpf = ?; DELETE FROM cliente where cpf = ?; COMMIT;";
            String sql = "UPDATE cliente SET status = FALSE where cpf = ?";
            PreparedStatement preparedStatement = conexaoPostgreSQL.prepareStatement(sql);
            preparedStatement.setString(1, cpf);
            // preparedStatement.setString(2, cpf);
            linhas = preparedStatement.executeUpdate();
        }
        return linhas != 0;
    }

}
