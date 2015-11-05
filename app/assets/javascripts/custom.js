$(function () {
  // Initialise tooltips
  $('[data-toggle="tooltip"]').tooltip();

  // Refresh the syncing loader
  autorefresh_sync_loader();

  // Calls the client modal via ajax
  $('.modal-link[data-target="#client-modal"]').on('click', function(e) {
  	$('#client-modal').find('.modal-content').load($(this).attr('data-path'));
  });

  // Trigger get actions via Ajax (e.g cancel mandate)
  $('a[data-role="ajax-get"]').on('click', function(e) {
  	e.preventDefault();
  	$.getScript($(this).attr('data-target'));
  });

  // Infinite scrolling
  if($('#infinite-scrolling').size() > 0) {
    $(window).on('scroll', function(e) {
      more_url = $('.pagination .next_page a').attr('href');
      if(more_url && $(window).scrollTop() > $(document).height() - $(window).height() - 180) {
        $('.pagination').html('<img src="/assets/ajax-loader.gif" alt="Loading..." title="Loading..." />');
        $.getScript(more_url);
      }
    });
    $(window).scroll(); // Triggers it at page load in case it's not below the fold
  }

  // Horrible hack to fix Simple Form handling of checkbox classes on input for Bootstrap 3
  $('label.checkbox').each(function() {
    $(this).find('input[type="checkbox"]').removeClass('form-control');
  });
});

function autorefresh_sync_loader() {
  if($('#data-syncing-loader').size() > 0) {
    setTimeout(function() {
      $.ajax({
        type: "GET",
        url: $('#data-syncing-loader').attr('data-target'),
        dataType: 'json',
        success: function(data){
          if(data.is_synced) {
            window.location.reload(true);
          }
        }
      });
      autorefresh_sync_loader(); // create loop
    }, 5000); // every 5s
  }
}