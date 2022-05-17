// -----------------------------------------------------------------------
// <copyright file="ViCon.ViFlow.WebModel.UI.js" company="ViCon GmbH">
//     Copyright © ViCon GmbH.
// </copyright>
// <summary>
//		This file provides all functionality for creating and
//		interacting with this web apps UI.
// </summary>
// <remarks>
//		This file relies on:
//		====================
//		~ ViCon.ViFlow.WebModel.js
//		~ ViCon.ViFlow.WebModel.AddOns.js
//		~ ViCon.ViFlow.WebModel.Common.js
//		~ ViCon.ViFlow.WebModel.Diagnostics.js
//		~ ViCon.ViFlow.WebModel.Drawing.js
//		~ ViCon.ViFlow.WebModel.Search.js
//		~ ViCon.ViFlow.WebModel.Settings.js
//
//		Assumed VDG Violations:
//		=======================
//		~ properties must be placed between functions and nested classes.
//				REASON:
//				constructor code relies on pre-defined properties within
//				JavaScript code.
// </remarks>
// -----------------------------------------------------------------------

/// <summary>
/// This class provides all functionality
/// for creating and interacting with this
/// web apps UI.
/// </summary>
function UIClass()
{
	//// ~~~~ constants ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var REGEX_MATCH_EMAIL = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _fti;		// file type icons
	var _wai;		// where am i
	var _bs;		// buttons
	var _ws;		// windows
	var _ts;		// tabstrips
	var _tv;		// treeviews
	var _da;		// drawing area
	var _cm;		// context menu
	var _lm;		// link menu
	var _re;		// resize event
	var _ut;		// UI translations
	var _pw;		// property window
	var _rw;		// result window
	var _cw;		// changes window

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "Buttons", { get: function () { return _bs; } });
	Object.defineProperty(this, "Windows", { get: function () { return _ws; } });
	Object.defineProperty(this, "TabStrips", { get: function () { return _ts; } });
	Object.defineProperty(this, "TreeViews", { get: function () { return _tv; } });
	Object.defineProperty(this, "DrawingArea", { get: function () { return _da; } });
	Object.defineProperty(this, "WhereAmI", { get: function () { return _wai; } });
	Object.defineProperty(this, "Translations", { get: function () { return _ut; } });
	Object.defineProperty(this, "PropertyWindow", { get: function () { return _pw; } });
	Object.defineProperty(this, "ResultWindow", { get: function () { return _rw; } });
	Object.defineProperty(this, "ChangesWindow", { get: function () { return _cw; } });
	Object.defineProperty(this, "ContextMenu", { get: function () { return _cm; } });
	Object.defineProperty(this, "FileTypeIcons", { get: function () { return _fti; } });

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	{
		_self = this;
		_self.extendAsEventDispatcher();

		_ut = new TranslationsClass();

		_bs = new WebModel.Common.CollectionClass();
		_ws = new WebModel.Common.CollectionClass();
		_ts = new WebModel.Common.CollectionClass();
		_tv = new WebModel.Common.CollectionClass();

		connectMarkup();
	}

	//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function OnMainWindowResize(myEvent)
	{
	 var ws;
	 var w;

		ws = _self.Windows;
		for (var i in ws) {
			w = ws[i];
			if (w.Visible) {
				w.open();
			}
		}

		OnNavigationFitRequired(myEvent);

		_re = document.createEvent('CustomEvent');
		_re.initCustomEvent('mainwindowresized', true, false, _self);
		_self.dispatchEvent(_re);
		
		if (myEvent) {
			WebModel.Common.Helper.cancelEvent(myEvent);
		}
	}

	function OnNavigationFitRequired(myEvent)
	{
	 var ay;
	 var bw;	// buttons width
	 var nw;	// navigation width
	 var bs;	// buttons
	 var b;		// button

		ay = new Array();
		bw = 0;
		nw = document.getElementById('searchForm').offsetLeft - 60;

		bs = _self.Buttons;								// let's get reversed button array
		for (var k in _bs) {							// and expand all buttons to their
			b = _bs[k];									// maximum size.
			if (!(b instanceof ButtonClass)) {
				continue;
			}

			b.Collapsed = false;
			bw += b.Width;								// buffer width of all buttons!

			ay.push(b);
		}

		ay.reverse();

		for (var k = 0; k < ay.length; k++) {			// collapse each button in reverse
			b = ay[k];									// order to ensure navigation bar
			if (bw < nw) {								// with still displays all elements
				break;									// correctly.
			}
 
			bw -= b.Width;
			b.Collapsed = true;
			bw += b.Width;
		}
	}

	function OnTabStripVisibilityChanged(myEvent)
	{
	 var ts;	// tabstrips

		myEvent = myEvent || event;

		ts = _self.TabStrips;
		switch (myEvent.detail) {
			case ts['pagetabs']:
				_self.DrawingArea.Element.parentElement.style.bottom = (myEvent.detail.Visible ? 27 : 0) + 'px;';
				break;
		}

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnTabSelected(myEvent)
	{
	 var ts;	// tabstrip(s)
	 var t;
	 var i;

		myEvent = myEvent || event;

		ts = _self.TabStrips;
		switch (myEvent.detail) {
			case ts['pagetabs']:
				i = 0;
				ts = myEvent.detail;
				for (var k in ts.Tabs) {
					t = ts.Tabs[k];
					if (!(t instanceof ts.TabClass)) {
						continue;
					}

					if (t == ts.ActiveTab) {
						WebModel.Drawing.load(WebModel.Drawing.GraphicID, ++i);
						break;
					}

					i++;
				}

				break;

			case ts['resulttabs']:
				i = 0;
				ts = myEvent.detail;
				for (var k in ts.Tabs) {
					t = ts.Tabs[k];
					if (!(t instanceof ts.TabClass)) {
						continue;
					}

					if (t == ts.ActiveTab) {
						t = document.getElementById('searchField');
						if (!t) {
							throw 'Could not find search field!';
						}

						WebModel.UI.ResultWindow.filter(i);
						break;
					}

					i++;
				}

				break;
		}

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnButtonClick(myEvent)
	{
	 var xslt;
	 var xml;
	 var bs;	// buttons
	 var ws;	// windows
	 var ts;	// tab strips
	 var nd;	// node
	 var sz;	// multiple usage!
	 var l;		// location
	 var b;		// button
	 var w;		// window

		myEvent = myEvent || event;

		b = myEvent.detail;
		if (!b)
			throw 'Could not determine button for button click event!';

		bs = _self.Buttons;
		ws = _self.Windows;
		ts = _self.TabStrips;
		switch (b) {
			case bs['naviHistoryLink']:
				w = ws['whatsChangedBox'];
				if (b.IsPressed == w.Visible) {
					break;
				}

				if (!w.Visible) {
					w.open(true);
				} else {
					w.close();
				}

				break;

			case bs['naviZoomLink']:
				w = ws['zoomBox'];
				if (b.IsPressed == w.Visible) {
					break;
				}

				if (!w.Visible) {
					w.open();
				} else {
					w.close();
				}

				break;

			case bs['naviHelpLink']:
				sz = './help/' + WebModel.Settings.LanguageUI + '.pdf';
				if (!WebModel.Common.Helper.validateURI(sz)) {
					sz = './help/en.pdf';
				}

				window.open(sz);
				break;

			case bs['naviSettingsLink']:
				ws['settingsBox'].open();
				break;

			case bs['naviFeedbackLink']:
				try {
					xslt = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './xslt/intermediate_list_settinglinks.xslt', false);
					xml = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/settings.xml', false);
					xml = WebModel.Common.Helper.transformXML(xml, xslt, { filter: WebModel.Drawing.GraphicID });
					sz = WebModel.Common.Helper.selectSingleNode(xml, '/list/@feedbackuri').nodeValue;
				}
				catch (e) {
					sz = WebModel.Settings.FeedbackURI;
				}

				if (sz.match(REGEX_MATCH_EMAIL) && sz.indexOf('mailto:') < 0) {
					sz = 'mailto:' + sz;
				}

				switch (true) {
					case sz.match(/mailto:/gi) != null:
						nd = _self.TreeViews['globalProcessTree'].findNode(WebModel.Drawing.GraphicID, true);

						if (nd && sz.toLowerCase().indexOf('subject=') < 0) {		// let's append current process' name to
							sz += sz.indexOf('?') >= 0 ? '&' : '?';					// to e-mail subject if no subject is present.
							sz += 'subject=';
							sz += encodeURIComponent(nd.Name);
						}

						if (nd && sz.toLowerCase().indexOf('body=') < 0) {			// let's append link to current process
							sz += sz.indexOf('?') >= 0 ? '&' : '?';					// to e-mail body if no body is present.
							sz += 'body=';
							sz += document.location.href.indexOf('://') >= 0 ? '' : 'file://';

							l = document.location.href;
							if (l.match(/processid=[0-9]+/)) {
								l = l.replace(/processid=[0-9]+/, 'processid=' + nd.ID);
								sz += encodeURIComponent(l);
							} else {
								sz += encodeURIComponent(l + (l.indexOf('?') >= 0 ? '&' : '?') + 'processid=' + nd.ID);
							}
						}
						document.location.href = sz;
						break;

					case sz.length > 0:
						window.open(sz);
						break;

					default:
						document.location.href = 'mailto:';
						return;
				}
				break;

			case bs['naviProcessesLink']:
			case bs['naviInformationLink']:
			case bs['naviAreasLink']:
				ts['processOverview'].Visible = (b == bs['naviProcessesLink']);
				ts['informationOverview'].Visible = (b == bs['naviInformationLink']);
				ts['areaOverview'].Visible = (b == bs['naviAreasLink']);

				w = ws['objectNav'];
				b = bs['naviProcessesLink'].IsPressed |
					bs['naviInformationLink'].IsPressed |
					bs['naviAreasLink'].IsPressed;
				
				if (b == w.Visible) {
					break;
				}
				
				if (!w.Visible) {
					w.open();
				} else {
					w.close();
				}

				break;
		}
	}

	function OnWindowStateChanged(myEvent)
	{
	 var wms;	// WebModel settings buffer
	 var wmh;	// WebModel helper buffer
	 var enm;	// enum
	 var set;	// setting
	 var pe;	// parent element
	 var ce;	// child element
	 var ay;	// array
	 var i;		// multiple usage
	 var k;		// multiple usage
	 var w; 	// window
	 var b; 	// button

		wms = WebModel.Settings;
		wmh = WebModel.Common.Helper;

		myEvent = myEvent || event;

		w = myEvent.detail;
		if (!w)
			throw 'Could not determine window for window state change event!';

		switch (w) {
			case _self.Windows['propertiesWindow']:
				if (w.Visible) {
					wms.PropertyWindowPosition = w.Position.Left + ';' +
												 w.Position.Top + ';' +
												 w.Position.Width + ';' +
												 w.Position.Height;
				}

				break;

			case _self.Windows['zoomBox']:
				wms.ZoomWindowVisible = w.Visible;
				if (w.Visible) {
					wms.ZoomWindowPosition = w.Position.Left + ';' + w.Position.Top;
				}

				b = _self.Buttons['naviZoomLink'];
				if (w.Visible != b.IsPressed) {
					b.toggle();
				}

				if (w.LastVisible != w.Visible && WebModel.Drawing) {
					WebModel.Drawing.refreshZoomWindowData();
					w.LastVisible = w.Visible;
				}

				break;

			case _self.Windows['resultBox']:
				wms.ResultWindowVisible = w.Visible;
				if (w.Visible) {
					wms.ResultWindowPosition = w.Position.Left + ';' +
											   w.Position.Top + ';' +
											   w.Position.Width + ';' +
											   w.Position.Height;
				}

				break;

			case _self.Windows['whatsChangedBox']:
				if (w.Visible) {
					wms.ChangesWindowPosition = w.Position.Left + ';' +
											    w.Position.Top + ';' +
											    w.Position.Width + ';' +
											    w.Position.Height;
				}

				b = _self.Buttons['naviHistoryLink'];
				if (w.Visible != b.IsPressed) {
					b.toggle();
				}

				if (!w.Visible && w.MarkAsRead) {
					wms.LastVisit = wmh.getDoubleFromDate(new Date());
				}

				break;

			case _self.Windows['objectNav']:
				wms.NavigationVisible = w.Visible;
				if (w.Visible) {
					wms.NavigationPosition = w.Position.Width;
				}

				break;

			case _self.Windows['settingsBox']:
				enm = {
					Users: 'intermediate_list_areas.xslt',
					UILanguages: 'intermediate_list_languages_ui.xslt',
					ContentLanguages: 'intermediate_list_languages_content.xslt'
				};

				if (!w.Visible) {																						// >>> BEGIN :: WINDOW CLOSED! <<<
					i = false;																							// let's re-set flag for persolinazation.

					for (k in enm) {																					// let's iterate all list
						switch (enm[k]) {																				// configuration information.
							case enm.Users:
								pe = document.getElementById('user');													// let's get our user selector
								set = 'CurrentUser';																	// let's supply according setting.
								break;
							case enm.UILanguages:
								pe = document.getElementById('uilanguage');												// let's get our ui language selector
								set = 'LanguageUI';																		// let's supply according setting.
								break;
							case enm.ContentLanguages:
								pe = document.getElementById('contentlanguage');										// let's get our content language selector
								set = 'LanguageContent';																// let's supply according setting.
								break;
							default:
								continue;
						}
						if (!pe) {																						// got it?
							throw 'Could not find setting selection element!';											// no! >> fail immediatly!
						}

						ce = pe.options[pe.options.selectedIndex];														// let's get selected option element.
						if (!ce) {																						// got it?
							WebModel.Diagnostics.Console.warn('Could not find selected item element!');						// no! >> warn about missing setting!
						} else {
							i |= (wms[set] != ce.value);																// personalization required?
							wms[set] = ce.value;																		// let's save current option.
						}
					}

					ce = document.getElementById('dependents');															// let's get dependents element.
					if (!ce) {																							// got it?
						throw 'Could not find dependency element!';														// no! >> fail immediatly!
					}

					i |= (wms.DependentObjects != ce.checked);															// personalization required?
					wms.DependentObjects = ce.checked;																	// let's set displaying dependents.

					ce = document.getElementById('showchanges');														// let's get changes display element.
					if (!ce) {																							// got it?
						throw 'Could not find changes display element!';												// no! >> fail immediatly!
					}

					wms.ShowChangesSinceVisit = ce.checked;																// let's set displaying changes.
					wms.FirstRunProcessed = true;																		// let's mark we executed first run!

					if (!i)	{																							// reset personalized things?
						break;																							// no! >> so leave here :-P
					}

					_ut.apply();																						// let's refresh UI translations!!

					wmh.performAsyncTransform(																			// let's reload user list.
						'./data/empty.xml',
						'./xslt/intermediate_list_areas.xslt',
						OnSettingListLoaded,
						{
							language: wms.LanguageContent,
							renferencedonly: +wms.ReferencedAreasOnly,
							exclusionlist: WebModel.ExclusionData
						}, {
							List: document.getElementById('user'),
							CurrentValue: wms.CurrentUser,
							IsUserList: true,
							Closing: true
						}
					);

					ay = new Array(
						{ TreeView: _self.TreeViews['globalProcessTree'], Transform: 'intermediate_tree_processes' },
						{ TreeView: _self.TreeViews['globalInformationTree'], Transform: 'intermediate_tree_information' },
						{ TreeView: _self.TreeViews['globalAreaTree'], Transform: 'intermediate_tree_areas' },
						{ TreeView: _self.TreeViews['myProcessTree'], Transform: 'intermediate_tree_processes_personalized' },
						{ TreeView: _self.TreeViews['myInformationTree'], Transform: 'intermediate_tree_information_personalized' },
						{ TreeView: _self.TreeViews['myAreaTree'], Transform: 'intermediate_tree_areas_personalized' }
					);
					for (i = 0; i < ay.length; i++) {
						wmh.performAsyncTransform('./data/empty.xml',
												  './xslt/' + ay[i].Transform + '.xslt',
												  ay[i].TreeView.reset,
												  {
												  	filter: wms.CurrentUser ? wms.CurrentUser : 0,
												  	dependents: +wms.DependentObjects,
												  	language: wms.LanguageContent,
												  	exclusionlist: WebModel.ExclusionData,
													referencedonly: ay[i].Transform.indexOf('areas') > 0 ? +wms.ReferencedAreasOnly : +wms.ReferencedInfosOnly
												  }
						);
					}

					ay = new Array('processOverview', 'informationOverview', 'areaOverview');
					for (i = 0; i < ay.length; i++) {
						for (v in _self.TabStrips[ay[i]].Tabs) {
							t = _self.TabStrips[ay[i]].Tabs[v];
							if (!(t instanceof _self.TabStrips[ay[i]].TabClass))
								continue;
							t.Visible = (wms.CurrentUser != 0);
							t.Selected = (t.ID.indexOf('global') >= 0 && !t.Visible) ||
										 (t.ID.indexOf('global') < 0 && t.Visible);
						}
					}

					break;
				}																										// >>> END :: WINDOW CLOSED! <<<

				if (w.SettingsInitialized) {
					return;
				}
				w.SettingsInitialized = true;

				for (k in enm) {																						// let's iterate all lists.
					switch (enm[k]) {																					// configuration information.
						case enm.Users:
							pe = document.getElementById('user');														// let's get our user selector.
							set = wms.CurrentUser;																		// let's cache according setting.
							break;
						case enm.UILanguages:
							pe = document.getElementById('uilanguage');													// let's get our ui language selector.
							set = wms.LanguageUI;																		// let's cache according setting.
							break;
						case enm.ContentLanguages:
							pe = document.getElementById('contentlanguage');											// let's get our content language selector.
							set = wms.LanguageContent;																	// let's cache according setting.
							break;
						default:
							continue;
					}
					if (!pe)																							// got it?
						throw 'Could not find setting selection element!';												// no! >> fail immediatly!

					pe.disabled = true;
					wmh.performAsyncTransform('./data/empty.xml',
											  './xslt/' + enm[k],
											  OnSettingListLoaded,
											  {
												language: wms.LanguageContent,
												renferencedonly: +wms.ReferencedAreasOnly,
												exclusionlist: WebModel.ExclusionData
											  }, {
											  	List: pe,
											  	CurrentValue: set,
											  	IsUserList: enm[k] == enm.Users
											  }
					);
				}

				pe = document.getElementById('dependents');																// let's get dependents element.
				if (!pe)																								// got it?
					throw 'Could not find dependency element!';															// no! >> fail immediatly!
				pe.checked = wms.DependentObjects;																		// let's set displaying dependents.

				pe = document.getElementById('showchanges');															// let's get changes display element.
				if (!pe)																								// got it?
					throw 'Could not find changes display element!';													// no! >> fail immediatly!
				pe.checked = wms.ShowChangesSinceVisit;																	// let's set displaying changes.

				break;
		}
	}

	function OnSettingListLoaded(myData, mySettings)
	{
	 var ay;
	 var nl;
	 var xn;
	 var sz;
	 var h;		// helper
	 var s;		// settings
	 var e;		// element
	 var f;		// fragment

		h = WebModel.Common.Helper;
		s = WebModel.Settings;

		ay = new Array();
		nl = h.selectNodes(myData, '/list/item');
		for (var i = 0; i < nl.length; i++) {																			// for each item to add to list
			xn = nl[i];																									// we create a corresponding
			e = document.createElement('option');																		// option element, select it
			e.value = h.selectSingleNode(xn, 'id/text()').nodeValue;													// on settings match and push
			if (e.value == mySettings.CurrentValue) {																	// it to array for sorting.
				e.selected = true;
			}
			sz = s.DisplayText == SettingsClass.DisplayText.Name ? 'name' : 'shapetext';
			sz = h.selectSingleNode(xn, sz + '/text()').nodeValue;
			if (sz.match(/eval\(.*\)/)) {
				sz = eval(sz);
			}
			e.appendChild(document.createTextNode(sz));
			ay.push(e);
		}

		e = document.createElement('option');																			// let's create a blank item
		e.appendChild(document.createTextNode(''));																		// and push it to array too if
		e.value = 0;																									// we're working on user list.
		if (mySettings.IsUserList) {
			ay.push(e);
		}

		while (mySettings.List.childNodes.length) {
			mySettings.List.removeChild(mySettings.List.childNodes[0]);
		}

		if (ay.length) {																								// elements buffered?
			ay.sort(																									// yeah! >> let's sort
				function compare(a, b) {																				// our elements based on
					if (a.firstChild.nodeValue < b.firstChild.nodeValue)												// their text.
						return -1;
					if (a.firstChild.nodeValue > b.firstChild.nodeValue)
						return 1;
					return 0;
				}
			);

			f = document.createDocumentFragment();
			for (i = 0; i < ay.length; i++)	{																			// finally add all elements
				f.appendChild(ay[i]);																					// to selection list.
			}
			mySettings.List.appendChild(f);
			mySettings.List.disabled = false;
		}

		if (!mySettings.Closing) {
			_self.Windows['settingsBox'].open();
		}
	}

	function OnHyperlinksLoaded(myData)
	{
	 var nl;
	 var xn;
	 var b;
	 var l = { URL: null, Caption: null, Image: null, AltImage: null };

		b = false;
		nl = WebModel.Common.Helper.selectNodes(myData, '/list/item');
		for (var i = 0; i < nl.length; i++) {
			xn = nl[i];
			l.URL = WebModel.Common.Helper.selectSingleNode(xn, 'uri/text()').nodeValue;
			l.Caption = WebModel.Common.Helper.selectSingleNode(xn, 'name/text()').nodeValue;
			_lm.add(new WebModel.Common.LinkClass(l.URL, l.Caption));
			b = true;
		}

		if (!b) {
			_self.Buttons['hyperlinkMenuLink'].Visible = false;
		}
	}

	function OnTreeReset(myEvent)
	{
	 var dw;	// drawing
	 var te;	// tree element

		switch (myEvent.detail.ID) {
			case 'globalProcessTree':
				_wai.refresh();					// re-translate WAI.
				_pw.refresh();					// re-translate property window.
				_cw.refresh();					// re-translate changes window.
				_rw.close();					// close results window.

				dw = WebModel.Drawing;
				dw.load(dw.GraphicID, dw.PageIndex);
				break;

			default:
				te = document.getElementById(myEvent.detail.ID);
				if (te) {
					_ut.apply(te);
				}
				break;
		}
	}

	function OnTreeNodeClick(myEvent)
	{
	 var sz;
	 var n;

		myEvent = myEvent || event;

		sz = myEvent.detail.Image.src;
		n = sz.lastIndexOf('/');
		if (n >= 0) {
			sz = sz.substr(++n, sz.length - n);
		}

		WebModel.navigate(myEvent.detail.UUID ? myEvent.detail.UUID : myEvent.detail.ID,
						  myEvent.detail.TreeView.ID,
						  sz.match(/processes|decisions/gi) && !myEvent.showProperties,
						  myEvent.HighlightSearch,
						  undefined,
						  myEvent.ShapeUUID);
	}

	function OnObjectClicked(myEvent)
	{
	 var tv;	// treeview
	 var ay;	// array
	 var pe;	// pseudo event
	 var sz;	// string
	 var l;		// link
	 var m;		// match
	 var n;		// node
	 var d;		// direct?
	 var b;		// multiple usage!

		myEvent = myEvent || event;
		if ((!myEvent.detail.Links || !myEvent.detail.Links.length) &&
			!myEvent.detail.Link)
		{
			return;
		}

		if (myEvent.detail.Link) {
			myEvent.detail.Links = new Array(myEvent.detail.Link);
			myEvent.detail.Direct = true;
		}

		l = myEvent.detail.Links[0];
		if (l.Image && l.Image.indexOf('information') >= 0) {
			switch (true) {
				case myEvent.detail.Links.length == 2:
					l = myEvent.detail.Links[1];
					break;
				case myEvent.detail.Links.length == 1:
					myEvent.detail.Direct = true;
					break;
			}
		}
		b = myEvent.detail.Links.length == 1;
		switch (true) {
			case !isNaN(parseFloat(l.URL)):
			case l.URL.match(/^\{[0-9a-fA-F]{8,8}\-[0-9a-fA-F]{4,4}\-[0-9a-fA-F]{4,4}\-[0-9a-fA-F]{4,4}\-[0-9a-fA-F]{12,12}\}$/) != null:
				m = l.Image.match(/.*\/(.*?)\.png/);
				if (!m || !m.length) {
					throw 'Could not determine viflow object type!';
				}

				switch (m[1]) {
					case 'decisions':
					case 'decision':
					case 'processes':
					case 'process':
						tv = _self.TreeViews['globalProcessTree']; 
						break;

					case 'information_link':
					case 'information':
						tv = _self.TreeViews['globalInformationTree'];
						break;

					case 'area':
						tv = _self.TreeViews['globalAreaTree'];
						break;

					default: throw 'Could not determine viflow object type!';
				}

				n = tv.findNode(l.URL, true);
				if (n && n.length) {
					n = n[0];
				}
				if (n) {
					pe = {													// pre-create pseudo event with navigation
						detail: n,											// type
						showProperties:
							l.Image.indexOf('processes.png') < 0 &
							l.Image.indexOf('decisions.png') < 0 &
							l.Image.indexOf('information_link.png') < 0 &
							l.Image.indexOf('information.png') < 0,
						HighlightSearch: myEvent.detail.HighlightSearch,
						ShapeUUID: l.ShapeUUID
					};
					b &= n.Image.src.indexOf('processes.png') < 0;			// let's determine if we're navigating
					b &= n.Image.src.indexOf('decisions.png') < 0;			// to a process graphic.
					b &= n.Image.src.indexOf('information_link.png') < 0;	
					b &= n.Image.src.indexOf('information.png') < 0;
					b |= myEvent.detail.Direct;								// append direct navigation flag to mask.
					if (b) {
						OnTreeNodeClick(pe);
						return;
					}

					ay = new Array();
					for (var i = 0; i < myEvent.detail.Links.length; i++) {
						l = myEvent.detail.Links[i];
						ay.push(l);
						if (i == 0 &&
							(l.Image.indexOf('processes') > 0 || l.Image.indexOf('decisions') > 0) &&
							l.Image.indexOf('information') < 0 &&
							l.Image.indexOf('area') < 0)
						{													// link represents process
							l = new WebModel.Common.LinkClass(				// graphic so we duplicate
								l.URL,										// it and setting dubplicate
								l.Caption + ' ' + _ut.getTranslation('webmodel.ui.contextmenudetails', '(details)'),
								l.Image.indexOf('processes.png') >= 0 ?		// to display details of that
									'./images/ui/process.png' :				// object.
									'./images/ui/decision.png',
								l.AltImage
							);
							ay.push(l);
						}
					}
					myEvent.detail.Links = ay;

				}
				break;

			case (b || myEvent.detail.Direct) && l.URL.match(/mailto:/gi) != null:
				document.location.href = l.URL;
				return;

			case (b || myEvent.detail.Direct):
				sz = l.URL.replace(/\\/gi, '/');							// let's check if target link
				b = sz.lastIndexOf('/');									// would navigate to a *.htm
				if (b >= 0) {												// file. if that's true we try
					sz = sz.substr(b, sz.length - b);						// to load settings.xml file
					if (sz.indexOf('.htm') >= 0) {							// within same folder. on success
						sz = l.URL.substr(0, b);							// we can assume navigation to
						sz += '/data/settings.xml';							// another webmodel and open
						try {												// it in the same window instead
							WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, sz, false);
							document.location.href = l.URL;					// opening a new one (which is
							return;											// the default way!).
						}
						catch (e) {}
					}
				}

				myEvent.detail.Link = l;									// ensuring correct nav on link list!
				_self.navigateURI(myEvent);
				return;

			default:
				ay = myEvent.detail.Links;
				break;
		}

		_cm.clear();
		for (var i = 0; i < ay.length; i++) {
			b = i == 0;
			_cm.add(ay[i],
					!myEvent.detail.HighlighSearch && (
						(i == 0 && ay[i].Image && (ay[i].Image.indexOf('information') < 0 || ay.length != 2)) ||
						(i == 1 && ay[i - 1].Image && ay[i - 1].Image.indexOf('information') >= 0 && ay.length == 2)
					),
					myEvent.detail.HighlightSearch);
		}

		_cm.show(myEvent.detail.Point.X, myEvent.detail.Point.Y);
	}

	function OnDropDownClick(myEvent)
	{
		OnObjectClicked(myEvent);
	}

	function OnDropDownClickWhereAmI(myEvent)
	{
	 var nd;
	 var ay;

		_cm.removeEventListener('click', OnDropDownClickWhereAmI, false);

		if (_cm.IndexWhereAmI) {
			_wai.clearAfter(_cm.IndexWhereAmI);
		} else {
			ay = _cm.Element.getElementsByTagName('li');
			for (var i = 0; i < ay.length; i++) {
				if (ay[i] == myEvent.detail.Element) {
					_wai.clearAfter(i);
					break;
				}
			}
		}

		nd = _self.TreeViews['globalProcessTree'].findNode(WebModel.Settings.CurrentID, true);
		if (!nd) {
			return;
		}

		if (nd.length) {
			nd = nd[0];
		}
		WebModel.UI.WhereAmI.add(nd);
	}

	function OnWhereAmIClick(myEvent)
	{
	 var xslt;
	 var xml;
	 var nl;
	 var nd;
	 var ay;
	 var b;
	 var l = { URL: null, Caption: null, Image: null, AltImage: null };

		if (!myEvent.detail.DropDownRequest) {																// dropdown requested?
			if (WebModel.Drawing.GraphicID != myEvent.detail.Node.ID) {										// no! >> so let's cleanup,
				_wai.clearAfter(myEvent.detail.Index);														// load graphic and add it
				WebModel.navigate(myEvent.detail.Node.ID, myEvent.detail.Node.TreeView.ID, true);			// to WhereAmI...
			}
			return;
		}

		_cm.clear();
		_cm.addEventListener('click', OnDropDownClickWhereAmI, false);

		ay = new Array();
		if (myEvent.detail.SpecialDropDown) {
			ay = _wai.getInvisibleElements();
			for (var i = 0; i < ay.length; i++) {
				nd = ay[i] = ay[i].Node;
				_cm.add(new WebModel.Common.LinkClass(nd.ID, nd.Name, nd.Image.src, nd.Image.src), i == (ay.length - 1));
			}
		} else if (myEvent.detail.PrecedingNode) {
			nd = myEvent.detail.PrecedingNode;
			_cm.add(new WebModel.Common.LinkClass(nd.ID, nd.Name, nd.Image.src, nd.Image.src), true);
			ay.push(nd);
		}

		xslt = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './xslt/intermediate_list_whereami.xslt', false);
		xml = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/empty.xml', false);
		xml = WebModel.Common.Helper.transformXML(xml, xslt, { filter: myEvent.detail.Node.ID, language: WebModel.Settings.LanguageContent, exclusionlist: WebModel.ExclusionData });
		nl = WebModel.Common.Helper.selectNodes(xml, '/list/item');
		for (var i = 0; i < nl.length; i++) {
			xn = nl[i];
			l.URL = WebModel.Common.Helper.selectSingleNode(xn, 'uri/text()').nodeValue;
			l.Image = WebModel.Common.Helper.selectSingleNode(xn, 'image/text()').nodeValue;
			l.AltImage = WebModel.Common.Helper.selectSingleNode(xn, 'altimage/text()');
			if (l.AltImage) {
				l.AltImage = l.AltImage.nodeValue;
			}
			sz = (WebModel.Settings.DisplayText == SettingsClass.DisplayText.Name) ? 'name' : 'shapetext';
			l.Caption = WebModel.Common.Helper.selectSingleNode(xn, sz + '/text()').nodeValue;

			b = false;
			for (var j = 0; j < ay.length; j++) {
				b |= (l.URL == ay[j].ID);
			}

			if (!b) {
				_cm.add(new WebModel.Common.LinkClass(l.URL, l.Caption, l.Image, l.AltImage));
			}
		}
		_cm.IndexWhereAmI = myEvent.detail.Index;
		_cm.show(myEvent.detail.X, myEvent.detail.Y);
	}

	function OnLinkMenuClick(myEvent)
	{
		if (!myEvent.detail || !myEvent.detail.Link) {
			return;
		}

		_self.navigateURI(myEvent);
	}

	function OnSearch(myEvent)
	{
	 var ts;
	 var t;
	 var e;
	 var i;

		e = document.getElementById('searchField');
		if (!e) {
			throw 'Could not find search field!';
		}

		i = 0;
		ts = _self.TabStrips['resulttabs'];
		for (var k in ts.Tabs) {
			t = ts.Tabs[k];
			if (!(t instanceof ts.TabClass)) {
				continue;
			}

			t.Selected = (i == 0);
			i++;
		}

		WebModel.Search.find(e.value);
		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnLogoLoadError(myEvent)
	{
	 var sz;
	 var i;

		sz = this.src;
		i = sz.indexOf('images/ui/logo.png');
		if (i < 0) {
			this.setAttribute('src', './images/ui/logo.png');
		}

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.performObjectNavigation = function (myPoint, myLinkList, direct, highlightSearch)
	{
	 var oe;	// object event

		if (myPoint == null) {
			throw 'myEvent must not be null!';
		}

		if (myLinkList == null) {
			throw 'myLinkList must not be null!';
		}

		if (!(myLinkList instanceof Array)) {
			throw 'myLinkList must be typeof Array<LinkClass>!';
		}

		for (var i = 0; i < myLinkList.length; i++) {
			if (!(myLinkList[i] instanceof WebModel.Common.LinkClass)) {
				throw 'myLinkList must be typeof Array<LinkClass>!';
			}
		}

		oe = document.createEvent('CustomEvent');
		oe.initCustomEvent('objectclicked', true, false, { Point: myPoint, Links: myLinkList, Direct : !!direct, HighlightSearch: highlightSearch });
		_self.dispatchEvent(oe);
	}

	this.navigateURI = function (myEvent)
	{
	 var sz;
     var h;
	 var n;
	 var l;
	 var r;
	 var m;

		WebModel.Common.Helper.cancelEvent(myEvent);												

		l = document.location.href;
		n = l.lastIndexOf('/');
		if (n >= 0) {
			l = l.substr(0, n);
		}

		sz = !(myEvent.target || myEvent.srcElement) ? myEvent.detail.Link.URL : (myEvent.target || myEvent.srcElement).getAttribute('href');		// let's fetch link and calc
		sz = sz.replace(l, '');																		// it's full path hash value.
		h = WebModel.Common.Helper.calculateHash(sz);

		sz = sz.replace(/\\/gi, '/');																// prepare link to contain
		n = sz.lastIndexOf('/');																	// file name only.
		if (n >= 0) {
			sz = sz.substr(++n, sz.length - n);
		}

		r = /#pagelink:([0-9]+).*/gim;
		m = r.exec(sz);
		if (m) {
			WebModel.Drawing.load(WebModel.Drawing.GraphicID, m[1]);
			return;
		}

		sz = './documents/' + h + '_' + sz;															// prepend docs folder and
		if (!WebModel.Common.Helper.validateURI(sz) &&												// hash and check validity.
			!WebModel.Common.Helper.validateURI(encodeURI(sz)))										// not valid? >> reset link!
		{																							
			sz = !(myEvent.target || myEvent.srcElement) ? myEvent.detail.Link.URL : (myEvent.target || myEvent.srcElement).getAttribute('href');
			if (sz.indexOf('://') < 0 && !sz.match(/mailto\:/gi) && sz.indexOf('.') != 0) {
				sz = 'file:///' + sz;
			}
		}
		
		try {
			if (sz.match(/mailto\:/gi)) {															// finally we try to open
				document.location.href = sz;														// the link and catch all
			} else {																				// exceptions for being...
				if (sz.indexOf('./documents') == 0) {												// copied file?
					sz = l + '/' + sz;																// yeah! >> let's fix chrome's
				}																					// bug prepending base location.
				window.open(sz);																
			}																					
		}																						
		catch (e) {}																			

		WebModel.Common.Helper.cancelEvent(myEvent);												// ...able to cancel click!
	}

	//// ~~~~ private functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function connectMarkup()
	{
	 var xslt;
	 var xml;
	 var ue; 	// ui element
	 var tv;	// treeview
	 var ts;	// tabstrip
	 var t;		// tab
	 var v;		// value (multiple usage)

		_fti = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI,				// first of all we initialize
											  './data/filetypes.xml',										// our file type icons definition.
											  false);

		ue = document.getElementById('logo');																// the second step is to try to load
		if (!ue) {																							// custom logo if specified and
			throw 'Logo element not found!';																// file type icons xml.
		}
		ue.addEventListener('error', OnLogoLoadError, false);
		if (WebModel.Settings.CustomLogo) {
			ue.setAttribute('src', './images/' + WebModel.Settings.CustomLogo);
		}

		ue = document.getElementById('naviProcessesLink'); 													// let's create our navigation
		if (!ue) {																							// button objects and attach
			throw 'Process button not found!'; 																// click handler to them.
		}
		_self.Buttons.add(new ButtonClass(ue, ButtonClass.Styles.MenuPress, Array('naviInformationLink', 'naviAreasLink')), ue.id);
		_self.Buttons[ue.id].addEventListener('buttonclicked', OnButtonClick, false);

		ue = document.getElementById('naviInformationLink');
		if (!ue) {
			throw 'Information button not found!';
		}
		_self.Buttons.add(new ButtonClass(ue, ButtonClass.Styles.MenuPress, Array('naviProcessesLink', 'naviAreasLink')), ue.id);
		_self.Buttons[ue.id].addEventListener('buttonclicked', OnButtonClick, false);

		ue = document.getElementById('naviAreasLink');
		if (!ue) {
			throw 'Areas button not found!';
		}
		_self.Buttons.add(new ButtonClass(ue, ButtonClass.Styles.MenuPress, Array('naviProcessesLink', 'naviInformationLink')), ue.id);
		_self.Buttons[ue.id].addEventListener('buttonclicked', OnButtonClick, false);

		ue = document.getElementById('naviHistoryLink');
		if (!ue) {
			throw 'History button not found!';
		}
		_self.Buttons.add(new ButtonClass(ue, ButtonClass.Styles.MenuPress), ue.id);
		_self.Buttons[ue.id].addEventListener('buttonclicked', OnButtonClick, false);

		ue = document.getElementById('naviZoomLink');
		if (!ue) {
			throw 'Zoom button not found!';
		}
		_self.Buttons.add(new ButtonClass(ue, ButtonClass.Styles.MenuPress), ue.id);
		_self.Buttons[ue.id].addEventListener('buttonclicked', OnButtonClick, false);

		ue = document.getElementById('naviFeedbackLink');
		if (!ue) {
			throw 'Feedback button not found!';
		}
		_self.Buttons.add(new ButtonClass(ue, ButtonClass.Styles.MenuDefault), ue.id);
		_self.Buttons[ue.id].addEventListener('buttonclicked', OnButtonClick, false);

		ue = document.getElementById('hyperlinkMenuLink');
		if (!ue) {
			throw 'Hyperlink button not found!';
		}
		_self.Buttons.add(new ButtonClass(ue, ButtonClass.Styles.MenuDropDown, null, document.getElementById('hyperlinkMenuUl')), ue.id);

		ue = document.getElementById('hyperlinkMenuUl');
		if (!ue) {
			throw 'Hyperlink Menu DropDown not found!';
		}
		_lm = new DropDownClass(ue);
		_lm.clear();
		_lm.addEventListener('click', OnLinkMenuClick, false);
		WebModel.Common.Helper.performAsyncTransform('./data/settings.xml',
													 './xslt/intermediate_list_settinglinks.xslt',
													 OnHyperlinksLoaded
		);

		ue = document.getElementById('naviSettingsLink');
		if (!ue) {
			throw 'Settings button not found!';
		}
		_self.Buttons.add(new ButtonClass(ue, ButtonClass.Styles.MenuDefault), ue.id);
		_self.Buttons[ue.id].addEventListener('buttonclicked', OnButtonClick, false);

		ue = document.getElementById('naviHelpLink');
		if (!ue) {
			throw 'Help button not found!';
		}
		_self.Buttons.add(new ButtonClass(ue, ButtonClass.Styles.MenuDefault), ue.id);
		_self.Buttons[ue.id].addEventListener('buttonclicked', OnButtonClick, false);

		ue = document.getElementById('rssButton');
		if (!ue) {
			throw 'RSS button not found!';
		}
		_self.Buttons.add(new ButtonClass(ue, ButtonClass.Styles.MenuDefault), ue.id);
		_self.Buttons[ue.id].addEventListener('buttonclicked', OnButtonClick, false);

		ue = document.getElementById('searchForm');
		if (!ue) {
			throw 'Search form not found!';
		}
		ue.addEventListener('submit', OnSearch, false);

		ue = document.getElementById('zoomBox'); 															// let's create our window objects
		if (!ue) {																							// and attach state handler to them.
			throw 'Zoom window not found!';
		}
		_self.Windows.add(new WindowClass(ue, WindowClass.Styles.ModelessDialog), ue.id);
		_self.Windows[ue.id].addEventListener('windowstatechanged', OnWindowStateChanged, false);
		v = WebModel.Settings.ZoomWindowPosition.split(';');
		if (v.length == 2) {
			_self.Windows[ue.id].Position = { Left: v[0], Top: v[1] };
		}
		_self.Windows[ue.id].Visible = WebModel.Settings.ZoomWindowVisible;

		ue = document.getElementById('resultBox');
		if (!ue) {
			throw 'Search Result window not found!';
		}
		_rw = new ResultWindowClass(ue, WindowClass.Styles.ModelessDialog);
		_self.Windows.add(_rw, ue.id);
		_self.Windows[ue.id].addEventListener('windowstatechanged', OnWindowStateChanged, false);
		v = WebModel.Settings.ResultWindowPosition.split(';');
		if (v.length == 4) {
			_self.Windows[ue.id].Position = { Left: v[0], Top: v[1], Width: v[2], Height: v[3] };
		}

		ue = document.getElementById('whatsChangedBox');
		if (!ue) {
			throw 'Changes window not found!';
		}
		_cw = new ChangesWindowClass(ue, WindowClass.Styles.ModelessDialog);
		_self.Windows.add(_cw, ue.id);
		_self.Windows[ue.id].addEventListener('windowstatechanged', OnWindowStateChanged, false);
		v = WebModel.Settings.ChangesWindowPosition.split(';');
		if (v.length == 4) {
			_self.Windows[ue.id].Position = { Left: v[0], Top: v[1], Width: v[2], Height: v[3] };
		}

		ue = document.getElementById('settingsBox');
		if (!ue) {
			throw 'Settings window not found!';
		}
		_self.Windows.add(new WindowClass(ue), ue.id);
		_self.Windows[ue.id].addEventListener('windowstatechanged', OnWindowStateChanged, false);

		ue = document.getElementById('propertiesWindow');
		if (!ue) {
			throw 'Property window not found!';
		}
		_pw = new PropertyWindowClass(ue, WindowClass.Styles.ModelessDialog);
		_self.Windows.add(_pw, ue.id);
		_self.Windows[ue.id].addEventListener('windowstatechanged', OnWindowStateChanged, false);
		v = WebModel.Settings.PropertyWindowPosition.split(';');
		if (v.length == 4) {
			_self.Windows[ue.id].Position = { Left: v[0], Top: v[1], Width: v[2], Height: v[3] };
		}

		ue = document.getElementById('objectNav');
		if (!ue) {
			throw 'Object navigation window not found!';
		}
		_self.Windows.add(new WindowClass(ue, WindowClass.Styles.Dock), ue.id);
		_self.Windows[ue.id].addEventListener('windowstatechanged', OnWindowStateChanged, false);
		v = WebModel.Settings.NavigationPosition;
		if (v.length > 0) {
			_self.Windows[ue.id].Position = { Width: v };
		}
		_self.Windows[ue.id].Visible = WebModel.Settings.NavigationVisible;
		if (WebModel.Settings.NavigationVisible)
			_self.Buttons['naviProcessesLink'].toggle(); {
		}

		ue = document.getElementById('processOverview');
		if (!ue) {
			throw 'Process Overview not found!';
		}
		_self.TabStrips.add(new TabStripClass(ue, { 'globalProcessTab':'globalProcessTree', 'myProcessTab':'myProcessTree' }), ue.id);
		for (v in _self.TabStrips[ue.id].Tabs) {
			t = _self.TabStrips[ue.id].Tabs[v];
			if (!(t instanceof _self.TabStrips[ue.id].TabClass)) {
				continue;
			}
			t.Visible = (WebModel.Settings.CurrentUser != 0);
			t.Selected = (t.ID.indexOf('global') >= 0 && !t.Visible) ||
							(t.ID.indexOf('global') < 0 && t.Visible);
		}

		ue = document.getElementById('pagetabs');
		if (!ue) {
			throw 'Page Tabs control not found!';
		}
		_self.TabStrips.add(new TabStripClass(ue), ue.id);
		_self.TabStrips[ue.id].addEventListener('visibilitychanged', OnTabStripVisibilityChanged, false);
		_self.TabStrips[ue.id].addEventListener('tabselected', OnTabSelected, false);

		ue = document.getElementById('resulttabs');
		if (!ue) {
			throw 'Result Tabs control not found!';
		}
		_self.TabStrips.add(new TabStripClass(ue, { 'result_all':'resultData', 'result_processes':'resultData', 'result_information':'resultData', 'result_areas':'resultData' }), ue.id);
		_self.TabStrips[ue.id].addEventListener('tabselected', OnTabSelected, false);

		ue = document.getElementById('informationOverview');
		if (!ue) {
			throw 'Information Overview not found!';
		}
		_self.TabStrips.add(new TabStripClass(ue, { 'globalInformationTab':'globalInformationTree', 'myInformationTab':'myInformationTree' }), ue.id);
		for (v in _self.TabStrips[ue.id].Tabs) {
			t = _self.TabStrips[ue.id].Tabs[v];
			if (!(t instanceof _self.TabStrips[ue.id].TabClass)) {
				continue;
			}
			t.Visible = (WebModel.Settings.CurrentUser != 0);
			t.Selected = (t.ID.indexOf('global') >= 0 && !t.Visible) ||
							(t.ID.indexOf('global') < 0 && t.Visible);
		}

		ue = document.getElementById('areaOverview');
		if (!ue) {
			throw 'Areas Overview not found!';
		}
		_self.TabStrips.add(new TabStripClass(ue, { 'globalAreaTab':'globalAreaTree', 'myAreaTab':'myAreaTree' }), ue.id);
		for (v in _self.TabStrips[ue.id].Tabs) {
			t = _self.TabStrips[ue.id].Tabs[v];
			if (!(t instanceof _self.TabStrips[ue.id].TabClass)) {
				continue;
			}
			t.Visible = (WebModel.Settings.CurrentUser != 0);
			t.Selected = (t.ID.indexOf('global') >= 0 && !t.Visible) ||
							(t.ID.indexOf('global') < 0 && t.Visible);
		}

		ue = document.getElementById('globalProcessTree');
		if (!ue) {
			throw 'Global Process Tree not found!';
		}
		xslt = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './xslt/intermediate_tree_processes.xslt', false);
		xml = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/empty.xml', false);
		xml = WebModel.Common.Helper.transformXML(xml, xslt, { language: WebModel.Settings.LanguageContent, exclusionlist: WebModel.ExclusionData });
		tv = new TreeViewClass(ue, xml, true);
		_self.TreeViews.add(tv, ue.id);
		_self.TreeViews[ue.id].addEventListener('nodeclicked', OnTreeNodeClick, false);
		_self.TreeViews[ue.id].addEventListener('reset', OnTreeReset, false);

		ue = document.getElementById('myProcessTree');
		if (!ue) {
			throw 'Personalized Process Tree not found!';
		}
		xslt = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './xslt/intermediate_tree_processes_personalized.xslt', false);
		xml = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/empty.xml', false);
		xml = WebModel.Common.Helper.transformXML(xml, xslt, { filter: WebModel.Settings.CurrentUser ? WebModel.Settings.CurrentUser : 0, dependents: +WebModel.Settings.DependentObjects, language: WebModel.Settings.LanguageContent, exclusionlist: WebModel.ExclusionData });
		tv = new TreeViewClass(ue, xml, true);
		_self.TreeViews.add(tv, ue.id);
		_self.TreeViews[ue.id].addEventListener('nodeclicked', OnTreeNodeClick, false);
		_self.TreeViews[ue.id].addEventListener('reset', OnTreeReset, false);

		ue = document.getElementById('globalInformationTree');
		if (!ue) {
			throw 'Global Information Tree not found!';
		}
		xslt = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './xslt/intermediate_tree_information.xslt', false);
		xml = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/empty.xml', false);
		xml = WebModel.Common.Helper.transformXML(xml, xslt, { language: WebModel.Settings.LanguageContent, renferencedonly: +WebModel.Settings.ReferencedInfosOnly, exclusionlist: WebModel.ExclusionData });
		tv = new TreeViewClass(ue, xml);
		_self.TreeViews.add(tv, ue.id);
		_self.TreeViews[ue.id].addEventListener('nodeclicked', OnTreeNodeClick, false);
		_self.TreeViews[ue.id].addEventListener('reset', OnTreeReset, false);

		ue = document.getElementById('myInformationTree');
		if (!ue) {
			throw 'Personalized Information Tree not found!';
		}
		xslt = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './xslt/intermediate_tree_information_personalized.xslt', false);
		xml = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/empty.xml', false);
		xml = WebModel.Common.Helper.transformXML(xml, xslt, { filter: WebModel.Settings.CurrentUser ? WebModel.Settings.CurrentUser : 0, dependents: +WebModel.Settings.DependentObjects, language: WebModel.Settings.LanguageContent, renferencedonly: +WebModel.Settings.ReferencedInfosOnly, exclusionlist: WebModel.ExclusionData });
		tv = new TreeViewClass(ue, xml, true);
		_self.TreeViews.add(tv, ue.id);
		_self.TreeViews[ue.id].addEventListener('nodeclicked', OnTreeNodeClick, false);
		_self.TreeViews[ue.id].addEventListener('reset', OnTreeReset, false);

		ue = document.getElementById('globalAreaTree');
		if (!ue) {
			throw 'Global Area Tree not found!';
		}
		xslt = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './xslt/intermediate_tree_areas.xslt', false);
		xml = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/empty.xml', false);
		xml = WebModel.Common.Helper.transformXML(xml, xslt, { language: WebModel.Settings.LanguageContent, renferencedonly: +WebModel.Settings.ReferencedAreasOnly, exclusionlist: WebModel.ExclusionData });
		tv = new TreeViewClass(ue, xml);
		_self.TreeViews.add(tv, ue.id);
		_self.TreeViews[ue.id].addEventListener('nodeclicked', OnTreeNodeClick, false);
		_self.TreeViews[ue.id].addEventListener('reset', OnTreeReset, false);

		ue = document.getElementById('myAreaTree');
		if (!ue) {
			throw 'Personalized Area Tree not found!';
		}
		xslt = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './xslt/intermediate_tree_areas_personalized.xslt', false);
		xml = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/empty.xml', false);
		xml = WebModel.Common.Helper.transformXML(xml, xslt, { filter: WebModel.Settings.CurrentUser ? WebModel.Settings.CurrentUser : 0, dependents: +WebModel.Settings.DependentObjects, language: WebModel.Settings.LanguageContent, renferencedonly: +WebModel.Settings.ReferencedAreasOnly, exclusionlist: WebModel.ExclusionData });
		tv = new TreeViewClass(ue, xml, true);
		_self.TreeViews.add(tv, ue.id);
		_self.TreeViews[ue.id].addEventListener('nodeclicked', OnTreeNodeClick, false);
		_self.TreeViews[ue.id].addEventListener('reset', OnTreeReset, false);

		ue = document.getElementById('whereami');
		if (!ue) {
			throw 'Where Am I not found!';
		}
		_wai = new WhereAmIClass(ue);
		_wai.add(_self.TreeViews['globalProcessTree'].findNode(WebModel.Settings.CurrentID, true));
		_wai.addEventListener('click', OnWhereAmIClick, false);

		ue = document.getElementById('svgport');
		if (!ue) {
			throw 'SVG Port not found!';
		}
		_da = new DrawingAreaClass(ue);
		_da.Element.parentElement.style.left = _self.Windows['objectNav'].Position.Width + 'px';

		ue = document.getElementById('contextmenu');
		if (!ue) {
			throw 'Context menu not found!';
		}
		_cm = new DropDownClass(ue);
		_cm.addEventListener('click', OnDropDownClick, false);

		_ut.apply();

		window.addEventListener('resize', OnMainWindowResize, false);
		OnMainWindowResize(null);

		_self.addEventListener('objectclicked', OnObjectClicked, false);
	}
}
///
/// End :: UI Class
///

