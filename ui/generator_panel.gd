@tool
extends Control

const BlockType = Generator.BlockType

@onready var texture_line_edit: LineEdit = $VBox/TextureSection/HBox/TexturePath
@onready var browse_btn: Button = $VBox/TextureSection/HBox/BrowseBtn
@onready var output_line_edit: LineEdit = $VBox/OutputSection/HBox/OutputPath
@onready var output_browse_btn: Button = $VBox/OutputSection/HBox/OutputBrowseBtn
@onready var grid_container: GridContainer = $VBox/ScrollContainer/GridContainer
@onready var generate_btn: Button = $VBox/GenerateBtn
@onready var status_label: Label = $VBox/StatusLabel

var file_dialog: FileDialog
var output_dialog: FileDialog

var block_configs: Array[int] = []
var grid_buttons: Array[Button] = []
var texture_path: String = ""
var output_dir: String = "res://gridmap_assets/"

var type_colors := {
	BlockType.SKIP: Color(0.3, 0.3, 0.3),
	BlockType.NORMAL: Color(0.6, 0.6, 0.6),
	BlockType.TRANSPARENT: Color(0.3, 0.5, 0.8),
	BlockType.CROSS: Color(0.3, 0.7, 0.3),
}

var type_names := {
	BlockType.SKIP: "跳过",
	BlockType.NORMAL: "普通",
	BlockType.TRANSPARENT: "透明",
	BlockType.CROSS: "X型",
}


func _ready() -> void:
	block_configs.resize(64)
	block_configs.fill(BlockType.SKIP)
	
	_setup_ui()
	_create_grid_buttons()
	_create_file_dialogs()


func _setup_ui() -> void:
	texture_line_edit.text = texture_path
	texture_line_edit.editable = false
	texture_line_edit.placeholder_text = "点击右侧按钮选择纹理图片..."
	
	output_line_edit.text = output_dir
	output_line_edit.editable = false
	
	browse_btn.text = "选择纹理"
	browse_btn.pressed.connect(_on_browse_texture)
	
	output_browse_btn.text = "选择目录"
	output_browse_btn.pressed.connect(_on_browse_output)
	
	generate_btn.text = "生成 GridMap 资源"
	generate_btn.pressed.connect(_on_generate_pressed)
	
	status_label.text = "请在上方选择纹理图片，然后在下方网格中配置方块类型"


func _create_grid_buttons() -> void:
	for child in grid_container.get_children():
		child.queue_free()
	grid_buttons.clear()
	
	grid_container.columns = 8
	
	for i in range(64):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(36, 36)
		btn.text = str(i)
		btn.tooltip_text = "ID: %d\n点击切换类型" % i
		_update_button_style(btn, i)
		btn.pressed.connect(_on_grid_button_pressed.bind(i))
		grid_container.add_child(btn)
		grid_buttons.append(btn)


func _create_file_dialogs() -> void:
	file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.filters = ["*.png ; PNG Images", "*.jpg ; JPEG Images", "*.webp ; WebP Images"]
	file_dialog.title = "选择纹理图片"
	file_dialog.file_selected.connect(_on_texture_selected)
	add_child(file_dialog)
	
	output_dialog = FileDialog.new()
	output_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	output_dialog.access = FileDialog.ACCESS_RESOURCES
	output_dialog.title = "选择输出目录"
	output_dialog.dir_selected.connect(_on_output_selected)
	add_child(output_dialog)


func _update_button_style(btn: Button, block_id: int) -> void:
	var block_type: int = block_configs[block_id]
	btn.modulate = type_colors[block_type]
	
	var type_name: String = type_names.get(block_type, "未知")
	btn.tooltip_text = "ID: %d\n类型: %s\n点击切换类型" % [block_id, type_name]


func _on_browse_texture() -> void:
	file_dialog.popup_centered(Vector2i(800, 600))


func _on_browse_output() -> void:
	output_dialog.popup_centered(Vector2i(800, 600))


func _on_texture_selected(path: String) -> void:
	texture_path = path
	texture_line_edit.text = path
	_load_texture_previews(path)
	set_all_to_type(BlockType.NORMAL)
	status_label.text = "已选择纹理: %s (所有方块已设为普通类型)" % path


func _on_output_selected(path: String) -> void:
	output_dir = path
	if not output_dir.ends_with("/"):
		output_dir += "/"
	output_line_edit.text = output_dir


func _load_texture_previews(path: String) -> void:
	if not ResourceLoader.exists(path):
		return
	
	var tex: Texture2D = load(path)
	if not tex:
		return
	
	var image := tex.get_image()
	if image.is_compressed():
		image.decompress()
	
	var tile_size := image.get_width() / 8
	
	for i in range(64):
		@warning_ignore("integer_division")
		var row := i / 8
		var col := i % 8
		var tile_img := image.get_region(Rect2i(col * tile_size, row * tile_size, tile_size, tile_size))
		var tile_tex := ImageTexture.create_from_image(tile_img)
		grid_buttons[i].icon = tile_tex
		grid_buttons[i].text = ""


func _on_grid_button_pressed(block_id: int) -> void:
	var current_type: int = block_configs[block_id]
	var next_type: int = (current_type + 1) % 4
	block_configs[block_id] = next_type
	
	_update_button_style(grid_buttons[block_id], block_id)
	
	var type_name: String = type_names.get(next_type, "未知")
	status_label.text = "方块 %d 已设置为: %s" % [block_id, type_name]


func _on_generate_pressed() -> void:
	if texture_path.is_empty():
		status_label.text = "错误：请先选择纹理图片！"
		status_label.add_theme_color_override("font_color", Color.RED)
		return
	
	var has_valid_blocks := false
	for i in range(64):
		if block_configs[i] != BlockType.SKIP:
			has_valid_blocks = true
			break
	
	if not has_valid_blocks:
		status_label.text = "错误：请至少选择一个方块类型！"
		status_label.add_theme_color_override("font_color", Color.RED)
		return
	
	status_label.text = "正在生成资源..."
	status_label.add_theme_color_override("font_color", Color.YELLOW)
	
	var config := {
		"texture_path": texture_path,
		"output_dir": output_dir,
		"blocks": block_configs,
	}
	
	var success := Generator.generate(config)
	
	if success:
		status_label.text = "资源生成成功！保存至: %s" % output_dir
		status_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		status_label.text = "资源生成失败，请检查控制台输出"
		status_label.add_theme_color_override("font_color", Color.RED)


func set_all_to_type(block_type: int) -> void:
	for i in range(64):
		block_configs[i] = block_type
		_update_button_style(grid_buttons[i], i)


func clear_all() -> void:
	set_all_to_type(BlockType.SKIP)
	status_label.text = "已清除所有方块配置"
