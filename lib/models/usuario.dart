class Usuario {
  final String nombre;
  final int edad;
  final String correo;

  const Usuario({required this.nombre, required this.edad, required this.correo});

  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(
        nombre: j['nombre'] as String,
        edad: j['edad'] as int,
        correo: j['correo'] as String,
      );

  Map<String, dynamic> toJson() => {'nombre': nombre, 'edad': edad, 'correo': correo};
}
