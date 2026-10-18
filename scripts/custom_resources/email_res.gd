@tool
extends Resource
class_name EmailRes


## Set upon creation and can't be changed.
@export var id := -1:
	set(new_email_id): if id == -1: id = new_email_id
@export var email_subject: String = ''
@export var email_from: String = ''
@export_multiline var email_body: String = ''
## The number of blog posts required to show this email.
@export var email_num_blog_posts: int = 0
## The specific blog posts required to show this email.
@export var email_prereq_blog_posts: Array[int] = []

@export_group('Hidden')
@export var trigger_portal := false
@export var sent_index: int = -1
@export var read := false
