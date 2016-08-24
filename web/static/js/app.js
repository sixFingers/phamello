import "phoenix_html"

import {connect, handler} from "./socket"
import form from "./form"

connect();

if (form.isReady()) {
  form.bind()
}

function buzzLogotype() {
  document.getElementById("logotype").className += " active";
}

function populatePicture(id, url) {
  let container = document.getElementById(`picture-${id}`)

  if (container) {
    container.firstElementChild.src = url;
  }
}

handler.onPictureReady = function(id, url) {
  buzzLogotype();
  populatePicture(id, url);
}
