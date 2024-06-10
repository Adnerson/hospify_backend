import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  return switch (context.request.method) {
    HttpMethod.get => _getAppointmentById(context, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _getAppointmentById(RequestContext context, String id) async {
  final appointment = <Map<String, dynamic>>[];

  final result =
      // ignore: lines_longer_than_80_chars
      await context.read<PostgreSQLConnection>().query('SELECT * FROM APPOINTMENTS WHERE id = $id');

  for (final row in result) { //probably more efficent way to do this
    appointment.add({
      //when it is a timestamp datatype use toString()
      'id': row[1],
      'appointmentdate': row[2].toString(), 
      'title': row[3],
      'description': row[4],
      'status': row[5],
    });
  }

  return Response.json(body: appointment);
}
