import {Socket} from "phoenix"

let socket = new Socket("/socket");
socket.connect();

const token = document.querySelector('meta[name="guardian_token"]').content;
const user_id = document.querySelector('meta[name="current_user"]').content;
let channel = socket.channel(`user:${user_id}`, {guardian_token: token});

channel.on("picture", ({id: id, url: url}) => {
  handler.onPictureReady(id, url);
});

function connect() {
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) });
}

const handler = {
  onPictureReady: function (id, url) {}
}

export {connect, handler}
