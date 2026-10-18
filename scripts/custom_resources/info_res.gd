@tool
extends Resource
class_name InfoRes


## Set upon creation and can't be changed.
@export var id := -1:
	set(new_info_id): if id == -1: id = new_info_id
@export var info_blurb: String = ''

@export_group('Hidden')
@export var discovered_index: int = -1
@export var used := false
@export var discovered_search_sources: Array[int] = []
@export var discovered_portal_sources: Array[int] = []
