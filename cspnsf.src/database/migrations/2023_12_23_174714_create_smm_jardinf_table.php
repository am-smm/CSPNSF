<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Spatie\Permission\PermissionRegistrar;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {

        Schema::create('password_reset_tokens', function (Blueprint $table) {
            $table->string('email')->primary();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
        });

        Schema::create('failed_jobs', function (Blueprint $table) {
            $table->id();
            $table->string('uuid')->unique();
            $table->text('connection');
            $table->text('queue');
            $table->longText('payload');
            $table->longText('exception');
            $table->timestamp('failed_at')->useCurrent();
        });

        // --------------------------------
        // --------------------------------

        $tableNames = config('permission.table_names');
        $columnNames = config('permission.column_names');
        $teams = config('permission.teams');

        if (empty($tableNames)) {
            throw new \Exception('Error: config/permission.php not loaded. Run [php artisan config:clear] and try again.');
        }
        if ($teams && empty($columnNames['team_foreign_key'] ?? null)) {
            throw new \Exception('Error: team_foreign_key on config/permission.php not loaded. Run [php artisan config:clear] and try again.');
        }

        Schema::create($tableNames['permissions'], function (Blueprint $table) {
            $table->bigIncrements('id'); // permission id
            $table->string('name');       // For MySQL 8.0 use string('name', 125);
            $table->string('guard_name'); // For MySQL 8.0 use string('guard_name', 125);
            $table->timestamps();

            $table->unique(['name', 'guard_name']);
        });

        Schema::create($tableNames['roles'], function (Blueprint $table) use ($teams, $columnNames) {
            $table->bigIncrements('id'); // role id
            if ($teams || config('permission.testing')) { // permission.testing is a fix for sqlite testing
                $table->unsignedBigInteger($columnNames['team_foreign_key'])->nullable();
                $table->index($columnNames['team_foreign_key'], 'roles_team_foreign_key_index');
            }
            $table->string('name');       // For MySQL 8.0 use string('name', 125);
            $table->string('guard_name'); // For MySQL 8.0 use string('guard_name', 125);
            $table->timestamps();
            if ($teams || config('permission.testing')) {
                $table->unique([$columnNames['team_foreign_key'], 'name', 'guard_name']);
            } else {
                $table->unique(['name', 'guard_name']);
            }
        });

        Schema::create($tableNames['model_has_permissions'], function (Blueprint $table) use ($tableNames, $columnNames, $teams) {
            $table->unsignedBigInteger(PermissionRegistrar::$pivotPermission);

            $table->string('model_type');
            $table->unsignedBigInteger($columnNames['model_morph_key']);
            $table->index([$columnNames['model_morph_key'], 'model_type'], 'model_has_permissions_model_id_model_type_index');

            $table->foreign(PermissionRegistrar::$pivotPermission)
                  ->references('id') // permission id
                  ->on($tableNames['permissions'])
                  ->onDelete('cascade');
            if ($teams) {
                $table->unsignedBigInteger($columnNames['team_foreign_key']);
                $table->index($columnNames['team_foreign_key'], 'model_has_permissions_team_foreign_key_index');

                $table->primary([$columnNames['team_foreign_key'], PermissionRegistrar::$pivotPermission, $columnNames['model_morph_key'], 'model_type'],
                                'model_has_permissions_permission_model_type_primary');
            } else {
                $table->primary([PermissionRegistrar::$pivotPermission, $columnNames['model_morph_key'], 'model_type'],
                                'model_has_permissions_permission_model_type_primary');
            }

        });

        Schema::create($tableNames['model_has_roles'], function (Blueprint $table) use ($tableNames, $columnNames, $teams) {
            $table->unsignedBigInteger(PermissionRegistrar::$pivotRole);

            $table->string('model_type');
            $table->unsignedBigInteger($columnNames['model_morph_key']);
            $table->index([$columnNames['model_morph_key'], 'model_type'], 'model_has_roles_model_id_model_type_index');

            $table->foreign(PermissionRegistrar::$pivotRole)
                  ->references('id') // role id
                  ->on($tableNames['roles'])
                  ->onDelete('cascade');
            if ($teams) {
                $table->unsignedBigInteger($columnNames['team_foreign_key']);
                $table->index($columnNames['team_foreign_key'], 'model_has_roles_team_foreign_key_index');

                $table->primary([$columnNames['team_foreign_key'], PermissionRegistrar::$pivotRole, $columnNames['model_morph_key'], 'model_type'],
                                'model_has_roles_role_model_type_primary');
            } else {
                $table->primary([PermissionRegistrar::$pivotRole, $columnNames['model_morph_key'], 'model_type'],
                                'model_has_roles_role_model_type_primary');
            }
        });

        Schema::create($tableNames['role_has_permissions'], function (Blueprint $table) use ($tableNames) {
            $table->unsignedBigInteger(PermissionRegistrar::$pivotPermission);
            $table->unsignedBigInteger(PermissionRegistrar::$pivotRole);

            $table->foreign(PermissionRegistrar::$pivotPermission)
                  ->references('id') // permission id
                  ->on($tableNames['permissions'])
                  ->onDelete('cascade');

            $table->foreign(PermissionRegistrar::$pivotRole)
                  ->references('id') // role id
                  ->on($tableNames['roles'])
                  ->onDelete('cascade');

            $table->primary([PermissionRegistrar::$pivotPermission, PermissionRegistrar::$pivotRole], 'role_has_permissions_permission_id_role_id_primary');
        });

        app('cache')
            ->store(config('permission.cache.store') != 'default' ? config('permission.cache.store') : null)
            ->forget(config('permission.cache.key'));

        // --------------------------------
        // --------------------------------

        Schema::create('comportamento_observavel_pd', function (Blueprint $table) {
            $table->bigIncrements('id')->index('fk_perfil_desenvolvimento_has_Comportamento_observavel_Perf_idx');
            $table->integer('id_Comp')->index('fk_perfil_desenvolvimento_has_Comportamento_observavel_Comp_idx');
            $table->text('observacao');
            $table->tinyInteger('estado');
            $table->date('data_acomp_1')->nullable();
            $table->mediumText('obs_acomp_1')->nullable();
            $table->date('data_acomp_2')->nullable();
            $table->mediumText('obs_acmomp_2')->nullable();
        });

        Schema::create('medidas', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->text('descricao')->nullable();
            $table->tinyInteger('eficaz')->nullable();
            $table->unsignedBigInteger('processo_adaptacao_id')->index('fk_medidas_processo_adaptacao_idx');
        });

        Schema::create('perfil_desenvolvimento', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->integer('tipo_perfil');
            $table->date('data_submissao')->nullable();
            $table->string('submetente')->nullable();
            $table->string('ficheiro')->nullable();
            $table->unsignedBigInteger('inscricao_id')->unique('inscricao_id');
        });

        Schema::create('plano_semanal_sala', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedTinyInteger('sala')->nullable();
            $table->unsignedInteger('ano_letivo')->default(2023);
            $table->date('semana')->nullable();
            $table->date('data_criacao')->nullable();
            $table->tinyInteger('estado')->nullable()->default(0);
            $table->text('seg')->nullable();
            $table->text('ter')->nullable();
            $table->text('qua')->nullable();
            $table->text('qui')->nullable();
            $table->text('sex')->nullable();
            $table->string('avaliado_por');
            $table->dateTime('dh_avaliacao')->useCurrent();
            $table->dateTime('dh_eliminado')->useCurrent();
            $table->string('eliminado_por');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('programa_acolhimento', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->dateTime('dh_criacao');
            $table->date('data_fim_estimada')->nullable();
            $table->text('descricao')->nullable();
            $table->integer('estado')->nullable();
            $table->tinyInteger('user_validou')->nullable();
            $table->dateTime('dh_validado')->nullable();
            $table->string('pdf_assinado_pa')->nullable();
            $table->tinyInteger('ee_jdi')->nullable();
            $table->tinyInteger('ee_colab')->nullable();
            $table->tinyInteger('ee_pa')->nullable();
            $table->tinyInteger('ee_continuar')->nullable();
            $table->text('sugestoes_melhoria')->nullable();
            $table->text('relatorio')->nullable();
            $table->date('data_relatorio')->nullable();
            $table->unsignedBigInteger('inscricao_id')->index('fk_programa_acolhimento_inscricao_id');
        });

        Schema::create('processo_adaptacao', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->date('data')->nullable();
            $table->text('descricao')->nullable();
            $table->unsignedBigInteger('tipo_pa_id')->index('fk_processo_adaptacao_Tipo_PA_idx');
            $table->unsignedBigInteger('programa_acolhimento_id')->index('fk_processo_adaptacao_programa_acolhimento_idx');
        });

        Schema::create('tipo_pa', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('tipo')->index('Tipo_UNIQUE');
        });

        Schema::create('atendimento', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedTinyInteger('tipo_realizacao')->default(0);
            $table->text('motivo_inscricao');
            $table->date('dt_pretendida')->nullable();
            $table->unsignedTinyInteger('tipo_atendimento')->default(0);
            $table->date('dh_sugerida_atentimento')->nullable();
            $table->date('dh_agendada_atentimento')->nullable();
            $table->text('obs_visita');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('atividade', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('nome')->nullable();
            $table->unsignedInteger('ano_letivo')->default(2023);
            $table->date('data_inic')->nullable();
            $table->date('data_fim')->nullable();
            $table->string('recursos_materiais')->nullable();
            $table->string('recursos_humanos')->nullable();
            $table->text('objetivos')->nullable();
            $table->tinyInteger('estado_aprovacao')->nullable()->default(1);
            $table->tinyInteger('estado')->nullable()->default(1);
            $table->text('comentario_final')->nullable();
            $table->dateTime('dh_comentario')->nullable();
            $table->unsignedBigInteger('relatorio_id')->index('fk_atividade_relatorio_id');
        });

        Schema::create('avaliacao_ocorrencia', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->text('antecedentes')->nullable();
            $table->text('comportamentos')->nullable();
            $table->text('intervencoes_consequencias')->nullable();
            $table->tinyInteger('notificacao_policial')->nullable();
            $table->tinyInteger('notificacao_ministerio_publico')->nullable();
            $table->tinyInteger('exame_medico')->nullable();
            $table->tinyInteger('comunicacao_pessoas_significativas')->nullable();
            $table->text('observacoes')->nullable();
            $table->unsignedBigInteger('ocorrencia_id')->nullable()->index('fk_avaliacao_ocorrencia_ocorrencia_id');
        });

        Schema::create('comportamento_observavel', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->tinyInteger('tipo_perfil');
            $table->integer('ordem');
            $table->tinyInteger('tema');
            $table->tinyInteger('dominio')->nullable();
            $table->text('descricao');
            $table->unsignedBigInteger('subcomportamento')->index('fk_Comportamento_observavel_Comportamento_observavel1_idx');
        });

        Schema::create('config', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('nif_jdi');
            $table->unsignedTinyInteger('vagas_34')->nullable()->default(15);
            $table->unsignedTinyInteger('vagas_45')->nullable()->default(15);
            $table->time('h_inic_manha')->nullable()->default('07:30:00');
            $table->time('h_fim_manha')->nullable();
            $table->time('h_inic_tarde')->nullable();
            $table->time('h_fim_tarde')->nullable()->default('19:00:00');
            $table->unsignedTinyInteger('max_dias_horizonte_agendamento')->nullable()->default(10);
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
            $table->unsignedInteger('ano_letivo_atual')->default(2023);
            $table->unsignedTinyInteger('horizonte_faltas')->default(3);
            $table->unsignedTinyInteger('horizonte_rd')->default(3);
            $table->unsignedTinyInteger('horizonte_desinfecao')->default(3);
            $table->unsignedTinyInteger('horizonte_ocorrencia')->default(3);
            $table->unsignedTinyInteger('horizonte_medicamento')->default(3);
        });

        Schema::create('config_docs', function (Blueprint $table) {
            $table->increments('id');
            $table->string('nome');
            $table->unsignedTinyInteger('is_obrigatorio')->nullable()->default(0);
            $table->unsignedTinyInteger('is_calculo_mensalidade')->nullable()->default(0);
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('crianca', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('nproc', 20)->unique('crianca_nproc_idx');
            $table->unsignedBigInteger('inscricao_atual_id')->nullable()->index('crianca_inscricao_atual_id_idx');
            $table->string('nome');
            $table->string('tratado_pelo_nome');
            $table->dateTime('dn')->nullable();
            $table->date('dt_inic_frequencia')->nullable();
            $table->string('nif')->index('crianca_nif_idx');
            $table->string('niss')->index('crianca_niss_idx');
            $table->unsignedTinyInteger('tipo_morada')->nullable()->default(0);
            $table->unsignedBigInteger('inscricao_atual_morada_id')->nullable()->index('crianca_inscricao_atual_morada_id_idx');
            $table->unsignedBigInteger('inscricao_atual_rl_pai_id')->nullable()->index('crianca_rl_pai_id_idx');
            $table->unsignedBigInteger('inscricao_atual_rl_mae_id')->nullable()->index('crianca_rl_mae_id_idx');
            $table->unsignedBigInteger('inscricao_atual_rl_outro_id')->nullable()->index('crianca_rl_outro_id_idx');
            $table->unsignedTinyInteger('tipo_ee')->default(0);
            $table->text('obs')->nullable();
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
            $table->dateTime('deleted_at')->nullable();
        });

        Schema::create('desinfecao', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('material_id')->index('desinfecao_material_id_idx');
            $table->date('data')->nullable();
            $table->unsignedInteger('ano_letivo')->default(2023);
            $table->unsignedTinyInteger('sala')->nullable()->default(0);
            $table->unsignedTinyInteger('qtd')->nullable()->default(0);
            $table->text('obs')->nullable();
            $table->unsignedBigInteger('reg_por_user_id')->index('desinfecao_reg_por_user_idx');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('documento', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedInteger('config_doc_id')->nullable()->index('documento_config_doc_id_idx');
            $table->string('nome');
            $table->unsignedTinyInteger('is_obrigatorio')->nullable()->default(0);
            $table->unsignedTinyInteger('is_calculo_mensalidade')->nullable()->default(0);
            $table->dateTime('entregue_em')->nullable();
            $table->unsignedBigInteger('entregue_por_user_id')->index('documento_entregue_por_user_id_idx');
            $table->dateTime('validado_em')->nullable();
            $table->unsignedBigInteger('validado_por_user_id')->index('documento_validado_por_user_id_idx');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
            $table->unsignedBigInteger('crianca_id')->index('fk_documento_crianca_id');
            $table->unsignedInteger('ano_letivo')->default(2023);
            $table->unsignedBigInteger('processo_id')->index('fk_documento_processo_id');
        });

        Schema::create('envolvidos', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('ocorrencia_id')->index('fk_envolvidos_ocorrencia_id');
            $table->string('envolvido_1', 100);
            $table->string('relacao_com_crianca_1', 100);
            $table->string('envolvido_2', 100);
            $table->string('relacao_com_crianca_2', 100);
            $table->string('envolvido_3', 100);
            $table->string('relacao_com_crianca_3', 100);
        });

        Schema::create('estado_processo', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('processo_id')->index('fk_estado_processo_processo_id');
            $table->unsignedTinyInteger('estado')->default(0);
            $table->string('modificado_por')->nullable();
            $table->dateTime('created_at')->nullable()->useCurrent()->index('estado_processo_estado_atual');
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('falta', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('inscricao_id')->index('falta_inscricao_id_idx');
            $table->date('data')->nullable();
            $table->unsignedInteger('ano_letivo')->default(2023);
            $table->unsignedTinyInteger('sala')->nullable()->default(0);
            $table->unsignedTinyInteger('tipo_falta')->default(0);
            $table->text('justificacao')->nullable();
            $table->unsignedBigInteger('marcada_por_user_id')->index('falta_marcada_por_user_idx');
            $table->string('fich_justificacao')->default('');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('form', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('processo_id')->unique('processo_id');
            $table->unsignedTinyInteger('estado')->default(0);
            $table->text('form')->nullable();
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('inscricao', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('crianca_id')->index('inscricao_crianca_id_idx');
            $table->unsignedTinyInteger('ordem')->nullable()->default(0);
            $table->unsignedInteger('al')->nullable()->default(2023);
            $table->dateTime('dt_validada')->nullable();
            $table->dateTime('dt_inicio_freq')->nullable();
            $table->unsignedTinyInteger('estado')->nullable()->default(0);
            $table->unsignedBigInteger('last_comunicacao')->nullable();
            $table->string('foto');
            $table->unsignedTinyInteger('sala')->nullable()->default(0);
            $table->unsignedTinyInteger('tipo_morada_c')->nullable()->default(0);
            $table->unsignedBigInteger('morada_id')->nullable()->index('inscricao_morada_id_idx');
            $table->unsignedBigInteger('rl_pai_id')->nullable()->index('inscricao_rl_pai_id_idx');
            $table->unsignedBigInteger('rl_mae_id')->nullable()->index('inscricao_rl_mae_id_idx');
            $table->unsignedBigInteger('rl_outro_id')->nullable()->index('inscricao_rl_outro_id_idx');
            $table->unsignedTinyInteger('tipo_ee')->default(0);
            $table->text('motivo_outro_rl');
            $table->unsignedBigInteger('atendimento_id')->nullable()->index('inscricao_atendimento_id_idx');
            $table->unsignedTinyInteger('qtd_irmaos_no_jdi')->default(0);
            $table->string('is_encaminhado_outros_serv')->nullable();
            $table->unsignedTinyInteger('is_familiar_colaborador')->default(0);
            $table->unsignedBigInteger('familiar_user_id')->nullable()->index('inscricao_familiar_user_id_idx');
            $table->unsignedInteger('familiar_parentesco_id')->nullable()->index('inscricao_familiar_parentesco_id_idx');
            $table->unsignedTinyInteger('is_necessario_apoio_especial')->default(0);
            $table->text('apoio_especial');
            $table->unsignedTinyInteger('is_necessario_apoio_comer')->default(0);
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
            $table->dateTime('deleted_at')->nullable();
        });

        Schema::create('lista_pertences', function (Blueprint $table) {
            $table->bigIncrements('pertences_id');
            $table->unsignedBigInteger('crianca_id')->index('fk_lista_pertences_crianca_id');
            $table->dateTime('ano_letivo')->nullable();
            $table->string('identificacao')->nullable();
            $table->integer('quantidade')->nullable();
            $table->string('obs')->nullable();
            $table->dateTime('data_hora_validacao')->nullable();
            $table->string('validado_por', 200)->nullable();
            $table->string('PDF_assinado', 200)->nullable();
        });

        Schema::create('material', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('nome')->default('');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('medicamento', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('nome')->default('');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('morada', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('rua');
            $table->string('localidade');
            $table->string('cp1', 4);
            $table->string('cp2', 3);
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('morph_comunicacao', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedInteger('gut')->default(111);
            $table->string('assunto');
            $table->unsignedBigInteger('registado_por_user_id')->index('morph_comunicacao_registado_por_idx');
            $table->unsignedBigInteger('destinatario_user_id')->nullable()->index('morph_comunicacao_destinatário_id_idx');
            $table->dateTime('lido_em')->nullable();
            $table->unsignedTinyInteger('estado_ant')->default(0);
            $table->unsignedTinyInteger('estado_atual')->default(0);
            $table->string('morph_model');
            $table->unsignedBigInteger('morph_id')->nullable();
            $table->unsignedTinyInteger('tipo_contacto')->default(0);
            $table->text('mensagem');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('ocorrencia', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('inscricao_id')->index('ocorrencia_inscricao_id_idx');
            $table->unsignedInteger('ano_letivo')->default(2023);
            $table->unsignedTinyInteger('sala')->nullable()->default(0);
            $table->tinyInteger('estado')->nullable()->default(1);
            $table->dateTime('dh_eliminada')->nullable();
            $table->text('descricao_ferimentos')->nullable();
            $table->tinyInteger('notificacao_policial')->nullable();
            $table->tinyInteger('notificacao_ministerio_publico')->nullable();
            $table->tinyInteger('exame_medico')->nullable();
            $table->tinyInteger('comunicacao_familia')->nullable();
            $table->text('comunicacao_interna')->nullable();
            $table->string('categoria_incidente', 100)->nullable();
            $table->dateTime('data_hora_acidente')->nullable()->useCurrent();
            $table->string('local_acidente', 200)->nullable()->default('JDI');
            $table->tinyInteger('agressao_fisica_si_proprio')->nullable();
            $table->tinyInteger('agressao_fisica_familia')->nullable();
            $table->tinyInteger('agressao_fisica_outro')->nullable();
            $table->text('agressao_fisica_especifique')->nullable();
            $table->tinyInteger('dano_na_crianca_acidente')->nullable();
            $table->tinyInteger('dano_na_crianca_si_proprio')->nullable();
            $table->tinyInteger('dano_na_crianca_familia')->nullable();
            $table->tinyInteger('dano_na_crianca_outro')->nullable();
            $table->text('dano_na_crianca_especifique')->nullable();
            $table->tinyInteger('ingestao_substancias_suspeita_observada')->nullable();
            $table->tinyInteger('ingestao_substancias_admitida')->nullable();
            $table->tinyInteger('ingestao_substancias_med_documentada')->nullable();
            $table->tinyInteger('ingestao_substancias_outros')->nullable();
            $table->text('ingestao_substancias_especifique')->nullable();
            $table->tinyInteger('comportamentos_negativos_ameaca')->nullable();
            $table->tinyInteger('comportamentos_negativos_contato_policial')->nullable();
            $table->tinyInteger('comportamentos_negativos_med_documentada')->nullable();
            $table->tinyInteger('comportamentos_negativos_outros')->nullable();
            $table->text('comportamentos_negativos_especifique')->nullable();
            $table->tinyInteger('abuso_sexual_comportamento_improprio_utente')->nullable();
            $table->tinyInteger('abuso_sexual_comportamento_improprio_colaborador')->nullable();
            $table->tinyInteger('abuso_sexual_comportamento_improprio_familia')->nullable();
            $table->text('abuso_sexual_comportamento_improprio_quem')->nullable();
            $table->tinyInteger('abuso_sexual_comportamento_improprio_outro')->nullable();
            $table->text('abuso_sexual_comportamento_improprio_especifique')->nullable();
            $table->tinyInteger('alegacao_abusos_colaborador')->nullable();
            $table->tinyInteger('alegacao_abusos_familia')->nullable();
            $table->text('alegacao_abusos_quem')->nullable();
            $table->tinyInteger('alegacao_abusos_outro')->nullable();
            $table->text('alegacao_abusos_especifique')->nullable();
            $table->tinyInteger('tipo_alegacao_fisico')->nullable();
            $table->tinyInteger('tipo_alegacao_sexual')->nullable();
            $table->tinyInteger('tipo_alegacao_negligencia')->nullable();
            $table->tinyInteger('tipo_alegacao_outro')->nullable();
            $table->text('tipo_alegacao_especifique')->nullable();
            $table->tinyInteger('ficha_ocorrencia_nao_investigado')->nullable();
            $table->tinyInteger('ficha_ocorrencia_decisao_pendente')->nullable();
            $table->tinyInteger('ficha_ocorrencia_investigado')->nullable();
            $table->tinyInteger('acoes_negativas_verbal')->nullable();
            $table->tinyInteger('acoes_negativas_fisica')->nullable();
            $table->tinyInteger('acoes_negativas_outro')->nullable();
            $table->text('acoes_negativas_especifique')->nullable();
            $table->tinyInteger('familia_magoada_contencao')->nullable();
            $table->tinyInteger('familia_magoada_infligido')->nullable();
            $table->tinyInteger('familia_magoada_outro')->nullable();
            $table->text('familia_magoada_especifique')->nullable();
            $table->tinyInteger('fonte_observacao_colaboradores')->nullable();
            $table->tinyInteger('fonte_observacao_familia')->nullable();
            $table->tinyInteger('fonte_observacao_outro')->nullable();
            $table->text('fonte_observacao_especifique')->nullable();
            $table->tinyInteger('ocorrencia_privada')->nullable();
            $table->tinyInteger('ocorrencia_publica')->nullable();
            $table->unsignedBigInteger('reg_por_colaborador_id')->index('ocorrencia_reg_por_colaborador_id_idx');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('parentesco', function (Blueprint $table) {
            $table->increments('id');
            $table->string('designacao');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('pessoa', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('inscricao_id')->index('pessoa_inscricao_id_idx');
            $table->unsignedTinyInteger('pode_levar_crianca')->default(0);
            $table->unsignedTinyInteger('is_emergencia')->default(0);
            $table->unsignedTinyInteger('in_agregado_familiar')->default(0);
            $table->string('nome');
            $table->unsignedInteger('parentesco_id')->nullable()->index('pessoa_parentesco_id_idx');
            $table->string('email');
            $table->string('tel');
            $table->string('tlm');
            $table->string('profissao');
            $table->dateTime('dn')->nullable();
            $table->unsignedDecimal('rendimento', 9)->nullable()->default(0);
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('processo', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('crianca_id')->index('fk_processo_crianca');
            $table->unsignedTinyInteger('estado')->default(0);
            $table->unsignedTinyInteger('tipo')->default(0);
            $table->date('data_inicio')->nullable();
            $table->date('data_fim')->nullable();
            $table->string('nome');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('projeto_curricular', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedInteger('ano_letivo')->default(2023);
            $table->string('submetido_por');
            $table->dateTime('dh_submetido')->useCurrent();
            $table->string('pc_ficheiro')->nullable();
            $table->unsignedBigInteger('relatorio_id_ano1')->unique('relatorio_id_ano1');
            $table->unsignedBigInteger('relatorio_id_ano2')->unique('relatorio_id_ano2');
            $table->unsignedBigInteger('relatorio_id_ano3')->unique('relatorio_id_ano3');
            $table->tinyInteger('estado')->nullable();
        });

        Schema::create('razao_toma', function (Blueprint $table) {
            $table->tinyIncrements('id');
            $table->string('razao')->default('');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('rd', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('inscricao_id')->index('rd_inscricao_id_idx');
            $table->date('data')->nullable();
            $table->unsignedInteger('ano_letivo')->default(2023);
            $table->unsignedTinyInteger('sala')->nullable()->default(0);
            $table->unsignedTinyInteger('tipo_descanso')->default(0);
            $table->unsignedTinyInteger('tipo_almoco')->default(0);
            $table->unsignedTinyInteger('tipo_lanche')->default(0);
            $table->unsignedTinyInteger('tipo_apoio_comer')->default(0);
            $table->unsignedBigInteger('reg_por_user_id')->index('rd_reg_por_user_idx');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('relatorio', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->text('avaliacao')->nullable();
            $table->string('pdf', 250)->nullable();
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable();
        });

        Schema::create('relatorio_pc', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('pc_id')->index('fk_relatorio_pc_projeto_curricular_id');
            $table->tinyInteger('relatorio_numero');
            $table->string('ficheiro_relatorio')->nullable();
            $table->string('submetido_por');
            $table->dateTime('dh_relatorio')->useCurrent();
        });

        Schema::create('rl', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('user_id')->nullable()->index('rl_user_id_idx');
            $table->unsignedTinyInteger('tipo_rl')->default(0);
            $table->string('nome');
            $table->dateTime('dn')->nullable();
            $table->string('nif')->index('rl_nif_idx');
            $table->string('email')->index('rl_email_idx');
            $table->dateTime('email_verified_at')->nullable();
            $table->string('tel');
            $table->string('tlm');
            $table->unsignedBigInteger('morada_id')->nullable()->index('rl_morada_id_idx');
            $table->string('sit_prof');
            $table->string('profissao');
            $table->string('localidade_emprego');
            $table->string('tlf_emprego');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('tentativas_comunicacao', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('atendimento_id')->index('fk_tentativas_comunicacao_atendimento_id');
            $table->text('obs')->nullable();
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('toma_medicamento', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('inscricao_id')->index('toma_medicamento_inscricao_id_idx');
            $table->unsignedBigInteger('medicamento_id')->index('toma_medicamento_medicamento_id_idx');
            $table->unsignedTinyInteger('razao_toma_id')->index('toma_medicamento_razao_toma_id_idx');
            $table->string('descricao_dosagem')->nullable()->default('');
            $table->dateTime('dh_toma')->nullable();
            $table->unsignedInteger('ano_letivo')->default(2023);
            $table->unsignedTinyInteger('sala')->nullable()->default(0);
            $table->unsignedBigInteger('reg_por_user_id')->index('fk_toma_medicamento_reg_por_user_id');
            $table->dateTime('dh_confirmacao_educadora')->nullable();
            $table->unsignedBigInteger('educadora_user_id')->index('fk_toma_medicamento_educadora_user_id');
            $table->dateTime('created_at')->nullable()->useCurrent();
            $table->dateTime('updated_at')->nullable()->useCurrent();
        });

        Schema::create('users', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('name');
            $table->string('short_name')->default('');
            $table->string('email')->unique();
            $table->dateTime('email_verified_at')->nullable();
            $table->string('password');
            $table->rememberToken();
            $table->string('avatar')->nullable();
            $table->dateTime('deactivated_at')->nullable();
            $table->dateTime('created_at')->nullable();
            $table->dateTime('updated_at')->nullable();
        });

        Schema::table('comportamento_observavel_pd', function (Blueprint $table) {
            $table->foreign(['id'], 'fk_perfil_desenvolvimento_has_Comportamento_observavel_Perfil')->references(['id'])->on('perfil_desenvolvimento')->onUpdate('NO ACTION')->onDelete('NO ACTION');
        });

        Schema::table('medidas', function (Blueprint $table) {
            $table->foreign(['Processo_Adaptacao_ID'], 'fk_medidas_Processo_Adaptacao1')->references(['ID'])->on('Processo_Adaptacao')->onUpdate('NO ACTION')->onDelete('NO ACTION');
        });

        Schema::table('perfil_desenvolvimento', function (Blueprint $table) {
            $table->foreign(['inscricao_id'], 'fk_perfil_desenvolvimento_inscricao_id')->references(['id'])->on('inscricao')->onUpdate('CASCADE');
        });

        Schema::table('programa_acolhimento', function (Blueprint $table) {
            $table->foreign(['inscricao_id'], 'fk_programa_acolhimento_inscricao_id')->references(['id'])->on('inscricao')->onUpdate('CASCADE');
        });

        Schema::table('processo_adaptacao', function (Blueprint $table) {
            $table->foreign(['programa_acolhimento_ID'], 'fk_processo_adaptacao_programa_acolhimento1')->references(['ID'])->on('programa_acolhimento')->onUpdate('NO ACTION')->onDelete('NO ACTION');
            $table->foreign(['Tipo_PA_ID'], 'fk_processo_adaptacao_Tipo_PA1')->references(['ID'])->on('Tipo_PA')->onUpdate('NO ACTION')->onDelete('NO ACTION');
        });

        Schema::table('atividade', function (Blueprint $table) {
            $table->foreign(['relatorio_id'], 'fk_atividade_relatorio_id')->references(['id'])->on('relatorio')->onUpdate('CASCADE');
        });

        Schema::table('avaliacao_ocorrencia', function (Blueprint $table) {
            $table->foreign(['ocorrencia_id'], 'avaliacao_ocorrencia_ibfk_1')->references(['id'])->on('ocorrencia')->onUpdate('NO ACTION')->onDelete('NO ACTION');
            $table->foreign(['ocorrencia_id'], 'fk_avaliacao_ocorrencia_ocorrencia_id')->references(['id'])->on('ocorrencia')->onUpdate('CASCADE');
        });

        Schema::table('comportamento_observavel', function (Blueprint $table) {
            $table->foreign(['subcomportamento'], 'fk_Comportamento_observavel_Comportamento_observavel1')->references(['id'])->on('Comportamento_observavel')->onUpdate('NO ACTION')->onDelete('NO ACTION');
        });

        Schema::table('crianca', function (Blueprint $table) {
            $table->foreign(['inscricao_atual_id'], 'fk_crianca_inscricao_atual_id')->references(['id'])->on('inscricao')->onUpdate('CASCADE');
            $table->foreign(['inscricao_atual_morada_id'], 'fk_crianca_inscricao_atual_morada_id')->references(['id'])->on('morada')->onUpdate('CASCADE');
            $table->foreign(['inscricao_atual_rl_mae_id'], 'fk_crianca_rl_mae_id')->references(['id'])->on('rl')->onUpdate('CASCADE');
            $table->foreign(['inscricao_atual_rl_outro_id'], 'fk_crianca_rl_outro_id')->references(['id'])->on('rl')->onUpdate('CASCADE');
            $table->foreign(['inscricao_atual_rl_pai_id'], 'fk_crianca_rl_pai_id')->references(['id'])->on('rl')->onUpdate('CASCADE');
        });

        Schema::table('desinfecao', function (Blueprint $table) {
            $table->foreign(['material_id'], 'fk_desinfecao_material_id')->references(['id'])->on('material')->onUpdate('CASCADE')->onDelete('CASCADE');
            $table->foreign(['reg_por_user_id'], 'fk_desinfecao_reg_por_user_id')->references(['id'])->on('users')->onUpdate('CASCADE');
        });

        Schema::table('documento', function (Blueprint $table) {
            $table->foreign(['config_doc_id'], 'fk_documento_config_doc_id')->references(['id'])->on('config_docs')->onUpdate('CASCADE');
            $table->foreign(['crianca_id'], 'fk_documento_crianca_id')->references(['id'])->on('crianca')->onUpdate('CASCADE');
            $table->foreign(['entregue_por_user_id'], 'fk_documento_entregue_por_user_id')->references(['id'])->on('users')->onUpdate('CASCADE');
            $table->foreign(['processo_id'], 'fk_documento_processo_id')->references(['id'])->on('processo')->onUpdate('CASCADE');
            $table->foreign(['validado_por_user_id'], 'fk_documento_validado_por_user_id')->references(['id'])->on('users')->onUpdate('CASCADE');
        });

        Schema::table('envolvidos', function (Blueprint $table) {
            $table->foreign(['ocorrencia_id'], 'fk_envolvidos_ocorrencia_id')->references(['id'])->on('ocorrencia')->onUpdate('CASCADE');
        });

        Schema::table('estado_processo', function (Blueprint $table) {
            $table->foreign(['processo_id'], 'fk_estado_processo_processo_id')->references(['id'])->on('processo')->onUpdate('CASCADE');
        });

        Schema::table('falta', function (Blueprint $table) {
            $table->foreign(['inscricao_id'], 'fk_falta_inscricao_id')->references(['id'])->on('inscricao')->onUpdate('CASCADE')->onDelete('CASCADE');
            $table->foreign(['marcada_por_user_id'], 'fk_falta_marcada_por_user_id')->references(['id'])->on('users')->onUpdate('CASCADE');
        });

        Schema::table('form', function (Blueprint $table) {
            $table->foreign(['processo_id'], 'fk_form_processo_id')->references(['id'])->on('processo')->onUpdate('CASCADE');
        });

        Schema::table('inscricao', function (Blueprint $table) {
            $table->foreign(['atendimento_id'], 'fk_inscricao_atendimento_id')->references(['id'])->on('atendimento')->onUpdate('CASCADE')->onDelete('CASCADE');
            $table->foreign(['crianca_id'], 'fk_inscricao_crianca_id')->references(['id'])->on('crianca')->onUpdate('CASCADE');
            $table->foreign(['familiar_parentesco_id'], 'fk_inscricao_familiar_parentesco_id')->references(['id'])->on('parentesco')->onUpdate('CASCADE');
            $table->foreign(['familiar_user_id'], 'fk_inscricao_familiar_user_id')->references(['id'])->on('users')->onUpdate('CASCADE');
            $table->foreign(['morada_id'], 'fk_inscricao_morada_id')->references(['id'])->on('morada')->onUpdate('CASCADE');
            $table->foreign(['rl_mae_id'], 'fk_inscricao_rl_mae_id')->references(['id'])->on('rl')->onUpdate('CASCADE');
            $table->foreign(['rl_outro_id'], 'fk_inscricao_rl_outro_id')->references(['id'])->on('rl')->onUpdate('CASCADE');
            $table->foreign(['rl_pai_id'], 'fk_inscricao_rl_pai_id')->references(['id'])->on('rl')->onUpdate('CASCADE');
        });

        Schema::table('lista_pertences', function (Blueprint $table) {
            $table->foreign(['crianca_id'], 'fk_lista_pertences_crianca_id')->references(['id'])->on('crianca')->onUpdate('NO ACTION')->onDelete('NO ACTION');
        });

        Schema::table('morph_comunicacao', function (Blueprint $table) {
            $table->foreign(['destinatario_user_id'], 'fk_morph_comunicacao_destinatario_user_id')->references(['id'])->on('users')->onUpdate('CASCADE');
            $table->foreign(['registado_por_user_id'], 'fk_morph_comunicacao_registado_por_user_id')->references(['id'])->on('users')->onUpdate('CASCADE');
        });

        Schema::table('ocorrencia', function (Blueprint $table) {
            $table->foreign(['inscricao_id'], 'fk_ocorrencia_inscricao_id')->references(['id'])->on('inscricao')->onUpdate('CASCADE')->onDelete('CASCADE');
            $table->foreign(['reg_por_colaborador_id'], 'fk_toma_medicamento_reg_por_colaborador_id')->references(['id'])->on('users')->onUpdate('CASCADE');
        });

        Schema::table('pessoa', function (Blueprint $table) {
            $table->foreign(['inscricao_id'], 'fk_pessoa_inscricao_id')->references(['id'])->on('inscricao')->onUpdate('CASCADE')->onDelete('CASCADE');
            $table->foreign(['parentesco_id'], 'fk_pessoa_parentesco_id')->references(['id'])->on('parentesco')->onUpdate('CASCADE');
        });

        Schema::table('processo', function (Blueprint $table) {
            $table->foreign(['crianca_id'], 'fk_processo_crianca')->references(['id'])->on('crianca')->onUpdate('CASCADE');
        });

        Schema::table('projeto_curricular', function (Blueprint $table) {
            $table->foreign(['relatorio_id_ano1'], 'fk_projeto_curricular_relatorio_pc_id_1')->references(['id'])->on('relatorio_pc')->onUpdate('CASCADE');
            $table->foreign(['relatorio_id_ano2'], 'fk_projeto_curricular_relatorio_pc_id_2')->references(['id'])->on('relatorio_pc')->onUpdate('CASCADE');
            $table->foreign(['relatorio_id_ano3'], 'fk_projeto_curricular_relatorio_pc_id_3')->references(['id'])->on('relatorio_pc')->onUpdate('CASCADE');
        });

        Schema::table('rd', function (Blueprint $table) {
            $table->foreign(['inscricao_id'], 'fk_rd_inscricao_id')->references(['id'])->on('inscricao')->onUpdate('CASCADE')->onDelete('CASCADE');
            $table->foreign(['reg_por_user_id'], 'fk_rd_marcada_por_user_id')->references(['id'])->on('users')->onUpdate('CASCADE');
        });

        Schema::table('relatorio_pc', function (Blueprint $table) {
            $table->foreign(['pc_id'], 'fk_relatorio_pc_projeto_curricular_id')->references(['id'])->on('projeto_curricular')->onUpdate('CASCADE');
        });

        Schema::table('rl', function (Blueprint $table) {
            $table->foreign(['morada_id'], 'fk_rl_morada_id')->references(['id'])->on('morada')->onUpdate('CASCADE');
            $table->foreign(['user_id'], 'fk_rl_user_id')->references(['id'])->on('users')->onUpdate('CASCADE');
        });

        Schema::table('tentativas_comunicacao', function (Blueprint $table) {
            $table->foreign(['atendimento_id'], 'fk_tentativas_comunicacao_atendimento_id')->references(['id'])->on('atendimento')->onUpdate('CASCADE')->onDelete('CASCADE');
        });

        Schema::table('toma_medicamento', function (Blueprint $table) {
            $table->foreign(['educadora_user_id'], 'fk_toma_medicamento_educadora_user_id')->references(['id'])->on('users')->onUpdate('CASCADE');
            $table->foreign(['inscricao_id'], 'fk_toma_medicamento_inscricao_id')->references(['id'])->on('inscricao')->onUpdate('CASCADE')->onDelete('CASCADE');
            $table->foreign(['medicamento_id'], 'fk_toma_medicamento_medicamento_id')->references(['id'])->on('medicamento')->onUpdate('CASCADE');
            $table->foreign(['razao_toma_id'], 'fk_toma_medicamento_razao_toma_id')->references(['id'])->on('razao_toma')->onUpdate('CASCADE');
            $table->foreign(['reg_por_user_id'], 'fk_toma_medicamento_reg_por_user_id')->references(['id'])->on('users')->onUpdate('CASCADE');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('toma_medicamento', function (Blueprint $table) {
            $table->dropForeign('fk_toma_medicamento_educadora_user_id');
            $table->dropForeign('fk_toma_medicamento_inscricao_id');
            $table->dropForeign('fk_toma_medicamento_medicamento_id');
            $table->dropForeign('fk_toma_medicamento_razao_toma_id');
            $table->dropForeign('fk_toma_medicamento_reg_por_user_id');
        });

        Schema::table('tentativas_comunicacao', function (Blueprint $table) {
            $table->dropForeign('fk_tentativas_comunicacao_atendimento_id');
        });

        Schema::table('rl', function (Blueprint $table) {
            $table->dropForeign('fk_rl_morada_id');
            $table->dropForeign('fk_rl_user_id');
        });

        Schema::table('relatorio_pc', function (Blueprint $table) {
            $table->dropForeign('fk_relatorio_pc_projeto_curricular_id');
        });

        Schema::table('rd', function (Blueprint $table) {
            $table->dropForeign('fk_rd_inscricao_id');
            $table->dropForeign('fk_rd_marcada_por_user_id');
        });

        Schema::table('projeto_curricular', function (Blueprint $table) {
            $table->dropForeign('fk_projeto_curricular_relatorio_pc_id_1');
            $table->dropForeign('fk_projeto_curricular_relatorio_pc_id_2');
            $table->dropForeign('fk_projeto_curricular_relatorio_pc_id_3');
        });

        Schema::table('processo', function (Blueprint $table) {
            $table->dropForeign('fk_processo_crianca');
        });

        Schema::table('pessoa', function (Blueprint $table) {
            $table->dropForeign('fk_pessoa_inscricao_id');
            $table->dropForeign('fk_pessoa_parentesco_id');
        });

        Schema::table('ocorrencia', function (Blueprint $table) {
            $table->dropForeign('fk_ocorrencia_inscricao_id');
            $table->dropForeign('fk_toma_medicamento_reg_por_colaborador_id');
        });

        Schema::table('morph_comunicacao', function (Blueprint $table) {
            $table->dropForeign('fk_morph_comunicacao_destinatario_user_id');
            $table->dropForeign('fk_morph_comunicacao_registado_por_user_id');
        });

        Schema::table('lista_pertences', function (Blueprint $table) {
            $table->dropForeign('fk_lista_pertences_crianca_id');
        });

        Schema::table('inscricao', function (Blueprint $table) {
            $table->dropForeign('fk_inscricao_atendimento_id');
            $table->dropForeign('fk_inscricao_crianca_id');
            $table->dropForeign('fk_inscricao_familiar_parentesco_id');
            $table->dropForeign('fk_inscricao_familiar_user_id');
            $table->dropForeign('fk_inscricao_morada_id');
            $table->dropForeign('fk_inscricao_rl_mae_id');
            $table->dropForeign('fk_inscricao_rl_outro_id');
            $table->dropForeign('fk_inscricao_rl_pai_id');
        });

        Schema::table('form', function (Blueprint $table) {
            $table->dropForeign('fk_form_processo_id');
        });

        Schema::table('falta', function (Blueprint $table) {
            $table->dropForeign('fk_falta_inscricao_id');
            $table->dropForeign('fk_falta_marcada_por_user_id');
        });

        Schema::table('estado_processo', function (Blueprint $table) {
            $table->dropForeign('fk_estado_processo_processo_id');
        });

        Schema::table('envolvidos', function (Blueprint $table) {
            $table->dropForeign('fk_envolvidos_ocorrencia_id');
        });

        Schema::table('documento', function (Blueprint $table) {
            $table->dropForeign('fk_documento_config_doc_id');
            $table->dropForeign('fk_documento_crianca_id');
            $table->dropForeign('fk_documento_entregue_por_user_id');
            $table->dropForeign('fk_documento_processo_id');
            $table->dropForeign('fk_documento_validado_por_user_id');
        });

        Schema::table('desinfecao', function (Blueprint $table) {
            $table->dropForeign('fk_desinfecao_material_id');
            $table->dropForeign('fk_desinfecao_reg_por_user_id');
        });

        Schema::table('crianca', function (Blueprint $table) {
            $table->dropForeign('fk_crianca_inscricao_atual_id');
            $table->dropForeign('fk_crianca_inscricao_atual_morada_id');
            $table->dropForeign('fk_crianca_rl_mae_id');
            $table->dropForeign('fk_crianca_rl_outro_id');
            $table->dropForeign('fk_crianca_rl_pai_id');
        });

        Schema::table('comportamento_observavel', function (Blueprint $table) {
            $table->dropForeign('fk_Comportamento_observavel_Comportamento_observavel1');
        });

        Schema::table('avaliacao_ocorrencia', function (Blueprint $table) {
            $table->dropForeign('avaliacao_ocorrencia_ibfk_1');
            $table->dropForeign('fk_avaliacao_ocorrencia_ocorrencia_id');
        });

        Schema::table('atividade', function (Blueprint $table) {
            $table->dropForeign('fk_atividade_relatorio_id');
        });

        Schema::table('processo_adaptacao', function (Blueprint $table) {
            $table->dropForeign('fk_processo_adaptacao_programa_acolhimento1');
            $table->dropForeign('fk_processo_adaptacao_Tipo_PA1');
        });

        Schema::table('programa_acolhimento', function (Blueprint $table) {
            $table->dropForeign('fk_programa_acolhimento_inscricao_id');
        });

        Schema::table('perfil_desenvolvimento', function (Blueprint $table) {
            $table->dropForeign('fk_perfil_desenvolvimento_inscricao_id');
        });

        Schema::table('medidas', function (Blueprint $table) {
            $table->dropForeign('fk_medidas_processo_adaptacao1');
        });

        Schema::table('comportamento_observavel_pd', function (Blueprint $table) {
            $table->dropForeign('fk_perfil_desenvolvimento_has_Comportamento_observavel_Perfil');
        });

        Schema::dropIfExists('users');

        Schema::dropIfExists('toma_medicamento');

        Schema::dropIfExists('tentativas_comunicacao');

        Schema::dropIfExists('rl');

        Schema::dropIfExists('relatorio_pc');

        Schema::dropIfExists('relatorio');

        Schema::dropIfExists('rd');

        Schema::dropIfExists('razao_toma');

        Schema::dropIfExists('projeto_curricular');

        Schema::dropIfExists('processo');

        Schema::dropIfExists('pessoa');

        Schema::dropIfExists('parentesco');

        Schema::dropIfExists('ocorrencia');

        Schema::dropIfExists('morph_comunicacao');

        Schema::dropIfExists('morada');

        Schema::dropIfExists('medicamento');

        Schema::dropIfExists('material');

        Schema::dropIfExists('lista_pertences');

        Schema::dropIfExists('inscricao');

        Schema::dropIfExists('form');

        Schema::dropIfExists('falta');

        Schema::dropIfExists('estado_processo');

        Schema::dropIfExists('envolvidos');

        Schema::dropIfExists('documento');

        Schema::dropIfExists('desinfecao');

        Schema::dropIfExists('crianca');

        Schema::dropIfExists('config_docs');

        Schema::dropIfExists('config');

        Schema::dropIfExists('comportamento_observavel');

        Schema::dropIfExists('avaliacao_ocorrencia');

        Schema::dropIfExists('atividade');

        Schema::dropIfExists('atendimento');

        Schema::dropIfExists('Tipo_PA');

        Schema::dropIfExists('processo_adaptacao');

        Schema::dropIfExists('programa_acolhimento');

        Schema::dropIfExists('plano_semanal_sala');

        Schema::dropIfExists('perfil_desenvolvimento');

        Schema::dropIfExists('medidas');

        Schema::dropIfExists('comportamento_observavel_pd');


        // --------------------------------
        // --------------------------------

        Schema::dropIfExists('users');
        Schema::dropIfExists('password_reset_tokens');
        Schema::dropIfExists('failed_jobs');
        // --------------------------------
        // --------------------------------
        $tableNames = config('permission.table_names');

        if (empty($tableNames)) {
            throw new \Exception('Error: config/permission.php not found and defaults could not be merged. Please publish the package configuration before proceeding, or drop the tables manually.');
        }

        Schema::drop($tableNames['role_has_permissions']);
        Schema::drop($tableNames['model_has_roles']);
        Schema::drop($tableNames['model_has_permissions']);
        Schema::drop($tableNames['roles']);
        Schema::drop($tableNames['permissions']);
    }
};
