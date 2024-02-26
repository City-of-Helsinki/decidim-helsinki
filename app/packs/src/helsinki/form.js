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

    let resetText = form.querySelector(".reset-info");
    if (!resetText) {
      resetText = document.createElement("div");
      resetText.classList.add("show-for-sr");
      resetText.setAttribute("aria-live", "assertive");
      resetText.setAttribute("aria-atomic", true);
      form.append(resetText);
    }

    const message = MESSAGES.resetMessage;
    const messageParts = message.split(" ");

    resetButtons.forEach((reset) => {
      reset.type = "submit";
      reset.addEventListener("click", () => {
        // Force the announcement text to be read if it has been already set to
        // the same value before. This uses two techniques in order to try to
        // make the screen reader understand that this text should be read out
        // loud:
        //
        // 1. Wrap the text in a span with a random attribute value that changes
        //    every time
        // 2. Add a random amount of spaces after the first word of the text
        //    in order to make it seem different than before
        resetText.innerHTML = "";

        setTimeout(() => {
          const announce = document.createElement("span")
          announce.setAttribute("data-random", randomIdentifier("announcement"));
          announce.textContent = [messageParts[0], randomSpaces(), ...messageParts.slice(1)].join(" ");
          resetText.append(announce);
        }, 100);

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
