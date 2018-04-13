$(document).ready(function() {
    $(".skip-link").on("click", function(ev) {
        var review_action_name = $(this).data("raction");
        var $post = $(this).parent().parent();
        var postId = $post.data("post-id");
        $.ajax({
            'type': 'POST',
            'url': '/review/create',
            'data': {
                'post_id': postId,
                'review_action': review_action_name
            }
        })
        .done(function(data) {
            $post.fadeOut(200, function() {
                $(this).remove();
            });
        })
        .error(function(xhr, status, error) {
            bonfire.createNotification('danger', JSON.parse(xhr.responseText)['error_message'], $(".skip-link"))
        });
    })

    $(".cast-flag").on("click", function(ev) {
        var review_action_name = $(this).data("raction");
        // Yeah, I know what you're thinking...
        var $post = $(this).parent().parent().parent().parent().parent().parent().parent().parent();
        var postId = $post.data("post-id");
        $.ajax({
            'type': 'POST',
            'url': '/review/create',
            'data': {
                'post_id': postId,
                'review_action': review_action_name
            }
        })
        .done(function(data) {
            $post.fadeOut(200, function() {
                $(this).remove();
            });
            $(".modal").modal('hide');
        })
        .error(function(xhr, status, error) {
            console.log(JSON.parse(xhr.responseText)['error_message'])
            bonfire.createNotification('danger', JSON.parse(xhr.responseText)['error_message'], $(".post-flag-link"))
        });
    })
});
