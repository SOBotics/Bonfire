var currentQuestionID;

function createFlagOption(item, handler) {
    var container = $("<div></div>");
    container.addClass("clearfix flag-option");
    container.append("<div class='pull-left col-sm-1 col-md-1'><input type='radio' name='flag-option' value='" + item['option_id'] + "' data-flagtype='" + item['title'] + "'/></div>");
    var details = $("<div class='pull-right col-sm-11 col-md-11'></div>");
    
    if('title' in item) {
        details.append("<p><strong>" + item['title'] + "</strong></p>");
    }
    details.append("<p>" +  item['description'] + "</p>");
    container.append(details);

    container.on('click', handler(item));

    return container;
}

function initialiseFlagDialog(items, dialog, empty=true) {
    if (empty == true) {
        $(".modal-body").empty();
    }

    for (var i = 0; i < items.length; i ++) {
        if(!items[i]['has_flagged']) {
            var flagOption = createFlagOption(items[i], function(item) {
                return function(ev) {
                    if (item['requires_comment']) {
                        window.flagComment = prompt("Please enter a comment to be sent with this flag: ", "");
                    }
                    if ('sub_options' in item) {
                        initialiseFlagDialog(item['sub_options'], dialog);
                    }
                }
            });
            flagOption.appendTo(dialog);
        }
    }
}

$(document).ready(function() {
    $(".post-flag-link").on("click", function(ev) {
        ev.preventDefault();
        var questionId = $(this).data("questionid");
        currentQuestionID = questionId;
        $.ajax({
            'type': 'GET',
            'url': '/posts/' + questionId + '/flag_options'
        })
        .done(function(data) {
            var items = data['items'];
            var dialog = $(".modal-body").first();
            var closeVoteItems = null             

            for (var i = 0; i < items.length; i ++) {
                // Pretty hacky and messy, but this *shouldn't* change with time and there is no better option.
                if (items[i]['title'] == 'should be closed...') {
                    if ('sub_options' in items[i]) {
                        closeVoteItems = items[i]['sub_options']
                    }
                }
            }
 
            if (closeVoteItems != null) {
                initialiseFlagDialog(closeVoteItems, dialog, false)
                $(".modal").first().modal('show');
            } else {
                bonfire.createNotification('danger', "No close options available; have you already cast a close vote, or have retracted your vote?", $(".post-flag-link"));
            }
        })
        .error(function(xhr, status, error) {
            bonfire.createNotification('danger', JSON.parse(xhr.responseText)['error_message'], $(".post-flag-link"));
        });
    });

    $(".cast-flag").on("click", function(ev) {
        var checkedOption = $("input[name=flag-option]:checked");
        var selected = checkedOption.val();
        var comment = window.flagComment || null;
        var questionId = currentQuestionID;
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
