/// Estados de ánimo disponibles (el criterio más importante de la recomendación).
enum EstadoAnimo {
  feliz('Feliz', '😊'),
  tranquilo('Tranquilo', '😌'),
  emocionado('Emocionado', '🤩'),
  nostalgico('Nostálgico', '🌙'),
  enojado('Enojado', '😠'),
  triste('Triste', '😢'),
  curioso('Curioso', '🧐'),
  conMiedo('Con miedo', '😨');

  final String etiqueta;
  final String emoji;
  const EstadoAnimo(this.etiqueta, this.emoji);
}
