import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "text" ]

  connect() {
    // Put the text fields in the correct state when form is pre-polutated.
    for (let select of this.element.getElementsByTagName('select')) {
      this.change({target: select})
    }
  }

  change(event) {
    this.textTargets.find((text) => {
      text.disabled = (event.target.value != "user")
      // Only focus the field when the UI triggered the event
      if (event.type) text.focus({preventScroll: true})
    })
  }
}
