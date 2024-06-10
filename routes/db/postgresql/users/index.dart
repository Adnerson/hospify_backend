import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getUsers(context),
    HttpMethod.post => _createUser(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _getUsers(RequestContext context) async {
  final users = <Map<String, dynamic>>[];
  final results =
      await context.read<PostgreSQLConnection>().query('SELECT * FROM users');

  for (final row in results) { //probably more efficent way to do this
    users.add({
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

  return Response.json(body: users);
}

Future<Response> _createUser(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final name = body['name'] as String?;
  final email = body['email'] as String?;
  final password = body['password'] as String?;
  final isDoctor = body['isDoctor'] as bool?;
  final specialization = body['specialization'] as String?;
  final address = body['address'] as String?;
  final phoneNumber = body['phoneNumber'] as String?;

  //unused?? but post grequest still worked??

  if (name != null) {
    try {
      final result = await context.read<PostgreSQLConnection>().query(
            // ignore: lines_longer_than_80_chars
            "INSERT INTO users (name, email, password, isDoctor, specialization, address, phonenumber) VALUES ('$name', '$email', '$password', '$isDoctor', '$specialization', '$address', '$phoneNumber') ",
          );

      if (result.affectedRowCount == 1) {
        return Response.json(body: {'success': true});
      } else {
        return Response.json(body: {'success': false});
      }
    } catch (e) {
      return Response(statusCode: HttpStatus.connectionClosedWithoutResponse);
    }
  } else {
    return Response(statusCode: HttpStatus.badRequest);
  }
}
