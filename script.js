var wsUrl = "ws://localhost/";

websocket = new WebSocket(wsUrl);
websocket.onopen = function(evt){ console.log("Connected."); };
websocket.onmessage = function(evt){ console.log(evt.data); handleMessage(evt.data); };
websocket.onclose = function(evt){
	console.log("Closed.");
};

function handleMessage(msg){
	var match_data = msg.match(/(.+?):(\d+)(?:->)?({.+?})?/);
	var command = match_data[1];
	var target = document.getElementById('item-' + match_data[2]);
	var data = JSON.parse(match_data[3]);
	switch (command){
		case 'update':
			target.properties = data;
			target.value = data.value;
	}
}

function getId(obj){
	return obj.id.match(/item-(\d+)/)[1];
}

var buttons = document.getElementsByTagName('input');
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
		websocket.send("update:" + getId(this) + "->" + JSON.stringify(value));
		websocket.send("input:" + getId(this));
	});
}

var textareas = document.getElementsByTagName('textarea');
for(i=0; i<textareas.length; i++){
	textareas[i].addEventListener('change', function(){
		var value = {value: this.value};
		websocket.send("change:" + getId(this) + "->" + JSON.stringify(value));
	});
}