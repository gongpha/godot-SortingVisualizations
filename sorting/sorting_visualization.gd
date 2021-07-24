extends Control
class_name SortingVisualization

# INPUT
export(int) var item_count : int = 30
export(int) var item_max_value : int = 100
export(Font) var font : Font
export(int) var msec_delay : int = 30 setget set_msec_delay

enum {
	SELECTION,
	INSERTION,
	BUBBLE,
	COCKTAIL,
	QUICK,
	MERGE,
	HEAP,
	RADIX_LSD
}

var current_sorting : int = -1

var thread : Thread
var mutex : Mutex
var array : Array # [value, color]

var cancel_flag : bool = false

signal start_sorting()
signal end_sorting()

func set_msec_delay(new_d : int) -> void :
	mutex.lock()
	msec_delay = new_d
	mutex.unlock()

func _ready() :
	Engine.iterations_per_second = 120
	thread = Thread.new()
	mutex = Mutex.new()

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
			array[i] = [int(randi() % item_max_value + 1),Color.white]
		
	update()
	
func array_sorted() :
	array.clear()
	array.resize(item_count)
	
	for i in range(item_count) :
		array[i] = [int((i + 1) / float(item_count) * (item_max_value)), Color.white]
	update()

func array_reversed() :
	array.clear()
	array.resize(item_count)
	
	for i in range(item_count) :
		array[i] = [int((i + 1) / float(item_count) * (item_max_value)), Color.white]
	array.invert()
	update()

const MARGIN := 60
const MARGIN_ITEM := 4

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
			draw_rect(Rect2(cursor_x + MARGIN_ITEM, size.y - height, thick - MARGIN_ITEM * 2, height), col)
		cursor_x += thick
		var strsize := font.get_string_size(str(array[i][0]))
		if strsize.x <= thick :
			draw_string(font, Vector2(int(cursor_x - (thick / 2) - (strsize.x / 2)), size.y + strsize.y + 10), str(array[i][0]), col)

func _on_sort_resized() :
	update()

func sort(which : int) :
	if current_sorting != -1 :
		return
		
	current_sorting = which
	emit_signal("start_sorting")
	# play
	#merge_sort(self)
	#return
	match which :
		SELECTION :
			thread.start(self, "selection_sort")
		INSERTION :
			thread.start(self, "insertion_sort")
		BUBBLE :
			thread.start(self, "bubble_sort")
		COCKTAIL :
			thread.start(self, "cocktail_shaker_sort")
		QUICK :
			thread.start(self, "quick_sort")
		MERGE :
			thread.start(self, "merge_sort")
		HEAP :
			thread.start(self, "heap_sort")
		RADIX_LSD :
			thread.start(self, "radix_sort_lsd")
			
func stop() :
	mutex.lock()
	cancel_flag = true
	mutex.unlock()
	
func thread_array_set_color(i : int, col : Color) :
	mutex.lock()
	array[i][1] = col
	mutex.unlock()
	
func thread_array_set_color_a(ia : Array, col : Color) :
	mutex.lock()
	ia[1] = col
	mutex.unlock()
	
func thread_sleep() :
	if msec_delay > 0 :
		OS.delay_msec(msec_delay)
		
func thread_swap(array : Array, a : int, b : int) :
	#mutex.lock()
	var a_ = array[a]
	array[a] = array[b]
	array[b] = a_
	#mutex.unlock()
	
func thread_sort_done() :
	thread.wait_to_finish()
	current_sorting = -1
	cancel_flag = false
	update()
	emit_signal("end_sorting")
	
func _process(delta : float) :
	if current_sorting != -1 :
		update()
	
###########################################################
###########################################################
###########################################################

