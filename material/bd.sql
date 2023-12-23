-- DROP SCHEMA smm_jardinf;
-- CREATE DATABASE smm_jardinf DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE smm_jardinf;
SET FOREIGN_KEY_CHECKS = 0;



-- ----------------------------------
-- @AM-23-12-23
-- tabelas users
-- ----------------------------------

DROP TABLE IF EXISTS users;
CREATE TABLE `users` (
                         `id` bigint unsigned NOT NULL AUTO_INCREMENT,
                         `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
                         `short_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
                         `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
                         `email_verified_at` DATETIME DEFAULT NULL,
                         `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
                         `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                         avatar varchar(255) 			DEFAULT NULL,
                         deactivated_at					DATETIME NULL DEFAULT NULL,
                         `created_at` DATETIME NULL DEFAULT NULL,
                         `updated_at` DATETIME NULL DEFAULT NULL,
                         PRIMARY KEY (`id`),
                         UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS config;
CREATE TABLE config
(
    id                             bigint unsigned                         NOT NULL AUTO_INCREMENT,
    nif_jdi                        varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    vagas_34                       tinyint unsigned default 15,
    vagas_45                       tinyint unsigned default 15,
    h_inic_manha                   TIME             DEFAULT '07:30',
    h_fim_manha                    TIME             DEFAULT NULL,
    h_inic_tarde                   TIME             DEFAULT NULL,
    h_fim_tarde                    TIME             DEFAULT '19:00',
    max_dias_horizonte_agendamento tinyint unsigned default 10,
    -- --------------------
    created_at                     DATETIME        DEFAULT CURRENT_TIMESTAMP,
    updated_at                     DATETIME         DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
    -- ------------------
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS config_docs;
CREATE TABLE config_docs
(
    id                     int unsigned                            NOT NULL AUTO_INCREMENT,
    nome                   varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    is_obrigatorio         tinyint unsigned default 0,
    is_calculo_mensalidade tinyint unsigned default 0,
    -- --------------------
    created_at             DATETIME        DEFAULT CURRENT_TIMESTAMP,
    updated_at             DATETIME         DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
    -- ------------------
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS crianca;
CREATE TABLE crianca
(
    id                          bigint unsigned                         NOT NULL AUTO_INCREMENT,
    nproc                       varchar(20) COLLATE utf8mb4_unicode_ci  NOT NULL,
    inscricao_atual_id          BIGINT unsigned                                  DEFAULT NULL,
    -- ------------------
    nome                        varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    tratado_pelo_nome           varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    dn                          DATETIME                                         DEFAULT NULL,
    dt_inic_frequencia          DATE                                             DEFAULT NULL,
    nif                         varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    niss                        varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    -- ------------------
    -- 0 - própria (!= pai, != mãe, != outro)
    -- 1 - pai
    -- 2 - mãe
    -- 3 - outro
    tipo_morada                 tinyint unsigned                                 default 0,
    inscricao_atual_morada_id   BIGINT unsigned                                  DEFAULT NULL,
    -- ------------------
    -- has_rl_pai?
    inscricao_atual_rl_pai_id   BIGINT unsigned                                  DEFAULT NULL,
    -- ------------------
    -- has_rl_mae?
    inscricao_atual_rl_mae_id   BIGINT unsigned                                  DEFAULT NULL,
    -- ------------------
    -- has_rl_outro?
    inscricao_atual_rl_outro_id BIGINT unsigned                                  DEFAULT NULL,
    -- ------------------
    -- 0 - Outro
    -- 1 - Mãe
    -- 2 - Pai
    -- 3 - Pais
    tipo_ee                     tinyint unsigned                        NOT NULL default 0,
    -- ------------------
    obs                         text                                             default NULL,
    -- ------------------
    created_at                  DATETIME                                        DEFAULT CURRENT_TIMESTAMP,
    updated_at                  DATETIME                                         DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at                  DATETIME                               NULL     DEFAULT NULL,
    PRIMARY KEY (id)
    -- ------------------
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;


DROP TABLE IF EXISTS atendimento;
CREATE TABLE atendimento
(
    id                      bigint unsigned                 NOT NULL AUTO_INCREMENT,
    -- ------------------
    -- campos que só interessam para candidaturas (ordem=0)
    -- ------------------
    -- 0 - Primeira visita não realizada, o EE/RL assim o entendeu.
    -- 1 - Visita realizada.
    -- 2 - Primeira visita não realizada, a resposta social não tinha disponibilidade.
    -- 3 - Primeira visita não realizada. Não foi possível agendar a visita por falta de disponibilidade do EE/RL.
    tipo_realizacao         tinyint unsigned                NOT NULL default 0,
    motivo_inscricao        text COLLATE utf8mb4_unicode_ci NOT NULL,
    dt_pretendida           DATE                                     DEFAULT NULL,
    -- ------------------
    -- 0 - nenhum
    -- 1 - telefónico
    -- 2 - presencial
    tipo_atendimento        tinyint unsigned                NOT NULL default 0,
    dh_sugerida_atentimento DATE                                     DEFAULT NULL,
    dh_agendada_atentimento DATE                                     DEFAULT NULL,
    obs_visita              text COLLATE utf8mb4_unicode_ci NOT NULL,
    -- ------------------
    created_at              DATETIME                                DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME                                 DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
    -- ------------------
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS inscricao;
CREATE TABLE inscricao
(
    id                            bigint unsigned                         NOT NULL AUTO_INCREMENT,
    crianca_id                    bigint unsigned                         not NULL,
    -- ------------------
    -- 0 - candidatura
    -- 1 - 1a Inscrição
    -- 2 - 2a Inscrição
    -- N - N-ésima Inscrição
    ordem                         tinyint unsigned                                 default 0,
    al                            int unsigned                                     default 2023,
    dt_validada                   DATETIME                                         DEFAULT NULL,
    dt_inicio_freq                DATETIME                                         DEFAULT NULL,
    estado                        tinyint unsigned                                 default 0,
    last_comunicacao              bigint unsigned                                  default NULL,
    foto                          varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    -- ------------------
    -- 1 - 3/4
    -- 2 - 4/5
    sala                          tinyint unsigned                                 default 0,
    -- ------------------
    -- 0 - própria (!= pai, != mãe, != outro)
    -- 1 - mãe
    -- 2 - pai
    -- 3 - outro
    -- !has_rl_mãe => tipo_morada_c IN (0,2,3)
    -- !has_rl_pai => tipo_morada_c IN (0,1,3)
    -- !has_rl_mãe && !has_rl_pai => tipo_morada_c IN (0,3)
    -- !has_rl_outro => tipo_morada_c IN (1,2)
    -- NOTA: has_rl_mãe || has_rl_pai || has_rl_outro
    tipo_morada_c                 tinyint unsigned                                 default 0,
    morada_id                     bigint unsigned                                  default NULL,
    -- ------------------
    -- caso tenha pai, um novo rl (pai) é registado a cada inscrição (para manter o histórico)
    -- has_rl_pai?
    rl_pai_id                     BIGINT unsigned                                  DEFAULT NULL,
    -- ------------------
    -- caso tenha mãe, um novo rl (mãe) é registado a cada inscrição (para manter o histórico)
    -- has_rl_mae?
    rl_mae_id                     BIGINT unsigned                                  DEFAULT NULL,
    -- ------------------
    -- caso tenha outro, um novo rl (outro) é registado a cada inscrição (para manter o histórico)
    -- has_rl_o?
    rl_outro_id                   BIGINT unsigned                                  DEFAULT NULL,
    -- ------------------
    -- 0 - Outro
    -- 1 - Mãe
    -- 2 - Pai
    -- 3 - Pais
    tipo_ee                       tinyint unsigned                        NOT NULL default 0,
    motivo_outro_rl               text COLLATE utf8mb4_unicode_ci         NOT NULL,
    -- ------------------
    atendimento_id                BIGINT unsigned                                  DEFAULT NULL,
    -- ------------------
    qtd_irmaos_no_jdi             tinyint unsigned                        NOT NULL default 0,
    is_encaminhado_de_outros_serv varchar(255) COLLATE utf8mb4_unicode_ci          DEFAULT NULL,
    is_familiar_de_colaborador    tinyint unsigned                        NOT NULL default 0,
    -- familiar de um colaborador
    familiar_user_id              bigint unsigned                                  default NULL,
    familiar_parentesco_id        int unsigned                                     default NULL,
    -- ------------------
    is_necessario_apoio_especial  tinyint unsigned                        NOT NULL default 0,
    apoio_especial                text COLLATE utf8mb4_unicode_ci         NOT NULL,
    -- ------------------
    created_at                    DATETIME                                        DEFAULT CURRENT_TIMESTAMP,
    updated_at                    DATETIME                                         DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at                    DATETIME                               NULL     DEFAULT NULL,
    PRIMARY KEY (id)
    -- ------------------
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS rl;
CREATE TABLE rl
(
    id                 bigint unsigned                         NOT NULL AUTO_INCREMENT,
    user_id            bigint unsigned                                  default NULL,
    -- 0 - Outro
    -- 1 - Mãe
    -- 2 - Pai
    tipo_rl            tinyint unsigned                        NOT NULL default 0,
    nome               varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    dn                 DATETIME                                         DEFAULT NULL,
    nif                varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    email              varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    email_verified_at  DATETIME                                        DEFAULT NULL,
    tel                varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    tlm                varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    -- ------------------
    morada_id          bigint unsigned                                  default NULL,
    sit_prof           varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    profissao          varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    localidade_emprego varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    tlf_emprego        varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,

    -- ------------------
    created_at         DATETIME                                        DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME                                         DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
    -- ------------------
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS pessoa;
CREATE TABLE pessoa
(
    id                   bigint unsigned                         NOT NULL AUTO_INCREMENT,
    inscricao_id         bigint unsigned                         NOT NULL,
    -- ------------------
    -- 0 - Não
    -- 1 - Sim
    pode_levar_crianca   tinyint unsigned                        NOT NULL default 0,
    is_emergencia        tinyint unsigned                        NOT NULL default 0,
    in_agregado_familiar tinyint unsigned                        NOT NULL default 0,
    -- ------------------
    nome                 varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    -- ------------------
    -- 0 - Nenhum
    -- 1 - Mãe
    -- 2 - Pai
    -- 3 - Outro RL
    -- 4 - Irmão / Irmá
    -- 5 - Avó / Avô
    -- 6 - Tia / Tio
    -- 7 - ...
    parentesco_id        int unsigned                                     default NULL,
    email                varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    tel                  varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    tlm                  varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    profissao            varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    dn                   DATETIME                                         DEFAULT NULL,
    rendimento           decimal(9, 2) unsigned                           DEFAULT 0,
    -- ------------------
    created_at           DATETIME                                        DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME                                         DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
    -- ------------------
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS documento;
CREATE TABLE documento
(
    id                     bigint unsigned                         NOT NULL AUTO_INCREMENT,
    inscricao_id           bigint unsigned                         NOT NULL,
    config_doc_id          int unsigned     default NULL,
    -- --------------------
    nome                   varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    is_obrigatorio         tinyint unsigned default 0,
    is_calculo_mensalidade tinyint unsigned default 0,
    -- --------------------
    entregue_em            DATETIME        DEFAULT null,
    entregue_por_user_id   bigint unsigned                         NOT NULL,
    -- --------------------
    validado_em            DATETIME        DEFAULT null,
    validado_por_user_id   bigint unsigned                         NOT NULL,
    -- --------------------
    created_at             DATETIME        DEFAULT CURRENT_TIMESTAMP,
    updated_at             DATETIME         DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
    -- ------------------
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS morada;
CREATE TABLE morada
(
    id         bigint unsigned                         NOT NULL AUTO_INCREMENT,
    -- ------------------
    rua        varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    localidade varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    cp1        varchar(4) COLLATE utf8mb4_unicode_ci   NOT NULL,
    cp2        varchar(3) COLLATE utf8mb4_unicode_ci   NOT NULL,
    -- ------------------
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
    -- ------------------
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS parentesco;
CREATE TABLE parentesco
(
    id         int unsigned                            NOT NULL AUTO_INCREMENT,
    -- ------------------
    designacao varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    -- ------------------
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
    -- ------------------
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS morph_comunicacao;
CREATE TABLE morph_comunicacao
(
    id                    bigint unsigned                         NOT NULL AUTO_INCREMENT,
    gut                   int unsigned                            NOT NULL DEFAULT 111,
    -- ------------------
    assunto               varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    -- ------------------
    -- quem registou
    registado_por_user_id bigint unsigned                         NOT NULL,
    -- ------------------
    -- para quem
    destinatario_user_id  bigint unsigned                                  default NULL,
    lido_em               DATETIME                                        default NULL,
    -- ------------------
    -- Contexto da mensagem:
    --   - estados anterior (estado em que se encontrava o modelo quando é registada a comunicação) e
    --     atual (estado em que ficou o modelo depois da comunicação)
    --   - sobre que o quê (candidatura, inscrição,....
    estado_ant            tinyint unsigned                        NOT NULL default 0,
    estado_atual          tinyint unsigned                        NOT NULL default 0,
    morph_model           varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    morph_id              bigint unsigned                                  default NULL,
    -- ------------------
    -- 1 - presencial
    -- 2 - telefónico
    -- 3 - email
    tipo_contacto         tinyint unsigned                        NOT NULL default 0,
    mensagem              text COLLATE utf8mb4_unicode_ci         NOT NULL,
    -- ------------------
    -- ------------------
    created_at            DATETIME                                        DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME                                         DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
    -- ------------------
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

--  ------------------------------------------------------------------------
--  criança
--  ------------------------------------------------------------------------
-- DROP INDEX crianca_nproc_idx ON crianca;
-- DROP INDEX crianca_nif_idx ON crianca;
-- DROP INDEX crianca_niss_idx ON crianca;
CREATE UNIQUE INDEX crianca_nproc_idx ON crianca (nproc ASC);
CREATE INDEX crianca_nif_idx ON crianca (nif ASC);
CREATE INDEX crianca_niss_idx ON crianca (niss ASC);

CREATE INDEX crianca_inscricao_atual_id_idx ON crianca (inscricao_atual_id ASC);
CREATE INDEX crianca_inscricao_atual_morada_id_idx ON crianca (inscricao_atual_morada_id ASC);
CREATE INDEX crianca_rl_mae_id_idx ON crianca (inscricao_atual_rl_mae_id ASC);
CREATE INDEX crianca_rl_pai_id_idx ON crianca (inscricao_atual_rl_pai_id ASC);
CREATE INDEX crianca_rl_outro_id_idx ON crianca (inscricao_atual_rl_outro_id ASC);

ALTER TABLE crianca
    ADD CONSTRAINT fk_crianca_inscricao_atual_id FOREIGN KEY (inscricao_atual_id)
        REFERENCES inscricao (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

ALTER TABLE crianca
    ADD CONSTRAINT fk_crianca_inscricao_atual_morada_id FOREIGN KEY (inscricao_atual_morada_id)
        REFERENCES morada (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

ALTER TABLE crianca
    ADD CONSTRAINT fk_crianca_rl_pai_id FOREIGN KEY (inscricao_atual_rl_pai_id)
        REFERENCES rl (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

ALTER TABLE crianca
    ADD CONSTRAINT fk_crianca_rl_mae_id FOREIGN KEY (inscricao_atual_rl_mae_id)
        REFERENCES rl (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

ALTER TABLE crianca
    ADD CONSTRAINT fk_crianca_rl_outro_id FOREIGN KEY (inscricao_atual_rl_outro_id)
        REFERENCES rl (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  inscricao
--  ------------------------------------------------------------------------

-- DROP INDEX inscricao_crianca_id_idx ON inscricao;
-- DROP INDEX inscricao_atendimento_id_idx ON inscricao;
CREATE INDEX inscricao_crianca_id_idx ON inscricao (crianca_id ASC);
CREATE INDEX inscricao_atendimento_id_idx ON inscricao (atendimento_id ASC);

ALTER TABLE inscricao
    -- DROP FOREIGN KEY fk_inscricao_crianca_id,
    ADD CONSTRAINT fk_inscricao_crianca_id FOREIGN KEY (crianca_id)
        REFERENCES crianca (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

ALTER TABLE inscricao
    -- DROP FOREIGN KEY fk_inscricao_atendimento_id,
    ADD CONSTRAINT fk_inscricao_atendimento_id FOREIGN KEY (atendimento_id)
        REFERENCES atendimento (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

-- DROP INDEX inscricao_rl_mae_id_idx ON inscricao;
-- DROP INDEX inscricao_rl_pai_id_idx ON inscricao;
-- DROP INDEX inscricao_rl_outro_id_idx ON inscricao;
CREATE INDEX inscricao_rl_mae_id_idx ON inscricao (rl_mae_id ASC);
CREATE INDEX inscricao_rl_pai_id_idx ON inscricao (rl_pai_id ASC);
CREATE INDEX inscricao_rl_outro_id_idx ON inscricao (rl_outro_id ASC);
CREATE INDEX inscricao_morada_id_idx ON inscricao (morada_id ASC);

ALTER TABLE inscricao
    -- DROP FOREIGN KEY fk_inscricao_rl_pai_id,
    ADD CONSTRAINT fk_inscricao_rl_pai_id FOREIGN KEY (rl_pai_id)
        REFERENCES rl (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

ALTER TABLE inscricao
    -- DROP FOREIGN KEY fk_inscricao_rl_mae_id,
    ADD CONSTRAINT fk_inscricao_rl_mae_id FOREIGN KEY (rl_mae_id)
        REFERENCES rl (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

ALTER TABLE inscricao
    -- DROP FOREIGN KEY fk_inscricao_rl_outro_id,
    ADD CONSTRAINT fk_inscricao_rl_outro_id FOREIGN KEY (rl_outro_id)
        REFERENCES rl (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

ALTER TABLE inscricao
    ADD CONSTRAINT fk_inscricao_morada_id FOREIGN KEY (morada_id)
        REFERENCES morada (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;


CREATE INDEX inscricao_familiar_user_id_idx ON inscricao (familiar_user_id ASC);
CREATE INDEX inscricao_familiar_parentesco_id_idx ON inscricao (familiar_parentesco_id ASC);

ALTER TABLE inscricao
    ADD CONSTRAINT fk_inscricao_familiar_user_id FOREIGN KEY (familiar_user_id)
        REFERENCES users (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

ALTER TABLE inscricao
    ADD CONSTRAINT fk_inscricao_familiar_parentesco_id FOREIGN KEY (familiar_parentesco_id)
        REFERENCES parentesco (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;


--  ------------------------------------------------------------------------
--  pessoa
--  ------------------------------------------------------------------------

CREATE INDEX pessoa_inscricao_id_idx ON pessoa (inscricao_id ASC);
CREATE INDEX pessoa_parentesco_id_idx ON pessoa (parentesco_id ASC);

ALTER TABLE pessoa
    ADD CONSTRAINT fk_pessoa_inscricao_id FOREIGN KEY (inscricao_id)
        REFERENCES inscricao (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

ALTER TABLE pessoa
    ADD CONSTRAINT fk_pessoa_parentesco_id FOREIGN KEY (parentesco_id)
        REFERENCES parentesco (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  rl
--  ------------------------------------------------------------------------

CREATE INDEX rl_email_idx ON rl (email ASC);
CREATE INDEX rl_nif_idx ON rl (nif ASC);
CREATE INDEX rl_user_id_idx ON rl (user_id ASC);
CREATE INDEX rl_morada_id_idx ON rl (morada_id ASC);

ALTER TABLE rl
    ADD CONSTRAINT fk_rl_user_id FOREIGN KEY (user_id)
        REFERENCES users (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

ALTER TABLE rl
    ADD CONSTRAINT fk_rl_morada_id FOREIGN KEY (morada_id)
        REFERENCES morada (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  documento
--  ------------------------------------------------------------------------

CREATE INDEX documento_inscricao_id_idx ON documento (inscricao_id ASC);
CREATE INDEX documento_config_doc_id_idx ON documento (config_doc_id ASC);
CREATE INDEX documento_entregue_por_user_id_idx ON documento (entregue_por_user_id ASC);
CREATE INDEX documento_validado_por_user_id_idx ON documento (validado_por_user_id ASC);

ALTER TABLE documento
    ADD CONSTRAINT fk_documento_inscricao_id
        FOREIGN KEY (inscricao_id)
            REFERENCES inscricao (id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE documento
    ADD CONSTRAINT fk_documento_config_doc_id
        FOREIGN KEY (config_doc_id)
            REFERENCES config_docs (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE documento
    ADD CONSTRAINT fk_documento_entregue_por_user_id
        FOREIGN KEY (entregue_por_user_id)
            REFERENCES users (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE documento
    ADD CONSTRAINT fk_documento_validado_por_user_id
        FOREIGN KEY (validado_por_user_id)
            REFERENCES users (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  morph_comunicacao
--  ------------------------------------------------------------------------

CREATE INDEX morph_comunicacao_registado_por_idx ON morph_comunicacao (registado_por_user_id ASC);
CREATE INDEX morph_comunicacao_destinatário_id_idx ON morph_comunicacao (destinatario_user_id ASC);

ALTER TABLE morph_comunicacao
    ADD CONSTRAINT fk_morph_comunicacao_registado_por_user_id
        FOREIGN KEY (registado_por_user_id)
            REFERENCES users (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE morph_comunicacao
    ADD CONSTRAINT fk_morph_comunicacao_destinatario_user_id
        FOREIGN KEY (destinatario_user_id)
            REFERENCES users (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;


--  ------------------------------------------------------------------------
--  adições derivadas de cuidados pessoais (27-11-2023)
--  faltas
--  registos diários (rd)
--  desinfeções (material + desinfeção)
--  toma de medicamentos (medicamento + razao_toma + toma_medicamento)
--  ------------------------------------------------------------------------

CREATE TABLE `falta` (
                         `id` bigint unsigned NOT NULL AUTO_INCREMENT,
                         `inscricao_id` bigint unsigned NOT NULL,
                         `data` date DEFAULT NULL,
                         `ano_letivo` INT UNSIGNED NOT NULL DEFAULT 2023,
                         sala         tinyint unsigned    default 0,
                         `tipo_falta` tinyint unsigned NOT NULL DEFAULT '0',
                         `justificacao` TEXT  DEFAULT NULL,
                         `marcada_por_user_id` bigint unsigned NOT NULL,
                         `fich_justificacao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
                         `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
                         `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                         PRIMARY KEY (`id`),
                         KEY `falta_inscricao_id_idx` (`inscricao_id`),
                         KEY `falta_marcada_por_user_idx` (`marcada_por_user_id`),
                         CONSTRAINT `fk_falta_inscricao_id` FOREIGN KEY (`inscricao_id`) REFERENCES `inscricao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
                         CONSTRAINT `fk_falta_marcada_por_user_id` FOREIGN KEY (`marcada_por_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


ALTER TABLE `config`
    ADD COLUMN `ano_letivo_atual` INT UNSIGNED NOT NULL DEFAULT 2023 AFTER `updated_at`,
    ADD COLUMN `horizonte_faltas` TINYINT UNSIGNED NOT NULL DEFAULT 3 AFTER `ano_letivo_atual`,
    ADD COLUMN `horizonte_rd` TINYINT UNSIGNED NOT NULL DEFAULT 3 AFTER `horizonte_faltas`,
    ADD COLUMN `horizonte_desinfecao` TINYINT UNSIGNED NOT NULL DEFAULT 3 AFTER `horizonte_rd`,
    ADD COLUMN `horizonte_medicamento` TINYINT UNSIGNED NOT NULL DEFAULT 3 AFTER `horizonte_desinfecao`;


ALTER TABLE `inscricao`
    ADD COLUMN `is_necessario_apoio_comer` TINYINT UNSIGNED NOT NULL DEFAULT 0 AFTER `apoio_especial`;

CREATE TABLE `rd` (
                         `id` bigint unsigned NOT NULL AUTO_INCREMENT,
                         `inscricao_id` bigint unsigned NOT NULL,
                         `data` date DEFAULT NULL,
                         `ano_letivo` INT UNSIGNED NOT NULL DEFAULT 2023,
                         sala         tinyint unsigned    default 0,
                         -- 0, 1, 2
                         `tipo_descanso` tinyint unsigned NOT NULL DEFAULT '0',
                         `tipo_almoco` tinyint unsigned NOT NULL DEFAULT '0',
                         `tipo_lanche` tinyint unsigned NOT NULL DEFAULT '0',
                         `tipo_apoio_comer` tinyint unsigned NOT NULL DEFAULT '0',
                         `reg_por_user_id` bigint unsigned NOT NULL,
                         `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
                         `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                         PRIMARY KEY (`id`),
                         KEY `rd_inscricao_id_idx` (`inscricao_id`),
                         KEY `rd_reg_por_user_idx` (`reg_por_user_id`),
                         CONSTRAINT `fk_rd_inscricao_id` FOREIGN KEY (`inscricao_id`) REFERENCES `inscricao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
                         CONSTRAINT `fk_rd_marcada_por_user_id` FOREIGN KEY (`reg_por_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `material` (
                         `id` bigint unsigned NOT NULL AUTO_INCREMENT,
                         `nome` varchar(255) NOT NULL DEFAULT '',
                         `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
                         `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                         PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `desinfecao` (
                      `id` bigint unsigned NOT NULL AUTO_INCREMENT,
                      `material_id` bigint unsigned NOT NULL,
                      `data` date DEFAULT NULL,
                      `ano_letivo` INT UNSIGNED NOT NULL DEFAULT 2023,
                      sala         tinyint unsigned    default 0,
                      qtd         tinyint unsigned    default 0,
                      obs        text   default null,
                      `reg_por_user_id` bigint unsigned NOT NULL,
                      `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
                      `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                      PRIMARY KEY (`id`),
                      KEY `desinfecao_material_id_idx` (`material_id`),
                      KEY `desinfecao_reg_por_user_idx` (`reg_por_user_id`),
                      CONSTRAINT `fk_desinfecao_material_id` FOREIGN KEY (`material_id`) REFERENCES `material` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
                      CONSTRAINT `fk_desinfecao_reg_por_user_id` FOREIGN KEY (`reg_por_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


--  toma de medicamentos (medicamento + razao_toma + toma_medicamento)

CREATE TABLE `medicamento` (
                            `id` bigint unsigned NOT NULL AUTO_INCREMENT,
                            `nome` varchar(255) NOT NULL DEFAULT '',
                            `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
                            `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                            PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `razao_toma` (
                            `id` tinyint unsigned NOT NULL AUTO_INCREMENT,
                            `razao` varchar(255) NOT NULL DEFAULT '',
                            `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
                            `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                            PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `toma_medicamento` (
                              `id` bigint unsigned NOT NULL AUTO_INCREMENT,
                              `inscricao_id` bigint unsigned NOT NULL,
                              `medicamento_id` bigint unsigned NOT NULL,
                              `razao_toma_id` tinyint unsigned NOT NULL,
                               descricao_dosagem        varchar(255)   default '',
                              `dh_toma` datetime DEFAULT NULL,
                              `ano_letivo` INT UNSIGNED NOT NULL DEFAULT 2023,
                               sala         tinyint unsigned    default 0,
                              `reg_por_user_id` bigint unsigned NOT NULL,
                              `dh_confirmacao_educadora` datetime DEFAULT NULL,
                              `educadora_user_id` bigint unsigned NOT NULL,
                              `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
                              `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                              PRIMARY KEY (`id`),
                              KEY `toma_medicamento_inscricao_id_idx` (`inscricao_id`),
                              KEY `toma_medicamento_medicamento_id_idx` (`medicamento_id`),
                              KEY `toma_medicamento_razao_toma_id_idx` (`razao_toma_id`),
                              CONSTRAINT `fk_toma_medicamento_inscricao_id` FOREIGN KEY (`inscricao_id`) REFERENCES `inscricao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
                              CONSTRAINT `fk_toma_medicamento_medicamento_id` FOREIGN KEY (`medicamento_id`) REFERENCES `medicamento` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
                              CONSTRAINT `fk_toma_medicamento_razao_toma_id` FOREIGN KEY (`razao_toma_id`) REFERENCES `razao_toma` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
                              CONSTRAINT `fk_toma_medicamento_reg_por_user_id` FOREIGN KEY (`reg_por_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
                              CONSTRAINT `fk_toma_medicamento_educadora_user_id` FOREIGN KEY (`educadora_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



--  ------------------------------------------------------------------------
--  adições  (29-11-2023)
--  ocorrências
--  ------------------------------------------------------------------------

ALTER TABLE `config`
    ADD COLUMN `horizonte_ocorrencia` TINYINT UNSIGNED NOT NULL DEFAULT 3 AFTER `horizonte_desinfecao`;

CREATE TABLE `ocorrencia` (
                              `id` bigint unsigned NOT NULL AUTO_INCREMENT,
                              `inscricao_id` bigint unsigned NOT NULL,
                              `ano_letivo` INT UNSIGNED NOT NULL DEFAULT 2023,
                              sala         tinyint unsigned    default 0,
                                -- estados
                                -- 0 - Eliminada
                                -- 1 - Em edição
                                -- 2 - Registada
                                -- 3 - Assinada / Concluido o registo
                                -- 4 - Em Avaliação Pendente
                              estado       tinyint   default '1',
                              `dh_eliminada` datetime DEFAULT NULL,
    -- -----------------------------------
                              descricao_ferimentos 							TEXT,
                              notificacao_policial 							TINYINT,
                              notificacao_ministerio_publico 					TINYINT,
                              exame_medico  			 						TINYINT,
                              comunicacao_familia 			 				TINYINT,
                              comunicacao_interna 							TEXT,
                              categoria_incidente 							VARCHAR(100),
    -- -----
                              data_hora_acidente								DATETIME DEFAULT CURRENT_TIMESTAMP,
    -- -----
                              local_acidente 									VARCHAR(200) DEFAULT 'JDI',
                              agressao_fisica_si_proprio 						TINYINT,
                              agressao_fisica_familia 						TINYINT,
                              agressao_fisica_outro 							TINYINT,
                              agressao_fisica_especifique 					TEXT,
                              dano_na_crianca_acidente 						TINYINT,
                              dano_na_crianca_si_proprio 						TINYINT,
                              dano_na_crianca_familia 						TINYINT,
                              dano_na_crianca_outro 							TINYINT,
                              dano_na_crianca_especifique 					TEXT,
                              ingestao_substancias_suspeita_observada 		TINYINT,
                              ingestao_substancias_admitida 					TINYINT,
                              ingestao_substancias_med_documentada 			TINYINT,
                              ingestao_substancias_outros 					TINYINT,
                              ingestao_substancias_especifique 				TEXT,
                              comportamentos_negativos_ameaca 				TINYINT,
                              comportamentos_negativos_contato_policial   	TINYINT,
                              comportamentos_negativos_med_documentada 		TINYINT,
                              comportamentos_negativos_outros 				TINYINT,
                              comportamentos_negativos_especifique 			TEXT,
                              abuso_sexual_comportamento_improprio_utente 	TINYINT,
                              abuso_sexual_comportamento_improprio_colaborador TINYINT,
                              abuso_sexual_comportamento_improprio_familia 	TINYINT,
                              abuso_sexual_comportamento_improprio_quem 		TEXT,
                              abuso_sexual_comportamento_improprio_outro 		TINYINT,
                              abuso_sexual_comportamento_improprio_especifique TEXT,
                              alegacao_abusos_colaborador 					TINYINT,
                              alegacao_abusos_familia 						TINYINT,
                              alegacao_abusos_quem 							TEXT,
                              alegacao_abusos_outro 							TINYINT,
                              alegacao_abusos_especifique 					TEXT,
                              tipo_de_alegacao_fisico	 						TINYINT,
                              tipo_de_alegacao_sexual 						TINYINT,
                              tipo_de_alegacao_negligencia 					TINYINT,
                              tipo_de_alegacao_outro 							TINYINT,
                              tipo_de_alegacao_especifique 					TEXT,
                              ficha_ocorrencia_nao_investigado 				TINYINT,
                              ficha_ocorrencia_decisao_pendente 				TINYINT,
                              ficha_ocorrencia_investigado 					TINYINT,
                              acoes_negativas_verbal 							TINYINT,
                              acoes_negativas_fisica 							TINYINT,
                              acoes_negativas_outro 							TINYINT,
                              acoes_negativas_especifique 					TEXT,
                              familia_magoada_contencao 						TINYINT,
                              familia_magoada_infligido 						TINYINT,
                              familia_magoada_outro 							TINYINT,
                              familia_magoada_especifique 					TEXT,
                              fonte_observacao_colaboradores					TINYINT,
                              fonte_observacao_familia					 	TINYINT,
                              fonte_observacao_outro 							TINYINT,
                              fonte_observacao_especifique 					TEXT,
                              ocorrencia_privada 								TINYINT,
                              ocorrencia_publica 								TINYINT,
    -- -----------------------------------

                              `reg_por_colaborador_id` bigint unsigned NOT NULL,
                              `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
                              `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                              PRIMARY KEY (`id`),
                              KEY `ocorrencia_inscricao_id_idx` (`inscricao_id`),
                              CONSTRAINT `fk_ocorrencia_inscricao_id` FOREIGN KEY (`inscricao_id`) REFERENCES `inscricao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
                              KEY `ocorrencia_reg_por_colaborador_id_idx` (`reg_por_colaborador_id`),
                              CONSTRAINT `fk_toma_medicamento_reg_por_colaborador_id` FOREIGN KEY (`reg_por_colaborador_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS envolvidos;
CREATE TABLE envolvidos (
                            id BIGINT(19) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
                            ocorrencia_id BIGINT(19) UNSIGNED NOT NULL,
                            envolvido_1 VARCHAR(100) NOT NULL,
                            relacao_com_crianca_1 VARCHAR(100) NOT NULL,
                            envolvido_2 VARCHAR(100) NOT NULL,
                            relacao_com_crianca_2 VARCHAR(100) NOT NULL,
                            envolvido_3 VARCHAR(100) NOT NULL,
                            relacao_com_crianca_3 VARCHAR(100) NOT NULL
)ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS avaliacao_ocorrencia;
CREATE TABLE avaliacao_ocorrencia (
                                      id BIGINT(19) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
                                      antecedentes TEXT,
                                      comportamentos TEXT,
                                      intervencoes_consequencias TEXT,
                                      notificacao_policial TINYINT,
                                      notificacao_ministerio_publico TINYINT,
                                      exame_medico TINYINT,
                                      comunicacao_pessoas_significativas TINYINT,
                                      observacoes TEXT,
                                      ocorrencia_id BIGINT(19) UNSIGNED,
                                      FOREIGN KEY (ocorrencia_id) REFERENCES ocorrencia(id)
)ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


--  ------------------------------------------------------------------------
--  envolvidos
--  ------------------------------------------------------------------------

ALTER TABLE envolvidos
    ADD CONSTRAINT fk_envolvidos_ocorrencia_id
        FOREIGN KEY (ocorrencia_id)
            REFERENCES ocorrencia (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  avaliacao_ocorrencia
--  ------------------------------------------------------------------------

ALTER TABLE avaliacao_ocorrencia
    ADD CONSTRAINT fk_avaliacao_ocorrencia_ocorrencia_id
        FOREIGN KEY (ocorrencia_id)
            REFERENCES ocorrencia (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;


--  ------------------------------------------------------------------------
--  adições derivadas de ocorrencias (18-12-2023)
--  ------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--  ------------------------------------------------------------------------
--  adições derivadas de plano anual de atividades (18-12-2023)
--  ------------------------------------------------------------------------
-- DROP TABLE IF EXISTS relatorio;
CREATE TABLE relatorio (
    id BIGINT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
    avaliacao 	TEXT,
    pdf 		VARCHAR(250),
    -- ----------------------
	created_at DATETIME  DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME   DEFAULT NULL
)ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- DROP TABLE IF EXISTS atividade;
CREATE TABLE atividade (
    id BIGINT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nome VARCHAR(255),
    ano_letivo INT UNSIGNED NOT NULL DEFAULT 2023,
    data_inic DATE,
    data_fim DATE,
    recursos_materiais 		VARCHAR(255),
    recursos_humanos 		VARCHAR(255),
    objetivos 				TEXT,
	-- estados de aprovação
    -- 0 - não aprovado
    -- 1 - por aprovar
    -- 2 - aprovado
    estado_aprovacao 		TINYINT(3) DEFAULT 1,
    -- estados
    -- 0 - realizada
    -- 1 - não realizada
    -- 2 - por realizar
    -- 3 - em curso
    estado 					TINYINT(4) DEFAULT 1,
    comentario_final 		TEXT,
    dh_comentario 			DATETIME,
    relatorio_id BIGINT UNSIGNED NOT NULL
)ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

--  ------------------------------------------------------------------------
--  avaliacao_ocorrencia
--  ------------------------------------------------------------------------

ALTER TABLE atividade
    ADD CONSTRAINT fk_atividade_relatorio_id
        FOREIGN KEY (relatorio_id)
            REFERENCES relatorio (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  adições derivadas de plano anual de atividades (18-12-2023)
--  ------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--  ------------------------------------------------------------------------
--  adições derivadas de processos (19-12-2023)
--  ------------------------------------------------------------------------

-- DROP TABLE IF EXISTS processo;
CREATE TABLE processo
(
    id                      bigint unsigned PRIMARY KEY 			NOT NULL AUTO_INCREMENT,
    crianca_id				bigint unsigned          		   	   NOT NULL,
    -- ------------------
    -- 0 - por elaborar
    -- 1 - em processo
    -- 2 - preenchido
    -- 3 - validado
    estado					TINYINT UNSIGNED			   			 NOT NULL default 0,
	-- ------------------
    -- 0 - sempre disponivel
    -- 1 - disponivel temporariamente
    tipo					TINYINT UNSIGNED			  			 NOT NULL default 0,
    data_de_inicio			DATE						   			 default null,
    data_de_fim				DATE						  			 default null,
    nome					VARCHAR(255) COLLATE utf8mb4_unicode_ci  NOT NULL ,
	-- ------------------
    created_at              DATETIME                                DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME                                 DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- DROP TABLE IF EXISTS form;
CREATE TABLE form
(
    id                      bigint unsigned PRIMARY KEY  			NOT NULL AUTO_INCREMENT,
    processo_id				bigint unsigned                 		NOT NULL UNIQUE,
    -- ------------------
    -- 0 - em processo
	-- 1 - preenchido
    -- 2 - validado
    estado					TINYINT UNSIGNED			   			 NOT NULL default 0,
    form					TEXT COLLATE utf8mb4_unicode_ci			 DEFAULT NULL,
    -- ------------------
    created_at              DATETIME                                DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME                                 DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    -- ------------------
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- DROP TABLE IF EXISTS estado_processo;
CREATE TABLE estado_processo
(
    id                      bigint unsigned PRIMARY KEY		NOT NULL AUTO_INCREMENT,
    processo_id				bigint unsigned                 NOT NULL,
    -- ------------------
    -- 0 - em processo
	-- 1 - preenchido
    -- 2 - validado
    estado					TINYINT UNSIGNED			   			 DEFAULT 0 NOT NULL ,
    modificado_por			varchar(255)							 DEFAULT NULL,
    -- ------------------
    created_at              DATETIME                                DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME                                 DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    -- ------------------
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

--  ------------------------------------------------------------------------
--  processo
--  ------------------------------------------------------------------------

ALTER TABLE processo
    ADD CONSTRAINT fk_processo_crianca FOREIGN KEY (crianca_id)
        REFERENCES crianca (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  form
--  ------------------------------------------------------------------------

ALTER TABLE form
    ADD CONSTRAINT fk_form_processo_id FOREIGN KEY (processo_id)
        REFERENCES processo (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  documento
--  ------------------------------------------------------------------------

ALTER TABLE documento
	ADD COLUMN crianca_id  BIGINT 	UNSIGNED  	NOT NULL,
    ADD COLUMN ano_letivo  INT 		UNSIGNED 	NOT NULL 	DEFAULT 2023,
    ADD COLUMN processo_id BIGINT	UNSIGNED 	NOT NULL,
    DROP COLUMN  inscricao_id,
    DROP CONSTRAINT fk_documento_inscricao_id;

ALTER TABLE documento
	ADD CONSTRAINT fk_documento_crianca_id FOREIGN KEY (crianca_id)
	REFERENCES crianca (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
	ADD CONSTRAINT fk_documento_processo_id FOREIGN KEY (processo_id)
	REFERENCES processo (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  estado_processo
--  ------------------------------------------------------------------------

CREATE INDEX estado_processo_estado_atual on  estado_processo(created_at ASC);

ALTER TABLE estado_processo
	ADD CONSTRAINT fk_estado_processo_processo_id FOREIGN KEY (processo_id)
	REFERENCES processo (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  adições derivadas de processos (18-12-2023)
--  ------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--  ------------------------------------------------------------------------
--  adições derivadas de projeto curricular (19-12-2023)
--  ------------------------------------------------------------------------
-- DROP TABLE IF EXISTS projeto_curricular;
CREATE TABLE projeto_curricular (
    id 			  	  BIGINT UNSIGNED PRIMARY KEY		NOT NULL AUTO_INCREMENT,
    ano_letivo  	  INT 				UNSIGNED 		NOT NULL 	DEFAULT 2023,
    submetido_por 	  VARCHAR(255)  	NOT NULL,
    dh_submetido 	  DATETIME     	NOT NULL 		DEFAULT CURRENT_TIMESTAMP,
    pc_ficheiro 	  VARCHAR(255),
    relatorio_id_ano1 BIGINT UNSIGNED                 	NOT NULL UNIQUE,
    relatorio_id_ano2 BIGINT UNSIGNED                 	NOT NULL UNIQUE,
    relatorio_id_ano3 BIGINT UNSIGNED                 	NOT NULL UNIQUE,
    -- estados
    -- 0 - validado
    -- 1 - Parte 1
    -- 2 - Parte 2
    -- 3 - Parte 3
    -- 4 - arquivado
    estado TINYINT(4)
);

-- DROP TABLE IF EXISTS relatorio_pc;
CREATE TABLE relatorio_pc (
    id							BIGINT UNSIGNED PRIMARY KEY		NOT NULL AUTO_INCREMENT,
    pc_id 						BIGINT 		  UNSIGNED NOT NULL,
    relatorio_numero 			TINYINT 	  NOT NULL,
    ficheiro_relatorio 			VARCHAR(255),
    submetido_por 				VARCHAR(255)  NOT NULL,
    dh_relatorio 				DATETIME 	  NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--  ------------------------------------------------------------------------
--  estado_processo
--  ------------------------------------------------------------------------

ALTER TABLE projeto_curricular
	ADD CONSTRAINT fk_projeto_curricular_relatorio_pc_id_1 FOREIGN KEY (relatorio_id_ano1)
	REFERENCES relatorio_pc (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;
ALTER TABLE projeto_curricular
	ADD CONSTRAINT fk_projeto_curricular_relatorio_pc_id_2 FOREIGN KEY (relatorio_id_ano2)
		REFERENCES relatorio_pc (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE;
ALTER TABLE projeto_curricular
	ADD CONSTRAINT fk_projeto_curricular_relatorio_pc_id_3 FOREIGN KEY (relatorio_id_ano3)
		REFERENCES relatorio_pc (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE;

ALTER TABLE relatorio_pc
	ADD CONSTRAINT fk_relatorio_pc_projeto_curricular_id FOREIGN KEY (pc_id)
	REFERENCES projeto_curricular (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  adições derivadas de projeto curricular (19-12-2023)
--  ------------------------------------------------------------------------
--  ------------------------------------------------------------------------
--  ------------------------------------------------------------------------
--  adições derivadas de tentativas de comunicacao (19-12-2023)
--  ------------------------------------------------------------------------

-- DROP TABLE IF EXISTS tentativas_de_comunicacao;
CREATE TABLE tentativas_de_comunicacao(
    id                      BIGINT UNSIGNED PRIMARY KEY		NOT NULL AUTO_INCREMENT,
    atendimento_id			bigint unsigned                 NOT NULL,
    obs						TEXT												   ,
    -- -----------------------
    created_at              DATETIME                                DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME                                 DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

  --  ------------------------------------------------------------------------
--  tentativas de comunicacao
--  ------------------------------------------------------------------------

ALTER TABLE tentativas_de_comunicacao
    ADD CONSTRAINT fk_tentativas_de_comunicacao_atendimento_id FOREIGN KEY (atendimento_id)
        REFERENCES atendimento (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  adições derivadas de tentativas de comunicacao (19-12-2023)
--  ------------------------------------------------------------------------
--  ------------------------------------------------------------------------
--  ------------------------------------------------------------------------
--  adições derivadas de plano semanal (19-12-2023)
--  ------------------------------------------------------------------------
-- DROP TABLE IF EXISTS Plano_Semanal_de_Sala;
CREATE TABLE Plano_Semanal_de_Sala(
    id 	 BIGINT UNSIGNED PRIMARY KEY		NOT NULL AUTO_INCREMENT,
    sala TINYINT UNSIGNED,
    ano_letivo INT UNSIGNED NOT NULL DEFAULT 2023,
    semana DATE,
    data_criacao DATE,
    -- estados
    -- 0 - por avaliar
    -- 1 - avaliado
    -- 2 - eliminado
    -- 4 - arquivado
    estado TINYINT(4) DEFAULT 0,
    seg TEXT,
    ter TEXT,
    qua TEXT,
    qui TEXT,
    sex TEXT,
    avaliado_por VARCHAR(255) NOT NULL,
    -- -----------------------
    dh_avaliacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	-- -----------------------
	dh_eliminado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    eliminado_por VARCHAR(255) NOT NULL,
    created_at              DATETIME                                DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME                                 DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

--  ------------------------------------------------------------------------
--  adições derivadas de plano semanal (19-12-2023)
--  ------------------------------------------------------------------------
--  ------------------------------------------------------------------------
--  ------------------------------------------------------------------------
--  adições derivadas de perfil de desenvolvimento (19-12-2023)
--  ------------------------------------------------------------------------

-- DROP TABLE IF EXISTS comportamento_observavel;
CREATE TABLE IF NOT EXISTS   comportamento_observavel  (

   id  				 BIGINT UNSIGNED PRIMARY KEY		NOT NULL AUTO_INCREMENT,
   tipo_perfil  	 TINYINT NOT NULL,
   ordem  			 INT NOT NULL,
   tema  			 TINYINT NOT NULL,
   dominio  		 TINYINT NULL,
   descricao		 TEXT NOT NULL,
   subcomportamento   BIGINT UNSIGNED NOT NULL
   ) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- DROP TABLE IF EXISTS Perfil_desenvolvimento;
CREATE TABLE IF NOT EXISTS   Perfil_desenvolvimento   (
    id   			BIGINT UNSIGNED PRIMARY KEY		NOT NULL AUTO_INCREMENT,
    tipoPerfil   	 INT NOT NULL,
    data_submissao   DATE NULL,
    submetente   	 VARCHAR(255) DEFAULT NULL,
    ficheiro   		 VARCHAR(255) DEFAULT NULL
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- DROP TABLE IF EXISTS Comportamento_observavel_PD;
CREATE TABLE IF NOT EXISTS  Comportamento_observavel_PD  (
   id_PD  			BIGINT UNSIGNED 		NOT NULL AUTO_INCREMENT,
   id_Comp  		INT             	 	NOT NULL,
   observacao  		TEXT 							NOT NULL,
   estado  			TINYINT 						NOT NULL,
   data_acomp_1  	DATE 							DEFAULT NULL,
   obs_acomp_1  	MEDIUMTEXT 						DEFAULT NULL,
   data_acomp_2  	DATE 							DEFAULT NULL,
   obs_acmomp_2  	MEDIUMTEXT 						DEFAULT NULL,
   primary key(id_PD,id_Comp)
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- DROP TABLE IF EXISTS Pograma_Acolhimento;
CREATE TABLE IF NOT EXISTS   Pograma_Acolhimento    (
     ID    					BIGINT UNSIGNED PRIMARY KEY		NOT NULL AUTO_INCREMENT,
     dh_criacao    			DATETIME NOT NULL,
     Data_fim_estimada    	DATE NULL,
     descricao    			TEXT NULL,
     Estado    				INT NULL,
     User_validou    		TINYINT NULL,
     dh_validado    		DATETIME NULL,
     pdf_assinado_PA    	VARCHAR(255) NULL,
     EE_JDI    				TINYINT NULL,
     EE_colab    			TINYINT NULL,
     EE_PA    				TINYINT NULL,
     EE_continuar    		TINYINT NULL,
     Sugestoes_melhoria    	TEXT NULL,
     Relatorio    			TEXT NULL,
     Data_relatorio    		DATE NULL
) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- DROP TABLE IF EXISTS Tipo_PA;
CREATE TABLE IF NOT EXISTS   Tipo_PA    (
     ID    	 BIGINT UNSIGNED PRIMARY KEY		NOT NULL AUTO_INCREMENT,
     Tipo    VARCHAR(255) NOT NULL) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- DROP TABLE IF EXISTS Processo_Adaptacao;
CREATE TABLE IF NOT EXISTS    Processo_Adaptacao    (
     ID    				BIGINT UNSIGNED PRIMARY KEY		NOT NULL AUTO_INCREMENT,
     data    			DATE NULL,
     descricao    		TEXT NULL,
     Tipo_PA_ID    		BIGINT UNSIGNED NOT NULL,
     Pograma_Acolhimento_ID    BIGINT UNSIGNED NOT NULL
     ) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- DROP TABLE IF EXISTS Medidas;
CREATE TABLE IF NOT EXISTS     Medidas    (
     ID    BIGINT UNSIGNED PRIMARY KEY		NOT NULL AUTO_INCREMENT,
     Descricao    TEXT NULL,
     Eficaz    TINYINT NULL,
     Processo_Adaptacao_ID    BIGINT UNSIGNED NOT NULL
     ) ENGINE = InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


--  ------------------------------------------------------------------------
--  Medidas
--  ------------------------------------------------------------------------

CREATE INDEX    fk_Medidas_Processo_Adaptacao1_idx on  Medidas   (   Processo_Adaptacao_ID    ASC);
ALTER TABLE Medidas
	ADD CONSTRAINT fk_Medidas_Processo_Adaptacao1
		FOREIGN KEY ( Processo_Adaptacao_ID )
		REFERENCES 	Processo_Adaptacao  ( ID )
		ON DELETE NO ACTION
		ON UPDATE NO ACTION;
--  ------------------------------------------------------------------------
--  Processo_Adaptacao
--  ------------------------------------------------------------------------

  CREATE INDEX    fk_Processo_Adaptacao_Tipo_PA1_idx on  Processo_Adaptacao   (   Tipo_PA_ID    ASC);
  CREATE INDEX    fk_Processo_Adaptacao_Pograma_Acolhimento1_idx on  Processo_Adaptacao   (   Pograma_Acolhimento_ID    ASC);

ALTER TABLE Processo_Adaptacao
	ADD   CONSTRAINT  fk_Processo_Adaptacao_Tipo_PA1
    FOREIGN KEY ( Tipo_PA_ID )
    REFERENCES Tipo_PA  ( ID )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

ALTER TABLE Processo_Adaptacao
	ADD   CONSTRAINT  fk_Processo_Adaptacao_Pograma_Acolhimento1
    FOREIGN KEY ( Pograma_Acolhimento_ID )
    REFERENCES  Pograma_Acolhimento  ( ID )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--  ------------------------------------------------------------------------
--  Comportamento_observavel
--  ------------------------------------------------------------------------

CREATE INDEX  fk_Comportamento_observavel_Comportamento_observavel1_idx on comportamento_observavel (subcomportamento ASC);
ALTER TABLE comportamento_observavel
	ADD CONSTRAINT  fk_Comportamento_observavel_Comportamento_observavel1
		FOREIGN KEY ( subcomportamento) REFERENCES   Comportamento_observavel  ( id )
		ON DELETE NO ACTION
		ON UPDATE NO ACTION;

--  ------------------------------------------------------------------------
--  Tipo_PA
--  ------------------------------------------------------------------------
CREATE INDEX  Tipo_UNIQUE on Tipo_PA (Tipo ASC);

--  ------------------------------------------------------------------------
--  Comportamento_observavel_PD
--  ------------------------------------------------------------------------

CREATE INDEX  fk_Perfil_desenvolvimento_has_Comportamento_observavel_Comp_idx  on Comportamento_observavel_PD ( id_Comp  ASC);
CREATE INDEX  fk_Perfil_desenvolvimento_has_Comportamento_observavel_Perf_idx on Comportamento_observavel_PD  ( id_PD  ASC)  ;

ALTER TABLE Comportamento_observavel_PD
	ADD  CONSTRAINT  fk_Perfil_desenvolvimento_has_Comportamento_observavel_Perfil
    FOREIGN KEY ( id_PD ) REFERENCES    Perfil_desenvolvimento  ( id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--  ------------------------------------------------------------------------
--  Pograma_Acolhimento
--  ------------------------------------------------------------------------

ALTER TABLE Pograma_Acolhimento
	ADD COLUMN inscricao_id 	BIGINT UNSIGNED NOT NULL;

ALTER TABLE Pograma_Acolhimento
	ADD CONSTRAINT fk_programa_de_acolhimento_inscricao_id FOREIGN KEY (inscricao_id)
	REFERENCES inscricao (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  Perfil_desenvolvimento
--  ------------------------------------------------------------------------

ALTER TABLE Perfil_desenvolvimento
	ADD COLUMN inscricao_id 	BIGINT UNSIGNED NOT NULL UNIQUE;

ALTER TABLE Perfil_desenvolvimento
	ADD CONSTRAINT fk_perfil_desenvolvimento_inscricao_id FOREIGN KEY (inscricao_id)
	REFERENCES inscricao (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

--  ------------------------------------------------------------------------
--  adições derivadas de perfil de desenvolvimento (19-12-2023)
--  ------------------------------------------------------------------------
--  ------------------------------------------------------------------------
--  ------------------------------------------------------------------------
--  adições derivadas á lista de pertences (21-12-2023)
--  ------------------------------------------------------------------------

-- DROP TABLE IF EXISTS lista_de_pertences;
CREATE TABLE lista_de_pertences(

	pertences_id BIGINT UNSIGNED PRIMARY KEY	NOT NULL AUTO_INCREMENT,
    crianca_id BIGINT UNSIGNED	NOT NULL,
    -- Foreign key da tabela crianÃ§a
    ano_letivo DATETIME,
    identificacao VARCHAR(255),
    quantidade INT,
    obs VARCHAR(255),
	data_hora_validacao DATETIME,
    validado_por VARCHAR(200),
    PDF_assinado VARCHAR(200)
);

--  ------------------------------------------------------------------------
--  lista de pertences
--  ------------------------------------------------------------------------

ALTER TABLE lista_de_pertences
	ADD  CONSTRAINT  fk_lista_de_pertences_crianca_id
    FOREIGN KEY ( crianca_id ) REFERENCES    crianca  ( id )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


SET FOREIGN_KEY_CHECKS = 1;

