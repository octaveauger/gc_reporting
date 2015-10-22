$(function () {
	// Update mandate useful data in payments form
	if($('#payment_request_mandate_id').size() > 0) {
		$('#payment_request_mandate_id').on('change', function(e) {
			mandate_url = $('#payment_request_mandate_id').attr('target') + $(this).val() + '.json';
			$.ajax({
				type: "GET",
				url: mandate_url,
				dataType: 'json',
				success: function(data){
					if(data.currency) {
						$('#payment_currency').html(data.currency);
					}
					if(data.next_possible_charge_date) {
						$('#next_possible_charge_date').html(data.next_possible_charge_date_formatted);
						$('#payment_request_charge_date').attr('value', data.next_possible_charge_date);
					}
				}
			});
		});
	}
});