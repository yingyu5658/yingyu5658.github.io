#!/bin/bash

# 获取当前日期
current_date=$(date +%s)

# 设置7月1日的日期
start_date=$(date -d "2025-07-01" +%s)

# 输出到 ~/ai.txt
output_file="$HOME/ai.txt"

# 清空输出文件（如果存在的话）
> "$output_file"

# 遍历当前目录下的所有文件夹
for dir in */; do
  # 仅处理文件夹
  if [ -d "$dir" ]; then
    # 获取文件夹的创建时间（转换为秒数）
    dir_creation_time=$(stat -c %W "$dir")
    
    # 如果文件夹没有创建时间（可能是某些文件系统），跳过
    if [ "$dir_creation_time" -eq 0 ]; then
      continue
    fi

    # 检查文件夹的创建时间是否在7月1日到现在之间
    if [ "$dir_creation_time" -ge "$start_date" ] && [ "$dir_creation_time" -le "$current_date" ]; then
      # 检查该文件夹下是否有 index.md 文件
      if [ -f "$dir/index.md" ]; then
        # 将 index.md 的内容追加到 ~/ai.txt
        cat "$dir/index.md" >> "$output_file"
      fi
    fi
  fi
done

echo "Finished appending index.md content to $output_file"