func selection_sort(u) :
	for i in range(array.size()) :			
		var min_idx = i
		for j in range(i + 1, array.size()) :
			if cancel_flag :
				call_deferred("thread_sort_done")
				return
			#sortv.call_deferred("array_set_color", j, Color.cyan)
			thread_array_set_color(j, Color.cyan)
			#ortv.call_deferred("update")
			thread_sleep()
			#if j - 1 > 0 :
			#	sortv.call_deferred("array_set_color", j - 1, Color.white)
			
			if array[min_idx][0] > array[j][0] :
				thread_array_set_color(min_idx, Color.white)
				#sortv.call_deferred("array_set_color", min_idx, Color.white)
				min_idx = j
				thread_array_set_color(min_idx, Color.red)
				#sortv.call_deferred("array_set_color", min_idx, Color.red)
			else :
				thread_array_set_color(j, Color.white)
				#sortv.call_deferred("array_set_color", j, Color.white)
			#sortv.call_deferred("update")
				   
		thread_swap(array, i, min_idx)
		thread_array_set_color(i, Color.white)
		#sortv.call_deferred("array_set_color", i, Color.green)
		#OS.delay_msec(100)
		#sortv.call_deferred("update")
	call_deferred("thread_sort_done")

func insertion_sort(u) :
	for i in range(1, array.size()) :
		if cancel_flag :
			call_deferred("thread_sort_done")
			return
			
		var key = array[i]
		thread_array_set_color(i, Color.white)
		var j : int = i - 1
		while j >= 0 and key[0] <= array[j][0] :
			thread_sleep()
			thread_array_set_color_a(key, Color.red)
			thread_swap(array, j, j + 1)
			j -= 1
		thread_array_set_color(j + 1, Color.white)
	call_deferred("thread_sort_done")
	
func bubble_sort(u) :
	for i in range(array.size() - 1) :
		if cancel_flag :
			call_deferred("thread_sort_done")
			return
			
		for j in range(array.size() - i - 1) :
			if array[j][0] > array[j + 1][0] :
				thread_array_set_color(j, Color.red)
				thread_sleep()
				thread_array_set_color(j, Color.white)
				thread_swap(array, j, j + 1)
	call_deferred("thread_sort_done")
	
func cocktail_shaker_sort(u) :
	var swapped : bool = true
	var start : int = 0
	var end : int = array.size() - 1
	
	while swapped :
		if cancel_flag :
			call_deferred("thread_sort_done")
			return
			
		swapped = false
		for i in range(start, end) :
			if array[i][0] > array[i + 1][0] :
				thread_array_set_color(i, Color.red)
				thread_sleep()
				thread_array_set_color(i, Color.white)
				thread_swap(array, i, i + 1)
				swapped = true
		if not swapped :
			break
		swapped = false
		end -= 1
		var i : int = end - 1
		while i >= start :
			if array[i][0] > array[i + 1][0] :
				thread_array_set_color(i, Color.red)
				thread_sleep()
				thread_array_set_color(i, Color.white)
				thread_swap(array, i, i + 1)
				swapped = true
			i -= 1
		start += 1
	call_deferred("thread_sort_done")
	
func quick_select_pivot(lo : int, hi : int) :
	var pivot : Array = array[hi]
	var i : int = lo - 1
	
	var j : int = lo
	while j <= hi - 1 :
		if cancel_flag :
			return null
			
		if array[j][0] <= pivot[0] :
			thread_array_set_color(j, Color.cyan)
			thread_sleep()
			thread_array_set_color(j, Color.white)
			i += 1
			thread_swap(array, i, j)
		j += 1
	thread_swap(array, i + 1, hi)
	return i + 1
	
func quick_ext(lo : int, hi : int) :
	if lo < hi :
		var pi : int = quick_select_pivot(lo, hi)
		thread_array_set_color(pi, Color.red)
		quick_ext(lo, pi - 1)
		quick_ext(pi + 1, hi)
		if pi == null :
			call_deferred("thread_sort_done")
			return
		thread_array_set_color(pi, Color.white)
	
	
func quick_sort(u) :
	quick_ext(0, array.size() - 1)
	call_deferred("thread_sort_done")
	
