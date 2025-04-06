# Usarei o banco de dados concedido pela Math para responder as questões apresentadas abaixo.
USE MathTest

# Introduzirei os Dados concediso do clientes e ramificarei eles em duas variáveis.

# A primeira sendo eles a CD_CLIENTE e a segunda NM_CLIENTE referente ao número de movimentações realizadas. 

INSERT INTO TbCliente (CD_CLIENTE, NM_CLIENTE) VALUES
(1, 'João'),
(2, 'Maria'),
(3, 'José'),
(4, 'Adilson'),
(5, 'Cleber');

# Introduzirei agora uma tabela com o relacionamento das transações realizadas.
# Com identificações sobre o período da transação.
# O CD_TRANSACAO que possui a legenda de 000 para CashBack , 110 para CashIn, 220 para CashOut.
# A quarta variável apresentada é o valor realizado das transações.  

INSERT INTO TbTransacoes (CD_CLIENTE, DT_TRANSACAO, CD_TRANSACAO, VR_TRANSACAO) VALUES
(1, '2021-08-28', '000', 20.00),
(1, '2021-09-09', '110', 78.90),
(1, '2021-09-17', '220', 58.00),
(1, '2021-11-15', '110', 178.90),
(1, '2021-12-24', '220', 110.37),
(5, '2021-10-28', '110', 220.00),
(5, '2021-11-07', '110', 380.00),
(5, '2021-12-05', '220', 398.86),
(5, '2021-12-14', '220', 33.90),
(5, '2021-12-21', '220', 16.90),
(3, '2021-10-05', '110', 720.90),
(3, '2021-11-05', '110', 720.90),
(3, '2021-12-05', '110', 720.90),
(4, '2021-10-09', '000', 50.00);

# 1. Qual cliente teve o maior saldo médio no mês 11?

Para calcularmos o saldo médio por cliente,  filtraremos as transações realizadas em 11/2021. 
Usarei uma nested query para realizar uma subconsulta através do comando FROM.

Após obtermos o saldo mensal dos clientes,  utilizaremos o resultado para realizar o cálculo da média do saldo apresentado 
e selecionaremos o cliente que apresentar o maior montante.

Após realizarmos esse primeiro processo investigativo, realizaremos a primeira subconsulta interna.
Selecionaremos a variável CD_CLIENTE, e usaremos o comando SUM com CASE para realizar o tratamento das transações. 

O CASE classificará as transações de entrada (CashIn, código 110)  e as de saída (CashOut, código 220).
Somando os valores positivos nas realizações de CashIn e subtraindo os valores que apresentarem o código de CashOut. 
Utilizaremos o comando ELSE 0 para certificar que as transações realizadas como CashBack (000), não afetem a resolução da query.
Inseriremos os comandos WHERE para filtrar as transações para pela latência do período requerido, sendo ele, (01/11/2021 a 30/11/2021). 

Utilizaremos GROUP BY CD_CLIENTE na realização do agrupamento dos resultados para cada cliente.
Utilizaremos as agregações de SUM e AVG para realizar o cálculo médio da transação realizada,
implementando  o filtro do período requisitado para garantir que o insight retornado apresente um resultado sobre o penúltimo mês do Ano. 

Garantindo o ornamento dos dados através de ORDER BY Saldo_Medio e DESC para sumarização dos clientes por ordem decrescente atráves do saldo médio,
e o comando LIMIT 1 para e limitar o resultado apenas para o maior valor apresentado.

SELECT CD_CLIENTE, AVG(Saldo) AS Saldo_Medio
FROM (
    SELECT 
        CD_CLIENTE,
        SUM(CASE 
            WHEN CD_TRANSACAO = '110' THEN VR_TRANSACAO 
            WHEN CD_TRANSACAO = '220' THEN -VR_TRANSACAO 
            ELSE 0 
        END) AS Saldo
    FROM TbTransacoes
    WHERE DT_TRANSACAO BETWEEN '2021-11-01' AND '2021-11-30'
    GROUP BY CD_CLIENTE
) AS SaldoMensal
GROUP BY CD_CLIENTE
ORDER BY Saldo_Medio DESC
LIMIT 1;

