// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getAppointments(context),
    HttpMethod.post => _createAppointment(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _getAppointments(RequestContext context) async {
  final lists = <Map<String, dynamic>>[];
  final results =
      await context.read<PostgreSQLConnection>().query('SELECT * FROM appointments');

  for (final row in results) { //probably more efficent way to do this
    lists.add({
      'appointment_id': row[0],
      'id': row[1],
      'appointmentDate': '${row[2]}',
      'title': row[3],
      'description': row[4],
      'status': row[5],
    });
  }

  return Response.json(body: lists);
}

Future<Response> _createAppointment(RequestContext context) async {
  //the body waits for ur request then executes it
  final body = await context.request.json() as Map<String, dynamic>;
  //probably just pass over a name instead of the id
  final id = body['id'] as String?;
  final appointmentDate = body['appointmentDate'] as String?;
  final title = body['title'] as String?;
  final description = body['description'] as String?;
  final status = body['status'] as bool?;

  if (id != null) {
    try {
      final result = await context.read<PostgreSQLConnection>().query(
        //replace the id argument with a SELECT id from users where name = (name)
            "INSERT INTO appointments (id, appointmentDate, title, description, status) VALUES ($id, '$appointmentDate', '$title', '$description', $status) ",
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
