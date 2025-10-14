package apresentacao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.databind.ObjectMapper;

import io.javalin.Javalin;
import io.javalin.http.staticfiles.Location;
import io.javalin.rendering.template.JavalinMustache;
import negocio.Filme;
import negocio.Poltrona;
import negocio.Sessao;
import persistencia.ConexaoPostgreSQL;
import persistencia.FilmeDAO;
import persistencia.PoltronaDAO;
import persistencia.SessaoDAO;

public class Main {
    public static void main(String[] args) {
          var app = Javalin.create(config -> {
                config.fileRenderer(new JavalinMustache());
                config.staticFiles.add("/static", Location.CLASSPATH);
            }).start(7070);

        app.get("/excluir/{id}", ctx -> {
            new FilmeDAO().excluir(Integer.parseInt(ctx.pathParam("id")));         
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

        app.post("/venda_ingresso", ctx -> {
            ctx.formParam("cpf");
            int poltrona_id = Integer.parseInt(ctx.formParam("poltrona_id"));
            int sessao_id = Integer.parseInt(ctx.formParam("sessao_id"));
            //  Ingresso ingresso = new Ingresso();
            // new IngressoDAO().compra();
            ctx.redirect("/");
        });
        
        app.post("/busca_poltronas", ctx -> {
            ObjectMapper objectMapper = new ObjectMapper();
            Map<String, String> map = objectMapper.readValue(ctx.body(), Map.class);
            int sessaoId = Integer.parseInt(map.get("sessao_id"));
            // System.out.println("sessaoid"+sessaoId);
            // System.out.println("foi?"+new PoltronaDAO().listar(sessaoId).size());
            ctx.json(new PoltronaDAO().listar(sessaoId));
        });

        app.get("/tela_venda_ingresso", ctx -> {
            List<Sessao> vetSessao = new ArrayList<>();
            // List<Poltrona> vetPoltrona = new ArrayList<>();
            Map<String, Object> map = new HashMap();
            vetSessao = new SessaoDAO().listarSessoesDisponiveis();
            map.put("vetSessao", vetSessao);           
            // map.put("vetPoltrona", vetPoltrona);
            ctx.render("/templates/tela_venda_ingresso.html", map);        
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