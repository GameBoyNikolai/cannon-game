extends Node
class_name Story

func intro_text() -> Array[String]:
	var speaker = "Commander Ballari"
	return [
		speaker + ":
Are you awake yet? Give an ack on your radio to let me know you can hear me.",
		speaker + ": 
Looks like that last blast really shook you up. You might be experiencing some amnesia, but we need you back up and running ASAP.",
		speaker + ":
Take a look at the terminal there to see what we need and how we need it.",
		speaker + ":
But hurry, our sources say we have another attack expected soon."
	]
