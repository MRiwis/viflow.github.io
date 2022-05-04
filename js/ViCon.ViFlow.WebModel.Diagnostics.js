// -----------------------------------------------------------------------
// <copyright file="ViCon.ViFlow.WebModel.Diagnostics.js" company="ViCon GmbH">
//     Copyright © ViCon GmbH.
// </copyright>
// <summary>
//		This file provides all functionality for diagnising
//		this web application.
// </summary>
// <remarks>
//		This file relies on:
//		====================
///		~ relies on ViCon.ViFlow.WebModel
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
/// for diagnosing this web application.
/// Further there will be provided a cross-
/// browser Console object.
/// </summary>
function DiagnosticsClass()
{
	//// ~~~~ fields ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	var _self;
	var _console;

	//// ~~~~ public properties ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Object.defineProperty(this, "Console", { get: function () { return _console; } });

	//// ~~~~ constructor ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	_console = window.console || {};
	_console.log = _console.log || function () {};
	_console.warn = _console.warn || function () {};
	_console.error = _console.error || function () {};
	_console.info = _console.info || function () {};
}
///
/// End :: Diagnostics Class
///