func merge_element(lo : int, mid : int, hi : int) -> bool :
	thread_array_set_color(lo, Color.red)
	thread_array_set_color(mid, Color.cyan)
	thread_array_set_color(hi - 1, Color.white)
	
	var out : Array
	out.resize(hi - lo)
	var i : int = lo
	var j : int = mid
	var o : int = 0
	
	while i < mid and j < hi :
		if cancel_flag :
			call_deferred("thread_sort_done")
			return false
			
		var ai := array[i] as Array
		var aj := array[j] as Array
		if ai[0] < aj[0] :
			i += 1
			out[o] = ai
		else :
			j += 1
			out[o] = aj
		o += 1
		
	while i < mid :
		out[o] = array[i]
		o += 1
		i += 1
	while j < hi :
		out[o] = array[j]
		o += 1
		j += 1
		
	if o == hi - lo :
		thread_array_set_color(mid, Color.white)
	
	i = 0
	while i < hi - lo :
		if i <= mid :
			thread_array_set_color(mid, Color.cyan)
		thread_sleep()
		thread_array_set_color_a(out[i], Color.white)
		array[lo + i] = out[i]
		i += 1
	
	thread_array_set_color(lo, Color.white)
	thread_array_set_color(hi - 1, Color.white)
	return true
	
func merge_ext(lo : int, hi : int):
	if lo + 1 < hi :
		var mid : int = (lo + hi) / 2
		merge_ext(lo, mid)
		merge_ext(mid, hi)
		var res := merge_element(lo, mid, hi)
		if res == false :
			return

func merge_sort(u) :
	merge_ext(0, array.size())
	call_deferred("thread_sort_done")

func heap_sort(u) :
	var n : int = array.size()
	var i : int = n / 2
	
	var j = i
	while j < n : 
		thread_array_set_color(j, Color(0.25, 1, ((j + 1) * 10) / 256.0))
		j += 1
		
	while true :
		if cancel_flag :
			call_deferred("thread_sort_done")
			return
			
		if i > 0 :
			i -= 1
		else :
			n -= 1
			if n == 0 :
				call_deferred("thread_sort_done")
				return
			thread_array_set_color(0, Color.cyan)
			thread_sleep()
			thread_array_set_color(0, Color.white)
			thread_swap(array, 0, n)
			
			thread_array_set_color(n, Color.red)
			if n + 1 < array.size() :
				thread_array_set_color(n + 1, Color.white)
				
		var parent : int = i
		var child : int = i * 2 + 1
		
		while child < n :
			if child + 1 < n and array[child + 1][0] > array[child][0] :
				child += 1
			if array[child][0] > array[parent][0] :
				thread_array_set_color(parent, Color.cyan)
				thread_sleep()
				thread_array_set_color(parent, Color.white)
				thread_swap(array, parent, child)
				parent = child
				child = parent * 2 + 1
			else :
				break
		thread_array_set_color(i, Color(0.25, ((i + 1) * 10) / 256.0, 1))

func count_sort(exp_ : int) :
	
	var output : PoolIntArray
	output.resize(array.size())
	for a in range(output.size()) :
		output[a] = 0
	var i : int
	var count : PoolIntArray
	count.resize(10)
	for a in range(count.size()) :
		count[a] = 0
	
	i = 0
	while i < array.size() :
		thread_array_set_color(i, Color.cyan)
		thread_sleep()
		thread_array_set_color(i, Color.white)
		count[(array[i][0] / exp_) % 10] += 1
		i += 1
		
	i = 1
	while i < 10 :
		count[i] += count[i - 1]
		i += 1
		
	i = array.size() - 1
	while i >= 0 :
		var exp__ : int = (array[i][0] / exp_) % 10
		output[count[exp__] - 1] = array[i][0]
		count[exp__] -= 1
		i -= 1
		
	i = 0
	while i < array.size() :
		thread_array_set_color(i, Color.red)
		thread_sleep()
		thread_array_set_color(i, Color.white)
		array[i][0] = output[i]
		i += 1

func radix_sort_lsd(u) :
	if array.empty() :
		call_deferred("thread_sort_done")
		return
		
	var exp_ : int
	var max_ = array[0][0]
	
	var i : int = 1
	while i < array.size() :
		if array[i][0] > max_ :
			max_ = array[i][0]
		i += 1
	
	exp_ = 1
	while max_ / exp_ > 0 :
		if cancel_flag :
			call_deferred("thread_sort_done")
			return
			
		count_sort(exp_)
		exp_ *= 10
	call_deferred("thread_sort_done")
