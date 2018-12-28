import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "numberOfRuns", "finalCommand" ]

  connect() {
    this.numberOfRunsTarget.value = '20'

    this.setFinalCommand()
  }


  // greet() {
  //   this.numberOfRunsTarget.textContent = `Hello, ${this.numberOfRunsTarget.value}!`
  // }


  // copy() {
  //   this.sourceTarget.select()
  //   document.execCommand("copy")
  // }

  setFinalCommand() {
    var numberOfRunsCmd = "-n " + this.numberOfRunsTarget.value;

    this.finalCommandTarget.value = numberOfRunsCmd;
  }
}
