

function make_call(url, form, btn) {
    var b = $(btn);
    b.prepend('<span id="loading" class="glyphicon glyphicon-refresh spinning"></span> ');

    $.ajax({
        url: url,
        dataType: "json"
    }) .done(function( obj ) {
        var text = "";

        if (obj.success) {
            text = JSON.stringify(obj.result, undefined, 2);
            $(form + "_link").attr("href", url);
            $(form + "_link").show();
        } else {
            text = "ERROR: " + obj.error;
            $(form + "_link").attr("href", "");
            $(form + "_link").hide();
        }
        $(form + "_output").html( text );
        $(form + "_container").slideDown();

        $('#loading').remove();
    }).error(function(){
        var text = "API call to " + url + " failed";
        $(form + "_output").html( text );
        $(form + "_container").slideDown();

        $('#loading').remove();
    });
}

function execute_query(btn) {
    $("#error").empty();
    $("#error").hide();
    var val = editor.getValue();
    if (!val) return;

    $("#table-results").html("");

    var b = $(btn);
    b.prepend('<span id="loading" class="glyphicon glyphicon-refresh spinning"></span> ');

    var url = "/api/"+ theme + "/sql?query=" + encodeURIComponent(val);

    // TODO: Change so it behaves like the other calls
    $.ajax({
        method: "GET",
        url: url,
        dataType: "json"
    }).done(function(object) {
        $('#loading').remove();
        if (!object.success) {
            $("#download").hide();
            $("#error").html(object.error);
            $("#error").show();
            $('.table-results').html("");
            editor.focus();
        } else {
            $("#csvlink").attr('href', host + url + '&_format=csv')
            $("#ttllink").attr('href', host + url + '&_format=ttl')
            $("#jsonlink").attr('href', host + url)
            $("#download").show();

            var text = JSON.stringify(object.result, undefined, 2);
            $('.table-results').html(text);
            $('.table-results-container').show();
        }
    });
}

function form_request(btn, form, fmt) {
    var params = "";
    var f = $(form);
    var url = f.attr('action') + "?";

    var elements = f.find("input");
    for(var i =0; i < elements.length; i++) {
        url += $(elements[i]).attr('name') + "=" + $(elements[i]).val();
        if ( i < elements.length - 1) {
            url += "&";
        }
    }

    if (fmt && fmt.length > 0) {
        window.location.href = url + "&_format=" + fmt;
        return;
    }

    make_call(url, form, btn)
}

function filter_request(btn,id, theme, name, fmt) {
    var items = [];

    $("#" + id + " .dataelement").each(function(idx, elem){
        _.each($(elem).contents(), function(element){
            if (element.nodeName == "LABEL") {
                items.push($(element).attr('for'));
            } else if (element.nodeName == "SELECT"){
                items.push(element.value);
            }
        });
    });

    var url = "/api/" + theme + "/" + name + "?";
    for (var i= 0; i < items.length; i+=2 ){
        url += items[i];
        url += "=" + items[i+1];
        if ( i < items.length - 2) {
            url += "&";
        }
    }

    if (fmt && fmt.length > 0) {
        window.location.href = url + "&_format=" + fmt;
        return;
    }

    make_call(url, "#" + id, btn);
}

