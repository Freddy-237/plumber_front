/// Énumération des types d'utilisateurs
enum UserType { client, plumber }

/// Modèle utilisateur simplifié pour l'authentification
class User {
  /// Identifiant unique de l'utilisateur
  final String id;

  /// Nom complet de l'utilisateur
  final String name;

  /// Numéro de téléphone (utilisé pour l'authentification)
  final String phone;

  /// Type d'utilisateur (client ou plombier)
  final UserType role;

  /// Token d'authentification
  final String token;

  /// Date de création du compte
  final DateTime created_at;

  /// Ville (optionnel)
  final String? city;

  /// Quartier (optionnel)
  final String? district;

  /// Champs spécifiques aux plombiers
  /// Numéro CNI (plombier)
  final String? cni_number;

  /// URL de la photo CNI (plombier)
  final String? cni_image;

  /// URL de la photo de profil (optionnel)
  final String? profile_picture;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.token,
    required this.created_at,
    this.city,
    this.district,
    this.cni_number,
    this.cni_image,
    this.profile_picture,
  });

  /// Crée une copie de l'utilisateur avec les champs modifiés
  User copyWith({
    String? id,
    String? name,
    String? phone,
    UserType? role,
    String? token,
    DateTime? created_at,
    String? city,
    String? district,
    String? cni_number,
    String? cni_image,
    String? profile_picture,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
      created_at: created_at ?? this.created_at,
      city: city ?? this.city,
      district: district ?? this.district,
      cni_number: cni_number ?? this.cni_number,
      cni_image: cni_image ?? this.cni_image,
      profile_picture: profile_picture ?? this.profile_picture,
    );
  }

  /// Convertit le modèle en JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role == UserType.plumber ? 'plombier' : 'client',
        'token': token,
        'created_at': created_at.toIso8601String(),
        if (city != null) 'city': city,
        if (district != null) 'district': district,
        if (cni_number != null) 'cni_number': cni_number,
        if (cni_image != null) 'cni_image': cni_image,
        if (profile_picture != null) 'profile_picture': profile_picture,
      };

  /// Crée un User à partir du JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: json['role'] == 'plombier' ? UserType.plumber : UserType.client,
      token: json['token'] as String? ?? '',
      created_at: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      city: json['city'] as String?,
      district: json['district'] as String?,
      cni_number: json['cni_number'] as String?,
      cni_image: json['cni_image'] as String?,
      profile_picture: json['profile_picture'] as String?,
    );
  }

  @override
  String toString() => 'User(id: $id, phone: $phone, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          phone == other.phone;

  @override
  int get hashCode => id.hashCode ^ phone.hashCode;
}