/// <summary>
/// This class provides all functionality
/// for translating the UI of this WebApp.
/// </summary>
function TranslationsClass()
{
	//// ~~~~ constants ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var TRANSLATION_BASE = 'WebModel.UI.';

	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _wmh;	// WebModel helper
	var _wmc;	// WebModel helper class
	var _wmd;	// WebModel diagnostics console
	var _wms;	// WebModel settings
	var _tb;	// translation base

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_self = this;

	_wmh = WebModel.Common.Helper;
	_wmc = WebModel.Common.HelperClass;
	_wms = WebModel.Settings;
	_wmd = WebModel.Diagnostics.Console;

	_tb = _wmh.loadXML(_wmc.XmlLoadMethods.URI, './data/ui.xml', false);

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.getTranslation = function (myKey, myDefaultValue)
	{
		if (!myKey) {
			throw 'myKey must not be null!';
		}

		if (!myDefaultValue) {
			myDefaultValue = '';
		}

		sz = WebModel.Settings.LanguageUI || '';
		if (sz == 'en') {
			xml = _tb;
		} else {
			sz += '.xml';
			try {
				xml = _wmh.loadXML(_wmc.XmlLoadMethods.URI, './data/ui.' + sz, false);
				if (xml.status != undefined && xml.status != 200 && xml.status != 0) {
					throw 'Could not find localization file for \'' + (WebModel.Settings.LanguageUI || '') + '\'. Switching to neutral language!';
				}
			}
			catch (e) {
				_wmd.warn('Could not find localization file for \'' + (WebModel.Settings.LanguageUI || '') + '\'. Switching to neutral language!');
				xml = _tb;
				sz = 'en';
				WebModel.Settings.LanguageUI = 'en';
			}
		}

		sz = '/root/data[@name="' + myKey + '"]/value/text()';
		nd = _wmh.selectSingleNode(_tb, sz);
		sz = (_wmh.selectSingleNode(xml, sz) || { nodeValue: '' }).nodeValue;
		if (sz.length == 0) {
			_wmd.log('Could not find translation for element ' + myKey + '.');
			return myDefaultValue;
		}

		if (!nd && myDefaultValue.length > 0) {
			nd = _wmh.selectSingleNode(_tb, '/root').appendChild(_tb.createElement('data'));
			nd.setAttribute('name', myKey);
			nd.setAttribute('xml:space', 'preserve');
			nd = nd.appendChild(_tb.createElement('value'));
			nd.appendChild(_tb.createTextNode(myDefaultValue));
		}

		return sz;
	}

	this.apply = function (myRoot)
	{
	 var xml;
	 var nd;	// node
	 var ka;	// key array
	 var ay;	// DOM node array
	 var nd;	// node
	 var nk;	// node key
	 var id;
	 var sz;
	 var m;		// matching
	 var e;		// element
	 var a;		// attribute

		ay = (myRoot || document).getElementsByTagName('*');
		if (!ay || ay.length == 0) {
			return;
		}

		ka = new Array('', 'alt', 'title', 'value');
		for (var i = 0; i < ay.length; i++) {
			e = ay[i];
			if (e.id) {
				id = e.id.toLowerCase();
				if (m = (/^(.*)\.[0-9]+$/gim).exec(id)) {
					id = m[1];
				}
				for (var k = 0; k < ka.length; k++) {
					a = ka[k];
					nk = TRANSLATION_BASE.toLocaleLowerCase() + (a.length > 0 ? a + '.' : '') + id; 
					switch (true) {
						case (a.length == 0):
							for (var j = 0; j < e.childNodes.length; j++) { 
								nd = e.childNodes[j];
								if (nd.nodeType == 3) {
									nd.data = _self.getTranslation(nk, nd.data);
									break;
								}
							}
							break;
					
						case e.hasAttribute(a) && a == 'value':
							sz = _self.getTranslation(nk, e.value);
							if (e.value != sz) {
								e.value = sz;
							}
							break;

						case e.hasAttribute(a):
							sz = _self.getTranslation(nk, e.getAttribute(a));
							if (e.getAttribute(a) != sz) {
								e.setAttribute(a, sz);
							}
							break;
					}
				}
			}
		}
	}
}
///
/// End :: Translations Class
///

