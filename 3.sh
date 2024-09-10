#!/bin/bash

# 提取 ERROR_CODE.md
error_codes_in_md=$(grep '^|\s*[0-9]' ERROR_CODE.md | awk -F '|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')

# 检查是否有重复的错误码
duplicate_code=$(echo "$error_codes_in_md" | sort | uniq -d)
if [ -n "$duplicate_code" ]; then
    echo "Error: Duplicate error codes found in ERROR_CODE.md: $duplicate_code"
    exit 1
fi

# 通过git diff获取本次提交的改动
new_error_codes=$(git diff --cached ERROR_CODE.md | grep '^+|\s*[0-9xX]\{1,\}' | awk -F '|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')
deleted_error_codes=$(git diff --cached ERROR_CODE.md | grep '^-|\s*[0-9xX]\{1,\}' | awk -F '|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')

# 文件有变化，需要检查是否有重复的错误码
if [ -n "$deleted_error_codes" ] || [ -n "$new_error_codes" ]; then
  # git diff 如果是修改，会同时存在一个-，一个+，可以不用检查confluence
  # 如果是新增，只会有一个+，这个就要检查confluence
  # 如果是删除，只会有一个-，不需要检查confluence
  updated_codes=""
  new_codes=""
  deleted_codes=""
  for new_item in $new_error_codes; do
    flag=0
    for deleted_item in $deleted_error_codes; do
      if [ "$new_item" == "$deleted_item" ]; then
        flag=1
        break
      fi
    done
    if [ $flag -eq 1 ]; then
      updated_codes="$updated_codes $new_item"
    else
      new_codes="$new_codes $new_item"
    fi
  done
  for remove_item in $deleted_error_codes; do
    if ! echo "$updated_codes" | grep -qw "$remove_item"; then
      deleted_codes="$deleted_codes $remove_item"
    fi
  done

  # 检查conflunce和ERROR_CODE的差异
  confluence_data=$(curl -s --location 'https://thebidgroup.atlassian.net/wiki/api/v2/pages/3333423226?body-format=STORAGE' \
       --header 'Accept: application/json' \
       --header 'Authorization: Basic dmFyZHkuemhhb0BsaWZlYnl0ZS5pbzpBVEFUVDN4RmZHRjBaS0ROSHY5VGh5My1abzhfMDRLb1dIZ0tJMUdWRkpKMEJYRUx0Q1dqWERONXd6ckt3SDdUcUVnajRJbWhiV0pZSHhSb1pHZXJVZ1B4MGpmNWJNeGtwc1piUkNuSndDWVBRZG1BWEw5dHNmZ2tJelFBLTQ1UnRCdGd6bkoyMmY5M3ZvV044RldDazdOVjNxVVdHdzZ5ZWRzTk1qaVd1OTR6UzZubzdkb0ZNcnc9QzZFMThENEM=' \
  )
  confluence_codes=$(echo "$confluence_data" | grep -o '<tr><td><p>[0-9]\+</p></td>' | sed 's|<[^>]*>||g' | sort -u)
  duplicate_confluence_codes=()
  for insert_code in $new_codes; do
    if echo "$confluence_codes" | grep -qw "$insert_code"; then
      duplicate_confluence_codes+=("$insert_code")
    fi
  done
  if [ -n "$duplicate_confluence_codes" ]; then
    echo "Error: The error code already exists in Confluence: $duplicate_confluence_codes"
    exit 1
  fi

  PYTHON_CMD=""
  PHP_CMD=""
  # 更新confluence，中文字符shell不好处理，要用python或者php
  if command -v py &> /dev/null; then
      PYTHON_CMD="py"
  elif command -v py3 &> /dev/null; then
      PYTHON_CMD="py3"
  elif command -v python3 &> /dev/null; then
      PYTHON_CMD="python3"
  elif command -v python &> /dev/null; then
      PYTHON_CMD="python"
  else
      echo "Python is not installed on this system.Can't update Confluence document,Please update Confluence document manually"
      exit 1
  fi
  touch tmp_params
  echo "confluence_data=$confluence_data" >> tmp_params
  echo "deleted_codes=$deleted_codes" >> tmp_params
  echo "updated_codes=$updated_codes" >> tmp_params
  echo "new_codes=$new_codes" >> tmp_params
  res=""
  if [ -n "$PYTHON_CMD" ]; then
    res=$($PYTHON_CMD -c '
import sys
import http.client
import json
import re

variables = {}
with open("tmp_params", "r", encoding="utf-8") as f:
    for line in f:
        name, value = line.strip().split("=", 1)
        variables[name] = value

deleted_codes = variables.get("deleted_codes", "").split()
update_codes = variables.get("updated_codes", "").split()
new_codes = variables.get("new_codes", "").split()
confluence_data = json.loads(variables.get("confluence_data", ""))
version_number = confluence_data["version"]["number"] + 1

confluence_codes = []
exists_doc_codes = {}
if "body" in confluence_data and "storage" in confluence_data["body"] and "value" in confluence_data["body"]["storage"]:
    html = confluence_data["body"]["storage"]["value"]
    rows = re.findall(r"<tr>(.*?)</tr>", html, re.S)
    for i, row in enumerate(rows):
        if i < 1:
            continue
        cells = re.findall(r"<td[^>]*><p[^>]*>(.*?)</p></td>", row, re.S)
        if cells:
            code = cells[0]
            cn = cells[1] if len(cells) > 1 else ""
            en = cells[2] if len(cells) > 2 else ""
            if code not in deleted_codes:
                exists_doc_codes[code] = True
                confluence_codes.append({
                    "code": code,
                    "cn": cn,
                    "en": en
                })
with open("ERROR_CODE.md", "r", encoding="utf-8") as file:
    lines = file.readlines()
table_lines = lines[2:]  # 跳过前两行表头
md_codes = []
for line in table_lines:
    if "-" in line:
        continue
    if "|" in line:
        row = re.split(r"\s*\|\s*", line.strip())
        if row:
            code = row[1]
            cn = row[2] if len(row) > 2 else ""
            en = row[3] if len(row) > 3 else ""
            if code in deleted_codes or (code in update_codes and code not in exists_doc_codes) or (code not in new_codes and code not in exists_doc_codes):
                continue
            md_codes.append({
                "code": code,
                "cn": cn,
                "en": en
            })
update_data = {}
i = 0
while i < len(confluence_codes) or i < len(md_codes):
    cData = confluence_codes[i] if i < len(confluence_codes) else None
    mData = md_codes[i] if i < len(md_codes) else None
    if cData and mData:
        if "x" in cData["code"].lower() or cData["code"] < mData["code"]:
            update_data[cData["code"]] = {"cn": cData["cn"], "en": cData["en"]}
            update_data[mData["code"]] = {"cn": mData["cn"], "en": mData["en"]}
        else:
            update_data[mData["code"]] = {"cn": cData["cn"], "en": mData["en"]}
            update_data[cData["code"]] = {"cn": cData["cn"], "en": cData["en"]}
    elif cData:
        update_data[cData["code"]] = {"cn": cData["cn"], "en": cData["en"]}
    elif mData:
        update_data[mData["code"]] = {"cn": mData["cn"], "en": mData["en"]}
    i += 1

md_content = "## 异常code表\n| Code   | CN  | EN                                            |\n|--------|-----|-----------------------------------------------|\n"
html_content = "<table data-table-width=\"1800\" data-layout=\"default\" ac:local-id=\"8cfa5e45-3eee-441b-9847-85c0fb3af991\"><tbody><tr><th><p>Code</p></th><th><p>CN</p></th><th><p>EN</p></th></tr>"
for code, item in update_data.items():
    md_content += f"|{code}|{item["cn"]}|{item["en"]}|\n"
    html_content += f"<tr><td><p>{code}</p></td><td><p>{item["cn"]}</p></td><td><p>{item["en"]}</p></td></tr>"
html_content += "</tbody></table>"
payload = json.dumps({
    "id": "3333423226",
    "status": "current",
    "title": "Backend Error Code",
    "body": {
        "representation": "storage",
        "value": html_content
    },
    "version": {
        "number": version_number,
        "message": "Git commit with update doc"
    }
})
headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "Basic dmFyZHkuemhhb0BsaWZlYnl0ZS5pbzpBVEFUVDN4RmZHRjBaS0ROSHY5VGh5My1abzhfMDRLb1dIZ0tJMUdWRkpKMEJYRUx0Q1dqWERONXd6ckt3SDdUcUVnajRJbWhiV0pZSHhSb1pHZXJVZ1B4MGpmNWJNeGtwc1piUkNuSndDWVBRZG1BWEw5dHNmZ2tJelFBLTQ1UnRCdGd6bkoyMmY5M3ZvV044RldDazdOVjNxVVdHdzZ5ZWRzTk1qaVd1OTR6UzZubzdkb0ZNcnc9QzZFMThENEM="
}

# 将字符串写入文件
with open("output.json", "w", encoding="utf-8") as file:
    file.write(payload)
conn = http.client.HTTPSConnection("thebidgroup.atlassian.net")
conn.request("PUT", "/wiki/api/v2/pages/3333423226", body=payload, headers=headers)
response = conn.getresponse()
conn.close()
data = response.read()
if response.status == 200:
    print("success")
    with open("ERROR_CODE.md", "w", encoding="utf-8") as f:
        f.write(md_content)
else:
    print(f"Failed to update Confluence content: {response.status}")
')
  fi
  rm -f tmp_params
  if [ "$res" != "success" ]; then
    echo $res
    exit 1
  fi
  git add ERROR_CODE.md
fi