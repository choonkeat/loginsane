(function() {
  function update_history_on_fbdialog() {
    var new_value = document.getElementById('fb_dialog_content');
    if (update_history_on_fbdialog.last_value != new_value) {
      update_history_on_fbdialog.last_value = new_value;
      window.location.replace(window.location.href + ((window.location.hash == "") ? '#FBHISTORY' : '1'));
    }
  }
  setInterval(update_history_on_fbdialog, 1000);
})();