José foi o cliente que obteve o maior CashIN do Banco no mês de Novembro/2021, sendo ele, no valor de  R$720.90. 

# 2.Qual é o saldo de cada cliente?

Calcularemos o saldo integral de cada cliente bancário apesar das  diferentes transações apresentadas.
Utilizaremos o comando LEFT JOIN para inclusão de todos os clientes da tabela, incluindo assim aqueles que não apresentara movimentações. 

Iniciaremos com a seleção das variáveis pertinentes, selecionaremos a coluna CD_CLIENTE da tabela TbCliente para realizar o calculo do saldo. 
Ao realizarmos a Análise Quantitativa, utilizaremos as funções SUM com Case para determinar o impacto de cada transação. 

Onde, nas transações que apresentarem o código 110 o valor será adicionado, nas transações que apresentarem o código 220 o valor será subtraido.
E os valores que apresentarem os códigos correspondentes as transações 000 serão neutralizados. 

Realizaremos a junção das tabelas através do comando LEFT JOIN para evitar a exclusão dos dados de algum cliente. 
Agruparemos a resolução do processo investigativo atraves da identificação do CD_CLIENTE para o retorno do salto total de cada cliente. 

SELECT 
    c.CD_CLIENTE,
    SUM(CASE 
        WHEN t.CD_TRANSACAO = '110' THEN t.VR_TRANSACAO 
        WHEN t.CD_TRANSACAO = '220' THEN -t.VR_TRANSACAO 
        WHEN t.CD_TRANSACAO = '000' THEN t.VR_TRANSACAO 
        ELSE 0 
    END) AS Saldo
FROM TbCliente c
LEFT JOIN TbTransacoes t ON c.CD_CLIENTE = t.CD_CLIENTE
GROUP BY c.CD_CLIENTE
LIMIT 0, 1000;

O Saldo de João é de R$ 109,43 
O Saldo de Maria é de R$ 0,00
O Saldo de José é de R$ 2162,70
O Saldo do Adilson é de R$ R$ 50,00
O Saldo de Cleber é de R$150,34

# 3.Qual é o saldo médio de clientes que receberam CashBack?

Identificaremos os clientes que recepcionaram CashBack em suas contas atráves do código CD_TRANSACAO = '000'.
Calcularemos o saldo total relacionado a cada cliente para obtermos o valor integral das transações que representará do cálculo da médio. 
Calcularemos o saldo integral relacionado a cada cliente. Utilizaremos o comando CTEs para estruturação da Query requisitada. 

As requisições de CTEs nos auxilirá a identificaremos os clientes que recepcionaram cashback em suas contas através do comando de CashBackClientes.
Selecionaremos CD_CLiente para introduzirmos os dados do cliente, TbTransacoes para auxiliar no processo investigativo, Distinct salientará que não
ocorrerá duplicidade nos calculos e garantirá que o cliente apareça apenas uma vez. 

As requisições direcionadas do comando CTE nos auxiliará a encontrar a média de SaldodoClientes e retornar o saldo total apresentado por cada cliente.
Utilizararemos CD_CLIENTE para identificarmos cada pessoa em específico, SUM para adição dos saldos apresentaodos 
e CASE para introduzirmos a regra que filtrará as transações e retornará os valores relacionadas ao CashBack.
Esse passo é importante para calcularmos o saldo líquido de cada cliente, independentemente de terem recebido CashBack. 
Essa etapa nos permitirá realizar posteriormente a filtragem de CashBack recepcionada para cada cliente. 

Aplicaremos o comando (AVG(Saldo)) apenas ao subconjunto requerido de clientes com saldos de CashBack recepcionados em sua conta que se encontram na tabela CashBackClientes.
Após a média dos saldos recepcionados, definiremos o critério atráves do comando WHERE para que a Query retornar apenas o saldo de CashBack relacionada a cada cliente.

