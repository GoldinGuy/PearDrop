(function ($) {
	"use strict";

	/*==================================================================
    [ Validate ]*/
	var input = $(".validate-input .input100");

	$(".validate-form").on("submit", function () {
		var check = true;

		for (var i = 0; i < input.length; i++) {
			if (validate(input[i]) == false) {
				showValidate(input[i]);
				check = false;
			}
		}

		return check;
	});

	$(".validate-form .input100").each(function () {
		$(this).focus(function () {
			hideValidate(this);
		});
	});

	function validate(input) {
		if ($(input).attr("type") == "email" || $(input).attr("name") == "email") {
			if (
				$(input)
					.val()
					.trim()
					.match(
						/^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{1,5}|[0-9]{1,3})(\]?)$/
					) == null
			) {
				return false;
			}
		} else {
			if ($(input).val().trim() == "") {
				return false;
			}
		}
	}

	function showValidate(input) {
		var thisAlert = $(input).parent();

		$(thisAlert).addClass("alert-validate");
	}

	function hideValidate(input) {
		var thisAlert = $(input).parent();

		$(thisAlert).removeClass("alert-validate");
	}

	/*==================================================================
    [ Modal ]*/
	$(".modal-subscribe").on("click", function (e) {
		e.stopPropagation();
	});

	$(".btn-close-modal").on("click", function () {
		$("#subscribe").modal("hide");
	});
})(jQuery);

function send_mail() {
	window.location.href =
		"mailto:gspam275@gmail.com?subject=" +
		encodeURI(
			document.getElementById("name_field").value +
				": New PearDrop Subscriber Email"
		) +
		"&body=" +
		encodeURI(document.getElementById("email_field").value);
	return false;
}

var deadline = new Date("Jun 28, 2020 15:37:25").getTime();
var x = setInterval(function () {
	var now = new Date().getTime();
	var t = deadline - now;
	document.getElementById("days").innerHTML = Math.floor(
		t / (1000 * 60 * 60 * 24)
	);
	document.getElementById("hours").innerHTML = Math.floor(
		(t % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)
	);
	document.getElementById("minutes").innerHTML = Math.floor(
		(t % (1000 * 60 * 60)) / (1000 * 60)
	);
	document.getElementById("seconds").innerHTML = Math.floor(
		(t % (1000 * 60)) / 1000
	);
}, 1000);
