extends Control
class_name Main


@onready var start_screen: CustomTweener = %StartScreen


func _ready() -> void:
	start_screen.show()
	await start_screen.toggle_finished
	await get_tree().create_timer(0.5).timeout
	GameState.app_requested.emit(E.App.EMAIL)
	remove_child(start_screen)
	start_screen.queue_free()


## DEBUG for fun
func _count_words() -> void:
	var word_count: int = 0
	for email in GameState.emails:
		word_count += email.email_body.countn(' ') + 1
	for result in GameState.search_results:
		word_count += result.search_result_text.countn(' ') + 1
	for result in GameState.portal_search_results:
		word_count += result.search_result_text.countn(' ') + 1
	for info in GameState.infos:
		word_count += info.info_blurb.countn(' ') + 1
	
	print(word_count)
