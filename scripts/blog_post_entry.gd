extends PanelContainer
class_name BlogPostEntry


@onready var title_label: Label = %TitleLabel
@onready var blurb_label: RichTextLabel = %BlurbLabel
@onready var infos_vbox: Container = %InfosVBox
@onready var publish_button: BaseButton = %PublishButton

var own_post_id: int = -1


func _check_refs() -> void:
	if title_label == null: title_label = %TitleLabel
	if blurb_label == null: blurb_label = %BlurbLabel
	if infos_vbox == null: infos_vbox = %InfosVBox
	if publish_button == null: publish_button = %PublishButton


func set_up_blog_post(post: BlogPostRes) -> void:
	_check_refs()
	own_post_id = post.id
	title_label.text = post.post_title
	blurb_label.hide()
	blurb_label.text = post.post_blurb
	for i in range(post.post_required_infos.size()):
		var info_button: BlogInfoButton = GameState.info_button_scene.instantiate()
		info_button.assigned_info_id_updated.connect(_update_assigned_infos)
		if post.assigned_infos.size() > i:
			info_button.assigned_info_id = post.assigned_infos[i]
			info_button.text = GameState.get_entry(GameState.infos, post.assigned_infos[i]).info_blurb
			info_button.theme_type_variation = 'SmallButtonEntryFilled'
		infos_vbox.add_child(info_button)
	publish_button.disabled = true
	publish_button.pressed.connect(_publish_post.bind(true))
	
	if post.published_index > -1: _publish_post(false)
	else: _check_if_can_publish_post()


func _update_assigned_infos() -> void:
	var post_entry: BlogPostRes = GameState.get_entry(GameState.blog_posts, own_post_id)
	post_entry.assigned_infos.clear()
	for child: BlogInfoButton in infos_vbox.get_children():
		if child.assigned_info_id > -1:
			post_entry.assigned_infos.append(child.assigned_info_id)
	_check_if_can_publish_post()


func _check_if_can_publish_post() -> void:
	_check_refs()
	var post_entry: BlogPostRes = GameState.get_entry(GameState.blog_posts, own_post_id)
	for info_id in post_entry.post_required_infos:
		if !post_entry.assigned_infos.has(info_id):
			publish_button.disabled = true
			return
	publish_button.disabled = false


func _publish_post(emit: bool) -> void:
	_check_refs()
	self.add_theme_stylebox_override('panel', GameState.published_post_style_box)
	blurb_label.show()
	for info in infos_vbox.get_children():
		info.disabled = true
	publish_button.disabled = true
	publish_button.text = 'Published'
	if emit:
		var own_post: BlogPostRes = GameState.get_entry(GameState.blog_posts, own_post_id)
		own_post.published_index = GameState.get_found_index(GameState.blog_posts, 'published_index')
		for info in own_post.post_required_infos:
			GameState.get_entry(GameState.infos, info).used = true
		GameState.blog_post_submitted.emit(own_post_id)
