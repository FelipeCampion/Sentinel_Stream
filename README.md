# Sentinel Stream: Sistema de Monitoramento e Telemetria IoT

O **Sentinel Stream** é uma solução de infraestrutura de banco de dados desenvolvida em **SQL Server (T-SQL)**. O projeto foi arquitetado para suportar a ingestão de dados massivos provenientes de dispositivos IoT, oferecendo monitoramento em tempo real, auditoria de hardware e processamento de regras de negócio automatizado.

---

## Arquitetura e Diferenciais Técnicos

### 1. Design de Dados Abstrato (Arquitetura Curinga)
Diferente de sistemas rígidos, o Sentinel Stream utiliza uma lógica de **metadados**. Através da tabela `regras_monitoramento`, o sistema pode monitorar qualquer grandeza física (temperatura, umidade, pressão, etc.) sem a necessidade de alterar a estrutura das tabelas ou o código da aplicação.

### 2. Processamento em Tempo Real (Triggers)
O "cérebro" do sistema reside em gatilhos automáticos:
* **`trg_sentinela_omni`**: Analisa cada leitura no momento da inserção. Caso os valores violem os limites predefinidos, um alerta é gerado instantaneamente na tabela `alertas_sistema`.
* **`trg_log_status_sensor`**: Garante a integridade e auditoria, registrando automaticamente qualquer mudança de estado dos sensores (ex: de 'ativo' para 'manutenção').

### 3. Performance e Escalabilidade
* **Precisão Temporal**: Utilização de `datetime2` com padrão **UTC** para rastreabilidade global e evitar conflitos de fuso horário.
* **Indexação Estratégica**: Índices compostos e por data foram implementados para garantir que consultas em tabelas com milhões de registros (Big Data) mantenham baixa latência.
* **Tipagem de Alta Capacidade**: Uso de `bigint` para chaves primárias de telemetria, prevendo o crescimento exponencial dos dados.

---

## Estrutura do Ecossistema

O projeto está dividido em três camadas principais:

1.  **DDL (Definição)**: Criação das tabelas, restrições de integridade (Check Constraints) e chaves estrangeiras.
2.  **DML (Manipulação)**: Scripts de carga inicial (Seeds) e simulação de dispositivos para validação do sistema.
3.  **Camada de Abstração (Views e Procedures)**:
    * `v_painel_alertas`: Centraliza informações complexas para consumo de dashboards.
    * `sp_resolver_alerta`: Encapsula a lógica de resolução de incidentes.
    * `sp_relatorio_sensor`: Procedure analítica para extração de médias e extremos (Mín/Máx).

---

## Como Executar

1.  Certifique-se de ter o **SQL Server** instalado.
2.  Execute o arquivo `sentinel_stream_setup.sql` para criar a estrutura e os objetos de inteligência (Triggers/Procedures).
3.  Execute o script de testes para validar o disparo automático de alertas.

---
