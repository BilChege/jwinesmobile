import 'package:jwines/models/salesmodels.dart';
import 'package:sqflite/sqflite.dart';
import 'package:jwines/utils/Config.dart' as Config;

class OrderDetailProvider{

  Database database;
  Future<void> open(String path) async{
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
    String _createTbSalesOrder = 'CREATE TABLE IF NOT EXISTS '+Config.tbSalesOrder+'('
        +Config.id+' INTEGER PRIMARY KEY AUTOINCREMENT, '
        +Config.custid+' VARCHAR(50), '
        +Config.orderid+' INTEGER, '
        +Config.orderdate+ ' VARCHAR(50), '
        +Config.orderdocno+' VARCHAR(100), '
        +Config.custname+' VARCHAR(200), '
        +Config.ordervalidity+' INTEGER)';
    print('--------------> QUERY TO CREATE TABLE ORDERdETAILS: $_createTbOrderDetail');
    String _dropTbOrderDetail = 'DROP TABLE IF EXISTS '+Config.tbOrderDetail;
    String _dropTbSalesOrder = 'DROP TABLE IF EXISTS '+Config.tbSalesOrder;
    database = await openDatabase(path,version: 1,onCreate: (Database db,int version) async{
      print('-------------> TABLE ORDER DETAILS CREATED');
      await db.execute(_createTbOrderDetail);
      await db.execute(_createTbSalesOrder);
    },onUpgrade: (db,i,j){
      db.execute(_dropTbOrderDetail);
      db.execute(_dropTbSalesOrder);
    });
  }

  Future<int> insert(OrderDetail orderDetail,int orderid) async{
    Map<String,dynamic> map = orderDetail.toMap();
    map[Config.orderid] = orderid;
    return await database.insert(Config.tbOrderDetail, map);
  }

  Future<OrderDetail> getOrderDetail(int id) async{
    List<Map> rows = await database.query(Config.tbOrderDetail,where: Config.id+' = ?',whereArgs: [id]);
    return OrderDetail.fromMap(rows.first);
  }

  Future<int> delete(int id) async{
    return await database.delete(Config.tbOrderDetail,where: Config.id+' = ?',whereArgs: [id]);
  }

  Future<List<OrderDetail>> findByCriteria(Map<String,dynamic> criteria) async{
    List<OrderDetail> results = new List();
    String where = '';
    int counter = 1;
    criteria.forEach((criterion,val){
      where += ' $criterion = $val ';
      if(counter < criteria.length){
        where += ' AND ';
      }
      counter += 1;
    });
    List<Map> rows = await database.query(Config.tbOrderDetail,where: where);
    rows.forEach((row){
      results.add(OrderDetail.fromMap(row));
    });
    return results;
  }

}