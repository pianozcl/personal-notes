### 什么是Apache POI？

Apache POI是Apache软件基金会的开放源码库，POI提供API给Java程序对Microsoft Office格式文件读和写的功能。本篇文章介绍提倡开发中使用Apache POI做Excel的导入导出功能

***



### 1. 首先引入相关依赖

在maven仓库搜索POI，会看到用的最多的是poi，poi-ooxml。下面说它们的区别

* poi是旧版遵循二进制文件格式Excel  97-2003所使用依赖，其生成的后缀为.xls。旧版poi几乎已经不再用了，但是为了兼容一些现有的老系统而保留了下来
* poi-ooxml为Excel 2007+的依赖，其生成后缀为.xlsx。所以下面会基于poi-ooxml的演示导入导出功能

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20210101215956.png)

#### 1.1 创建SpringBoot项目引入相关依赖

maven依赖如下，主要有

* poi-ooxml 支持07+版本Excel
* spring-boot-starter-web 用来开发一个可供postman或者浏览器下载Excel的接口

```xml
<dependencies>
        <!-- https://mvnrepository.com/artifact/junit/junit -->
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
            <scope>test</scope>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.apache.poi/poi-ooxml -->
        <dependency>
            <groupId>org.apache.poi</groupId>
            <artifactId>poi-ooxml</artifactId>
            <version>4.1.2</version>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.springframework.boot/spring-boot-starter-web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
            <version>2.3.4.RELEASE</version>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
```

### 2. 导入导出Service代码

* 如下导出代码注释部分用于通过response返回给客户端，供客户端下载
* 注释上面代码，是通过输出流直接下载到本机。与以上二选一

```java
package com.zcl.demo.poi;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * @author : chenliangzhou
 * create at:  2021/1/1  10:15 PM
 * @description:
 **/
@Service
public class TestExcel {

    public void exportExcel() throws IOException {

        //创建一个Excel
        Workbook workbook = new SXSSFWorkbook();

        //创建一个sheet
        Sheet sheet = workbook.createSheet();

        for(int i=0;i<100;i++){
            //创建一个行
            Row row = sheet.createRow(i);
            for(int j=0;j<10;j++){
                //创建每行的j个单元格
                Cell cell = row.createCell(j);

                //填充单元格数据
                cell.setCellValue(j);
            }
        }


        //输出到指定目录
        FileOutputStream fileOutputStream = new FileOutputStream("/test.xlsx");
        workbook.write(fileOutputStream);
        fileOutputStream.close();
        ((SXSSFWorkbook) workbook).dispose();


//        //获取response对象，将文件写入到客户端
//        HttpServletResponse response = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getResponse();
//
//        //返回内容类型，excel，编码格式utf8
//        response.setContentType("application/vnd.ms-excel;charset=UTF-8");
//        response.setHeader("content-Type", "application/vnd.ms-excel");
//
//        //这个头表示在页面展示或者是作为附件下载。第二个参数attachment表示通过附件下载，filename默认下的文件名字
//        response.setHeader("Content-Disposition", "attachment;filename=" + "testExcel" + ".xlsx");
//        response.flushBuffer();
//        workbook.write(response.getOutputStream());
//
//        //清除临时文件
//        ((SXSSFWorkbook) workbook).dispose();
    }



    public void importExcel() throws Exception{
        FileInputStream fileInputStream = new FileInputStream("/Users/chenliangzhou/Desktop/testcode/poi/src/main/java/com/zcl/demo/poi/test.xlsx");
        XSSFWorkbook workbook = new XSSFWorkbook(fileInputStream);

        //按序号获取sheet
        XSSFSheet sheet = workbook.getSheetAt(0);

        //获取excel行数
        int physicalNumberOfRows = sheet.getPhysicalNumberOfRows();

        for(int i=0;i<physicalNumberOfRows;i++){
            XSSFRow row = sheet.getRow(i);
            if(row!=null){
                //获取每行的单元格数
                int physicalNumberOfCells = row.getPhysicalNumberOfCells();
                for(int j=0;j<physicalNumberOfCells;j++){
                    XSSFCell cell = row.getCell(j);
                    if(cell!=null){
                        //这里获取单元格数据类型
                        CellType cellType = cell.getCellType();
                        System.out.println(cellType);

                        //这里是获取数值类型的方法，自行参考其他方法
                        double numericCellValue = cell.getNumericCellValue();
                        System.out.println(numericCellValue);
                    }
                }
            }
        }

        fileInputStream.close();
    }
}

```

### 3. Controller

* 这里提供一个用于客户端下载的接口，**注意不要用@RestController，或者ResponseBody，因为返回内容不是JSON类型的**

```java
package com.zcl.demo.poi;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import java.io.IOException;

@Controller
@RequestMapping("test")
public class TestController {
    @Autowired
    private TestExcel testExcel;

    @RequestMapping("/exportExcel")
    public void exportExcel() throws IOException {
        testExcel.exportExcel();
    }

}

```

也可以通过单元测试，测试直接在本地指定目录生成Excel

```java
import com.zcl.demo.poi.TestExcel;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import java.io.IOException;

@SpringBootTest
@RunWith(SpringRunner.class)
public class ExcelTest {
    @Autowired
    private TestExcel testExcel;

    @Test
    public void export() throws IOException {
        testExcel.exportExcel();
    }

    @Test
    public void importExcel()throws Exception{
        testExcel.importExcel();
    }
}
```

### 4. Postman下载Excel

这里选择Send and Download下载

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20210102154822.png)

