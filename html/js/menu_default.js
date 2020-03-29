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
			'}'
		'</style>'

	window.esx_MENU       = {};
	esx_MENU.ResourceName = 'ml_jobs';
	esx_MENU.opened       = {};
	esx_MENU.focus        = [];
	esx_MENU.pos          = {};

	esx_MENU.open = function(namespace, name, data) {
		if (data != null && data.elements == null) {
			data.elements = { }
		}

		if (typeof esx_MENU.opened[namespace] == 'undefined') {
			esx_MENU.opened[namespace] = {};
		}

		if (typeof esx_MENU.opened[namespace][name] != 'undefined') {
			esx_MENU.close(namespace, name);
		}

		if (typeof esx_MENU.pos[namespace] == 'undefined') {
			esx_MENU.pos[namespace] = {};
		}

		for (let i=0; i<data.elements.length; i++) {
			if (typeof data.elements[i].type == 'undefined') {
				data.elements[i].type = 'default';
			}
		}

		data._index     = esx_MENU.focus.length;
		data._namespace = namespace;
		data._name      = name;

		for (let i=0; i<data.elements.length; i++) {
			data.elements[i]._namespace = namespace;
			data.elements[i]._name      = name;
		}

		let menu = esx_MENU.filterDisabled(data);

		esx_MENU.opened[namespace][name] = data;

		if (menu == null) {
			esx_MENU.pos   [namespace][name] = 0;
		} else {
			if (menu[0] == null) {
				esx_MENU.pos[namespace][name] = 0;
			} else {
				esx_MENU.pos   [namespace][name] = menu[0].pos;
			}
		}

		for (let i=0; i<data.elements.length; i++) {
			if (data.elements[i].selected) {
				esx_MENU.pos[namespace][name] = i;
			} else {
				data.elements[i].selected = false;
			}

			if (!data.elements[i].disabled) {
				data.elements[i].disabled = false
			}
		}

		esx_MENU.focus.push({
			namespace: namespace,
			name     : name
		});

		esx_MENU.render();
		$('#menu_' + namespace + '_' + name).find('.menu-item.selected').not('.disabled')[0].scrollIntoView();
	};

	esx_MENU.close = function(namespace, name) {

		if (esx_MENU != null &&
			esx_MENU.opened != null &&
			esx_MENU.opened[namespace] != null &&
			esx_MENU.opened[namespace][name] != null) {
			delete esx_MENU.opened[namespace][name];
		}

		for (let i=0; i<esx_MENU.focus.length; i++) {
			if (esx_MENU.focus[i].namespace == namespace && esx_MENU.focus[i].name == name) {
				esx_MENU.focus.splice(i, 1);
				break;
			}
		}

		esx_MENU.render();

	};

	esx_MENU.render = function() {

		let menuContainer       = document.getElementById('menu_default');
		let focused             = esx_MENU.getFocused();
		menuContainer.innerHTML = '';

		$(menuContainer).hide();

		for (let namespace in esx_MENU.opened) {
			for (let name in esx_MENU.opened[namespace]) {

				let menuData = esx_MENU.opened[namespace][name];
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

					if (i == esx_MENU.pos[namespace][name]) {
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

	esx_MENU.submit = function(namespace, name, data) {
		$.post('http://' + esx_MENU.ResourceName + '/menu_submit', JSON.stringify({
			_namespace: namespace,
			_name     : name,
			current   : data,
			elements  : esx_MENU.opened[namespace][name].elements
		}));
	};

	esx_MENU.cancel = function(namespace, name) {
		$.post('http://' + esx_MENU.ResourceName + '/menu_cancel', JSON.stringify({
			_namespace: namespace,
			_name     : name
		}));
	};

	esx_MENU.change = function(namespace, name, data) {
		$.post('http://' + esx_MENU.ResourceName + '/menu_change', JSON.stringify({
			_namespace: namespace,
			_name     : name,
			current   : data,
			elements  : esx_MENU.opened[namespace][name].elements
		}));
	};

	esx_MENU.getFocused = function() {
		return esx_MENU.focus[esx_MENU.focus.length - 1];
	};

	esx_MENU.filterDisabled = function(menu) {
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

	window.onData = (data) => {

		switch (data.action) {

			case 'openMenu': {
				esx_MENU.open(data.namespace, data.name, data.data);
				break;
			}

			case 'closeMenu': {
				esx_MENU.close(data.namespace, data.name);
				break;
			}

			case 'controlPressed': {

				switch (data.control) {

					case 'ENTER': {
						let focused = esx_MENU.getFocused();

						if (typeof focused != 'undefined') {
							let menu    = esx_MENU.opened[focused.namespace][focused.name];
							let pos     = esx_MENU.pos[focused.namespace][focused.name];
							let elem    = menu.elements[pos];

							if (menu.elements.length > 0) {
								esx_MENU.submit(focused.namespace, focused.name, elem);
							}
						}

						break;
					}

					case 'BACKSPACE': {
						let focused = esx_MENU.getFocused();

						if (typeof focused != 'undefined') {
							esx_MENU.cancel(focused.namespace, focused.name);
						}

						break;
					}

					case 'TOP': {

						let focused = esx_MENU.getFocused();

						if (typeof focused != 'undefined') {
							let rawMenu = esx_MENU.opened[focused.namespace][focused.name];
							let menu = esx_MENU.filterDisabled(rawMenu)
							let pos  = esx_MENU.pos[focused.namespace][focused.name];

							if (pos > 0) {
								let index = 0;

								for (let i = 0; i < menu.length; i++) {
									if (menu[i].pos == esx_MENU.pos[focused.namespace][focused.name]) {
										index = i;
									}
								}

								index--;

								if (index < 0) {
									index = menu.length - 1;
								} else if(index > menu.length) {
									index = 0;
								}

								esx_MENU.pos[focused.namespace][focused.name] = menu[index].pos;
							} else {
								esx_MENU.pos[focused.namespace][focused.name] = menu[menu.length - 1].pos;
							}

							let elem = rawMenu.elements[esx_MENU.pos[focused.namespace][focused.name]];

							for (let i=0; i<rawMenu.elements.length; i++) {
								if (i == esx_MENU.pos[focused.namespace][focused.name]) {
									rawMenu.elements[i].selected = true;
								} else {
									rawMenu.elements[i].selected = false;
								}
							}

							esx_MENU.change(focused.namespace, focused.name, elem);
							esx_MENU.render();

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected').not('.disabled')[0].scrollIntoView();
						}

						break;

					}

					case 'DOWN' : {

						let focused = esx_MENU.getFocused();

						if (typeof focused != 'undefined') {
							let rawMenu = esx_MENU.opened[focused.namespace][focused.name];
							let menu = esx_MENU.filterDisabled(rawMenu)
							let pos  = esx_MENU.pos[focused.namespace][focused.name];

							if (pos < menu[menu.length - 1].pos) {
								let index = 0;

								for (let i = 0; i < menu.length; i++) {
									if (menu[i].pos == esx_MENU.pos[focused.namespace][focused.name]) {
										index = i;
									}
								}

								index++;

								if (index < 0) {
									index = 0;
								} else if(index > menu.length) {
									index = menu.length - 1;
								}

								esx_MENU.pos[focused.namespace][focused.name] = menu[index].pos;
							} else {
								esx_MENU.pos[focused.namespace][focused.name] = menu[0].pos;
							}

							let elem = rawMenu.elements[esx_MENU.pos[focused.namespace][focused.name]];

							for (let i=0; i<rawMenu.elements.length; i++) {
								if (i == esx_MENU.pos[focused.namespace][focused.name]) {
									rawMenu.elements[i].selected = true;
								} else {
									rawMenu.elements[i].selected = false;
								}
							}

							esx_MENU.change(focused.namespace, focused.name, elem);
							esx_MENU.render();

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected').not('.disabled')[0].scrollIntoView();
						}

						break;
					}

					case 'LEFT' : {

						let focused = esx_MENU.getFocused();

						if (typeof focused != 'undefined') {
							let menu = esx_MENU.opened[focused.namespace][focused.name];
							let pos  = esx_MENU.pos[focused.namespace][focused.name];
							let elem = menu.elements[pos];

							switch(elem.type) {
								case 'default': break;

								case 'slider': {
									let min = (typeof elem.min == 'undefined') ? 0 : elem.min;

									if (elem.value > min) {
										elem.value--;
										esx_MENU.change(focused.namespace, focused.name, elem);
									}

									esx_MENU.render();
									break;
								}

								default: break;
							}

							$('#menu_' + focused.namespace + '_' + focused.name).find('.menu-item.selected').not('.disabled')[0].scrollIntoView();
						}

						break;
					}

					case 'RIGHT' : {

						let focused = esx_MENU.getFocused();

						if (typeof focused != 'undefined') {
							let menu = esx_MENU.opened[focused.namespace][focused.name];
							let pos  = esx_MENU.pos[focused.namespace][focused.name];
							let elem = menu.elements[pos];

							switch(elem.type) {
								case 'default': break;

								case 'slider': {
									if (typeof elem.options != 'undefined' && elem.value < elem.options.length - 1) {
										elem.value++;
										esx_MENU.change(focused.namespace, focused.name, elem);
									}

									if (typeof elem.max != 'undefined' && elem.value < elem.max) {
										elem.value++;
										esx_MENU.change(focused.namespace, focused.name, elem);
									}

									esx_MENU.render();
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

		}

	};

	window.onload = function(e){
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};

})();