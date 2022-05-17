// -----------------------------------------------------------------------
// <copyright file="ViCon.ViFlow.WebModel.js" company="ViCon GmbH">
//     Copyright © ViCon GmbH.
// </copyright>
// <summary>
//		This file provides all basic functionality for the WebModel
//		and represents the main entry point for the whole web application.
// </summary>
// <remarks>
//		This file relies on:
//		====================
//		~ no other javascript files
//
//		Assumed VDG Violations:
//		=======================
//		~ properties must be placed between functions and nested classes.
//				REASON:
//				constructor code relies on pre-defined properties within
//				JavaScript code.
//
//		Pre-Requisites:
//		===============
//		~ this is the base clase for the whole WebModel and
//		  the entry point for all functionality / object model.
//		~ cross browser compatibility (HTML5-based):
//			-> Chrome				>= v18
//			-> Firefox (Gecko)		>= v4.0 (v2.0)
//			-> Internet Explorer	>= v10
//			-> Opera				>= v11.50
//			-> Safari				>= 5.3
//
//		Possible Parameters:
//		====================
//		~ resetsettings=true		>= reset current settings
//		~ displaysettings=true		>= display current settings
//		~ processid={number}		>= force opening specific graphic
// </remarks>
// -----------------------------------------------------------------------

/// <summary>
/// This is main main entry point
/// for all functionality provided
/// by this web application.
/// </summary>
{
	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var WebModel;
	var ErrorProcessed;

	//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	window.onload = function (dontReloadObjectModel)
	{
		document.getElementById('errormessage').style.display = 'none';				// hide error message on working script.
		if (!dontReloadObjectModel || dontReloadObjectModel!= true) {				// check for bool as there could come in an event!
			document.getElementById('splash').style.display = 'inherit';			// let's show splash screen and
			setTimeout(loadObjectModel, 500);										// initialize the object model.
		}
	}

	window.onerror = function (myMessage, myURL, myLine)
	{
	 var em;

		if (ErrorProcessed)
			return;

		ErrorProcessed = true;

		myMessage = myMessage || event;

		em = document.getElementById('errormessage');
		if (em == null)
			return;

		em.style.display = 'inherit';
		em = em.appendChild(document.createElement('p'));
		em.appendChild(document.createTextNode('Extended information: ' + myMessage + ' (0x' + myLine.toString(16) + ' in ' + myURL + ')'));
	}

	//// ~~~~ functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function loadObjectModel()
	{
		WebModel = new WebModelClass();
	}
}
///
/// End :: Main Entry Point
///

