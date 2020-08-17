import 'package:sqflite/sqflite.dart';

//Objeto Padre
abstract class TableElement {
  //Clase abstracta con elementos que seran sobre escritos
  int id; //ID del elemento dentro de la Base de datos
  final String tableName; //Nombre de la Tabla
  TableElement(this.id, this.tableName); //Constructor

  void createTable(Database db); //Creamos la Tabla
  Map<String, dynamic> toMap(); //Mapa para devolver valores
}

class Notas extends TableElement {
  static final String TABLE_NAME = "cuidad";
  String title; //Atributo

  Notas({this.title, id})
      : super(id,
            TABLE_NAME); //Constructor, Recibe titulo, id y pasa los valores a la tabla

  factory Notas.fromMap(Map<String, dynamic> map) {
    return Notas(title: map["title"], id: map["_id"]);
  }

  @override
  void createTable(Database db) {
    //Se crea la base de datos,
    db.rawUpdate(
        "CREATE TABLE ${TABLE_NAME}(_id integer primary key autoincrement, title varchar(30))");
  }

  @override
  Map<String, dynamic> toMap() {
    //mapa de datos par valor id : valor
    var map = <String, dynamic>{"title": this.title};

    //Al tener un id, se agrega el valor al map
    if (this.id != null) {
      map["_id"] = id;
    }
    return map;
  }
}

//Asignamos el nombre de nuesta base de datos
final String DB_FILE_NAME = "crub.db";

//Nos ayuda a mantener una comunicacion con la base de datos
class DatabaseHelper {
  //Mantiene una instancia de por vida, para ahorrar tiempo
  static final DatabaseHelper _instance = new DatabaseHelper._internal();
  factory DatabaseHelper() =>
      _instance; //metodo que ayuda al constructor a devolver instancias
  DatabaseHelper._internal(); //Constructor que nosotros definimos

  //atributo de base de datos, aqui estara la conexion a la base de datos
  Database _database;

  //se revisa si existe conexion con la Base de datos, si no se conecta
  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await open();
    return _database;
  }

  Future<Database> open() async {
    try {
      //Obtenemos el Path de la base de datos
      String databasesPath = await getDatabasesPath();
      String path = "$databasesPath/$DB_FILE_NAME";
      var db = await openDatabase(path, version: 1,
          onCreate: (Database database, int version) {
        new Notas().createTable(database);
      });
      return db;
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  //Obtenemos el listado de la DB
  Future<List<Notas>> getList() async {
    Database dbClient = await db;
    //se Declara las columnas que queremos que nos regrese
    List<Map> maps =
        await dbClient.query(Notas.TABLE_NAME, columns: ["_id", "title"]);

    //se regresa la lista de valores
    return maps.map((i) => Notas.fromMap(i)).toList();
  }

  Future<TableElement> insert(TableElement element) async {
    var dbClient = await db;

    element.id = await dbClient.insert(element.tableName, element.toMap());
    print("new Id ${element.id}");
    return element;
  }

  Future<int> delete(TableElement element) async {
    var dbClient = await db;
    return await dbClient
        .delete(element.tableName, where: '_id = ?', whereArgs: [element.id]);
  }

  Future<int> update(TableElement element) async {
    var dbClient = await db;

    return await dbClient.update(element.tableName, element.toMap(),
        where: '_id = ?', whereArgs: [element.id]);
  }
}
