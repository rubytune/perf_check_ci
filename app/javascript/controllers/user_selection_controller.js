import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "text" ]

  change(event) {
    this.textTargets.find((text) => {
      text.disabled = (event.target.value != "user")
      text.focus({preventScroll: true})
    })
  }
}
