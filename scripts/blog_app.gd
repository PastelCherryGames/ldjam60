extends CustomWindow
class_name BlogApp


@onready var empty_label: Label = %EmptyLabel
@onready var infos_vbox: Container = %InfosVBox
@onready var blog_posts_vbox: Container = %BlogPostsVBox


func _ready() -> void:
	super()
	GameState.blog_post_unlocked.connect(_refresh_posts)
	_refresh_infos()
	_refresh_posts()


func toggle_window(should_show: bool) -> void:
	super(should_show)
	if should_show:
		_refresh_infos()
		_refresh_posts()


func _refresh_infos() -> void:
	for child in infos_vbox.get_children():
		infos_vbox.remove_child(child)
		child.queue_free()
	GameState.infos.sort_custom(GameState.sort_infos)
	for info in GameState.infos:
		if info.discovered_index > -1:
			if empty_label.visible: empty_label.hide()
			var entry: InfoEntry = GameState.info_entry_scene.instantiate()
			entry.set_up_info_entry(info)
			infos_vbox.add_child(entry)
			infos_vbox.move_child(entry, 0)


func _refresh_posts() -> void:
	for child in blog_posts_vbox.get_children():
		blog_posts_vbox.remove_child(child)
		child.queue_free()
	GameState.blog_posts.sort_custom(GameState.sort_blog_posts)
	for post in GameState.blog_posts:
		if post.unlocked_index > -1:
			var entry: BlogPostEntry = GameState.blog_post_entry_scene.instantiate()
			entry.set_up_blog_post(post)
			blog_posts_vbox.add_child(entry)
			## uncomment if posts are in wrong order
			#blog_posts_vbox.move_child(entry, 0)
