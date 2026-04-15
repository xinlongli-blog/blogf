#### MySQL 语法相关

###### 开场小demo/

 需求如下：来自技术群驴友需求 把MySQL证书按字符串格式输出，1按照四位一组进行分组，并以逗号分割，2不足四位，高位补零

 SQL实现：

```ABAP
lixl@msql[(none)]> select group_concat(lpad(reverse(substring(reverse(numstr)
    -> from 4*(col-1)+1 for 4)),4,'0') order by col desc)
    -> from (select '1234567890' numstr) t1
    -> left  join(select 1 as col union select 2 union select 3 union select 4 union select 5 union select 6)
    -> t2 on length(numstr)/4+1>=col;
+---------------------------------------------------------------------------------------------------------+
| group_concat(lpad(reverse(substring(reverse(numstr)
from 4*(col-1)+1 for 4)),4,'0') order by col desc) |
+---------------------------------------------------------------------------------------------------------+
| 0012,3456,7890                                                                                          |
+---------------------------------------------------------------------------------------------------------+
1 row in set (0.03 sec)
```

流程 将一个字符串 `1234567890` 进行特定规则的分组、翻转、补零，并按照一定顺序连接成一个新的字符串