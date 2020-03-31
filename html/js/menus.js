(function(){

	let MenuTpl =
		'<div id="menu_{{_namespace}}_{{_name}}" class="menu menu_default {{#align}} align-{{align}}{{/align}}">' +
			'<div class="head_menu_default" image="{{image}}"><span></span></div>' +
				'<div class="category" style="color: {{primaryColor}}"><span>{{{title}}}</span></div>' +
					'<div class="menu-items">' +
						'{{#elements}}' +
							'<div class="menu-item {{#selected}}selected{{/selected}} {{#disabled}}disabled{{/disabled}}" style="{{#selected}}background-color: {{primaryColor}}{{/selected}}">' +
								'{{{label}}}{{#isSlider}} : &lt;{{{sliderLabel}}}&gt;{{/isSlider}}' +
							'</div>' +
						'{{/elements}}' +
					'</div>'+
				'</div>' +
			'</div>';

	let CustomStyleTemplate =
		'<style id="menu_default_style">' +
			'.menu.menu_default .head_menu_default {' +
				'background-image: url("./img/headers/{{image}}");' +
			'}' +
		'</style>'

	let MenuDialogTpl =
		'<div id="menu_{{_namespace}}_{{_name}}" class="dialog menu_dialog {{#isBig}}big{{/isBig}}">' +
			'<div class="head_menu_dialog"><span></span></div>' +
			'<div class="category" style="color: {{primaryColor}}"><span>{{title}}</span></div>' +
				'<input type="text" name="value" id="inputText"/>' +
				'<button type="button" name="submit" value="submit">{{submit}}</button>' +
				'<button type="button" name="cancel" value="cancel">Annuleren</button>'
			'</div>' +
        '</div>';

    let CustomDialogStyleTemplate =
		'<style id="menu_dialog_style">' +
			'.dialog.menu_dialog .head_menu_dialog {' +
				'background: url("./img/headers/{{image}}") no-repeat center center;' +
				'-webkit-background-size: cover;' +
				'-moz-background-size: cover;' +
				'-o-background-size: cover;' +
				'background-size: cover;' +
			'}' +
		'</style>'

	window.job_default       = {};
	job_default.ResourceName = 'esx_customjobs';
	job_default.opened       = {};
	job_default.focus        = [];
	job_default.pos          = {};

	job_default.open = function(namespace, name, data) {
		if (data != null && data.elements == null) {
			data.elements = { }
		}

		if (typeof job_default.opened[namespace] == 'undefined') {
			job_default.opened[namespace] = {};
		}

		if (typeof job_default.opened[namespace][name] != 'undefined') {
			job_default.close(namespace, name);
		}

		if (typeof job_default.pos[namespace] == 'undefined') {
			job_default.pos[namespace] = {};
		}

		for (let i=0; i<data.elements.length; i++) {
			if (typeof data.elements[i].type == 'undefined') {
				data.elements[i].type = 'default';
			}
		}

		data._index     = job_default.focus.length;
		data._namespace = namespace;
		data._name      = name;

		for (let i=0; i<data.elements.length; i++) {
			data.elements[i]._namespace = namespace;
			data.elements[i]._name      = name;
		}

		let menu = job_default.filterDisabled(data);

		job_default.opened[namespace][name] = data;

		if (menu == null) {
			job_default.pos   [namespace][name] = 0;
		} else {
			if (menu[0] == null) {
				job_default.pos[namespace][name] = 0;
			} else {
				job_default.pos   [namespace][name] = menu[0].pos;
			}
		}

		for (let i=0; i<data.elements.length; i++) {
			if (data.elements[i].selected) {
				job_default.pos[namespace][name] = i;
			} else {
				data.elements[i].selected = false;
			}

			if (!data.elements[i].disabled) {
				data.elements[i].disabled = false
			}
		}

		job_default.focus.push({
			namespace: namespace,
			name     : name
		});

		job_default.render();

		var elem = $('#menu_' + namespace + '_' + name)

		if (elem.length) {
			var selectedElem = elem.find('.menu-item.selected')

			if (selectedElem.length) {
				var firstNotDisabledElem = selectedElem.not('.disabled')

				if (firstNotDisabledElem.length) {
					firstNotDisabledElem[0].scrollIntoView()
				}
			}
		}
	};

	job_default.close = function(namespace, name) {

		if (job_default != null &&
			job_default.opened != null &&
			job_default.opened[namespace] != null &&
			job_default.opened[namespace][name] != null) {
			delete job_default.opened[namespace][name];
		}

		for (let i=0; i<job_default.focus.length; i++) {
			if (job_default.focus[i].namespace == namespace && job_default.focus[i].name == name) {
				job_default.focus.splice(i, 1);
				break;
			}
		}

		job_default.render();

	};

	job_default.render = function() {

		let menuContainer       = document.getElementById('menu_default');
		let focused             = job_default.getFocused();
		menuContainer.innerHTML = '';

		$(menuContainer).hide();

		for (let namespace in job_default.opened) {
			for (let name in job_default.opened[namespace]) {

				let menuData = job_default.opened[namespace][name];
				let view     = JSON.parse(JSON.stringify(menuData));

				for (let i=0; i<menuData.elements.length; i++) {
					let element = view.elements[i];

					switch (element.type) {
						case 'default' : break;

						case 'slider' : {
							element.isSlider    = true;
							element.sliderLabel = (typeof element.options == 'undefined') ? element.value : element.options[element.value];

							break;
						}

						default : break;
					}

					if (i == job_default.pos[namespace][name]) {
						element.selected = true;
					}
				}

				let menu = $(Mustache.render(MenuTpl, view))[0];
				let menuDefaultStyle = Mustache.render(CustomStyleTemplate, view);

				if ($('#menu_default_style').length) {
					$('#menu_default_style').remove()
				}

				$('head').append(menuDefaultStyle)

				$(menu).hide();
				menuContainer.appendChild(menu);
			}
		}

		if (typeof focused != 'undefined') {
			$('#menu_' + focused.namespace + '_' + focused.name).show();
		}

		$(menuContainer).show();

	};

	job_default.submit = function(namespace, name, data) {
		$.post('http://' + job_default.ResourceName + '/job_default_submit', JSON.stringify({
			_namespace: namespace,
			_name     : name,
			current   : data,
			elements  : job_default.opened[namespace][name].elements
		}));
	};

	job_default.cancel = function(namespace, name) {
		$.post('http://' + job_default.ResourceName + '/job_default_cancel', JSON.stringify({
			_namespace: namespace,
			_name     : name
		}));
	};

	job_default.change = function(namespace, name, data) {
		$.post('http://' + job_default.ResourceName + '/job_default_change', JSON.stringify({
			_namespace: namespace,
			_name     : name,
			current   : data,
			elements  : job_default.opened[namespace][name].elements
		}));
	};

	job_default.getFocused = function() {
		return job_default.focus[job_default.focus.length - 1];
	};

	job_default.filterDisabled = function(menu) {
		let menu_elements = []

		if (menu == null || menu.elements == null) {
			return []
		}

		for (let i = 0; i < menu.elements.length; i++) {
			menu.elements[i].pos = i;

			if (menu.elements[i].disabled == null ||
				menu.elements[i].disabled == false) {
				menu_elements.push(menu.elements[i])
			}
		}

		return menu_elements
	};

	window.job_dialog       = {};
	job_dialog.ResourceName = 'esx_customjobs';
	job_dialog.opened       = {};
	job_dialog.focus        = [];
	job_dialog.pos          = {};

	job_dialog.open = function(namespace, name, data) {

		if(typeof job_dialog.opened[namespace] == 'undefined')
			job_dialog.opened[namespace] = {};

		if(typeof job_dialog.opened[namespace][name] != 'undefined')
			job_dialog.close(namespace, name);

		if(typeof job_dialog.pos[namespace] == 'undefined')
			job_dialog.pos[namespace] = {};

		if(typeof data.type == 'undefined')
			data.type = 'default';

		if(typeof data.align == 'undefined')
			data.align = 'top-left';

		data._index     = job_dialog.focus.length;
		data._namespace = namespace;
		data._name      = name;

		job_dialog.opened[namespace][name] = data;
		job_dialog.pos   [namespace][name] = 0;

		job_dialog.focus.push({
			namespace: namespace,
			name     : name
		});

		document.onkeyup = function (key) {
			if (key.which == 27) { // Escape key
				$.post('http://' + job_dialog.ResourceName + '/job_dialog_cancel', JSON.stringify(data));
			} else if (key.which == 13) { // Enter key
				$.post('http://' + job_dialog.ResourceName + '/job_dialog_submit', JSON.stringify(data));
			}
		};

		job_dialog.render();
	}

	job_dialog.close = function(namespace, name) {

		delete job_dialog.opened[namespace][name];

		for(let i=0; i<job_dialog.focus.length; i++){
			if(job_dialog.focus[i].namespace == namespace && job_dialog.focus[i].name == name){
				job_dialog.focus.splice(i, 1);
				break;
			}
		}

		job_dialog.render();
	}

	job_dialog.render = function() {

		let menuContainer = $('#menu_dialog')[0];

		$(menuContainer).find('button[name="submit"]').unbind('click');
		$(menuContainer).find('button[name="cancel"]').unbind('click');
		$(menuContainer).find('[name="value"]')       .unbind('input propertychange');

		menuContainer.innerHTML = '';

		$(menuContainer).hide();

		for(let namespace in job_dialog.opened){
			for(let name in job_dialog.opened[namespace]){

				let menuData = job_dialog.opened[namespace][name];
				let view     = JSON.parse(JSON.stringify(menuData));

				switch(menuData.type){

					case 'default' : {
						view.isDefault = true;
						break;
					}

					case 'big' : {
						view.isBig = true;
						break;
					}

					default : break;
				}

                let menu = $(Mustache.render(MenuDialogTpl, view))[0];
                let menuDialogStyle = Mustache.render(CustomDialogStyleTemplate, view);

                if ($('#menu_dialog_style').length) {
					$('#menu_dialog_style').remove()
                }

                $('head').append(menuDialogStyle)

				$(menu).css('z-index', 1000 + view._index);

				$(menu).find('button[name="submit"]').click(function() {
					menuData['_namespace'] = namespace;
					menuData['namespace'] = namespace;
					menuData['_name'] = name;
					menuData['name'] = name;

					if(typeof menuData.value == 'undefined') {
						menuData.value = $(menu).find('[name="value"]').val();
					}

					job_dialog.submit(menuData);
				});

				$(menu).find('button[name="cancel"]').click(function() {
					job_dialog.cancel(this.namespace, this.name, this.data);
				}.bind({namespace: namespace, name: name, data: menuData}));

				$(menu).find('[name="value"]').bind('input propertychange', function(){
					this.data.value = $(menu).find('[name="value"]').val();
					job_dialog.change(this.namespace, this.name, this.data);
				}.bind({namespace: namespace, name: name, data: menuData}));

				if(typeof menuData.value != 'undefined')
					$(menu).find('[name="value"]').val(menuData.value);

				menuContainer.appendChild(menu);
			}
		}

		$(menuContainer).show();
		$("#inputText").focus();
	}

	job_dialog.submit = function(data){
		$.post('http://' + job_dialog.ResourceName + '/job_dialog_submit',JSON.stringify(data));
	}

	job_dialog.cancel = function(namespace, name, data) {
		$.post('http://' + job_dialog.ResourceName + '/job_dialog_cancel', JSON.stringify(data));
	}

	job_dialog.change = function(namespace, name, data) {
		$.post('http://' + job_dialog.ResourceName + '/job_dialog_change', JSON.stringify(data));
	}

	job_dialog.getFocused = function() {
		return job_dialog.focus[job_dialog.focus.length - 1];
	}

	window.onData = (data) => {
		switch (data.action) {

			case 'openMenuDefault': {
				job_default.open(data.namespace, data.name, data.data);
				break;
			}

			case 'closeMenuDefault': {
				job_default.close(data.namespace, data.name);
				break;
			}

			case 'controlPressedDefault': {

				switch (data.control) {

					case 'ENTER': {
						let focused = job_default.getFocused();

						if (typeof focused != 'undefined') {
							let menu    = job_default.opened[focused.namespace][focused.name];
							let pos     = job_default.pos[focused.namespace][focused.name];
							let elem    = menu.elements[pos];

							if (menu.elements.length > 0) {
								job_default.submit(focused.namespace, focused.name, elem);
							}
						}

						break;
					}

					case 'BACKSPACE': {
						let focused = job_default.getFocused();

						if (typeof focused != 'undefined') {
							job_default.cancel(focused.namespace, focused.name);
						}

						break;
					}

					case 'TOP': {

						let focused = job_default.getFocused();

						if (typeof focused != 'undefined') {
							let rawMenu = job_default.opened[focused.namespace][focused.name];
							let menu = job_default.filterDisabled(rawMenu)
							let pos  = job_default.pos[focused.namespace][focused.name];

							if (pos > 0) {
								let index = 0;

								for (let i = 0; i < menu.length; i++) {
									if (menu[i].pos == job_default.pos[focused.namespace][focused.name]) {
										index = i;
									}
								}

								index--;

								if (index < 0) {
									index = menu.length - 1;
								} else if(index > menu.length) {
									index = 0;
								}

								job_default.pos[focused.namespace][focused.name] = menu[index].pos;
							} else {
								job_default.pos[focused.namespace][focused.name] = menu[menu.length - 1].pos;
							}

							let elem = rawMenu.elements[job_default.pos[focused.namespace][focused.name]];

							for (let i=0; i<rawMenu.elements.length; i++) {
								if (i == job_default.pos[focused.namespace][focused.name]) {
									rawMenu.elements[i].selected = true;
								} else {
									rawMenu.elements[i].selected = false;
								}
							}

							job_default.change(focused.namespace, focused.name, elem);
							job_default.render();

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected').not('.disabled')[0].scrollIntoView();
						}

						break;

					}

					case 'DOWN' : {

						let focused = job_default.getFocused();

						if (typeof focused != 'undefined') {
							let rawMenu = job_default.opened[focused.namespace][focused.name];
							let menu = job_default.filterDisabled(rawMenu)
							let pos  = job_default.pos[focused.namespace][focused.name];

							if (pos < menu[menu.length - 1].pos) {
								let index = 0;

								for (let i = 0; i < menu.length; i++) {
									if (menu[i].pos == job_default.pos[focused.namespace][focused.name]) {
										index = i;
									}
								}

								index++;

								if (index < 0) {
									index = 0;
								} else if(index > menu.length) {
									index = menu.length - 1;
								}

								job_default.pos[focused.namespace][focused.name] = menu[index].pos;
							} else {
								job_default.pos[focused.namespace][focused.name] = menu[0].pos;
							}

							let elem = rawMenu.elements[job_default.pos[focused.namespace][focused.name]];

							for (let i=0; i<rawMenu.elements.length; i++) {
								if (i == job_default.pos[focused.namespace][focused.name]) {
									rawMenu.elements[i].selected = true;
								} else {
									rawMenu.elements[i].selected = false;
								}
							}

							job_default.change(focused.namespace, focused.name, elem);
							job_default.render();

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected').not('.disabled')[0].scrollIntoView();
						}

						break;
					}

					case 'LEFT' : {

						let focused = job_default.getFocused();

						if (typeof focused != 'undefined') {
							let menu = job_default.opened[focused.namespace][focused.name];
							let pos  = job_default.pos[focused.namespace][focused.name];
							let elem = menu.elements[pos];

							switch(elem.type) {
								case 'default': break;

								case 'slider': {
									let min = (typeof elem.min == 'undefined') ? 0 : elem.min;

									if (elem.value > min) {
										elem.value--;
										job_default.change(focused.namespace, focused.name, elem);
									}

									job_default.render();
									break;
								}

								default: break;
							}

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected').not('.disabled')[0].scrollIntoView();
						}

						break;
					}

					case 'RIGHT' : {

						let focused = job_default.getFocused();

						if (typeof focused != 'undefined') {
							let menu = job_default.opened[focused.namespace][focused.name];
							let pos  = job_default.pos[focused.namespace][focused.name];
							let elem = menu.elements[pos];

							switch(elem.type) {
								case 'default': break;

								case 'slider': {
									if (typeof elem.options != 'undefined' && elem.value < elem.options.length - 1) {
										elem.value++;
										job_default.change(focused.namespace, focused.name, elem);
									}

									if (typeof elem.max != 'undefined' && elem.value < elem.max) {
										elem.value++;
										job_default.change(focused.namespace, focused.name, elem);
									}

									job_default.render();
									break;
								}

								default: break;
							}

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected').not('.disabled')[0].scrollIntoView();
						}

						break;
					}

					default : break;

				}

				break;
			}

			case 'openMenuDialog' : {
				job_dialog.open(data.namespace, data.name, data.data);
				break;
			}

			case 'closeMenuDialog' : {
				job_dialog.close(data.namespace, data.name);
				break;
			}
		}

	};

	window.onload = function(e){
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};
})();