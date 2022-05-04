// -----------------------------------------------------------------------
// <copyright file="ViCon.ViFlow.WebModel.Drawing.js" company="ViCon GmbH">
//     Copyright © ViCon GmbH.
// </copyright>
// <summary>
//		This file provides all functionality for displaying and interacting
//		with SVG process drawings, like navigation and zoom.
// </summary>
// <remarks>
//		This file relies on:
//		====================
//		~ ViCon.ViFlow.WebModel.js
//		~ ViCon.ViFlow.WebModel.Common.js
//		~ ViCon.ViFlow.WebModel.Diagnostics.js
//		~ ViCon.ViFlow.WebModel.Search.js
//		~ ViCon.ViFlow.WebModel.Settings.js
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
/// This class provides all functionality
/// for displaying and interacting with SVG
/// process drawings, like navigation and
/// zoom.
/// </summary>
function DrawingClass(myElement)
{
	//// ~~~~ constants ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var CURSOR_PIXELS = 0x5;
	var PIXEL_FIX = 0x2;
	var UUID_FIELD = 'VIFLOW__Verwendungsdaten__UniqueID';
	var NAME_FIELD = 'Shapename';
	var NAMES_FIELD = 'VIFLOW__Stammdaten__Bezeichnung_A';
	var NAMEL_FIELD = 'VIFLOW__Stammdaten__Beschreibung';
	var UUID_EMPTY = '{00000000-0000-0000-0000-000000000000}';
	var IMAGE_BASE = './images/content/';
	var BLINK_MAX = 0x32;
	var BLINK_TIMEOUT = 0x64;
	var BLINK_OPACITY = 0.25;

	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _tmr;		// timer
	var _gid;		// graphic id
	var _gpi;		// graphic page index
	var _gpl;		// graphic language
	var _hp;		// helper
	var _st;		// settings
	var _zb;		// zoom buttons
	var _zg;		// zoom graphic
	var _ze;		// zoom eventing object
	var _zr;		// zoom rectangle
	var _go;		// graphic object
	var _mi;		// marker ids
	var _ms;		// marked shapes
	var _hs;		// highlight search?
	var _vp;		// view port
	var _sf;		// start factor
	var _pl;		// page loader
	var _ed;		// exclusion data
	var _f;			// factor
	var _dp;		// do not use document.PointerEvent

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "GraphicID", { get: function () { return _gid; } });
	Object.defineProperty(this, "PageIndex", { get: function () { return _gpi; } });
	Object.defineProperty(this, "Zoom", { get: function () { return _f; } });
	Object.defineProperty(this, "GraphicAspect", { get: function () { return _self.SVGDocument.documentElement.viewBox.animVal.width / _self.SVGDocument.documentElement.viewBox.animVal.height; } });
	Object.defineProperty(this, "ViewPortAspect", { get: function () { return _vp.clientWidth / _vp.clientHeight; } });
	Object.defineProperty(this, "InteractionEnabled", {
		get: function () {
			return !document.getElementById('GraphicLock');
		}, 
		set: function (myValue)
		{
		 var gl;

			gl = document.getElementById('GraphicLock');
			switch (!myValue && gl == undefined) {
				case true:
					gl = document.createElement('div');
					gl.setAttribute('id', 'GraphicLock');
					gl.setAttribute('style', 'position: absolute; width: 100%; height: 100%');
					_vp.parentNode.appendChild(gl);
					break;

				default:
					if (gl) {
						gl.parentNode.removeChild(gl);
					}
					break;
			}
		}
	});
	Object.defineProperty(this, "SVGDocument", {
		get: function ()
		{
			try {
				return WebModel.UI.DrawingArea.Element.contentDocument ? WebModel.UI.DrawingArea.Element.contentDocument : WebModel.UI.DrawingArea.Element.getSVGDocument();
			}
			catch (e) {
				return null;
			}
		}
	});
	Object.defineProperty(this, "SVGDocumentZoom", { get: function () { return _zg.firstChild.contentDocument ? _zg.firstChild.contentDocument : _zg.firstChild.getSVGDocument(); } });
	Object.defineProperty(this, "SVGWindow", {
		get: function () {
			if (_self.SVGDocument && _self.SVGDocument.defaultView)
				return this.SVGDocument.defaultView;
			else if (WebModel.UI.DrawingArea.Element.window)
				return WebModel.UI.DrawingArea.Element.window;
			else
				return WebModel.UI.DrawingArea.Element.getWindow();
		}
	});
	Object.defineProperty(this, "SVGWindowZoom", {
		get: function () {
			if (_self.SVGDocumentZoom && _self.SVGDocumentZoom.defaultView)
				return this.SVGDocumentZoom.defaultView;
			else if (_zg.firstChild.window)
				return _zg.firstChild.window;
			else
				return _zg.firstChild.getWindow();
		}
	});

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	{
		_self = this;
		_self.extendAsEventDispatcher(); 																		// let's extend as dispatcher.

		_hp = WebModel.Common.Helper;																			// buffer helper for performance!
		_st = WebModel.Settings;																				// buffer settings form performance!

		_pl = document.createElement('img');																	// create page loader element for
		_pl.addEventListener('load', OnAdditionalPageDetection, false);											// recognizing additional pages.

		WebModel.UI.addEventListener('mainwindowresized', OnMainWindowResized, true);							// let's attach to general UI events.
		WebModel.UI.Windows['objectNav'].addEventListener('windowstatechanged', OnNavWindowResized, true);

 		WebModel.UI.DrawingArea.addEventListener('load', OnLoad, false);										// let's attach to drawing area
		WebModel.UI.DrawingArea.Element.parentElement.addEventListener('click', OnPreventNavigation, false);	// events.
		WebModel.UI.DrawingArea.Element.parentElement.addEventListener('mousedown', OnMouseDown, false);		
		WebModel.UI.DrawingArea.Element.parentElement.addEventListener('mousemove', OnMouseMove, false);
		WebModel.UI.DrawingArea.Element.parentElement.addEventListener('mouseup', OnMouseUp, false);
		WebModel.UI.DrawingArea.Element.parentElement.addEventListener('mousewheel', OnMouseWheel, false);
		WebModel.UI.DrawingArea.Element.parentElement.addEventListener('DOMMouseScroll', OnMouseWheel, false);
		WebModel.UI.DrawingArea.Element.parentElement.addEventListener('scroll', OnScroll, false);
		WebModel.UI.DrawingArea.Element.parentElement.addEventListener('touchstart', OnTouchStart, false);
		WebModel.UI.DrawingArea.Element.parentElement.addEventListener('touchmove', OnTouchMove, false);
		WebModel.UI.DrawingArea.Element.parentElement.addEventListener('touchend', OnTouchEnd, false);
		WebModel.UI.DrawingArea.Element.parentElement.addEventListener('gesturestart', OnGestureStart, false);
		WebModel.UI.DrawingArea.Element.parentElement.addEventListener('gesturechange', OnGestureChange, false);
		Object.addMSGestureEventListener(WebModel.UI.DrawingArea.Element.parentElement, 'MSGestureStart', OnGestureStart, false);
		Object.addMSGestureEventListener(WebModel.UI.DrawingArea.Element.parentElement, 'MSGestureChange', OnGestureChange, false);

		_zg = document.getElementById('zoomGraphic')
		if (!_zg)
			throw 'Could not locate zoom graphic!';

		_ze = document.getElementById('zoomEvents')
		if (!_ze)
			throw 'Could not locate zoom events object!';
		_ze.addEventListener('mousedown', OnZoomMouseDown, false);												// let's attach to zoom event
		_ze.addEventListener('mousemove', OnZoomMouseMove, false);												// object events.
		_ze.addEventListener('mouseup', OnZoomMouseUp, false);
		_ze.addEventListener('mouseout', OnZoomMouseOut, false);
		_ze.addEventListener('touchstart', OnZoomTouchStart, false);
		_ze.addEventListener('touchmove', OnZoomTouchMove, false);
		_ze.addEventListener('touchend', OnZoomTouchEnd, false);

		_zr = document.getElementById('zoomRectangle')
		if (!_zr)
			throw 'Could not locate zoom rectangle!';
		_zr.addEventListener('mousedown', OnZoomMouseDown, false);												// let's attach to zoom rect
		_zr.addEventListener('mousemove', OnZoomMouseMove, false);												// object events.
		_zr.addEventListener('mouseup', OnZoomMouseUp, false);
		_zr.addEventListener('mouseout', OnZoomMouseOut, false);
		_zr.addEventListener('touchstart', OnZoomTouchStart, false);
		_zr.addEventListener('touchmove', OnZoomTouchMove, false);
		_zr.addEventListener('touchend', OnZoomTouchEnd, false);

		_zb = document.getElementById('zoomFunctions');															// let's attach event handlers
		if (!_zb)																								// to all zoom buttons within
			throw 'Could not locate zoom buttons!';																// the zoom box.
		_zb = _zb.getElementsByTagName('li');
		for (i = 0; i < _zb.length; i++)
			_zb[i].addEventListener('click', OnZoomButtonClick, false);

		_dp = /\b(iPad|iPhone|iPod|)\b/.test(navigator.userAgent);
		if (!_dp){																								// iPads aren't recognized by userAgent property
			_dp = /\b(Mac.*)\b/.test(navigator.platform);														// platform used instead. (MacIntel, Macintosh, MacPPC, Mac68K)
		}
		if (_dp) {
			_dp = /Version\/(\d+)/.exec(navigator.userAgent);													// SAFARI 13 supports window.PointerEvent now, but the implementation differs
			_dp = _dp ? _dp[1] >= 13 : false;																	// with the iexplore one. Disable it for safari
		}
	}

	//// ~~~~ event handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function OnAdditionalPageDetection(myEvent)
	{
	 var ts;	// tab strip
	 var xd;	// xml document
	 var m;
	 var i;

		ts = WebModel.UI.TabStrips['pagetabs'];
		if (!ts) {
			throw 'Could not locate page tabs strip!';
		}

		if (myEvent == true) {
			ts.Visible = false;
			ts.clearTabs();

			_vp.style.bottom = 0;
			_pl.setAttribute('src', IMAGE_BASE + _gid + '_2.svg');
		} else {
			myEvent = myEvent || event;

			if (!(m = (/^.*_([0-9]+)\.svg/gi).exec(_pl.getAttribute('src'))) || m.length != 2 || parseInt(m[1]) == NaN) {
				throw 'Failed to parse page index!';
			}

			if (!ts.Visible) {
				ts.Visible = true;
				ts.addTab(WebModel.UI.Translations.getTranslation('webmodel.ui.pagecaption', 'Page {0}').replace(/\{0\}/gi, 1), _gpi == 1);

				OnMainWindowResized();																		// ensure correct layout!
			}

			i = parseInt(m[1]);
			ts.addTab(WebModel.UI.Translations.getTranslation('webmodel.ui.pagecaption', 'Page {0}').replace(/\{0\}/gi, i), _gpi == i++);

			_pl.setAttribute('src', IMAGE_BASE + _gid + '_' + i + '.svg');

			WebModel.Common.Helper.cancelEvent(myEvent, false);
		}
	}
	
	function OnPreventNavigation(myEvent)
	{
		myEvent = myEvent || event;
		WebModel.Common.Helper.cancelEvent(myEvent, false);													// prevent navigation only!
	}

	function OnMainWindowResized(myEvent)
	{
		_self.zoom(_f);
	}

	function OnNavWindowResized(myEvent)
	{
		myEvent = myEvent || event;

		_vp.style.left = myEvent.detail.Position.Width + 'px';
		_self.zoom(_f);
	}

	function OnLoad(myEvent, refreshZoomOnly)
	{
	 var xslt;
	 var svg;
	 var le;

		if (_self.SVGDocument == null) {
			if (_gpl == 'A') {
				throw 'Cannot find graphic to load - giving up!';
			}
			_self.load(_self.GraphicID, _self.PageIndex, undefined, true);
			return;
		}

		while (_zg.firstChild.nodeType == 3) {																// first, we remove text nodes
			_zg.removeChild(_zg.firstChild);																// if available.
		}

		svg = (_zg.firstChild != _ze ? _zg.firstChild : WebModel.UI.DrawingArea.Element).cloneNode();		// now we ensure loading a
		svg.id = 'svgport_zoom';																			// graphic duplicate to our
		svg.src = WebModel.UI.DrawingArea.Element.src;														// zoom area.
		svg.addEventListener('load', OnZoomLoad, false);
		if (_zg.firstChild == _ze) {
			_zg.insertBefore(svg, _zg.firstChild);
		} else {
			_zg.replaceChild(svg, _zg.firstChild);
		}

		if (refreshZoomOnly) {																				// refresh zoom only?
			return;																							// yeah! >> leave!
		}

		if (!myEvent) {
			myEvent = event;
		}

		clearTooltips(_self.SVGDocument.documentElement);
		prepareShapes(_self.SVGDocument.documentElement);

		_self.SVGDocument.documentElement.setAttribute('overflow', 'scroll');								// format graphic holder
		_self.SVGDocument.documentElement.setAttribute('width', '100%');									// to fit correctly and
		_self.SVGDocument.documentElement.setAttribute('height', '100%');									// attach required events.
		_self.SVGWindow.addEventListener('click', OnPreventNavigation, false);
		_self.SVGWindow.addEventListener('mousedown', OnMouseDown, false);
		_self.SVGWindow.addEventListener('mousemove', OnMouseMove, false);
		_self.SVGWindow.addEventListener('mouseup', OnMouseUp, false);
		_self.SVGWindow.addEventListener('mousewheel', OnMouseWheel, false);
		_self.SVGWindow.addEventListener('DOMMouseScroll', OnMouseWheel, false);
		_self.SVGWindow.addEventListener('touchstart', OnTouchStart, false);
		_self.SVGWindow.addEventListener('touchmove', OnTouchMove, false);
		_self.SVGWindow.addEventListener('touchend', OnTouchEnd, false);
		_self.SVGDocument.documentElement.addEventListener('gesturestart', OnGestureStart, false);
		_self.SVGDocument.documentElement.addEventListener('gesturechange', OnGestureChange, false);
		Object.addMSGestureEventListener(_self.SVGDocument.documentElement, 'MSGestureStart', OnGestureStart, false);
		Object.addMSGestureEventListener(_self.SVGDocument.documentElement, 'MSGestureChange', OnGestureChange, false);

		_go = WebModel.UI.DrawingArea.Element;																// buffer graphic and viewport
		_vp = _go.parentElement;																			// for speed considerations.

		if (_hs) {
			// Code to highlight search terms will
			// be placed here when highlight function
			// is able to highlight text within svg.
		}

		_self.zoom(-1);																						// initially display whole page and

		le = document.createEvent('CustomEvent');
		le.initCustomEvent('load', true, false, _self);
		_self.dispatchEvent(le);																			// notify about loaded graphic.

		markShapes(_ms);

		OnAdditionalPageDetection(true);																	// force additional page detection.

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnZoomLoad(myEvent)
	{
     var zw, zh, zx, zy;		// zoom rect size and position
	 var gw, gh, gx, gy;		// graphic size and position
     var vw, vh, vx, vy;		// view port size and position (different contexts!)
	 var b;						// multiple usage

		_self.SVGDocumentZoom.documentElement.setAttribute('overflow', 'scroll');			// format graphic holder
		_self.SVGDocumentZoom.documentElement.setAttribute('width', '100%');				// to fit correctly.
		_self.SVGDocumentZoom.documentElement.setAttribute('height', '100%');

		zw = vw = _zg.clientWidth;															// we assume same graphic
		zh = vh = _zg.clientHeight;															// and view port size.

		zh = zw * _self.GraphicAspect;														// let's calculate graphic
		if (zh > vh) {																		// size in dependency of
			zh = vh;																		// graphic's aspect.
			zw = zh * _self.GraphicAspect;
		}
		if (zw > vw) {
			zw = vw;
			zh = zw / _self.GraphicAspect;
		}

		zx = _zg.offsetLeft + (vw / 2) - (zw / 2);											// let's calculate graphic's
		zy = _zg.offsetTop + (vh / 2) - (zh / 2);											// centered position.

		_zg.firstChild.style.width = _ze.style.width = zw + 'px';							// let's draw zoom graphic
		_zg.firstChild.style.height = _ze.style.height = zh + 'px';							// and its event div to
		_zg.firstChild.style.left = _ze.style.left = zx + 'px';								// calculated values.
		_zg.firstChild.style.top = _ze.style.top = zy + 'px';


		zx = _zg.firstChild.offsetLeft;														// finally calculate and draw
		zy = _zg.firstChild.offsetTop;														// zoom rectangle.

		vw = _vp.clientWidth;
		vh = _vp.clientHeight;
		vx = _vp.scrollLeft;
		vy = _vp.scrollTop;

		gw = _go.clientWidth;
		gh = _go.clientHeight;
		gx = _go.clientLeft;
		gy = _go.clientTop;

		_zr.style.display = _f <= 1 ? 'none' : 'inherit';
		_zr.style.width = Math.min(zw, zw * (vw / gw)) + 'px';
		_zr.style.height = Math.min(zh, zw * (vw / gw) / _self.ViewPortAspect) + 'px';
		_zr.style.left = zx + Math.max(0, (-1 * (vw / gw) * zw * ((gx - vx) / vw))) + 'px';
		_zr.style.top = zy + Math.max(0, (-1 * (vh / gh) * zh * ((gy - vy) / vh))) + 'px';
	}

	function OnScroll(myEvent)
	{
	 var vw, vh, vx, vy;	// viewport rect
	 var gw, gh, gx, gy;	// graphic rect
	 var zw, zh, zx, zy;	// zoom rect

	 	if (myEvent) {
			myEvent = myEvent || event;
		}

		if (!_vp) {
			return;
		}

		vw = _vp.clientWidth;													// let's get view port data.
		vh = _vp.clientHeight;
		vx = _vp.scrollLeft;
		vy = _vp.scrollTop;

		gw = _go.clientWidth;													// let's set graphic data.
		gh = _go.clientHeight;
		gx = _go.offsetLeft;
		gy = _go.offsetTop;

		zw = _ze.clientWidth;													// let's calculate and
		zh = _ze.clientHeight;													// draw zoom rectangle.
		zx = _ze.offsetLeft;
		zy = _ze.offsetTop;

		_zr.style.display = _f <= 1 ? 'none' : 'inherit';
		_zr.style.width = Math.min(zw, zw * (vw / gw)) + 'px';
		_zr.style.height = Math.min(zh, zw * (vw / gw) / _self.ViewPortAspect) + 'px';
		_zr.style.left = zx + Math.max(0, (-1 * (vw / gw) * zw * ((gx - vx) / vw))) + 'px';
		_zr.style.top = zy + Math.max(0, (-1 * (vh / gh) * zh * ((gy - vy) / vh))) + 'px';

		if (myEvent)
			WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnClick(myEvent, direct)
	{
	 var ll;	// link list
	 var p;		// point
	 var b;
	 var o;

		myEvent = myEvent || event;
		o = !myEvent.changedTouches ? myEvent : myEvent.changedTouches[0] || myEvent;

		var i = getShapeInfo(o.target);
		if (i) {
			b = i.MainElement &&													// process exclusion
				i.MainElement.hasAttribute('style') &&								// policy.
				i.MainElement.getAttribute('style').indexOf('not-allowed') < 0;
			b |= !i.MainElement;

			if (b) {																// navigation allowed?
				p = {																// create source point
					X: o.pageX + _vp.offsetLeft - _vp.scrollLeft + _go.offsetLeft,	// for navigation and
					Y: o.pageY + _vp.offsetTop - _vp.scrollTop + _go.offsetTop		// fetch corresponding
				};																	// links.
				ll = fetchLinks(i);
				if (ll.length == 1 && ll[0].URL == _gid) {							// only 1 link to current graphic?
					direct = true;													// yeah! >> force direct call!
				}

				WebModel.UI.performObjectNavigation(p, ll, direct);					// yeah! >> do it! :-D
			}
		}

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnDoubleClick(myEvent)
	{
		OnClick(myEvent, true);
	}

	function OnMouseDown(myEvent)
	{
     var b
	 var o;

		myEvent = myEvent || event;
		o = !myEvent.targetTouches ? myEvent : myEvent.targetTouches[0];

		b =	(																	// the following code block
				myEvent.pageX >= this.clientWidth + this.clientLeft &&			// detects event processing
				myEvent.pageX <= this.offsetWidth + this.offsetLeft				// if mouse down occurs on
			) || (																// scrollbars.
				myEvent.pageY >= this.clientHeight + this.clientTop &&
				myEvent.pageY <= this.offsetHeight + this.offsetTop
			);

		if (!_go.DragData && !b) {
			_go.DragData = {
				X: o.screenX,
				Y: o.screenY,
				Move: false,
				Zoom: _f,
				OnTouch: myEvent.targetTouches != undefined						// prevent mouse/touch coex.
			};
		}

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnMouseMove(myEvent)
	{
	 var o;
	 var i;
	 var s;

		myEvent = myEvent || event;
		o = !myEvent.targetTouches ? myEvent : myEvent.targetTouches[0];

		if (o &&
			_go &&
			_go.DragData &&
			_go.DragData.OnTouch == (myEvent.targetTouches != undefined))
		{
			_vp.scrollLeft += (_go.DragData.X - o.screenX);						// drag move:
			_vp.scrollTop += (_go.DragData.Y - o.screenY);						// perform drag action!
			_go.DragData = {
				X: o.screenX,
				Y: o.screenY,
				Move: (_go.DragData.X - o.screenX) != 0 || (_go.DragData.Y - o.screenY) != 0,
				Zoom: _go.DragData.Zoom,
				OnTouch: myEvent.targetTouches != undefined
			};
		}

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnMouseUp(myEvent)
	{
	 var n;		// now
	 var l;		// last
	 var d;		// delta
	 var b;

		myEvent = myEvent || event;
		o = !myEvent.targetTouches ? myEvent : myEvent.targetTouches[0];

		if (_go && _go.DragData) {												// did we get drag data?
			b = _go.DragData.Move || _go.DragData.Zoom != _f;					// yeah! >> buffer move and zoom
			_go.DragData = null;												// flags and pre-nullify them.

			if (!b) {															// no move flag set?
				n = new Date().getTime();										// yeah! >> get current time
				l = this.LastUp || n + 1;										// and calculate difference
				d = n - l;														// to last up-event.

				if (_tmr) {														// any timer set?
					clearTimeout(_tmr);											// yeah! >> reset it!
					_tmr = null;
				}

				if (d < 500 && d > 0) {											// last up-event within 500ms?
					OnDoubleClick(myEvent);										// yeah! >> raise double click!
				} else {														// no! >> let's trigger timered
					_tmr = setTimeout(											// click event within next 500ms.
						function (myEvent) { OnClick(myEvent) },
						500,
						myEvent
					);
				}

				this.LastUp = n;												// buffer last up-event time.
			}
		}

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnMouseWheel(myEvent)
	{
		myEvent = myEvent || event;

		switch (true) {
			case (myEvent.wheelDelta || (-1 * myEvent.detail)) > 0:
				_self.zoom('zoomPlus');
				break;
			case (myEvent.wheelDelta || (-1 * myEvent.detail)) < 0:
				_self.zoom('zoomMinus');
				break;
		}

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnGestureStart(myEvent)
	{
		_sf = _f;

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnGestureChange(myEvent)
	{
	 var b;

		b = window.PointerEvent || window.MSPointerEvent;
		myEvent = myEvent || event;

		if (myEvent.scale)
			_self.zoom(((b && !_dp) ? _f : _sf) * myEvent.scale);

		if (b && !_dp && _vp) {										// let's perform graphic
			_vp.scrollLeft -= parseInt(myEvent.translationX);		// movement manually if
			_vp.scrollTop -= parseInt(myEvent.translationY);		// we're on windows platform!
		}

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnTouchStart(myEvent)
	{
	 var t;

		myEvent = myEvent || event;
		t = myEvent.touches;
		if (t && t.length == 2) {
			_vp.pinchScale = Math.sqrt((t[0].clientX - t[1].clientX) * (t[0].clientX - t[1].clientX) + (t[0].clientY - t[1].clientY) * (t[0].clientY - t[1].clientY));
			OnGestureStart(myEvent);
		} else {
			OnMouseDown(myEvent);
		}
	}

	function OnTouchMove(myEvent)
	{
	 var t;

		myEvent = myEvent || event;
		t = myEvent.touches;
		if (t && t.length == 2) {
			myEvent.scale = Math.sqrt((t[0].clientX - t[1].clientX) * (t[0].clientX - t[1].clientX) + (t[0].clientY - t[1].clientY) * (t[0].clientY - t[1].clientY));
			myEvent.scale -= _vp.pinchScale;
			myEvent.scale /= 100;
			myEvent.scale += 1;
			WebModel.Diagnostics.Console.log(myEvent.scale);
			OnGestureChange(myEvent);
		} else {
			OnMouseMove(myEvent);
		}
	}

	function OnTouchEnd(myEvent)
	{
		OnMouseUp(myEvent);
	}

	function OnZoomButtonClick(myEvent)
	{
		if (!myEvent)
			myEvent = event;

		_self.zoom(myEvent.target || myEvent.srcElement);
		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnZoomMouseDown(myEvent)
	{
	 var p;		// point
	 var o;		// object
	 var c;		// cursor

		myEvent = myEvent || event;
		o = !myEvent.targetTouches ? myEvent : myEvent.targetTouches[0];
		c = getZoomRectCursor(myEvent);
		p = _hp.getRelativePosition(_ze, o.clientX, o.clientY);										// getting our zoom rectangle
		_zr.OnTouch = myEvent.targetTouches != undefined											// we're setting d'n'd and delta
		_zr.DeltaX = o.screenX - (p.X + _ze.offsetLeft);											// information based on mouse
		_zr.DeltaY = o.screenY - (p.Y + _ze.offsetTop);												// cursor information for being
		_zr.style.display = 'inherit';																// size and position within the
		switch (c) {																				// mouse-move event.
			case 'move':																			
				_zr.DragData = { X: 0, Y: 0 };														
				break;																				
			case 'n-resize':																		
				_zr.DragData = { X: 0, Y: _zr.offsetTop + _zr.clientHeight };						
				break;
			case 'e-resize':
				_zr.DragData = { X: _zr.offsetLeft, Y: 0 };
				break;
			case 's-resize':
				_zr.DragData = { X: 0, Y: _zr.offsetTop };
				break;
			case 'w-resize':
				_zr.DragData = { X: _zr.offsetLeft + _zr.clientWidth, Y: 0 };
				break;
			case 'ne-resize':
				_zr.DragData = { X: _zr.offsetLeft, Y: _zr.offsetTop + _zr.clientHeight };
				break;
			case 'nw-resize':
				_zr.DragData = { X: _zr.offsetLeft + _zr.clientWidth, Y: _zr.offsetTop + _zr.clientHeight };
				break;
			case 'se-resize':
				_zr.DragData = { X: _zr.offsetLeft, Y: _zr.offsetTop };
				break;
			case 'sw-resize':
				_zr.DragData = { X: _zr.offsetLeft + _zr.clientWidth, Y: _zr.offsetTop };
				break;
			default:
				_zr.style.width = '0px';															// force null-size rectangle
				_zr.style.height = '0px';															// if we're re-creating...
				_zr.DragData = { X:	p.X + _ze.offsetLeft, Y: p.Y + _ze.offsetTop };
				break;
		}

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnZoomMouseMove(myEvent)
	{
	 var sz;
	 var o;							// event object
	 var e;							// element
	 var p, a, l, r, t, b, w, h;	// position, aspect, left, right, top, bottom, width, height

		myEvent = myEvent || event;
		o = !myEvent.targetTouches ? myEvent : myEvent.targetTouches[0];
		e = document.elementFromPoint(o.pageX, o.pageY);
		p = _hp.getRelativePosition(e, o.clientX, o.clientY);

		if (!_zr.DragData) {																						// no drag box targeted?
			_zr.style.cursor = getZoomRectCursor(myEvent);															// yeah! >> let's set zoom
		}																											// rect cursor.

		if (!_zr.DragData || _zr.DragData.OnTouch == (myEvent.targetTouches != undefined)) {						// no drag data?
			WebModel.Common.Helper.cancelEvent(myEvent);															// yeah! >> let's cancel event
			return;																									// and leave immediatly!
		}

		l = _zr.DragData.X ? _zr.DragData.X : parseFloat(_zr.style.left);											// let's calculate size
		r = _zr.DragData.X ? o.screenX - _zr.DeltaX : parseFloat(_zr.style.left) + _zr.clientWidth;					// and position of our
		t = _zr.DragData.Y ? _zr.DragData.Y : parseFloat(_zr.style.top);											// rectangle. this is very
		b = _zr.DragData.Y ? o.screenY - _zr.DeltaY : parseFloat(_zr.style.top) + _zr.clientHeight;					// tricky in dependency
		w = Math.max(10, Math.abs(r - l));																			// of original mouse data
		h = Math.max(10, Math.abs(b - t));																			// according to the current.
		if (_zr.DragData.X && _zr.DragData.Y ) {																	// so step this code with
			w = (w < h * _self.ViewPortAspect) || !_zr.DragData.X ? h * _self.ViewPortAspect : w;					// your debugger of choice
			h = (h < w / _self.ViewPortAspect) || !_zr.DragData.Y ? w / _self.ViewPortAspect : h;					// to see and understand
		} else {																									// it's magic.
			w = ((w < h * _self.ViewPortAspect) || _zr.DragData.Y) && !_zr.DragData.X ? h * _self.ViewPortAspect : w;
			h = ((h < w / _self.ViewPortAspect) || _zr.DragData.X) && !_zr.DragData.Y ? w / _self.ViewPortAspect : h;
		}
		l = !_zr.DragData.X ?																						
			l -= (w - _zr.clientWidth) / 2 :																		
			l < r ? Math.min(l, r) : l - w;
		t = !_zr.DragData.Y ?
			t -= (h - _zr.clientHeight) / 2 :
			t < b ? Math.min(t, b) : t - h;

		if (!_zr.DragData.Move)																						// if we are on move op
			_zr.DragData.Move = { X: o.screenX, Y: o.screenY };														// we attach an additional
		else {																										// point object to d'n'd data
			l -= !_zr.DragData.X && _zr.DragData.Y ? 0 : _zr.DragData.Move.X - o.screenX;							// and correct the rectangle's
			t -= !_zr.DragData.Y && _zr.DragData.X ? 0 : _zr.DragData.Move.Y - o.screenY;							// position. this object will
			_zr.DragData.Move = { X: o.screenX, Y: o.screenY };														// be nullified on mouse-up!
		}

		w = Math.min(w, _ze.clientWidth);																			// let's finally ensure our
		h = Math.min(h, _ze.clientHeight);																			// rectangle bounds are within
		l = Math.max(l, _ze.offsetLeft);																			// the bounds of our zoom
		l = Math.min(l, _ze.offsetLeft + _ze.clientWidth - w);														// graphic and got a minimum
		t = Math.max(t, _ze.offsetTop);																				// size.
		t = Math.min(t, _ze.offsetTop + _ze.clientHeight - h);

		_zr.style.left = l + 'px';
		_zr.style.top = t + 'px';
		_zr.style.width = w + 'px';
		_zr.style.height = h + 'px';

		if (!_zr.DragData.X && !_zr.DragData.Y)																		// if we're moving the rect
			OnZoomMouseUp(myEvent, true);																			// we live-update graphic.

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnZoomMouseUp(myEvent, liveDrag)
	{
	 var z, x, y;		// zoom, x-scoll, y-scroll
	 var o;

		myEvent = myEvent || event;
		o = !myEvent.targetTouches ? myEvent : myEvent.targetTouches[0];

		if (_zr.DragData && _zr.DragData.Move) {
			z = _ze.clientWidth / _zr.clientWidth > _ze.clientHeight / _zr.clientHeight ?							// calculate zoom factor
				_ze.clientWidth / _zr.clientWidth :																	// and scroll positions.
				_ze.clientHeight / _zr.clientHeight;
			x = (_ze.clientWidth / _zr.clientWidth) * _vp.clientWidth * ((_zr.offsetLeft - _ze.offsetLeft) / _ze.clientWidth);
			y = (_ze.clientHeight / _zr.clientHeight) * _vp.clientHeight * ((_zr.offsetTop - _ze.offsetTop) / _ze.clientHeight);
			_self.zoom(z, x, y);																					// set zoom & position!

			if (!liveDrag) {
				_zr.style.display = z <= 1 ? 'none' : 'inherit';													// show / hide zoom rect.
				_zr.DragData = null;																				// clear current d'n'd record!
			}
		} else {																									// no move?
			_self.zoom(_f);																							// yeah! >> ensure drawing
			_zr.DragData = null;																					// rectangle and clear d'n'd!
		}
		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnZoomMouseOut(myEvent)
	{
		myEvent = myEvent || event;

		if (_zr.DragData &&																							// do we've d'n'd data
			myEvent.relatedTarget != _zr &&																			// and not on zoom box
			myEvent.relatedTarget != _ze)																			// or graphic?
		{ OnZoomMouseUp(myEvent); }																					// yeah! >> trigger mouseup! 

		WebModel.Common.Helper.cancelEvent(myEvent);
	}

	function OnZoomTouchStart(myEvent)
	{
		OnZoomMouseDown(myEvent);
	}

	function OnZoomTouchMove(myEvent)
	{
		OnZoomMouseMove(myEvent);
	}

	function OnZoomTouchEnd(myEvent)
	{
		OnZoomMouseUp(myEvent);
	}

	//// ~~~~ public functions  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.load = function (myGraphicID, myPageIndex, highlightSearch, forceDefaultLanguage, markShapeID)
	{
	 var tv;		// tree view
	 var n;			// node(s)

		if (!myGraphicID) {
			throw 'myGraphicID must not be null!';
		}

		if (!myPageIndex) {
			myPageIndex = 1;
		}

		_f = -1;																							// reset all buffers first!
		_go = null;
		_vp = null;
		_ms = new Array();
		_hs = highlightSearch;
		_mi = markShapeID ? markShapeID.split(';') : undefined; 
		_gid = myGraphicID;
		_gpi = myPageIndex;
		_gpl = forceDefaultLanguage ? 'A' : _st.LanguageContent;

		WebModel.UI.DrawingArea.load('./images/content/' +													// now trigger the load based
									 _gid + '_' + _gpi + (_gpl == "A" ? '' : '_' + _gpl) +					// on graphic id, page index
									 '.svg');																// and content language.

		tv = WebModel.UI.TreeViews['globalProcessTree'];
		tv.clearSelection();																				// clear current selection.

		n = tv.findNode(_gid, true);
		switch (true) {
			case n == null:
				break;
			case !n.length:
				n.Selected = true;
				document.title = n.Name;
				break;
			default:
				for (i = 0; i < n.length; i++)
					n[i].Selected = true;
					if (i == 0)
						document.title = n[i].Name;
				break;
		}

		if (!WebModel.Settings.RememberLastID)
			return;

		WebModel.Settings.CurrentID = _gid;
		WebModel.Settings.CurrentPage = _gpi;
	}

	this.zoom = function (myFactor, myScrollX, myScrollY)
	{
     var zb, zw, zh, zx, zy;	// zoom box, witdh, height, x, y
	 var vw, vh;				// view port width/height
	 var vx, vy;				// view port x/y
	 var gw, gh;				// graphic object with/height
	 var gx, gy;				// graphic object x/y
	 var cx, cy;				// center-x/y
	 var f;						// current factor
	 var i;						// multiple usage
	 var b;						// multiple usage
	 
		if (!_vp || !_go) {
			return;
		}

		f = _f;																	// buffer active factor

		if (myFactor instanceof Object)
			myFactor = myFactor.getAttribute('id');

		switch (myFactor) {
			case 'zoomPlus':
			case 'zoomMinus':
				b = false;
				for (i = 0; i < _zb.length; i++)
					if (_zb[i].id.match('zoom' + (_f * 100)))
						if (i == 9 && myFactor == 'zoomMinus') {
							b = true;
							break;
						} else if (i == 2 && myFactor == 'zoomPlus') {
							_f += 0.5;
							b = true;
							break;
						} else {
							_f = 0.01* _zb[i + (myFactor == 'zoomPlus' ? -1 : 1)].id.replace(/zoom/, '');
							b = true;
							break;
						}
				if (!b)
					_f += myFactor == 'zoomPlus' ? 0.5 : -0.5;
				break;
			case 'zoom200':
			case 'zoom175':
			case 'zoom150':
			case 'zoom125':
			case 'zoom100':
			case 'zoom75':
			case 'zoom50':
			case 'zoom25':
				_f = 0.01 * parseFloat(myFactor.replace(/zoom/, ''));
				break;
			case 'zoomSheet':
			case undefined:
			case -1:															// whole page
				myFactor = 1.0;
			default:															// based on factor
				_f = myFactor;
				break;
		}

		if (_f < 0.25)															// let's ensure factor
			_f = 0.25;															// to be never < 0.25!

		vw = _vp.clientWidth;													// let's get view port
		vh = _vp.clientHeight;													// data.
		vx = _vp.scrollLeft;
		vy = _vp.scrollTop;

		gw = parseInt((_f * vw) - PIXEL_FIX);									// let's calculate graphic
		gh = gw * _self.GraphicAspect;											// data especially depending
		if (gh > parseInt((_f * vh) - PIXEL_FIX)) {								// on the given viewport size.
			gh = parseInt((_f * vh) - PIXEL_FIX);
			gw = gh * _self.GraphicAspect;
		}
		if (gw > parseInt((_f * vw) - PIXEL_FIX)) {
			gw = parseInt((_f * vw) - PIXEL_FIX);
			gh = gw / _self.GraphicAspect;
		}
		gx = parseFloat(_go.style.left || 0);
		gy = parseFloat(_go.style.top || 0)

		cx = (_f / f) * (vx + (vw / 2) - gx);									// let's calculate center
		cy = (_f / f) * (vy + (vh / 2) - gy);									// position.

		if (gw <= vw) {															// let's calculate graphic's
			gx = Math.max(0, (vw / 2) - (gw / 2));								// x-position based on given
			vx = 0;																// viewport size.
		} else {
			vx = cx - (vw / 2);
			if (vx >= 0)
				gx = 0;
			else {
				gx = -vx;
				vx = 0;
			}
		}

		if (gh < vh) {															// let's calculate graphic's
			gy = Math.max(0, (vh / 2) - (gh / 2));								// y-position based on given
			vy = 0;																// viewport size.
		} else {
			vy = cy - (vh / 2);
			if (vy >= 0)
				gy = 0;
			else {
				gy = -vy;
				vy = 0;
			}
		}

		if (gw <= vw)															// graphic width < viewport?
			_vp.scrollLeft = 0;													// yeah! >> ensure scrollbar.
		if (gw <= gh)															// graphic height < viewport?
			_vp.scrollTop = 0;													// yeah! >> ensure scrollbar.

		_go.style.width = gw + 'px';											// let's set newly calced
		_go.style.height = gh + 'px';											// graphic and viewport
		_go.style.left = gx + 'px';												// dimensions...
		_go.style.top = gy + 'px';
		_vp.scrollLeft = myScrollX ? myScrollX : vx;
		_vp.scrollTop = myScrollY ? myScrollY : vy;

		if (myScrollX == undefined && myScrollY == undefined)					// are we called by zoom window?
			OnScroll(null);														// no! >> let's trigger zoom draw!

		for (i = 0; i < _zb.length; i++) {										// finally we try to activate
			_zb[i].className = 'zoomStep';										// current zoom button if some
			if (_zb[i].id.match('zoom' + (_f * 100)))							// associated...
				_zb[i].className = 'activeZoomStep';
		}
	}

	this.refreshZoomWindowData = function () { OnLoad(null, true); }

	//// ~~~~ private functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function getZoomRectCursor(myEvent)
	{
	 var c;		// cursor
	 var p;		// point
	 var e;		// element

		myEvent = myEvent || event;
		myEvent = !myEvent.targetTouches ? myEvent : myEvent.targetTouches[0];

		e = document.elementFromPoint(myEvent.pageX, myEvent.pageY);
		if (e != _zr)																	// return if current element
			return 'default';															// isn't zoom rectangle!

		c = '';																		
		p = _hp.getRelativePosition(e, myEvent.clientX, myEvent.clientY);				// get cursor on rectangle.

		if (p.Y >= 0 &&																	// north border?
			p.Y <= CURSOR_PIXELS)																	
		{ c += 'n'; }

		if (p.Y >= _zr.clientHeight - CURSOR_PIXELS &&									// south border?
			p.Y <= _zr.clientHeight)
		{ c += 's'; }

		if (p.X >= 0 &&																	// west border?
			p.X <= CURSOR_PIXELS)
		{ c += 'w'; }

		if (p.X >= _zr.clientWidth - CURSOR_PIXELS &&									// east border?
			p.X <= _zr.clientWidth)
		{ c += 'e'; }

		if (c.length == 0 &&															// between all borders?
			p.X >= 0 &&
			p.X <= _zr.clientWidth &&
			p.Y >= 0 &&
			p.Y <= _zr.clientHeight)
		{ c = 'move'; }

		if (c.length == 0)
			c = 'default';
		if (c != 'move' && c != 'default')
			c += '-resize';

		return c;
	}

	function getShapeInfo(myElement)
	{
	 var sz;
	 var a;		// user field attribute
	 var e;		// empty connector?
	 var f = _hp.getFirstChildByTagName;
	 var i = { MainElement: null, UUID: null };
	 var b;

		if (!myElement) {
			throw 'myElement must not be null!';
		}

		i.MainElement = myElement;														// first we assume our main
		do {																			// element is a group containing
			if (!i.MainElement) {														// user defined fields.
				break;
			}

			b = (i.MainElement.nodeName != 'g');
			if (!b) {
				nd = f(i.MainElement, 'v:userDefs');
				b = (nd == null);
			}

			if (!b) {
				b = (null == f(nd, 'v:ud', 'v:nameU', UUID_FIELD));
			}

			if (b) {
				i.MainElement = i.MainElement.parentNode;
			}
		} while (b);

		if (!i.MainElement) {															// did we get a main element?
			i.MainElement = myElement;													// no! >> so we assume our main
			while (																		// element will be a link tag.
				i.MainElement &&
				(
					i.MainElement.nodeName != 'a' ||
					(
						i.MainElement.attributes &&
						!i.MainElement.attributes.getNamedItem('xlink:href')
					)
				)
			) {
				i.MainElement = i.MainElement.parentNode;
			}
		}

		if (i.MainElement == null) {													// didn't we get an element?
			return;																		// no! >> we leave here.
		}

		if (i.MainElement.nodeName == 'a') {											// is element a link?
			return i;																	// yeah! >> return its info.
		}

		e = true;
		f = _hp.getFirstChildByTagName;
		myElement = f(i.MainElement, 'v:userDefs');
		if (myElement) {
			myElement = myElement.firstElementChild;									// set element to first
			while (myElement) {															// user defined field and
				if (myElement.attributes) {												// search each field.
					a = myElement.attributes.getNamedItem('v:nameU');
				}

				if (!a || myElement.nodeType != 1) {									// if no named user field
					myElement = myElement.nextSibling;									// we skip this element!
					continue;
				}

				if (a.value == UUID_FIELD) {											// got UUID field?
					sz = myElement.attributes.getNamedItem('v:val').value;				// yeah! >> get its value,
					sz = sz.match(/.*?(\{.*?\}).*/);									// extract UUID data.
					if (sz && sz.length == 2) {											// data correct?
						i.UUID = sz[1];													// yeah! >> buffer UUID.
						e &= (i.UUID != UUID_EMPTY);									// flag non-empty on null UUID.
					}
				}

				if (a.value == NAME_FIELD) {											// got name field?
					sz = myElement.attributes.getNamedItem('v:val').value;				// yeah! >> get its value.
					e &= (sz.toLowerCase().indexOf('(daten)') >= 0);					// indicate emtpty connector.
				}

				if (a.value == NAMES_FIELD || a.value == NAMEL_FIELD) {					// got caption field?
					sz = myElement.attributes.getNamedItem('v:val').value;				// yeah! >> get its value.
					e &= (sz == 'VT4()');												// set empty connector flag.
				}

				myElement = myElement.nextSibling;
			}
		}

		if (!e && i.MainElement && i.UUID) {											// got valid info element?
			return i;																	// yeah! >> return it!
		}
	}

	function prepareShapes(mySVGDocument)
	{
	 var gc;	// group collection
	 var ge;	// group element
	 var tc;	// title collection
	 var te;	// title element
	 var tt;	// tooltip
	 var si;	// shape info
	 var ed;
	 var sz;

		if (!mySVGDocument) {
			throw 'mySVGDocument must not be null!';
		}

		gc = mySVGDocument.getElementsByTagName('g');									// let's find all group elements.
		if (!gc || gc.length <= 0) {													// did we get any group element?
			return;																		// no! >> leave here...
		}

		ed = WebModel.ExclusionData;
		tt = WebModel.UI.Translations.getTranslation('webmodel.ui.shapetooltip', 'Click to follow the hyperlink.');

		for (var i = 0; i < gc.length; i++) {
			ge = gc[i];
			si = getShapeInfo(ge);														// let's set mouse pointer dependent
			ge = (si ? si.MainElement : ge);											// of finding a group node containing
			if (ge && ge.style) {														// an UUID, representing a link and
				switch (true) {															// being allowed to navigate.
					case si != undefined && ed.indexOf(si.UUID) >= 0:
						sz = 'not-allowed';
						break;

					case si != undefined:
						sz = 'pointer';
						break;

					default:
						sz = 'default';
						break;

				}

				ge.style.cursor = sz;
				tc = ge.getElementsByTagName('title');
				if (si && tc && tc.length) {
					for (var j = 0; j < tc.length; j++) {
						te = tc[j];
						if (!te.childNodes.length) {
							te.appendChild(te.ownerDocument.createTextNode(sz == 'pointer' ? tt : ''));
						}
					}
				}
			}

			if (si && _mi) {
				for (var j = 0; j < _mi.length; j++) {
					try {
						if (_mi[j] == si.UUID &&
							!(function(myArray, myElement) { for (var i = 0; i < myArray.length; i++) { if (myArray[i] == myElement) { return true; } }} (_ms, si.MainElement)))
						{
							_ms.push(si.MainElement);
						}
					}
					catch (e) {};	// prevents permission denied errors!
				}
			}
		}
	}

	function markShapes(myElementArray, myBlinkCount)
	{
	 var e;

		if (!myElementArray || !myElementArray.length) {
			return;
		}

		if (!myBlinkCount) {
			myBlinkCount = 0;
		}

		myBlinkCount++;

		try {
			for (var i = 0; i < myElementArray.length; i++) {
				e = myElementArray[i];
				switch (e.hasAttribute('opacity')) {
					case true:
						e.removeAttribute('opacity');
						break;

					default:
						e.setAttribute('opacity', BLINK_OPACITY.toString());
						break;
				}
			}

			if (myBlinkCount < BLINK_MAX || myElementArray[0].hasAttribute('opacity')) {
				setTimeout(function() { markShapes(myElementArray, myBlinkCount); }, BLINK_TIMEOUT);
			}
		}
		catch (e) {};	// prevents permission denied errors!
	}

	function fetchLinks(myShapeInfo)
	{
	 var xslt;
	 var xml;
	 var nl;	// multiple usage!
	 var xn;
	 var ay;
	 var sz;
	 var n;		// multiple usage!
	 var l = { URL: null, Caption: null, Image: null, AltImage: null, ShapeUUID: null };

		if (!myShapeInfo) {
			throw 'myShapeInfo must not be null!';
		}

		ay = new Array();
		if (!myShapeInfo.UUID) {
			appendExternalLinks(myShapeInfo.MainElement, ay);
			return ay;
		}

		xslt = _hp.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './xslt/intermediate_list_hyperlinks.xslt', false);
		xml = _hp.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/empty.xml', false);
		xml = _hp.transformXML(xml, xslt, {
							   filter: (myShapeInfo.UUID == UUID_EMPTY ? _gid : myShapeInfo.UUID),
							   language: WebModel.Settings.LanguageContent,
							   explicit: (myShapeInfo.UUID == UUID_EMPTY ? 'P' : ''),
							   forcedetails: +(myShapeInfo.UUID == UUID_EMPTY),			// convert bool => int!
							   linkfallback: +WebModel.Settings.LinkFallback,
							   displaytext: WebModel.Settings.DisplayText,
							   exclusionlist: WebModel.ExclusionData
		});
		nl = _hp.selectSingleNode(xml, '/lists');
		if (nl) {
			nl = _hp.selectNodes(xml, '/lists/list[@filter="' + (myShapeInfo.UUID == UUID_EMPTY ? _gid : myShapeInfo.UUID) + '"]/item');
		} else {
			nl = _hp.selectNodes(xml, '/list/item');
		}
		for (var i = 0; i < nl.length; i++) {
			xn = nl[i];
			l.URL = _hp.selectSingleNode(xn, 'uri/text()').nodeValue;
			l.Image = _hp.selectSingleNode(xn, 'image/text()').nodeValue;
			l.AltImage = _hp.selectSingleNode(xn, 'altimage/text()');
			if (l.AltImage) {
				l.AltImage = l.AltImage.nodeValue;
			}
			l.ShapeUUID = _hp.selectSingleNode(xn, 'shapeuuid/text()');
			if (l.ShapeUUID) {
				l.ShapeUUID = l.ShapeUUID.nodeValue;
			}
			if (!isNaN(parseFloat(l.URL) ||
				l.URL.match(/^\{[0-9a-fA-F]{8,8}\-[0-9a-fA-F]{4,4}\-[0-9a-fA-F]{4,4}\-[0-9a-fA-F]{4,4}\-[0-9a-fA-F]{12,12}\}$/) != null))
			{
				sz = WebModel.Settings.DisplayText == SettingsClass.DisplayText.Name ?								
					 'name' : 'shapetext';
				l.Caption = _hp.selectSingleNode(xn, sz + '/text()').nodeValue;
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
			ay.push(new WebModel.Common.LinkClass(l.URL, l.Caption, l.Image, l.AltImage, l.ShapeUUID));			
		}

		if (myShapeInfo.MainElement.parentNode &&
			myShapeInfo.MainElement.parentNode.nodeName == 'a' &&
			myShapeInfo.MainElement.parentNode.attributes &&
			myShapeInfo.MainElement.parentNode.attributes.getNamedItem('xlink:href'))
		{
			appendExternalLinks(myShapeInfo.MainElement.parentNode, ay);
		}

		return ay;
	}

	function appendExternalLinks(myElement, myArray)
	{
	 var l = { URL: null, Caption: null, Image: null, AltImage: null };
	 var ay;
	 var n;
	 var e;
	 var m;
	 var r;

		l.URL = myElement.attributes.getNamedItem('xlink:href').value
		r = /#pagelink:([0-9]+).*/gim;
		m = r.exec(l.URL);

		switch (true) {
			case m != undefined && m != null:																// page link: add it!
				l.Caption = WebModel.UI.Translations.getTranslation('webmodel.ui.pagecaption', 'Page {0}').replace(/\{0\}/gi, m[1]);
				myArray.push(new WebModel.Common.LinkClass(l.URL, l.Caption));
				break;

			case l.URL.indexOf('#') != 0:																	// normal link: add it!
				l.Caption = myElement.attributes.getNamedItem('xlink:title') ?
							myElement.attributes.getNamedItem('xlink:title').value :
							l.URL;
				ay = new Array('\\', '/');
				for (var i = 0; i < ay.length; i++) {
					n = l.Caption.lastIndexOf(ay[i]);
					if (n >= 0) {
						l.Caption = l.Caption.substr(++n, l.Caption.length - n);
					}
				}

				myArray.push(new WebModel.Common.LinkClass(l.URL, l.Caption));
				break;

			case l.URL.indexOf('#') == 0:																	// link menu: parse it!
				e = _self.SVGDocument.getElementById(l.URL.substr(1, l.URL.length - 1));
				if (e) {
					ay = e.getElementsByTagName('a');
					for (var i = 0; i < ay.length; i++) {
						appendExternalLinks(ay[i], myArray);
					}
				}

				break;
		}
	}

	function clearTooltips(mySVGDocument)
	{
	 var ec;	// element collection
	 var e;		// element

		if (!mySVGDocument) {
			throw 'mySVGDocument must not be null!';
		}

		ec = mySVGDocument.getElementsByTagName('title');								// let's find all elements.
		if (!ec || ec.length <= 0) {													// did we get any element?
			return;																		// no! >> leave here...
		}

		for (var i = 0; i < ec.length; i++) {
			e = ec[i];
			if (e.childNodes.length > 0) {
				e.removeChild(e.firstChild);
			}
		}
	}
}
///
/// End :: Drawing Class
///
