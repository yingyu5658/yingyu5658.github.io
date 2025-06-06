import os
import glob
import frontmatter
from datetime import datetime

def convert_metadata(post):
    # 核心字段保留中文
    new_meta = {
        'title': post.get('title', '无标题'),
        'date': convert_time(post.get('date', datetime.now())),
        'categories': post.get('categories', []),  # 直接保留中文分类 
        'tags': post.get('tags', []),             # 保留中文标签
        'slug': post.get('abbrlink', '')          # 保持原abbrlink值 
    }

    # 特殊字段处理
    status_mapping = {'publish': False, 'draft': True}
    new_meta['draft'] = status_mapping.get(post.get('status', 'publish'), False)
    
    # 移除Hexo专属字段（防止冲突）
    hexo_keys = ['layout', 'cid', 'mathjax', 'noThumbInfoStyle', 
                'outdatedNotice', 'parseWay', 'reprint', 'thumbChoice', 
                'thumbStyle', 'abbrlink']
    for key in hexo_keys:
        post.metadata.pop(key, None)

    # 合并自定义字段（保留中文key）
    new_meta.update(post.metadata)
    
    return new_meta

def convert_time(hexo_time):
    """处理Hexo时间格式混乱问题"""
    time_formats = [
        "%Y/%m/%d %H:%M:%S",      # Hexo默认格式 
        "%Y-%m-%d %H:%M:%S",      # 可能的变体格式
        "%Y-%m-%dT%H:%M:%S"       # ISO格式
    ]
    
    if isinstance(hexo_time, str):
        for fmt in time_formats:
            try:
                dt = datetime.strptime(hexo_time, fmt)
                return dt.strftime("%Y-%m-%dT%H:%M:%S+08:00")
            except ValueError:
                continue
        return datetime.now().strftime("%Y-%m-%dT%H:%M:%S+08:00")
    else:
        return hexo_time.strftime("%Y-%m-%dT%H:%M:%S+08:00")

def process_post(file_path):
    try:
        post = frontmatter.load(file_path)
        new_meta = convert_metadata(post)
        post.metadata = new_meta
        
        # 保持原目录结构（中文路径）
        output_path = os.path.join("content/posts", os.path.relpath(file_path, "_posts"))
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(frontmatter.dumps(post))
    except Exception as e:
        print(f"处理 {file_path} 失败：{str(e)}")

if __name__ == "__main__":
    md_files = glob.glob('./_posts/**/*.md', recursive=True)
    
    for md_file in md_files:
        process_post(md_file)
        
    print(f"转换完成！共处理{len(md_files)}篇文章，保留全部中文分类和标签")