WITH CashBackClientes AS (
    SELECT DISTINCT CD_CLIENTE
    FROM TbTransacoes
    WHERE CD_TRANSACAO = '000'
),
SaldoClientes AS (
    SELECT 
        CD_CLIENTE,
        SUM(CASE WHEN CD_TRANSACAO = '110' THEN VR_TRANSACAO 
                 WHEN CD_TRANSACAO = '220' THEN -VR_TRANSACAO 
                 ELSE 0 END) AS Saldo
    FROM TbTransacoes
    GROUP BY CD_CLIENTE
)
SELECT AVG(Saldo) AS Saldo_Medio_CashBack
FROM SaldoClientes
WHERE CD_CLIENTE IN (SELECT CD_CLIENTE FROM CashBackClientes);

# O saldo médio de clientes que receberam Cashback é de R$44.71

# 4. Qual o ticket médio das quatro últimas movimentações dos usuários?

Utilizaremos o comando CTE realizará uma consulta acerca das últimas movimentacoes com uma função que funcionará como uma janela, em seguida, unirá á tabela de cada cliente. 
Selecioremos assim,  a identificação de cada cliente e o valor da transações realizadas pelo mesmo, ordenado o resultado apresentado por ordem decrescente cronológica.

Encontramos as informações requeridas na Tabela TbTransacoes, sendo elas, as variáveis relacionadas as  as transações dos clientes. 
Dentro das variáveis presentes na TbTransacoes, selecionaremos CD_CLIENTE e VR_TRANSACAO para nossa análise.
Utilizaremos a função ROW_NUMBER() para numeraração das transações realizadas por cada cliente ordenadas de forma cronologicamente decrescente 
com a utilização da funçãode data (DT_TRANSACAO DESC).

Particionaremos  por CD_CLIENTE para que ocorra uma restaurar a numeração de cada usúario. 
Selecionaremos por CD_CLIENTE e em seguida calcularemos a média dos valores das transações realizados auxiliados pela função (AVG(VR_TRANSACAO)).
Usaremos LEFT JOIN para salientarmos novamente  que todos os clientes sejam computados e filtraremos todos os valores, para que apenas as quatro últimas transações 
do cálculo relacionado ao ticket médio sejam retornadas através do comando  rn <= 4. 

WITH UltimasMovimentacoes AS (
    SELECT 
        CD_CLIENTE,
        VR_TRANSACAO,
        ROW_NUMBER() OVER (PARTITION BY CD_CLIENTE ORDER BY DT_TRANSACAO DESC) AS rn
    FROM TbTransacoes
)
SELECT 
    c.CD_CLIENTE,
    AVG(um.VR_TRANSACAO) AS Ticket_Medio
FROM TbCliente c
LEFT JOIN UltimasMovimentacoes um ON c.CD_CLIENTE = um.CD_CLIENTE AND um.rn <= 4
GROUP BY c.CD_CLIENTE;

O Ticket Médio das 4 últimas movimentações de  João é de R$106.54
Maria não apresentou movimentações no período requerido.  
O Ticket Médio das 4 últimas movimentações de José é de R$720,90
O Ticket Médio das 4 últimas movimentações de Adilson é de R$50,00
O Ticket Médio das 4 últimas movimentações de Cleber é de 207,41

# 5. Qual é a proporção entre Cash In/Out mensal?

A Query requerida pode ser flexibilizada na utilização de análise dos dados apresentados em uma caixa por um período específico.
Somaremos o valor integral das transações mensais relacionadas aos valores de  entrada (Cash In) e de saída (Cash Out). 
Observaremos as proporcionais apresentadas pelas transações  entre Cash In e Cash Out.
Selecionaremos apenas os valores apresentados pelo requerido, sendo ele, Novembro de 2021.

Estruturaremos a Query para realização do cálculo de Cash In, atráves do ID de transação de CashIN (110)
a função SUM concomitante com CASE para somatória condicional dos valores baseado nas transações recepcionadas, finalizando
com o comando lógico para caso a transação retorne uma requisição divergente, adicionar o montante 0 ao resultado. 

Estruturaremos a Query para realizado do Cálculo de Cash Out utilizando uma estrutura similar, sendo ela,
a utilização da função SUM atrelada com CASE para adicionar as transições de saída, finalizando com 
a mesma estrutura lógica de adição 0 ao valores retornado.

