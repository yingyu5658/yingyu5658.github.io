#!/usr/bin/env bash

# 递归处理_posts目录下的所有.md文件
find ./_posts -type f -name "*.md" | while read -r hexo_file; do
    # 生成Hugo内容路径（保持中文目录结构）
    hugo_file="content/posts/${hexo_file#./_posts/}"
    mkdir -p "$(dirname "$hugo_file")"

    # 提取Front Matter元数据块
    frontmatter=$(sed -n '/^---$/,/^---$/p' "$hexo_file" | sed '1d;$d')

    # 转换元数据字段
    converted_meta=$(echo "$frontmatter" | awk '
        BEGIN { 
            FS=":"; 
            print "+++" 
        }
        /^layout:/ { next }    # 删除Hexo特有字段
        /^cid:/ { next }
        /^mathjax:/ { next }
        /^noThumbInfoStyle:/ { next }
        /^status:/ { 
            gsub(/publish/, "false");
            gsub(/draft/, "true");
            $1 = "draft"; 
        }
        /^date:/ { 
            gsub(/\//, "-", $2);          # 转换日期格式2024/12/13 -> 2024-12-13
            gsub(/ /, "T", $2);           # 添加时间分隔符
            sub(/$/, "+08:00", $2);       # 添加时区
            $0 = "date = \"" $2 "\"" 
        }
        /^slug:/ { next }                 # 删除slug字段
        /^categories:/ { 
            gsub(/$$|$$/, "");            # 移除数组符号
            $1 = "categories = [\"" $2 "\"]" 
        }
        { print } 
        END { print "+++" }
    ')

    # 合并转换后的元数据和正文
    {
        echo "$converted_meta"
        sed -e '1,/^---$/d' "$hexo_file" # 提取正文部分
    } >"$hugo_file"

    echo "已转换: $hexo_file → $hugo_file"
done
