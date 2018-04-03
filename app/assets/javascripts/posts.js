function createFlagOption(item, handler) {
    var container = $("<div></div>");
    container.addClass("clearfix flag-option");
    container.append("<div class='pull-left col-sm-1 col-md-1'><input type='radio' name='flag-option' value='" + item['option_id'] + "' data-flagtype='" + item['title'] + "'/></div>");
    var details = $("<div class='pull-right col-sm-11 col-md-11'></div>");
    details.append("<p><strong>" + item['title'] + "</strong></p>");
    details.append("<p>" +  item['description'] + "</p>");
    container.append(details);

    container.on('click', handler(item));

    return container;
}

$(document).ready(function() {
    $(".post-flag-link").on("click", function(ev) {
        ev.preventDefault();
        var questionId = $(this).data("questionid");
        $.ajax({
            'type': 'GET',
            'url': '/posts/' + questionId + '/flag_options'
        })
        .done(function(data) {
            var items = data['items'];
            var dialog = $(".modal-body").first();
            for (var i = 0; i < items.length; i++) {
                if (!items[i]['has_flagged']) {
                    var flagOption = createFlagOption(items[i], function(item) {
                        return function(ev) {
                            if (item['requires_comment']) {
                                window.flagComment = prompt("Please enter a comment to be sent with this flag:", "");
                            }
                        }
                    });
                    flagOption.prependTo(dialog);
                }
            }
            $(".modal").first().modal('show');
        })
        .error(function(xhr, status, error) {
            bonfire.createNotification('danger', JSON.parse(xhr.responseText)['error_message'], $(".post-flag-link"));
        });
    });

    $(".cast-flag").on("click", function(ev) {
        var checkedOption = $("input[name=flag-option]:checked");
        var selected = checkedOption.val();
        var comment = window.flagComment || null;
        var questionId = $(this).data("questionid");
        var flagType = checkedOption.data("flagtype");
        $.ajax({
            'type': 'POST',
            'url': '/posts/' + questionId + '/flag',
            'data': {
                'option_id': selected,
                'comment': comment,
                'flag_type': flagType
            }
        })
        .done(function(data) {
            $(".modal").modal('hide');
            bonfire.createNotification('success', "Post flagged successfully.", $(".post-flag-link"));
        })
        .error(function(xhr, status, error) {
            $(".modal").modal('hide');
            bonfire.createNotification('danger', JSON.parse(xhr.responseText)['error_message'], $(".post-flag-link"));
        });
    });

    $(document).on("hide.bs.modal", function(ev) {
        $(".modal-body").empty();
    });
});
