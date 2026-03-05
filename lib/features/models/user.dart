class User {
  final String id;
  final String email;
  final String password;
  final String name;
  final String imageUrl;
  final bool isDarkMode;
  final String? title;
  final String? about;
  final String? phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.imageUrl,
    required this.isDarkMode,
    this.title,
    this.about,
    this.phoneNumber,
  });

  // Convert JSON map to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      isDarkMode: json['isDarkMode'] is bool
          ? json['isDarkMode'] as bool
          : false,
      title: json['title']?.toString(),
      about: json['about']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
    );
  }

  factory User.fromApi(
    Map<String, dynamic> json, {
    String fallbackEmail = '',
    String fallbackPassword = '',
  }) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? fallbackEmail,
      password: json['password']?.toString() ?? fallbackPassword,
      name: json['name']?.toString() ?? fallbackEmail.split('@').first,
      imageUrl: json['imageUrl']?.toString() ?? '',
      isDarkMode: json['isDarkMode'] is bool
          ? json['isDarkMode'] as bool
          : false,
      title: json['title']?.toString(),
      about: json['about']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
    );
  }

  // Convert User object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'imageUrl': imageUrl,
      'isDarkMode': isDarkMode,
      'title': title,
      'about': about,
      'phoneNumber': phoneNumber,
    };
  }

  // Create a copy of this User with some fields changed
  User copyWith({
    String? id,
    String? email,
    String? password,
    String? name,
    String? imageUrl,
    bool? isDarkMode,
    String? about,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      about: about ?? this.about,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
