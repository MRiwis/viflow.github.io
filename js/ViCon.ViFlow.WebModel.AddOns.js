// -----------------------------------------------------------------------
// <copyright file="ViCon.ViFlow.WebModel.AddOns.js" company="ViCon GmbH">
//     Copyright © ViCon GmbH.
// </copyright>
// <summary>
//		This file provides functionality that is required for
//		dealing with AddOns within this web application.
// </summary>
// <remarks>
//		This file relies on:
//		====================
//		~ ViCon.ViFlow.WebModel.js
//		~ ViCon.ViFlow.WebModel.Common.js
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
/// This class provides functionality that is
/// required for dealing with AddOns within this
/// web application.
/// </summary>
function AddOnsClass()
{
	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _base;

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "AddOnClass", { get: function () { return AddOnClass; } });

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_self = this;
	_self.base = WebModel.Common.CollectionClass;
	_self.base()

	{
	 var xslt;
	 var xml;
	 var nl;
	 var n;		// node
	 var a;		// addon
	
		xslt = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './xslt/intermediate_addons.xslt', false);
		xml = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './data/settings.xml', false);
		xml = WebModel.Common.Helper.transformXML(xml, xslt);
		nl = WebModel.Common.Helper.selectNodes(xml, '/addons/addon');
		for (var i = 0; i < nl.length; i++) {
			n = nl[i];
			xml = WebModel.Common.Helper.loadXML(WebModel.Common.HelperClass.XmlLoadMethods.URI, './AddOns/' + n.getAttribute('url'), false);
			xml = WebModel.Common.Helper.transformXML(xml, xslt);
			n = WebModel.Common.Helper.selectSingleNode(xml, '/addons/addon');
			if (n) {
				a = new AddOnClass(n);
				_self.add(a, a.ID);
			}
		}
	}

	//// ~~~~ public functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	this.addHost = function (myClient)
	{
		try {
			myClient.contentWindow.WebModel = WebModel;
		}
		catch (e) {}
	}

	//// ~~~~ inner classes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	/// <summary>
	/// This class provides all functionality
	/// for creating and interacting with
	/// AddOn objects.
	/// </summary>
	function AddOnClass(myNodeXML)
	{
		//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		var _c;			// command
		var _u;			// unique identifier
		var _n;			// display name
		var _r;			// tab replacement

		//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		Object.defineProperty(this, "ID", { get: function () { return _u; } });
		Object.defineProperty(this, "Name", { get: function () { return _n; } });
		Object.defineProperty(this, "Replaces", { get: function () { return _r; } });
		Object.defineProperty(this, "Command", {
			get: function ()
			{
			 var bu;	// base uri
			 var sz;
			 var x;
			 var m;
			 var v;

				bu = document.location.href;
				v = bu.lastIndexOf('/');
				if (v >= 0) {
					bu = bu.substr(0, v);
				}
				
				sz = _c;
				sz = sz.replace(/\{AddOns\.Folder\}/gi, bu + '/AddOns');
				sz = sz.replace(/\\/gi, '/');
				sz = sz.replace(/&/gi, '%26');

				x = /\{(.*?)\}/gi;
				while (m = x.exec(sz)) {
					try {
						v = '' + eval(m[1]);
						v = v.replace(/[\{\}]/gi, '');
					}
					catch (e) {
						WebModel.Diagnostics.Console.warn('Could not evaluate AddOn parameter ' + m[1]);
						v = '';
					}
					sz = sz.replace('{' + m[1] + '}', v);

					x = /\{(.*?)\}/gi;
				}

				return sz;
			}
		});

		//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		if (!myNodeXML) {
			throw 'myNodeXML must not be null!';
		}

		_u = myNodeXML.getAttribute('id');
		_c = myNodeXML.getAttribute('cmd');
		_n = myNodeXML.getAttribute('name');
		_r = myNodeXML.getAttribute('replace');
	}
	///
	/// End :: AddOn Class
	///
}
AddOnsClass.prototype = WebModel.Common.CollectionClass.prototype;	// let's inherit from CollectionClass!
///
/// End :: AddOns Class
///