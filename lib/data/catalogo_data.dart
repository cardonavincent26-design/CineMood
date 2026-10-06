import '../models/contenido.dart';

/// Catálogo de ejemplo (mock). Más adelante lo reemplaza la API (FastAPI).
const generosDisponibles = [
  'Acción',
  'Comedia',
  'Drama',
  'Terror',
  'Romance',
  'Ciencia ficción',
];

const catalogoInicial = <Contenido>[
  Contenido(
    id: 1, titulo: 'Interstellar', tipo: TipoContenido.pelicula, genero: 'Ciencia ficción',
    anio: 2014, duracionMin: 169, valoracion: 4.8,
    sinopsis: 'Un equipo de exploradores viaja por un agujero de gusano en busca de un nuevo hogar para la humanidad.',
    afinidadAnimo: {'curioso': 0.95, 'emocionado': 0.8, 'nostalgico': 0.7, 'triste': 0.6, 'tranquilo': 0.4},
  ),
  Contenido(
    id: 2, titulo: 'La La Land', tipo: TipoContenido.pelicula, genero: 'Romance',
    anio: 2016, duracionMin: 128, valoracion: 4.5,
    sinopsis: 'Una actriz y un pianista persiguen sus sueños en Los Ángeles mientras su amor es puesto a prueba.',
    afinidadAnimo: {'feliz': 0.85, 'nostalgico': 0.95, 'tranquilo': 0.7, 'triste': 0.65},
  ),
  Contenido(
    id: 3, titulo: 'Mad Max: Fury Road', tipo: TipoContenido.pelicula, genero: 'Acción',
    anio: 2015, duracionMin: 120, valoracion: 4.6,
    sinopsis: 'En un desierto postapocalíptico, una rebelde huye junto a un grupo de mujeres de un tirano.',
    afinidadAnimo: {'enojado': 0.95, 'emocionado': 0.95, 'curioso': 0.4},
  ),
  Contenido(
    id: 4, titulo: 'Superbad', tipo: TipoContenido.pelicula, genero: 'Comedia',
    anio: 2007, duracionMin: 113, valoracion: 4.2,
    sinopsis: 'Dos amigos intentan vivir una última gran noche antes de terminar la secundaria.',
    afinidadAnimo: {'feliz': 0.95, 'nostalgico': 0.6, 'tranquilo': 0.5},
  ),
  Contenido(
    id: 5, titulo: 'El Conjuro', tipo: TipoContenido.pelicula, genero: 'Terror',
    anio: 2013, duracionMin: 112, valoracion: 4.3,
    sinopsis: 'Dos investigadores paranormales ayudan a una familia atormentada por una presencia oscura.',
    afinidadAnimo: {'conMiedo': 0.95, 'emocionado': 0.7, 'curioso': 0.5, 'enojado': 0.3},
  ),
  Contenido(
    id: 6, titulo: 'Whiplash', tipo: TipoContenido.pelicula, genero: 'Drama',
    anio: 2014, duracionMin: 107, valoracion: 4.6,
    sinopsis: 'Un joven baterista busca la perfección bajo las órdenes de un instructor despiadado.',
    afinidadAnimo: {'enojado': 0.8, 'emocionado': 0.75, 'triste': 0.5, 'curioso': 0.5},
  ),
  Contenido(
    id: 7, titulo: 'Stranger Things', tipo: TipoContenido.serie, genero: 'Ciencia ficción',
    anio: 2016, duracionMin: 50, valoracion: 4.7,
    sinopsis: 'Un grupo de niños enfrenta fuerzas sobrenaturales en un pequeño pueblo de los años 80.',
    afinidadAnimo: {'nostalgico': 0.95, 'curioso': 0.85, 'conMiedo': 0.7, 'emocionado': 0.8},
  ),
  Contenido(
    id: 8, titulo: 'The Office', tipo: TipoContenido.serie, genero: 'Comedia',
    anio: 2005, duracionMin: 22, valoracion: 4.6,
    sinopsis: 'La rutina de una oficina de papel contada como un falso documental.',
    afinidadAnimo: {'feliz': 0.9, 'tranquilo': 0.85, 'triste': 0.6, 'nostalgico': 0.7},
  ),
  Contenido(
    id: 9, titulo: 'Breaking Bad', tipo: TipoContenido.serie, genero: 'Drama',
    anio: 2008, duracionMin: 47, valoracion: 4.9,
    sinopsis: 'Un profesor de química con cáncer se adentra en el mundo del narcotráfico.',
    afinidadAnimo: {'enojado': 0.85, 'curioso': 0.8, 'emocionado': 0.8, 'triste': 0.5},
  ),
  Contenido(
    id: 10, titulo: 'Coco', tipo: TipoContenido.pelicula, genero: 'Comedia',
    anio: 2017, duracionMin: 105, valoracion: 4.7,
    sinopsis: 'Un niño viaja a la Tierra de los Muertos para descubrir la historia de su familia.',
    afinidadAnimo: {'triste': 0.9, 'nostalgico': 0.9, 'feliz': 0.8, 'tranquilo': 0.6},
  ),
];
