var websocket =
(function configureWebSocket(){
	var wsUrl = "ws://localhost:" + wsPort + "/";

	var websocket = new WebSocket(wsUrl);
	websocket.onopen = function(evt){
		console.log("Connected.");
	};
	websocket.onmessage = function(evt){
		console.log("received: " + evt.data);
		handleMessage(evt.data);
	};
	websocket.onclose = function(evt){
		console.log("Closed.");
	};
	websocket.originalSend = websocket.send;
	websocket.send = function(msg){
		console.log("sent: " + msg);
		websocket.originalSend(msg);
	}
	return websocket;
})();

function sync(obj){
	websocket.send("sync:" + getId(obj) + "->" + JSON.stringify(obj.properties));
}

var changeListeners = {
	textline: {
		event: ['input','select'],
		function: (function(){
			this.properties.text = this.value;
			this.properties.selection = [this.selectionStart, this.selectionEnd];
			sync(this);
		})
	},

	textarea: {
		event: ['input','select'],
		function: (function(){
			this.properties.text = this.value;
			this.properties.selection = [this.selectionStart, this.selectionEnd];
			sync(this);
		})
	},

	checkbox: {
		event: ['change'],
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
		event: ['change'],
		function: (function(){
			this.properties.checked = this.value;
			sync(this);
		})
	},

	radio: {
		event: ['change'],
		function: (function(){
			this.properties.checked = this.elements['radio'].value;
			sync(this);
		})
	}
}

function addChangeListener(obj){
	var type = obj.getAttribute('data-type');
	changeListener = changeListeners[type];
	if(changeListener){
		for(var i in changeListener.event){
			obj.addEventListener(changeListener.event[i], changeListener.function);
		}
	}
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
	base: (function(target, data){
		var properties = ['width', 'height', 'font', 'margin', 'background', 'border'];
		for(var i=0;i<properties.length;i++){
			if(data[properties[i]]!=undefined) target.style[properties[i]] = data[properties[i]];
		}
	}),

	body: (function(target, data){

	}),

	form: (function(target, data){
		target.getElementsByClassName('title')[0].getElementsByTagName('span')[0].textContent = data.title;
	}),

	button: (function(target, data){
		target.textContent = data.text;
	}),

	textline: (function(target, data){
		target.value = data.text;
		//if(data.selection){
		//	target.selectionStart = data.selection[0];
		//	target.selectionEnd = data.selection[1];
		//}
	}),

	textarea: (function(target, data){
		target.value = data.text;
		//if(data.selection){
		//	target.selectionStart = data.selection[0];
		//	target.selectionEnd = data.selection[1];
		//}
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
		if(data.arrange=='horizontal') target.className = 'flow';
		if(data.arrange=='vertical') target.className = 'stack';
		var options = target.children;
		for(var i=0;i<options.length;) target.removeChild(options[i]);
		for(var i=0;i<data.options.length;i++){
			var option = document.createElement('div');
			option.className = "option";
			var input = document.createElement('input');
			var label = document.createElement('label');
			input.type = 'checkbox';
			input.value = data.options[i];
			label.textContent = data.options[i];
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
		if(data.arrange=='horizontal') target.className = 'flow';
		if(data.arrange=='vertical') target.className = 'stack';
		var options = target.children;
		for(var i=0;i<options.length;) target.removeChild(options[i]);
		for(var i=0;i<data.options.length;i++){
			var option = document.createElement('div');
			option.className = "option";
			var input = document.createElement('input');
			var label = document.createElement('label');
			input.type="radio";
			input.value = data.options[i];
			input.name = "radio";
			label.textContent = data.options[i];
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
			option.textContent = data.options[i];
			target.appendChild(option);
		}
	}),

	label: (function(target, data){
		target.textContent = data.text;
	}),

	table: (function(target, data){
		for(var i=0;i<target.children.length;) target.removeChild(target.children[i]);
		var tableData = data.data;
		var table = document.createElement('table');
		var columnNames = data.column_names;
		var rowNames = data.row_names;
		if (columnNames) {
			var tr = document.createElement('tr');
			if (rowNames) {
				var th = document.createElement('th');
				th.textContent = '';
				tr.appendChild(th);
			}
			for(var i=0; i<columnNames.length; i++ ){
				var th = document.createElement('th');
				th.textContent = columnNames[i] || '';
				tr.appendChild(th);
			}
			table.appendChild(tr);
		}
		for(var i=0; i<tableData.length; i++){
			var tr = document.createElement('tr');
			if(rowNames){
				var th = document.createElement('th');
				th.textContent = rowNames[i] || '';
				tr.appendChild(th);
			}
			for(var j=0; j<tableData[i].length; j++){
				var td = document.createElement('td');
				td.textContent = tableData[i][j];
				tr.appendChild(td);
			}
			table.appendChild(tr);
		}
		target.appendChild(table);
	})

};

function handleMessage(msg){
	var match_data = msg.match(/(.+?):(\d+)(?:->)?(.+)?/);
	var command = match_data[1];
	var target = document.getElementById('item-' + match_data[2]);
	if(match_data[3]) var data = JSON.parse(match_data[3]);
	switch (command){
		case 'sync':
			target.properties = data;
			var type = target.getAttribute('data-type');
			syncHandlers.base(target, data);
			syncHandlers[type](target, data);
			break;
		case 'add_event':
			addEvents(target, data);
			break;
		case 'alert':
			window.alert(data.message);
			break;
		case 'focus':
			target.focus();
			break;
	}
}
