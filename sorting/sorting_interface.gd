extends Panel

onready var sort := $vbox/sort as SortingVisualization
onready var rand := $vbox/margin/vbox/hbox/rand as Button
onready var randl := $vbox/margin/vbox/hbox/randl as Button

onready var use_width := $vbox/margin/vbox/hbox/use_width as CheckBox
onready var count := $vbox/margin/vbox/hbox/count as SpinBox # RealSpinSlider
onready var max_ := $vbox/margin/vbox/hbox/max as SpinBox # RealSpinSlider
onready var msort := $vbox/margin/vbox/hbox/sort as OptionButton

onready var play := $vbox/margin/vbox/hbox2/play as Button
onready var delay := $vbox/margin/vbox/hbox2/delay as SpinBox

func _ready() :
	count.value = sort.item_count
	max_.value = sort.item_max_value
	delay.value = sort.msec_delay
	
	#msort.get_popup().connect("id_pressed", self, "_on_id_pressed")

func _on_rand_pressed() :
	sort.array_random(false)


func _on_randl_pressed() :
	sort.array_random(true)


func _on_use_width_toggled(button_pressed) :
	count.editable = not button_pressed


func _on_count_value_changed(value) :
	sort.item_count = value
	#pass # Replace with function body.


func _on_sort_end_sorting() :
	count.editable = true
	max_.editable = true
	rand.disabled = false
	randl.disabled = false
	msort.disabled = false
	
	play.disabled = false
	#delay.editable = true


func _on_sort_start_sorting() :
	count.editable = false
	max_.editable = false
	rand.disabled = true
	randl.disabled = true
	msort.disabled = true
	
	play.disabled = true
	#delay.editable = false


func _on_play_pressed() :
	sort.sort(msort.selected)


func _on_delay_value_changed(value) :
	sort.msec_delay = value


func _on_max_value_changed(value) :
	sort.item_max_value = value
