function submit_distinct(service, field, btn) {
    var url = $("#form-" + service + "-" + field).attr('action');
    var select = $("#filter-" + service + "-" + field);

    if ( select.val() == "" ) {
        return;
    }
    url = url + "?" + escape(field) + "=" + escape(select.val());

    var output = "#basic-" + service + "-output";
    var link = "#basic-" + service + "-link";
    make_call(url, output, link, btn)
}



function make_call(url, output, link, btn) {
    var b = $(btn);
    b.prepend('<span id="loading" class="glyphicon glyphicon-refresh spinning"></span> ');

    $.ajax({
        url: url,
        dataType: "json"
    }) .done(function( obj ) {
        var text = "";

        if (obj.success) {
            text = JSON.stringify(obj.result, undefined, 2);
            $("#link-modal").val(url)
            $(link + "-csv").attr("href", url + "&_format=csv");
            $(link + "-ttl").attr("href",  url + "&_format=ttl");

            $(link).removeAttr('disabled');
            $(link + "-downloads").removeAttr('disabled');
        } else {
            text = "ERROR: " + obj.error;
            $("#link-modal").val("");
            $(link + "-csv").attr("href", "");
            $(link + "-ttl").attr("href", "");

            $(link).attr('disabled', 'disabled');
            $(link + "-downloads").attr('disabled', 'disabled');
        }

        $(output).html( text );
        $('#loading').remove();
    }).error(function(){
        var text = "API call to " + url + " failed";
        $(output).html( text );
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

function form_request(btn, name, fname) {

    var params = "";
    var f = $("#form-" + name + "-" + fname);
    var url = f.attr('action') + "?";

    var elements = f.find("input");
    for(var i =0; i < elements.length; i++) {
        url += $(elements[i]).attr('name') + "=" + $(elements[i]).val();
        if ( i < elements.length - 1) {
            url += "&";
        }
    }

    var output = "#basic-" + name + "-output";
    var link = "#basic-" + name + "-link";
    make_call(url, output, link, btn)
}

