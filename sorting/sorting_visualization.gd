extends Control
class_name SortingVisualization

# INPUT
export(int) var item_count : int = 30
export(int) var item_max_value : int = 100
export(Font) var font : Font
export(int) var msec_delay : int = 30

enum {
	SELECTION,
	INSERTION,
	BUBBLE,
	QUICK,
	MERGE
}

var current_sorting : int = -1

var thread : Thread
var array : Array # [value, color]

signal start_sorting()
signal end_sorting()

func _ready() :
	thread = Thread.new()

func array_random(unique : bool) :
	array.clear()
	array.resize(item_count)
		
	if unique :
		for i in range(item_count) :
			array[i] = [int((i + 1) / float(item_count) * (item_max_value)), Color.white]
		array.shuffle()
	else :
		randomize()
		
		for i in range(item_count) :
			array[i] = [int(randi() % 100 + 1),Color.white]
		
	update()
#
const MARGIN := 60
const MARGIN_ITEM := 8

func _draw() :
	if array.empty() :
		return
		
	
	if not font :
		font = get_font("")
	var size := get_size() - Vector2(0, MARGIN)
	var thick : float = get_size().x / array.size()
	var cursor_x : float = 0
		
	for i in range(array.size()) :
		var col := array[i][1] as Color
		var height : int = (float(array[i][0]) / item_max_value) * size.y
		var x : int = size.x / array.size()
		if thick < MARGIN_ITEM * 3 :
			draw_rect(Rect2(cursor_x, size.y - height, thick, height), col)
		else :
			draw_rect(Rect2(cursor_x + MARGIN_ITEM, size.y - height, thick - MARGIN_ITEM, height), col)
		cursor_x += thick
		var strsize := font.get_string_size(str(array[i][0]))
		if strsize.x <= thick :
			draw_string(font, Vector2(int(cursor_x - thick / 2 - strsize.x / 2), size.y + strsize.y + 10), str(array[i][0]), col)


func _on_sort_resized() :
	update()

func sort(which : int) :
	if current_sorting != -1 :
		return
		
	current_sorting = which
	emit_signal("start_sorting")
	# play
	thread.start(self, "selection_sort", self)
	#selection_sort(self)
	#breakpoint
	
func array_set_color(i : int, col : Color) :
	array[i][1] = col
	
func thread_sort_done() :
	thread.wait_to_finish()
	current_sorting = -1
	emit_signal("end_sorting")

func selection_sort(sortv) :
	for i in range(array.size()) :
		
			
		var min_idx = i
		for j in range(i + 1, array.size()) :
			
			sortv.call_deferred("array_set_color", j, Color.cyan)
			sortv.call_deferred("update")
			OS.delay_msec(sortv.msec_delay)
			#if j - 1 > 0 :
			#	sortv.call_deferred("array_set_color", j - 1, Color.white)
			
			if array[min_idx] > array[j] :
				
				sortv.call_deferred("array_set_color", min_idx, Color.white)
				min_idx = j
				sortv.call_deferred("array_set_color", min_idx, Color.red)
			else :
				sortv.call_deferred("array_set_color", j, Color.white)
				sortv.call_deferred("update")
			#sortv.call_deferred("update")
				   
		var a_ = array[i]
		array[i] = array[min_idx]
		array[min_idx] = a_
		sortv.call_deferred("array_set_color", i, Color.green)
		sortv.call_deferred("update")
		#OS.delay_msec(100)
		#sortv.call_deferred("update")
	sortv.call_deferred("thread_sort_done")
