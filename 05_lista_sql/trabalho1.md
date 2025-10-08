# Trabalho 1

## Valor e Data de Entrega 

* Trabalho 1 valerá 6 pontos 

* E terá uma semana a mais (já ajustada no SIGAA) já que aumentamos os requisitos

## Descrição: 

* Funcionalidades exigidas abaixo + incorporar estas funcionalidades ao sistema javalin que estamos desenvolvendo em aula.

Baseado no nosso banco de cinema, implemente:

### ✅ Relatório de clientes frequentes com média de gasto

**Descrição:**
Crie uma função que gere um relatório com os clientes que compraram ingressos em pelo menos 5 sessões diferentes, informando:

* CPF do cliente
* Nome
* Quantidade de ingressos comprados
* Total gasto
* Valor médio gasto por ingresso

  **Dica:**  para colocar o nome será preciso acrescentar uma nova tabela (para não infringir regras de normalização), e usar - ou não - o cpf como chave estrangeira (coluna cpf já existe na tabela de ingresso - mas ainda não funciona como fk)

---

### ✅ Verificar sessões simultâneas para o mesmo filme

**Descrição:**
Implemente uma função que verifica se existe **conflito de horário** para sessões do **mesmo filme em salas diferentes**. Retorne as sessões que iniciam no mesmo horário, com o mesmo filme, em salas distintas.

---

### ✅ Simulação de ocupação futura de sessão

**Descrição:**
Crie uma função que simula a ocupação de uma sessão com base em um percentual informado (ex: 70%).
A função deverá:

* Receber `id_sessao` e percentual de ocupação
* Verificar se há poltronas suficientes
* Inserir "ingressos simulados" em uma **tabela** (pode ser normal ou temporária)
* Retornar o número de poltronas que seriam ocupadas

---

### ✅ Função de ajuste automático de preços em sessões com baixa ocupação

**Descrição:**
Implemente uma função que reduza o valor dos ingressos de uma sessão em 20% **caso a ocupação seja inferior a 30%** a até 1 hora do início da sessão.

* A função deve ser executada manualmente ou via agendamento externo
* Atualizar os preços diretamente na tabela de ingressos ainda não vendidos
* Retornar a quantidade de ingressos ajustados

---

### ✅ Procedure de remanejamento de poltronas

**Descrição:**
Crie uma procedure que permita **remanejar** um cliente de uma poltrona para outra dentro da mesma sessão.
Ela deve:

* Verificar se a nova poltrona está disponível
* Atualizar a poltrona do ingresso
* Gerar um log do remanejamento com CPF do cliente, data/hora, poltrona antiga e nova


