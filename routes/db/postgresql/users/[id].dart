import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
  String email,
) async {
  return switch (context.request.method) {
    HttpMethod.get => _getUserByEmail(context, email),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _getUserByEmail(RequestContext context, String email) async {
  final user = <Map<String, dynamic>>[];

  final result =
      // ignore: lines_longer_than_80_chars
      await context.read<PostgreSQLConnection>().query("SELECT * FROM users WHERE email = '$email' ");

  for (final row in result) { //probably more efficent way to do this
    user.add({
      'id': row[0],
      'name': row[1],
      'email': row[2],
      'password': row[3],
      'isDoctor': row[4],
      'specialization': row[5],
      'address': row[6],
      'phoneNumber': row[7],
    });
  }

  return Response.json(body: user);
}
