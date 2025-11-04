package apresentacao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.jetty.util.ssl.SslContextFactory.Client;

import com.fasterxml.jackson.databind.ObjectMapper;

import io.javalin.Javalin;
import io.javalin.http.staticfiles.Location;
import io.javalin.rendering.template.JavalinMustache;
import negocio.Cliente;
import negocio.Filme;
import negocio.Ingresso;
import negocio.Poltrona;
import negocio.Sessao;
import persistencia.ClienteDAO;
import persistencia.ConexaoPostgreSQL;
import persistencia.FilmeDAO;
import persistencia.GeneroDAO;
import persistencia.IngressoDAO;
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
            Map<String, Object> map = new HashMap();
            map.put("vetGenero", new GeneroDAO().listar());
            ctx.render("/templates/filme/tela_adicionar.html", map);
        });

        app.get("/tela_adicionar_cliente", ctx -> {
            ctx.render("/templates/cliente/tela_adicionar.html");
        });

        app.post("/adicionar", ctx -> {
            Filme filme = new Filme();
            filme.setTitulo(ctx.formParam("titulo"));
            filme.setSinopse(ctx.formParam("sinopse"));
            List<Integer> vetGenero = listStringToListInteger(ctx.formParams("generos"));
            filme.setVetGenero(new GeneroDAO().listar(vetGenero));
            new FilmeDAO().inserir(filme);
            ctx.redirect("/");
        });


        app.post("/adicionar_cliente", ctx -> {
            Cliente cliente = new Cliente();
            cliente.setCpf(ctx.formParam("cpf"));
            cliente.setNome(ctx.formParam("nome"));
            new ClienteDAO().inserir(cliente);
            ctx.redirect("/");
        });


        app.post("/venda_ingresso", ctx -> {
            String cpf = ctx.formParam("cpf");
            int poltrona_id = Integer.parseInt(ctx.formParam("poltrona_id"));
            int sessao_id = Integer.parseInt(ctx.formParam("sessao_id"));
            String cliente_cpf = ctx.formParam("cliente_cpf");
            Cliente cliente = new ClienteDAO().obter(cliente_cpf);
            Ingresso ingresso = new Ingresso();
            ingresso.setCliente(cliente);
            Poltrona poltrona = new PoltronaDAO().obter(poltrona_id);
            ingresso.setPoltrona(poltrona);
            Sessao sessao = new SessaoDAO().obter(sessao_id);
            ingresso.setSessao(sessao);
            boolean resposta = new IngressoDAO().salvar(ingresso);
            // ctx.redirect("/");
            // Map<String, Object> map = new HashMap();
            // map.put("mensagem", resposta);
            ctx.html("<script>alert('"+resposta+"');location.href='/';</script>");
            // ctx.render("/templates/mensagem.html", map);
        });
        
        app.post("/busca_poltronas", ctx -> {
            ObjectMapper objectMapper = new ObjectMapper();
            Map<String, String> map = objectMapper.readValue(ctx.body(), Map.class);
            int sessaoId = Integer.parseInt(map.get("sessao_id"));
            ctx.json(new PoltronaDAO().listarDisponiveis(sessaoId));
        });

        app.get("/tela_venda_ingresso", ctx -> {
            List<Sessao> vetSessao = new ArrayList<>();
            // List<Poltrona> vetPoltrona = new ArrayList<>();
            Map<String, Object> map = new HashMap();
            vetSessao = new SessaoDAO().listarSessoesDisponiveis();
            
            map.put("vetSessao", vetSessao);      
            map.put("vetCliente", new ClienteDAO().listar());     
            // map.put("vetPoltrona", vetPoltrona);
            ctx.render("/templates/ingresso/tela_venda_ingresso.html", map);        
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

    private static List<Integer> listStringToListInteger(List<String> vStrings) {
        List<Integer> vIntegers = new ArrayList<>();
        for (String string : vStrings) {
            vIntegers.add(Integer.parseInt(string));
        }
        return vIntegers;
    }
}