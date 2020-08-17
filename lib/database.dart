import 'package:sqflite/sqflite.dart';


abstract class TableElement{
  int id;
  final String tableName;
  TableElement(this.id, this.tableName);
  void createTable(Database db);
  Map<String, dynamic> toMap();
}

class Ciudad extends TableElement{
  static final String TABLE_NAME = "cuidad";
  String title;

  Ciudad({this.title, id}):super(id, TABLE_NAME);
  factory Ciudad.fromMap(Map<String, dynamic> map){
    return Ciudad(title: map["title"], id: map["_id"]);
  }

  @override
  void createTable(Database db) {
    db.rawUpdate("CREATE TABLE ${TABLE_NAME}(_id integer primary key autoincrement, title varchar(30))");
  }

  @override
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{"title":this.title};
    if(this.id != null){
      map["_id"] = id;
    }
    return map;
  }

}


final String DB_FILE_NAME = "crub.db";

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database _database;


  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await open();

    return _database;
  }

  Future<Database> open() async {
    try{
      String databasesPath = await getDatabasesPath();
      String path = "$databasesPath/$DB_FILE_NAME";
      var db  = await openDatabase(path,
          version: 1,
          onCreate: (Database database, int version) {
            new Ciudad().createTable(database);
          });
      return db;
    }catch(e){
      print(e.toString());
    }
    return null;
  }

  Future<List<Ciudad>> getList() async{
    Database dbClient = await db;

    List<Map> maps = await dbClient.query(Ciudad.TABLE_NAME,
        columns: ["_id", "title"]);

    return maps.map((i)=> Ciudad.fromMap(i)).toList();
  }
  Future<TableElement> insert(TableElement element) async {
    var dbClient = await db;

    element.id = await dbClient.insert(element.tableName, element.toMap());
    print("new Id ${element.id}");
    return element;
  }
  Future<int> delete(TableElement element) async {
    var dbClient = await db;
    return await dbClient.delete(element.tableName, where: '_id = ?', whereArgs: [element.id]);

  }
  Future<int> update(TableElement element) async {
    var dbClient = await db;

    return await dbClient.update(element.tableName, element.toMap(),
        where: '_id = ?', whereArgs: [element.id]);
  }
}
