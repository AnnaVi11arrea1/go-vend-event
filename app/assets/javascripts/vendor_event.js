document.addEventListener('DOMContentLoaded', function() {
  var paidCheckbox = document.getElementById('paid-checkbox');
  var applicationStatusInput = document.getElementById('application-status-input');

  if (paidCheckbox) {
    paidCheckbox.addEventListener('change', function() {
      var isChecked = paidCheckbox.checked;
      var vendorEventId = document.querySelector('input[name="vendor_event[id]"]').value;

      fetch(`/vendor_events/${vendorEventId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: JSON.stringify({ vendor_event: { paid: isChecked } })
      })
      .then(response => response.json())
      .then(data => {
        if (data.status === 'success') {
          console.log('Paid status updated successfully');
        } else {
          console.error('Failed to update paid status');
        }
      })
      .catch(error => console.error('Error:', error));
    });
  }

  if (applicationStatusInput) {
    applicationStatusInput.addEventListener('change', function() {
      var newStatus = applicationStatusInput.value;
      var vendorEventId = document.querySelector('input[name="vendor_event[id]"]').value;

      fetch(`/vendor_events/${vendorEventId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: JSON.stringify({ vendor_event: { application_status: newStatus } })
      })
      .then(response => response.json())
      .then(data => {
        if (data.status === 'success') {
          console.log('Application status updated successfully');
        } else {
          console.error('Failed to update application status');
        }
      })
      .catch(error => console.error('Error:', error));
    });
  }
});
