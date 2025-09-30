# 🎬 Lista 2 – Sistema de Cinema

## 🔧 Functions (10)

1. Calcular a **arrecadação total de um filme** (por `id`).
2. Contar quantos **ingressos um cliente comprou** (por CPF).
3. Retornar a **média de ocupação de uma sala** (por `id`).
4. Calcular o **percentual de ocupação de uma sessão**.
5. Listar o **filme mais lucrativo** (retorna título e valor).
6. Retornar o **gênero mais assistido** (maior número de ingressos vendidos).
7. Retornar o **diretor mais popular** (baseado em público dos filmes).
8. Calcular a **idade mínima recomendada** de um filme (classificação etária).
9. Retornar o **cliente que mais gastou** em ingressos.
10. Retornar a **sessão mais lotada** (maior ocupação em %).

---

## ⚙️ Procedures (10)

2. **Cadastrar novo filme** com título, ano, duração e classificação.
3. **Inserir sessão** validando conflito de horários na sala.
4. **Cancelar sessão** excluindo ingressos associados.
5. **Transferir sessão de sala** (se disponível).
6. **Reagendar sessão** (alterar data/hora).
7. **Atualizar classificação etária** de um filme.
8. **Excluir cliente** apenas se não houver ingressos comprados.
9. **Aplicar desconto em ingressos** de um determinado cliente.
10. **Cadastrar ingresso** para cliente/sessão validando disponibilidade.

---

## ⏱️ Triggers (10)

1. **Log de venda de ingresso** em tabela `log_ingresso`.
2. **Impedir venda de poltrona duplicada** em uma sessão.
3. **Bloquear exclusão de filme** com sessões ativas.
4. **Bloquear exclusão de cliente** que tenha ingressos comprados.
5. **Atualizar ocupação da sala** após venda de ingresso.
6. **Registrar alterações em sessões** em tabela `log_sessao`.
7. **Gerar auditoria de preço de ingresso** quando alterado.
8. **Notificar tentativa de inserção de sessão duplicada** no mesmo horário/sala.
9. **Gerar log de exclusão de ingresso** (auditoria de cancelamento).
10. **Impedir alteração de CPF do cliente** após cadastrado.


