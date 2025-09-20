#!/bin/bash

# 定义需要处理的目录
directories=("about" "archives" "links" "readings" "search" "posts")

# 遍历所有目录
for dir in "${directories[@]}"; do
    # 检查目录是否存在
    if [ -d "$dir" ]; then
        echo "处理目录: $dir"
        
        # 如果是 posts 目录，需要处理其子目录
        if [ "$dir" = "posts" ]; then
            for subdir in "$dir"/*/; do
                if [ -d "$subdir" ]; then
                    # 获取子目录名称
                    subdir_name=$(basename "$subdir")
                    # 检查是否存在 index.md
                    if [ -f "$subdir/index.md" ]; then
                        # 移动并重命名文件
                        mv "$subdir/index.md" "$dir/$subdir_name.md"
                        # 删除空目录
                        rmdir "$subdir"
                        echo "已处理: $subdir -> $dir/$subdir_name.md"
                    else
                        echo "警告: $subdir 中没有 index.md，跳过"
                    fi
                fi
            done
        else
            # 处理其他目录
            if [ -f "$dir/index.md" ]; then
                # 移动并重命名文件
                mv "$dir/index.md" "$dir.md"
                # 删除空目录
                rmdir "$dir"
                echo "已处理: $dir -> $dir.md"
            else
                echo "警告: $dir 中没有 index.md，跳过"
            fi
        fi
    else
        echo "警告: 目录 $dir 不存在，跳过"
    fi
done

echo "扁平化处理完成！"
