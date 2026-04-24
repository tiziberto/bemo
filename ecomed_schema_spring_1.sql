-- ============================================================
--  ECOMED — Schema optimizado para Spring Boot / JPA / Hibernate
--  MariaDB 10.6+ / MySQL 8+
--  Fecha: 2026-03-19
-- ============================================================
--
--  DECISIONES DE DISEÑO PARA SPRING BOOT
--  ──────────────────────────────────────
--  1. TODOS los ID son BIGINT AUTO_INCREMENT (un solo campo).
--     Los @EmbeddedId compuestos de JPA son dolorosos; mejor
--     surrogate key + unique constraint donde haga falta.
--
--  2. Campos de auditoría ESTANDARIZADOS en todas las entidades:
--       created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
--       updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE ...
--       created_by   VARCHAR(50)   → @CreatedBy  de Spring Data Auditing
--       updated_by   VARCHAR(50)   → @LastModifiedBy
--     Se mapean con @EntityListeners(AuditingEntityListener.class)
--     en una clase base @MappedSuperclass.
--
--  3. DATETIME en lugar de TIMESTAMP para evitar la conversión
--     automática de zona horaria de MariaDB/MySQL. Spring maneja
--     la zona en la capa de aplicación.
--
--  4. Sin PARTICIONADO en tablas que Spring consulta por @Id o
--     relaciones JPA — el particionado exige que la PK incluya
--     la columna de partición, lo que rompe la semántica de
--     @GeneratedValue. Los turnos históricos van a una tabla
--     separada de archivo (`turnos_archivo`) que se gestiona
--     fuera del contexto JPA normal.
--
--  5. Booleanos como BOOLEAN (alias de TINYINT(1)).
--     En Java se mapean a `boolean` / `Boolean` sin conversores.
--
--  6. Importes siempre DECIMAL(12,2), nunca DOUBLE.
--
--  7. Claves foráneas con CASCADE declarado explícitamente para
--     que coincidan con las opciones @OnDelete / CascadeType de JPA.
--
--  8. UNIQUE constraints con nombre para poder referenciarlos
--     desde las @UniqueConstraint en las entidades Java.
-- ============================================================

SET NAMES utf8mb4;
SET foreign_key_checks = 0;
SET time_zone = '+00:00';

-- ============================================================
--  CATÁLOGOS  (tablas de referencia, pocas filas, casi solo-lectura)
-- ============================================================

