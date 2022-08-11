window.addEventListener("primordial_web:clipcopy", (event) => {
  if ("clipboard" in navigator) {
      const text = event.target.textContent;
      navigator.clipboard.writeText(text);
      document.querySelector('.copy-button').classList.add("clicked");
  } else {
    alert("Sorry, your browser does not support clipboard copy.");
  }
});
