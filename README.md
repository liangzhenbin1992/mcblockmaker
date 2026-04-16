# MCBlockMaker

一个用于 Godot 4 的编辑器插件，可以批量生成 Minecraft 风格方块的 GridMap 资源。

## 功能特性

- **批量网格生成**：从 8×8 纹理图自动生成 64 个方块网格
- **三种方块类型**：
  - **普通方块**：标准六面体，带碰撞
  - **透明方块**：双面渲染，适用于玻璃等
  - **X型灌木**：交叉面片，适用于花草等装饰
- **可视化配置**：直观的网格界面，点击切换方块类型
- **自动生成 MeshLibrary**：可直接用于 GridMap 节点
- **纹理预览**：加载纹理后自动显示每个格子的缩略图

## 安装方法

### 方式一：手动安装

1. 下载本插件
2. 将 `addons/mcblockmaker` 文件夹复制到你的 Godot 项目的 `addons/` 目录下
3. 在 Godot 编辑器中：**项目 → 项目设置 → 插件**
4. 找到 **MCBlockMaker** 并启用它

### 方式二：通过 Asset Library 安装（推荐）

1. 在 Godot 编辑器中：**项目 → 工具 → Asset Library**
2. 搜索 "MCBlockMaker"
3. 点击下载并安装

## 使用方法

### 1. 准备纹理图片

- 尺寸：512×512 像素
- 格式：8×8 格子，共 64 个纹理单元
- 支持格式：PNG、JPG、WebP

### 2. 配置方块

1. 启用插件后，左侧 Dock 会出现 **MC GridMap 资源生成器** 面板
2. 点击 **选择纹理** 按钮，选择你的纹理图片
3. 所有方块默认设为**普通**类型
4. 在 8×8 网格中点击方块，循环切换类型：
   - **灰色** = 跳过（不生成）
   - **白色** = 普通方块
   - **蓝色** = 透明方块
   - **绿色** = X型/灌木

### 3. 生成资源

1. 选择输出目录（默认 `res://gridmap_assets/`）
2. 点击 **生成 GridMap 资源** 按钮
3. 等待生成完成

### 4. 使用生成的资源

1. 在场景中创建 **GridMap** 节点
2. 将生成的 `voxel_mesh_library.tres` 拖入 GridMap 的 **Mesh Library** 属性
3. 开始绘制你的方块世界！

## 文件结构

```
addons/mcblockmaker/
├── plugin.cfg              # 插件配置
├── plugin.gd               # 插件入口
├── generator.gd            # 核心生成逻辑
├── icon.svg                # 插件图标
├── README.md               # 说明文档
└── ui/
    ├── generator_panel.gd  # UI 面板逻辑
    └── generator_panel.tscn # UI 面板场景
```

## 生成输出

生成完成后，输出目录包含：

```
gridmap_assets/
├── block_0.tres            # 方块网格资源
├── block_1.tres
├── ...
└── voxel_mesh_library.tres # MeshLibrary 资源
```

## 系统要求

- Godot 4.6 或更高版本
- Godot .NET 版本同样兼容

## 许可证

本插件基于 [MIT License](LICENSE) 开源。

## 作者

Linsan

## 反馈与贡献

如果你发现问题或有改进建议，欢迎：
- 提交 Issue
- 发起 Pull Request

## 更新日志

### v1.0.0
- 初始版本发布
- 支持普通、透明、X型三种方块类型
- 可视化配置界面
- 自动生成 MeshLibrary
