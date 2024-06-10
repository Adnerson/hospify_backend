import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getDoctors(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _getDoctors(RequestContext context) async {
  final lists = <Map<String, dynamic>>[];
  final results =
      // ignore: lines_longer_than_80_chars
      await context.read<PostgreSQLConnection>().query('SELECT * FROM users WHERE isDoctor = true');

  for (final row in results) { //probably more efficent way to do this
    lists.add({
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

  return Response.json(body: lists);
}