Calcularemos a proporção através da divisão total de CashIN pelo valor integral apresentado em CashOut. 
Utilizaremos o comando NULLIF evitar a realização da soma dos valores por 0 e um returno de valores Nulos caso o Cash Out apresentado seja de zero reais. 

SELECT 
    SUM(CASE WHEN CD_TRANSACAO = '110' THEN VR_TRANSACAO ELSE 0 END) AS Total_CashIn,
    SUM(CASE WHEN CD_TRANSACAO = '220' THEN VR_TRANSACAO ELSE 0 END) AS Total_CashOut,
    SUM(CASE WHEN CD_TRANSACAO = '110' THEN VR_TRANSACAO ELSE 0 END) / NULLIF(SUM(CASE WHEN CD_TRANSACAO = '220' THEN VR_TRANSACAO ELSE 0 END), 0) AS Proporcao_CashIn_Out
FROM TbTransacoes
WHERE DT_TRANSACAO BETWEEN '2021-11-01' AND '2021-11-30';

A proporção de CashIN no mês de novembro é de R$1279,80 e de CashOut 0,00.

# 6. Qual a última transação de cada tipo para cada usuário?

Identificar a última data de transação para cada tipo de transação (CD_TRANSACAO) de cada cliente (CD_CLIENTE).
Identificaremos a data da última transação realizada para cada cliente, em nossa análise garantiremos que todos os clientes estejam 
inclusos atráves da função LEFT JOIN. 

Estruturaremos a Query através das variáveis CD_CLIENTE e CD_TRANSACAO presentes na TbCliente. Utilizaremos os comandos CD_TRANSACAO e a data máxima (MAX(DT_TRANSACAO)) 
para restringir um retorno relacionado apenas a  da data máxima das transações. 

Agruparemos a resolução das transações apresentadas por CD_CLIENTE e CD_TRANSACAO, para realização do cálculo relacionado a último dia de transação realizada por cada cliente. 

SELECT 
    c.CD_CLIENTE,
    t.CD_TRANSACAO,
    MAX(t.DT_TRANSACAO) AS Ultima_Transacao
FROM TbCliente c
LEFT JOIN TbTransacoes t ON c.CD_CLIENTE = t.CD_CLIENTE
GROUP BY c.CD_CLIENTE, t.CD_TRANSACAO;

As últimas transações de  João foram a 000 e 110 realizadas em 28 de agosto de 2021 e em 21 de novembro de 2021.
Maria não apresentou transações no período. 
A últimas transações de José foi de um 110 realizado no dia 05 de Dezembro de 2021
A última transação de Adilson foi de um 000 realizada no dia 09 de outubro de 2021
A última transação de Cleber foi de um 220 no dia 21 de dezembro de 2021. 

# 7. Qual a última transação de cada tipo para cada usuário por mês?

Identificaremos a data da última transação realizada através da função DATE_FORMAT, que converte a data da transação para o primeiro dia do mês requisitado. 
para auxilixar na análise utilizareos  (CD_TRANSACAO) para cada tipo de transação realizada e a variável (CD_CLIENTE) para avaliar a singularidade de cada cliente pela latência mensal.

Selecionaremos CD_CLIENTE dentro da tabela de clientes, e através da função MAX() ordenaremos o calculo da último dia das transações de cada cliente bancário. 
Concomitante a essas requisições, orientaremos DATE_FORMAT, para agrupar as transações mensais e converter a data da realizações dela para o primeiro dia de cada mês. 

Realizaremos a junções de tabelas através de LEFT JOIN, agruparemos a resolução retornada pelas variáveis de CD_CLIENTE, CD_TRANSACAO, associando assim, os verbos atrelados 
a CD_CLIENTE o mês correspondente a essa ação, visualizando assim a data da última transação realizada. 

SELECT 
    c.CD_CLIENTE,
    t.CD_TRANSACAO,
    DATE_FORMAT(t.DT_TRANSACAO, '%Y-%m-01') AS Mes,
    MAX(t.DT_TRANSACAO) AS Ultima_Transacao
