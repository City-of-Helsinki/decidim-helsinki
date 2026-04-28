const randomIdentifier = (prefix) => {
  return `${prefix}-${new Date().getUTCMilliseconds()}-${Math.floor(Math.random() * 10000000)}`;
};

const randomSpaces = () => {
  const amount = Math.floor(Math.random() * 100);
  return " ".repeat(amount > 0 ? amount : 1);
}

/**
 * Initializes the dynamic functionality related to forms.
 */
export default (container) => {
  const { dynamicForm: MESSAGES } = window.Decidim.config.get("messages");

  // Changes the behavior of the filter forms reset buttons to clear the values
  // and submit the form.
  container.querySelectorAll("form.new_filter").forEach((form) => {
    const resetButtons = form.querySelectorAll("button[type='reset']")
    if (resetButtons.length < 1) {
      return;
    }

    const initialValues = {};
    for (const pair of (new FormData(form)).entries()) {
      initialValues[pair[0]] = pair[1];
    }

    const message = MESSAGES.resetMessage;

    resetButtons.forEach((reset) => {
      reset.type = "submit";
      reset.addEventListener("click", () => {
        window.Decidim.announceForScreenReader(message);

        form.querySelectorAll("input:not([type='hidden']), textarea, select").forEach((input) => {
          if (input.nodeName === "INPUT") {
            if (input.type === "checkbox" || input.type === "radio") {
              input.checked = false;
            } else if (input.type === "text" || input.type === "search" || input.type === "number") {
              input.value = "";
            }
          } else if (input.nodeName === "TEXTAREA") {
            input.value = "";
          } else if (input.nodeName === "SELECT") {
            // Set the value of the first option for the select elements
            const opt = input.querySelector("option");
            input.value = opt?.value || "";
          }
        })
      });
    });
  });
};
