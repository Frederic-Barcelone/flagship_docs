var active_color = '#000'; // color of user provided text
var inactive_color = '#ccc'; // color of default text

$(document).ready(function () {
	//Search box live search
  var AJAX = $.manageAjax.create('AjaxProfile',
    {
      queue:'clear',
      cacheResponse:true,
      abortOld: true
    });
	$("#search_query").addClass("search-default");
	
	$("#search-jQuery").css({'display' : 'block'});
	$("#search_query").click(function() {
		$("#search_query").removeClass("search-default");
		$("#search_query").addClass("has_focus");
	});
	
	$("#search_query").bind('keyup',function () {
		if ($(this).val().length == 0 ) {
			$("#search_query_auto_complete").fadeOut(100);
			$("#search_query_auto_complete").html("");
		} else if ($(this).hasClass('has_focus')) {
    AJAX.add({
				type: "POST",
				cache: true,
				url: searchURL,
				data: $(this),
				success: function(msg) {
					$("#search_query_auto_complete").fadeIn(100);
					$("#search_query_auto_complete").html(msg);
				}
			});
		}
	});

	$("#search_query").keypress(function() {
		$('a#search_ex').fadeIn('fast');
	});
	
	if (!$('input#search_query').val('')) {
		$('a#search_ex').show();
	} 
	
	$("#search_query").blur(function() {
		if ($('#search_query').val() == "") {
			$("#search_query").addClass("search-default");
		}
		$("#search_query").removeClass("has_focus");
		$("#search_query_auto_complete").fadeOut('medium');
	});
	
	//Clear search box when click:
	$('a#search_ex').click(function() {
		$('input#search_query').val('');
		$(this).fadeOut('fast');
		$("#search_query_auto_complete").fadeOut(100);
		$("#search_query").addClass("search-default");
	});
	
	//End search box

	//Expandable category tree
	$('#cat_tree_inset').hide();
	$('#cat_tree_expand').show();
	$('#search-jQuery').show();
	$('#cat_tree_expand').click(function() {
		$('#cat_tree_inset').toggle();
		if ($('#label_show').css("display") == "none") {   // case PREVIOUSLY CLOSED
			$('#label_hide').hide();
			$('#label_show').show();
		} else {                                          // case PREVIOUSLY OPEN
			$('#label_show').hide();
			$('#label_hide').show();
		}
		return false;
	});
	//End category tree
	
	
	$('.info_box p img').tipsy({gravity: 's'});
	$('ul.img_sel li img').tipsy({gravity: 's'});

        //Document grid/table switching
        $('a.update_holder').live('click', function(event){
          event.preventDefault();
          target_url = $(this).attr('href')
            $.ajax({
              url: target_url,
              dataType: "html",
              cache: false,
              success: function(data) {
                $("#doc_holder").fadeOut(100, function(){
                  $("#doc_holder").html("").html(data).fadeIn('slow')
                });
              }
          });
        });
});




