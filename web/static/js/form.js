const uploadTrigger = document.querySelector("input[type=file]");

function bindForm() {
  const imagePreview = document.getElementById("image-preview")

  uploadTrigger.onchange = function() {
    let reader = new FileReader();

    reader.onload = (e) => {
      imagePreview.src = e.target.result;
      imagePreview.parentNode.style.display = "block";
    }

    reader.readAsDataURL(this.files[0]);
  }
}

const api = {
  isReady: () => {return uploadTrigger !== null},
  bind: () => bindForm()
}

export default api