/// <summary>
/// This class provides all functionality
/// for creating and interacting with
/// window objects.
/// </summary>
function WindowClass(myElement, myStyle)
{
	//// ~~~~ constants ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var MAX_ZINDEX = 0xFFFFF;

	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _go;		// gesture objects
	var _we; 		// window element
	var _ws;		// window style
	var _te; 		// title element
	var _ce; 		// close element
	var _wp; 		// window position
	var _se; 		// window state event
	var _mo; 		// modal overlay
	var _sl;		// slider element
	var _cs;		// corner slider element

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "Visible", {
		get: function () { return _we.style.display == 'inherit'; },
		set: function (myValue) {
			if (myValue == (_we.style.display == 'inherit'))
				return;
			switch (myValue) {
				case true:
					_self.open();
					break;
				case false:
					_self.close();
					break;
			}
		}
	});

	Object.defineProperty(this, "Position", {
		get: function () {
			return {
				Left: parseInt(_we.style.left),
				Top: parseInt(_we.style.top),
				Width: parseInt(_we.offsetWidth),
				Height: parseInt(_we.offsetHeight)
			};
		},
		set: function (myValue) {
			if (!myValue)
				return;

			if (myValue.Left != undefined && !isNaN(parseInt(myValue.Left)) && parseInt(myValue.Left) > 0)
				_we.style.left = myValue.Left + 'px';
			if (myValue.Top != undefined && !isNaN(parseInt(myValue.Top)) && parseInt(myValue.Top) > 0)
				_we.style.top = myValue.Top + 'px';
			if (myValue.Width != undefined && !isNaN(parseInt(myValue.Width)) && parseInt(myValue.Width) < document.body.offsetWidth)
				_we.style.width = (myValue.Width - parseInt(WebModel.Common.Helper.getStyle(_we, 'paddingLeft')) - parseInt(WebModel.Common.Helper.getStyle(_we, 'paddingRight'))) + 'px';
			if (myValue.Height != undefined && !isNaN(parseInt(myValue.Height)) && parseInt(myValue.Height) < document.body.offsetHeight)
				_we.style.height = (myValue.Height - parseInt(WebModel.Common.Helper.getStyle(_we, 'paddingTop')) - parseInt(WebModel.Common.Helper.getStyle(_we, 'paddingBottom'))) + 'px';
		}
	});

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_self = this;
	_self.extendAsEventDispatcher(); 																		// let's extend as dispatcher.

	if (!myElement)
		throw 'myElement must not be null!';

	_go = new Array();

	_we = myElement;
	_ws = myStyle || WindowClass.Styles.ModalDialog;

	switch (_ws) {																							// attach slider evvents
		case WindowClass.Styles.Dock:
			_sl = _we.getElementsByClassName('slider');
			if (_sl.length) {
				_sl = _sl[0];
			}
			if (!_sl.className || _sl.className != 'slider') {
				_sl = null;
			} else {
				_sl.addEventListener('touchstart', OnTouchStart, false);
				_sl.addEventListener('touchmove', OnTouchMove, false);
				_sl.addEventListener('touchend', OnTouchEnd, false);
				_sl.addEventListener('mousedown', OnMouseDown, false);
				window.addEventListener('mousemove', OnMouseMove, false);
				window.addEventListener('mouseup', OnMouseUp, false);
				Object.addMSGestureEventListener(_sl, 'MSGestureChange', OnGestureChange, false);
			}
			break;

		case WindowClass.Styles.ModelessDialog:
			_cs = _we.getElementsByClassName('cornerSlider');
			if (_cs.length) {
				_cs = _cs[0];
			}
			if (!_cs.className || _cs.className != 'cornerSlider') {
				_cs = null;
			} else {
				_we.addEventListener('focus', OnFocus, true);
				_we.addEventListener('blur', OnBlur, true);
				_we.addEventListener('mousedown', OnMouseDown, false);
				_cs.addEventListener('touchstart', OnTouchStart, false);
				_cs.addEventListener('touchmove', OnTouchMove, false);
				_cs.addEventListener('touchend', OnTouchEnd, false);
				_cs.addEventListener('mousedown', OnMouseDown, false);
				window.addEventListener('mousemove', OnMouseMove, false);
				window.addEventListener('mouseup', OnMouseUp, false);
				Object.addMSGestureEventListener(_cs, 'MSGestureChange', OnGestureChange, false);
			}
			break;
	}

	_te = _we.getElementsByTagName('div');
	if (_te)
		_te = _te[0];
	if (_te && _te.className == 'boxTop Movable') {
		_te.addEventListener('touchstart', OnTouchStart, false);
		_te.addEventListener('touchmove', OnTouchMove, false);
		_te.addEventListener('touchend', OnTouchEnd, false);
		_te.addEventListener('mousedown', OnMouseDown, false);
		window.addEventListener('mousemove', OnMouseMove, false);
		window.addEventListener('mouseup', OnMouseUp, false);
		Object.addMSGestureEventListener(_te, 'MSGestureChange', OnGestureChange, false);
	}

	_ce = _te.getElementsByTagName('span');
	if (_ce)
		_ce = _ce[0];
	if (_ce)
		_ce.addEventListener('click', OnClick, false);
	else
		_ce = null;

	_mo = document.getElementById('modaloverlay');
	if (_ws == WindowClass.Styles.ModalDialog && !_mo) {
		_mo = document.createElement('div');
		_mo.id = 'modaloverlay';
		_mo.style.position = 'absolute';
		_mo.style.left = '0px';
		_mo.style.top = '0px';
		_mo.style.width = '100%';
		_mo.style.height = '100%';
		_mo.style.opacity = '0.5';
		_mo.style.backgroundColor = '#000000';
		_mo.style.display = 'none';

		document.body.appendChild(_mo);
	}

	//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function OnFocus(myEvent)
	{
		myEvent = myEvent || event;

		_we.style.zIndex = parseInt(WebModel.Common.Helper.getStyle(_we, 'zIndex')) + 1;
		//_te.focus();	// this is causing issues with add-in controls getting focus!

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnBlur(myEvent)
	{
		myEvent = myEvent || event;

		_we.style.zIndex = parseInt(WebModel.Common.Helper.getStyle(_we, 'zIndex')) - 1;

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnClick(myEvent)
	{
		myEvent = myEvent || event;
		if ((myEvent.target || myEvent.srcElement) != _ce)
			return;

		_self.close();

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnMouseDown(myEvent)
	{
	 var o;
	 var h;
	 var d;
	 var b;

		_we.focus();

		OnMouseMove(myEvent);

		h = WebModel.Common.Helper;
		d = WebModel.Drawing;

		myEvent = myEvent || event;
		o = !myEvent.targetTouches ? myEvent : myEvent.targetTouches[0];
		if ((o.target || o.srcElement) == _ce) {
			OnClick(myEvent);
			return;
		}

		b = true;
		b &= o.target != _cs && o.currentTarget != _cs && o.srcElement != _cs;
		b &= o.target != _te && o.currentTarget != _te && o.srcElement != _te;
		b &= (h.getStyle(_we, 'cursor') == 'auto' ||
			  h.getStyle(_we, 'cursor') == 'default' ||
			  h.getStyle(_we, 'cursor') == 'pointer' ||
			  h.getStyle(_we, 'cursor') == '');

		if (o.target) {
			b &= (h.getStyle(o.target, 'cursor') == 'auto' ||
				  h.getStyle(o.target, 'cursor') == 'default' ||
				  h.getStyle(o.target, 'cursor') == 'pointer' ||
				  h.getStyle(o.target, 'cursor') == '');
		}

		if (o.currentTarget) {
			b &= (h.getStyle(o.currentTarget, 'cursor') == 'auto' ||
				  h.getStyle(o.currentTarget, 'cursor') == 'default' ||
				  h.getStyle(o.currentTarget, 'cursor') == 'pointer' ||
				  h.getStyle(o.currentTarget, 'cursor') == '');
		}

		if (o.srcElement) {
			b &= (h.getStyle(o.srcElement, 'cursor') == 'auto' ||
				  h.getStyle(o.srcElement, 'cursor') == 'default' ||
				  h.getStyle(o.srcElement, 'cursor') == 'pointer' ||
				  h.getStyle(o.srcElement, 'cursor') == '');
		}

		if (b) {
			return;
		}

		if (!_wp) {
			d.InteractionEnabled = false;
			_wp = {
				X: _we.offsetLeft,
				Y: _we.offsetTop,
				Width: (_we.offsetWidth - parseInt(h.getStyle(_we, 'paddingLeft')) - parseInt(h.getStyle(_we, 'paddingRight'))),
				Height: (_we.offsetHeight - parseInt(h.getStyle(_we, 'paddingTop')) - parseInt(h.getStyle(_we, 'paddingBottom'))),
				Offset: {
					X: o.clientX - _we.offsetLeft,
					Y: o.clientY - _we.offsetTop,
					Width: o.clientX - (_we.offsetWidth - parseInt(h.getStyle(_we, 'paddingLeft')) - parseInt(h.getStyle(_we, 'paddingRight'))),
					Height: o.clientY - (_we.offsetHeight - parseInt(h.getStyle(_we, 'paddingTop')) - parseInt(h.getStyle(_we, 'paddingBottom')))
				},
				Move: (o.target || o.srcElement) != _cs,
				OnTouch: myEvent.targetTouches != undefined
			};
		}

		h.cancelEvent(myEvent);
	}

	function OnMouseMove(myEvent)
	{
	 var CURSOR_PIXELS = 0x5;
	 var o;
	 var c;

		myEvent = myEvent || event;
		o = !myEvent.targetTouches ? myEvent : myEvent.targetTouches[0];
		if ((o.target || o.srcElement) == _ce) {
			return;
		}

		if (!_wp && _cs && ((o.target || o.srcElement) == _we || (o.target || o.srcElement) == _te)) {
			c = '';																		
			p = { X: o.clientX - _we.offsetLeft, Y: o.clientY - _we.offsetTop };			// get cursor position.

			if (p.Y >= 0 &&																	// north border?
				p.Y <= CURSOR_PIXELS)																	
			{ c += 'n'; }

			if (p.Y >= _we.clientHeight - CURSOR_PIXELS &&									// south border?
				p.Y <= _we.clientHeight)
			{ c += 's'; }

			if (p.X >= 0 &&																	// west border?
				p.X <= CURSOR_PIXELS)
			{ c += 'w'; }

			if (p.X >= _we.clientWidth - CURSOR_PIXELS &&									// east border?
				p.X <= _we.clientWidth)
			{ c += 'e'; }

			if (c.length == 0) {
				c = 'default';
			}

			if (c != 'move' && c != 'default') {
				c += '-resize';
			}

			_we.style.cursor = c;
		}

		if (_wp && _wp.OnTouch == (myEvent.targetTouches != undefined)) {
			c = _we.style.cursor;

			switch (true) {
				case c.length && c == 'n-resize':
					_we.style.top = o.clientY - _wp.Offset.Y + 'px';
					_we.style.height = _wp.Height - ((o.clientY - _wp.Offset.Y) - _wp.Y) + 'px';
					break;

				case c.length && c == 'e-resize':
					_we.style.width = o.clientX - _wp.Offset.Width + 'px';
					break;

				case c.length && c == 's-resize':
					_we.style.height = o.clientY - _wp.Offset.Height + 'px';
					break;

				case c.length && c == 'w-resize':
					_we.style.left = o.clientX - _wp.Offset.X + 'px';
					_we.style.width = _wp.Width - ((o.clientX - _wp.Offset.X) - _wp.X) + 'px';
					break;

				case c.length && c == 'ne-resize':
					_we.style.top = o.clientY - _wp.Offset.Y + 'px';
					_we.style.width = o.clientX - _wp.Offset.Width + 'px';
					_we.style.height = _wp.Height - ((o.clientY - _wp.Offset.Y) - _wp.Y) + 'px';
					break;

				case c.length && c == 'nw-resize':
					_we.style.left = o.clientX - _wp.Offset.X + 'px';
					_we.style.top = o.clientY - _wp.Offset.Y + 'px';
					_we.style.width = _wp.Width - ((o.clientX - _wp.Offset.X) - _wp.X) + 'px';
					_we.style.height = _wp.Height - ((o.clientY - _wp.Offset.Y) - _wp.Y) + 'px';
					break;

				case c.length && c == 'se-resize':
					_we.style.width = o.clientX - _wp.Offset.Width + 'px';
					_we.style.height = o.clientY - _wp.Offset.Height + 'px';
					break;

				case c.length && c == 'sw-resize':
					_we.style.left = o.clientX - _wp.Offset.X + 'px';
					_we.style.width = _wp.Width - ((o.clientX - _wp.Offset.X) - _wp.X) + 'px';
					_we.style.height = o.clientY - _wp.Offset.Height + 'px';
					break;

				case _sl != undefined:
					_we.style.width = o.clientX - _wp.Offset.Width + 'px';
					break;

				case _cs != undefined && _wp && !_wp.Move:
					_we.style.width = o.clientX - _wp.Offset.Width + 'px';
					_we.style.height = o.clientY - _wp.Offset.Height + 'px';
					break;

				default:
					_we.style.left = o.clientX - _wp.Offset.X + 'px';
					_we.style.top = o.clientY - _wp.Offset.Y + 'px';
					break;
			}

			_se = document.createEvent('CustomEvent');
			_se.initCustomEvent('windowstatechanged', true, false, _self);
			_self.dispatchEvent(_se); 								// raise state event.
		}
	}

	function OnMouseUp(myEvent)
	{
	 var o;

		myEvent = myEvent || event;
		o = !myEvent.targetTouches ? myEvent : myEvent.targetTouches[0];
		if (o && (o.target || o.srcElement) == _ce) {
			return;
		}

		_wp = null;
		_we.style.cursor = 'default';

		WebModel.Drawing.InteractionEnabled = true;
		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnGestureChange(myEvent)
	{
	 var b;
	 var c;
	 var o;

		myEvent = myEvent || event;
		o = (myEvent.target || myEvent.srcElement);
		c = _we.style.cursor;

		b = window.PointerEvent || window.MSPointerEvent;
		if (b) {
			switch (true) {
				case c.length && c != 'default':
					break;

				case _sl != undefined:
					_we.style.width = parseFloat(_we.style.width || 0) + myEvent.translationX + 'px';
					break;

				case _cs != undefined && _wp && !_wp.Move:
					_we.style.width = parseFloat(_we.style.width || 0) + myEvent.translationX + 'px';
					_we.style.height = parseFloat(_we.style.height || 0) + myEvent.translationY + 'px';
					WebModel.Diagnostics.Console.log('Setting new size...');
					break;

				default:
					_we.style.left = parseFloat(_we.style.left || 0) + myEvent.translationX + 'px';
					_we.style.top = parseFloat(_we.style.top || 0) + myEvent.translationY + 'px';
					break;
			}
		}

		_se = document.createEvent('CustomEvent');
		_se.initCustomEvent('windowstatechanged', true, false, _self);
		_self.dispatchEvent(_se);		// raise state changed event!

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnTouchStart(myEvent)
	{
		OnMouseDown(myEvent);
	}

	function OnTouchMove(myEvent)
	{
		OnMouseMove(myEvent);
	}

	function OnTouchEnd(myEvent)
	{
		OnMouseUp(myEvent);
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.open = function open() {
		if (_ws == WindowClass.Styles.ModalDialog ||														// dialog window already positioned ?
			(!_we.style.left && _ws == WindowClass.Styles.ModelessDialog))
		{
			_we.style.left = '-999999px'; 																	// no! >> let's position our window
			_we.style.top = '-999999px'; 																	// out of view.
			_we.style.display = 'inherit'; 																	// display window and re-position
			_we.style.left = (document.body.clientWidth / 2) - (_we.clientWidth / 2) + 'px'; 				// it centered on screen.
			_we.style.top = (document.body.clientHeight / 2) - (_we.clientHeight / 2) + 'px';
		} else
			_we.style.display = 'inherit'; 																	// yes! >> display window.

		if (_ws == WindowClass.Styles.ModalDialog) {
			_we.style.zIndex = MAX_ZINDEX;
			_mo.style.zIndex = MAX_ZINDEX - 1; 															
			_mo.style.display = '';
		}

		if (_we.offsetLeft < 0)																				// let's ensure window is never
			_we.style.left = 0 + 'px';																		// displayed out of view.
		if (_we.offsetLeft + _we.offsetWidth > document.body.clientWidth)
			_we.style.left = document.body.clientWidth - _we.offsetWidth + 'px';
		if (_we.offsetTop < 0)
			_we.style.top = 0 + 'px';
		if (_we.offsetTop + _we.offsetHeight > document.body.clientHeight)
			_we.style.top = document.body.clientHeight - _we.offsetHeight + 'px';

		_we.focus();

		_se = document.createEvent('CustomEvent');
		_se.initCustomEvent('windowstatechanged', true, false, _self);
		_self.dispatchEvent(_se); 																			// finally raise state event.
	}

	this.close = function close() {
		_we.style.display = 'none';
		if (_ws == WindowClass.Styles.ModalDialog)
			_mo.style.display = 'none';

		_se = document.createEvent('CustomEvent');
		_se.initCustomEvent('windowstatechanged', true, false, _self);
		_self.dispatchEvent(_se); 																			// finally raise state event.
	}
}
WindowClass.Styles = { ModalDialog: 0, ModelessDialog: 1, Dock: 2 }; 										// static!
///
/// End :: Window Class
///

/// <summary>
/// This class provides all functionality
/// for displaying properties of viflow
/// objects.
/// </summary>
function PropertyWindowClass(myElement, myStyle)
{
	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _base;
	var _mode;
	var _ue;	// ui element
	var _ts;	// translations
	var _cn;	// current node
	var _ct;	// current tab
	var _pd;	// property data
	var _hs;	// highlight search?
	var _ld;	// last data

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "CurrentNode", { get: function () { return _cn; } });
	Object.defineProperty(this, "CurrentData", { get: function () { return _pd; } });

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_self = this;
	_self.base = WindowClass;
	_self.base(myElement, myStyle)
	
	_base = {
		open: _self.open
	}

	_ue = myElement;
	_ts = new TranslationsClass();
	_ld = { ID: null, UUID: null, TabID: null, Language: null };

	{
	 var as, a;	// addon(s)
	 var cf;	// content fragment
	 var tf;	// tab fragment
	 var ay;
	 var e;		// element
	 var t;		// replacement target
		
		cf = document.createDocumentFragment();

		as = WebModel.AddOns;
		for (var k in as) {
			a = as[k];
			if (!(a instanceof WebModel.AddOns.AddOnClass)) {					// ignore each iteration object not
				continue;														// being based on addon class.
			}

			t = document.getElementById(a.Replaces);

			tf = document.createDocumentFragment();

			e = tf.appendChild(document.createElement('li'));
			e.setAttribute('id', a.ID);
			e.setAttribute('flags', '0x7');
			e.setAttribute('onclick', 'WebModel.UI.PropertyWindow.loadTab(this.id); return false;');

			e = e.appendChild(document.createElement('a'));
			e.setAttribute('id', 'tab_' + a.ID);
			e.setAttribute('href', '#propertiesWindow');
			e.setAttribute('title', t ? t.getAttribute('title') : a.Name);

			e.appendChild(document.createTextNode(t ? t.firstChild.data : a.Name));

			if (t) {															// skip each addon replacing existing
				t.parentNode.parentNode.replaceChild(tf, t.parentNode);
			} else {
				cf.appendChild(tf);
			}
		}

		e = document.getElementById('propertiesWindowTabs');
		if (!e) {
			throw 'Could not locate property window tabs container!';
		}
		
		e.appendChild(cf);
	}

	//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function OnPropertiesLoaded(myData)
	{
     var ay;	// array
	 var ce;	// content element
	 var o;		// multiple usage
	 var a;		// addon
	 var n;		// node

		WebModel.Diagnostics.Console.log('Loading data for ' + (_cn.UUID ?_cn.UUID : _cn.ID) + ' to property window.');

		_pd = myData;																	// let's cache current data!

		ay = document.getElementById('propertiesWindowTabs');
		if (ay) {
			ay = ay.getElementsByTagName('li');
		}
		if (!ay) {
			throw 'Could not find property window tab list!';
		}

		for (var i = 0; i < ay.length; i++) {
			o = ay[i];
			if (!(/^\{.*?\}$/gi).test(o.id)) {
				if (WebModel.Common.Helper.selectNodes(_pd, '/data/' + o.id + '//td').length > 0) {
					o.removeAttribute('disabled');
				} else if (o.id == _ct) {
					_ct = 'general';
					o.removeAttribute('class');
					document.getElementById(_ct).setAttribute('class', 'propertiesActive');
				}
			}
		}

		ce = document.getElementById('propertiesWindowContent');
		if (!ce) {
			throw 'Could not find property window content element!';
		}

		o = /^\{.*?\}$/gi;
		if (o.test(_ct)) {
			ce.setAttribute('style', 'overflow: hidden;')
			a = WebModel.AddOns[_ct];
			n = WebModel.Common.Helper.getXmlFromString('<container><iframe src="' + a.Command + '" onload="WebModel.AddOns.addHost(this);"/></container>', true).firstChild;
			WebModel.Common.Helper.appendXmlToElement(n, ce, true);
		} else {
			if (ce.getAttribute('style')) {
				ce.removeAttribute('style');
			}
			n = myData.getElementsByTagName(_ct);
			if (n && n.length) {
				n = n.item(0);
				WebModel.Common.Helper.appendXmlToElement(n, ce, true);
			}
		}

		_ts.apply(_ue);

		if (_hs) {
			WebModel.Search.highlightTerms(ce);
			_hs = false;
		}

		o = document.getElementById('propertiesWindowProgress');
		if (!o) {
			throw 'Could not find property window progress element!';
		}
		o.setAttribute('style', 'display: none;');

		WebModel.Diagnostics.Console.log('Finished loading data for ' + (_cn.UUID ?_cn.UUID : _cn.ID) + ' to property window.');
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.open = function (myNode, highlightSearch)
	{
	 var tv;	// tree views
	 var ht;	// hidden tabs
	 var ay;	// array
	 var b;		// multiple usage!
	 var o;		// multiple usage!
	 var e;		// expression

		if (!myNode && _cn == null) {
			throw 'myNode must not be null!';
		}

		if (myNode) {
			if (_cn != myNode) {															// node changed?
				_pd = undefined;															// yeah! >> force refreshing
			}																				// property window data!

			_cn = myNode;
		}

		_hs = !!highlightSearch;
		_ts.apply(_ue);

		tv = WebModel.UI.TreeViews;
		switch (_cn.TreeView) {
			case tv['globalProcessTree']:
			case tv['myProcessTree']:
				_mode = PropertyWindowClass.Modes.Process;
				break;

			case tv['globalInformationTree']:
			case tv['myInformationTree']:
				_mode = PropertyWindowClass.Modes.Information;
				break;

			case tv['globalAreaTree']:
			case tv['myAreaTree']:
				_mode = PropertyWindowClass.Modes.Area;
				break;
		}

		ht = WebModel.Settings.HiddenTabs;
		ay = document.getElementById('propertiesWindowTabs');
		if (ay) {
			ay = ay.getElementsByTagName('li');
		}
		if (!ay) {
			throw 'Could not find property window tab list!';
		}

		b = document.getElementById(_ct || 'general');
		if (highlightSearch || !b || b.hasAttribute('style')) {
			_ct = 'general';
		}

		e = /^\{.*?\}$/gi;
		for (var i = 0; i < ay.length; i++) {
			o = ay[i];
			if (!e.test(o.id) && 
				!(
					((_cn.UUID ? _cn.UUID : _cn.ID) == (_ld.UUID ? _ld.UUID : _ld.ID) &&
					(_ct == _ld.TabID) &&
					(WebModel.Settings.LanguageContent == _ld.Language))
				)
			) {
				o.setAttribute('disabled', 'true');
			}

			b = o.hasAttribute('flags') &&
				(eval(o.getAttribute('flags')) & _mode) == _mode;
			b &= !o.hasAttribute('tabmask') ||
				 (ht & eval(o.getAttribute('tabmask'))) != eval(o.getAttribute('tabmask'));
			if (b) {
				if (o.hasAttribute('style')) {
					o.removeAttribute('style');
				}
			} else {
				o.setAttribute('style', 'display: none');
			}
		}

		_self.loadTab(_ct || 'general');

		_base.open();
	};

	this.loadTab = function (myTabID)
	{
	 var ay;
	 var nd;
	 var o;		// multiple usage!

		if (!myTabID) {
			throw 'myTabID must not be null!';
		}

		_ct = myTabID;

		if ((_cn.UUID ?_cn.UUID : _cn.ID) == (_ld.UUID ?_ld.UUID : _ld.ID) &&			// ensures each tab is loaded
			(myTabID == _ld.TabID) &&													// once (prevents duplicate
			(WebModel.Settings.LanguageContent == _ld.Language))						// displaying the same content).
		{
			return;																		
		} else {
			_ld = {
				ID:			_cn.ID,
				UUID:		_cn.UUID,
				TabID:		myTabID,
				Language:	WebModel.Settings.LanguageContent
			};
		}

		o = document.getElementById('propertiesWindowProgress');
		if (!o) {
			throw 'Could not find property window progress element!';
		}
		if (o.hasAttribute('style')) {
			o.removeAttribute('style');
		}

		o = document.getElementById('propertiesWindowTitle');
		if (!o) {
			throw 'Could not find property window title element!';
		}
		for (var i = 0; i < o.childNodes.length; i++) { 
			nd = o.childNodes[i];
			if (nd.nodeType == 3) {
				nd.data = _cn.Name;
				break;
			}
		}

		o = document.getElementById('propertiesWindowIcon');
		if (o) {
			o.setAttribute('src', _cn.Image.getAttribute('src'));
		}

		ay = document.getElementById('propertiesWindowTabs');
		if (ay) {
			ay = ay.getElementsByTagName('li');
		}
		if (!ay) {
			throw 'Could not find property window tab list!';
		}

		for (var i = 0; i < ay.length; i++) {
			o = ay[i];
			if (o.hasAttribute('class')) {
				o.removeAttribute('class');
			}
			if (o.hasAttribute('id') &&
				o.getAttribute('id') == _ct)
			{
				o.setAttribute('class', 'propertiesActive');
			} 
		}

		o = document.getElementById('propertiesWindowContent');
		if (!o) {
			throw 'Could not find property window content element!';
		}
		while (o.childNodes.length > 0) {
			o.removeChild(o.firstChild);
		}

		if (_pd) {																			// cached property data available?
			OnPropertiesLoaded(_pd);														// yeah! let's display them and 
			return;																			// leave here.
		}

		o = './xslt/intermediate_properties_';
		switch (_mode) {
			case PropertyWindowClass.Modes.Process:
				o += 'process';
				break;

			case PropertyWindowClass.Modes.Information:
				o += 'information';
				break;

			case PropertyWindowClass.Modes.Area:
				o += 'area';
				break;

			default:
				o = false;
				break;
		}

		if (o) {
			o += '.xslt';
			WebModel.Diagnostics.Console.log('Starting to load data for ' + (_cn.UUID ?_cn.UUID : _cn.ID) + '.');
			WebModel.Common.Helper.performAsyncTransform('./data/empty.xml',
														 o,
														 OnPropertiesLoaded,
														 {
															filter: (_cn.UUID ?_cn.UUID : _cn.ID),
															language: WebModel.Settings.LanguageContent, 
															displaytext: WebModel.Settings.DisplayText,
															linkfallback: +WebModel.Settings.LinkFallback,
															searchterms: _hs ? WebModel.Search.Terms : '',
															exclusionlist: WebModel.ExclusionData
														 });
		}
	};

	this.refresh = function ()
	{
	 var nd;

		if (!_self.Visible || !_cn) {
			return;
		}

		nd = _cn.TreeView.findNode(_cn.UUID ? _cn.UUID : _cn.ID, true);
		if (nd && nd.length) {
			nd = nd[0];
		}

		if (nd) {
			_ld = { ID: null, UUID: null, TabID: null };									// ensures view reset on language changes.
			_self.open(nd);
		}
	}
}
PropertyWindowClass.prototype = WindowClass.prototype;		// let's inherit from WindowClass!
PropertyWindowClass.Modes = { Process: 0x1 << 0x0, Information: 0x1 << 0x1, Area: 0x1 << 0x2 };
///
/// End :: Property Window Class
///

/// <summary>
/// This class provides all functionality
/// for displaying search results for viflow
/// objects.
/// </summary>
function ResultWindowClass(myElement, myStyle)
{
	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _base;
	var _ue;	// ui element
	var _re;	// result element
	var _pe;	// progress element
	var _se;	// search field element
	var _ts;	// translations
	var _rd;	// result data

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "Data", {
		get: function () {
			return _rd;
		},
		set: function (myValue)
		{
		 var sz;
		 var b;		// bool
		 var n;		// node
		 var c;		// count
		 var s;		// seconds
		 var t;		// term(s)

			WebModel.Diagnostics.Console.log('Loading data to search result window.');

			_self.open();
			_rd = myValue;

			c = myValue && myValue.Result ? -1 + myValue.Result.getElementsByTagName('tr').length : 0;
			s = myValue && myValue.Seconds ? myValue.Seconds : 0;
			t = _se.value != _ts.getTranslation('webmodel.ui.value.' + _se.id.toLowerCase(), _se.value) ?
				_se.value : _ts.getTranslation('webmodel.ui.noterm', 'empty query');
			t = t.replace(/&/g, '&amp;');
			t = t.replace(/</g, '&lt;');
			t = t.replace(/>/g, '&gt;');
			t = t.replace(/"/g, '&quot;');
			t = t.replace(/'/g, '&#039;');

			sz = _ts.getTranslation('webmodel.ui.resultinfo', '<span>{0} results matching <i>{1}</i> ({2}s)</span>');
			sz = sz.replace(/\{0\}/gi, c);
			sz = sz.replace(/\{1\}/gi, t);
			sz = sz.replace(/\{2\}/gi, s);
			n = WebModel.Common.Helper.getXmlFromString(sz, true);
			n = WebModel.Common.Helper.importNodeFromXML(n.firstChild, true);
			_re.appendChild(n);

			if (myValue && myValue.Result && c) {
				n = myValue.Result.getElementsByTagName('table');
				if (n && n.length) {
					n = n.item(0);
					WebModel.Common.Helper.appendXmlToElement(n, _re);
				}
			}

			_ts.apply(_ue);
			_pe.setAttribute('style', 'display: none;');

			_ll = WebModel.Settings.LanguageContent;

			WebModel.Diagnostics.Console.log('Finished loading data to search result window.');
		}
	});

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	{
		_self = this;
		_self.base = WindowClass;
		_self.base(myElement, myStyle)

		_base = {
			open: _self.open
		}

		_ue = myElement;
		_ts = new TranslationsClass();

		_re = document.getElementById('resultData');
		if (!_re) {
			throw 'Could not locate result data element!';
		}

		_pe = document.getElementById('resultBoxProgress');
		if (!_pe) {
			throw 'Could not locate result progress element!';
		}

		_se = document.getElementById('searchField');
		if (!_se) {
			throw 'Could not locate search field element!';
		}
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.reset = function ()
	{
	 var f;
	 var e;

		_self.ResultFragment = undefined;

		if (_pe.hasAttribute('style')) {
			_pe.removeAttribute('style');
		}

		while (_re.firstChild) {
			_re.removeChild(_re.firstChild);
		}
	}

	this.filter = function (myFilter)
	{
	 var FILTER = { p: 1, i: 2, a: 3 };

	 var ra;	// row array
	 var fe;	// filter element
	 var sz;
	 var f;
	 var n;

		if (!_self.ResultFragment) {							// let's clone result if
			_self.ResultFragment = _re.cloneNode(true);			// not already done.
		}

		f = document.createDocumentFragment();					// clone result to fragment
		f.appendChild(_self.ResultFragment.cloneNode(true));	// and get fragments first
		f = f.firstChild;										// child.

		n = -1;

		ra = f.getElementsByTagName('tr');						// remove each filtered line
		for (var i = 0; i < ra.length; i++) {					// from fragment.
			fe = ra[i];
			if (fe.hasAttribute('filter') &&
				myFilter &&
				FILTER[fe.getAttribute('filter')] != myFilter)
			{
				fe.parentNode.removeChild(fe);
				i--;
			} else {
				n++;
			}
		}

		sz = _ts.getTranslation('webmodel.ui.resultinfo', '<span>{0} results matching <i>{1}</i> ({2}s)</span>');
		sz = sz.replace(/\{0\}/gi, (n < 0 ? 0 : n));
		sz = sz.replace(/\{1\}/gi,
						_se.value != _ts.getTranslation('webmodel.ui.value.' + _se.id.toLowerCase(), _se.value) ?
						_se.value : _ts.getTranslation('webmodel.ui.noterm', 'empty query'));
		sz = sz.replace(/\{2\}/gi,
						(
							(_rd && _rd.Seconds ? _rd.Seconds : 0) /
							(_rd && _rd.Result ? (_rd.Result.getElementsByTagName('tr').length - 1) : 1) *
							n
						).toFixed(2));
		n = WebModel.Common.Helper.getXmlFromString(sz, true);
		n = WebModel.Common.Helper.importNodeFromXML(n.firstChild, true);
		f.replaceChild(n, f.firstChild);

		_re.parentNode.replaceChild(f, _re);					// replace result with
		_re = f;												// filtered fragment.
	}
}
ResultWindowClass.prototype = WindowClass.prototype;	// let's inherit from WindowClass!
///
/// End :: Result Window Class
///

/// <summary>
/// This class provides all functionality
/// for displaying information about
/// what's changed since last publication.
/// </summary>
function ChangesWindowClass(myElement, myStyle)
{
	//// ~~~~ constants ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var LINK_TYPE = 0x0;
	var LINK_ID = 0x1;

	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _base;
	var _ue;	// ui element
	var _me;	// mark as read element
	var _mc;	// mark as read container
	var _re;	// result element
	var _pe;	// progress element
	var _rs;	// rss element
	var _ts;	// translations
	var _tp;	// table page
	var _tr;	// transform running?
	var _ll;	// last content language
	var _lf;	// last filter

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "MarkAsRead", { get: function () { return _me.checked; }});

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	{
	 var xslt;
	 var xml;

		_self = this;
		_self.base = WindowClass;
		_self.base(myElement, myStyle)

		_base = {
			open: _self.open,
			close: _self.close
		}

		_ue = myElement;
		_ts = new TranslationsClass();

		_re = document.getElementById('whatsChangedBoxData');
		if (!_re) {
			throw 'Could not locate changes data element!';
		}
		_re.addEventListener('scroll', OnScroll, false);

		_pe = document.getElementById('whatsChangedBoxProgress');
		if (!_pe) {
			throw 'Could not locate changes progress element!';
		}

		_rs = document.getElementById('rssButton');
		if (!_rs) {
			throw 'Could not locate rss button element!';
		}
		_rs.addEventListener('click', OnClickRSS, false);

		_mc = document.getElementById('whatsChangedBoxMarker');
		if (!_mc) {
			throw 'Could not locate mark-as-read container!';
		}

		_me = document.getElementById('whatsChangedBoxRead');
		if (!_me) {
			throw 'Could not locate mark-as-read element!';
		}

		if (WebModel.Settings.LastVisit > 0 && WebModel.Settings.ShowChangesSinceVisit) {
			_lf = WebModel.Settings.LastVisit;
			xslt = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './xslt/intermediate_history.xslt', false);
			xml = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/empty.xml', false);
			xml = WebModel.Common.Helper.transformXML(
				xml,
				xslt,
				{
					language: WebModel.Settings.LanguageContent, 
					displaytext: WebModel.Settings.DisplayText,
					linkfallback: +WebModel.Settings.LinkFallback,		// convert bool => int!
					renferencedareasonly: +WebModel.Settings.ReferencedAreasOnly,
					renferencedinfosonly: +WebModel.Settings.ReferencedInfosOnly,
					filter: _lf,
					exclusionlist: WebModel.ExclusionData
				}
			);
			OnChangesAvailable(xml);
		}
	}

	//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function OnClickRSS(myEvent)
	{
		window.open(_rs.getAttribute('rss'));
	}
	
	function OnChangesAvailable (myValue)
	{
	 var sz;
	 var n;		// node
	 var b;		// boolean
	 var s;		// seconds

		WebModel.Diagnostics.Console.log('Loading data to changes window.');

		if (myValue &&
			myValue.getElementsByTagName('td').length > 0)
		{
			if (!_self.Visible) {
				_self.open();
			}

			b = (_re.childNodes.length > 0);
			n = myValue.getElementsByTagName('table');
			if (n && n.length) {
				n = n.item(0);
				_tp = !b ? 1 : (_tp + 1);

				WebModel.Common.Helper.appendXmlToElement(n, (b ? _re.firstChild : _re), b, b);
			}

			_ts.apply(_ue);
		}

		WebModel.Diagnostics.Console.log('Finished loading data to changes window.');

		_ll = WebModel.Settings.LanguageContent;
		_pe.setAttribute('style', 'display: none;');
		_tr = false;
	}

	function OnScroll (myEvent)
	{
	 var xslt;
	 var xml;
	 var m;		// max entries
	 var l;		// per load entries

		myEvent = myEvent || event;
		if (myEvent.target.scrollTop + myEvent.target.offsetHeight < myEvent.target.scrollHeight) {
			return;
		}

		if (_tr) {
			return;
		}

		_tr = true;
		_pe.removeAttribute('style');

		WebModel.Common.Helper.performAsyncTransform(
			'./data/empty.xml',
			'./xslt/intermediate_history.xslt',
			OnChangesAvailable,
			{
				language: WebModel.Settings.LanguageContent, 
				displaytext: WebModel.Settings.DisplayText,
				linkfallback: +WebModel.Settings.LinkFallback,
				renferencedareasonly: +WebModel.Settings.ReferencedAreasOnly,
				renferencedinfosonly: +WebModel.Settings.ReferencedInfosOnly,
				filter: _lf,
				page: _tp,
				exclusionlist: WebModel.ExclusionData
			}
		);
	}

	this.OnChangeClick = function (myEvent)
	{
	 var xslt;
	 var xml;
	 var xn;	// xml node
	 var nl;	// node list
	 var ay;	// array
	 var id;
	 var tp;	// type
	 var sz;
	 var n;

	 var l = { URL: null, Caption: null, Image: null, AltImage: null };

		myEvent = myEvent || event;
		WebModel.Common.Helper.cancelEvent(myEvent);

		o = !myEvent.changedTouches ? myEvent : myEvent.changedTouches[0] || myEvent;

		sz = o.currentTarget.href;
		n = sz.lastIndexOf('/');
		if (n >= 0) {
			sz = sz.substr(++n, sz.length - n);
		}
		ay = sz.split('-');
		if (ay.length != 2) {
			throw 'Bad result link format!';
		} else {
			id = ay[LINK_ID];
			tp = ay[LINK_TYPE];
		}

		ay = new Array();
		xslt = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './xslt/intermediate_list_hyperlinks.xslt', false);
		xml = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/empty.xml', false);
		xml = WebModel.Common.Helper.transformXML(xml, xslt, { filter: id, language: WebModel.Settings.LanguageContent, explicit: tp, exclusionlist: WebModel.ExclusionData });
		nl = WebModel.Common.Helper.selectNodes(xml, '/list/item');
		for (var i = 0; i < nl.length; i++) {
			xn = nl[i];
			l.URL = WebModel.Common.Helper.selectSingleNode(xn, 'uri/text()').nodeValue;
			l.Image = WebModel.Common.Helper.selectSingleNode(xn, 'image/text()').nodeValue;
			l.AltImage = WebModel.Common.Helper.selectSingleNode(xn, 'altimage/text()');
			if (l.AltImage) {
				l.AltImage = l.AltImage.nodeValue;
			}
			if (!isNaN(parseFloat(l.URL) ||
				l.URL.match(/^\{[0-9a-fA-F]{8,8}\-[0-9a-fA-F]{4,4}\-[0-9a-fA-F]{4,4}\-[0-9a-fA-F]{4,4}\-[0-9a-fA-F]{12,12}\}$/) != null))
			{
				sz = WebModel.Settings.DisplayText == SettingsClass.DisplayText.Name ?								
					 'name' : 'shapetext';
				l.Caption = WebModel.Common.Helper.selectSingleNode(xn, sz + '/text()').nodeValue;
			} else {
				n = l.URL.lastIndexOf('/');
				if (n < 0) {
					n = l.URL.lastIndexOf('\\');
				}
				if (n < 0) {
					n = 0;
				}
				l.Caption = l.URL.substr(n, l.URL.length - n);
			}
			ay.push(new WebModel.Common.LinkClass(l.URL, l.Caption, l.Image, l.AltImage));			
		}

		p = {
			X: o.pageX,
			Y: o.pageY
		};

		WebModel.UI.performObjectNavigation(p, ay, undefined);
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.open = function (displayCompleteList)
	{
	 var xslt;
	 var xml;
	 var rfa;	// rss available?
	 var sz;

		if (!_base.Visible) {
			_base.open();
		}

		if (!displayCompleteList) {									// prevents custom filtering
			return;													// on displaying latest changes
		}															// after startup.

		sz = './rss/';
		sz += WebModel.Settings.LanguageContent.toLowerCase();		// let's check if rss url is
		sz += '.xml';												// available and display rss
																	// button in dependency.
		try {
			rfa = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, sz, false);
			if (!(rfa.status != undefined && rfa.status != 200 && rfa.status != 0)) {
				rfa = true;
			} else {
				rfa = false;
			}
		}
		catch (e) {
			rfa = false;
		}
		rfa &= document.location.protocol.indexOf('file:') < 0;

		_rs.setAttribute('rss', sz);
		_rs.setAttribute('style', 'display: ' + (rfa ? 'inherit' : 'none') + ';');

		while (_re.childNodes.length > 0) {							// let's clean result data.
			_re.removeChild(_re.firstChild);
		}

		_lf = 0;
		_tr = true;
		_pe.removeAttribute('style');
		_mc.setAttribute('style', 'display: none;');
		_re.setAttribute('style', 'bottom: 12px;');

		WebModel.Common.Helper.performAsyncTransform(
			'./data/empty.xml',
			'./xslt/intermediate_history.xslt',
			OnChangesAvailable,
			{
				language: WebModel.Settings.LanguageContent, 
				displaytext: WebModel.Settings.DisplayText,
				linkfallback: +WebModel.Settings.LinkFallback,
				renferencedareasonly: +WebModel.Settings.ReferencedAreasOnly,
				renferencedinfosonly: +WebModel.Settings.ReferencedInfosOnly,
				filter: _lf,
				page: 0,
				exclusionlist: WebModel.ExclusionData
			}
		);
	};

	this.refresh = function()
	{
		if (_self.Visible &&
			_ll != WebModel.Settings.LanguageContent)
		{
			_self.open(true);
		}
	}

	this.close = function ()
	{
		_tn = 0;
		_base.close();
	};
}
ChangesWindowClass.prototype = WindowClass.prototype;	// let's inherit from WindowClass!
///
/// End :: Changes Window Class
///

/// <summary>
/// This class provides all functionality
/// for creating and interacting with
/// button objects.
/// </summary>
function ButtonClass(myElement, myStyle, dependentButtons, myDropDownElement)
{
	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _bs; 		// button style
	var _db; 		// dependent buttons
	var _me; 		// markup element
	var _de; 		// dropdown element
	var _be;		// button click event
	var _hi;		// has image?

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "IsPressed", { get: function () { return _me.className == 'menuActive'; } });
	Object.defineProperty(this, "Width", { get: function () { return _me.offsetWidth; } });
	Object.defineProperty(this, "Visible", {
		get: function () { return _me.style.display != 'none'; },
		set: function (myValue) {
			if (myValue != (_me.style.display != 'none')) {
				_me.style.display = myValue ? undefined : 'none';
			}
		}
	});
	Object.defineProperty(this, "Collapsed", {
		get: function () { return _hi && _me.getElementsByTagName('span').length > 0; },
		set: function (myValue)
		{
		 var s;	// span
		 var t; // text

			if (!_hi) {
				return;
			}

			for (var i = 0; i < _me.childNodes.length; i++) {
				s = _me.childNodes[i];
				if (s.nodeName.toLowerCase() == 'span') {
					t = s.firstChild.cloneNode(true);

					_me.appendChild(t);
					_me.removeChild(s);
					break;
				}
			}

			if (myValue) {
				for (var i = 0; i < _me.childNodes.length; i++) {
					t = _me.childNodes[i];
					if (t.nodeType == document.TEXT_NODE) {
						s = document.createElement('span');
						s.setAttribute('style', 'display: none;');
						s.appendChild(t.cloneNode(true));

						_me.appendChild(s);
						_me.removeChild(t);
						break;
					}
				}
			}
		}
	});

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_self = this;
	_self.extendAsEventDispatcher();																		// let's extend as dispatcher.

	_bs = !myStyle ? ButtonClass.Styles.Default : myStyle;
	_db = !dependentButtons || !(dependentButtons instanceof Array) ? new Array() : dependentButtons;

	if (!myDropDownElement && _bs == ButtonClass.Styles.MenuDropDown) {
		throw 'myDropDownElement must not be null while relating style is used!';
	}

	_de = myDropDownElement;

	if (!myElement) {
		throw 'myElement must not be null!';
	}

	_me = myElement;
	_me.addEventListener('click', OnClick, false);

	_hi = _me.getElementsByTagName('img').length > 0;

	//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function OnClick(myEvent)
	{
		if (!myEvent)
			myEvent = event;

		if (_bs != ButtonClass.Styles.Default)
			_self.toggle(myEvent);

		_be = document.createEvent('CustomEvent');
		_be.initCustomEvent('buttonclicked', true, false, _self);
		_self.dispatchEvent(_be); 																			// raise button click event.

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnBlur(myEvent) {
		OnClick(myEvent);
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.toggle = function (myEvent) {
		var i; 	// multiple usage
		var e; 	// element

		if (myEvent)																						// toggled by element?
			for (i = 0; i < _db.length; i++)																// yeah! >> toggle all
				WebModel.UI.Buttons[_db[i]].toggle(false); 													// dependent elements!

		_me.className = ((_me.className != 'menuActive') && myEvent != false) ? 'menuActive' : ''; 			// toggle active class.

		switch (_bs) {																						// style-dependent actions for
			case ButtonClass.Styles.MenuDefault: 															// default button:
				if (_me.className == 'menuActive')															// button active?
					setTimeout(_self.toggle, 100); 															// yeah! >> toggle again.
				_me.blur(); 																				// ensure correct style.
				break;

			case ButtonClass.Styles.MenuPress:
				_me.blur(); 																				// ensure correct style.
				break;

			case ButtonClass.Styles.MenuDropDown: 															// dropdown button:
				if (_me.className == 'menuActive') {														// we display dropdowm
					_de.style.display = 'block';															// directly but hide it
				} else {																					// delayed for being able
					window.setTimeout(function () { _de.style.display = 'none'; }, 1000);					// to recognize clicked
				}																							// links. in addition we
				if (_me.className == 'menuActive') {														// de-/attach blur event
					_me.addEventListener('blur', OnBlur, false); 											// for being able to toggle
				} else {																					// if we loose focus.
					_me.blur(); 																			// enforcing blur is
					_me.removeEventListener('blur', OnBlur, false);											// recuried here!
				}

				_de.style.left = _me.offsetLeft + 'px'; 													// let's position drop-
				_de.style.paddingLeft = '0px'; 																// down correctly.
		}
	};
}
ButtonClass.Styles = { Default: 0, MenuDefault: 1, MenuPress: 2, MenuDropDown: 3 };							// static!
///
/// End :: Button Class
///

/// <summary>
/// This class provides all functionality
/// for creating and interacting with
/// dropdown objects.
/// </summary>
function DropDownClass(myDropDownElement)
{
	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _dd; 		// dropdown
	var _de;		// default element
	var _ce;		// click event
	var _bo;		// bluring objects

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "Element", { get: function () { return _dd; } });

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_self = this;
	_self.extendAsEventDispatcher();																		// let's extend as dispatcher.

	if (!myDropDownElement) {
		throw 'myDropDownElement must not be null!';
	}
	_dd = myDropDownElement;
	_dd.addEventListener('blur', OnBlur, false);

	//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function OnClick(myEvent)
	{
		myEvent = myEvent || event;

		OnBlur(myEvent);																					// force context menu to close.

		_ce = document.createEvent('CustomEvent');
		_ce.initCustomEvent('click', true, false, myEvent.detail);
		_self.dispatchEvent(_ce); 																			// re-raise element click event.

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnBlur(myEvent)
	{
		if (_bo) {
			for (var i = 0; i < _bo.length; i++) {															// deteach formally attached
				_bo[i].Element.removeEventListener(_bo[i].Event, OnBlur, false);							// event handlers as they aren't
			}																								// needed anymore!
		}
		_self.hide();
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.clear = function ()
	{
		while (_dd.childNodes.length > 0) {
			_dd.removeChild(_dd.childNodes[0]);
		}
	}
	
	this.add = function (myLink, isDefault, highlightSearch)
	{
	 var de;
		
		de = new DropDownElementClass(myLink, isDefault, highlightSearch);
		de.addEventListener('click', OnClick, false);

		if (isDefault) {
			_de = de.Element;
		}
	}

	this.show = function (myX, myY)
	{
	 var h;		// helper
	 var p;		// padding

		if (parseFloat(myX) == NaN || parseFloat(myY) == NaN) {
			return;
		}

		h = WebModel.Common.Helper;
		p = {
			Left: parseFloat(h.getStyle(_dd, 'paddingLeft')),
			Right: parseFloat(h.getStyle(_dd, 'paddingRight')),
			Top: parseFloat(h.getStyle(_dd, 'paddingTop')),
			Bottom: parseFloat(h.getStyle(_dd, 'paddingBottom'))
		};

		_dd.style.display = 'block';
		_dd.style.left = (myX - p.Left) + 'px';
		_dd.style.top = (myY - p.Top) + 'px';
		if (_dd.offsetLeft + _dd.offsetWidth > document.body.clientWidth) {
			_dd.style.left = (document.body.clientWidth - _dd.offsetWidth) + 'px';
		}
		if (_dd.offsetTop + _dd.offsetHeight > document.body.clientHeight) {
			_dd.style.top = (document.body.clientHeight - _dd.offsetHeight) + 'px';
		}

		_bo = new Array(																					// build array of elements for
			{ Element: WebModel.UI.DrawingArea.Element.parentElement, Event: 'touchend'	},					// recognizing gestures besides
			{ Element: WebModel.UI.DrawingArea.Element.parentElement, Event: 'click'	},					// the context menu for being
			{ Element: WebModel.Drawing.SVGWindow, Event: 'touchend' },										// able to hide it.
			{ Element: WebModel.Drawing.SVGWindow, Event: 'click' },										
			{ Element: document, Event: 'click' }
		);

		for (var i = 0; i < _bo.length; i++) {																// let's bind to click events
			_bo[i].Element.addEventListener(_bo[i].Event, OnBlur, false);									// of all elements in recognition
		}																									// array.
		
		if (_de) {																							// scroll default element into
			_de.scrollIntoView();																			// view if available.
		}
	}

	this.hide = function ()
	{
		_dd.style.display = 'none';
	}

	//// ~~~~ inner classes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	/// <summary>
	/// This class provides all functionality
	/// for creating and interacting with
	/// dropdown element objects.
	/// </summary>
	function DropDownElementClass(myLink, isDefault, highlightSearch)
	{
		//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		var _self;
		var _de;		// dropdown element
		var _ce;		// click event
		var _l;			// link
		var _s;			// from search

		//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		Object.defineProperty(this, "Element", { get: function () { return _de; } });
		Object.defineProperty(this, "Link", { get: function () { return _l; } });
		Object.defineProperty(this, "HighlightSearch", { get: function () { return _s; } });

		//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		var e;		// element

		_self = this;
		_self.extendAsEventDispatcher();																	// let's extend as dispatcher.

		if (!myLink) {
			throw 'myLink must not be null!';
		}

		if (!(myLink instanceof WebModel.Common.LinkClass)) {
			throw 'myLink must be typeof LinkClass!';
		}

		_s = !!highlightSearch;
		_l = myLink;
		_de = _dd.appendChild(document.createElement('li'));
		e = _de.appendChild(document.createElement('a'));
		e.setAttribute('href', _l.URL);
		if (isDefault) {
			e.setAttribute('style', 'font-weight: bold;');
		}
		e.addEventListener('click', OnClick, false);

		e = e.appendChild(document.createElement('img'));
		e.setAttribute('src', _l.Image);
		e.addEventListener('error', OnImageLoadError, false);
		e.parentNode.appendChild(document.createTextNode(_l.Caption));

		//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		function OnClick(myEvent)
		{
			_ce = document.createEvent('CustomEvent');
			_ce.initCustomEvent('click', true, false, { Link: _l, Element: _de, HighlightSearch: _s });
			_self.dispatchEvent(_ce); 																		// raise tab click event.

			WebModel.Common.Helper.cancelEvent(myEvent);
		}

		function OnImageLoadError(myEvent)
		{
		 var xn;
		 var sz;
		 var ig;
		 var i;

			sz = this.src;
			i = sz.lastIndexOf('/');
			sz = sz.substr(i, (sz.length - i));
			switch (true) {
				case (_l.Image != undefined && _l.Image.length > 0 && _l.Image.indexOf(sz) >= 0 && _l.AltImage != undefined && _l.AltImage.length > 0):
					this.setAttribute('src', _l.AltImage);
					break;
				
				case (_l.Image != undefined && _l.Image.length > 0 && !this.hasAttribute('base64_source')):
				case (_l.AltImage != undefined && _l.AltImage.length > 0 && this.hasAttribute('base64_source') && this.getAttribute('base64_source') == _l.Image):
					ig = !this.hasAttribute('base64_source') ? _l.Image : _l.AltImage;
					this.setAttribute('base64_source', ig);
					i = ig.lastIndexOf('/');
					if (i >= 0) {
						ig = ig.substr(++i, (ig.length - i));
					}

					i = ig.lastIndexOf('.');
					if (i >= 0) {
						sz = ig.substr(0, i).toLowerCase();
						xn = WebModel.Common.Helper.selectSingleNode(WebModel.UI.FileTypeIcons, '/icons/icon[@type="' + sz + '"]/text()');
						this.setAttribute('src', xn ? xn.nodeValue : 'base64');
						break;
					}

				default:
					this.setAttribute('style', 'display: none;');
					break;
			}

			if (_dd.offsetLeft + _dd.offsetWidth > document.body.clientWidth) {
				_dd.style.left = (document.body.clientWidth - _dd.offsetWidth) + 'px';
			}
			if (_dd.offsetTop + _dd.offsetHeight > document.body.clientHeight) {
				_dd.style.top = (document.body.clientHeight - _dd.offsetHeight) + 'px';
			}

			WebModel.Common.Helper.cancelEvent(myEvent);
		}
	}
	///
	/// End :: DropDownElement Class
	///
}
///
/// End :: DropDown Class
///

/// <summary>
/// This class provides all functionality
/// for creating and interacting with
/// tabstrip objects.
/// </summary>
function TabStripClass(myElement, myTabElements)
{
	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _ve;		// visibility event
	var _se;		// tab selection event
	var _me;		// markup element
	var _tb;		// tabs
	var _ta;		// active tab

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "ActiveTab", { get: function () { return _ta; } });
	Object.defineProperty(this, "Tabs", { get: function () { return _tb; } });
	Object.defineProperty(this, "Visible", {
		get: function () { return WebModel.Common.Helper.getStyle(_me, 'display') != 'none'; },
		set: function (myValue)
		{
			_me.style.display = myValue ? 'inherit' : 'none';

			_ve = document.createEvent('CustomEvent');
			_ve.initCustomEvent('visibilitychanged', true, false, _self);
			_self.dispatchEvent(_ve);
		}
	});
	Object.defineProperty(this, "TabClass", { get: function () { return TabClass; } });

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_self = this;
	_self.extendAsEventDispatcher();																	// let's extend as dispatcher.

	if (!myElement)
		throw 'myElement must not be null!';

	_me = myElement;

	_tb = new WebModel.Common.CollectionClass();
	try {
		for (var k in myTabElements) {
			if (k == 'extendAsEventDispatcher')
				continue;
			var v = myTabElements[k];
			if (!v)
				throw '';

			_ta = new TabClass(document.getElementById(k), document.getElementById(v));
			_ta.addEventListener('tabclick', OnTabClick, false);
			_self.Tabs.add(_ta, k);
		}

		for (k in _self.Tabs) {																			// let's set first tab to be
			_ta = _self.Tabs[k];																		// active and skip each function
			if (!(_ta instanceof TabClass))																// on iteration (triple-= is needed
				continue;																				// here!).
			_ta.Selected = true;																
			break;
		}
	}
	catch(e) {
		throw 'myTabElements must be type of associative array and contain at least 1 tab and content element!';
	}

	//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function OnTabClick(myEvent)
	{
	 var t;

		if (!myEvent)
			myEvent = event;

		for (var k in _self.Tabs) {																		// let's set clicked tab to
			t = _self.Tabs[k];																			// be the active one and skip
			if (!(t instanceof TabClass)) {																// each iteration object not
				continue;																				// being based on tab class.
			}

			t.Selected = (t == myEvent.detail);
			if (t.Selected) {
				_ta = t;
			}
		}

		_se = document.createEvent('CustomEvent');
		_se.initCustomEvent('tabselected', true, false, _self);
		_self.dispatchEvent(_se);

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.addTab = function (myCaption, isActive)
	{
	 var f;
	 var e;
	 var t;

		if (!myCaption) {
			throw 'myCaption must not be null!';
		}

		f = document.createDocumentFragment();

		f.appendChild(document.createTextNode(' '));													// this ensures tab spacing!

		e = f.appendChild(document.createElement('li'));
		
		e = e.appendChild(document.createElement('a'));
		e.appendChild(document.createTextNode(myCaption));
		e.setAttribute('href', '#');

		_ta = new TabClass(e);
		_ta.addEventListener('tabclick', OnTabClick, false);
		_ta.Selected = isActive;
		_self.Tabs.add(_ta, _tb.Length.toString());

		_me.firstChild.appendChild(f);
	}

	this.clearTabs = function (myElement)
	{
	 var o;
	
		while (_me.firstChild) {
			_me.removeChild(_me.firstChild);
		}
		o = document.createElement('ul');
		_me.appendChild(o);

		_tb.clear();
	}

	//// ~~~~ inner classes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	/// <summary>
	/// This class provides all functionality
	/// for creating and interacting with
	/// tab objects.
	/// </summary>
	function TabClass(myTabElement, myContentElement)
	{
		//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		var _self;
		var _te;		// tab element
		var _ce;		// content element
		var _ia;		// is active
		var _ev;		// click event

		//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		Object.defineProperty(this, "ID", { get: function () { return _ce.id; } });

		Object.defineProperty(this, "Selected", {
			get: function () { return _ia; },
			set: function (myValue) {
				if (_ce) {
					_ce.style.display = myValue ? 'inherit' : 'none';
				}
				_te.className = myValue ? 'tabstripActive' : '';
				_te.blur();																				// blur to ensure correct style.
				_ia = myValue;
			}
		});

		Object.defineProperty(this, "Visible", {
			get: function () { return _te.style.display != 'none'; },
			set: function (myValue)
			{
				_te.style.display = myValue ? 'inherit' : 'none';

				if (_ce) {
					_ce.className = _ce.className.replace(/treeViewNoTabs /gi, '');
				}

				if (!myValue) {
					_ce.className = 'treeViewNoTabs ' + _ce.className;
				}
			}
		});

		//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		_self = this;
		_self.extendAsEventDispatcher();																// let's extend as dispatcher.

		if (!myTabElement) {
			throw 'myTabElement must not be null!';
		}

		_te = myTabElement;
		_te.addEventListener('click', OnClick, false);

		_ce = myContentElement;

		//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		function OnClick(myEvent)
		{
			if (!myEvent)
				myEvent = event;

			_ev = document.createEvent('CustomEvent');
			_ev.initCustomEvent('tabclick', true, false, _self);
			_self.dispatchEvent(_ev); 																	// raise tab click event.

			WebModel.Common.Helper.cancelEvent(myEvent);
		}
	}
	///
	/// End :: Tab Class
	///
}
///
/// End :: TabStrip Class
///

/// <summary>
/// This class provides all functionality
/// for creating and interacting with
/// treeview objects.
/// </summary>
function TreeViewClass(myElement, myXML, fistLevelClickable)
{
	//// ~~~~ constants ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var TOUCH_EXPAND_WIDTH = 20;

	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _xml;		// xml data
	var _to;		// treeview object
	var _te;		// treeview element
	var _ns;		// nodes collection
	var _ce;		// node click event
	var _ee;		// node expand event
	var _se;		// node collapse event
	var _re;		// reset event
	var _fc;		// first level clickable

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "ID", { get: function () { return _te.id; } });
	Object.defineProperty(this, "Nodes", { get: function () { return _ns; } });
	Object.defineProperty(this, "NodeClass", { get: function () { return NodeClass; } });

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_self = _to = this;																					// let's buffer this for later usage.
	_self.extendAsEventDispatcher();																	// let's extend as dispatcher.

	_fc = fistLevelClickable;

	if (!myElement)
		throw 'myElement must not be null!';
	_te = myElement;

	if (!myXML)
		throw 'myXML must not be null!';
	_xml = myXML;

	_ns = new WebModel.Common.CollectionClass();

	loadNodes();

	//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function OnExpanded(myEvent)
	{
	 var e;

		if (!myEvent)
			myEvent = event;

		e = myEvent.detail;
		if (!e.Nodes.Length && hasChildren(e))
			loadNodes(e);
		else {
			e = e.Element.getElementsByTagName('ul');
			if (e.length) {
				e = e[0];
				e.style.display = 'inherit';
			}
		}

		_ee = document.createEvent('CustomEvent');
		_ee.initCustomEvent('nodeexpanded', true, false, myEvent.detail);
		_self.dispatchEvent(_ee);

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnCollapsed(myEvent)
	{
	 var e;

		if (!myEvent)
			myEvent = event;

		e = myEvent.detail;
		if (e.Nodes.Length) {
			e = e.Element.getElementsByTagName('ul');
			if (e.length) {
				e = e[0];
				e.style.display = 'none';
			}
		}

		_se = document.createEvent('CustomEvent');
		_se.initCustomEvent('nodecollapsed', true, false, myEvent.detail);
		_self.dispatchEvent(_se);

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnClick(myEvent)
	{
	 var e;

		if (!myEvent)
			myEvent = event;

		_ce = document.createEvent('CustomEvent');
		_ce.initCustomEvent('nodeclicked', true, false, myEvent.detail);
		_self.dispatchEvent(_ce);

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.clearSelection = function ()
	{
	 var st; 	// stack
	 var n;		// node

		st = new Array();
		for (n in _ns) {
			if (n != 'add' && n != 'remove' && n != 'clear' && n != 'extendAsEventDispatcher') {
				st.push(_ns[n]);
			}
		}

		while (st.length) {
			for (n in st[0].Nodes) {
				if (n != 'add' && n != 'remove' && n != 'clear' && n != 'extendAsEventDispatcher') {
					st.push(st[0].Nodes[n]);
				}
			}
			n = st.shift().Selected = false;
		}
	};

	this.findNode = function (myID, includeUnloaded)
	{
	 var hp;	// helper
	 var st; 	// stack
	 var qy;	// query
	 var xn;	// xml node
	 var ps;	// parents
	 var mn;	// maximum number
	 var n;		// node
	 var r;		// return;
	 var o;		// multiple usage
	 var i;

		hp = WebModel.Common.Helper;

		r = new Array();
		st = new Array();
		for (n in _ns) {
			if (n != 'add' && n != 'remove' && n != 'clear' && n != 'extendAsEventDispatcher') {
				st.push(_ns[n]);
			}
		}

		while (st.length) {
			if (st[0].ID == myID) {
				r.push(st[0]);
			}

			for (n in st[0].Nodes) {
				if (n != 'add' && n != 'remove' && n != 'clear' && n != 'extendAsEventDispatcher') {
					st.push(st[0].Nodes[n]);
				}
			}

			st.shift();
		}

		if (r.length == 0 && includeUnloaded) {																		// nothing found?
			qy = '/tree/item[%SELECTION%]';																			// yeah! >> let's search
			qy = qy.replace(/%SELECTION%/gi,'id=\'' + myID + '\' or parents/parent/@uuid=\'' + myID + '\'');		// directly in xml.

			mn = 99;																								// find out the highest
			ps = hp.selectNodes(_xml, 'tree/item/parents/parent/@number');											// number value around
			for (i = 0; i < ps.length; i++)	{																		// the whole WebModel.
				if (mn < parseInt(ps[i].nodeValue)) {
					mn = parseInt(ps[i].nodeValue);
				}
			}

			mn = mn.toString();

			xn = hp.selectSingleNode(_xml, qy);
			if (xn) {
				o = isNaN(parseInt(myID)) ? myID : undefined;
				myID = hp.selectSingleNode(xn, 'id/text()').nodeValue;												// let's create our node

				n = new NodeClass(document.createElement('li'), myID);												// to return.
				n.UUID = o;
				n.Name = (WebModel.Settings.DisplayText == SettingsClass.DisplayText.Name ?							
						  hp.selectSingleNode(xn, 'name/text()').nodeValue :
						  hp.selectSingleNode(xn, 'shapetext/text()').nodeValue);

				o = hp.selectSingleNode(xn, 'image/text()');
				if (o != null) {
					n.Image = o.nodeValue;
				}

				r.push(n);
			}
		}

		switch (true) {
			case r.length == 0:		return null;
			case r.length == 1:		return r[0];
			default:				return r;
		}
	};

	this.reset = function (myXML)
	{
	 var e;

		if (myXML != null)
			_xml = myXML;

		_ns.clear();
		for (i = _te.childNodes.length - 1; i >= 0; i--) {
			e = _te.childNodes[i];
			e.parentNode.removeChild(e);
		}

		loadNodes();

		_re = document.createEvent('CustomEvent');
		_re.initCustomEvent('reset', true, false, _self);
		_self.dispatchEvent(_re);
	}

	//// ~~~~ private functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function loadNodes(myParentNode)
	{
	 var img;		// image
	 var qy;		// query
	 var nl;		// node list
	 var xn;		// xml node
	 var tn;		// tree node
	 var le;		// list element
	 var ie;		// item element
	 var ps;		// parents
	 var pn;		// processed nodes
	 var mn;		// maximum number
	 var ay;
	 var o;			// multiple usage
	 var f;			// fragment
	 var i;
	 var j;
	 var s;			// sort by number?
	 var t;			// display text?

		s = WebModel.Settings.Order == SettingsClass.Order.Number;												// buffer display style!
		t = WebModel.Settings.DisplayText == SettingsClass.DisplayText.Name;

		qy = (myParentNode == null) ?																			// let's create our query
			 '/tree/item[count(parents/parent) = 0]' :															// for nodes to insert.
			 '/tree/item[parents/parent/@id=' + myParentNode.ID + ']';

		mn = 99;																								// find out the highest
		ps = WebModel.Common.Helper.selectNodes(_xml, 'tree/item/parents/parent/@number');						// number value around
		for (i = 0; i < ps.length; i++)																			// the whole WebModel.
			if (mn < parseInt(ps[i].nodeValue)) mn = parseInt(ps[i].nodeValue);
		mn = mn.toString();

		ay = new Array();																						
		pn = new WebModel.Common.CollectionClass();
		nl = WebModel.Common.Helper.selectNodes(_xml, qy);
		for (i = 0; i < nl.length; i++) {																		// for each item to add
			if (!le) {																							// to the current parent
				le = document.createElement('ul');																// we create an html element
				(!myParentNode ? _te : myParentNode.Element).appendChild(le);									// first and add an unordered
			}																									// list once.
			xn = nl[i];
			ps = WebModel.Common.Helper.selectNodes(xn, 'parents/parent[@id=' + (myParentNode != null ? myParentNode.ID : 0) + ']');

			j = 0;																								// this code will be run
			do {																								// at least once per selected
				ie = document.createElement('li');																// xml node to create it! 
				tn = new NodeClass(ie,
								   WebModel.Common.Helper.selectSingleNode(xn, 'id/text()').nodeValue,
								   le.parentNode == _te && !_fc);
				tn.Name = (t ?
						   WebModel.Common.Helper.selectSingleNode(xn, 'name/text()').nodeValue :
						   WebModel.Common.Helper.selectSingleNode(xn, 'shapetext/text()').nodeValue);

				o = WebModel.Common.Helper.selectSingleNode(xn, 'image/text()');
				if (o != null)
					tn.Image = o.nodeValue;

				tn.addEventListener('expanded', OnExpanded, false);
				tn.addEventListener('collapsed', OnCollapsed, false);
				tn.addEventListener('click', OnClick, false);

				if (s && ps.length > 0) {																		// numbering & multiple parents?
					o = WebModel.Common.Helper.selectSingleNode(ps[j], '@uuid');								// yeah! >> uuid given?
					if (o != null) {																			// yeah! >> save uuid and
						o = o.nodeValue;																		// formatted, corresponding
						tn.UUID = o;																			// number to created node.
						o = String.repeat("0", mn.length);
						o += WebModel.Common.Helper.selectSingleNode(ps[j], '@number').nodeValue;
						tn.Number = o.slice(-1 * (mn.length));
					}
				}

				(!myParentNode ? _ns : myParentNode.Nodes).add(tn, tn.UUID || tn.ID.toString());				// let's add node to node
				ay.push(tn);																					// list and buffer for sort.
			}																									// loop each parent while
			while(s && ++j < ps.length)																			// we're displaying numbers!

		}
		
		if (!ay.length)																							// no nodes buffered?
			return;																								// yeah! >> return here.

		ay.sort(																								// let's sort our nodes
			function compare(a, b) {																			// based on their text.
				if (a.DisplayName.toLowerCase() < b.DisplayName.toLowerCase()) {
					return -1;
				}
				if (a.DisplayName.toLowerCase() > b.DisplayName.toLowerCase()) {
					return 1;
				}
				return 0;
			}
		);

		f = document.createDocumentFragment();																	// finally add node elements to
		for (i = 0; i < ay.length; i++) {																		// corresponding unordered list.
			f.appendChild(ay[i].Element);																		
		}
		le.appendChild(f);
	}

	function hasChildren(myParentNode)
	{
	 var qy;		// query
	 var nl;		// node list

		qy = '/tree/item[%SELECTION%]';
		qy = qy.replace(/%SELECTION%/gi,
						(myParentNode == null) ? 'count(parents/parent) = 0' : 'count(parents/parent[@id=' + myParentNode.ID + ']) > 0');
		nl = WebModel.Common.Helper.selectNodes(_xml, qy);

		return nl.length > 0;
	}

	//// ~~~~ inner classes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	/// <summary>
	/// This class provides all functionality
	/// for creating and interacting with
	/// treeview node objects.
	/// </summary>
	function NodeClass(myElement, myID, expandableOnly)
	{
		//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		var _self;
		var _tmr;		// timer
		var _ne;		// node element
		var _ns;		// nodes collection
		var _ce;		// click event
		var _ee;		// expand event
		var _se;		// collapse event
		var _id;		// id
		var _uid;		// uniqueid
		var _nm;		// node name
		var _nb;		// number
		var _si;		// state image element
		var _ii;		// icon image element
		var _tn;		// text node
		var _be;		// border element
		var _eo;		// expandable only?

		//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		Object.defineProperty(this, "ID", { get: function () { return _id; } });
		Object.defineProperty(this, "UUID", {
			get: function () { return _uid; },
			set: function (myUUID) { _uid = myUUID; }
		});
		Object.defineProperty(this, "Element", { get: function () { return _ne; } });
		Object.defineProperty(this, "TreeView", { get: function () { return _to; } });
		Object.defineProperty(this, "Image", {
			get: function () { return _ii; },
			set: function (myImage) { _ii.src = myImage; _ii.style.display = (myImage.length > 0 ? '' : 'none'); } 
		});
		Object.defineProperty(this, "DisplayName", {
			get: function () { return _tn.nodeValue; }
		});
		Object.defineProperty(this, "Name", {
			get: function () { return _nm; },
			set: function (myName)
			{
				_nm = myName;

				_tn.nodeValue = _nm;
				if (_nb && WebModel.Settings.Order == SettingsClass.Order.Number)
					_tn.nodeValue = _nb + ' ' + _nm;
			}
		});
		Object.defineProperty(this, "Number", {
			get: function () { return parseInt(_nb); },
			set: function (myNumber)
			{
				_nb = myNumber;

				_tn.nodeValue = _nm;
				if (_nb && WebModel.Settings.Order == SettingsClass.Order.Number)
					_tn.nodeValue = _nb + ' ' + _nm;
			}
		});
		Object.defineProperty(this, "Expanded", { get: function () { return _si.getAttribute('src').indexOf('tree_opened') >= 0 } });
		Object.defineProperty(this, "Selected", {
			get: function () { return _be.clasName == 'treeViewSelectedItem'; },
			set: function (isSelected) { _be.className = isSelected ? 'treeViewSelectedItem' : ''; }
		});
		Object.defineProperty(this, "Nodes", { get: function () { return _ns; } });

		//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		_self = this;
		_self.extendAsEventDispatcher();																		// let's extend as dispatcher.

		_eo = expandableOnly;

		if (!myElement)
			throw 'myElement must not be null!';
		_ne = myElement;
		_ne.addEventListener('mouseup', OnNodeMouseUp, false);
		_ne.addEventListener('touchend', OnNodeTouchEnd, false);

		if (!myID)
			throw 'myID must not be null!';
		_id = parseInt(myID);

		_be = _ne.appendChild(document.createElement('span'));

		if (!hasChildren(_self)) {
			_ne.style.paddingLeft = '20px';
		} else {
			_si = _be.appendChild(document.createElement('img'));
			_si.setAttribute('src', './images/ui/tree_closed.png');
			_si.addEventListener('click', OnStateImageClick, false);
		}
		_ii = _be.appendChild(document.createElement('img'));
		_ii.setAttribute('style', 'display: none');
		_tn = document.createTextNode('');
		_be.appendChild(document.createElement('span')).appendChild(_tn);
		if (_id == 0) {
			_tn.parentNode.setAttribute('id', 'nullid');
		}
		_ns = new WebModel.Common.CollectionClass();

		//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		function OnStateImageClick(myEvent)
		{
		 var e;

			if (!myEvent)
				myEvent = event;

			e = (myEvent.target || myEvent.srcElement);
			if (e != _si) {
				WebModel.Common.Helper.cancelEvent(myEvent);
				return;
			}

			switch (e.getAttribute('src').indexOf('tree_closed') >= 0) {
				case true:
					e.setAttribute('src', './images/ui/tree_opened.png');

					_ee = document.createEvent('CustomEvent');
					_ee.initCustomEvent('expanded', true, false, _self);
					_self.dispatchEvent(_ee); 																	// raise expand event.
					break;

				case false:
					e.setAttribute('src', './images/ui/tree_closed.png');

					_se = document.createEvent('CustomEvent');
					_se.initCustomEvent('collapsed', true, false, _self);
					_self.dispatchEvent(_se); 																	// raise collapse event.
					break;
			}

			WebModel.Common.Helper.cancelEvent(myEvent);
		}

		function OnNodeClick(myEvent)
		{
			if (_eo || myEvent.offsetX < TOUCH_EXPAND_WIDTH) {
				if (_si) {
					_si.click();
					return;
				}
			}

			_self.TreeView.clearSelection();			// clear current node selection,
			_self.Selected = true;						// select the current node and

			_ce = document.createEvent('CustomEvent');
			_ce.initCustomEvent('click', true, false, _self);
			_self.dispatchEvent(_ce);					// raise its click event.
		}

		function OnNodeDoubleClick(myEvent)
		{
			if (!_eo) {
				OnNodeClick(myEvent);
			}
			if (_si) {									// state image available?
				_si.click();							// yeah! >> dispatch click!
			}
		}
		
		function OnNodeMouseUp(myEvent)
		{
		 var e;
		 var n;		// now
		 var l;		// last
		 var d;		// delta

			myEvent = myEvent || event;
			e = myEvent.target || myEvent.srcElement;
			if ((e != _ne && e != _be && e.parentNode != _ne && e.parentNode != _be) ||
				(e == _si))
			{
				WebModel.Common.Helper.cancelEvent(myEvent);
				return;
			}

			n = new Date().getTime();										// let's get current time
			l = this.LastUp || n + 1;										// and calculate difference
			d = n - l;														// to last up-event.

			if (_tmr) {														// any timer set?
				clearTimeout(_tmr);											// yeah! >> reset it!
				_tmr = null;
			}

			if (d < 500 && d > 0) {											// last up-event within 500ms?
				OnNodeDoubleClick(myEvent);									// yeah! >> dispatch double click!
			} else {														// no! >> let's trigger timered
				_tmr = setTimeout(											// click event within next 500ms.
					function (myEvent) { OnNodeClick(myEvent); },
					500,
					{ offsetX: myEvent.offsetX, offsetY: myEvent.offsetY }
				);
			}

			this.LastUp = n;												// buffer last up-event time.

			WebModel.Common.Helper.cancelEvent(myEvent);
		}

		function OnNodeTouchEnd(myEvent)
		{
			OnNodeMouseUp(myEvent);
		}
	}
	///
	/// End :: Node Class
	///
}
TreeViewClass.Style = { Default: 0, Processes: 1, Information: 2, Areas: 3 };		// static!
///
/// End :: TreeView Class
///

/// <summary>
/// This class provides all functionality
/// for creating and interacting with
/// drawing area objects.
/// </summary>
function DrawingAreaClass(myElement)
{
	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _dae;		// drawing area element
	var _le;		// load event

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "Element", { get: function () { return _dae; } });

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_self = this;
	_self.extendAsEventDispatcher();																		// let's extend as dispatcher.

	if (!myElement)
		throw 'myElement must not be null!';
	_dae = myElement;
	_dae.addEventListener('load', OnLoad, false);

	//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function OnLoad(myEvent)
	{
	 var e;

		if (!myEvent)
			myEvent = event;

		_le = document.createEvent('CustomEvent');
		_le.initCustomEvent('load', true, false, _self);
		_self.dispatchEvent(_le);																			// raise loaded event.

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.load = function (myURI)
	{
	 var da;	// drawing area
	 
		if(!myURI) {
			throw 'myURI must not be null!';
		}

		da = _dae.cloneNode(true); 
		da.setAttribute('src', myURI); 
		da.addEventListener('load', OnLoad, false);

		_dae.parentNode.replaceChild(da, _dae);
		_dae = da; 
	};
}
///
/// End :: DrawingArea Class
///

/// <summary>
/// This class provides all functionality
/// for creating and interacting with
/// WhereAmI objects.
/// </summary>
function WhereAmIClass(myElement)
{
	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _me; 		// markup element
	var _md;		// main drop down element
	var _fe;		// first (visible) element
	var _ce;		// click event
	var _es;		// elements

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_self = this;
	_self.extendAsEventDispatcher();																		// let's extend as dispatcher.

	if (!myElement) {
		throw 'myElement must not be null!';
	}
	_me = myElement;

	_md = myElement.appendChild(document.createElement('li'));												// let's create special drop
	_md.setAttribute('style', 'display: none;');															// down element for displaying
	_md.appendChild(document.createElement('a'));															// elements hidden by overflow.
	_md.firstChild.appendChild(document.createTextNode('«'));
	_md.firstChild.setAttribute('href', '#');
	_md.firstChild.addEventListener('click', OnClick, false);

	_es = new Array();

	//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function OnClick(myEvent)
	{
	 var d;

		myEvent = myEvent || event;

		if (this == _md.firstChild) {
			d = {
				Index: 0,
				Node: _fe.Node,
				PrecedingNode: null,
				DropDownRequest: true,
				SpecialDropDown: true,
				X: myEvent.clientX,
				Y: myEvent.clientY
			};
		}

		_ce = document.createEvent('CustomEvent');
		_ce.initCustomEvent('click', true, false, d || myEvent.detail);
		_self.dispatchEvent(_ce); 																			// re-raise click event.

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.add = function (myNode)
	{
	 var e;
	 var n;
	 var b;		// multiple usage!
		
		if (!myNode) {
			throw 'myNode must not be null!';
		}

		_md.setAttribute('style', 'display: none');

		n = _es.length;
		if (n-- && _es[n].Node.ID == myNode.ID) {
			b = true;
		}

		if (n-- > 0 && _es[n++].Node.ID == myNode.ID) {
			e = _es[n];
			e.Element.parentNode.removeChild(e.Element);
			_es.pop();
			b = true;
		}

		if (!b) {
			e = new WhereAmIElementClass(myNode);
			e.addEventListener('click', OnClick, false);

			_es.push(e);
		}

		for (var i = 0; i < _es.length; i++) {
			e = _es[i].Element;
			e.removeAttribute('style');
			e.firstChild.removeAttribute('style');
		}

		b = false;
		for (var i = 0; i < _es.length; i++) {
			e = _es[i];
			if (_me.parentNode.scrollWidth <= _me.parentNode.offsetWidth) {
				if (b) {
					e.Element.firstChild.setAttribute('style', 'display: none;');
				}
				_fe = e;
				break;
			} else {
				b = true;
				_md.removeAttribute('style');
				e.Element.setAttribute('style', 'display: none;');
			}
		}
	}

	this.clearAfter = function (myIndex)
	{
	 var e;
		
		if (isNaN(myIndex) || myIndex < 0) {
			throw 'myIndex is out of range!';
		}

		while (_es.length > myIndex) {
			e = _es[_es.length - 1];
			e.Element.parentNode.removeChild(e.Element);
			_es.pop();
		}
	}

	this.clear = function ()
	{
	 var e;
		
		while (_es.length > 0) {
			e = _es[_es.length - 1];
			e.Element.parentNode.removeChild(e.Element);
			_es.pop();
		}
	}

	this.getInvisibleElements = function ()
	{
	 var ay;

		ay = new Array();
		for (var i = 0; i < _es.length; i++) {
			e = _es[i];
			if (e.Element.hasAttribute('style')) {
				ay.push(e);
			} else {
				break;
			}
		}

		return ay;
	}

	this.refresh = function ()
	{
	 var ay;
	 var nd;

		ay = new Array();
		for (var i = 0; i < _es.length; i++) {
			nd = _es[i].Node;
			ay.push(nd.TreeView.findNode(nd.ID, true));
		}

		_self.clear();

		for (var i = 0; i < ay.length; i++) {
			_self.add(ay[i]);
		}
	}

	//// ~~~~ inner classes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	/// <summary>
	/// This class provides all functionality
	/// for creating and interacting with
	/// WhereAmI element objects.
	/// </summary>
	function WhereAmIElementClass(myNode)
	{
		//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		var _self;
		var _e;			// markup element
		var _d;			// dropdown element
		var _n;			// node
		var _p;			// preceding
		var _i;			// index
		var _ce;		// click event

		//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		Object.defineProperty(this, "Element", { get: function () { return _e; } });
		Object.defineProperty(this, "Node", { get: function () { return _n; } });
		Object.defineProperty(this, "Index", { get: function () { return _i; } });

		//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		var e;		// element

		_self = this;
		_self.extendAsEventDispatcher();																	// let's extend as dispatcher.

		if (!myNode) {
			throw 'myNode must not be null!';
		}

		if (!myNode.TreeView || !(myNode instanceof myNode.TreeView.NodeClass)) {
			throw 'myNode must be typeof TreeViewClass.NodeClass!';
		}

		_i = _es.length;
		_n = myNode;
		_p = _i > 0 ? _es[_i - 1].Node : null;
		_e = _me.appendChild(document.createElement('li'));

		if (_es.length) {
			_d = _e.appendChild(document.createElement('a'));
			_d.setAttribute('href', '#');
			_d.appendChild(document.createTextNode('►'));
			_d.addEventListener('click', OnClick, false);
		}

		e = _e.appendChild(document.createElement('a'));
		e.setAttribute('href', 'index.html?processid=' + myNode.ID);
		e.appendChild(document.createTextNode(_n.Name));
		e.addEventListener('click', OnClick, false);

		//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		function OnClick(myEvent)
		{
		 var d;	// detail
		 var n;	// number

			n = _es.length;
			d = {
				Index: _i,
				Node: _n,
				PrecedingNode: _p,
				DropDownRequest: (this == _d),
				SpecialDropDown: false,
				X: myEvent.clientX,
				Y: myEvent.clientY
			};

			_ce = document.createEvent('CustomEvent');
			_ce.initCustomEvent('click', true, false, d);
			_self.dispatchEvent(_ce);

			WebModel.Common.Helper.cancelEvent(myEvent);
		}
	}
	///
	/// End :: DropDownElement Class
	///
}
///
/// End :: DropDown Class
///