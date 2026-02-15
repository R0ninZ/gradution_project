class StudentEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String studentId;
  final int universityYear;
  final String track;

  StudentEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentId,
    required this.universityYear,
    required this.track,
  });

  factory StudentEntity.fromMap(Map<String, dynamic> map) {
    return StudentEntity(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      email: map['email'],
      studentId: map['student_id'],
      universityYear: map['university_year'],
      track: map['track'] ?? '',
    );
  }
}
