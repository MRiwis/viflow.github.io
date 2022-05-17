// -----------------------------------------------------------------------
// <copyright file="ViCon.ViFlow.WebModel.Printing.js" company="ViCon GmbH">
//     Copyright © ViCon GmbH.
// </copyright>
// <summary>
//		This file provides all functionality for printing
//		this web apps content.
// </summary>
// <remarks>
//		This file relies on:
//		====================
//		~ ViCon.ViFlow.WebModel.js
//		~ ViCon.ViFlow.WebModel.Common.js
//		~ ViCon.ViFlow.WebModel.Diagnostics.js
//		~ ViCon.ViFlow.WebModel.Drawing.js
//		~ ViCon.ViFlow.WebModel.UI.js
//
//		Assumed VDG Violations:
//		=======================
//		~ properties must be placed between functions and nested classes.
//				REASON:
//				constructor code relies on pre-defined properties within
//				JavaScript code.
//		~ fields must be placed together.
//				REASON:
//				constructor code is not encapsulated as a funtion within
//				JavaScript code.
// </remarks>
// -----------------------------------------------------------------------

/// <summary>
/// This class provides all functionality
/// for printing this web apps.
/// </summary>
function PrintingClass()
{

	//// ~~~~ constants ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var EVENT_DELAY = 0x400;
	var PIXEL_FIX = 0x2;
	var MAX_SCALE = 0x8;

	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _lc;	// last call
	var _pi;	// print image
	var _ga;	// graphic aspect

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_self = this;
	_self.extendAsEventDispatcher();

	window.onbeforeprint = OnBeforePrint;
    if (window.matchMedia)
	{
     var mql;

		mql = window.matchMedia('print');
		if (mql) {
			mql.addListener(OnBeforePrintMatchMedia);
		}
    }

	WebModel.Drawing.addEventListener('load', OnGraphicLoaded, false);

	//// ~~~~ event handlers ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function OnBeforePrint(myEvent)
	{
	 var n;

		n = new Date().getTime();
		if (!_lc || (_lc + EVENT_DELAY) < n) {						// let's prevent event triggers
			handleBeforePrint();									// printer output more than once
		}															// per EVENT_DELAY's ms.

		_lc = n;
	}

	function OnBeforePrintMatchMedia(myMedia)
	{
		if (myMedia.matches) {
			OnBeforePrint(null);
		}
	}

	function OnGraphicLoaded(myEvent)
	{
		WebModel.Diagnostics.Console.log('Beginning refresh of printing graphic...');

		if (!_pi) {													// print image exists?
			_pi = document.createElement('img');					// no! >> let's create it.
			_pi.setAttribute('id', 'printimage');
			document.body.appendChild(_pi);
		}

		_pi.src = WebModel.UI.DrawingArea.Element.src;				// set current graphic and
		_ga = WebModel.Drawing.GraphicAspect;						// its aspect.

		WebModel.Diagnostics.Console.log('Printing graphic has been refreshed.');
	}

	//// ~~~~ private functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	function handleBeforePrint()
	{
		//There is currently nothing to do here! :-D
	}
}
///
/// End :: Printing Class
///