FROM TbCliente c
LEFT JOIN TbTransacoes t ON c.CD_CLIENTE = t.CD_CLIENTE
GROUP BY c.CD_CLIENTE, t.CD_TRANSACAO, DATE_FORMAT(t.DT_TRANSACAO, '%Y-%m-01');

As últimas transações de João foram em: 
2021-08-01	2021-08-28
2021-09-01	2021-09-09
2021-09-01	2021-09-17
2021-11-01	2021-11-15
2021-12-01	2021-12-24

Maria não apresentou transações no período.

As últimas transações de José foram em:
2021-10-01	2021-10-05
2021-11-01	2021-11-05
2021-12-01	2021-12-05

A última transação de Adilson foi em :
2021-10-01	2021-10-09

As últimas transação de Cleber foram em:
2021-10-01	2021-10-28
2021-11-01	2021-11-07
2021-12-01	2021-12-21

# 8. Qual quantidade de usuários que movimentaram a conta?

Utilizaremos  COUNT(DISTINCT ...) para nos auxiliar a contar distintamente os clientes que realizaram movimentações bancárias. 
Obteremos o resultado após análise realizada na tabela de transações que contém todas as transações realizadas pelos usuários. 

SELECT COUNT(DISTINCT CD_CLIENTE) AS Quantidade_Usuarios
FROM TbTransacoes;

4 pessoas movimentaram a conta. 

# 9. Qual o balanço do final de 2021?

Somaremos o balanço integral das transações realizadas até o final do ano de  2021.
Consideraremos a ramificação das transações apresentadas para determinar o impacto do balanço anual.
Estruturaremos a Query com a utilização concomitante das funções SUM com CASE para realizar condicionalmente 
a soma e subtração dos dados baseado no tipo de transação realizada.

Aplicaremos a condição de CD_TRANSACAO = '110' para observamos como entrada de dinheiro a operação (Cash In), somando na variável de VR_TRANSACAO.
Aplicaremos a condição lógica de somar o valor zerado as demais transações realizadas para que elas o impacto delas seja neutralizado em nossa análise. 

Filtraremos pelo ano requisitado através da inclusão de condição (DT_TRANSACAO <= '2021-12-31'), obtendo assim análises do balanço das transações realizadas apenas para o período requisitado. 

SELECT 
    SUM(CASE WHEN CD_TRANSACAO = '110' THEN VR_TRANSACAO 
             WHEN CD_TRANSACAO = '220' THEN -VR_TRANSACAO 
             ELSE 0 END) AS Balanco_Final
FROM TbTransacoes
WHERE DT_TRANSACAO <= '2021-12-31';

O Balanço final de 2021 é de R$2402,47 transações.

# 10. Quantos usuários que receberam CashBack continuaram interagindo com este banco?

Observaremos a retenção de  usuários que receberam cashback e continuaram realizando transações após o dia 31/12/2021.
Estruturaremos a Query com CTEs para facilitar a leitura, distinguindo os comando lógicos realizados. 

Iniciaremos a análise pelo comportamento dos clientes que realizaram transações de cashback, através de CD_CLIENTE da tabela  TbTransacoes 
onde CD_TRANSACAO = '000'.
Utilizaremos o comando DISTINCT assegurando a não ocorrência de duplicidade, e garantindo que o valor analisado não obtenha duplicidade.

Realizaremos agora o Common Table Expressions na seleção de  CD_CLIENTE da tabela TbTransacoes 
,onde, DT_TRANSACAO > '2021-12-31'. Indicando a análise temporal do período requisitado. 
Utilizaremos novamente DISTINCT para assegurar a qualidade da análise e tratamentos dos dados. 

Assertivando uma análise completa que englobe todos usuários atráves de LEFT JOIN, filtraremos concomitante com a tabela TbCliente, 
Commom Table Expressions de UsuariosAtivos através da função (u.CD_CLIENTE IS NOT NULL), certificando de um valor singular para cada usuario apresentado 
através do comando  COUNT(DISTINCT c.CD_CLIENTE)   auxiliando assim na análise de retenção dos clientes exemplificados após o ano 2021.


