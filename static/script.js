//websocket设置
var websocket = 
(function configureWebSocket(){
	var wsUrl = "ws://localhost/";

	var websocket = new WebSocket(wsUrl);
	websocket.onopen = function(evt){
		console.log("Connected.");
	};
	websocket.onmessage = function(evt){
		console.log(evt.data);
		handleMessage(evt.data);
	};
	websocket.onclose = function(evt){
		console.log("Closed.");
	};
	return websocket;
})();

function sync(obj){
	var value = {value: obj.value};
	websocket.send("update:" + getId(obj) + "->" + JSON.stringify(value));
}

function addEvents(obj, events){
	for(i in events){
		(function(){
			var type = events[i];
			obj.addEventListener(type, function(){
				websocket.send(type + ":" + getId(this));
			});
		})();
	}
}

function getId(obj){
	return obj.id.match(/item-(\d+)/)[1];
}

(function addSyncListener(){
	var inputs = document.getElementsByTagName('input');
	for(var i=0; i<inputs.length; i++){
		inputs[i].addEventListener('input', function(){
			sync(this);
			websocket.send("input:" + getId(this));
		});
	}
	var inputs = document.getElementsByTagName('textarea');
	for(var i=0; i<inputs.length; i++){
		inputs[i].addEventListener('input', function(){
			sync(this);
			websocket.send("input:" + getId(this));
		});
	}
})();

function handleMessage(msg){
	var match_data = msg.match(/(.+?):(\d+)(?:->)?(.+)?/);
	var command = match_data[1];
	var target = document.getElementById('item-' + match_data[2]);
	var data = JSON.parse(match_data[3]);
	switch (command){
		case 'update':
			target.properties = data;
			target.value = data.value;
			target.style.cssText = data.style;
			break;
		case 'add_event':
			addEvents(target, data);
			break;
	}
}