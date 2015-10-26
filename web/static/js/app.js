// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

/*
import socket from "./socket"

socket.connect()

let counter = 0;

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("info:api", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully") })
  .receive("error", resp => { console.log("Unable to join", resp) });

function process_users(users) {
    if (users < 1) users = 1;
    if (users == 1) {
        $('#plural').html("");
    } else {
        $('#plural').html("s");
    }
    $("#users").html(users.toString())
}

channel.on("user:joined",resp => {
    var users = parseInt($("#users").html(), 10);
    process_users(users+1);
});

channel.on("user:left",resp => {
    var users = parseInt($("#users").html(), 10);
    console.log("Someone left...")
    process_users(users-1);
});

channel.on("new:message",resp => {
    var block = "<div class='info-block row' style='display:none;'>";
    block += "<div class='col-sm-1'><img height='58' src='images/theme_" + resp.theme + ".jpg'></div>";
    block += "<div class='col-sm-11 query'>" + resp.query + "</div>";
    block += "</div>";

    var size = $('.info-block').size();
    if ( size == 20 ) {
        $('#info').find(".info-block").slice(19).remove();
    }
    $(block).hide().prependTo('#info').fadeIn();
});
*/