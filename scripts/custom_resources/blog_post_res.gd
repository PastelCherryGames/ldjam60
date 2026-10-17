@tool
extends Resource
class_name BlogPostRes


## Set upon creation and can't be changed.
@export var id := -1:
	set(new_post_id): if id == -1: id = new_post_id
@export var post_title: String = ''
@export_multiline var post_blurb: String = ''
@export var post_required_infos: Array[int] = []

@export_group('Unlock Requirements')
@export var email_prereqs: Array[int] = []
@export var info_prereqs: Array[int] = []

@export_group('Hidden')
## Controls the order blog posts are show in.
@export var unlocked_index: int = -1
## Controls the order blog posts are show in.
@export var published_index: int = -1
## Infos the player has assigned to post.
@export var assigned_infos: Array[int] = []
