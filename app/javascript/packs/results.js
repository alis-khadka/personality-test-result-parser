$(document).ready(function () {
  $('#file').on('focusout', function () {
    if (this.value) {
      disableOtherFields(this.id);
      values = this.value.split('\\');
      fileName = values[values.length - 1];
    } else {
      fileName = 'Choose file';
      enableOtherFields(this.id);
    }
    $('label.custom-file-label')[0].innerText = fileName;
  });

  $('#text')
    .add('#url')
    .on('focusout', function () {
      console.log(this.value);
      if (this.value) {
        disableOtherFields(this.id);
      } else {
        enableOtherFields(this.id);
      }
    });
});

function disableOtherFields(name, disable = true) {
  var ids = ['file', 'text', 'url'];
  ids
    .filter((e) => e != name)
    .forEach((element) => {
      $(`#${element}`).prop('disabled', disable);
    });
}

function enableOtherFields(name) {
  disableOtherFields(name, false);
}
