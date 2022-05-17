// -----------------------------------------------------------------------
// <copyright file="ViCon.ViFlow.WebModel.Search.js" company="ViCon GmbH">
//     Copyright © ViCon GmbH.
// </copyright>
// <summary>
//		This file provides functionality that is required for
//		searching in content within this web application.
// </summary>
// <remarks>
//		This file relies on:
//		====================
//		~ ViCon.ViFlow.WebModel.js
//		~ ViCon.ViFlow.WebModel.Common.js
//		~ ViCon.ViFlow.WebModel.Diagnostics.js
//		~ ViCon.ViFlow.WebModel.UI.js
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
/// This is main main entry point
/// for creating search indices
/// used by this web application.
/// </summary>
{
	//// ~~~~ functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	{
	 var si;

		si = new SearchIndexClass();
		try {
			var b = (WebModel == undefined);
		}
		catch (e) {
			si.create();
		}
	}
}
///
/// End :: Main Entry Point
///

/// <summary>
/// This class provides functionality that is
/// required for searching content within this
/// web application.
/// </summary>
function SearchClass()
{
	//// ~~~~ constants ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var HIGHLIGH_COLORS = ['#ff6', '#a0ffff', '#9f9', '#f99', '#f6f'];
	var HIGHLIGHT_SKIP = 'th';
	var HIGHLIGHT_TAG = 'text';
	var LINK_TYPE = 0x0;
	var LINK_ID = 0x1;

	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _tmr;	// click handling timer
	var _hp;	// helper
	var _ls;	// last search
	var _se;	// search field element

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "Terms", { get: function () { return _ls ? _ls.Expression : ''; } });

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_self = this;

	_se = document.getElementById('searchField');
	if (!_se) {
		throw 'Could not locate search field element!';
	}

	//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.OnResultNavigate = function (myEvent)
	{
	 var n;		// now
	 var l;		// last
	 var d;		// delta
	 var b;

		myEvent = myEvent || event;
		o = !myEvent.targetTouches ? myEvent : myEvent.targetTouches[0];

		n = new Date().getTime();										// get current time and
		l = this.LastUp || n + 1;										// calculate difference
		d = n - l;														// to last up-event.

		if (_tmr) {														// any timer set?
			clearTimeout(_tmr);											// yeah! >> reset it!
			_tmr = null;
		}

		if (d < 500 && d > 0) {											// last up-event within 500ms?
			OnResultDoubleClick(myEvent);								// yeah! >> raise double click!
		} else {														// no! >> let's trigger timered
			_tmr = setTimeout(											// click event within next 500ms.
				function (myEvent) { OnResultClick(myEvent) },
				500,
				{
					currentTarget: myEvent.currentTarget,
					target: myEvent.target,
					srcElement: myEvent.srcElement,
					changedTouches: myEvent.changedTouches,
					pageX: myEvent.clientX,
					pageY: myEvent.clientY
				}
			);
		}

		this.LastUp = n;												// buffer last up-event time.

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	OnResultClick = function (myEvent, direct)
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

		sz = (o.currentTarget || o.target || o.srcElement).href;
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

		WebModel.UI.performObjectNavigation(p, ay, direct, true);
	}

	function OnResultDoubleClick(myEvent)
	{
		OnResultClick(myEvent, true);
	}

	function OnResultAvailable (myData, searchStarted)
	{
	 var d;

		d = (new Date() - searchStarted) / 1000;
		d = d.toFixed(2);
		if (isNaN(d)) {
			d = (0).toFixed(2);
		}
		WebModel.UI.ResultWindow.Data = { Result: myData, Seconds: d };
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.find = function (myExpression, myFilter)
	{
		WebModel.UI.ResultWindow.open();

		if (!_ls || myExpression != _ls.Expression || myFilter != _ls.Filter) {
			WebModel.UI.ResultWindow.reset();
		} else {
			return;
		}

		if (myExpression &&
			myExpression.length &&
			myExpression != WebModel.UI.Translations.getTranslation('webmodel.ui.value.' + _se.id.toLowerCase(), _se.value))
		{
			_ls = { Expression: myExpression, Filter: myFilter };

			WebModel.Common.Helper.performAsyncTransform(
				'./data/search_index_' + WebModel.Settings.LanguageContent + '.xml',
				'./xslt/intermediate_search.xslt',
				OnResultAvailable,
				{
					displaytext: WebModel.Settings.DisplayText,
					linkfallback: +WebModel.Settings.LinkFallback,
					query: myExpression,
					filter: (myFilter || ''),
					renferencedareasonly: +WebModel.Settings.ReferencedAreasOnly,
					renferencedinfosonly: +WebModel.Settings.ReferencedInfosOnly,
					exclusionlist: WebModel.ExclusionData
				},
				new Date()
			);
		} else {
			OnResultAvailable(undefined);
		}
	}

	this.highlightTerms = function (myElement)
	{
	 var se;	// skip expression
	 var me;	// match expression
	 var ms;	// matches
	 var wc;	// word colors
	 var ci;	// color index
	 var st;	// stack
	 var sz;
	 var i, j;	// multiple usage
	 var e;		// element
	 var o;		// multiple usage

		se = new RegExp('^(?:' + HIGHLIGHT_SKIP + ')$', 'gim');

		wc = new Array();
		me = new Array();
		sz = _ls.Expression.toLowerCase();
		do {
			sz = sz.replace(/  /gi, ' ').trim();
			i = sz.indexOf('"');
			j = sz.substr(++i, sz.length - i).indexOf('"');
			switch (true) {
				case i >= 0 && j >= 0:
					me.push(sz.substr(i, j));
					sz = sz.replace('"' + sz.substr(i, j) + '"', '');
					break;
				
				case sz.indexOf(' ') >= 0:
					i = sz.indexOf(' ');
					me.push(sz.substr(0, i));
					sz = sz.substr(i, sz.length - i);
					break;

				case sz.length > 0:
					me.push(sz);
					sz = '';
					break;
			}
		} while (sz.length > 0);

		sz = ' ' + _ls.Expression.toLowerCase().replace(/"/gi, '') + ' ';
		do {
			o = false;
			for (i = 0; i < me.length - 1; i++) {
				if (sz.indexOf(' ' + me[i++] + ' ') > sz.indexOf(' ' + me[i--] + ' ')) {
					j = me[i];
					me[i] = me[++i];
					me[i--] = j;
					o = true;
				}
			}
		} while (o);
		sz = '(' + me.join('|') + ')';

		ci = 0;
		st = new Array();
		st.push(myElement);
		do {
			e = st.pop();
			me = new RegExp(sz, 'gim');
			
			if (!se.test(e.nodeName)) {
				if (e.hasChildNodes()) {
					for (i = 0; i < e.childNodes.length; i++) {
						st.push(e.childNodes[i]);
					}
				}

				if (e.nodeType == 3 &&
					(ms = me.exec(e.nodeValue)))
				{
					if(!wc[ms[0].toLowerCase()]) {
						wc[ms[0].toLowerCase()] = HIGHLIGH_COLORS[ci++ % HIGHLIGH_COLORS.length];
					}

					o = document.createElement(HIGHLIGHT_TAG);
					o.appendChild(document.createTextNode(ms[0]));
					o.setAttribute('style', 'background-color: ' + wc[ms[0].toLowerCase()] + '; font-style: inherit; color: #000;');
					j = e.splitText(ms.index);
					j.nodeValue = j.nodeValue.substr(ms[0].length);
					e.parentNode.insertBefore(o, j);

					st.push(j);
				}
			}
		} while (st.length);

	}

	this.removeHighlighting = function ()
	{
	 var ay;
	 var e;		// element
	 var p;		// parent

		ay = document.getElementsByTagName(HIGHLIGHT_TAG);
		while (ay.length && (e = ay[0])) {
			p = e.parentNode;
			p.replaceChild(e.firstChild, e);
			p.normalize();
		}
	}
}
///
/// End :: Search Class
///

/// <summary>
/// This class provides functionality that is
/// required for creating search indices for
/// this web application.
/// </summary>
function SearchIndexClass()
{
	//// ~~~~ consts ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var PATH_TLNG = '..\\xslt\\intermediate_list_languages_content.xslt';
	var PATH_TIDX = '..\\xslt\\intermediate_search_index.xslt';
	var PATH_ISET = '..\\data\\settings.xml';
	var PATH_IDOC = '..\\data\\empty.xml';
	var PATH_ODOC = '..\\data\\';

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	{
	 var _self;

		_self = this;
		_self.create = create;
	}

	//// ~~~~ functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function create()
	{
	 var xdout;
	 var xslt;
	 var xdin;
	 var set;
	 var nl;
	 var ay;
	 var ec;		// exit code

		ec = ensurePlatformX86();
		if (ec != undefined) {
			WScript.Quit(ec);	
		}

		xdin = getNewInstanceXML();
		if (!xdin.load(PATH_ISET)) {
			failFast(-1, 'Loading settings failed!');
		}

		set = {
			DisplayText: +xdin.selectSingleNode('/settings/DisplayText/text()').nodeValue,
			LinkFallback: +xdin.selectSingleNode('/settings/LinkFallback/text()').nodeValue,
			ReferencedAreasOnly: +xdin.selectSingleNode('/settings/ReferencedAreasOnly/text()').nodeValue,
			ReferencedInfosOnly: +xdin.selectSingleNode('/settings/ReferencedInfosOnly/text()').nodeValue
		}

		if (!xdin.load(PATH_IDOC)) {
			failFast(-2, 'Loading generic input document failed!');
		}

		xslt = getNewInstanceXML();
		if (!xslt.load(PATH_TLNG)) {
			failFast(-3, 'Loading language transformation failed!');
		}

		xdout = getNewInstanceXML();
		xdin.transformNodeToObject(xslt, xdout);
		nl = xdout.selectNodes('/list/item/id/text()');

		ay = new Array();
		for (var i = 0; i < nl.length; i++) {
			ay.push(nl[i].nodeValue);
		}

		if (!xslt.load(PATH_TIDX)) {
			failFast(-4, 'Loading search index tranformation failed!');
		}

		xslt.selectSingleNode('//xsl:param[@name="displaytext"]/text()').nodeValue = set.DisplayText;
		xslt.selectSingleNode('//xsl:param[@name="linkfallback"]/text()').nodeValue = set.LinkFallback;
		xslt.selectSingleNode('//xsl:param[@name="renferencedareasonly"]/text()').nodeValue = set.ReferencedAreasOnly;
		xslt.selectSingleNode('//xsl:param[@name="renferencedinfosonly"]/text()').nodeValue = set.ReferencedInfosOnly;

		for (var i = 0; i < ay.length; i++) {
			xdout = getNewInstanceXML();

			xslt.selectSingleNode('//xsl:param[@name="language"]/text()').nodeValue = ay[i];
			xdin.transformNodeToObject(xslt, xdout);
			
			xdout.save(PATH_ODOC + 'search_index_' + ay[i] + '.xml');
		}

		WScript.Quit(0);
	}

	function getNewInstanceXML()
	{
	 var xd;

		if (!xd) {
			try { xd = WScript.CreateObject('Msxml2.FreeThreadedDOMDocument.6.0'); }
			catch (e) {}
		}

		if (!xd) {
			try { xd = WScript.CreateObject('Msxml2.FreeThreadedDOMDocument.3.0'); }
			catch (e) {}
		}

		if (!xd) {
			try { xd = WScript.CreateObject('Msxml.DOMDocument'); }
			catch (e) {}
		}

		try { xd.setProperty('AllowDocumentFunction', true); }							// let's try to allow document function
		catch (e) {}																	// if needed.
		try { xd.setProperty('AllowXsltScript', true); }								// let's try to allow xslt script if
		catch (e) {}																	// needed.
		try { xd.setProperty('ResolveExternals', true); }								// let's try to allow resolving external
		catch (e) {}																	// documents.

		xd.setProperty('SelectionNamespaces', 'xmlns:xsl="http://www.w3.org/1999/XSL/Transform"');

		return xd;
	}

	function ensurePlatformX86()
	{
	 var sh;
	 var ev;
	 var sz;
	 
	 	sh = WScript.CreateObject('WScript.Shell');
		ev = sh.Environment('Process');
		
		if (WScript.FullName.toLowerCase().indexOf('system32') && ev('PROCESSOR_ARCHITECTURE') == 'AMD64') {
			sz = ev('WINDIR') + '\\syswow64\\cscript.exe' + ' "' + WScript.ScriptFullName + '"';
			return sh.Run(sz, 1, true);
		}

		return;			
	}
	
	function failFast(myErrorCode, myMessage)
	{
	 var sh;

		if (myMessage) {
			if (WScript.FullName.toLowerCase().indexOf('cscript.exe') >= 0) {
				WScript.Echo(myMessage);
			}
			
			sh = WScript.CreateObject('WScript.Shell');
			sh.LogEvent(1, 'ViCon.ViFlow.WebModel.SearchIndex: ' + myMessage);
		}

		WScript.Quit(myErrorCode);
	}
}
///
/// End :: Search Class
///
