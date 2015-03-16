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

Element.prototype.g = function(e){
	e = e.split(' ');
	result = this;
	for(var i=0;i<e.length;i++){
		if(e[i][0]=='.'){
			result = result.getElementsByClassName(e[i].substr(1));
		} else if(e[i][0]=='#'){
			result = document.getElementById(e[i].substr(1));
		} else {
			result = result.getElementsByTagName(e[i]);
		}
	}
	return result;
}
document.g = Element.prototype.g;

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
			var options = this.getElementsByTagName('input');
			var checked = [];
			for(var i=0;i<options.length;i++){
				if(options[i].checked==true) checked.push(options[i].value);
			}
			this.properties.checked = checked;
			sync(this);
		})
	},

	select: {
		event: 'change',
		function: (function(){
			this.properties.checked = this.getElementsByTagName('select')[0].value;
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
		var bar = target.getElementsByClassName('bar')[0];
		bar.style.width = data.percent.toString() + '%';
	}),

	checkbox: (function(target, data){
		var options = target.children;
		for(var i=0;i<options.length;) target.removeChild(options[i]);
		for(var i=0;i<data.options.length;i++){
			var option = document.createElement('div');
			var input = document.createElement('input');
			var label = document.createElement('label');
			input.type = 'checkbox';
			input.value = data.options[i];
			label.innerText = data.options[i];
			option.appendChild(input);
			option.appendChild(label);
			target.appendChild(option);
			if(data.checked!=undefined){
				for(var j=0;j<data.checked.length;j++){
					if(data.checked[j] == data.options[i]) input.checked = true;
				}
			}
		}
		
	}),

	radio: (function(target, data){
		var options = target.children;
		for(var i=0;i<options.length;) target.removeChild(options[i]);
		for(var i=0;i<data.options.length;i++){
			var option = document.createElement('div');
			var input = document.createElement('input');
			var label = document.createElement('label');
			input.type="radio";
			input.value = data.options[i];
			input.name = "radio";
			label.innerText = data.options[i];
			option.appendChild(input);
			option.appendChild(label);
			target.appendChild(option);
			if(data.checked!=undefined && data.checked == input.value){
				input.checked = true;
			}
		}
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
		case 'alert':
			window.alert(data.message);
			break;
		case 'comfirm':
			window.confirm(data.message);
			break;
		case 'prompt':
			window.prompt(data.text, data.value);
			break;
	}
}