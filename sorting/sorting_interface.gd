extends Panel

onready var sort := $vbox/sort as SortingVisualization
onready var rand := $vbox/margin/vbox/hbox/rand as Button
onready var randl := $vbox/margin/vbox/hbox/randl as Button
onready var sorted := $vbox/margin/vbox/hbox/sorted as Button
onready var reversed := $vbox/margin/vbox/hbox/reversed as Button

onready var count := $vbox/margin/vbox/hbox/count as SpinBox # RealSpinSlider
onready var max_ := $vbox/margin/vbox/hbox/max as SpinBox # RealSpinSlider
onready var msort := $vbox/margin/vbox/hbox/sort as OptionButton

onready var play := $vbox/margin/vbox/hbox2/play as Button
onready var stop := $vbox/margin/vbox/hbox2/stop as Button
onready var delay := $vbox/margin/vbox/hbox2/delay as SpinBox

func _ready() :
	count.value = sort.item_count
	max_.value = sort.item_max_value
	delay.value = sort.msec_delay
	
func _on_rand_pressed() :
	sort.array_random(false)

func _on_randl_pressed() :
	sort.array_random(true)

func _on_count_value_changed(value) :
	sort.item_count = value

func _on_sort_end_sorting() :
	count.editable = true
	max_.editable = true
	rand.disabled = false
	randl.disabled = false
	sorted.disabled = false
	reversed.disabled = false
	msort.disabled = false
	
	play.disabled = false
	stop.disabled = true

func _on_sort_start_sorting() :
	count.editable = false
	max_.editable = false
	rand.disabled = true
	randl.disabled = true
	sorted.disabled = true
	reversed.disabled = true
	msort.disabled = true
	
	play.disabled = true
	stop.disabled = false

func _on_play_pressed() :
	sort.sort(msort.selected)

func _on_delay_value_changed(value) :
	sort.msec_delay = value

func _on_max_value_changed(value) :
	sort.item_max_value = value

func _on_stop_pressed():
	sort.stop()
	stop.disabled = true

func _on_sorted_pressed() :
	sort.array_sorted()


func _on_reversed_pressed() :
	sort.array_reversed()
