// -----------------------------------------------------------------------
// <copyright file="ViCon.ViFlow.WebModel.Common.js" company="ViCon GmbH">
//     Copyright © ViCon GmbH.
// </copyright>
// <summary>
//		This file provides common functionality that may be used
//		between different components of this web application.
// </summary>
// <remarks>
//		This file relies on:
//		====================
//		~ ViCon.ViFlow.WebModel.js
//		~ ViCon.ViFlow.WebModel.Diagnostics.js
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
/// This class provides common functionality
/// used between different components of this
/// web application.
/// </summary>
function CommonClass()
{
	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _hp;	// helper
	var _xc;	// xml cache

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "Helper", { get: function () { return _hp; } });
	Object.defineProperty(this, "LinkClass", { get: function () { return LinkClass; } });
	Object.defineProperty(this, "HelperClass", { get: function () { return HelperClass; } });
	Object.defineProperty(this, "CollectionClass", { get: function () { return CollectionClass; } });

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_hp = new HelperClass();																							// let's create our helper instance!
	_xc = new CollectionClass();																						// let's initialize xml cache!

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.prototype.extendAsEventDispatcher = function () {															// let's extend all javascript
		if (!this._el) {																								// objects to be able to be used
			this._el = []; 																								// as event dispatchers...
		}
		this.isEventDispatcher = true;

		if (typeof (this.dispatchEvent) == "undefined") {
			this.dispatchEvent = function (eventObject) {
				for (var i = 0; i < this._el.length; i++) {
					var o = this._el[i];
					if (o.type === eventObject.type) {
						o.callback(eventObject);
						if (eventObject.cancelBubble) {
							break;
						}
					}
				}
			};
		}

		if (typeof (this.addEventListener) == "undefined") {
			this.addEventListener = function (type, callback, capture) {
				var b = false;
				for (var i = 0; i < this._el.length; i++) {
					var o = this._el[i];
					if (o.type === type && o.callback === callback) {
						b = true;
						break;
					}
				}
				if (!b) {
					this._el.push({ 'type': type, 'callback': callback, 'capture': capture });
				}
			};
		}

		if (typeof (this.removeEventListener) == "undefined") {
			this.removeEventListener = function (type, callback, capture) {
				for (var i = 0; i < this._el.length; i++) {
					var o = this._el[i];
					if (o.type === type && o.callback === callback) {
						this._el.splice(i, 1);
						break;
					}
				}
			};
		}
	}

	Object.addMSGestureEventListener = function (myObject, myHandlerName, myHandler, useCapture)
	{
     var n;

		if (!window.PointerEvent && !window.MSPointerEvent)
			return;

		if (!myObject._go) {
			try { myObject._go = new MSGesture(); }
			catch (e) {}
			if (myObject._go) {
				myObject._go.target = myObject;
				myObject.addEventListener(
					(window.PointerEvent ? 'pointerdown' : 'MSPointerDown'),
					function (myEvent) { myObject._go.addPointer(myEvent.pointerId); }
				);
			}
		}

		myObject.addEventListener(myHandlerName, myHandler, useCapture);
	}

	String.repeat = function (myString, myCount) {
		return new Array(parseInt(myCount) + 1).join(myString);
	};

	//// ~~~~ inner classes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	/// <summary>
	/// This class provides a simple collection
	/// object for storing data based on keys.
	/// </summary>
	function CollectionClass()
	{
		//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		var _self;

		//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		Object.defineProperty(this, "Length", { get: function ()
		{
		 var n; 	

			n = 0;
			for (var k in _self) {
				if (k != 'add' && k != 'remove' && k != 'clear' && k != 'extendAsEventDispatcher') {
					n++;
				}
			}

			return n;
		} });

		//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		_self = this;

		//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		this.add = function (myItem, myKey) {
			if (!myItem) {
				throw 'myItem must not be null!';
			}

			if (!myKey) {
				throw 'myKey must not be null!';
			}

			if (_self[myKey]) {
				throw 'Element with index ' + myKey + ' already exists!';
			}

			_self[myKey] = myItem;

			return myItem;
		}

		this.remove = function (myKey) {
			if (!myKey) {
				throw 'myIndex must not be null!';
			}

			if (_self[myKey]) {
				throw 'Element with key ' + myKey + ' does not exists!';
			}

			delete _self[myKey];
		}

		this.clear = function () {
			for (var k in _self) {
				if (k != 'add' && k != 'remove' && k != 'clear' && k != 'extendAsEventDispatcher') {
					delete _self[k];
				}
			}
		}
	}
	///
	/// End :: Collection Class
	///

	/// <summary>
	/// This class provides a simple hyperlink
	/// object for being able to store more
	/// information related to a hyperlink.
	/// </summary>
	function LinkClass(myURL, myCaption, myImage, myAltImage, myShapeUUID)
	{
		//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		var _u;		// url
		var _c;		// caption
		var _i;		// image
		var _a;		// alternative image
		var _s;		// shape uuid

		//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		_u = myURL;
		_c = myCaption;
		_i = myImage;
		_a = myAltImage;
		_s = myShapeUUID

		//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		Object.defineProperty(this, "URL", { get: function () { return _u; } });
		Object.defineProperty(this, "Caption", { get: function () { return _c; } });
		Object.defineProperty(this, "Image", { get: function () { return _i; } });
		Object.defineProperty(this, "AltImage", { get: function () { return _a; } });
		Object.defineProperty(this, "ShapeUUID", { get: function () { return _s; } });
	}
	///
	/// End :: Link Class
	///

	/// <summary>
	/// This class provides common helper
	/// functions.
	/// </summary>
	function HelperClass()
	{
		//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		this.cancelEvent = function (myEvent, fullCancel)
		{
	 		if (myEvent) {
				myEvent = myEvent || event;
			}

			if (!myEvent) {
				throw 'myEvent must not be null!';
			}

			if (typeof myEvent.cancelBubble !== 'unknown' &&
				typeof myEvent.cancelBubble !== 'undefined')
			{
				myEvent.cancelBubble = true;
			}

			if (typeof myEvent.returnValue !== 'unknown' &&
				typeof myEvent.returnValue !== 'undefined')
			{
				myEvent.returnValue = false;
			}

			if (typeof myEvent.preventDefault !== 'unknown' &&
				typeof myEvent.preventDefault !== 'undefined')
			{
				myEvent.preventDefault();
			}

			if (typeof myEvent.stopPropagation !== 'unknown' &&
				typeof myEvent.stopPropagation !== 'undefined' &&
				(fullCancel == undefined || fullCancel))
			{
				myEvent.stopPropagation();
			}
		}

		this.getStyle = function (myElement, myProperty)
		{
			if (!myElement) {
				throw 'myElement must not be null!';
			}

			if (!myProperty) {
				throw 'myProperty must not be null!';
			}

			if (myElement.currentStyle) {														//IE?
				return myElement.currentStyle[myProperty];
			} else {
				if (document.defaultView && document.defaultView.getComputedStyle) {			// FF?
					return document.defaultView.getComputedStyle(myElement, "")[myProperty];
				} else {																		// try and get inline style...
					return myElement.style[myProperty];
				}
			}
		}

		this.getTimeStamp = function ()
		{
			return Math.round(new Date().getTime() / 1000);
		}

		this.getRelativePosition = function (myElement, eventX, eventY)
		{
		 var pos;

			if (!myElement) {
				throw 'myElement must not be null!';
			}

			pos = { X: eventX, Y: eventY };
			while (myElement) {
				pos.X -= myElement.offsetLeft;
				pos.Y -= myElement.offsetTop;
				myElement = myElement.offsetParent;
			}

			return pos;
		}

		this.getDateFromDouble = function (myDouble)
		{
		 var e;		// epoch
		 var m;		// msec / day
		 var n;		// number
		 var d;		// decimal

			if (!+myDouble) {
				return;
			}

			e = new Date(1899,11,30);
			m = 8.64e7;
			n = parseFloat(myDouble);
			d = n - Math.floor(n);
			if (n < 0 && d) {
				n = Math.floor(n) - d;
			}

			return new Date(n * m + e.getTime());
		}				

		this.getDoubleFromDate = function (myDate)
		{
		 var e;		// epoch
		 var m;		// msec / day
		 var n;		// number

			if (!myDate) {
				return 0;
			}

			e = new Date(1899,11,30);
			m = 8.64e7;
			n = -1 * (e - myDate) / m;
			d = n - Math.floor(n);
			if (n < 0 && d) {
				n = Math.floor(n) - d;
			}

			return n;
		}
		
		this.containsChildNodeWithTagName = function (myNode, myTagName, myOptionalAttributeNameFilter, myOptionalAttributeValueFilter)
		{
			return (_hp.getFirstChildByTagName(myNode, myTagName) != null);
		}

		this.getFirstChildByTagName = function (myNode, myTagName, myOptionalAttributeNameFilter, myOptionalAttributeValueFilter)
		{
		 var nl;
		 var nd;
		 var at;

			if (!myNode) {
				throw 'myNode must not be null!';
			}

			if (!myTagName) {
				throw 'myTagName must not be null!';
			}

			nl = myNode.childNodes;
			for (var i = 0; i < nl.length; i++) {
				nd = nl.item(i);
				if (nd.nodeName.toLowerCase() == myTagName.toLowerCase()) {
					if (myOptionalAttributeNameFilter ||
						myOptionalAttributeValueFilter)
					{
						at = nd.getAttribute(myOptionalAttributeNameFilter);
						if (at &&
							(
								!myOptionalAttributeValueFilter ||
								at.toLowerCase() == myOptionalAttributeValueFilter.toLowerCase()
							)
						) {
							return nd;
						}
					} else {
						return nd;
					}
				}
			}

			return null;
		}

		this.appendXmlToElement = function (myData, myTargetNode, skipRootNode, preserveSort)
		{
		 var ta;	// table array
		 var ra;	// row array
		 var o, p;	// multiple usage
		 var r;		// row
		 var n;		// node
		 var c;		// count
		 var f;		// fragment
		 var s;		// sort direction
		 var d;		// date

			WebModel.Diagnostics.Console.log('Got following XML data for appending to HTML:\r\n\r\n' + WebModel.Common.Helper.getStringFromXml(myData));

			f = document.createDocumentFragment();
			if (skipRootNode) {
				for (var i = 0, il = myData.childNodes.length; i < il; i++) {
					f.appendChild(_hp.importNodeFromXML(myData.childNodes[i], true, true));
				}
			} else {
				f.appendChild(_hp.importNodeFromXML(myData, true, true));
			}
			myTargetNode.appendChild(f);

			n = myTargetNode.getElementsByTagName('*');
			if (n && n.length) {
				for (var i = (n.length - 1); i >= 0; i--) {
					o = n[i];
					if (o.hasAttribute('class') &&
						o.getAttribute('class') == 'timestamp' &&
						!o.hasAttribute('convertedtimestamp'))
					{
						o.setAttribute('convertedtimestamp', o.textContent.length > 0 ? o.textContent : 0);

						d = _hp.getDateFromDouble(o.textContent);
						d = d ? d.toLocaleDateString() : '';
						d = d.replace(/\d+/g, function(myMatch) {
							return "0".substr(myMatch.length - 1) + myMatch;
						});

						o.textContent = d;
					}
				}
			}

			myTargetNode = (skipRootNode && myTargetNode.parentNode) ?
						   myTargetNode.parentNode :
						   myTargetNode;
			ta = myTargetNode.getElementsByTagName('table');
			if (ta && ta.length) {
				for (var i = 0; i < ta.length; i++) {
					o = ta[i];
					if (o.hasAttribute('class') &&
						o.getAttribute('class').indexOf('sortable') >= 0)
					{
						c = 0;
						ra = o.getElementsByTagName('tr');
						if (ra && ra.length) {
							for (var j = 0; j < ra.length; j++) {
								r = ra[j];
								if (r.parentNode != o) {
									continue;
								}

								n = r.getElementsByTagName('th');
								if (n && n.length) {
									for (var k = (n.length - 1); k >= 0; k--) {
										p = n[k];
										if (p.parentNode != r) {
											continue;
										}

										p.addEventListener('click', _hp.sortTableByHeader, false);
										if (p.hasAttribute('class') || (!c && k == 0)) {
											if (preserveSort) {												// if we've to preserve sort order
												s = p.getAttribute('class');								// we flip sort state to get right
												s = (s == 'sorted_asc') ? 'sorted_desc' : 'sorted_asc';		// sort direction. *omg*
												p.setAttribute('class', s);
											}
											_hp.sortTableByHeader({ target: p }, k != 0);		
											ta = myTargetNode.getElementsByTagName('table');				// we've to refresh as previous
											o = ta[i];														// call deletes current collection
											ra = o.getElementsByTagName('tr');								// data!
											r = ra[j];
											n = r.getElementsByTagName('th');						
											c++;
										}
									}
								}
							}
						}
					}
				}
			}

			WebModel.Diagnostics.Console.log('Finished appending XML data.');
		}

		this.sortTableByHeader = function (myEvent, preverseSortInstruction)
		{
		 var th;		// table header
		 var tr;		// table row
		 var tb;		// table
		 var hr;		// header row
		 var cc;		// column count
		 var ci;		// column index
		 var ri;		// row index
		 var sa;		// sort ascending?
		 var sd;		// sort date?
		 var ss;		// swap succeeded?
		 var rc;		// row collection
		 var ra;		// row array
		 var sb;		// sort range begin
		 var se;		// sort range end
		 var tt;		// temporary table
		 var v1, v2;	// values
		 var o;			// multiple usage!
		 var f;			// fragment

			myEvent = myEvent || event;
			th = myEvent.target || myEvent.srcElement;
			hr = th.parentNode;

			tb = th
			do {
				tb = tb.parentNode;
			} while(tb && tb.nodeName.toLowerCase() != 'table');
		
			if (!tb) {
				throw 'Could not get sortable table base!';
			}

			cc = hr.getElementsByTagName('th');
			if (!cc || !cc.length) {
				throw 'Sortable table is badly formatted!';
			}
			
			sb = se = -1;
			for (var i = 0; i < cc.length; i++) {
				o = cc[i];
				if (o.parentNode &&
					o.parentNode == hr)
				{
					if (o == th) {
						ci = i;
					} else if (!preverseSortInstruction) {
						o.removeAttribute('class');
					}
				}
			}

			if (!th.hasAttribute('class') || th.getAttribute('class') != 'sorted_asc') {
				th.setAttribute('class', 'sorted_asc');
				sa = true;
			} else {
				th.setAttribute('class', 'sorted_desc');
				sa = false;
			}

			f = document.createDocumentFragment();

			rc = tb.getElementsByTagName('tr');
			if (rc && rc.length) {
				sb = _hp.getNodeIndex(hr) + 1;								// let's determine search
				for (var i = sb; i < rc.length; i++) {						// begin and end.
					if (rc[i] == hr) {
						sb = i + 1;
						continue;
					}

					if (sb > 0) {
						cc = rc[i].getElementsByTagName('th');
						if (cc && cc.length) {
							for (var j = 0; j < cc.length; j++) {
								o = cc[j];
								if (o.parentNode &&
									o.parentNode != hr &&
									o.parentNode.parentNode &&
									o.parentNode.parentNode == tb)
								{
									se = i;
									break;
								}
							}
						}
					}
				}

				ra = new Array();											// let's re-add event
				for (var i = 0; i < rc.length; i++) {						// listeners to our
					tr = rc[i];												// table headers.
					if (tr.parentNode && tr.parentNode == tb) {
						tr = tr.cloneNode(true);
						ra.push(tr);

						th = tr.getElementsByTagName('th');
						if (th && th.length) {
							for (var j = 0; j < th.length; j++) {
								o = th[j];
								if (o.parentNode && o.parentNode == tr) {
									o.addEventListener('click', _hp.sortTableByHeader, false);
								}
							}
						}
					}
				}

				if (se < 0) {
					se = ra.length;
				}

				do {														// let's sort determined
					ss = false;												// table rows on selected
					for (var i = sb; i < se - 1; i++) {						// column.
						v1 = ra[i++].childNodes[ci];
						v1 = v1.hasAttribute != undefined && v1.hasAttribute('convertedtimestamp') ?
							 v1.getAttribute('convertedtimestamp') :
							 v1.textContent.toLowerCase();

						v2 = ra[i--].childNodes[ci];
						v2 = v2.hasAttribute != undefined && v2.hasAttribute('convertedtimestamp') ?
							 v2.getAttribute('convertedtimestamp') :
							 v2.textContent.toLowerCase();

						if ((sa && v1.localeCompare(v2) > 0) || (!sa && v1.localeCompare(v2) < 0)) {
							tr = ra[i];
							ra[i] = ra[++i];
							ra[i--] = tr;
							ss = true;
						}
					}
				} while (ss);

				for (var i = 0; i < ra.length; i++) {
					f.appendChild(ra[i]);
				}
			}

			tt = tb.cloneNode(false);				// explicit bool usage because of firefox bug!
			tt.appendChild(f);

			tb.parentNode.replaceChild(tt, tb);
		}

		this.getNodeIndex = function (myNode)
		{
		 var i;
		 var n;

			i = 0;
			n = myNode;
			while (n = n.previousSibling) {
				if (n.nodeType === 1) {
					++i;
				}
			}

			return i;
		}

		this.validateURI = function (myURI)
		{
		 var xr;

			if (!xr) {																							// let's create IE v6 local parser.
				try { xr = new ActiveXObject('Msxml2.FreeThreadedDOMDocument.6.0'); }
				catch (e) {}
			}
			if (!xr) {																							// let's create IE v3 local parser.
				try { xr = new ActiveXObject('Msxml2.FreeThreadedDOMDocument.3.0'); }
				catch (e) {}
			}
			if (!xr) {																							// let's create IE web parser.
				try { new ActiveXObject('Microsoft.XMLHTTP'); }
				catch (e) {}
			}
			if (!xr) {																							// let's create cross-browser parser.
				try { xr = new XMLHttpRequest(); }
				catch (e) {}
			}
			if (!xr)																							// fail if no parser is there!
				throw 'Could not create XMLHttpRequest!';

			switch (xr.open) {
				case undefined:																					// we're using local parser.
					xr.async = false;
					if (!xr.load(myURI)) {																		// successfully loaded requested resource?
						return (xr.parseError.errorCode != -2147024893) &&	// E_PATHNOTFOUND					// no! >> notify fail!
							   (xr.parseError.errorCode != -2147024894) &&	// E_FILENOTFOUND
							   (xr.parseError.errorCode != -2146697210) &&	// INET_E_OBJECT_NOT_FOUND
							   (xr.parseError.errorCode != -2146697208) &&	// SYSTEM_ERROR
							   (xr.parseError.errorCode != -1072896636);	// DTD_PROHIBITED
					}
					break;

				default:																						// we're using remote parser.
					xr.open(document.location.protocol.toLowerCase().indexOf('file:') < 0 ? 'HEAD' : 'GET', myURI, false);																// open it with GET method.
					xr.onreadystatechange = function () {														// let's create async handler.
						if (xr.readyState != 4)
							return;
						if (xr.status != undefined && xr.status != 200 && xr.status != 0)
							return;
					}
					try {
						xr.send(null);																			// finally send the request.
					}
					catch (e) {
						return false;																			// on fail we notify about!
					}

					if (xr.status != undefined && xr.status != 200 && xr.status != 0)
						return false;

					break;
			}

			return true;																						// all well, let's go!
		}

		this.calculateHash = function (myString)
		{
		 var h;

			h = 0;
			for (var i = 0; i < myString.length; i++) {
				if (!(i % 2)) {
					h += (myString.charCodeAt(i) * i);
				} else {
					h -= Math.round(myString.charCodeAt(i) / i);
				}
			}

			return h;
		}

		this.importNodeFromXML = function importNodeFromXML(myNodeXML, recursive, disableOutputEscaping)
		{
		 var nd;
		 var nl;
		 var sz;
		 var at;
		 var n;
		 var f;

			if (!myNodeXML) {
				throw 'myNodeXML must not be null!';
			}

			if (!recursive) {
				recursive = false;
			}

			if (!disableOutputEscaping) {
				disableOutputEscaping = false;
			}

			switch (myNodeXML.nodeType) {
				case document.ELEMENT_NODE:
					nd = document.createElement(myNodeXML.nodeName);
					if (myNodeXML.attributes && myNodeXML.attributes.length > 0) {
						for (var i = 0, il = myNodeXML.attributes.length; i < il; i++) {
							at = myNodeXML.attributes[i];
							nd.setAttribute(at.nodeName, myNodeXML.getAttribute(at.nodeName));
						}
					}
				
					if (recursive && myNodeXML.childNodes && myNodeXML.childNodes.length > 0) {
						for (var i = 0, il = myNodeXML.childNodes.length; i < il; i++) {
							nd.appendChild(importNodeFromXML(myNodeXML.childNodes[i], recursive, disableOutputEscaping));
						}
					}

					return nd;

				case document.COMMENT_NODE:
					return document.createComment(sz.replace(/&#13;&#10;/gi, '\r\n'));

				case document.TEXT_NODE:
				case document.CDATA_SECTION_NODE:
					f = document.createDocumentFragment();

					sz = myNodeXML.nodeValue;
					if (!disableOutputEscaping) {
						return document.createTextNode(decodeURI(sz.replace(/&#13;&#10;/gi, '\r\n')));
					}

					nd = document.createElement('div');
					nd.innerHTML = sz;
					nl = nd.childNodes;
					n = nl.length;
					if (n == 1 && (nl[0].nodeType == document.TEXT_NODE  || nl[0].nodeType == document.CDATA_SECTION_NODE)) {
						try {																					// try to decode URI
							return document.createTextNode(decodeURI(sz.replace(/&#13;&#10;/gi, '\r\n')));		// and insert as normal
						}																						// text if decoding
						catch (e) {																				// fails.
							return document.createTextNode(sz.replace(/&#13;&#10;/gi, '\r\n'));
						}
					}

					if (n >= 1) {
						for (var i = 0; i < n; i++) {
							f.appendChild(importNodeFromXML(nl[i], recursive, disableOutputEscaping));
						}
					}

					return f;
			}
		}

		this.loadXML = function (myMethod, myStringOrURI, executeAsync, myCallback, mySendMethod, myParameter)
		{
		 var xc;	// xml cache
		 var xr;	// xml request
		 var ca;	// callback attached?
		 var dr;	// data return
		 var i;

			WebModel.Diagnostics.Console.info('Loading XML: ' + myStringOrURI);

			if (myMethod == HelperClass.XmlLoadMethods.URI &&				// is request cached?
				myStringOrURI.indexOf('data:text/xml') < 0)					// yeah! >> return from
			{																// cache!
				xr = _xc[myStringOrURI];
				if (xr) {
					WebModel.Diagnostics.Console.info('Returning cached XML: ' + myStringOrURI);
					if (myCallback) {
						myCallback(xr);
					}
					return xr;
				} else {
					xr = null;
				}
			}

			dr = function(myResponse)
			{
			 var b;

				b = (myMethod == HelperClass.XmlLoadMethods.URI);
				b &= (myStringOrURI.indexOf('data:text/xml') < 0);

				myResponse = myResponse.responseXML != undefined ? myResponse.responseXML : myResponse;

				if (b && !myResponse.documentURI && myResponse.URL) {													// fix response for
					myResponse.documentURI = myResponse.URL + myStringOrURI;											// edge browser.
				}

				try { myResponse.originalURI = myStringOrURI; }															// try to circumvent edge
				catch (e) { }																							// compat with own buffer.

				if (b) {
					_xc.add(myResponse, myStringOrURI);
				}

				if (executeAsync) {
					myCallback(myResponse);
				} else {
					return myResponse;
				}
			}

			if (myMethod == undefined || !(myMethod == HelperClass.XmlLoadMethods.String | myMethod == HelperClass.XmlLoadMethods.URI)) {
				throw 'myMethod must be type of ViCon.ViFlow.WebModel.Common.Helper.XmlLoadMethods!';
			}

			if (!myStringOrURI || !(typeof myStringOrURI == 'string')) {
				throw 'myStringOrURI must not be null and type of String!';
			}

			switch (myMethod) {
				case HelperClass.XmlLoadMethods.URI:
					if (executeAsync == undefined) {
						executeAsync = true;
					}

					if (executeAsync && !myCallback) {
						throw 'myCallback must not be null while using URI method for aynchronous loading XML!';
					}

					if (!xr) {																							// let's create IE v6 local parser.
						try { xr = new ActiveXObject('Msxml2.FreeThreadedDOMDocument.6.0'); }
						catch (e) {}
					}

					if (!xr) {																							// let's create IE v3 local parser.
						try { xr = new ActiveXObject('Msxml2.FreeThreadedDOMDocument.3.0'); }
						catch (e) {}
					}

					if (!xr) {																							// let's create IE web parser.
						try { new ActiveXObject('Microsoft.XMLHTTP'); }
						catch (e) {}
					}

					if (!xr) {																							// let's create cross-browser parser.
						try { xr = new XMLHttpRequest(); }
						catch (e) {}
					}

					if (!xr) {																							// fail if no parser is there!
						throw 'Could not create XMLHttpRequest!';
					}

					ca = true;
					switch (xr.open) {
						case undefined:																					// we're using local parser.
							ca = false;
							xr.async = executeAsync;
							if (executeAsync) {
								try {																					// try to attach async callback 1.
									xr.onload = function () {
										dr(xr);
									}
									ca = true;
								}
								catch (e) {}

								try {																					// try to attach async callback 2.
									xr.onreadystatechange = function () {
										if (xr.readyState != 4)
											return;
										if (xr.status != undefined && xr.status != 200 && xr.status != 0)
											return;
										dr(xr);
									}
									ca = true;
								}
								catch (e) {}

								if (!ca) {
									xr.async = false;
								}
							}

							if (!xr.load(myStringOrURI)) {																// successfully loaded requested resource?
								throw 'Could not load XML file!';														// no! >> fail!
							}

							break;

						default:																						// we're using remote parser.
							xr.open(mySendMethod || 'GET', myStringOrURI, executeAsync);								// open it with required method.
							if (mySendMethod == 'POST')																	// POST command?
								xr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');				// yeah! >> let´'s set content parm.
							xr.onreadystatechange = function () {														// let's create async handler.
								if (xr.readyState != 4)
									return;
								if (xr.status != undefined && xr.status != 200 && xr.status != 0)
									return;
								if (executeAsync) {																		// only process while async as
									dr(xr);																				// some browsers always execute.
								}
							}

							i = myStringOrURI.toLowerCase().indexOf('.xslt');											// are we loading xslt file?
							if (i >= 0 && (myStringOrURI.length - 5) == i) {												// yeah! >> ensure correct
								xr.overrideMimeType('text/xml');														// MIME type...
							}

							xr.send(myParameter);																		// finally send the request.
							ca = executeAsync;
							break;
					}

					return (!ca ? dr(xr) : null);

				default:
					if (executeAsync)
						throw 'executeAsync must be null while using String method for loading XML!';
					
					if (myCallback != undefined)
						throw 'myCallback must be null while using String method for loading XML!';

					if (mySendMethod)
						throw 'mySendMethod must be null while using String method for loading XML!';

					if (myParameter)
						throw 'myParameter must be null while using String method for loading XML!';

					if (!xr) {																							// let's create IE v6 local parser.
						try { xr = new ActiveXObject('Msxml2.FreeThreadedDOMDocument.6.0'); }
						catch (e) {}
					}
					if (!xr) {																							// let's create IE v3 local parser.
						try { xr = new ActiveXObject('Msxml2.FreeThreadedDOMDocument.3.0'); }
						catch (e) {}
					}
					if (!xr) {																							// let's create cross-browser parser.
						try { xr = new DOMParser(); }
						catch (e) {}
					}
					if (!xr)																							// fail if no parser is there!
						throw 'Could not create DOMParser!';
					
					try { return xr.parseFromString(myStringOrURI, 'text/xml'); }
					catch (e) {}
					try {
						xr.async = false;
						if (xr.loadXML(myStringOrURI)) {
							return xr;
						}
					}
					catch (e) {}
					try {
						return this.loadXML(HelperClass.XmlLoadMethods.URI, 'data:text/xml;charset=utf-8,' + encodeURIComponent(myStringOrURI), false);
					}
					catch (e) {}

					throw 'Could not parse XML!';
			}
		}

		this.transformXML = function (myXML, myXSLT, myParameterList)
		{
		 var xslt;
		 var out;
		 var p;
		 var k;
		 var r;
		 var u;
		 var s;
		 var n;

			if (!myXML)
				throw 'myXML must not be null!';

			if (!myXSLT)
				throw 'myXSLT must not be null!';

			if (WebModel.Settings) {
				u = myXSLT.originalURI || myXSLT.documentURI || myXSLT.url;																	// let's try to get pre-cahced
				if (u.indexOf(document.URL) >= 0) {																		// xml to get out more performance,
					u = document.URL;																					// fixing it's base uri.
					n = u.lastIndexOf('/');
					u = u.substr(0, ++n);
					u = (myXSLT.originalURI || myXSLT.documentURI || myXSLT.url).replace(document.URL, u);
					u = u.replace('file://', '');
				}

				s = /(.*?)\/(xslt)\/(.*?)\.xslt(.*?)/gim;
				r = s.exec(u);
				u = r[1] + '/cache/' + r[3];
				try {
					out = this.loadXML(HelperClass.XmlLoadMethods.URI, u + '.xml', false);
					if (!(out.status != undefined && out.status != 200 && out.status != 0)) {
						return out;
					}
				}
				catch (e) { }

				try {
					out = this.loadXML(HelperClass.XmlLoadMethods.URI, u + '_' + WebModel.Settings.LanguageContent.toLowerCase() + '.xml', false);
					if (!(out.status != undefined && out.status != 200 && out.status != 0)) {
						return out;
					}
				}
				catch (e) { }
			}

			switch (true) {
				case window.XSLTProcessor != undefined:																	// transform the normal way!
					if ((/WebKit/.test(navigator.userAgent))) {
						r = performFixWebKitXSLT(myXML, myXSLT);
					} else {
						r = { XML: null, XSLT: null };
					}
					try {
						p = new XSLTProcessor();
						p.importStylesheet(r.XSLT ? r.XSLT : myXSLT);
						if (myParameterList)
							for (k in myParameterList)
								try { p.setParameter(null, k, myParameterList[k]); }
								catch (e) {}
						out = p.transformToDocument(r.XML ? r.XML : myXML, document);
					}
					catch (e) {
						throw 'Could not perform XSLT transformation!';
					}
					break;

				case (window.ActiveXObject != undefined || "ActiveXObject" in window):									// transform the IE way!
					try { xslt = new ActiveXObject('Msxml2.XSLTemplate'); }
					catch (e) {}

					if (!out) {																							// let's create IE v6 local parser.
						try { out = new ActiveXObject('Msxml2.FreeThreadedDOMDocument.6.0'); }
						catch (e) {}
					}
					if (!out) {																							// let's create IE v3 local parser.
						try { out = new ActiveXObject('Msxml2.FreeThreadedDOMDocument.3.0'); }
						catch (e) {}
					}
					try { myXSLT.setProperty('AllowDocumentFunction', true); }											// let's try to allow document function
					catch (e) {}																						// if needed.
					try { myXSLT.setProperty('AllowXsltScript', true); }												// let's try to allow xslt script if
					catch (e) {}																						// needed.
					try { myXSLT.setProperty('ResolveExternals', true); }												// let's try to allow resolving external
					catch (e) {}																						// documents.

					try {																								// let's try to parse in all parameters
						if (myParameterList) {																			// we got the MSXMLDom way.
							myXSLT.setProperty('SelectionNamespaces', 'xmlns:xsl="http://www.w3.org/1999/XSL/Transform"');
							for (k in myParameterList) {
								p = null;
								p = myXSLT.selectSingleNode('//xsl:param[@name="' + k + '"]/text()');
								if (!p) {
									p = myXSLT.selectSingleNode('//xsl:param[@name="' + k + '"]');
									if (p != null)
										p = p.appendChild(myXSLT.createTextNode(''));
								}
								if (p != null)
									p.nodeValue = myParameterList[k];
							}
						}
					}
					catch (e) {}

					try { myXML.transformNodeToObject(myXSLT, out); }													// finally try to transform the document.
					catch (e) {
						try {
							out.loadXML(myXSLT.xml);
							xslt.stylesheet = out;
							p = xslt.createProcessor();
							p.input = myXML;
							if (myParameterList)
								for (k in myParameterList)
									try { p.addParameter(k, myParameterList[k]); }
									catch (e) {}
							p.transform();
							out = p.output;
						}
						catch (e) { throw 'Could not perform XSLT transformation!'; }
					}
					break;

				default:																								// transform the proxy way!
					throw 'Could not perform XSLT transformation!';
			}

			return out;
		}

		this.performAsyncTransform = function (myUriXML, myUriXSLT, myCallback, myParameterListXSLT, myParameterListCallback)
		{
		 var d;

			if (!(typeof myUriXML === 'string')) {
				throw 'myUriXML must be typeof string!';
			}

			if (!(typeof myUriXSLT === 'string')) {
				throw 'myUriXSLT must be typeof string!';
			}

			if (!(typeof myCallback === 'function')) {
				throw 'myCallback must be typeof function!';
			}

			d = { XML: myUriXML, XSLT: myUriXSLT, Result: null };
			_hp.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, d.XML, true, OnHandleLoadedXML);

			function OnHandleLoadedXML(myResult)
			{
				d.XML = myResult;
				_hp.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, d.XSLT, true, OnHandleLoadedXSLT);
			}

			function OnHandleLoadedXSLT(myResult)
			{
				d.XSLT = myResult;
				window.setTimeout(OnHandleTransform, 10);
			}

			function OnHandleTransform()
			{
				d.Result = _hp.transformXML(d.XML, d.XSLT, myParameterListXSLT);
				myCallback(d.Result, myParameterListCallback);
			}
		}

		this.appendXML = function (myXML, myElement)
		{
		 var xslt = '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:output method="html" /><xsl:template match="*"><xsl:copy-of select="." /></xsl:template></xsl:stylesheet>';
		 var xd;
 
			xd = this.loadXML(HelperClass.XmlLoadMethods.String,
							  function (myXSLT)
							  {
							   var out;

								out = WebModel.Common.Helper.transformXML(myXML, myXSLT);
								if (window.ActiveXObject || "ActiveXObject" in window)
									myElement.innerHTML = out;
								else
									myElement.appendChild(out);
							  },
							  xslt);
		}

		this.getStringFromXml = function (myXML)
		{
			if (!myXML)
				throw 'myXML must not be null!';

			try { return new XMLSerializer().serializeToString(myXML); }
			catch (e) {}
			try { return myXML.xml; }
			catch (e) {}
			
			throw 'No way there to serialize XML to string!';
		}

		this.getXmlFromString = function (myString)
		{
			if (!myString)
				throw 'myString must not be null!';

			return this.loadXML(HelperClass.XmlLoadMethods.String, myString, false);
		}

		this.selectNodes = function (myXML, myXPath)
		{
		 var e;		// xpath evaluator
		 var r;		// namespace resolver
		 var i;		// item
		 var l;		// list

			try { myXML.setProperty('SelectionLanguage', 'XPath'); }													// use XPath in IE!
			catch (ex) {}

			try { return myXML.selectNodes(myXPath); }																	// evaluate IE-style
			catch (ex) {}

			try {																										// evaluate standards-style
				e = myXML.ownerDocument
				if (!e)
					e = myXML;
				r = e.createNSResolver(myXML.ownerDocument == null ? myXML.documentElement : myXML.ownerDocument.documentElement);
				r = e.evaluate(myXPath, myXML, r, 0, null);
				l = [];
				while (i = r.iterateNext())
					l.push(i);
				return l;
			}
			catch (ex) {}

			throw 'Could not evaluate XPath expression!';
		}

		this.selectSingleNode = function (myXML, myXPath)
		{
			var l = this.selectNodes(myXML, myXPath)
			if (!l || l.length < 1)
				return null;
			return l[0];
		}

		//// ~~~~ private functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		function performFixWebKitXSLT(myXML, myXSLT)
		{
		 var wlm;
		 var wmh;
		 var out;
		 var xd;	// temporary document
		 var dn;	// destination node
		 var sn;	// source node
		 var nl;	// node list
		 var sr;	// serializer
		 var sz;	// string
		 var pi;	// processed items
		 var ay;	// array	
		 var s;		// search
		 var r;		// result
		 var u;		// uri
		 var k;		// key
		 var i;
		 var n;

			wlm = WebModel.Common.HelperClass.XmlLoadMethods;
			wmh = WebModel.Common.Helper;

			out = { XML: null, XSLT: null };

			out.XML = myXML.implementation.createDocument(myXML.namespaceURI, null, null);
			out.XML.appendChild(out.XML.importNode(myXML.documentElement, true));

			out.XSLT = myXSLT.implementation.createDocument(myXSLT.namespaceURI, null, null);
			out.XSLT.appendChild(out.XSLT.importNode(myXSLT.documentElement, true));

			sr = new XMLSerializer();
			if (!sr)
				throw 'Could not create XMLSerializer!';

			sz = sr.serializeToString(myXSLT);

			s = /\<xsl\:include href="(.*?)".*?\/\>/gim;																	// let's match all xsl:include calls.
			while(r = s.exec(sz)) {																							// iterate each xsl:include call.
				u = myXSLT.originalURI || myXSLT.documentURI || myXSLT.url;																		// let's buffer xslt's originating
				if (u.indexOf(document.URL) >= 0) {																			// path and fix it's base uri.
					u = document.URL;
					n = u.lastIndexOf('/');
					u = u.substr(0, ++n);
					u = (myXSLT.originalURI || myXSLT.documentURI || myXSLT.url).replace(document.URL, u);
                    u = u.replace('file://', '');
				}

				n = u.lastIndexOf('/');																						
				u = u.substr(0, ++n);

				sz = sz.replace(r[0], '');																					// nullify that call.
				out.XSLT = wmh.loadXML(wlm.String, sz, false);																// compile current xslt string to
																															// a valid document and load xslt
				xd = wmh.loadXML(wlm.URI, u + r[1], false);																	// that should be included.

				ay = new Array('param', 'key', 'variable', 'template', 'include',
							   'xsl:param', 'xsl:key', 'xsl:variable', 'xsl:template', 'xsl:include');						// we iterate each tag name to import
				for (i = 0; i < ay.length; i++) {																			// getting its elements.
					nl = xd.firstChild.getElementsByTagName(ay[i]);															// let's iterate each found element.
					for (var j = 0; j < nl.length; j++) {																	
						sn = nl[j];																							// first-level element?
						if (sn.parentNode == xd.firstChild) {																// yeah! >> let's import it to our
							dn = out.XSLT.importNode(sn, true);																// XSLT!
							out.XSLT.firstChild.appendChild(dn);															
						}
					}
				}

				sz = sr.serializeToString(out.XSLT);																		// re-serialize our xslt to string again.
				s = /\<xsl\:include href="(.*?)".*?\/\>/gim;																// let's re-match all xsl:include calls.
			}

			s = /document\('(.*?)'\)/gim;																					// let's match all document() calls.
			while(r = s.exec(sz)) {																							// yeah! >> we iterate each match and
				u = myXSLT.originalURI || myXSLT.documentURI || myXSLT.url;																		// build uri of document to include in
				if (u.indexOf(document.URL) >= 0) {																			// our source xml file, fixing it's base uri.
					u = document.URL;
					n = u.lastIndexOf('/');
					u = u.substr(0, ++n);
					u = (myXSLT.originalURI || myXSLT.documentURI || myXSLT.url).replace(document.URL, u);
                    u = u.replace('file://', '');
				}

				n = u.lastIndexOf('/');
				u = u.substr(0, ++n);

				k = r[1].replace(/\//gi, '_').replace(/\./gi, '_');
				if (!wmh.selectSingleNode(out.XML, 'data' + k)) {
					xd = wmh.loadXML(wlm.URI, u + r[1], false);																// let's load the include file and
					xn = out.XML.createElement('data' + k);																	// append a data[i] section to our
					out.XML.lastChild.appendChild(xn);																		// originating xml file, containing
					sn = out.XML.importNode(xd.documentElement, true);														// whole included xml document data.
					xn.appendChild(sn);
				}

				u = '/';																									// let's build up xpath selector
				u += out.XML.firstChild.nodeName + '/';																		// representing that data[i] section
				u += 'data' + k;																							// and replace related document() call.

				sz = sz.replace(r[0], u);
				s = /document\('(.*?)'\)/gim;																				// let's re-match all document() calls.
			}

			out.XSLT = wmh.loadXML(wlm.String, sz, false);																	// finally re-build xslt document...

			WebModel.Diagnostics.Console.log('Fixed XSLT for Webkit to work. New source looks like\r\n\r\n' + 
											 wmh.getStringFromXml(out.XML) +
											 '\r\n\r\nNew transform looks like\r\n\r\n' +
											 wmh.getStringFromXml(out.XSLT));

			return out;																										// ...and return fixed xml and xslt docs.
		}
	}
	HelperClass.XmlLoadMethods = { String: 0, URI: 1 };																		// static!
	///
	/// End :: Helper Class
	///
}
///
/// End :: Common Class
///