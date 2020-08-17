import 'package:flutter/material.dart';
import 'package:flutter_sqlite_list/database.dart';

final String DB_NAME = "contactos1";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ejemplo de CRUD',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  List<Notas> _list;
  DatabaseHelper _databaseHelper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CRUD en Flutter"),

        //Agregamos un boton para agregar datos
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              insert(context);
            },
          )
        ],
      ),
      body: _getBody(),
    );
  }

  void insert(BuildContext context) {
    Notas nNombre = new Notas();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Agregar"),
            content: TextField(
              //Capturamos la variable conforme se modifica
              onChanged: (value) {
                nNombre.title = value;
              },
              decoration: InputDecoration(labelText: "Nota:"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  //cerramos el alert
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Guardar"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _databaseHelper.insert(nNombre).then((value) {
                    updateList();
                  });
                },
              )
            ],
          );
        });
  }

  void onDeletedRequest(int index) {
    Notas notas = _list[index];
    _databaseHelper.delete(notas).then((value) {
      setState(() {
        _list.removeAt(index);
      });
    });
  }

  void onUpdateRequest(int index) {
    Notas nNombre = _list[index];
    final controller = TextEditingController(text: nNombre.title);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Modificar"),
            content: TextField(
              controller: controller,
              onChanged: (value) {
                nNombre.title = value;
              },
              decoration: InputDecoration(labelText: "Título:"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Actualizar"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _databaseHelper.update(nNombre).then((value) {
                    updateList();
                  });
                },
              )
            ],
          );
        });
  }

  Widget _getBody() {
    //Creamos el cuerpo de nuestra app
    //Si la lista es nula mandamos un icono de cargado
    if (_list == null) {
      return CircularProgressIndicator();
    } else if (_list.length == 0) {
      //Si esta vacio indica que esta vacio
      return Text("Está vacío");
    } else {
      return ListView.builder(
          // Si tiene datos los muestra
          itemCount: _list.length,
          itemBuilder: (BuildContext context, index) {
            Notas notas = _list[index];
            return NotasWidget(notas, onDeletedRequest, index, onUpdateRequest);
          });
    }
  }

  @override
  void initState() {
    super.initState();
    _databaseHelper = new DatabaseHelper();
    updateList();
  }

  void updateList() {
    //instanciamos la Base de Datos
    _databaseHelper.getList().then((resultList) {
      setState(() {
        //Obtenemos la lista y asignamos a nuestra variable
        _list = resultList;
      });
    });
  }
}

typedef OnDeleted = void Function(int index);
typedef OnUpdate = void Function(int index);

class NotasWidget extends StatelessWidget {
  final Notas notas;
  final OnDeleted onDeleted;
  final OnUpdate onUpdate;
  final int index;
  NotasWidget(this.notas, this.onDeleted, this.index, this.onUpdate);

  @override
  Widget build(BuildContext context) {
    //Al usar Dismissible Permite eliminar con slide
    return Dismissible(
      //Parametro Key para borra, se pasa id para saber cual se borra
      key: Key("${notas.id}"),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(notas.title),
            ),
            IconButton(
              icon: Icon(
                Icons.edit,
                size: 30,
              ),
              onPressed: () {
                this.onUpdate(index);
              },
            )
          ],
        ),
      ),
      //Aqui hace la eliminacion, llamando el metodo OnDeleted
      onDismissed: (direction) {
        onDeleted(this.index);
      },
    );
  }
}
