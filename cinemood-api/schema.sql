-- =====================================================================
-- CineMood · Esquema MySQL 8 (utf8mb4)
-- Basado en los modelos de la app Flutter (lib/models) y el SRS v1.0.
-- Ejecutar: mysql -u USUARIO -p < schema.sql
-- =====================================================================
CREATE DATABASE IF NOT EXISTS cinemood CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE cinemood;

-- ---------- Catálogos pequeños ----------
CREATE TABLE generos (
  id      TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  nombre  VARCHAR(40) NOT NULL UNIQUE
);

-- codigo = nombre del enum EstadoAnimo en Flutter (feliz, conMiedo, ...)
CREATE TABLE estados_animo (
  id        TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  codigo    VARCHAR(20) NOT NULL UNIQUE,
  etiqueta  VARCHAR(30) NOT NULL,
  emoji     VARCHAR(8)  NOT NULL
);

-- ---------- Usuarios ----------
CREATE TABLE usuarios (
  id               INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  nombre           VARCHAR(100) NOT NULL,
  edad             TINYINT UNSIGNED NOT NULL,
  correo           VARCHAR(150) NOT NULL UNIQUE,
  contrasena_hash  VARCHAR(255) NOT NULL,            -- bcrypt, nunca la contraseña en claro
  rol              ENUM('usuario','admin') NOT NULL DEFAULT 'usuario',
  activo           BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Preferencias (RF-004, RF-005, RF-014): una fila por usuario
CREATE TABLE preferencias_usuario (
  usuario_id        INT UNSIGNED PRIMARY KEY,
  tipo              ENUM('pelicula','serie') NOT NULL DEFAULT 'pelicula',
  rango_tiempo      ENUM('menos30','de30a60','de60a120','mas120') NULL,
  estado_animo_id   TINYINT UNSIGNED NULL,           -- último mood elegido
  FOREIGN KEY (usuario_id)      REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (estado_animo_id) REFERENCES estados_animo(id)
);

CREATE TABLE preferencias_generos (
  usuario_id  INT UNSIGNED NOT NULL,
  genero_id   TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (usuario_id, genero_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (genero_id)  REFERENCES generos(id)
);

-- ---------- Catálogo ----------
CREATE TABLE contenidos (
  id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  titulo        VARCHAR(200) NOT NULL,
  tipo          ENUM('pelicula','serie') NOT NULL,
  genero_id     TINYINT UNSIGNED NOT NULL,
  anio          SMALLINT UNSIGNED NOT NULL,
  duracion_min  SMALLINT UNSIGNED NOT NULL,
  valoracion    DECIMAL(2,1) NOT NULL CHECK (valoracion BETWEEN 0 AND 5),
  sinopsis      TEXT NOT NULL,
  imagen_url    VARCHAR(300) NULL,
  FOREIGN KEY (genero_id) REFERENCES generos(id),
  INDEX idx_tipo_genero (tipo, genero_id)
);

-- Cuánto encaja cada contenido con cada mood (0.00 a 1.00): reemplaza el Map afinidadAnimo
CREATE TABLE afinidad_animo (
  contenido_id     INT UNSIGNED NOT NULL,
  estado_animo_id  TINYINT UNSIGNED NOT NULL,
  afinidad         DECIMAL(3,2) NOT NULL CHECK (afinidad BETWEEN 0 AND 1),
  PRIMARY KEY (contenido_id, estado_animo_id),
  FOREIGN KEY (contenido_id)    REFERENCES contenidos(id) ON DELETE CASCADE,
  FOREIGN KEY (estado_animo_id) REFERENCES estados_animo(id)
);

-- ---------- Interacción del usuario ----------
CREATE TABLE mi_lista (
  usuario_id    INT UNSIGNED NOT NULL,
  contenido_id  INT UNSIGNED NOT NULL,
  agregado_en   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (usuario_id, contenido_id),
  FOREIGN KEY (usuario_id)   REFERENCES usuarios(id)   ON DELETE CASCADE,
  FOREIGN KEY (contenido_id) REFERENCES contenidos(id) ON DELETE CASCADE
);

-- Historial (RF-013): la app lo reinserta al volver a ver algo -> se actualiza visto_en
CREATE TABLE historial (
  usuario_id    INT UNSIGNED NOT NULL,
  contenido_id  INT UNSIGNED NOT NULL,
  visto_en      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (usuario_id, contenido_id),
  FOREIGN KEY (usuario_id)   REFERENCES usuarios(id)   ON DELETE CASCADE,
  FOREIGN KEY (contenido_id) REFERENCES contenidos(id) ON DELETE CASCADE,
  INDEX idx_historial_fecha (usuario_id, visto_en)
);

-- Valoración (RF-011): puntaje 1-5 y/o interés / desinterés (una fila por usuario y contenido)
CREATE TABLE valoraciones (
  usuario_id    INT UNSIGNED NOT NULL,
  contenido_id  INT UNSIGNED NOT NULL,
  puntaje       TINYINT UNSIGNED NULL CHECK (puntaje BETWEEN 1 AND 5),
  interes       ENUM('interesa','no_interesa') NULL,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (usuario_id, contenido_id),
  FOREIGN KEY (usuario_id)   REFERENCES usuarios(id)   ON DELETE CASCADE,
  FOREIGN KEY (contenido_id) REFERENCES contenidos(id) ON DELETE CASCADE
);

-- =====================================================================
-- Datos iniciales (tomados de lib/data/catalogo_data.dart)
-- =====================================================================

INSERT INTO generos (id, nombre) VALUES
  (1, 'Acción'),
  (2, 'Comedia'),
  (3, 'Drama'),
  (4, 'Terror'),
  (5, 'Romance'),
  (6, 'Ciencia ficción');

INSERT INTO estados_animo (id, codigo, etiqueta, emoji) VALUES
  (1, 'feliz', 'Feliz', '😊'),
  (2, 'tranquilo', 'Tranquilo', '😌'),
  (3, 'emocionado', 'Emocionado', '🤩'),
  (4, 'nostalgico', 'Nostálgico', '🌙'),
  (5, 'enojado', 'Enojado', '😠'),
  (6, 'triste', 'Triste', '😢'),
  (7, 'curioso', 'Curioso', '🧐'),
  (8, 'conMiedo', 'Con miedo', '😨');

INSERT INTO contenidos (id, titulo, tipo, genero_id, anio, duracion_min, valoracion, sinopsis) VALUES
  (1, 'Interstellar', 'pelicula', 6, 2014, 169, 4.8, 'Un equipo de exploradores viaja por un agujero de gusano en busca de un nuevo hogar para la humanidad.'),
  (2, 'La La Land', 'pelicula', 5, 2016, 128, 4.5, 'Una actriz y un pianista persiguen sus sueños en Los Ángeles mientras su amor es puesto a prueba.'),
  (3, 'Mad Max: Fury Road', 'pelicula', 1, 2015, 120, 4.6, 'En un desierto postapocalíptico, una rebelde huye junto a un grupo de mujeres de un tirano.'),
  (4, 'Superbad', 'pelicula', 2, 2007, 113, 4.2, 'Dos amigos intentan vivir una última gran noche antes de terminar la secundaria.'),
  (5, 'El Conjuro', 'pelicula', 4, 2013, 112, 4.3, 'Dos investigadores paranormales ayudan a una familia atormentada por una presencia oscura.'),
  (6, 'Whiplash', 'pelicula', 3, 2014, 107, 4.6, 'Un joven baterista busca la perfección bajo las órdenes de un instructor despiadado.'),
  (7, 'Stranger Things', 'serie', 6, 2016, 50, 4.7, 'Un grupo de niños enfrenta fuerzas sobrenaturales en un pequeño pueblo de los años 80.'),
  (8, 'The Office', 'serie', 2, 2005, 22, 4.6, 'La rutina de una oficina de papel contada como un falso documental.'),
  (9, 'Breaking Bad', 'serie', 3, 2008, 47, 4.9, 'Un profesor de química con cáncer se adentra en el mundo del narcotráfico.'),
  (10, 'Coco', 'pelicula', 2, 2017, 105, 4.7, 'Un niño viaja a la Tierra de los Muertos para descubrir la historia de su familia.');

INSERT INTO afinidad_animo (contenido_id, estado_animo_id, afinidad) VALUES
  (1, 7, 0.95),
  (1, 3, 0.8),
  (1, 4, 0.7),
  (1, 6, 0.6),
  (1, 2, 0.4),
  (2, 1, 0.85),
  (2, 4, 0.95),
  (2, 2, 0.7),
  (2, 6, 0.65),
  (3, 5, 0.95),
  (3, 3, 0.95),
  (3, 7, 0.4),
  (4, 1, 0.95),
  (4, 4, 0.6),
  (4, 2, 0.5),
  (5, 8, 0.95),
  (5, 3, 0.7),
  (5, 7, 0.5),
  (5, 5, 0.3),
  (6, 5, 0.8),
  (6, 3, 0.75),
  (6, 6, 0.5),
  (6, 7, 0.5),
  (7, 4, 0.95),
  (7, 7, 0.85),
  (7, 8, 0.7),
  (7, 3, 0.8),
  (8, 1, 0.9),
  (8, 2, 0.85),
  (8, 6, 0.6),
  (8, 4, 0.7),
  (9, 5, 0.85),
  (9, 7, 0.8),
  (9, 3, 0.8),
  (9, 6, 0.5),
  (10, 6, 0.9),
  (10, 4, 0.9),
  (10, 1, 0.8),
  (10, 2, 0.6);

-- Primer administrador: crea el hash con bcrypt desde la API (no pongas contraseñas en claro aquí).
-- INSERT INTO usuarios (nombre, edad, correo, contrasena_hash, rol) VALUES ('Admin', 30, 'admin@cinemood.app', '<hash_bcrypt>', 'admin');
