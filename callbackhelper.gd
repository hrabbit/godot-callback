extends Node

var registry = {}

func add(registryKey: String, callback, priority: int = 0) -> bool:
	if(registryKey not in self.registry):
		self.registry[registryKey] = []
		
	self.registry[registryKey].append({ "callback": callback, "priority": priority })
	return true

func remove(registryKey: String, callback) -> bool:
	if(registryKey not in self.registry):
		return false

	self.registry[registryKey] = self.registry[registryKey] \
		.filter(func(entry): return entry.callback != callback)
	return true		

func run(registryKey, params: Dictionary) -> Dictionary:
	var calculatedParams = params
	for hook in self.buildCallbacks(registryKey):
		calculatedParams = hook.callback.call(calculatedParams)
	return calculatedParams

func buildCallbacks(registryKey: String) -> Array:
	if(registryKey not in self.registry):
		return []

	var list = self.registry[registryKey]
	list.sort_custom(self._sort)
	return list

func _sort(a, b):
	if(a.priority < b.priority):
		return true

func empty(registryKey: String) -> bool:
	if(registryKey in self.registry):
		self.registry[registryKey] = []
	return true
