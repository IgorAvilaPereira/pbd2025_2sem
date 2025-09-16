package apresentacao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.javalin.Javalin;
import io.javalin.http.staticfiles.Location;
import io.javalin.rendering.template.JavalinMustache;
import negocio.Filme;
import persistencia.ConexaoPostgreSQL;
import persistencia.FilmeDAO;

public class Main {
    public static void main(String[] args) {
          var app = Javalin.create(config -> {
                config.fileRenderer(new JavalinMustache());
                config.staticFiles.add("/static", Location.CLASSPATH);
            }).start(7070);

        app.get("/excluir/{id}", ctx -> {
            Connection conexao = new ConexaoPostgreSQL().getConexao();
            PreparedStatement instrucao = conexao.prepareStatement("SELECT excluir_filme(?);");
            instrucao.setInt(1, Integer.parseInt(ctx.pathParam("id")));
            instrucao.execute();
            conexao.close();
            ctx.redirect("/");
        });  

        app.get("/cancelar_sessao/{id}", ctx -> {
            Connection conexao = new ConexaoPostgreSQL().getConexao();
            PreparedStatement instrucao = conexao.prepareStatement("SELECT cancelar_sessao(?);");
            instrucao.setInt(1, Integer.parseInt(ctx.pathParam("id")));
            instrucao.execute();
            conexao.close();
            ctx.redirect("/");
        });

        app.get("/tela_adicionar", ctx -> {
             ctx.render("/templates/tela_adicionar.html");
        });

        app.post("/adicionar", ctx -> {
            Filme filme = new Filme();
            filme.setTitulo(ctx.formParam("titulo"));
            filme.setSinopse(ctx.formParam("sinopse"));
            new FilmeDAO().inserir(filme);
            ctx.redirect("/");


        });

        app.get("/", ctx -> {
            // String htmlOuput = "<ul>";
            List<Filme> vetFilme = new FilmeDAO().listar();
            Map<String, Object> map = new HashMap();
            map.put("vetFilme", vetFilme);           
            ctx.render("/templates/index.html", map);

             // for (Filme filme : vetFilme) {
            //     htmlOuput += "<li style='color:red'>"+filme.getTitulo()+"</li>";
            // }
            // htmlOuput+="</ul>";
            // ctx.html(htmlOuput);
            // ctx.json(vetFilme);
        });
    }
}