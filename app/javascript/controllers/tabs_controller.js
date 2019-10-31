import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "tab", "content" ]

  makeCurrent(tab) {
    let selected = this.tabTargets.indexOf(tab)
    this.tabTargets.forEach((tab, index) => {
      if (index == selected) {
        tab.classList.add("current")
      } else {
        tab.classList.remove("current")
      }
    })
    this.contentTargets.forEach((content, index) => {
      content.style.display = (index == selected) ? "block" : "none"
    })
  }

  connect() {
    let tab = this.tabTargets.find((tab) => {
      return window.location == tab.children[0].href
    })
    this.makeCurrent(tab || this.tabTargets[0])
  }

  select(event) {
    event.preventDefault()
    window.location = event.currentTarget.children[0].href
    this.makeCurrent(event.currentTarget)
  }
}
