import 'package:flutter/material.dart';
import 'package:jardin_flutter/pages/tabs/niveles_tab.dart';
import 'package:jardin_flutter/providers/providers_page.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

class AgregarEstudiante extends StatefulWidget {
  AgregarEstudiante({Key? key}) : super(key: key);

  @override
  State<AgregarEstudiante> createState() => _AgregarEstudianteState();
}

class _AgregarEstudianteState extends State<AgregarEstudiante> {
  final formKey = GlobalKey<FormState>();

  TextEditingController codigoCtrl = TextEditingController();
  TextEditingController nombreCtrl = TextEditingController();
  TextEditingController apellidoCtrl = TextEditingController();
  TextEditingController EdadCtrl = TextEditingController();

  String errCodigo = '';
  String errNombre = '';
  String errApellido = '';

  /////PARA DROPDOWNBUTTON/////
  int dropdownValue =
      1; //se debe cambiar este valor por el primer elemento de la lista de Niveles
  List nivelesList = List.empty();
  final String apiURL = 'http://10.0.2.2:8000/api';

  Future getAllNiveles() async {
    var uri = Uri.parse('$apiURL/niveles');
    var respuesta = await http.get(uri);

    if (respuesta.statusCode == 200) {
      //return json.decode(respuesta.body);
      var jsonData = jsonDecode(respuesta.body);
      setState(() {
        nivelesList = jsonData;
      });
    } else {
      return [];
    }
    //print(nivelesList);
  }

  @override
  void initState() {
    super.initState();
    getAllNiveles();
  }
  ////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estudiante'),
        backgroundColor: Color.fromARGB(255, 242, 76, 5),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Container(),
              TextFormField(
                controller: codigoCtrl,
                decoration: InputDecoration(labelText: 'Codigo'),
              ),
              Container(
                width: double.infinity,
                child: Text(
                  errCodigo,
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextFormField(
                controller: nombreCtrl,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              Container(
                width: double.infinity,
                child: Text(
                  errNombre,
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextFormField(
                controller: apellidoCtrl,
                decoration: InputDecoration(labelText: 'Apellido'),
              ),
              Container(
                width: double.infinity,
                child: Text(
                  errApellido,
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextFormField(
                controller: EdadCtrl,
                decoration: InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
              ),
              // TextFormField(
              //   controller: NivelCtrl,
              //   decoration: InputDecoration(
              //       labelText: 'Nivel',
              //       hintText: 'Solo numeros del 1 al 3',
              //       helperText:
              //           '(1)Medio Menor   (2)Medio Mayor   (3)Playground'),
              //   keyboardType: TextInputType.number,
              // ),
              Text(''),
              Text(''),
              Text(
                'Nivel',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              DropdownButton(
                  //Nuevo Widget :D //Agregar para que sea con base de datos
                  isExpanded: true,
                  value: dropdownValue,
                  hint: Text('Seleccione un nivel'),
                  onChanged: (val) {
                    setState(() {
                      int newVal = int.tryParse(val.toString()) ??
                          0; // Transformando el val a String y luego a int para que el valor que tome sea el id
                      dropdownValue = newVal;
                    });
                  },
                  items: nivelesList.map((niveles) {
                    return DropdownMenuItem(
                      value: niveles['id'], //toma el valor id
                      child: Text(
                          niveles['nombre']), //muesta en pantalla el nombre
                    );
                  }).toList()),

              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('Agregar Estudiante'),
                  onPressed: () async {
                    int edad = int.tryParse(EdadCtrl.text) ?? 0;
                    //int niveles_id = int.tryParse(NivelCtrl.text) ?? 0;

                    var respuesta = await Providers().estudiantesAgregar(
                      codigoCtrl.text.trim(),
                      nombreCtrl.text.trim(),
                      apellidoCtrl.text.trim(),
                      edad,
                      dropdownValue, //toma el valor de la id seleccionada (desde el DropDownButton),
                      //BigInt.from(nivel), //transformar a BigInt
                    );

                    if (respuesta['message'] != null) {
                      //codigo
                      if (respuesta['errors']['cod_estudiante'] != null) {
                        errCodigo = respuesta['errors']['cod_estudiante'][0];
                      }

                      //nombre
                      if (respuesta['errors']['nombre'] != null) {
                        errNombre = respuesta['errors']['nombre'][0];
                      }

                      //apeliido
                      if (respuesta['errors']['apellido'] != null) {
                        errApellido = respuesta['errors']['apellido'][0];
                      }
                      setState(() {});
                      return;
                    }

                    Navigator.pop(context);
                  }, //Fuera de onPressed
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 143, 195, 80),
                  ), //Cambiar color del boton
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
