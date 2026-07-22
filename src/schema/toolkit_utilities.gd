extends Object
class_name Toolkitu

# I hold a bunch of nice utility functions
const game_name := "Toolkit"

enum ll { ## Log Levels, use with [method Toolkitu.logm]
	## Prints a simple but explicit debug message.
	DEBUG, 
	## Prints a simple but explicit debug message with a stack trace.
	TRACE, 
	## Prints a simple but explicit debug message in aquamarine.
	INFO, 
	## Prints a simple but explicit debug message in goldenrod.
	WARN, 
	## Prints a simple but explicit debug message in goldenrod and pushes a warning.
	ALERT, 
	## Prints a simple but explicit error message.
	ERROR, 
	## Prints a simple but explicit error message and pushes an error.
	FATAL, 
	## Prints a simple but explicit error message and stops the game.
	ASSERT, 
}

## Picks a number between 0 and [param mx] (inclusive). Include seed and state if you want repeatable results.
static func pick(mx : int, sd : int = 0, state : int = 0) -> int:
	var rng := RandomNumberGenerator.new()
	if sd != 0: rng.seed = sd
	if state != 0: rng.state = state
	return rng.randi_range(0,mx)

## Returns true if a random number is less than [param c]. Include seed and state if you want repeatable results.
static func roll(c : float, sd : int = 0, state : int = 0) -> bool:
	var rng := RandomNumberGenerator.new()
	if sd != 0: rng.seed = sd
	if state != 0: rng.state = state
	if rng.randf() < c: return true
	return false

## Returns true or false (50:50). Include seed and state if you want repeatable results.
static func coinflip(sd : int = 0, state : int = 0) -> bool:
	var rng := RandomNumberGenerator.new()
	if sd != 0: rng.seed = sd
	if state != 0: rng.state = state
	return [true,false][rng.randi_range(0,1)]

## Checks if [param sub_array] is contained [b]exactly[/b] within [param main_array]
static func subarr(sub_array : Array, main_array : Array) -> bool:
	for i in sub_array:
		if !main_array.has(i): return false
		if main_array.count(i) != sub_array.count(i): return false
	return true

## Checks if [param sub_array] is contained [b]loosely[/b] within [param main_array]
static func subarr_nc(sub_array : Array, main_array : Array) -> bool:
	#nc means no count
	for i in sub_array:
		if !main_array.has(i): return false
	return true

## Returns a comma seperated integer. eg. 1000 -> 1,000
static func comma_sepi(n: int) -> String:
	var result := ""
	var i: int = absi(n)
	
	while i > 999:
		result = ",%03d%s" % [i % 1000, result]
		i /= 1000
	
	return "%s%s%s" % ["-" if n < 0 else "", i, result]

## Returns a comma seperated float. eg. 1000.0 -> 1,000.0
static func comma_sepf(n: float) -> String:
	var remainder := fmod(n,roundf(n))
	var result := comma_sepi(int(floorf(n)))
	return result + str(remainder).erase(0)

## Returns a bar comparing [param a] to [param b]. eg. "[■■■■■■■\■■■] (a = 366)"
static func visually_compare_floats(
	a : float, b : float, length : int = 10, 
	bbcode := true, colr := Color("#f2b63d"), 
	labls : Array[String] = ["a","b","[","■","\\","■","]"]
	) -> String:
	
	## Styling
	const default_style : Array[String] = ["a","b","[","■","\\","■","]"]
	var avl := default_style[0] if labls.is_empty() else labls[0]
	var bvl := default_style[1] if labls.size() <= 1 else labls[1]
	var start_cap := default_style[2] if labls.size() <= 2 else labls[2]
	var min_unit := default_style[3] if labls.size() <= 3 else labls[3]
	var seperator := default_style[4] if labls.size() <= 4 else labls[4]
	var max_unit := default_style[5] if labls.size() <= 5 else labls[5]
	var end_cap := default_style[6] if labls.size() <= 6 else labls[6]
	const readout := " (%s = %s)"
	const readoutbb := " ([b]%s[/b] = [i]%s[/i])"
	
	## Bar Construction
	var minv := minf(a,b)
	var maxv := maxf(a,b)
	var perc : float = float(minv) / float(maxv)
	var minbar : int = int(floorf(float(length) * perc))
	var final_string := ""
	final_string += start_cap
	if bbcode: final_string += "[color=%s]" % colr.to_html()
	for i in minbar:
		final_string += min_unit
	if bbcode: final_string += "[/color]"
	final_string += seperator
	for i in length - minbar:
		final_string += max_unit
	final_string += end_cap
	
	var maxl : String
	if a > b: maxl = avl
	else: maxl = bvl
	if bbcode:
		final_string += readoutbb % [maxl,str(maxv)]
	else: final_string += readout % [maxl,str(maxv)]
	
	return final_string