/// <summary>
/// This class provides the most
/// common functionality for this
/// web application.
/// </summary>
function WebModelClass()
{
	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;

	var _Common;
	var _Diagnostics;
	var _Search;
	var _Drawing;
	var _Settings;
	var _UI;
	var _AddOns;
	var _ExclusionData;

	var _pl;				// parameter list

	//// ~~~~ properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, 'Common', {get: function () { return _Common; } });
	Object.defineProperty(this, 'Diagnostics', { get: function () { return _Diagnostics; } }); 			
	Object.defineProperty(this, 'Search', {get: function () { return _Search; } });
	Object.defineProperty(this, 'Drawing', { get: function () { return _Drawing; } }); 			
	Object.defineProperty(this, 'Parameters', { get: function () { return _ps; } });
	Object.defineProperty(this, 'Settings', { get: function () { return _Settings; } }); 			
	Object.defineProperty(this, 'UI', { get: function () { return _UI; } });
	Object.defineProperty(this, 'AddOns', { get: function () { return _AddOns; } });
	Object.defineProperty(this, 'ExclusionData', { get: function () { return _ExclusionData; } });

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	{
		_self = this;
		_ps = new Object();

		_pl = document.location.search;																						// let's parse query string
		_pl = _pl.slice(1);																									// to a parameter array and...
		_pl = _pl.split('&');
		for (var i = 0; i < _pl.length; i++) {																				// ...iterate each key value
			_pl[i] = _pl[i].split('=');																						// pair setting it to ourself's
			_ps[_pl[i][0]] = _pl[i][1];																						// parameters list.
		}

		OnLibraryLoaded();																									// let's initialize our libraries.
	}

	//// ~~~~ event handlers ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function OnLibraryLoaded(myLibrary)
	{
	 var NAMESPACE = 'ViCon.ViFlow.WebModel';
	 var xslt;
	 var gid;	// graphic id
	 var pid;	// page id
	 var oid;	// object id
	 var tfg;	// type flag
	 var clg;	// content language
	 var ilg;	// interface language
	 var hp;	// helper

		switch (myLibrary) {
			case undefined:
				loadScript('./js/ViCon.ViFlow.WebModel.Diagnostics.js', OnLibraryLoaded);
				break;

			case NAMESPACE + '.Diagnostics':
				_Diagnostics = new DiagnosticsClass();
				loadScript('./js/lz-string-1_3_3.js', OnLibraryLoaded);
				break;

			case 'lz-string-1_3_3':
				loadScript('./js/iso-languages.js', OnLibraryLoaded);
				break;

			case 'iso-languages':
				loadScript('./js/ViCon.ViFlow.WebModel.Common.js', OnLibraryLoaded);
				break;

			case NAMESPACE + '.Common':
				_Common = new CommonClass();
				loadScript('./js/ViCon.ViFlow.WebModel.AddOns.js', OnLibraryLoaded);
				break;

			case NAMESPACE + '.AddOns':
				_AddOns = new AddOnsClass();
				loadScript('./js/ViCon.ViFlow.WebModel.Settings.js', OnLibraryLoaded);
				break;

			case NAMESPACE + '.Settings':
				_Settings = new SettingsClass();
				_Settings.load();

				clg = WebModel.Parameters['contentlanguage'];
				if (clg) {
					_Settings.LanguageContent = clg;
				}

				ilg = WebModel.Parameters['interfacelanguage'];
				if (ilg) {
					_Settings.LanguageUI = ilg;
				}

				hp = WebModel.Common.Helper;
				xslt = hp.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './xslt/intermediate_exclusions.xslt', false);	// let's build global
				_ExclusionData = hp.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/empty.xml', false);				// exclusion list to
				_ExclusionData = hp.transformXML(_ExclusionData, xslt);																// disable pre-selected
				_ExclusionData = (hp.selectSingleNode(_ExclusionData, '/exclusions/text()') || { nodeValue: '' }).nodeValue;		// objects.

				loadScript('./js/ViCon.ViFlow.WebModel.UI.js', OnLibraryLoaded);
				break;

			case NAMESPACE + '.UI':
				_UI = new UIClass();
				loadScript('./js/ViCon.ViFlow.WebModel.Drawing.js', OnLibraryLoaded);
				break;

			case NAMESPACE + '.Drawing':
				_Drawing = new DrawingClass();
				loadScript('./js/ViCon.ViFlow.WebModel.Search.js', OnLibraryLoaded);
				break;

			case NAMESPACE + '.Search':
				_Search = new SearchClass();
				loadScript('./js/ViCon.ViFlow.WebModel.Printing.js', OnLibraryLoaded);
				break;

			case NAMESPACE + '.Printing':
				_Printing = new PrintingClass();
				OnLibraryLoaded(_self);
				break;

			case _self:
				gid = WebModel.Parameters['processid'] || WebModel.Settings.CurrentID;									// let's load last or specified
				pid = WebModel.Parameters['page'] || WebModel.Settings.CurrentPage;										// drawing and replace history
				oid = WebModel.Parameters['objectid'];
				tfg = WebModel.Parameters['typeflag'];
				WebModel.Drawing.load(gid, pid);																		// state accordingly.

				if (oid && tfg) {
					switch (tfg) {
						case 'p':	tfg = 'globalProcessTree';		break;
						case 'i':	tfg = 'globalInformationTree';	break;
						case 'a':	tfg = 'globalAreaTree';			break;
					}

					_self.navigate(oid, tfg, undefined, undefined, true);
				}

				window.history.replaceState(
				{
					ObjectID: gid,
					TreeViewID: 'globalProcessTree',
					PropertiesVisible: false,
					GraphicID: gid
				}, document.title);
				window.addEventListener('popstate', OnHistoryChange, false);											// let's listen to history changes.
				window.addEventListener('beforeunload', _Settings.save, false);											// let's listen to unload event.
				if (!!navigator.platform.match(/iPhone|iPod|iPad/)) {
					window.addEventListener('pagehide', _Settings.save, false);
				}
				
				document.getElementById('splash').style.display = 'none';												// finally hide splash screen.

				loadScript('./js/custom.js');																			// try to execute custom scripts.
				break;
		}
	}

	function OnHistoryChange(myEvent)
	{
	 var s;		// state
	 var o;		// object

		myEvent = myEvent || event;

		window.onload(true);																							// let's hide error message!

		s = myEvent.state;
		o = WebModel.UI.TreeViews[s.TreeViewID].findNode(s.ObjectID, true);
		if (o) {
			if (s.PropertiesVisible) {
				WebModel.UI.PropertyWindow.open(o);
			} else {
				WebModel.UI.PropertyWindow.close();
			}
			if (WebModel.Drawing.GraphicID != s.GraphicID)
			{
				o = WebModel.UI.TreeViews['globalProcessTree'].findNode(s.GraphicID, true);
				if (o) {
					WebModel.Drawing.load(o.ID, 1);
					WebModel.UI.WhereAmI.add(o);
				}
			}
		}

		if (WebModel.UI.ContextMenu) {
			WebModel.UI.ContextMenu.hide();
		}

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.navigate = function (myObjectID, myTreeViewID, openGraphic, highlightSearch, noHistory, markShapeID)
	{
	 var u;
		
		if (!myObjectID) {
			throw 'myID must not be null!';
		}

		if (!myTreeViewID) {
			throw 'myTreeViewID must not be null!';
		}

		u = WebModel.UI;
		o = u.TreeViews[myTreeViewID];
		if (!o) {
			throw 'Tree View with given ID could not be found!';
		}

		o = o.findNode(myObjectID, true);
		if (!o) {
			throw 'Tree Node with given ID could not be found!';
		}

		if (o.length) {												// multiple matches?
			if (myTreeViewID.indexOf('process') >= 0) {				// yeah! >> process tree?
				o = o[0];											// yeah! >> use first item!
			} else {												// no! let's use first
				for (var i = 0; i < o.length; i++) {				// childless item!
					if (!o[i].Nodes.length) {
						o = o[i];
						break;
					}
				}
			}
		}

		if (openGraphic) {
			WebModel.UI.PropertyWindow.close();
			WebModel.Drawing.load(o.ID, 1, highlightSearch, undefined, markShapeID);
			u.WhereAmI.add(o);
		} else {
			u.PropertyWindow.open(o, highlightSearch);
		}

		if (WebModel.UI.ContextMenu) {
			WebModel.UI.ContextMenu.hide();
		}

		if (noHistory) {
			return;
		}

		window.history.pushState(
		{
			ObjectID: o.UUID ? o.UUID : o.ID,
			TreeViewID: o.TreeView.ID,
			PropertiesVisible: u.PropertyWindow.Visible,
			GraphicID: WebModel.Drawing.GraphicID
		}, o.Name);
	}

	//// ~~~~ private functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function loadScript(myScript, myCallback)
	{
	 var h; // head
	 var s; // script
	 var l;	// library
	 var n;	// multiple usage

		if (!myScript) {
			throw 'myScript must not be null!';
		}

		l = myScript;
		n = l.lastIndexOf('/');
		l = l.substr(++n, (l.length - n));
		n = l.lastIndexOf('.js');
		l = l.substr(0, n);

		s = document.createElement('script');
		s.setAttribute('type', 'text/javascript');
		s.setAttribute('src', myScript);
		if (s.readyState)
			s.onreadystatechange = function () {
				if (s.readyState == 'loaded' || s.readyState == 'complete') {
					s.onreadystatechange = null;
					if (!!myCallback) {
						myCallback(l);
					}
				}
			};
		else
			s.onload = function () {
				if (!!myCallback) {
					myCallback(l);
				}
			};

		h = document.getElementsByTagName('head')[0];
		if (h == null)
			throw 'Head element not found!';

		h.appendChild(s);
	}
}
///
/// End :: WebModel Class
///