-- DROP SCHEMA smm_jardinf;
-- CREATE DATABASE smm_jardinf DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE smm_jardinf;
SET FOREIGN_KEY_CHECKS = 0;

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
    created_at                     TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
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
    created_at             TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
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
    created_at                  TIMESTAMP                                        DEFAULT CURRENT_TIMESTAMP,
    updated_at                  DATETIME                                         DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at                  timestamp                               NULL     DEFAULT NULL,
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
    created_at              TIMESTAMP                                DEFAULT CURRENT_TIMESTAMP,
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
    created_at                    TIMESTAMP                                        DEFAULT CURRENT_TIMESTAMP,
    updated_at                    DATETIME                                         DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at                    timestamp                               NULL     DEFAULT NULL,
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
    email_verified_at  TIMESTAMP                                        DEFAULT NULL,
    tel                varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    tlm                varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    -- ------------------
    morada_id          bigint unsigned                                  default NULL,
    sit_prof           varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    profissao          varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    localidade_emprego varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
    tlf_emprego        varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,

    -- ------------------
    created_at         TIMESTAMP                                        DEFAULT CURRENT_TIMESTAMP,
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
    created_at           TIMESTAMP                                        DEFAULT CURRENT_TIMESTAMP,
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
    entregue_em            TIMESTAMP        DEFAULT null,
    entregue_por_user_id   bigint unsigned                         NOT NULL,
    -- --------------------
    validado_em            TIMESTAMP        DEFAULT null,
    validado_por_user_id   bigint unsigned                         NOT NULL,
    -- --------------------
    created_at             TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
    lido_em               TIMESTAMP                                        default NULL,
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
    created_at            TIMESTAMP                                        DEFAULT CURRENT_TIMESTAMP,
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

SET FOREIGN_KEY_CHECKS = 1;



--  ------------------------------------------------------------------------
--  adições derivadas de cuidados pessoais (27-11-2023)
--  ------------------------------------------------------------------------

CREATE TABLE `falta` (
                         `id` bigint unsigned NOT NULL AUTO_INCREMENT,
                         `inscricao_id` bigint unsigned NOT NULL,
                         `data` date DEFAULT NULL,
                         `ano_letivo` INT UNSIGNED NOT NULL DEFAULT 2023,
                         `tipo_falta` tinyint unsigned NOT NULL DEFAULT '0',
                         `justificacao` TEXT  DEFAULT NULL,
                         `marcada_por_user_id` bigint unsigned NOT NULL,
                         `fich_justificacao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
                         `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
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
    ADD COLUMN `horizonte_desinfecao` TINYINT UNSIGNED NOT NULL DEFAULT 3 AFTER `horizonte_rd`;


ALTER TABLE `inscricao`
    ADD COLUMN `is_necessario_apoio_comer` TINYINT UNSIGNED NOT NULL DEFAULT 0 AFTER `apoio_especial`;

ALTER TABLE `users`
    ADD COLUMN `short_name` varchar(255)  NOT NULL DEFAULT '' AFTER `name`;


CREATE TABLE `rd` (
                         `id` bigint unsigned NOT NULL AUTO_INCREMENT,
                         `inscricao_id` bigint unsigned NOT NULL,
                         `data` date DEFAULT NULL,
                         `ano_letivo` INT UNSIGNED NOT NULL DEFAULT 2023,
                         -- 0, 1, 2
                         `tipo_descanso` tinyint unsigned NOT NULL DEFAULT '0',
                         `tipo_almoco` tinyint unsigned NOT NULL DEFAULT '0',
                         `tipo_lanche` tinyint unsigned NOT NULL DEFAULT '0',
                         `tipo_apoio_comer` tinyint unsigned NOT NULL DEFAULT '0',
                         `reg_por_user_id` bigint unsigned NOT NULL,
                         `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
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
                         `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
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
                      `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                      `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                      PRIMARY KEY (`id`),
                      KEY `desinfecao_material_id_idx` (`material_id`),
                      KEY `desinfecao_reg_por_user_idx` (`reg_por_user_id`),
                      CONSTRAINT `fk_desinfecao_material_id` FOREIGN KEY (`material_id`) REFERENCES `material` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
                      CONSTRAINT `fk_desinfecao_reg_por_user_id` FOREIGN KEY (`reg_por_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
