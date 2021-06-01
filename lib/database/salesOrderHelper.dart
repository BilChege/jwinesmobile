import 'package:jwines/models/salesmodels.dart';
import 'package:jwines/utils/Config.dart' as Config;
import 'package:sqflite/sqflite.dart';

class AppDB{
  AppDB._privateConstructor();
  static final AppDB appDB = AppDB._privateConstructor();

  static final String _dropTbSalesOrder = 'DROP TABLE IF EXISTS '+Config.tbSalesOrder;
  static final String _dropTbOrderDetail = 'DROP TABLE IF EXISTS '+Config.tbOrderDetail;



}

class SalesOrderProvider{

  Database database;

  Future<void> open(String path) async{
    String _createTbSalesOrder = 'CREATE TABLE IF NOT EXISTS '+Config.tbSalesOrder+'('
        +Config.id+' INTEGER PRIMARY KEY AUTOINCREMENT, '
        +Config.custid+' VARCHAR(50), '
        +Config.orderid+' INTEGER, '
        +Config.orderdate+ ' VARCHAR(50), '
        +Config.orderdocno+' VARCHAR(100), '
        +Config.custname+' VARCHAR(200), '
        +Config.ordervalidity+' INTEGER)';
    String _createTbOrderDetail = 'CREATE TABLE IF NOT EXISTS '+Config.tbOrderDetail+'('
        +Config.invCode+' VARCHAR(100), '
        +Config.invDescrip+' VARCHAR(350), '
        +Config.invQty+' REAL, '
        +Config.orderid+' INTEGER, '
        +Config.itemPrice+' REAL, '
        +Config.itemQty+' REAL, '
        +Config.originalPrice+' REAL, '
        +Config.invDiscount+' REAL, '
        +Config.invPrice+' REAL)';
    String _dropTbOrderDetail = 'DROP TABLE IF EXISTS '+Config.tbOrderDetail;
    String _dropTbSalesOrder = 'DROP TABLE IF EXISTS '+Config.tbSalesOrder;
      database = await openDatabase(path,version: 1,onCreate: (Database db, int version) async{
      await db.execute(_createTbSalesOrder);
      await db.execute(_createTbOrderDetail);
    },onUpgrade: (db,i,j){
        db.execute(_dropTbOrderDetail);
        db.execute(_dropTbSalesOrder);
    });
  }

  Future<int> insert(SalesOrder salesOrder) async{
    Map<String,dynamic> map = salesOrder.toMap();
    return await database.insert(Config.tbSalesOrder, map);
  }

  Future<SalesOrder> getSalesOrder(int id) async{
    List<Map> rows = await database.query(Config.tbSalesOrder,where: Config.id+' = ?',whereArgs: [id]);
    return SalesOrder.fromMap(rows.first);
  }

  Future<List<SalesOrder>> findAll() async{
    List<SalesOrder> response = new List();
    List<Map> rows = await database.query(Config.tbSalesOrder);
    rows.forEach((map){
      SalesOrder salesOrder = SalesOrder.fromMap(map);
      salesOrder.orderid = map[Config.id];
      response.add(salesOrder);
    });
    return response;
  }

  Future<int> delete(int id) async {
    return await database.delete(Config.tbSalesOrder, where: Config.id+' = ?',whereArgs: [id]);
  }

}