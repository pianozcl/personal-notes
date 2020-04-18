### list转tree，用于展示层级结构

>部门类定义
>
>```java
>import java.util.List;
>
>/**
> * 部门类（省略get set方法）
> **/
>public class DepartmentVO {
>    /**
>     * 当前部门id
>     */
>    private String deptId;
>
>    /**
>     * 父部门id
>     */
>    private String parentId;
>
>    /**
>     * 当前部门子部门
>     */
>    private List<DepartmentVO> childrens;
>
>```
>
>方法的实现
>
>```java
>import java.util.ArrayList;
>import java.util.List;
>import java.util.Objects;
>import java.util.stream.Collectors;
>
>/**
> * 模拟七个部门，分三个层级
> */
>public class Test4 {
>    public static void main(String[] args) {
>        //一级部门
>        DepartmentVO level100 = new DepartmentVO();
>        level100.setDeptId("10000");
>        level100.setParentId("0");
>
>        //二级部门
>        DepartmentVO level200 = new DepartmentVO();
>        level200.setDeptId("20000");
>        level200.setParentId("10000");
>        DepartmentVO level201 = new DepartmentVO();
>        level201.setDeptId("20001");
>        level201.setParentId("10000");
>        DepartmentVO level202 = new DepartmentVO();
>        level202.setDeptId("20002");
>        level202.setParentId("10000");
>
>        //三级部门
>        DepartmentVO level300 = new DepartmentVO();
>        level300.setDeptId("30000");
>        level300.setParentId("20000");
>        DepartmentVO level301 = new DepartmentVO();
>        level301.setDeptId("30000");
>        level301.setParentId("20000");
>        DepartmentVO level302 = new DepartmentVO();
>        level302.setDeptId("30000");
>        level302.setParentId("20000");
>
>        List<DepartmentVO> list = new ArrayList<>();
>        list.add(level100);
>        list.add(level200);
>        list.add(level201);
>        list.add(level202);
>        list.add(level300);
>        list.add(level301);
>        list.add(level302);
>        List<DepartmentVO> tree = getDepartmentTree(list);
>    }
>
>    /**
>     *  list转tree方法
>     */
>    public static List<DepartmentVO> getDepartmentTree(List<DepartmentVO> list) {
>        for (DepartmentVO l : list) {
>      			//每次循环找到每个节点的子节点们（f代表符合条件的集合），并挂载到当前节点下
>            List<DepartmentVO> children = list.stream().filter(f -> l.getDeptId().equals(f.getParentId())).collect(Collectors.toList());
>            l.setChildrens(children);
>        }
>      	//for循环结束，整棵树挂载完毕，需要找到树的根节点（此例定义parentId为0就是根节点）
>        List<DepartmentVO> rootNodes = list.stream()
>                .filter(f -> f.getParentId() == "0" || Objects.isNull(f.getParentId())).collect(Collectors.toList());
>        return rootNodes;
>    }
>}
>
>```
>
>最终生产的树转JSON结构如下
>
>```json
>[
>    {
>        "deptId": "10000",
>        "parentId": "0",
>        "childrens": [
>            {
>                "deptId": "20000",
>                "parentId": "10000",
>                "childrens": [
>                    {
>                        "deptId": "30000",
>                        "parentId": "20000",
>                        "childrens": []
>                    },
>                    {
>                        "deptId": "30000",
>                        "parentId": "20000",
>                        "childrens": []
>                    },
>                    {
>                        "deptId": "30000",
>                        "parentId": "20000",
>                        "childrens": []
>                    }
>                ]
>            },
>            {
>                "deptId": "20001",
>                "parentId": "10000",
>                "childrens": []
>            },
>            {
>                "deptId": "20002",
>                "parentId": "10000",
>                "childrens": []
>            }
>        ]
>    }
>]
>```
>
>