WITH CashBackClientes AS (
    SELECT DISTINCT CD_CLIENTE
    FROM TbTransacoes
    WHERE CD_TRANSACAO = '000'
),
UsuariosAtivos AS (
    SELECT DISTINCT CD_CLIENTE
    FROM TbTransacoes
    WHERE DT_TRANSACAO > '2021-12-31'
)
SELECT 
    COUNT(DISTINCT c.CD_CLIENTE) AS Usuarios_Ativos
FROM TbCliente t
LEFT JOIN CashBackClientes c ON t.CD_CLIENTE = c.CD_CLIENTE
LEFT JOIN UsuariosAtivos u ON t.CD_CLIENTE = u.CD_CLIENTE
WHERE u.CD_CLIENTE IS NOT NULL;

Nenhum dos usuarios que receberam cashback continuaram interagindo com o banco. 

# 11. Qual a primeira e a última movimentação dos usuários com saldo maior que R$100?

Iniciaremos a resolução do questionamento proposto através da identificação dos clientes que apresentaram um  saldo maior que R$100.
Determinando com implicações lógica a primeira e a última data de movimentação desse cliente

Utilizaremos CTEs para auxiliar na resolução do cálculo  do saldo integral de cada cliente através da
utilização concomitante das funções SUM e CASE, e do comando CD_TRANSACAO = '110' para adicionarmos o valor da transações que realizaram Cash In.
e  CD_TRANSACAO = '220': para subtração do valores que realizaram Cash Out.
As demais transações seram visualizadas com os valores zerados. 

Agruparemos CD_CLIENTE para somarmos o saldo integral de cada cliente e utilizaremos HAVING na filtragem de clientes que apresentaram um com saldo maior que R$100.

Através de CD_CLIENTE calcularemos a primeira com a utilização do comando (MIN(DT_TRANSACAO)) e a última transação através da função (MAX(DT_TRANSACAO)) retornando assim a data da transação. 
Filtrando a variável de clientes presente  na lista SaldoClientes e salientando apenas o retorno daqueles que o saldo excedia R$100,00. 
Agrupando CD_CLIENTE para resolução da requisição apresentada. 

WITH SaldoClientes AS (
    SELECT 
        CD_CLIENTE,
        SUM(CASE WHEN CD_TRANSACAO = '110' THEN VR_TRANSACAO 
                 WHEN CD_TRANSACAO = '220' THEN -VR_TRANSACAO 
                 ELSE 0 END) AS Saldo
    FROM TbTransacoes
    GROUP BY CD_CLIENTE
    HAVING SUM(CASE WHEN CD_TRANSACAO = '110' THEN VR_TRANSACAO 
                    WHEN CD_TRANSACAO = '220' THEN -VR_TRANSACAO 
                    ELSE 0 END) > 100
),
Movimentacoes AS (
    SELECT 
        CD_CLIENTE,
        MIN(DT_TRANSACAO) AS Primeira_Movimentacao,
        MAX(DT_TRANSACAO) AS Ultima_Movimentacao
    FROM TbTransacoes
    WHERE CD_CLIENTE IN (SELECT CD_CLIENTE FROM SaldoClientes)
    GROUP BY CD_CLIENTE
)
SELECT * FROM Movimentacoes;

A primeira e última movimentação de José foi em:
2021-10-05	2021-12-05
A primeira e última movimentação de Cleber foi em:
2021-10-05	2021-12-05

# 12. Qual o balanço das últimas quatro movimentações de cada usuário?

Calcularemos o balanço das quatro últimas transações de cada cliente exemplificado
Observando a ramificação dos três tipos de transações apresentadas, realizaremos a análise com a utilização de CTEs.

Selecionaremos as seguintes variáveis CD_CLIENTE, CD_TRANSACAO, e VR_TRANSACAO da tabela TbTransacoes para prosseguirmos com a análise. 
Usaremos a novamente a função ROW_NUMBER() para numeração das transações distinta de cada cliente ordenada decrescentemente pela data da ação realizada através da função (DT_TRANSACAO DESC).
Particionaremos a variável CD_CLIENTE para resetar de forma ordinal a identificação de  cada cliente, possibilitando assim, realizar a identificação  das últimas quatro transações.