CREATE TABLE IF NOT EXISTS condicion_iva (
  id          TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  descripcion VARCHAR(50)      NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_condicion_iva_descripcion (descripcion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Condiciones de IVA (Responsable Inscripto, Monotributo, etc.)';

-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tipo_domicilio (
  id          TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  descripcion VARCHAR(50)      NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tipo de domicilio (real, legal, comercial)';

-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS especialidad (
  id          SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  descripcion VARCHAR(100)      NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_especialidad_descripcion (descripcion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Especialidades médicas';

-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS estado_turno (
  id          TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  descripcion VARCHAR(50)      NOT NULL,
  color       VARCHAR(10)      NOT NULL DEFAULT '#FFFFFF',
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Estados del turno: Libre, Reservado, Presente, Ausente, etc.';

-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS origen (
  id          TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  descripcion VARCHAR(50)      NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Origen de la orden (espontáneo, derivación, internación)';

-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS sexo (
  id          TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  descripcion VARCHAR(50)      NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Sexo / género';

-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tipo_usuario (
  id          TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  descripcion VARCHAR(50)      NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tipo de usuario del sistema';

-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tipo_afiliado (
  id          TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  descripcion VARCHAR(50)      NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tipo de afiliado: titular, cónyuge, hijo, etc.';

-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tipo_recupero (
  id          TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  descripcion VARCHAR(50)      NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tipos de recupero de caja';

-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tipo_pago (
  id          TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  descripcion VARCHAR(50)      NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tipos de pago: efectivo, transferencia, cheque, etc.';

-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS provincia (
  id          SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  descripcion VARCHAR(50)       NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Provincias argentinas';

-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS localidad (
  id           INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  descripcion  VARCHAR(50)       NOT NULL,
  provincia_id SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (id),
  INDEX idx_localidad_provincia (provincia_id),
  CONSTRAINT fk_localidad_provincia
    FOREIGN KEY (provincia_id) REFERENCES provincia (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Localidades por provincia';

-- ============================================================
--  OBRA SOCIAL  →  PLAN  (1 : N)
-- ============================================================

CREATE TABLE IF NOT EXISTS obra_social (
  id               SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  descripcion      VARCHAR(150)      NOT NULL,
  abreviatura      VARCHAR(20)       NOT NULL DEFAULT '',
  condicion_iva_id TINYINT UNSIGNED  NOT NULL DEFAULT 5,
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  INDEX idx_obra_social_descripcion (descripcion(50)),
  CONSTRAINT fk_obra_social_condicion_iva
    FOREIGN KEY (condicion_iva_id) REFERENCES condicion_iva (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Obras sociales y prepagas';

-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS plan (
  id             SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  obra_social_id SMALLINT UNSIGNED NOT NULL,
  descripcion    VARCHAR(50)       NOT NULL,
  PRIMARY KEY (id),
  INDEX idx_plan_obra_social (obra_social_id),
  CONSTRAINT fk_plan_obra_social
    FOREIGN KEY (obra_social_id) REFERENCES obra_social (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Planes por obra social';

-- ============================================================
--  PERÍODO DE FACTURACIÓN
-- ============================================================

CREATE TABLE IF NOT EXISTS periodo (
  id          MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT
              COMMENT 'Ej: 202306 = junio 2023',
  descripcion VARCHAR(50)        NOT NULL,
  cerrado     BOOLEAN            NOT NULL DEFAULT FALSE,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Períodos de facturación a obras sociales';

-- ============================================================
--  NOMENCLADOR
--  (nomenclador_2023 era duplicado — unificado aquí por periodo_id)
-- ============================================================

CREATE TABLE IF NOT EXISTS nomenclador (
  id              BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  periodo_id      MEDIUMINT UNSIGNED NOT NULL DEFAULT 0,
  obra_social_id  SMALLINT UNSIGNED  NOT NULL DEFAULT 0,
  codigo          VARCHAR(10)        NOT NULL DEFAULT '',
  descripcion     VARCHAR(200)       NOT NULL DEFAULT '',
  id_galeno       SMALLINT UNSIGNED  NOT NULL DEFAULT 0,
  valor_galeno    DECIMAL(12,4)      NOT NULL DEFAULT 0.0000,
  id_gasto        SMALLINT UNSIGNED  NOT NULL DEFAULT 0,
  unidades_gasto  DECIMAL(12,4)      NOT NULL DEFAULT 0.0000,
  especialidad_id SMALLINT UNSIGNED  NOT NULL DEFAULT 0,
  vigente         BOOLEAN            NOT NULL DEFAULT TRUE,
  importe_tit_a   DECIMAL(12,4)      NOT NULL DEFAULT 0.0000,
  importe_gas_a   DECIMAL(12,4)      NOT NULL DEFAULT 0.0000,
  importe_tit_b   DECIMAL(12,4)      NOT NULL DEFAULT 0.0000,
  importe_gas_b   DECIMAL(12,4)      NOT NULL DEFAULT 0.0000,
  importe_tit_c   DECIMAL(12,4)      NOT NULL DEFAULT 0.0000,
  importe_gas_c   DECIMAL(12,4)      NOT NULL DEFAULT 0.0000,
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  -- la unicidad real es periodo + obra_social + código
  UNIQUE KEY uq_nomenclador_periodo_os_codigo (periodo_id, obra_social_id, codigo),
  INDEX idx_nomenclador_especialidad (especialidad_id),
  INDEX idx_nomenclador_vigente      (vigente),
  CONSTRAINT fk_nomenclador_obra_social
    FOREIGN KEY (obra_social_id) REFERENCES obra_social (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_nomenclador_especialidad
    FOREIGN KEY (especialidad_id) REFERENCES especialidad (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Nomenclador de prestaciones por período y obra social';

-- ============================================================
--  PRESTADOR  (médico efector)
-- ============================================================

CREATE TABLE IF NOT EXISTS prestador (
  id               SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre           VARCHAR(100)      NOT NULL DEFAULT '',
  categoria        CHAR(1)           NOT NULL DEFAULT 'A',
  telefono         VARCHAR(25)       NOT NULL DEFAULT '',
  cuit             VARCHAR(20)       NOT NULL DEFAULT '',
  condicion_iva_id TINYINT UNSIGNED  DEFAULT NULL,
  email            VARCHAR(100)      NOT NULL DEFAULT '',
  matricula        VARCHAR(10)       NOT NULL DEFAULT '',
  porcentaje_efe   TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  especialidad     VARCHAR(150)      NOT NULL DEFAULT '',
  asigna_turnos    BOOLEAN           NOT NULL DEFAULT FALSE,
  observaciones    TEXT              NOT NULL DEFAULT '',
  mensaje          TEXT              NOT NULL DEFAULT '',
  fecha_alta       DATE              DEFAULT NULL,
  fecha_baja       DATE              DEFAULT NULL,
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  INDEX idx_prestador_nombre (nombre(50)),
  INDEX idx_prestador_activo (fecha_baja),
  CONSTRAINT fk_prestador_condicion_iva
    FOREIGN KEY (condicion_iva_id) REFERENCES condicion_iva (id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Médicos / prestadores del centro';

-- ============================================================
--  SOLICITANTE  (médico derivante)
-- ============================================================

CREATE TABLE IF NOT EXISTS solicitante (
  id             SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(100)      NOT NULL DEFAULT '',
  porcentaje_sol TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  INDEX idx_solicitante_nombre (nombre(50))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Médicos solicitantes (que derivan pacientes)';

-- ============================================================
--  HORARIO  (uno por prestador, 1:1)
-- ============================================================

CREATE TABLE IF NOT EXISTS horario (
  id           BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  prestador_id SMALLINT UNSIGNED NOT NULL,
  -- Lunes
  lun_inicio_m TIME NOT NULL DEFAULT '00:00:00',
  lun_fin_m    TIME NOT NULL DEFAULT '00:00:00',
  lun_inicio_t TIME NOT NULL DEFAULT '00:00:00',
  lun_fin_t    TIME NOT NULL DEFAULT '00:00:00',
  lun_duracion TIME NOT NULL DEFAULT '00:00:00',
  -- Martes
  mar_inicio_m TIME NOT NULL DEFAULT '00:00:00',
  mar_fin_m    TIME NOT NULL DEFAULT '00:00:00',
  mar_inicio_t TIME NOT NULL DEFAULT '00:00:00',
  mar_fin_t    TIME NOT NULL DEFAULT '00:00:00',
  mar_duracion TIME NOT NULL DEFAULT '00:00:00',
  -- Miércoles
  mie_inicio_m TIME NOT NULL DEFAULT '00:00:00',
  mie_fin_m    TIME NOT NULL DEFAULT '00:00:00',
  mie_inicio_t TIME NOT NULL DEFAULT '00:00:00',
  mie_fin_t    TIME NOT NULL DEFAULT '00:00:00',
  mie_duracion TIME NOT NULL DEFAULT '00:00:00',
  -- Jueves
  jue_inicio_m TIME NOT NULL DEFAULT '00:00:00',
  jue_fin_m    TIME NOT NULL DEFAULT '00:00:00',
  jue_inicio_t TIME NOT NULL DEFAULT '00:00:00',
  jue_fin_t    TIME NOT NULL DEFAULT '00:00:00',
  jue_duracion TIME NOT NULL DEFAULT '00:00:00',
  -- Viernes
  vie_inicio_m TIME NOT NULL DEFAULT '00:00:00',
  vie_fin_m    TIME NOT NULL DEFAULT '00:00:00',
  vie_inicio_t TIME NOT NULL DEFAULT '00:00:00',
  vie_fin_t    TIME NOT NULL DEFAULT '00:00:00',
  vie_duracion TIME NOT NULL DEFAULT '00:00:00',
  -- Sábado
  sab_inicio_m TIME NOT NULL DEFAULT '00:00:00',
  sab_fin_m    TIME NOT NULL DEFAULT '00:00:00',
  sab_inicio_t TIME NOT NULL DEFAULT '00:00:00',
  sab_fin_t    TIME NOT NULL DEFAULT '00:00:00',
  sab_duracion TIME NOT NULL DEFAULT '00:00:00',
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  UNIQUE KEY uq_horario_prestador (prestador_id),
  CONSTRAINT fk_horario_prestador
    FOREIGN KEY (prestador_id) REFERENCES prestador (id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Horarios de atención por prestador';

-- ============================================================
--  USUARIO DEL SISTEMA
-- ============================================================

CREATE TABLE IF NOT EXISTS usuario (
  id               BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  username         VARCHAR(50)       NOT NULL,
  nombre           VARCHAR(100)      NOT NULL DEFAULT '',
  nivel            TINYINT UNSIGNED  NOT NULL DEFAULT 0
                   COMMENT '0=solo lectura, 5=operador, 9=admin',
  password_hash    VARCHAR(255)      NOT NULL DEFAULT ''
                   COMMENT 'Hash bcrypt/argon2id — nunca texto plano',
  tipo_usuario_id  TINYINT UNSIGNED  DEFAULT NULL,
  prestador_id     SMALLINT UNSIGNED DEFAULT NULL
                   COMMENT 'Si el usuario es un prestador',
  fecha_alta       DATE              DEFAULT NULL,
  fecha_baja       DATE              DEFAULT NULL,
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  UNIQUE KEY uq_usuario_username (username),
  INDEX idx_usuario_activo    (fecha_baja),
  INDEX idx_usuario_prestador (prestador_id),
  CONSTRAINT fk_usuario_tipo
    FOREIGN KEY (tipo_usuario_id) REFERENCES tipo_usuario (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_usuario_prestador
    FOREIGN KEY (prestador_id) REFERENCES prestador (id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Usuarios del sistema. username = login. Spring Security lo carga aquí.';

-- ============================================================
--  PACIENTE
-- ============================================================

CREATE TABLE IF NOT EXISTS paciente (
  id           BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  nombre       VARCHAR(150)      NOT NULL,
  domicilio    VARCHAR(100)      NOT NULL DEFAULT '',
  localidad_id INT UNSIGNED      NOT NULL DEFAULT 1,
  documento    BIGINT UNSIGNED   NOT NULL DEFAULT 0
               COMMENT 'DNI sin puntos',
  sexo_id      TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  fecha_nac    DATE              NOT NULL,
  observaciones TEXT             NOT NULL DEFAULT '',
  telefono1    VARCHAR(50)       NOT NULL DEFAULT '',
  telefono2    VARCHAR(50)       NOT NULL DEFAULT '',
  email        VARCHAR(100)      NOT NULL DEFAULT '',
  medico_cab_id SMALLINT UNSIGNED DEFAULT NULL
               COMMENT 'Médico de cabecera (prestador)',
  nro_interno  VARCHAR(10)       NOT NULL DEFAULT '',
  fecha_alta   DATE              NOT NULL,
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  INDEX idx_paciente_nombre    (nombre(60)),
  INDEX idx_paciente_documento (documento),
  INDEX idx_paciente_localidad (localidad_id),
  CONSTRAINT fk_paciente_localidad
    FOREIGN KEY (localidad_id) REFERENCES localidad (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_paciente_sexo
    FOREIGN KEY (sexo_id) REFERENCES sexo (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_paciente_medico_cab
    FOREIGN KEY (medico_cab_id) REFERENCES prestador (id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Padrón de pacientes';

-- ============================================================
--  AFILIACION  (paciente → obra_social, muchos a muchos)
--  Surrogate PK + unique constraint para JPA sin @EmbeddedId
-- ============================================================

CREATE TABLE IF NOT EXISTS afiliacion (
  id              BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  paciente_id     BIGINT UNSIGNED   NOT NULL,
  obra_social_id  SMALLINT UNSIGNED NOT NULL,
  plan_id         SMALLINT UNSIGNED NOT NULL,
  nro_afiliado    VARCHAR(25)       NOT NULL DEFAULT '',
  tipo_afiliado_id TINYINT UNSIGNED NOT NULL DEFAULT 1,
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  -- un paciente solo puede tener una afiliación por obra social activa
  UNIQUE KEY uq_afiliacion_paciente_os (paciente_id, obra_social_id),
  INDEX idx_afiliacion_obra_social (obra_social_id),
  INDEX idx_afiliacion_plan        (plan_id),
  CONSTRAINT fk_afiliacion_paciente
    FOREIGN KEY (paciente_id) REFERENCES paciente (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_afiliacion_obra_social
    FOREIGN KEY (obra_social_id) REFERENCES obra_social (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_afiliacion_plan
    FOREIGN KEY (plan_id) REFERENCES plan (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_afiliacion_tipo
    FOREIGN KEY (tipo_afiliado_id) REFERENCES tipo_afiliado (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Afiliaciones de pacientes a obras sociales';

-- ============================================================
--  TURNO
--  • Sin particionado → JPA puede usar @Id normal
--  • Archivo histórico en tabla separada (ver abajo)
-- ============================================================

CREATE TABLE IF NOT EXISTS turno (
  id             BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  consultorio_id TINYINT UNSIGNED  NOT NULL DEFAULT 1,
  prestador_id   SMALLINT UNSIGNED NOT NULL,
  fecha          DATE              NOT NULL,
  hora           TIME              NOT NULL,
  observaciones  VARCHAR(200)      NOT NULL DEFAULT '',
  estado_id      TINYINT UNSIGNED  NOT NULL,
  paciente_id    BIGINT UNSIGNED   DEFAULT NULL
                 COMMENT 'NULL = turno libre',
  obra_social_id SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  fijo           BOOLEAN           NOT NULL DEFAULT FALSE,
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  INDEX idx_turno_prestador_fecha (prestador_id, fecha),
  INDEX idx_turno_paciente        (paciente_id),
  INDEX idx_turno_estado          (estado_id),
  INDEX idx_turno_fecha           (fecha),
  CONSTRAINT fk_turno_prestador
    FOREIGN KEY (prestador_id) REFERENCES prestador (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_turno_estado
    FOREIGN KEY (estado_id) REFERENCES estado_turno (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_turno_paciente
    FOREIGN KEY (paciente_id) REFERENCES paciente (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Agenda de turnos activa. Turnos viejos → turno_archivo.';

-- Tabla de archivo para turnos históricos (>= 2 años atrás).
-- Spring no gestiona esto con JPA normal; se llena desde un job @Scheduled.
CREATE TABLE IF NOT EXISTS turno_archivo LIKE turno;
ALTER TABLE turno_archivo COMMENT = 'Archivo histórico de turnos (solo lectura desde Spring)';

-- ============================================================
--  LOG DE CONFIRMACIONES DE TURNO
-- ============================================================

CREATE TABLE IF NOT EXISTS turno_confirmacion (
  id           BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  paciente_id  BIGINT UNSIGNED   NOT NULL,
  prestador_id SMALLINT UNSIGNED NOT NULL,
  fecha_turno  DATE              NOT NULL,
  hora_turno   TIME              NOT NULL,
  observaciones VARCHAR(200)     NOT NULL DEFAULT '',
  visto_en     DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_turno_conf_paciente  (paciente_id),
  INDEX idx_turno_conf_prestador (prestador_id, fecha_turno),
  CONSTRAINT fk_turno_conf_paciente
    FOREIGN KEY (paciente_id) REFERENCES paciente (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_turno_conf_prestador
    FOREIGN KEY (prestador_id) REFERENCES prestador (id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Log de visualizaciones/confirmaciones de turno';

-- ============================================================
--  RECEPCION  (check-in del paciente el día del turno)
-- ============================================================

CREATE TABLE IF NOT EXISTS recepcion (
  id             BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  consultorio_id TINYINT UNSIGNED  NOT NULL DEFAULT 1,
  nro_asignado   INT UNSIGNED      NOT NULL DEFAULT 0,
  paciente_id    BIGINT UNSIGNED   NOT NULL,
  prestador_id   SMALLINT UNSIGNED NOT NULL,
  fecha_realiza  DATE              DEFAULT NULL,
  coseguro       DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  pago_efectivo  DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  tipo_pago_id   TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  INDEX idx_recepcion_paciente  (paciente_id),
  INDEX idx_recepcion_prestador (prestador_id),
  INDEX idx_recepcion_fecha     (fecha_realiza),
  CONSTRAINT fk_recepcion_paciente
    FOREIGN KEY (paciente_id) REFERENCES paciente (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_recepcion_prestador
    FOREIGN KEY (prestador_id) REFERENCES prestador (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Recepción / check-in del paciente';

-- ============================================================
--  ORDEN DE PRESTACION  (fordenes + fordenes_h unificadas)
-- ============================================================

CREATE TABLE IF NOT EXISTS orden_prestacion (
  id              BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  consultorio_id  TINYINT UNSIGNED  NOT NULL DEFAULT 1,
  nro_asignado    INT UNSIGNED      NOT NULL DEFAULT 0,
  paciente_id     BIGINT UNSIGNED   NOT NULL,
  obra_social_id  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  nro_afiliado    VARCHAR(30)       NOT NULL DEFAULT '',
  nro_bono        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  fecha_realiza   DATE              DEFAULT NULL,
  codigo_nomencla VARCHAR(10)       NOT NULL DEFAULT '',
  solicitante_id  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  porc_solicitante TINYINT UNSIGNED NOT NULL DEFAULT 0,
  prestador_id    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  porc_efector    TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  importe         DECIMAL(12,2)     NOT NULL DEFAULT 0.00,
  honorario       DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  gasto           DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  iva             DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  importe_total   DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  coseguro        DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  pago_efectivo   DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  tipo_pago_id    TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  tipo_afiliado_id TINYINT UNSIGNED NOT NULL DEFAULT 0,
  plan_id         SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  origen_id       TINYINT UNSIGNED  NOT NULL DEFAULT 1,
  periodo_id      MEDIUMINT UNSIGNED NOT NULL DEFAULT 0,
  marcado         BOOLEAN           NOT NULL DEFAULT FALSE,
  generado        BOOLEAN           NOT NULL DEFAULT FALSE,
  es_historico    BOOLEAN           NOT NULL DEFAULT FALSE
                  COMMENT 'TRUE = antes en fordenes_h',
  marcado_por     VARCHAR(50)       NOT NULL DEFAULT '',
  fecha_marca     DATETIME          NOT NULL DEFAULT '1900-01-01 00:00:00',
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  INDEX idx_orden_paciente   (paciente_id),
  INDEX idx_orden_prestador  (prestador_id),
  INDEX idx_orden_obra_social (obra_social_id),
  INDEX idx_orden_periodo    (periodo_id),
  INDEX idx_orden_fecha      (fecha_realiza),
  INDEX idx_orden_marcado    (marcado),
  INDEX idx_orden_historico  (es_historico),
  CONSTRAINT fk_orden_paciente
    FOREIGN KEY (paciente_id) REFERENCES paciente (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_orden_prestador
    FOREIGN KEY (prestador_id) REFERENCES prestador (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_orden_obra_social
    FOREIGN KEY (obra_social_id) REFERENCES obra_social (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_orden_tipo_afiliado
    FOREIGN KEY (tipo_afiliado_id) REFERENCES tipo_afiliado (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Órdenes de prestación (activas + históricas)';

-- ============================================================
--  CAJA
-- ============================================================

CREATE TABLE IF NOT EXISTS caja (
  id              BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  consultorio_id  TINYINT UNSIGNED  NOT NULL DEFAULT 1,
  nro_asignado    INT UNSIGNED      NOT NULL DEFAULT 0,
  paciente_id     BIGINT UNSIGNED   NOT NULL,
  obra_social_id  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  nro_bono        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  fecha           DATETIME          DEFAULT NULL,
  prestador_id    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  coseguro        DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  pago_efectivo   DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  en_deposito     BOOLEAN           NOT NULL DEFAULT FALSE,
  observaciones   TEXT              NOT NULL DEFAULT '',
  especialidad_id SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  INDEX idx_caja_paciente   (paciente_id),
  INDEX idx_caja_prestador  (prestador_id),
  INDEX idx_caja_fecha      (fecha),
  INDEX idx_caja_deposito   (en_deposito),
  CONSTRAINT fk_caja_paciente
    FOREIGN KEY (paciente_id) REFERENCES paciente (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_caja_prestador
    FOREIGN KEY (prestador_id) REFERENCES prestador (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_caja_especialidad
    FOREIGN KEY (especialidad_id) REFERENCES especialidad (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Movimientos de caja (cobros en el mostrador)';

-- ============================================================
--  DEPOSITO / RECUPERO
-- ============================================================

CREATE TABLE IF NOT EXISTS deposito (
  id               BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  consultorio_id   TINYINT UNSIGNED  NOT NULL DEFAULT 1,
  nro_asignado     INT UNSIGNED      NOT NULL DEFAULT 0,
  paciente_id      BIGINT UNSIGNED   NOT NULL,
  fecha            DATETIME          NOT NULL,
  prestador_id     SMALLINT UNSIGNED NOT NULL,
  importe          DECIMAL(12,2)     NOT NULL DEFAULT 0.00,
  tipo_recupero_id TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  fecha_recupero   DATETIME          NOT NULL DEFAULT '1900-01-01 00:00:00',
  recuperado_por   VARCHAR(50)       NOT NULL DEFAULT '',
  nro_recupero     INT UNSIGNED      NOT NULL DEFAULT 0,
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  INDEX idx_deposito_paciente  (paciente_id),
  INDEX idx_deposito_prestador (prestador_id),
  INDEX idx_deposito_fecha     (fecha),
  CONSTRAINT fk_deposito_paciente
    FOREIGN KEY (paciente_id) REFERENCES paciente (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_deposito_prestador
    FOREIGN KEY (prestador_id) REFERENCES prestador (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_deposito_tipo_recupero
    FOREIGN KEY (tipo_recupero_id) REFERENCES tipo_recupero (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Depósitos y recuperos de caja';

-- ============================================================
--  RESUMEN FACTURADO  (liquidación a obras sociales)
-- ============================================================

CREATE TABLE IF NOT EXISTS resumen_facturado (
  id               BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  consultorio_id   TINYINT UNSIGNED  NOT NULL DEFAULT 1,
  nro_asignado     INT UNSIGNED      NOT NULL DEFAULT 0,
  paciente_id      BIGINT UNSIGNED   NOT NULL,
  obra_social_id   SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  nro_afiliado     VARCHAR(30)       NOT NULL DEFAULT '',
  nro_bono         SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  fecha_realiza    DATE              DEFAULT NULL,
  especialidad_id  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  codigo_nomencla  VARCHAR(10)       NOT NULL DEFAULT '',
  solicitante_id   SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  porc_solicitante TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  prestador_id     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  porc_efector     TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  importe          DECIMAL(12,2)     NOT NULL DEFAULT 0.00,
  honorario        DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  gasto            DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  iva              DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  importe_total    DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  coseguro         DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  tipo_pago_id     TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  tipo_afiliado_id TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  plan_id          SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  periodo_id       MEDIUMINT UNSIGNED NOT NULL DEFAULT 0,
  origen_id        TINYINT UNSIGNED  NOT NULL DEFAULT 1,
  tag              TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  modificado_por   VARCHAR(50)       NOT NULL DEFAULT '',
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  INDEX idx_resfact_paciente    (paciente_id),
  INDEX idx_resfact_obra_social (obra_social_id),
  INDEX idx_resfact_prestador   (prestador_id),
  INDEX idx_resfact_periodo     (periodo_id),
  INDEX idx_resfact_fecha       (fecha_realiza),
  CONSTRAINT fk_resfact_paciente
    FOREIGN KEY (paciente_id) REFERENCES paciente (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_resfact_obra_social
    FOREIGN KEY (obra_social_id) REFERENCES obra_social (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_resfact_prestador
    FOREIGN KEY (prestador_id) REFERENCES prestador (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_resfact_especialidad
    FOREIGN KEY (especialidad_id) REFERENCES especialidad (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Resumen de prestaciones facturadas (liquidación)';

-- ============================================================
--  INFORME DE ESTUDIO
-- ============================================================

CREATE TABLE IF NOT EXISTS informe_estudio (
  id              BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  nro_asignado    INT UNSIGNED      NOT NULL DEFAULT 0,
  nro_informe     INT UNSIGNED      NOT NULL DEFAULT 0,
  paciente_id     BIGINT UNSIGNED   NOT NULL,
  prestador_id    SMALLINT UNSIGNED NOT NULL,
  codigo_nomencla VARCHAR(20)       NOT NULL DEFAULT '',
  texto           TEXT              NOT NULL DEFAULT '',
  fecha_realiza   DATE              NOT NULL,
  fecha_informe   DATE              NOT NULL,
  enviado         BOOLEAN           NOT NULL DEFAULT FALSE,
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  INDEX idx_informe_paciente  (paciente_id),
  INDEX idx_informe_prestador (prestador_id),
  INDEX idx_informe_fecha     (fecha_realiza),
  CONSTRAINT fk_informe_paciente
    FOREIGN KEY (paciente_id) REFERENCES paciente (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_informe_prestador
    FOREIGN KEY (prestador_id) REFERENCES prestador (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Informes y resultados de estudios';

-- ============================================================
--  PLANTILLA DE INFORME  (pre_informes)
-- ============================================================

CREATE TABLE IF NOT EXISTS plantilla_informe (
  id         SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  titulo     VARCHAR(200)      NOT NULL DEFAULT '',
  texto      TEXT              NOT NULL DEFAULT '',
  -- auditoría
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by  VARCHAR(50)  NOT NULL DEFAULT '',
  updated_by  VARCHAR(50)  NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  FULLTEXT KEY ft_plantilla (titulo, texto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Plantillas reutilizables para informes';

-- ============================================================
--  MENSAJERIA INTERNA
-- ============================================================

CREATE TABLE IF NOT EXISTS mensaje (
  id          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  tipo_id     TINYINT UNSIGNED NOT NULL DEFAULT 0,
  destinatario VARCHAR(50)     NOT NULL,
  remitente    VARCHAR(50)     NOT NULL,
  asunto       VARCHAR(250)    NOT NULL DEFAULT '',
  texto        TEXT            NOT NULL DEFAULT '',
  leido        BOOLEAN         NOT NULL DEFAULT FALSE,
  leido_en     DATETIME        DEFAULT NULL,
  enviado_en   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_mensaje_destinatario (destinatario),
  INDEX idx_mensaje_remitente    (remitente),
  INDEX idx_mensaje_leido        (leido)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Mensajería interna entre usuarios del sistema';

-- ============================================================
--  METADATOS DE ARCHIVOS DE INFORMES
-- ============================================================

CREATE TABLE IF NOT EXISTS archivo_informe (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre_archivo VARCHAR(100) DEFAULT NULL,
  solicitante    VARCHAR(100) DEFAULT NULL,
  efector        VARCHAR(100) DEFAULT NULL,
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Metadatos de archivos de informes generados';

-- ============================================================
--  LOG DEL SISTEMA
-- ============================================================

CREATE TABLE IF NOT EXISTS log_sistema (
  id       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario  VARCHAR(50)     NOT NULL,
  fecha    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  accion   VARCHAR(500)    NOT NULL,
  PRIMARY KEY (id),
  INDEX idx_log_usuario (usuario),
  INDEX idx_log_fecha   (fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Log de acciones de usuarios en el sistema';

-- ============================================================
--  RECORDATORIOS
-- ============================================================

CREATE TABLE IF NOT EXISTS recordatorio (
  id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  texto   TEXT         NOT NULL,
  activo  BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Recordatorios y avisos del sistema';

-- ============================================================
--  URL SHORTENER  (envío de turnos por WhatsApp/SMS)
-- ============================================================

CREATE TABLE IF NOT EXISTS url_corta (
  id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  codigo      VARCHAR(20)   NOT NULL COMMENT 'El código corto único',
  url_destino VARCHAR(1000) NOT NULL,
  clics       INT UNSIGNED  NOT NULL DEFAULT 0,
  created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_url_corta_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Acortador de URLs';

-- ============================================================
--  CONFIGURACION GLOBAL DE LA EMPRESA
--  (modelo clave-valor — Spring puede leerlo con un @Repository)
-- ============================================================

CREATE TABLE IF NOT EXISTS configuracion (
  clave       VARCHAR(60)  NOT NULL,
  valor       VARCHAR(500) NOT NULL DEFAULT '',
  descripcion VARCHAR(200) DEFAULT NULL,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (clave)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Configuración global (razón social, domicilio, teléfono, etc.)';

INSERT IGNORE INTO configuracion (clave, valor, descripcion) VALUES
  ('empresa.nombre',    '', 'Razón social'),
  ('empresa.domicilio', '', 'Domicilio'),
  ('empresa.telefono',  '', 'Teléfono'),
  ('empresa.email',     '', 'Email'),
  ('sistema.nro_asignado_actual', '0', 'Número de orden correlativo'),
  ('sistema.id_informe_actual',   '0', 'Último ID de informe generado');

-- ============================================================
--  STAGING DE IMPORTACION  (reemplaza tmp_fordenes)
--  Sin FKs intencionalmente: es una tabla de ingesta temporal
--  gestionada por un job de Spring Batch
-- ============================================================

CREATE TABLE IF NOT EXISTS staging_orden (
  id              BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  consultorio_id  TINYINT UNSIGNED NOT NULL DEFAULT 1,
  nro_asignado    INT UNSIGNED     NOT NULL DEFAULT 0,
  paciente_id     BIGINT UNSIGNED  NOT NULL DEFAULT 0,
  nombre_paciente VARCHAR(150)     NOT NULL DEFAULT '',
  documento       BIGINT UNSIGNED  NOT NULL DEFAULT 0,
  obra_social_id  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  nro_afiliado    VARCHAR(30)      NOT NULL DEFAULT '',
  nro_bono        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  fecha_realiza   DATE             DEFAULT NULL,
  especialidad_id SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  codigo_nomencla VARCHAR(10)      NOT NULL DEFAULT '',
  solicitante_id  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  porc_solicitante TINYINT UNSIGNED NOT NULL DEFAULT 0,
  prestador_id    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  porc_efector    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  importe         DECIMAL(12,2)    NOT NULL DEFAULT 0.00,
  honorario       DECIMAL(10,2)    NOT NULL DEFAULT 0.00,
  gasto           DECIMAL(10,2)    NOT NULL DEFAULT 0.00,
  iva             DECIMAL(10,2)    NOT NULL DEFAULT 0.00,
  importe_total   DECIMAL(10,2)    NOT NULL DEFAULT 0.00,
  coseguro        DECIMAL(10,2)    NOT NULL DEFAULT 0.00,
  tipo_pago_id    TINYINT UNSIGNED NOT NULL DEFAULT 0,
  tipo_afiliado_id TINYINT UNSIGNED NOT NULL DEFAULT 0,
  plan_id         SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  periodo_id      MEDIUMINT UNSIGNED NOT NULL DEFAULT 0,
  origen_id       TINYINT UNSIGNED NOT NULL DEFAULT 1,
  tag             TINYINT UNSIGNED NOT NULL DEFAULT 0,
  modificado_por  VARCHAR(50)      NOT NULL DEFAULT '',
  importado_por   VARCHAR(50)      NOT NULL DEFAULT '',
  importado_en    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_staging_paciente (paciente_id),
  INDEX idx_staging_periodo  (periodo_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tabla staging para Spring Batch — importación de órdenes. Se vacía al confirmar.';

-- ============================================================
SET foreign_key_checks = 1;
-- FIN DEL SCRIPT
-- ============================================================
