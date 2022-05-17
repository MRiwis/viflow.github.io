// -----------------------------------------------------------------------
// <copyright file="ViCon.ViFlow.WebModel.Settings.js" company="ViCon GmbH">
//     Copyright © ViCon GmbH.
// </copyright>
// <summary>
//		This file provides all functionality for persisting
//		web application settings.
// </summary>
// <remarks>
//		This file relies on:
//		====================
///		~ relies on ViCon.ViFlow.WebModel
///		~ relies on ViCon.ViFlow.WebModel.Common
///		~ relies on ViCon.ViFlow.WebModel.Diagnostics
///		~ relies on lz-string 1.3.3
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
/// for persisting web application settings.
/// </summary>
function SettingsClass()
{
	//// ~~~~ constants ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var REGEX_MATCH_EMAIL = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
	var REGEX_MATCH_SETTINGS = /settings=([^\s;]*)/gi;
	var COOKIE_EXPIRATION = 0x757B12C00;				// 365 days

	//// ~~~~ enums ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var SettingsType = { Default: 0, Integer: 1, Boolean: 2, Float: 3 };

	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _xml;
	var _hp;	// helper

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "RawData", {
		get: function () { return _xml; }
	});
	Object.defineProperty(this, "FirstRunProcessed", {
		get: function () { return readSetting('FirstRunProcessed', SettingsType.Boolean); },
		set: function (myValue) { writeSetting('FirstRunProcessed', myValue); }
	});
	Object.defineProperty(this, "ShowChangesSinceVisit", {
		get: function () { return readSetting('ShowChangesSinceVisit', SettingsType.Boolean); },
		set: function (myValue) { writeSetting('ShowChangesSinceVisit', myValue); }
	});
	Object.defineProperty(this, "LastVisit", {
		get: function () { return readSetting('LastVisit', SettingsType.Float); },
		set: function (myValue) { writeSetting('LastVisit', myValue); }
	});
	Object.defineProperty(this, "Order", {
		get: function () { return readSetting('Order', SettingsType.Integer); },
		set: function (myValue) { writeSetting('Order', myValue); }
	});
	Object.defineProperty(this, "DisplayText", {
		get: function () { return readSetting('DisplayText', SettingsType.Integer); },
		set: function (myValue) { writeSetting('DisplayText', myValue); }
	});
	Object.defineProperty(this, "LinkFallback", {
		get: function () { return readSetting('LinkFallback', SettingsType.Boolean); },
		set: function (myValue) { writeSetting('LinkFallback', myValue); }
	});
	Object.defineProperty(this, "ReferencedAreasOnly", {
		get: function () { return readSetting('ReferencedAreasOnly', SettingsType.Boolean); },
		set: function (myValue) { writeSetting('ReferencedAreasOnly', myValue); }
	});
	Object.defineProperty(this, "ReferencedInfosOnly", {
		get: function () { return readSetting('ReferencedInfosOnly', SettingsType.Boolean); },
		set: function (myValue) { writeSetting('ReferencedInfosOnly', myValue); }
	});
	Object.defineProperty(this, "RememberLastID", {
		get: function () { return readSetting('RememberLastID', SettingsType.Boolean); },
		set: function (myValue) { writeSetting('RememberLastID', myValue); }
	});
	Object.defineProperty(this, "CurrentID", {
		get: function () { return readSetting('CurrentID', SettingsType.Integer); },
		set: function (myValue) { writeSetting('CurrentID', myValue); }
	});
	Object.defineProperty(this, "CurrentPage", {
		get: function () { return readSetting('CurrentPage', SettingsType.Integer); },
		set: function (myValue) { writeSetting('CurrentPage', myValue); }
	});
	Object.defineProperty(this, "CurrentUser", {
		get: function () { return readSetting('CurrentUser', SettingsType.Integer); },
		set: function (myValue) { writeSetting('CurrentUser', myValue); }
	});
	Object.defineProperty(this, "DependentObjects", {
		get: function () { return readSetting('DependentObjects', SettingsType.Boolean); },
		set: function (myValue) { writeSetting('DependentObjects', myValue); }
	});
	Object.defineProperty(this, "PropertyWindowPosition", {
		get: function () { return readSetting('PropertyWindowPosition'); },
		set: function (myValue) { writeSetting('PropertyWindowPosition', myValue); }
	});
	Object.defineProperty(this, "ZoomWindowPosition", {
		get: function () { return readSetting('ZoomWindowPosition'); },
		set: function (myValue) { writeSetting('ZoomWindowPosition', myValue); }
	});
	Object.defineProperty(this, "ZoomWindowVisible", {
		get: function () { return readSetting('ZoomWindowVisible', SettingsType.Boolean); },
		set: function (myValue) { writeSetting('ZoomWindowVisible', myValue); }
	});
	Object.defineProperty(this, "ResultWindowPosition", {
		get: function () { return readSetting('ResultWindowPosition'); },
		set: function (myValue) { writeSetting('ResultWindowPosition', myValue); }
	});
	Object.defineProperty(this, "ResultWindowVisible", {
		get: function () { return readSetting('ResultWindowVisible', SettingsType.Boolean); },
		set: function (myValue) { writeSetting('ResultWindowVisible', myValue); }
	});
	Object.defineProperty(this, "ChangesWindowPosition", {
		get: function () { return readSetting('ChangesWindowPosition'); },
		set: function (myValue) { writeSetting('ChangesWindowPosition', myValue); }
	});
	Object.defineProperty(this, "NavigationPosition", {
		get: function () { return readSetting('NavigationPosition'); },
		set: function (myValue) { writeSetting('NavigationPosition', myValue); }
	});
	Object.defineProperty(this, "NavigationVisible", {
		get: function () { return readSetting('NavigationVisible', SettingsType.Boolean); },
		set: function (myValue) { writeSetting('NavigationVisible', myValue); }
	});
	Object.defineProperty(this, "LanguageUI", {
		get: function ()
		{
		 var sz;
		 var n;

			sz = readSetting('LanguageUI');
			if (sz.length == 0)
				sz = window.navigator.userLanguage || window.navigator.language;

			n = sz.indexOf('-');
			if (n > 0)
				sz = sz.substr(0, n);

			return sz;
		},
		set: function (myValue) { writeSetting('LanguageUI', myValue); }
	});
	Object.defineProperty(this, "LanguageContent", {
		get: function ()
		{
			return readSetting('LanguageContent') || 'A';
		},
		set: function (myValue) { writeSetting('LanguageContent', myValue); }
	});
	Object.defineProperty(this, "CustomLogo", {
		get: function () { return readSetting('CustomLogo', SettingsType.Default); }
	});
	Object.defineProperty(this, "FeedbackURI", {
		get: function ()
		{
		 var sz;

			sz = readSetting('FeedbackURI', SettingsType.Default);
			if (sz.match(REGEX_MATCH_EMAIL) && sz.indexOf('mailto:') < 0) {
				sz = 'mailto:' + sz;
			}

			return sz;
		}
	});
	Object.defineProperty(this, "HiddenTabs", {
		get: function () { return readSetting('HiddenTabs', SettingsType.Integer); }
	});

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	_self = this;
	_hp = WebModel.Common.Helper;

	//// ~~~~ public functions  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.load = function ()
	{
	 var d;		// default settings
	 var m;		// match
	 var r;		// reset?
	 var c;
	 var i;

		WebModel.Diagnostics.Console.info('Loading settings.');

		try {
			c = localStorage.getItem(document.location.pathname);
		}
		catch (e) {
			c = document.cookie;
		}

		if (!c) {
			c = '';
		}

		i = 0;																														// let's load our settings
		while (m = REGEX_MATCH_SETTINGS.exec(c)) {																					// data from the document
			_xml = m[1];																											// cookie.
			i++;
		}
		if (i != 1)	{																												// did we get valid settings?
			_xml = null;																											// no! >> let's nullify them.
			WebModel.Diagnostics.Console.warn('Got invalid settings. Using default.');
		} else {																													// yes! >> let's try to load them.
			try {
				_xml = unescape(_xml);
				_xml = LZString.decompressFromBase64(_xml);
				_xml = _hp.getXmlFromString(_xml);
			}
			catch (e) {																												// exception? yeah!
				_xml = null;																										// let's nullify settings.
				WebModel.Diagnostics.Console.warn('Got invalid settings. Using default.');
			}
		}

		r = WebModel.Parameters['resetsettings'];
		if (!r)
			r = false;
		else {
			r = r.toLowerCase();
			r = parseInt(r) == 1 || r == 'true';
		}
		if (r || !_xml) {																											// don't got xml?
			_xml = _hp.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/settings.xml', false);						// yeah! >> load default
			WebModel.Diagnostics.Console.info('User enforced us to use default settings.');
		}

		d = _hp.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/settings.xml', false);

		if (parseFloat(_hp.selectSingleNode(_xml, '/settings/@timestamp').nodeValue) < parseFloat(_hp.selectSingleNode(d, '/settings/@timestamp').nodeValue)) {
			WebModel.Diagnostics.Console.info('Timestamp too old. We\'ve to migrate current settings now.');
			upgradeSettings(_xml, d);
		}
		r = WebModel.Parameters['displaysettings'];
		if (!r)
			r = false;
		else {
			r = r.toLowerCase();
			r = parseInt(r) == 1 || r == 'true';
		}
		if (r)
			alert(_hp.getStringFromXml(_xml));

		WebModel.Diagnostics.Console.log('Our finally loaded settings are:\r\n\r\n' + _hp.getStringFromXml(_xml));
	}

	this.save = function ()
	{
	 var s;		// settings
	 var e;		// expiration
		
		_hp.selectSingleNode(_xml, '/settings/@timestamp').nodeValue = _hp.getTimeStamp();

		if (_self.LastVisit <= 0) {																						// no last visit saved?
			_self.LastVisit = WebModel.Common.Helper.getDoubleFromDate(new Date());										// yeah! >> save initially!
		}

		s = _hp.getStringFromXml(_xml);																					// let's get our settings...
		WebModel.Diagnostics.Console.log('We are saving the following settings now:\r\n\r\n' + s);

		s = LZString.compressToBase64(s);																				// ...as string, compress
		s = escape(s);																									// and escape them for saving.

		e = new Date();
		e.setTime(e.getTime() + COOKIE_EXPIRATION);
		e = e.toUTCString();

		s =  'settings=' + s + '; ';																					// let's build our cookie.
		s += 'expires=';
		s += e;

		try {
			localStorage.setItem(document.location.pathname, s);
		}
		catch (e) {
			document.cookie = s;
		}

		WebModel.Diagnostics.Console.info('Settings saved.');
	}

	//// ~~~~ private functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function readSetting(mySetting, myType)
	{
	 var v;

		if (!mySetting) {
			throw 'mySetting must not be null!';
		}

		v = _hp.selectSingleNode(_xml, '/settings/' + mySetting + '/text()');
		if (!v) {
			v = { nodeValue: null };
		}
		v = v.nodeValue;

		switch (myType) {
			case SettingsType.Integer:
				v = (v != null) ? parseInt(v) : 0;				
				break;
			case SettingsType.Float:
				v = (v != null) ? parseFloat(v) : 0;				
				break;
			case SettingsType.Boolean:
				if (v == null) {
					v = false;
				}

				if (!isNaN(parseInt(v))) {
					v = parseInt(v) != 0;
				}

				break;
			default:
				if (v == null) {
					v = '';
				}

				break;
		}

		return v;
	}

	function writeSetting(mySetting, myValue)
	{
	 var n;

		if (!mySetting) {
			throw 'mySetting must not be null!';
		}

		if (myValue == undefined || myValue == null) {
			throw 'myValue must not be null!';
		}

		n = _hp.selectSingleNode(_xml, '/settings/' + mySetting + '/text()');
		if (!n) {
			n = _hp.selectSingleNode(_xml, '/settings/' + mySetting);
			n = n.appendChild(_xml.createTextNode(''));
		}

		if (isNaN(parseInt(myValue)) && (myValue == true || myValue == false)) {
			myValue = myValue ? 1 : 0;
		}

		n.nodeValue = myValue;
	}

	function upgradeSettings(mySettings, myDefault)
	{
	 var nl;
	 var n;

		nl = _hp.selectNodes(myDefault, '/settings/*');
		for (var i = 0; i < nl.length; i++)																			// let's iterate each default setting.
			switch (true) {
				case !_hp.selectSingleNode(_xml, '/settings/' + nl[i].nodeName):									// local setting not available? >> so
					n = _xml.importNode(nl[i], true);																// we add it by simply cloning the setting
					_hp.selectSingleNode(_xml, '/settings').appendChild(n);											// node.
					break;
				case _hp.selectSingleNode(nl[i], '@mergable') != null:												// local setting exists and is mergable?
					if (_hp.selectSingleNode(nl[i], '@mergable').nodeValue != 'true' &&								// >> so we remove local node and re-clone
						parseInt(_hp.selectSingleNode(nl[i], '@mergable').nodeValue) == 0)							// the default one.
					{ break; }

					n = _hp.selectSingleNode(_xml, '/settings/' + nl[i].nodeName);
					n.parentNode.removeChild(n);

					n = _xml.importNode(nl[i], true);
					_hp.selectSingleNode(_xml, '/settings').appendChild(n);
					break;
			}
	}
}
SettingsClass.Order = { Number: 0, Name: 1 }; 											// static!
SettingsClass.DisplayText = { Name: 1, ShapeText: 0 }; 									// static!
///
/// End :: Settings Class
///