Utilizaremos os comandos SUM com CASE para calcular condicionalmente o balanço das 4 últimas transações.
Introduziremos a condição lógica, Se rn <= 4, para estipularmos o alcance requisitado na base de cálculo do balanço.


Estruturaremos a Query para realização do cálculo de Cash In, atráves do ID de transação de CashIN (110)
a função SUM concomitante com CASE para somatória condicional dos valores baseado nas transações recepcionadas, finalizando
com o comando lógico para caso a transação retorne uma requisição divergente, adicionar o montante 0 ao resultado. 

Estruturaremos a Query para realizado do Cálculo de Cash Out utilizando uma estrutura similar, sendo ela,
a utilização da função SUM atrelada com CASE para adicionar as transições de saída, finalizando com 
a mesma estrutura lógica de adição 0 ao valores retornado.

E utilizaremos  COALESCE para garantir que o balanço apresente o valor 0 caso os clientes não tenham  realizado transações.

WITH UltimasMovimentacoes AS (
    SELECT ]
        CD_CLIENTE,
        CD_TRANSACAO,
        VR_TRANSACAO,
        ROW_NUMBER() OVER (PARTITION BY CD_CLIENTE ORDER BY DT_TRANSACAO DESC) AS rn
    FROM TbTransacoes
)
SELECT 
    c.CD_CLIENTE,
    COALESCE(SUM(CASE 
        WHEN um.rn <= 4 THEN 
            CASE 
                WHEN um.CD_TRANSACAO = '110' THEN um.VR_TRANSACAO 
                WHEN um.CD_TRANSACAO = '220' THEN -um.VR_TRANSACAO 
                ELSE 0 
            END 
        ELSE 0
    END), 0) AS Balanço_Ultimas_Quatro
FROM TbCliente c
LEFT JOIN UltimasMovimentacoes um ON c.CD_CLIENTE = um.CD_CLIENTE
GROUP BY c.CD_CLIENTE;

As quatro últimas movimentações apresentada para cliente:
Foi de 	R$89.43 para o João
Maria não apresentou movimentação no período	0.00
De 	R$2162.70 para José
Adilson também não apresentou transação	0.00
Cleber apresenta o valor negativo de: -69.66

#13. Qual o ticket médio das últimas quatro movimentações de cada usuário?

Observaremos apenas as quatro transações mais recentes de cada cliente para solurcionarmos a requisição acima. 

Iniciaremos nossa análise através das variáveis CD_CLIENTE e VR_TRANSACAO da presentes na tabela TbTransacoes.
Utilizaremos o comando ROW_NUMBER() para realizar a numeração das transações de cada cliente, ordenando de forma cronologicamente decrescente através da função (DT_TRANSACAO DESC).
Particionaremos por CD_CLIENTE para resetar a numeração para cada cliente, possibilitando assim a identificação  das transações mais recentes.

Utilizaremos o comando  LEFT JOIN entre  as tabelas TbCliente e as presentes em CTE UltimasMovimentacoes assegurando assim que todos os  clientes sejam incluídos.
Utilizaremos o comando lógico <=4 para nos auxiliar na filtragem  do comportamento mais recente dos clientes bancários. 

Calcularemos o ticket médico através das funções  AVG(um.VR_TRANSACAO), agrupando-os por CD_CLIENTE para resolução da requisição apresentada.

WITH UltimasMovimentacoes AS (
    SELECT 
        CD_CLIENTE,
        VR_TRANSACAO,
        ROW_NUMBER() OVER (PARTITION BY CD_CLIENTE ORDER BY DT_TRANSACAO DESC) AS rn
    FROM TbTransacoes
)
SELECT 
    c.CD_CLIENTE,
    AVG(um.VR_TRANSACAO) AS Ticket_Medio
FROM TbCliente c
LEFT JOIN UltimasMovimentacoes um ON c.CD_CLIENTE = um.CD_CLIENTE AND um.rn <= 4
GROUP BY c.CD_CLIENTE;

O ticket médio apresentado para cada cliente é de:
João R$ 106.54
Maria não apresentou transações
José 	 720.90
Adilson	50.00
Cleber	207.41
