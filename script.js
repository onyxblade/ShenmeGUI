var wsUrl = "ws://localhost/";

websocket = new WebSocket(wsUrl);
websocket.onopen = function(evt){ console.log("Connected."); };
websocket.onmessage = function(evt){ console.log(evt.data); };
websocket.onclose = function(evt){ console.log("Closed."); };

function getId(obj){
	return obj.id.match(/item-(\d+)/)[1];
}

var buttons = document.getElementsByTagName('button');
var i;
for(i=0; i<buttons.length; i++){
	buttons[i].addEventListener('click', function(){
		websocket.send("click:" + getId(this));
	});
}

var inputs = document.getElementsByTagName('input');
for(i=0; i<inputs.length; i++){
	inputs[i].addEventListener('input', function(){
		var value = {value: this.value};
		websocket.send("change:" + getId(this) + "->" + JSON.stringify(value));
	});
}

var textareas = document.getElementsByTagName('textarea');
for(i=0; i<textareas.length; i++){
	textareas[i].addEventListener('change', function(){
		var value = {value: this.value};
		websocket.send("change:" + getId(this) + "->" + JSON.stringify(value));
	});
}