import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "numberOfRuns", "branchName", "finalCommand", "onlyBenchBranch", "runMigrations", "verifyNoDiff" ]

  connect() {
    this.numberOfRunsTarget.value = '20'
    this.branchNameTarget.value = 'master'
    this.setFinalCommand()
  }

  // copy() {
  //   this.sourceTarget.select()
  //   document.execCommand("copy")
  // }

  generateArgumentString(target, prefix) {
    if(target.value != undefined && target.value != ''){
      return prefix + ' ' + target.value;
    } else {
      return '';
    }
  }

  generateArgumentBoolean(target, cmd) {
    if(target.checked){
      return cmd;
    }
  }

  setFinalCommand() {
    var numberOfRunsCmd = this.generateArgumentString(this.numberOfRunsTarget, '-n');
    var branchNameCmd = this.generateArgumentString(this.branchNameTarget, '-r');
    var onlyBenchBranchCmd = this.generateArgumentBoolean(this.onlyBenchBranchTarget, '-q')
    var runMigrationsCmd = this.generateArgumentBoolean(this.runMigrationsTarget, '--run-migrations')
    var verifyNoDiffCmd = this.generateArgumentBoolean(this.verifyNoDiffTarget, '--verify-no-diff')

    this.finalCommandTarget.value = [numberOfRunsCmd, branchNameCmd, onlyBenchBranchCmd, runMigrationsCmd, verifyNoDiffCmd].join(' ');
  }
}
