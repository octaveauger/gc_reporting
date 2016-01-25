$(function () {
  initialize();

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

  //Initialise datepickers - http://bootstrap-datepicker.readthedocs.org/en/stable/
  $('.datepicker').datepicker({
    language: $('#locale').attr('data-value'),
    autoclose: true
  });

  // Show / hide between time filters
  $('select[name="time_filter"]').on('change', function(e) {
    if($(this).val() == 'between') { $('#time-filters-between').removeClass('hide'); }
    else { $('#time-filters-between').addClass('hide'); }
  }).change();

});

function initialize() {
  // Initialise tooltips
  $('[data-toggle="tooltip"]').tooltip();

  // Refresh the syncing loader
  autorefresh_sync_loader();

  // Calls the client modal via ajax
  $('.modal-link[data-target="#client-modal"]').off('click').on('click', function(e) {
    $('#client-modal').find('.modal-content').load($(this).attr('data-path'), function() {
      initialize(); //make sure the usual JS is available post-loading, e.g tooltips
    });
  });

  // Trigger get actions via Ajax (e.g cancel mandate)
  $('a[data-role="ajax-get"]').off('click').on('click', function(e) {
    e.preventDefault();
    $.getScript($(this).attr('data-target'));
  });

  // Horrible hack to fix Simple Form handling of checkbox classes on input for Bootstrap 3
  $('label.checkbox').each(function() {
    $(this).find('input[type="checkbox"]').removeClass('form-control');
  });

  // Management of tagsinput form
  $('[data-role="tagsinput"]').tagsinput({
    confirmKeys: [13, 32, 44] //comma, space and enter trigger it - TODO: space not working
  });
  // Fix for copy/paste - TODO: need to change the appearance, not only the valiue
  $('[data-role="tagsinput"]').off('change').on('change', function(e) {
    $(this).val($(this).val().split(/[ ,]+/).join(','));
  });
}

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