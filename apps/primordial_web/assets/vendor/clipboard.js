window.addEventListener("primordial_web:clipcopy", (event) => {
    if ("clipboard" in navigator) {        
      const text = event.target.textContent;
      //navigator.clipboard.writeText(text);
      navigator.clipboard.writeText(text).then(() => {
          /* Resolved - text copied to clipboard */
          document.querySelector('.copy-button').classList.add("clicked");
      },() => {
          /* Rejected - clipboard failed */
          alert("Sorry, your browser does not support clipboard copy.");
      });
      
  } else {
    alert("Sorry, your browser does not support clipboard copy.");
  }
});
