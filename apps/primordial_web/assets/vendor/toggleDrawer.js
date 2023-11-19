const toggleDrawer = (el) => {

        // The event.target element must implement the following dataset:
        // data-drawer-target="#id-my-target-element"
        // data-drawer-class-toggle="class-name-to-add-or-remove"

        const target = el.dataset['drawerTarget'];
        const classToggle = el.dataset['drawerClassToggle'];

        let targetEl = document.querySelector(`#${target}`);

        if (targetEl.classList.contains(classToggle)) {
                targetEl.classList.remove(classToggle);
        }
        else {
                targetEl.classList.add(classToggle);
        }

};

window.addEventListener("primordial_web:toggleDrawer", (event) => {
        const el = event.target
        toggleDrawer(el);
});
