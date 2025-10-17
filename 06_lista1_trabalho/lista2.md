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
11. Claro! Aqui estão **mais 10 ideias de triggers** para complementar os exercícios que você já listou. Mantive no mesmo contexto (sistema de cinema, com vendas de ingressos, sessões, clientes etc.):
12. **Calcular receita total da sessão após venda de ingresso**
   • *Ao inserir um novo ingresso*, atualizar o valor total arrecadado na tabela `sessao`.
13. **Registrar log de alteração de assento**
   • *Ao atualizar um ingresso* com mudança de poltrona, gravar em `log_assento` o assento antigo e o novo.
14. **Bloquear alteração de horário de sessão após o início da exibição**
   • *Antes de atualizar a sessão*, verificar se a hora atual é maior ou igual ao horário da sessão.
15. **Notificar tentativa de venda após o início da sessão**
   • *Antes de inserir um ingresso*, verificar se a hora atual é maior que o horário da sessão; se for, impedir e registrar em `log_tentativa_venda`.
16. **Registrar histórico de alteração de status da sessão (ativa, cancelada, encerrada)**
   • *Ao atualizar a tabela `sessao`*, gravar no `log_status_sessao` o status antigo, o novo e a data da alteração.
17. **Bloquear alteração de valor do ingresso após início da sessão**
   • *Antes de atualizar preço*, impedir mudança caso a sessão já tenha começado.
18. **Registrar data/hora de exclusão de sessão no log**
   • *Ao excluir da tabela `sessao`*, gravar no `log_exclusao_sessao` informações sobre a sessão removida.
19. **Bloquear exclusão de sala se houver sessões futuras agendadas**
   • *Antes de excluir da tabela `sala`*, verificar se existem sessões futuras vinculadas.
20. **Gerar log de tentativa de exclusão de ingresso pago**
   • *Antes de excluir ingresso*, se o status for “pago”, bloquear exclusão e registrar tentativa em `log_tentativa_exclusao`.
21. **Atualizar número de ingressos disponíveis da sessão ao cancelar um ingresso**
    • *Ao excluir um ingresso*, incrementar a quantidade de assentos disponíveis na sessão correspondente.