## Searches (optionally, recursively) [param parent] for children with types specified in [param types]. If [param all] is true, it will return all the children instead of the first found.
static func search_children(parent : Node, types : Array[Node], all : bool = false, max_depth : int = 0, current_depth : int = 0) -> Array[Node]:
	var results : Array[Node] = []
	var query : Array = []
	for type in types:
		var script = type.get_script()
		if script == null: continue
		query.append(script)
	
	for child : Node in parent.get_children():
		if child.get_script() in query:
			results.append(child)
			if !all: break
			
		if current_depth < max_depth:
			var new_result := search_children(child,types,all,max_depth,current_depth + 1)
			if !new_result.is_empty(): results.append_array(new_result)
	
	return results

## Gets the lowest, closest integer in the specified [param array]
static func get_lowcloi(number : int, array : Array) -> int:
	var closest : int = array.min()
	for i : int in array:
		if i <= number and i > closest:
			closest = i
	return closest

## Gets the lowest, closest float in the specified [param array]
static func get_lowclof(number : float, array : Array) -> float:
	var closest : float = array.min()
	for i : float in array:
		if i <= number and i > closest:
			closest = i
	return closest

## Prints a nice log message.
static func logm(msg : String,level : ll = ll.DEBUG,from : String = "",additional_details : Dictionary = {}) -> void:
	var lm : Dictionary = {
		"&level": ll.find_key(level),
		"&script":from,
		"&messsage":msg,
	}
	var gn := game_name.to_lower()
	if from == "": lm.erase("&script")
	if !additional_details.is_empty():
		lm.merge(additional_details)
	match level:
		ll.DEBUG: #simple
			print("[%s_debug] %s " % [gn,msg],JSON.stringify(lm,"	"))
		ll.TRACE: #simple but prints stack
			print("[%s_trace] %s " % [gn,msg],JSON.stringify(lm,"	"))
			print_stack()
		ll.INFO: #prints in cyan
			print_rich("[color=aquamarine][%s_info] [b]%s[/b][/color] " % [gn,msg],JSON.stringify(lm,"	"))
		ll.WARN: #prints in yellow
			print_rich("[color=goldenrod][%s_warning] [b]%s[/b][/color] " % [gn,msg],JSON.stringify(lm,"	"))
		ll.ALERT: #prints in yellow and push warning to the debugger
			print_rich("[color=goldenrod][%s_warning] [b]%s[/b][/color] " % [gn,msg],JSON.stringify(lm,"	"))
			push_warning("[!] %s" % msg)
		ll.ERROR: #printerr
			printerr("[%s_err] %s " % [gn,msg],JSON.stringify(lm,"	"))
		ll.FATAL: #printerr and push error to debugger
			printerr("[%s_err!] %s " % [gn,msg],JSON.stringify(lm,"	"))
			push_error("[err!] %s " % msg)
		ll.ASSERT: #printerr and stops game
			printerr("[%s_err!] %s " % [gn,msg],JSON.stringify(lm,"	"))
			assert(false, "[err!] %s " % msg)
