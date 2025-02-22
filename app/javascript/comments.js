function showEditForm(commentId) {
  const form = document.getElementById(`edit-form-${commentId}`);
  const body = document.getElementById(`comment-body-${commentId}`);
  form.style.display = (form.style.display === 'none') ? 'block' : 'none';
  body.style.display = (form.style.display === 'none') ? 'block' : 'none';
}
