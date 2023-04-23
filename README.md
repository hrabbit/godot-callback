# Godot callback helper

Simply put, this plugin allows any script to register itself as a callback for hook labels and be included in a chain based on priority before finally outputing the parameters to a destination of choice.

## Example

While building an incremental game for myself to learn Godot, the ability to alter "scores" within the game itself from one game object through many objects before being applied to the player score was looking to be a management nightmare.

By using a single registration and iteration engine to perform these routines, I am now able to add nodes to the platform which register local methods against a registry for particular "callback keys" and have the payload modified however needed.

Further, the ability to perform these actions using a weight/priority allows for processing particular rules before other rules in different parts of the game.

eg.

* Player clicks a button which adds 1 point to the system.
* Player purchases a modifier that should double all points from the player clicking a button.
* Modifier registers itself as a callback for points being added from click from button.
* Player clicks the button which performs a callback into the plugin, this in turns calls all the registered callbacks in sequence, passing the paramaters along each time.
* The modifier accepts the request with the payload, performs the double on the score and returns the payload to the callback plugin.
* Once the last callback is called, the "finally" callback is called which is responsible for storing the final value.

## Usage

Normally this plugin would be dropped into your addones directory, then the callbackhelper.gd file would be autoloaded in order to be available globally, but this has only been my usecase and yours may vary.
#### Button gdscript
```
# Register a normal signal to be used for sending data initially.
signal player_clicked_the_button(source: String, params: Dictionary, finally: Callable)

# Fire the payload into the signal to be intercepted
func _on_button_up():
	player_clicked_the_button.emit("player_clicks_button", {"score": 1}, $Score._apply_score)

```

#### Modifier gdscript
```
# Register with the callback helper, the "player_clicks_button" registry key is defined for this particular ruleset.
# The callback_double_score is the method that will be called in the chain
# The int (optional), defined the priority in the chain, with lower values being run first, after this, all callables are ordered by the sequence they were added to the registry
func _ready():
	Callback.add("player_clicks_button", self.callback_double_score, 2)

# The callback method itself, is fine to modify the params dictionary as much as required, but must return it afterwards.
func callback_double_score(params: Dictionary) -> Dictionary:
	# Perform an action on the params dictionary
	params['score'] *= 2
	return params
```

#### Score maintaining gdscript

```
var score = 0

# Listen for the signal
func _ready():
	$Button1.connect("player_clicked_the_button", process_callback)

# Fire off the callback chain and receive back the param dictionary with any modifications in place.
func process_callback(registryKey: String, params: Dictionary, finally: Callable):
	var resultingParams = Callback.run(registryKey, params)
	finally.call(resultingParams)
	pass
	
# The finally endpoint as defined in the process_callback method, after all callbacks are complete, this is the final endpoint.
func _apply_score(params: Dictionary):
	score += params['score']
	
```
