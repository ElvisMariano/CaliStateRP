$(function() {
    window.addEventListener('message', function(event) {
        var item = event.data;
        var buf = $('#wrap');
        buf.find('table').append("<h1 class=\"heading\">California State Roleplay</h1><img class='image' src='https://cdn.pixabay.com/photo/2017/03/17/05/20/info-2150938_640.png'><p id='website'>www.crp.news</p><p id='discord'>discord.gg/EStMZhR</p>");
        if (item.meta && item.meta == 'close') {
            document.getElementById("ptbl").innerHTML = "";
            $('#wrap').hide();
            return;
        }
        buf.find('#ptbl').append(item.text);
        var sorted = $('#ptbl tr').sort(function(a, b) {
            var a = $(a).find('td:eq(1)').text(),
                b = $(b).find('td:eq(1)').text();
            return a.localeCompare(b, false, { numeric: true })
        })

        var players = $('#ptbl tr').length;

        $('#ptbl').html("<h1 class=\"heading\">California State Roleplay • " + players + "/32</h1><img class='image' src='https://cdn.pixabay.com/photo/2017/03/17/05/20/info-2150938_640.png'><p id='website'>www.crp.news</p><p id='discord'>discord.gg/EStMZhR</p>");
        $('#ptbl').append(sorted);
        $('#wrap').show();
    }, false);
});