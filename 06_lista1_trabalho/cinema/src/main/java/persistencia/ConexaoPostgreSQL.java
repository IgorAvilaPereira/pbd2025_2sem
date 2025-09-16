package persistencia;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexaoPostgreSQL {
    private String host;
    private String dbname;
    private String password;
    private String port;
    private String username;
    

    public ConexaoPostgreSQL(){
        this.host = "localhost";
        this.dbname = "cinema";
        this.port = "5432";
        this.username = "postgres";
        this.password = "postgres";
    }

    public Connection getConexao(){
        String url = "jdbc:postgresql://"+this.host+":"+this.port+"/"+dbname;
        try {
            return DriverManager.getConnection(url, username, password);
        } catch (SQLException e) {
            System.out.println("Xabum!");
            e.printStackTrace();
        }
        return null;
    }

}
