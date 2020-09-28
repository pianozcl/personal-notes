### Mysql快速创建测试数据（存储过程）

#### 1.创建测试数据库

```sql
CREATE TABLE `test_user` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(11) DEFAULT NULL,
  `age` int(4) DEFAULT NULL,
  `address` varchar(256) DEFAULT NULL,
  `create_time` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4;
```

#### 2.创建随机字符串函数

函数功能：从base_str中随机获取字符，再通过循环拼接成长度为n的随机字符串

* delimiter：作为函数开始结束的标示
* declare：定义变量
* concat：拼接函数，用于拼接字符为新的字符串

```sql
delimiter $$
CREATE FUNCTION rand_str(n int) RETURNS varchar(255) 
begin        
  declare base_str varchar(100) default "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  declare resp varchar(255) default "";        
  declare i int default 0;
  while i < n do        
      set resp=concat(resp,substring(base_str,floor(1+rand()*62),1));
      set i= i+1;        
  end while;        
  return resp;    
end $$
delimiter ;
```

### 3.创建存储过程，用于生成n条数据

```sql
delimiter $$
CREATE  PROCEDURE `insert_data`(IN n int)
BEGIN  
  DECLARE i INT DEFAULT 1;
    WHILE (i <= n ) DO
      INSERT into test_user (name,age,address,create_time) VALUEs (rand_str(5),FLOOR(RAND() * 100), rand_str(20),now() );
            set i=i+1;
    END WHILE;
END $$
delimiter ;
```

### 4.调用存储过程生成数据

```sql
call insert_data(10);
```

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200923175120.png)

