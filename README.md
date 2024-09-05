# test

## 异常code表
Name | Description | En
--- | --- | --- |
hubx错误码 |
101 | 缺乏必要参数或参数无效 | Lack of necessary fields or invalid fields.
102 | 请求参数类型不对 | bad request type
101 | 缺乏必要参数或参数无效 | Lack of necessary fields or invalid fields.
102 | 请求参数类型不对 | bad request type

## 权限
ID | Name | Description | 
--- | --- | --- |
1 | IBManagement-ReadOnly |  
2 | IBManagement-FullAccess | 
3 | Dashboard-ReadOnly | 



awk '/^## 异常code表/,/^## / {if ($1 ~ /^[0-9]+$/) print $1}' README.md


awk '
/^## 异常code表/ { in_table = 1; next }  # 检测到异常code表的标题，开始处理
/^## / { in_table = 0 }                 # 检测到下一个标题，停止处理
in_table && /^[0-9]+[[:space:]]*\|/ {    # 仅处理以数字开头并跟随有 | 的行
  split($0, fields, "|")
  gsub(/[[:space:]]+/, "", fields[1])    # 去掉第一列的多余空格
  print fields[1]                        # 输出错误码
}' README.md