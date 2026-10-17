@tool
extends Resource
class_name SearchResultRes


## Set upon creation and can't be changed.
@export var id := -1:
	set(new_search_result_id): if id == -1: id = new_search_result_id
## This search result will show up if one of these terms is searched (exact)
@export var search_result_keywords: Array[String] = []
@export var discoverable_infos: Array[int] = []
@export_multiline var search_result_text: String = ''

@export_group('Hidden')
@export var visited := false
