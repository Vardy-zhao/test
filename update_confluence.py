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
