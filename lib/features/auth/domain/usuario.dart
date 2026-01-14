class Usuario {
  final String id;
  final String email;
  final String? nome;

  Usuario({
    required this.id,
    required this.email,
    this.nome,
  });

  factory Usuario.fromFirebase(dynamic user) {
    return Usuario(
      id: user.uid,
      email: user.email ?? '',
      nome: user.displayName,
    );
  }
}