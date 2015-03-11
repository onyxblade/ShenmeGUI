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
	websocket.send("sync:" + getId(obj) + "->" + JSON.stringify(obj.properties));
}

var changeListeners = {
	textline: {
		event: 'input',
		function: (function(){
			this.properties.text = this.value;
			sync(this);
		})
	},

	textarea: {
		event: 'input',
		function: (function(){
			this.properties.text = this.value;
			sync(this);
		})
	},

	checkbox: {
		event: 'change',
		function: (function(){
			this.properties.checked = this.getElementsByClassName('checkbox')[0].checked;
			sync(this);
		})
	},

	select: {
		event: 'change',
		function: (function(){
			this.properties.checked = this.value;
			sync(this);
		})
	},

	radio: {
		event: 'change',
		function: (function(){
			this.properties.checked = this.elements['radio'].value;
			sync(this);
		})
	}
}

function addChangeListener(obj){
	var type = obj.getAttribute('data-type');
	changeListener = changeListeners[type];
	if(changeListener)	obj.addEventListener(changeListener.event, changeListener.function);
}

function addEvents(obj, events){
	addChangeListener(obj);
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

var syncHandlers = {
	
	body: (function(target, data){

	}),

	button: (function(target, data){
		target.innerText = data.text;
	}),

	textline: (function(target, data){
		target.value = data.text;
	}),

	textarea: (function(target, data){
		target.value = data.text;
	}),

	image: (function(target, data){
		target.src = data.src;
	}),

	div: (function(target, data){

	}),

	progress: (function(target, data){
		var label = target.getElementsByClassName('label')[0];
		var bar = target.getElementsByClassName('bar')[0];
		var progress = target.getElementsByClassName('progress')[0];
		bar.style.width = data.percent.toString() + '%';
		if(data.text) label.innerText = data.text;
		progress.innerText = data.percent.toString() + '%';
	}),

	checkbox: (function(target, data){
		var label = target.getElementsByTagName('label')[0];
		var checkbox = target.getElementsByClassName('checkbox')[0];
		label.innerText = data.text;
		if(data.checked != undefined) checkbox.checked = data.checked;
	}),

	select: (function(target, data){
		var options = target.getElementsByTagName('option');
		for(var i=0;i<options.length;) target.removeChild(options[i]);
		for(var i=0;i<data.options.length;i++){
			var option = document.createElement('option');
			option.value = data.options[i];
			option.innerText = data.options[i];
			target.appendChild(option);
		}
	}),

	radio: (function(target, data){
		var options = target.children;
		for(var i=0;i<options.length;) target.removeChild(options[i]);
		for(var i=0;i<data.options.length;i++){
			var option = document.createElement('div');
			option.className="ui radio checkbox";
			var input = document.createElement('input');
			var label = document.createElement('label');
			input.type="radio";
			input.value = data.options[i];
			input.className = "checkbox";
			input.name = "radio";
			label.innerText = data.options[i];
			option.appendChild(input);
			option.appendChild(label);
			target.appendChild(option);
		}
	})
};

function handleMessage(msg){
	var match_data = msg.match(/(.+?):(\d+)(?:->)?(.+)?/);
	var command = match_data[1];
	var target = document.getElementById('item-' + match_data[2]);
	var data = JSON.parse(match_data[3]);
	switch (command){
		case 'sync':
			target.properties = data;
			var type = target.getAttribute('data-type');
			syncHandlers[type](target, data);
			break;
		case 'add_event':
			addEvents(target, data);
			break;
	}
}