# Trabalho 2: Expansão de Sistema de Cinema com Java, PostgreSQL e Javalin

## Descrição do Trabalho

O objetivo deste trabalho é expandir um sistema de cinema existente, implementando funcionalidades completas de *gerenciamento de filmes, salas, sessões e ingressos. O sistema deve ser desenvolvido em **Java, utilizando **Javalin* como framework web para criar uma API REST, e PostgreSQL como banco de dados relacional.

No banco de dados, deverão ser implementadas *funções, procedures e triggers* para automatizar regras de negócio e garantir a integridade dos dados. Por exemplo:

* Evitar a venda de ingressos para assentos já ocupados.
* Impedir que a venda de ingressos ultrapasse a capacidade da sala.
* Atualizar relatórios de sessões e lotação automaticamente.

O sistema permitirá que administradores e operadores:

* Cadastrem e consultem filmes e sessões.
* Vendam ingressos de forma segura e controlada.
* Consultem relatórios de ocupação por sala ou sessão.

---

## Objetivos

1. Modelar e implementar o banco de dados para armazenar informações de filmes, salas, sessões e ingressos.
2. Criar *funções* e *procedures* para automatizar operações críticas, como vendas de ingressos e cálculo de lotação.
3. Implementar *triggers* que garantam integridade e consistência nos dados, prevenindo erros e duplicidades.
4. Desenvolver uma *API REST com Java e Javalin* para permitir interação com o sistema de cinema.
5. Integrar chamadas a funções e procedures do PostgreSQL a partir do backend Java.

---

## *Exercícios e Atividades*

### *1. Funções e Procedures*

* Criar uma *função* que conte o número de ingressos vendidos por sessão.
* Criar uma *procedure* para vender ingressos, garantindo que não ultrapasse a capacidade da sala.
* Criar funções adicionais para gerar relatórios de ocupação ou verificar assentos disponíveis.

### *2. Triggers*

* Implementar um *trigger* que impeça a venda de ingressos para assentos já vendidos.
* Criar triggers adicionais que atualizem automaticamente tabelas de histórico ou relatórios sempre que houver uma venda de ingresso.

### *3. Desenvolvimento em Java com Javalin*

* Ilustrar no Projeto Javalin as funções, procedures e Triggers criadas anteriormente.
