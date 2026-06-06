function showEditForm(commentId) {
  const form = document.getElementById(`edit-form-${commentId}`);
  const body = document.getElementById(`comment-body-${commentId}`);
  const toggleButton = document.getElementById(`edit-toggle-${commentId}`);
  form.style.display = (form.style.display === 'none') ? 'block' : 'none';
  body.style.display = (form.style.display === 'none') ? 'block' : 'none';

  if (toggleButton) {
    toggleButton.textContent = (form.style.display === 'none') ? 'Edit' : 'Cancel';
  }
}
