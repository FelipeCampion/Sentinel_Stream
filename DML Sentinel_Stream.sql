use sentinel_stream;
go

-- Inserindo os tipos de sensores suportados
insert into tipo_sensor (nome_tipo, unidade_medida) values 
('temperatura', 'celsius'),
('umidade', 'percentual'),
('pressão', 'pascal');

-- Inserindo o catálogo de mensagens (Normalização)
insert into mensagens_padrao (codigo_alerta, texto_mensagem) values 
('crit_001', 'perigo: temperatura acima do limite de segurança!'),
('crit_002', 'alerta: umidade criticamente baixa para o ambiente.'),
('warn_001', 'atenção: oscilação de pressão detectada.');

-- Inserindo os sensores (Exemplo em Rio Claro)
insert into sensores (nome_sensor, latitude, longitude, id_tipo) values 
('sensor_estufa_01', -22.4111, -47.5622, 1), -- temperatura
('sensor_estufa_02', -22.4115, -47.5620, 2), -- umidade
('sensor_tanque_beta', -22.3950, -47.5410, 3); -- pressão

-- Configurando as regras de monitoramento (O motor do sistema)
-- vinculando limites específicos para cada sensor e qual mensagem disparar
insert into regras_monitoramento (id_sensor, limite_minimo, limite_maximo, id_mensagem, nivel_severidade) values 
(1, 10.00, 32.00, 1, 'crítica'), -- sensor 1 dispara crit_001 se > 32°c
(2, 30.00, 80.00, 2, 'alta');    -- sensor 2 dispara crit_002 se < 30%
go

-- Simulando a ingestão de dados (Telemetria)
-- estas inserções vão disparar a trigger 'trg_sentinela_omni'

-- leitura normal (não gera alerta)
insert into leituras_telemetria (id_sensor, valor_leitura) values (1, 24.5);

-- leitura crítica (vai gerar alerta de temperatura alta)
insert into leituras_telemetria (id_sensor, valor_leitura) values (1, 38.2);

-- leitura crítica (vai gerar alerta de umidade baixa)
insert into leituras_telemetria (id_sensor, valor_leitura) values (2, 25.0);
go

-- Testando a Trigger de Auditoria (Log)
-- Mudança no status de um sensor para ver se ele grava o log sozinho
update sensores set status_sensor = 'manutenção' where id_sensor = 1;
update sensores set status_sensor = 'ativo' where id_sensor = 1;
go

-- Verificar os alertas gerados automaticamente pela trigger
-- note como a view v_painel_alertas já traz os nomes e textos mastigados
select * from v_painel_alertas;

-- Verificar o log de auditoria de status
-- mostra que o banco "vigiou" o update e gravou o status anterior e o novo
select * from log_status_sensor;

-- Testar a procedure de resolução de alerta
-- simula um operador do sistema marcando o incidente como resolvido
exec sp_resolver_alerta @id_alerta = 1, @novo_status = 'resolvido';

-- Testar a procedure de relatório estatístico
-- extrai inteligência dos dados brutos (média, min, max) de um período
-- ajuste as datas para o dia de hoje conforme sua necessidade
declare @hoje datetime2 = sysutcdatetime();
declare @amanha datetime2 = dateadd(day, 1, sysutcdatetime());

exec sp_relatorio_sensor 
    @id_sensor = 1, 
    @data_inicio = @hoje, 
    @data_fim = @amanha;

-- Consulta bruta de telemetria para conferir os índices
-- o sql server usará o idx_data_leitura aqui para performance
select top 100 * from leituras_telemetria 
order by data_leitura desc;
